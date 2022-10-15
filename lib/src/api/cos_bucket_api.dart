import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';

import '../model/model.dart';
import 'cos_abstract_api.dart';
import 'cos_api_mixin.dart';

/// Bucket接口
/// https://cloud.tencent.com/document/product/436/7738
class COSBucketApi extends COSAbstractApi with COSApiMixin {
  COSBucketApi(
    super.config, {
    required this.bucketName,
    required this.region,
  });

  /// 存储桶，COS 中用于存储数据的容器
  final String bucketName;

  /// 地域信息，枚举值可参见 可用地域 文档，例如：ap-beijing、ap-hongkong、eu-frankfurt 等
  final String region;

  String getBaseApiUrl([String? bucketName, String? region]) {
    return 'https://${bucketName ?? this.bucketName}-${config.appId}.cos.'
        '${region ?? this.region}.myqcloud.com';
  }

  ///
  /// GET Service 接口是用来查询请求者名下的所有存储桶列表或特定地域下的存储桶列表
  Future<COSListAllMyBucketsResult> getService({String? region}) async {
    String authority = 'service.cos.myqcloud.com';
    if (region?.isNotEmpty ?? false) {
      authority = 'cos.$region.myqcloud.com';
    }
    final Uri url = Uri.https(authority, '/');
    final Response response = await client.get(url.toString());
    return toXml<COSListAllMyBucketsResult>(response)(
        COSListAllMyBucketsResult.fromXml);
  }

  ///
  /// PUT Bucket 接口请求可以在指定账号下创建一个存储桶
  Future<Response> putBucket({
    required String bucketName,
    required String region,
    Map<String, String> headers = const <String, String>{},
    bool isMAZ = false,
  }) async {
    final Map<String, String> newHeaders = Map.of(headers);
    newHeaders['Content-Length'] = '0';
    String? xmlString;
    if (isMAZ) {
      xmlString = COSCreateBucketConfiguration().toXmlString();
      // http 框架设置body时，会自动给 Content-Type 指定字符集为 charset=utf-8
      // 设置 application/xml; charset=utf-8 保持一致
      newHeaders['Content-Type'] = 'application/xml; charset=utf-8';
      newHeaders['Content-Length'] = xmlString.length.toString();
      final String md5String = Base64Encoder()
          .convert(md5.convert(xmlString.codeUnits).bytes)
          .toString();
      newHeaders['Content-MD5'] = md5String;
    }
    final Response response = await client.put(
      '${getBaseApiUrl(bucketName, region)}/',
      headers: newHeaders,
      body: xmlString,
    );
    return toValidation(response);
  }

  // ///
  // /// GET Bucket 请求等同于 List Objects 请求，可以列出该存储桶内的部分或者全部对象。
  // Future<COSListBucketResult> getBucket({
  //   String? bucketName,
  //   String? region,
  //   String? prefix,
  //   String? delimiter,
  //   String? encodingType,
  //   String? marker,
  //   int? maxKeys,
  // }) async {
  //   final Response response = await client.get(
  //     '${getBaseApiUrl(bucketName, region)}/',
  //     queryParameters: <String, String>{
  //       if (prefix != null) 'prefix': prefix,
  //       if (delimiter != null) 'delimiter': delimiter,
  //       if (encodingType != null) 'encoding-type': encodingType,
  //       if (marker != null) 'marker': marker,
  //       if (maxKeys != null) 'max-keys': maxKeys.toString(),
  //     },
  //   );
  //   return toXml<COSListBucketResult>(response)(COSListBucketResult.fromXml);
  // }

