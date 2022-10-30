import 'package:tencent_cos_plus/tencent_cos_plus.dart';

Future<void> main() async {
  COSApiFactory.initialize(
    config: COSConfig(
      appId: 'xxx',
      secretId: 'xxxxxxxxx',
      secretKey: 'xxxxxxxxx',
    ),
    bucketName: 'xxx',
    region: 'xxx-xxx',
  );

  dynamic result;

  ///  查询请求者名下的所有存储桶列表或特定地域下的存储桶列表
  result = await COSApiFactory.bucketApi.getService(region: 'ap-guangzhou');
  (result as COSListAllMyBucketsResult).buckets?.forEach((element) {
    print('${element.name}\b');
  });

  /// 在指定账号下创建一个存储桶
  result = await COSApiFactory.bucketApi.putBucket(
    bucketName: 'xxx',
    region: 'xxx-xxx',
  );

  /// 删除指定的存储桶
  result = await COSApiFactory.bucketApi.deleteBucket();

  /// 列出该存储桶内的部分或者全部对象
  result = await COSApiFactory.objectApi.listObjects(
    bucketName: 'xxx',
    region: 'xxx-xxx',
    listObjectHeader: COSListObjectHeader()..prefix = 'xxx',
  );

  /// 将本地的对象（Object）上传至指定存储桶中
  result = await COSApiFactory.objectApi.putObject(
    bucketName: 'xxx',
    region: 'xxx-xxx',
    objectKey: 'xxx',
    filePath: 'xxx',
  );

  /// 将 COS 存储桶中的对象（Object）下载至本地
  result = await COSApiFactory.objectApi.getObject(
    bucketName: 'xxx',
    region: 'xxx-xxx',
    objectKey: 'xxx',
    getObject: COSGetObject()..responseCacheControl = 'xxx',
  );

  /// 删除一个指定的对象（Object）
  result = await COSApiFactory.objectApi.deleteObject(
    objectKey: 'xxx',
  );

  /// 批量删除指定存储桶中的多个对象（Object）
  result = await COSApiFactory.objectApi.listObjects(
    bucketName: 'xxx',
    region: 'xxx-xxx',
    listObjectHeader: COSListObjectHeader()..prefix = 'xxx',
  );
  final List<COSObject>? objects = (result as COSListBucketResult)
      .contents
      ?.map<COSObject>((COSContents element) {
    print('${element.key} \b');
    return COSObject(key: element.key ?? '');
  }).toList();
  final COSDelete delete =
      COSDelete(quiet: false, objects: objects ?? <COSObject>[]);
  result = await COSApiFactory.objectApi.deleteMultipleObjects(
    bucketName: 'xxx',
    region: 'xxx-xxx',
    delete: delete,
  );
}
