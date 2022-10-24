import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import '../model/model.dart';
import 'cos_abstract_api.dart';
import 'cos_api_mixin.dart';

/// Object接口
/// https://cloud.tencent.com/document/product/436/7749
class COSObjectApi extends COSAbstractApi with COSApiMixin {
  COSObjectApi(
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

  /// GET Bucket 请求等同于 List Objects 请求，可以列出该存储桶内的部分或者全部对象。
  Future<COSListBucketResult> listObjects({
    String? bucketName,
    String? region,
    String? prefix,
    String? delimiter,
    String? encodingType,
    String? marker,
    int? maxKeys,
  }) async {
    final Response response = await client.get(
      '${getBaseApiUrl(bucketName, region)}/',
      queryParameters: <String, String>{
        if (prefix != null) 'prefix': prefix,
        if (delimiter != null) 'delimiter': delimiter,
        if (encodingType != null) 'encoding-type': encodingType,
        if (marker != null) 'marker': marker,
        if (maxKeys != null) 'max-keys': maxKeys.toString(),
      },
    );
    return toXml<COSListBucketResult>(response)(COSListBucketResult.fromXml);
  }

  /// GET Bucket Object versions 接口用于拉取存储桶内的所有对象及其历史版本信息，
  /// 您可以通过指定参数筛选出存储桶内部分对象及其历史版本信息
  Future<COSListVersionsResult> listObjectVersions({
    String? bucketName,
    String? region,
    String? prefix,
    String? delimiter,
    String? encodingType,
    String? marker,
    String? versionIdMarker,
    int? maxKeys,
  }) async {
    final Response response = await client.get(
      '${getBaseApiUrl(bucketName, region)}/?versions',
      queryParameters: <String, String>{
        // 'versions': '',
        if (prefix != null) 'prefix': prefix,
        if (delimiter != null) 'delimiter': delimiter,
        if (encodingType != null) 'encoding-type': encodingType,
        if (marker != null) 'marker': marker,
        if (versionIdMarker != null) 'version-id-marker': versionIdMarker,
        if (maxKeys != null) 'max-keys': maxKeys.toString(),
      },
    );
    return toXml<COSListVersionsResult>(response)(
        COSListVersionsResult.fromXml);
  }

  /// PUT Object 接口请求可以将本地的对象（Object）上传至指定存储桶中
  Future<Response> putObject({
    String? bucketName,
    String? region,
    required String objectKey,
    String? filePath,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final Map<String, String> newHeaders = Map.of(headers);
    Uint8List? bytes;
    if (filePath?.isNotEmpty ?? false) {
      bytes = File(filePath!).readAsBytesSync();
      final String length = bytes.length.toString();
      final String md5String =
          Base64Encoder().convert(md5.convert(bytes).bytes).toString();
      newHeaders['Content-Type'] = lookupMimeType(filePath) ?? '';
      newHeaders['Content-Length'] = length;
      newHeaders['Content-MD5'] = md5String;
    }
    final Response response = await client.put(
      '${getBaseApiUrl(bucketName, region)}/$objectKey',
      headers: newHeaders,
      body: bytes,
    );
    return toValidation(response);
  }

  /// PUT Object - Copy 接口请求创建一个已存在 COS 的对象的副本，即将一个对象从源路径（对象键）复制到目标路径（对象键）
  Future<COSCopyObjectResult> putObjectCopy({
    String? bucketName,
    String? region,
    required String objectKey,
    required String xCOSCopySource,
    required String contentType,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final Map<String, String> newHeaders = Map.of(headers);
    newHeaders['x-cos-copy-source'] = xCOSCopySource;
    newHeaders['Content-Type'] = contentType;
    final Response response = await client.put(
      '${getBaseApiUrl(bucketName, region)}/$objectKey',
      headers: newHeaders,
    );
    return toXml<COSCopyObjectResult>(response)(COSCopyObjectResult.fromXml);
  }

  /// GET Object GET Object 接口请求可以将 COS 存储桶中的对象（Object）下载至本地
  Future<Response> getObject({
    String? bucketName,
    String? region,
    required String objectKey,
    COSGetObject? getObject,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final Response response = await client.get(
      '${getBaseApiUrl(bucketName, region)}/$objectKey',
      queryParameters: getObject?.toMap(),
    );
    return toValidation(response);
  }

  /// POST Object 接口请求可以将本地不超过5GB的对象（Object）以网页表单（HTML Form）的形式上传至指定存储桶中
  // Future<Response> postObject({
  //   String? bucketName,
  //   String? region,
  //   required String key,
  // }) async {}

  /// HEAD Object 接口请求可以判断指定对象是否存在和有权限，并在指定对象可访问时获取其元数据
  Future<Response> headObject({
    String? bucketName,
    String? region,
    required String objectKey,
    String? versionId,
    Map<String, String> headers = const <String, String>{},
  }) async {
    final Response response = await client.head(
      '${getBaseApiUrl(bucketName, region)}/$objectKey',
      headers: headers,
      queryParameters: <String, String>{
        if (versionId != null) 'versionId': versionId
      },
    );
    return toValidation(response);
  }

  /// DELETE Object 接口请求可以删除一个指定的对象（Object）
  Future<Response> deleteObject({
    String? bucketName,
    String? region,
    required String objectKey,
    String? versionId,
  }) async {
    final Response response = await client.delete(
      '${getBaseApiUrl(bucketName, region)}/$objectKey',
      queryParameters: <String, String>{
        if (versionId != null) 'versionId': versionId
      },
    );
    return toValidation(response);
  }

  /// DELETE Multiple Objects 接口请求可以批量删除指定存储桶中的多个对象（Object），单次请求支持最多删除1000个对象
  Future<COSDeleteResult> deleteMultipleObjects({
    String? bucketName,
    String? region,
    required COSDelete delete,
  }) async {
    Map<String, String> headers = <String, String>{};
    final String xmlString = delete.toXmlString();
    // http 框架设置body时，会自动给 Content-Type 指定字符集为 charset=utf-8
    // 设置 application/xml; charset=utf-8 保持一致
    headers['Content-Type'] = 'application/xml; charset=utf-8';
    headers['Content-Length'] = xmlString.length.toString();
    final String md5String = Base64Encoder()
        .convert(md5.convert(xmlString.codeUnits).bytes)
        .toString();
    headers['Content-MD5'] = md5String;
    final Response response = await client.post(
      '${getBaseApiUrl(bucketName, region)}/?delete',
      headers: headers,
      body: xmlString,
    );
    return toXml<COSDeleteResult>(response)(COSDeleteResult.fromXml);
  }

  /// OPTIONS Object 用于跨域资源共享（CORS）的预检（Preflight）请求
  Future<Response> optionsObject({
    String? bucketName,
    String? region,
    required String objectKey,
    required String origin,
    required String accessControlRequestMethod,
    String? accessControlRequestHeaders,
  }) async {
    final Map<String, String> headers = <String, String>{
      'Origin': origin,
      'Access-Control-Request-Method': accessControlRequestMethod,
      if (accessControlRequestHeaders != null)
        'Access-Control-Request-Headers': accessControlRequestHeaders,
    };
    final Response response = await client.options(
      '${getBaseApiUrl(bucketName, region)}/$objectKey',
      headers: headers,
    );
    return toValidation(response);
  }

  /// POST Object restore 接口请求可以对一个归档存储或深度归档存储类型的对象进行恢复（解冻）
  /// 以便读取该对象内容，恢复出的可读取对象是临时的，您可以设置需要保持可读以及随后删除该临时副本的时间
  Future<Response> postObjectRestore({
    String? bucketName,
    String? region,
    required String objectKey,
    required COSRestoreRequest restoreRequest,
  }) async {
    Map<String, String> headers = <String, String>{};
    final String xmlString = restoreRequest.toXmlString();
    // http 框架设置body时，会自动给 Content-Type 指定字符集为 charset=utf-8
    // 设置 application/xml; charset=utf-8 保持一致
    headers['Content-Type'] = 'application/xml; charset=utf-8';
    headers['Content-Length'] = xmlString.length.toString();
    final String md5String = Base64Encoder()
        .convert(md5.convert(xmlString.codeUnits).bytes)
        .toString();
    headers['Content-MD5'] = md5String;
    final Response response = await client.post(
      '${getBaseApiUrl(bucketName, region)}/$objectKey?restore',
      body: xmlString,
    );
    return toValidation(response);
  }

  /// 上传目录
  Future<bool> uploadDirectory({
    String? bucketName,
    String? region,
    required String directory,
    Map<String, String> headers = const <String, String>{},
  }) async {
    try {
      final List<FileSystemEntity> entities =
          Directory(directory).listSync(recursive: true);
      if (entities.isNotEmpty) {
        final List<Future<void>> tasks =
            entities.map<Future<void>>((FileSystemEntity entity) {
          final String objectKey = path.relative(entity.path, from: directory);
          final String? filePath =
              FileSystemEntity.isFileSync(entity.path) ? entity.path : null;
          return putObject(
            bucketName: bucketName,
            region: region,
            objectKey: objectKey,
            filePath: filePath,
            headers: headers,
          );
        }).toList();
        await Future.wait(tasks);
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  /// 删除目录
  Future<bool> deleteDirectory({
    String? bucketName,
    String? region,
    required String directory,
  }) async {
    try {
      final COSListBucketResult buckets = await listObjects(
        bucketName: bucketName,
        region: region,
        prefix: directory,
      );
      if (buckets.contents?.isNotEmpty ?? false) {
        final List<COSObject> objects =
            buckets.contents!.map<COSObject>((COSContents content) {
          return COSObject(key: content.key ?? '');
        }).toList();
        final COSDelete delete = COSDelete(quiet: false, objects: objects);
        await deleteMultipleObjects(delete: delete);
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }
}
