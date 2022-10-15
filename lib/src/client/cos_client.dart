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

  Future<Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _request(
      method: 'put',
      url: url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

  Future<Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) {
    return _request(
      method: 'post',
      url: url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

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

  Future<Response> delete(
    String url, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
    Encoding? encoding,
  }) {
    return _request(
      method: 'delete',
      url: url,
      headers: headers,
      body: body,
      encoding: encoding,
    );
  }

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

  /// 请求
  Future<Response> _request({
    required String method,
    required String url,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Object? body,
    Encoding? encoding,
  }) async {
    String uriString = url;
    if (queryParameters != null && queryParameters.isNotEmpty) {
      if (uriString.contains('?')) {
        uriString += '&';
      }
      uriString = queryParameters.keys.fold('$uriString?',
          (String previousValue, String element) {
        return '$previousValue$element=${queryParameters[element]}&';
      });
      uriString = uriString.substring(0, uriString.length - 1);
    }
    final Uri uri = Uri.parse(uriString);

    final Request request = Request(method, uri);

    if (headers != null && headers.isNotEmpty) {
      request.headers.addAll(headers);
    }
    request.headers['Host'] = uri.authority;
    request.headers['Date'] = formatHttpDate(DateTime.now());
    final String authorization = _generateSign(
      method: method,
      path: uri.path,
      headers: request.headers,
      queryParameters: uri.queryParameters,
    );
    request.headers['Authorization'] = authorization;

    if (encoding != null) request.encoding = encoding;

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

    return Response.fromStream(await _client.send(request));
  }

  /// 签名
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
      final List<String> params = _processParams(queryParameters!);
      urlParamList = params[0];
      httpParameters = params[1];
    }

    // 4. 生成 HeaderList 和 HttpHeaders
    final List<String> params = _processParams(headers);
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
    final StringBuffer result = StringBuffer('q-sign-algorithm=sha1');
    result
      ..write('&q-ak=${config.secretId}')
      ..write('&q-sign-time=$keyTime')
      ..write('&q-key-time=$keyTime')
      ..write('&q-header-list=$headerList')
      ..write('&q-url-param-list=$urlParamList')
      ..write('&q-signature=$signature');
    return result.toString();
  }

  /// hmacSha1加密
  String _hmacSha1(String key, String value) {
    return Hmac(sha1, key.codeUnits).convert(value.codeUnits).toString();
  }

  /// 处理参数拼接
  List<String> _processParams(Map<String, String> params) {
    final SplayTreeMap<String, String> sortedMap = SplayTreeMap.from(params);
    final StringBuffer paramListBuffer = StringBuffer();
    final StringBuffer httpParamsBuffer = StringBuffer();
    for (int i = 0; i < sortedMap.keys.length; i++) {
      String key = sortedMap.keys.elementAt(i);
      key = Uri.encodeComponent(key).toLowerCase();
      String value = sortedMap.values.elementAt(i);
      value = Uri.encodeComponent(value);

      paramListBuffer.write(key);
      httpParamsBuffer
        ..write(key)
        ..write('=')
        ..write(value);
      if (i < sortedMap.keys.length - 1) {
        paramListBuffer.write(';');
        httpParamsBuffer.write('&');
      }
    }
    final String paramList = paramListBuffer.toString();
    final String httpParams = httpParamsBuffer.toString();
    return [paramList, httpParams];
  }
}
