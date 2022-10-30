import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import '../../model/model.dart';
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
    COSACLHeader? aclHeader,
    Map<String, String> headers = const <String, String>{},
  }) {
    final Uint8List bytes = File(filePath).readAsBytesSync();
    return putObject(
      bucketName: bucketName,
      region: region,
      objectKey: objectKey,
      objectValue: bytes,
      contentType: lookupMimeType(filePath) ?? '',
      aclHeader: aclHeader,
      headers: headers,
    );
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
    try {
      final List<FileSystemEntity> entities =
          Directory(directory).listSync(recursive: true);
      if (entities.isNotEmpty) {
        final List<Future<void>> tasks =
            entities.map<Future<void>>((FileSystemEntity entity) {
          final String objectKey = path.relative(entity.path, from: directory);
          if (FileSystemEntity.isFileSync(entity.path)) {
            return putFileObject(
              bucketName: bucketName,
              region: region,
              objectKey: objectKey,
              filePath: entity.path,
              headers: headers,
            );
          } else {
            return putFolderObject(
              bucketName: bucketName,
              region: region,
              objectKey: objectKey,
              headers: headers,
            );
          }
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
}
