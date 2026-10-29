import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_demo/core/network/auth_token_refresher.dart';

import '../../helpers/fake_network.dart';

void main() {
  group('AuthTokenRefresher', () {
    test('exchanges the refresh token and stores the rotated pair', () async {
      final storage = FakeAuthStorage(
        token: 'expired',
        refreshToken: 'refresh-1',
      );
      final requests = <Map<String, dynamic>>[];
      final dio = dioWith(
        FakeAdapter((options) async {
          requests.add(options.data as Map<String, dynamic>);
          return jsonResponse(200, {
            'accessToken': 'fresh',
            'refreshToken': 'refresh-2',
          });
        }),
      );

      final result = await AuthTokenRefresher(dio, storage).refresh();

      expect(result, isA<TokenRefreshed>());
      expect((result as TokenRefreshed).accessToken, 'fresh');
      expect(storage.token, 'fresh');
      expect(storage.refreshToken, 'refresh-2');
      expect(requests, hasLength(1));
      expect(requests.single['refreshToken'], 'refresh-1');
    });

    test('shares one request between parallel callers', () async {
      final storage = FakeAuthStorage(
        token: 'expired',
        refreshToken: 'refresh-1',
      );
      final gate = Completer<void>();
      var calls = 0;
      final dio = dioWith(
        FakeAdapter((options) async {
          calls++;
          await gate.future;
          return jsonResponse(200, {'accessToken': 'fresh'});
        }),
      );

      final refresher = AuthTokenRefresher(dio, storage);
      final futures = [
        refresher.refresh(),
        refresher.refresh(),
        refresher.refresh(),
      ];

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(calls, 1);

      gate.complete();
      final results = await Future.wait(futures);

      expect(results, everyElement(isA<TokenRefreshed>()));
      expect(calls, 1);
      expect(storage.token, 'fresh');
    });

    test('reports a rejected refresh token without clearing storage', () async {
      final storage = FakeAuthStorage(
        token: 'expired',
        refreshToken: 'invalid',
      );
      final dio = dioWith(
        FakeAdapter(
          (options) async => jsonResponse(401, {'message': 'Invalid token'}),
        ),
      );

      final result = await AuthTokenRefresher(dio, storage).refresh();

      expect(result, isA<TokenRefreshRejected>());
      expect(storage.token, 'expired');
      expect(storage.refreshToken, 'invalid');
    });

    test('reports a network failure without clearing storage', () async {
      final storage = FakeAuthStorage(
        token: 'expired',
        refreshToken: 'refresh-1',
      );
      final dio = dioWith(
        FakeAdapter(
          (options) async => throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          ),
        ),
      );

      final result = await AuthTokenRefresher(dio, storage).refresh();

      expect(result, isA<TokenRefreshUnavailable>());
      expect(storage.token, 'expired');
      expect(storage.refreshToken, 'refresh-1');
    });

    test('does not call the API when no refresh token is stored', () async {
      final storage = FakeAuthStorage(token: 'expired');
      var calls = 0;
      final dio = dioWith(
        FakeAdapter((options) async {
          calls++;
          return jsonResponse(200, {'accessToken': 'fresh'});
        }),
      );

      final result = await AuthTokenRefresher(dio, storage).refresh();

      expect(result, isA<TokenRefreshRejected>());
      expect(calls, 0);
    });
  });
}
