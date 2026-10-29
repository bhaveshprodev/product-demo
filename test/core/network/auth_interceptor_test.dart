import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_demo/core/network/auth_interceptor.dart';
import 'package:product_demo/core/network/auth_token_refresher.dart';
import 'package:product_demo/core/network/session_expiry_notifier.dart';

import '../../helpers/fake_network.dart';

void main() {
  group('AuthInterceptor', () {
    late FakeAuthStorage storage;
    late SessionExpiryNotifier sessionExpiry;
    late int refreshCalls;
    late Dio apiDio;

    Dio buildApi(FakeAdapter adapter, Dio refreshDio) {
      final dio = dioWith(adapter);
      dio.interceptors.add(
        AuthInterceptor(
          storage,
          AuthTokenRefresher(refreshDio, storage),
          sessionExpiry,
          dio,
        ),
      );
      return dio;
    }

    Dio refreshDio(Future<ResponseBody> Function(RequestOptions) handler) {
      return dioWith(
        FakeAdapter((options) {
          refreshCalls++;
          return handler(options);
        }),
      );
    }

    setUp(() {
      storage = FakeAuthStorage(token: 'expired', refreshToken: 'refresh-1');
      sessionExpiry = SessionExpiryNotifier();
      refreshCalls = 0;
    });

    tearDown(() => sessionExpiry.dispose());

    test('attaches the bearer token to authenticated requests', () async {
      String? sentHeader;
      apiDio = buildApi(
        FakeAdapter((options) async {
          sentHeader = options.headers['Authorization'] as String?;
          return jsonResponse(200, {'ok': true});
        }),
        refreshDio((_) async => jsonResponse(200, {'accessToken': 'fresh'})),
      );

      await apiDio.get<dynamic>('/products');

      expect(sentHeader, 'Bearer expired');
      expect(refreshCalls, 0);
    });

    test('refreshes once on 401 and replays the original request', () async {
      var expiredEvents = 0;
      final subscription = sessionExpiry.onExpired.listen((_) {
        expiredEvents++;
      });
      addTearDown(subscription.cancel);

      final productCalls = <String?>[];
      apiDio = buildApi(
        FakeAdapter((options) async {
          final auth = options.headers['Authorization'] as String?;
          productCalls.add(auth);
          if (auth == 'Bearer fresh') {
            return jsonResponse(200, {'ok': true});
          }
          return jsonResponse(401, {'message': 'Token expired'});
        }),
        refreshDio(
          (_) async =>
              jsonResponse(200, {'accessToken': 'fresh', 'refreshToken': 'r2'}),
        ),
      );

      final response = await apiDio.get<dynamic>('/products');

      expect(response.data, {'ok': true});
      expect(productCalls, ['Bearer expired', 'Bearer fresh']);
      expect(refreshCalls, 1);
      expect(storage.token, 'fresh');
      expect(storage.refreshToken, 'r2');
      expect(expiredEvents, 0);
    });

    test('queues parallel 401s behind a single refresh', () async {
      final gate = Completer<void>();
      apiDio = buildApi(
        FakeAdapter((options) async {
          final auth = options.headers['Authorization'] as String?;
          if (auth == 'Bearer fresh') {
            return jsonResponse(200, {'ok': true});
          }
          return jsonResponse(401, {'message': 'Token expired'});
        }),
        refreshDio((_) async {
          await gate.future;
          return jsonResponse(200, {'accessToken': 'fresh'});
        }),
      );

      final requests = [
        apiDio.get<dynamic>('/products'),
        apiDio.get<dynamic>('/products'),
        apiDio.get<dynamic>('/products'),
      ];

      // Let all three requests fail with 401 and join the refresh.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(refreshCalls, 1);

      gate.complete();
      final responses = await Future.wait(requests);

      expect(responses, everyElement(isA<Response<dynamic>>()));
      expect(
        responses.map((response) => response.data),
        everyElement({'ok': true}),
      );
      expect(refreshCalls, 1);
    });

    test('clears the session when the refresh token is rejected', () async {
      var expiredEvents = 0;
      final subscription = sessionExpiry.onExpired.listen((_) {
        expiredEvents++;
      });
      addTearDown(subscription.cancel);

      apiDio = buildApi(
        FakeAdapter(
          (options) async => jsonResponse(401, {'message': 'Token expired'}),
        ),
        refreshDio(
          (_) async => jsonResponse(401, {'message': 'Invalid refresh token'}),
        ),
      );

      await expectLater(
        apiDio.get<dynamic>('/products'),
        throwsA(
          isA<DioException>().having(
            (error) => error.response?.statusCode,
            'status',
            401,
          ),
        ),
      );

      await Future<void>.delayed(Duration.zero);
      expect(storage.token, isNull);
      expect(storage.refreshToken, isNull);
      expect(storage.clearCount, 1);
      expect(expiredEvents, 1);
    });

    test(
      'keeps the session when the refresh cannot reach the server',
      () async {
        var expiredEvents = 0;
        final subscription = sessionExpiry.onExpired.listen((_) {
          expiredEvents++;
        });
        addTearDown(subscription.cancel);

        apiDio = buildApi(
          FakeAdapter(
            (options) async => jsonResponse(401, {'message': 'Token expired'}),
          ),
          refreshDio(
            (options) async => throw DioException(
              requestOptions: options,
              type: DioExceptionType.connectionError,
            ),
          ),
        );

        await expectLater(
          apiDio.get<dynamic>('/products'),
          throwsA(isA<DioException>()),
        );

        await Future<void>.delayed(Duration.zero);
        expect(storage.token, 'expired');
        expect(storage.refreshToken, 'refresh-1');
        expect(storage.clearCount, 0);
        expect(expiredEvents, 0);
      },
    );

    test('does not try to refresh a rejected login', () async {
      apiDio = buildApi(
        FakeAdapter(
          (options) async =>
              jsonResponse(401, {'message': 'Invalid credentials'}),
        ),
        refreshDio((_) async => jsonResponse(200, {'accessToken': 'fresh'})),
      );

      await expectLater(
        apiDio.post<dynamic>('/auth/login'),
        throwsA(isA<DioException>()),
      );

      expect(refreshCalls, 0);
      expect(storage.token, 'expired');
    });
  });
}
