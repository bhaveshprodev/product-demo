import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:product_demo/core/storage/auth_storage.dart';

class FakeAuthStorage implements AuthStorage {
  FakeAuthStorage({this.token, this.refreshToken, this.user});

  String? token;
  String? refreshToken;
  String? user;
  int clearCount = 0;

  @override
  Future<void> writeToken(String value) async => token = value;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeRefreshToken(String value) async => refreshToken = value;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<void> writeUser(String json) async => user = json;

  @override
  Future<String?> readUser() async => user;

  @override
  Future<void> clear() async {
    clearCount++;
    token = null;
    refreshToken = null;
    user = null;
  }
}

/// Minimal Dio adapter so network behaviour can be scripted in tests without
/// adding another dependency.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(int statusCode, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Dio dioWith(FakeAdapter adapter, {String baseUrl = 'https://dummyjson.com'}) {
  return Dio(BaseOptions(baseUrl: baseUrl))..httpClientAdapter = adapter;
}
