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

  /// 拼接BaseApiUrl
  /// [bucketName] 存储桶
  /// [region] 区域信息
  String getBaseApiUrl([String? bucketName, String? region]) {
    return 'https://${bucketName ?? this.bucketName}-${config.appId}.cos.'
        '${region ?? this.region}.myqcloud.com';
  }

  /// GET Service 接口是用来查询请求者名下的所有存储桶列表或特定地域下的存储桶列表
  /// [region]
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

  /// PUT Bucket 接口请求可以在指定账号下创建一个存储桶
  /// [bucketName]
  /// [region]
  /// [aclHeader]
  /// [isMAZ]
  Future<Response> putBucket({
    required String bucketName,
    required String region,
    COSACLHeader? aclHeader,
    bool isMAZ = false,
  }) async {
    Map<String, String>? headers;
    if (aclHeader != null) {
      headers ??= aclHeader.toMap();
    }
    String? xmlString;
    if (isMAZ) {
      xmlString = COSCreateBucketConfiguration().toXmlString();
      headers ??= <String, String>{};
      // http 框架设置body时，会自动给 Content-Type 指定字符集为 charset=utf-8
      // 设置 application/xml; charset=utf-8 保持一致
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Content-Length'] = xmlString.length.toString();
      final String md5String = Base64Encoder()
          .convert(md5.convert(xmlString.codeUnits).bytes)
          .toString();
      headers['Content-MD5'] = md5String;
    }
    final Response response = await client.put(
      '${getBaseApiUrl(bucketName, region)}/',
      headers: headers,
      body: xmlString,
    );
    return toValidation(response);
  }

  /// HEAD Bucket 请求可以确认该存储桶是否存在，是否有权限访问
  /// [bucketName]
  /// [region]
  Future<Response> headBucket({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.head('${getBaseApiUrl(bucketName, region)}/');
    return toValidation(response);
  }

  /// DELETE Bucket 请求用于删除指定的存储桶
  /// [bucketName]
  /// [region]
  Future<Response> deleteBucket({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.delete('${getBaseApiUrl(bucketName, region)}/');
    return toValidation(response);
  }

  /// PUT Bucket acl 接口用来写入存储桶的访问控制列表（ACL），
  /// 您可以通过请求头 x-cos-acl 和 x-cos-grant-* 传入 ACL 信息，或者通过请求体以 XML 格式传入 ACL 信息。
  /// [bucketName]
  /// [region]
  /// [aclHeader]
  /// [accessControlPolicy]
  Future<Response> putBucketACL({
    String? bucketName,
    String? region,
    COSACLHeader? aclHeader,
    COSAccessControlPolicy? accessControlPolicy,
  }) async {
    Map<String, String>? headers;
    if (aclHeader != null) {
      headers ??= aclHeader.toMap();
    }
    String? xmlString;
    if (accessControlPolicy != null) {
      headers ??= <String, String>{};
      xmlString = accessControlPolicy.toXmlString();
      // http 框架设置body时，会自动给 Content-Type 指定字符集为 charset=utf-8
      // 设置 application/xml; charset=utf-8 保持一致
      headers['Content-Type'] = 'application/xml; charset=utf-8';
      headers['Content-Length'] = xmlString.length.toString();
      final String md5String = Base64Encoder()
          .convert(md5.convert(xmlString.codeUnits).bytes)
          .toString();
      headers['Content-MD5'] = md5String;
    }

    final Response response = await client.put(
      '${getBaseApiUrl(bucketName, region)}/?acl',
      headers: headers,
      body: xmlString,
    );
    return toValidation(response);
  }

  /// GET Bucket acl 接口用来获取存储桶的访问控制列表（ACL）
  /// [bucketName]
  /// [region]
  Future<COSAccessControlPolicy> getBucketACL({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.get('${getBaseApiUrl(bucketName, region)}/?acl');
    return toXml<COSAccessControlPolicy>(response)(
        COSAccessControlPolicy.fromXml);
  }

  /// PUT Bucket cors 请求用于为存储桶配置跨域资源共享（CORS）访问控制，您可以通过传入 XML 格式的配置文件来实现配置，文件大小限制为64KB
  /// [bucketName]
  /// [region]
  /// [corsConfiguration]
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

  /// GET Bucket cors 请求用于查询存储桶的跨域资源共享（CORS）访问控制。
  /// [bucketName]
  /// [region]
  Future<COSCORSConfiguration> getBucketCORS({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.get('${getBaseApiUrl(bucketName, region)}/?cors');
    return toXml<COSCORSConfiguration>(response)(COSCORSConfiguration.fromXml);
  }

  /// DELETE Bucket cors 请求用于删除存储桶的跨域资源共享（CORS）访问控制。
  /// [bucketName]
  /// [region]
  Future<Response> deleteBucketCORS({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.delete('${getBaseApiUrl(bucketName, region)}/?cors');
    return toValidation(response);
  }

  /// PUT Bucket referer 接口用于为存储桶设置 Referer 白名单或者黑名单。
  /// [bucketName]
  /// [region]
  /// [refererConfiguration]
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

  /// GET Bucket referer 接口用于读取存储桶 Referer 白名单或者黑名单。
  /// [bucketName]
  /// [region]
  Future<COSRefererConfiguration> getBucketReferer({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.get('${getBaseApiUrl(bucketName, region)}/?referer');
    return toXml<COSRefererConfiguration>(response)(
        COSRefererConfiguration.fromXml);
  }

  /// PUT Bucket accelerate 接口实现启用或者暂停存储桶的全球加速功能。
  /// [bucketName]
  /// [region]
  /// [accelerateConfiguration]
  Future<Response> putBucketAccelerate({
    String? bucketName,
    String? region,
    required COSAccelerateConfiguration accelerateConfiguration,
  }) async {
    final Map<String, String> headers = <String, String>{};
    final String xmlString = accelerateConfiguration.toXmlString();
    // http 框架设置body时，会自动给 Content-Type 指定字符集为 charset=utf-8
    // 设置 application/xml; charset=utf-8 保持一致
    headers['Content-Type'] = 'application/xml; charset=utf-8';
    headers['Content-Length'] = xmlString.length.toString();
    final String md5String = Base64Encoder()
        .convert(md5.convert(xmlString.codeUnits).bytes)
        .toString();
    headers['Content-MD5'] = md5String;
    final Response response = await client.put(
      '${getBaseApiUrl(bucketName, region)}/?accelerate',
      headers: headers,
      body: xmlString,
    );
    return toValidation(response);
  }

  /// GET Bucket accelerate 接口实现查询存储桶的全球加速功能配置。
  /// [bucketName]
  /// [region]
  Future<COSAccelerateConfiguration> getBucketAccelerate({
    String? bucketName,
    String? region,
  }) async {
    final Response response =
        await client.get('${getBaseApiUrl(bucketName, region)}/?accelerate');
    return toXml<COSAccelerateConfiguration>(response)(
        COSAccelerateConfiguration.fromXml);
  }
}