  ///
  /// HEAD Bucket 请求可以确认该存储桶是否存在，是否有权限访问
  Future<Response> headBucket({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.head('${getBaseApiUrl(bucketName, region)}/');
    return toValidation(response);
  }

  ///
  /// DELETE Bucket 请求用于删除指定的存储桶
  Future<Response> deleteBucket({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.delete('${getBaseApiUrl(bucketName, region)}/');
    return toValidation(response);
  }

  // ///
  // /// GET Bucket Object versions 接口用于拉取存储桶内的所有对象及其历史版本信息，
  // /// 您可以通过指定参数筛选出存储桶内部分对象及其历史版本信息
  // Future<COSListVersionsResult> getBucketObjectVersions({
  //   String? bucketName,
  //   String? region,
  //   String? prefix,
  //   String? delimiter,
  //   String? encodingType,
  //   String? marker,
  //   String? versionIdMarker,
  //   int? maxKeys,
  // }) async {
  //   final Response response = await client.get(
  //     '${getBaseApiUrl(bucketName, region)}/',
  //     queryParameters: <String, String>{
  //       'versions': '',
  //       if (prefix != null) 'prefix': prefix,
  //       if (delimiter != null) 'delimiter': delimiter,
  //       if (encodingType != null) 'encoding-type': encodingType,
  //       if (marker != null) 'marker': marker,
  //       if (versionIdMarker != null) 'version-id-marker': versionIdMarker,
  //       if (maxKeys != null) 'max-keys': maxKeys.toString(),
  //     },
  //   );
  //   return toXml<COSListVersionsResult>(response)(
  //       COSListVersionsResult.fromXml);
  // }

  ///
  /// PUT Bucket acl 接口用来写入存储桶的访问控制列表（ACL），
  /// 您可以通过请求头 x-cos-acl 和 x-cos-grant-* 传入 ACL 信息，或者通过请求体以 XML 格式传入 ACL 信息。
  Future<Response> putBucketACL({
    String? bucketName,
    String? region,
    Map<String, String> headers = const <String, String>{},
    COSBucketACLHeader? bucketACLHeader,
    COSAccessControlPolicy? accessControlPolicy,
  }) async {
    final Map<String, String> newHeaders = Map.of(headers);
    if (bucketACLHeader != null) {
      newHeaders.addAll(bucketACLHeader.toMap());
    }

    if (accessControlPolicy != null) {
      final String xmlString = accessControlPolicy.toXmlString();
      // http 框架设置body时，会自动给 Content-Type 指定字符集为 charset=utf-8
      // 设置 application/xml; charset=utf-8 保持一致
      newHeaders['Content-Type'] = 'application/xml; charset=utf-8';
      newHeaders['Content-Length'] = xmlString.length.toString();
      final String md5String = Base64Encoder()
          .convert(md5.convert(xmlString.codeUnits).bytes)
          .toString();
      newHeaders['Content-MD5'] = md5String;
    }

    final Response response = await client.put(
      '${getBaseApiUrl(bucketName, region)}/?acl',
      headers: newHeaders,
    );
    return toValidation(response);
  }

  ///
  /// GET Bucket acl 接口用来获取存储桶的访问控制列表（ACL）
  Future<COSAccessControlPolicy> getBucketACL({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.get('${getBaseApiUrl(bucketName, region)}/?acl');
    return toXml<COSAccessControlPolicy>(response)(
        COSAccessControlPolicy.fromXml);
  }

  ///
  /// PUT Bucket cors 请求用于为存储桶配置跨域资源共享（CORS）访问控制，您可以通过传入 XML 格式的配置文件来实现配置，文件大小限制为64KB
  Future<Response> putBucketCORS({
    String? bucketName,
    String? region,
    required COSCORSConfiguration corsConfiguration,
  }) async {
    final Map<String, String> headers = <String, String>{};
    final String xmlString = corsConfiguration.toXmlString();
    // http 框架设置body时，会自动给 Content-Type 指定字符集为 charset=utf-8
    // 设置 application/xml; charset=utf-8 保持一致
    headers['Content-Type'] = 'application/xml; charset=utf-8';
    headers['Content-Length'] = xmlString.length.toString();
    final String md5String = Base64Encoder()
        .convert(md5.convert(xmlString.codeUnits).bytes)
        .toString();
    headers['Content-MD5'] = md5String;
    final Response response = await client.put(
      '${getBaseApiUrl(bucketName, region)}/?cors',
      headers: headers,
      body: xmlString,
    );
    return toValidation(response);
  }

  ///
  /// GET Bucket cors 请求用于查询存储桶的跨域资源共享（CORS）访问控制。
  Future<COSCORSConfiguration> getBucketCORS({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.get('${getBaseApiUrl(bucketName, region)}/?cors');
    return toXml<COSCORSConfiguration>(response)(COSCORSConfiguration.fromXml);
  }

  ///
  /// DELETE Bucket cors 请求用于删除存储桶的跨域资源共享（CORS）访问控制。
  Future<Response> deleteBucketCORS({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.delete('${getBaseApiUrl(bucketName, region)}/?cors');
    return toValidation(response);
  }

  ///
  /// PUT Bucket referer 接口用于为存储桶设置 Referer 白名单或者黑名单。
  Future<Response> putBucketReferer({
    String? bucketName,
    String? region,
    required COSRefererConfiguration refererConfiguration,
  }) async {
    final Map<String, String> headers = <String, String>{};
    final String xmlString = refererConfiguration.toXmlString();
    // http 框架设置body时，会自动给 Content-Type 指定字符集为 charset=utf-8
    // 设置 application/xml; charset=utf-8 保持一致
    headers['Content-Type'] = 'application/xml; charset=utf-8';
    headers['Content-Length'] = xmlString.length.toString();
    final String md5String = Base64Encoder()
        .convert(md5.convert(xmlString.codeUnits).bytes)
        .toString();
    headers['Content-MD5'] = md5String;
    final Response response = await client.put(
      '${getBaseApiUrl(bucketName, region)}/?referer',
      headers: headers,
      body: xmlString,
    );
    return toValidation(response);
  }

  ///
  /// GET Bucket referer 接口用于读取存储桶 Referer 白名单或者黑名单。
  Future<COSRefererConfiguration> getBucketReferer({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.get('${getBaseApiUrl(bucketName, region)}/?referer');
    return toXml<COSRefererConfiguration>(response)(
        COSRefererConfiguration.fromXml);
  }
}
