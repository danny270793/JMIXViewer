import 'dart:convert';

import 'package:dio/dio.dart';

import '../../logging/app_logger.dart';
import 'jmix_api_exception.dart';
import 'jmix_client_config.dart';
import 'models/jmix_error.dart';
import 'models/jmix_token.dart';

/// OAuth2 client for obtaining access tokens used with [JmixRestConnector].
///
/// Uses the token schema from the OpenAPI spec (`components.schemas.token`).
/// Default paths follow the Jmix Authorization Server add-on (`oauth2/token`).
class JmixOAuthConnector {
  JmixOAuthConnector({
    required this.config,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                validateStatus: (code) => code != null && code < 500,
              ),
            ) {
    _dio.interceptors.add(HttpRequestUrlInterceptor());
  }

  final JmixClientConfig config;
  final Dio _dio;

  /// Resource Owner Password Credentials grant.
  Future<JmixToken> obtainTokenWithPassword({
    required String username,
    required String password,
    String clientId = 'client',
    String? clientSecret,
    String scope = 'rest-api',
  }) async {
    final body = <String, dynamic>{
      'grant_type': 'password',
      'username': username,
      'password': password,
      'client_id': clientId,
      'scope': scope,
    };
    if (clientSecret != null) {
      body['client_secret'] = clientSecret;
    }
    return _postToken(body);
  }

  /// Client Credentials grant (RFC 6749). Uses `Authorization: Basic` with
  /// Base64(`clientId:clientSecret`) and body `grant_type=client_credentials`.
  Future<JmixToken> obtainTokenWithClientCredentials({
    required String clientId,
    required String clientSecret,
  }) async {
    final basic = base64Encode(utf8.encode('$clientId:$clientSecret'));
    return _postToken(
      {'grant_type': 'client_credentials'},
      authorizationBasic: basic,
    );
  }

  /// Refresh token grant.
  Future<JmixToken> refreshToken({
    required String refreshToken,
    String clientId = 'client',
    String? clientSecret,
  }) async {
    final body = <String, dynamic>{
      'grant_type': 'refresh_token',
      'refresh_token': refreshToken,
      'client_id': clientId,
    };
    if (clientSecret != null) {
      body['client_secret'] = clientSecret;
    }
    return _postToken(body);
  }

  Future<JmixToken> _postToken(
    Map<String, dynamic> body, {
    String? authorizationBasic,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        config.tokenUri.toString(),
        data: body,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
          headers: authorizationBasic != null
              ? <String, String>{'Authorization': 'Basic $authorizationBasic'}
              : null,
        ),
      );
      final code = response.statusCode ?? 0;
      final data = response.data;
      if (code >= 200 && code < 300 && data != null) {
        return JmixToken.fromJson(data);
      }
      if (data != null && data.containsKey('error')) {
        final oauthErr = JmixOAuthError.fromJson(data);
        throw JmixApiException(
          message: oauthErr.errorDescription ?? oauthErr.error ?? 'OAuth error',
          statusCode: code,
        );
      }
      if (data != null && data.containsKey('details')) {
        final err = JmixError.fromJson(data);
        throw JmixApiException(
          message: err.details ?? err.error ?? 'Token request failed',
          statusCode: code,
          error: err,
        );
      }
      throw JmixApiException(
        message: 'Token request failed',
        statusCode: code,
        rawBody: response.data?.toString(),
      );
    } on JmixApiException {
      rethrow;
    } catch (e) {
      throw JmixApiException.fromDio(e);
    }
  }
}
