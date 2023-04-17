import 'dart:collection';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

import '../model/model.dart' show COSConfig;

/// COS请求
class COSClient extends _COSClientBase {
  factory COSClient(COSConfig config) =>
      _instance ??= COSClient._internal(config);
  static COSClient? _instance;

  COSClient._internal(super.config);

  /// PUT
  /// [url] 请求地址
  /// [queryParameters] 请求参数
  /// [body] 请求体
  Future<Response> put(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
  }) {
    return _request(
      method: 'put',
      url: url,
      headers: headers,
      body: body,
    );
  }

  /// POST
  /// [url] 请求地址
  /// [headers] 请求头
  /// [body] 请求体
  Future<Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) {
    return _request(
      method: 'post',
      url: url,
      headers: headers,
      body: body,
    );
  }

  /// GET
  /// [url] 请求地址
  /// [headers] 请求头
  /// [queryParameters] 请求参数
  Future<Response> get(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) {
    return _request(
      method: 'get',
      url: url,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  /// HEAD
  /// [url] 请求地址
  /// [headers] 请求头
  /// [queryParameters] 请求参数
  Future<Response> head(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) {
    return _request(
      method: 'head',
      url: url,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  /// DELETE
  /// [url] 请求地址
  /// [headers] 请求头
  /// [queryParameters] 请求参数
  /// [body] 请求体
  Future<Response> delete(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
  }) {
    return _request(
      method: 'delete',
      url: url,
      headers: headers,
      body: body,
    );
  }

  /// OPTIONS
  /// [url] 请求地址
  /// [headers] 请求头
  /// [queryParameters] 请求参数
  Future<Response> options(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) {
    return _request(
      method: 'options',
      url: url,
      headers: headers,
      queryParameters: queryParameters,
    );
  }
}

class _COSClientBase {
  _COSClientBase(this.config) : _client = Client();

  final COSConfig config;
  final Client _client;

  /// request
  /// [method] 请求方式
  /// [url] 请求地址
  /// [headers] 请求头
  /// [queryParameters] 请求参数
  /// [body] 请求体
  Future<Response> _request({
    required String method,
    required String url,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
  }) async {
    final Uri uri = _joinUri(url, queryParameters);

    final Request request = Request(method, uri);

    _setHeaders(request, headers);

    _setBody(request, body);

    return Response.fromStream(await _client.send(request));
  }

  /// 拼接uri
  /// [url] 请求地址
  /// [queryParameters] 请求参数
  Uri _joinUri(String url, Map<String, String>? queryParameters) {
    String uriString = url;
    if (queryParameters != null && queryParameters.isNotEmpty) {
      if (uriString.contains('?')) {
        uriString += '&';
      } else {
        uriString += '?';
      }
      uriString = queryParameters.keys.fold(uriString,
          (String previousValue, String element) {
        return '$previousValue$element=${queryParameters[element]}&';
      });
      uriString = uriString.substring(0, uriString.length - 1);
    }
    final Uri uri = Uri.parse(uriString);
    return uri;
  }

  /// 设置headers
  /// [request] http request
  /// [headers] 请求头
  void _setHeaders(Request request, Map<String, String>? headers) {
    final Uri uri = request.url;

    if (headers != null && headers.isNotEmpty) {
      request.headers.addAll(headers);
    }
    request.headers['Host'] = uri.authority;
    request.headers['Date'] = formatHttpDate(DateTime.now());

    final String authorization = _generateSign(
      method: request.method,
      path: uri.path,
      headers: request.headers,
      queryParameters: uri.queryParameters,
    );

    request.headers['Authorization'] = authorization;
  }

  /// 设置body
  /// [request] http request
  /// [body] 请求体
  void _setBody(Request request, Object? body) {
    // if (encoding != null) request.encoding = encoding;

    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body.cast<int>();
      } else if (body is Map) {
        request.bodyFields = body.cast<String, String>();
      } else {
        throw ArgumentError('Invalid request body "$body".');
      }
    }
  }

  /// 签名
  /// [method] 请求方式
  /// [path] 请求路径
  /// [headers] 请求头
  /// [queryParameters] 请求参数
  String _generateSign({
    required String method,
    String path = '',
    required Map<String, String> headers,
    Map<String, String>? queryParameters,
  }) {
    // 1. 生成 KeyTime
    final int startTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final int endTime = startTime + 1000 * 60;
    String keyTime = '$startTime;$endTime';

    // 2. 生成 SignKey
    final String signKey = _hmacSha1(config.secretKey, keyTime);

    // 3. 生成 UrlParamList 和 HttpParameters
    String urlParamList = '';
    String httpParameters = '';
    if (queryParameters?.isNotEmpty ?? false) {
      final List<String> params = _joinParams(queryParameters!);
      urlParamList = params[0];
      httpParameters = params[1];
    }

    // 4. 生成 HeaderList 和 HttpHeaders
    final List<String> params = _joinParams(headers);
    final String headerList = params[0];
    final String httpHeaders = params[1];

    // 5. 生成 HttpString
    final String httpString =
        '${method.toLowerCase()}\n$path\n$httpParameters\n$httpHeaders\n';

    // 6. 生成 StringToSign
    final String stringToSign =
        'sha1\n$keyTime\n${sha1.convert(utf8.encode(httpString)).toString()}\n';

    // 7. 生成Signature
    final String signature = _hmacSha1(signKey, stringToSign);

    /// 8. 生成签名
    final StringBuffer result = StringBuffer('q-sign-algorithm=sha1')
      ..write('&q-ak=${config.secretId}')
      ..write('&q-sign-time=$keyTime')
      ..write('&q-key-time=$keyTime')
      ..write('&q-header-list=$headerList')
      ..write('&q-url-param-list=$urlParamList')
      ..write('&q-signature=$signature');
    return result.toString();
  }

  /// hmacSha1加密
  /// [key] 密钥
  /// [value] 加密内容
  String _hmacSha1(String key, String value) {
    return Hmac(sha1, key.codeUnits).convert(value.codeUnits).toString();
  }

  /// 拼接参数
  /// [params] 参数
  List<String> _joinParams(Map<String, String> params) {
    final SplayTreeMap<String, String> sortedMap = SplayTreeMap.from(params);
    final List<String> paramLists = <String>[];
    final List<String> httpParams = <String>[];
    sortedMap.map((String key, String value) {
      return MapEntry(
        Uri.encodeComponent(key).toLowerCase(),
        Uri.encodeComponent(value),
      );
    }).forEach((key, value) {
      paramLists.add(key);
      httpParams.add('$key=$value');
    });
    final String paramListString = paramLists.join(';');
    final String httpParamsString = httpParams.join('&');
    return <String>[paramListString, httpParamsString];
  }
}
