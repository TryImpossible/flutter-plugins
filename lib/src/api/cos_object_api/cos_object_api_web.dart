import 'package:http/http.dart';

import 'cos_abstract_object_api.dart';

/// Object接口
/// https://cloud.tencent.com/document/product/436/7749
class COSObjectApi extends COSAbstractObjectApi {
  COSObjectApi(
    super.config, {
    required super.bucketName,
    required super.region,
  });

  /// 上传文件对象
  /// [bucketName]
  /// [region]
  /// [objectKey]
  /// [filePath]
  /// [headers]
  @override
  Future<Response> putFileObject({
    String? bucketName,
    String? region,
    required String objectKey,
    required String filePath,
    Map<String, String> headers = const <String, String>{},
  }) {
    throw UnimplementedError(
        'putFileObject is not implemented on the web platform');
  }

  /// 上传目录
  /// [bucketName]
  /// [region]
  /// [directory]
  /// [headers]
  @override
  Future<bool> putDirectory({
    String? bucketName,
    String? region,
    required String directory,
    Map<String, String> headers = const <String, String>{},
  }) async {
    throw UnimplementedError(
        'putDirectory is not implemented on the web platform');
  }
}
