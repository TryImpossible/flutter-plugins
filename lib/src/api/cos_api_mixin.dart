import 'dart:convert';

import 'package:http/http.dart' show Response;
import 'package:xml/xml.dart';

import '../model/model.dart' show COSException;
import 'cos_abstract_api.dart';

/// xml 解析器
typedef XmlConverter<T> = T Function(XmlElement data);

/// xml 解析结果
typedef XmlConverterResult<T> = T Function(XmlConverter<T> converter);

/// COSMinix类
mixin COSApiMixin on COSAbstractApi {
  /// 将 response 转化成 xml
  /// [response] http response
  XmlConverterResult<T> toXml<T>(Response response) {
    final String xmlString = utf8.decode(toValidation(response).bodyBytes);
    final XmlDocument xmlDocument = XmlDocument.parse(xmlString);

    // T convert(XmlConverter<T> converter) => converter(xmlDocument.rootElement);
    // return convert;

    return (XmlConverter<T> converter) => converter(xmlDocument.rootElement);
  }

  /// 验证 response 是否有效
  /// [response] http response
  Response toValidation(Response response) {
    if (_validateStatus(response.statusCode)) {
      return response;
    }
    throw COSException.fromResponse(response);
  }

  /// 验证 http 状态
  /// [statusCode] http code
  bool _validateStatus(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
}
