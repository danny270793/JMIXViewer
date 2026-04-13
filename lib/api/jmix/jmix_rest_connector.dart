import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../logging/app_logger.dart';
import 'jmix_api_exception.dart';
import 'jmix_client_config.dart';
import 'models/jmix_entity_list_result.dart';
import 'models/jmix_error.dart';

/// Resolves the current Bearer token for [JmixRestConnector] (if any).
typedef AccessTokenProvider = String? Function();

/// Provides typed HTTP access to the Jmix Generic REST API
/// ([openapi/rest-openapi.yaml](https://docs.jmix.io/openapi/2.8/rest-openapi.yaml)).
///
/// Pass an [accessTokenProvider] after obtaining a [JmixToken] via [JmixOAuthConnector],
/// or leave it null only if the server allows anonymous access to the routes you call.
class JmixRestConnector {
  JmixRestConnector({
    required JmixClientConfig config,
    Dio? dio,
    this.accessTokenProvider,
  }) {
    var baseStr = config.restBaseUri.toString();
    if (!baseStr.endsWith('/')) {
      baseStr = '$baseStr/';
    }
    _dio = dio ?? Dio();
    if (_dio.options.baseUrl.isEmpty) {
      _dio.options = _dio.options.copyWith(
        baseUrl: baseStr,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        validateStatus: (code) => code != null && code < 500,
        responseType: ResponseType.json,
      );
    }
    _dio.interceptors.add(HttpRequestUrlInterceptor());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = accessTokenProvider?.call();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  late final Dio _dio;

  /// Returns the current access token for each request (e.g. from secure storage).
  AccessTokenProvider? accessTokenProvider;

  // --- Entities ---

  Future<JmixEntityListResult> loadEntities(
    String entityName, {
    String? fetchPlan,
    String? limit,
    String? offset,
    String? sort,
    bool? returnCount,
    bool? dynamicAttributes,
  }) async {
    final r = await _getList(
      'entities/${_enc(entityName)}',
      query: _nonNullQuery({
        'fetchPlan': fetchPlan,
        'limit': limit,
        'offset': offset,
        'sort': sort,
        'returnNulls': true,
        'returnCount': returnCount,
        'dynamicAttributes': dynamicAttributes,
      }),
    );
    return r;
  }

  Future<Map<String, dynamic>> loadEntity(
    String entityName,
    String entityId, {
    String? fetchPlan,
    bool? dynamicAttributes,
  }) {
    return _getMap(
      'entities/${_enc(entityName)}/${_enc(entityId)}',
      query: _nonNullQuery({
        'fetchPlan': fetchPlan,
        'returnNulls': true,
        'dynamicAttributes': dynamicAttributes,
      }),
    );
  }

  Future<Map<String, dynamic>> createEntity(
    String entityName,
    Map<String, dynamic> body,
  ) {
    return _postMap(
      'entities/${_enc(entityName)}',
      data: body,
      expectStatus: 201,
    );
  }

  Future<Map<String, dynamic>> updateEntity(
    String entityName,
    String entityId,
    Map<String, dynamic> body,
  ) {
    return _putMap(
      'entities/${_enc(entityName)}/${_enc(entityId)}',
      data: body,
    );
  }

  Future<void> deleteEntity(String entityName, String entityId) async {
    await _delete('entities/${_enc(entityName)}/${_enc(entityId)}');
  }

  Future<JmixEntityListResult> searchEntitiesGet(
    String entityName,
    Map<String, dynamic> filter, {
    String? fetchPlan,
    String? limit,
    String? offset,
    String? sort,
    bool? returnCount,
    bool? dynamicAttributes,
  }) async {
    final filterJson = jsonEncode(filter);
    final r = await _getList(
      'entities/${_enc(entityName)}/search',
      query: _nonNullQuery({
        'filter': filterJson,
        'fetchPlan': fetchPlan,
        'limit': limit,
        'offset': offset,
        'sort': sort,
        'returnNulls': true,
        'returnCount': returnCount,
        'dynamicAttributes': dynamicAttributes,
      }),
    );
    return r;
  }

  /// Search with filter and list options in the JSON body; null optionals omitted.
  Future<JmixEntityListResult> searchEntitiesPost(
    String entityName,
    Map<String, dynamic> filterBody, {
    String? fetchPlan,
    String? limit,
    String? offset,
    String? sort,
    bool? returnCount,
    bool? dynamicAttributes,
  }) async {
    final r = await _dio.post<dynamic>(
      'entities/${_enc(entityName)}/search',
      data: _nonNullQuery({
        'filter': filterBody,
        'fetchPlan': fetchPlan,
        'limit': limit,
        'offset': offset,
        'sort': sort,
        'returnNulls': true,
        'returnCount': returnCount,
        'dynamicAttributes': dynamicAttributes,
      }),
      options: Options(responseType: ResponseType.json),
    );
    _throwIfError(r);
    final list = _asMapList(r.data);
    return JmixEntityListResult(
      items: list,
      totalCount: _parseTotalCount(r.headers),
    );
  }

  // --- Queries ---

  Future<List<Map<String, dynamic>>> listQueries(String entityName) async {
    final r = await _dio.get<dynamic>('queries/${_enc(entityName)}');
    _throwIfError(r);
    return _asMapList(r.data);
  }

  Future<JmixEntityListResult> executeQueryGet(
    String entityName,
    String queryName, {
    String? limit,
    String? offset,
    String? fetchPlan,
    bool? returnCount,
    bool? dynamicAttributes,
    Map<String, String>? queryParameters,
  }) async {
    final q = _nonNullQuery({
      'limit': limit,
      'offset': offset,
      'fetchPlan': fetchPlan,
      'returnCount': returnCount,
      'dynamicAttributes': dynamicAttributes,
      ...?queryParameters,
      'returnNulls': true,
    });
    final r = await _getList(
      'queries/${_enc(entityName)}/${_enc(queryName)}',
      query: q,
    );
    return r;
  }

  /// Optional [body] for JPQL parameter map when the server expects a JSON body (see Jmix docs).
  Future<JmixEntityListResult> executeQueryPost(
    String entityName,
    String queryName, {
    String? limit,
    String? offset,
    String? fetchPlan,
    bool? returnCount,
    bool? dynamicAttributes,
    Map<String, dynamic>? body,
  }) async {
    final q = _nonNullQuery({
      'limit': limit,
      'offset': offset,
      'fetchPlan': fetchPlan,
      'returnNulls': true,
      'returnCount': returnCount,
      'dynamicAttributes': dynamicAttributes,
    });
    final r = await _dio.post<dynamic>(
      'queries/${_enc(entityName)}/${_enc(queryName)}',
      queryParameters: q.isEmpty ? null : q,
      data: body,
      options: Options(responseType: ResponseType.json),
    );
    _throwIfError(r);
    return JmixEntityListResult(
      items: _asMapList(r.data),
      totalCount: _parseTotalCount(r.headers),
    );
  }

  Future<int> countQueryGet(String entityName, String queryName) async {
    final r = await _dio.get<dynamic>(
      'queries/${_enc(entityName)}/${_enc(queryName)}/count',
    );
    _throwIfError(r);
    return _asCount(r.data);
  }

  Future<int> countQueryPost(String entityName, String queryName) async {
    final r = await _dio.post<dynamic>(
      'queries/${_enc(entityName)}/${_enc(queryName)}/count',
    );
    _throwIfError(r);
    return _asCount(r.data);
  }

  // --- Services ---

  Future<List<Map<String, dynamic>>> listServiceMethods(String serviceName) async {
    final r = await _dio.get<dynamic>('services/${_enc(serviceName)}');
    _throwIfError(r);
    return _asMapList(r.data);
  }

  Future<dynamic> invokeServiceGet(
    String serviceName,
    String methodName, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final r = await _dio.get<dynamic>(
      'services/${_enc(serviceName)}/${_enc(methodName)}',
      queryParameters: queryParameters,
    );
    _throwIfError(r);
    if (r.statusCode == 204) return null;
    return r.data;
  }

  Future<dynamic> invokeServicePost(
    String serviceName,
    String methodName,
    Object? data,
  ) async {
    final r = await _dio.post<dynamic>(
      'services/${_enc(serviceName)}/${_enc(methodName)}',
      data: data,
      options: Options(responseType: ResponseType.json),
    );
    _throwIfError(r);
    if (r.statusCode == 204) return null;
    return r.data;
  }

  // --- Files ---

  Future<JmixFileInfo> uploadMultipart({
    required List<int> fileBytes,
    required String fileName,
    String? nameQuery,
    String? storageName,
    String? contentType,
  }) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
        contentType:
            contentType != null ? MediaType.parse(contentType) : null,
      ),
    });
    final q = _nonNullQuery({'name': nameQuery, 'storageName': storageName});
    final r = await _dio.post<Map<String, dynamic>>(
      'files',
      queryParameters: q.isEmpty ? null : q,
      data: form,
    );
    _throwIfError(r);
    final data = r.data;
    if (data == null) {
      throw JmixApiException(message: 'Empty upload response', statusCode: r.statusCode);
    }
    return JmixFileInfo.fromJson(data);
  }

  Future<List<int>> downloadFile(
    String id, {
    bool attachment = false,
  }) async {
    final r = await _dio.get<List<int>>(
      'files/${_enc(id)}',
      queryParameters: _nonNullQuery({'attachment': attachment}),
      options: Options(responseType: ResponseType.bytes),
    );
    _throwIfError(r);
    return r.data ?? Uint8List(0);
  }

  // --- Metadata ---

  Future<List<Map<String, dynamic>>> metadataListEntities() async {
    final r = await _dio.get<dynamic>('metadata/entities');
    _throwIfError(r);
    return _asMapList(r.data);
  }

  Future<Map<String, dynamic>> metadataGetEntity(String entityName) {
    return _getMap('metadata/entities/${_enc(entityName)}');
  }

  Future<List<Map<String, dynamic>>> metadataListFetchPlans(String entityName) async {
    final r = await _dio.get<dynamic>(
      'metadata/entities/${_enc(entityName)}/fetchPlans',
    );
    _throwIfError(r);
    return _asMapList(r.data);
  }

  Future<Map<String, dynamic>> metadataGetFetchPlan(
    String entityName,
    String fetchPlanName,
  ) {
    return _getMap(
      'metadata/entities/${_enc(entityName)}/fetchPlans/${_enc(fetchPlanName)}',
    );
  }

  Future<List<Map<String, dynamic>>> metadataListEnums() async {
    final r = await _dio.get<dynamic>('metadata/enums');
    _throwIfError(r);
    return _asMapList(r.data);
  }

  Future<Map<String, dynamic>> metadataGetEnum(String enumName) {
    return _getMap('metadata/enums/${_enc(enumName)}');
  }

  Future<List<Map<String, dynamic>>> metadataListDatatypes() async {
    final r = await _dio.get<dynamic>('metadata/datatypes');
    _throwIfError(r);
    return _asMapList(r.data);
  }

  // --- Messages ---

  Future<Map<String, dynamic>> messagesEntities() {
    return _getMap('messages/entities');
  }

  /// Prefer [messagesEntities] when possible; the bulk map usually includes
  /// per-entity keys (e.g. `EntityName.attribute`) so a second GET is redundant.
  Future<Map<String, dynamic>> messagesEntity(String entityName) {
    return _getMap('messages/entities/${_enc(entityName)}');
  }

  Future<Map<String, dynamic>> messagesEnums() {
    return _getMap('messages/enums');
  }

  Future<Map<String, dynamic>> messagesEnum(String enumName) {
    return _getMap('messages/enums/${_enc(enumName)}');
  }

  // --- Permissions & user ---

  Future<Map<String, dynamic>> getPermissions() {
    return _getMap('permissions');
  }

  Future<JmixUserInfo> getUserInfo() async {
    final m = await _getMap('userInfo');
    return JmixUserInfo.fromJson(m);
  }

  Future<Map<String, dynamic>> getCapabilities() {
    return _getMap('capabilities');
  }

  // --- Internals ---

  String _enc(String s) => Uri.encodeComponent(s);

  Map<String, dynamic> _nonNullQuery(Map<String, dynamic> input) {
    final out = <String, dynamic>{};
    input.forEach((k, v) {
      if (v != null) out[k] = v;
    });
    return out;
  }

  Future<JmixEntityListResult> _getList(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final r = await _dio.get<dynamic>(
      path,
      queryParameters: query,
    );
    _throwIfError(r);
    return JmixEntityListResult(
      items: _asMapList(r.data),
      totalCount: _parseTotalCount(r.headers),
    );
  }

  Future<Map<String, dynamic>> _getMap(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final r = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: query,
    );
    _throwIfError(r);
    final data = r.data;
    if (data == null) {
      throw JmixApiException(message: 'Empty response', statusCode: r.statusCode);
    }
    return data;
  }

  Future<Map<String, dynamic>> _postMap(
    String path, {
    required Map<String, dynamic> data,
    int expectStatus = 200,
  }) async {
    final r = await _dio.post<Map<String, dynamic>>(path, data: data);
    _throwIfError(r);
    final out = r.data;
    if (out == null) {
      throw JmixApiException(message: 'Empty response', statusCode: r.statusCode);
    }
    return out;
  }

  Future<Map<String, dynamic>> _putMap(
    String path, {
    required Map<String, dynamic> data,
  }) async {
    final r = await _dio.put<Map<String, dynamic>>(path, data: data);
    _throwIfError(r);
    final out = r.data;
    if (out == null) {
      throw JmixApiException(message: 'Empty response', statusCode: r.statusCode);
    }
    return out;
  }

  Future<void> _delete(String path) async {
    final r = await _dio.delete<void>(path);
    _throwIfError(r);
  }

  void _throwIfError(Response<dynamic> r) {
    final code = r.statusCode ?? 0;
    if (code >= 200 && code < 300) return;
    final data = r.data;
    if (data is Map<String, dynamic>) {
      if (data.containsKey('details') || data.containsKey('error')) {
        final err = JmixError.fromJson(data);
        throw JmixApiException(
          message: err.details ?? err.error ?? 'Request failed',
          statusCode: code,
          error: err,
        );
      }
    }
    throw JmixApiException(
      message: 'HTTP $code',
      statusCode: code,
      rawBody: data?.toString(),
    );
  }

  List<Map<String, dynamic>> _asMapList(dynamic data) {
    if (data is! List) {
      throw JmixApiException(message: 'Expected JSON array');
    }
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  int _asCount(dynamic data) {
    if (data is int) return data;
    if (data is num) return data.toInt();
    throw JmixApiException(message: 'Expected count integer');
  }

  int? _parseTotalCount(Headers headers) {
    final raw = headers.value('x-total-count');
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }
}
