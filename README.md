一个强大的`Tencent COS`插件，支持`Android、iOS、Linux、MacOS、Web、Windows`全平台， 实现了`bucket`接口和`object`接口的基本操作.

## 功能

- 支持`Bucket`接口的基本操作，增加、删除、查询存储桶等
- 支持`Bucket`接口的访问控制(acl)
- 支持`Bucket`接口的跨域资源共享(cors)
- 支持`Bucket`接口的防盗链(referer)
- 支持`Object`接口的基本操作，上传、删除、查询存储对象等
- 支持`Object`接口的访问控制(acl)
- 支持扩展其它接口

## 开始
```yaml
dependencies:
  tencent_cos_plus: ^1.0.0
```

```dart
import 'package:tencent_cos_plus/tencent_cos_plus.dart';
```

## 用法

### 初始化

```
 COSApiFactory.initialize(
    config: COSConfig(
      appId: 'xxx',
      secretId: 'xxxxxxxxx',
      secretKey: 'xxxxxxxxx',
    ),
    bucketName: 'xxx',
    region: 'xxx-xxx',
  );
```

### Bucket 接口

- 查询请求者名下的所有存储桶列表或特定地域下的存储桶列表

```
final COSListAllMyBucketsResult result =
    await COSApiFactory.bucketApi.getService(region: 'xxx-xxx');
result.buckets?.forEach((element) {
  print('${element.name}\b');
});
```

- 在指定账号下创建一个存储桶

```
final Response result = await COSApiFactory.bucketApi.putBucket(
  bucketName: 'xxx',
  region: 'xxx-xxx',
);
```

- 确认该存储桶是否存在，是否有权限访问

```
final Response result = await COSApiFactory.bucketApi.headBucket();
```

- 删除指定的存储桶

```
final Response result = await COSApiFactory.bucketApi.deleteBucket();
```

- 写入存储桶的访问控制列表（ACL）

```
final Response result = await COSApiFactory.bucketApi.putBucketACL(
  bucketName: 'xxx',
  region: 'xxx-xxx',
  bucketACLHeader: COSBucketACLHeader()..xCosAcl = 'public-read',
);
``` 

- 获取存储桶的访问控制列表（ACL）

```
final COSAccessControlPolicy result =
    await COSApiFactory.bucketApi.getBucketACL(
  bucketName: 'xxx',
  region: 'xxx-xxx',
);
```

- 为存储桶配置跨域资源共享（CORS）访问控制

```
final Response result = await COSApiFactory.bucketApi.putBucketCORS(
    bucketName: 'xxx',
    region: 'xxx-xxx',
    corsConfiguration: COSCORSConfiguration(
      corsRules: <COSCORSRule>[
        COSCORSRule(
          allowedOrigins: <String>['*'],
          allowedMethods: <String>['PUT', 'GET', 'POST', 'DELETE', 'HEAD'],
          allowedHeaders: <String>['*'],
          exposeHeaders: <String>[
            'ETag',
            'Content-Length',
            'x-cos-request-id'
          ],
          maxAgeSeconds: 600,
        )
      ],
    ),
  );
```

- 查询存储桶的跨域资源共享（CORS）访问控制

```
final COSCORSConfiguration result =
      await COSApiFactory.bucketApi.getBucketCORS(
    bucketName: 'xxx',
    region: 'xxx-xxx',
  );
```

- 删除存储桶的跨域资源共享（CORS）访问控制

```
final Response result = await COSApiFactory.bucketApi.deleteBucketCORS(
    bucketName: 'xxx',
    region: 'xxx-xxx',
  );
```

- 为存储桶设置 Referer 白名单或者黑名单

```
final COSDomainList domainList = COSDomainList()
    ..domains = ['*.qcloud.com', '*.qq.com'];
  final Response result = await COSApiFactory.bucketApi.putBucketReferer(
    bucketName: 'xxx',
    region: 'xxx-xxx',
    refererConfiguration: COSRefererConfiguration()
      ..status = 'Enabled'
      ..refererType = 'White-List'
      ..domainList = domainList
      ..emptyReferConfiguration = 'Allow',
  );
```

- 读取存储桶 Referer 白名单或者黑名单。

```
final COSRefererConfiguration result =
      await COSApiFactory.bucketApi.getBucketReferer(
    bucketName: 'xxx',
    region: 'xxx-xxx',
  );
```

### Object 接口

- 列出该存储桶内的部分或者全部对象

```
final COSListBucketResult result =
    await COSApiFactory.objectApi.listObjects(
  bucketName: 'xxx',
  region: 'xxx-xxx',
  prefix: 'xxx',
);
```

- 拉取存储桶内的所有对象及其历史版本信息

```
final COSListVersionsResult result =
    await COSApiFactory.objectApi.listObjectVersions(
  bucketName: 'xxx',
  region: 'xxx-xxx',
  prefix: 'xxx',
);
```

- 将本地的对象（Object）上传至指定存储桶中

```
final Response result = await COSApiFactory.objectApi.putObject(
  bucketName: 'xxx',
  region: 'xxx-xxx',
  objectKey: 'xxx',
  filePath: 'xxx',
);
```

- 创建一个已存在 COS 的对象的副本

```
final COSCopyObjectResult result =
    await COSApiFactory.objectApi.putObjectCopy(
  bucketName: 'xxx',
  region: 'xxx-xxx',
  objectKey: 'xxx',
  xCOSCopySource: 'xxx',
  contentType: 'xxx',
);
```

- 将 COS 存储桶中的对象（Object）下载至本地

```
final Response result = await COSApiFactory.objectApi.getObject(
  bucketName: 'xxx',
  region: 'xxx-xxx',
  objectKey: 'xxx',
  getObject: COSGetObject()..responseCacheControl = 'xxx',
);
```

- 判断指定对象是否存在和有权限

```
final Response result = await COSApiFactory.objectApi.headObject(
  bucketName: 'xxx',
  region: 'xxx-xxx',
  objectKey: 'xxx',
);
```

- 删除一个指定的对象（Object）

```
final Response result = await COSApiFactory.objectApi.deleteObject(
  objectKey: 'xxx',
);
```

- 批量删除指定存储桶中的多个对象（Object）

```
var result;
result = await COSApiFactory.objectApi.listObjects(
  bucketName: 'xxx',
  region: 'xxx-xxx',
  prefix: 'xxx',
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
```

- 用于跨域资源共享（CORS）的预检（Preflight）请求

```
final Response result = await COSApiFactory.objectApi.optionsObject(
  bucketName: 'xxx',
  region: 'xxx-xxx',
  objectKey: 'xxx',
  origin: 'xxx',
  accessControlRequestMethod: 'xxx',
);
```

- 对一个归档存储或深度归档存储类型的对象进行恢复（解冻）以便读取该对象内容

```
final Response result = await COSApiFactory.objectApi.postObjectRestore(
    bucketName: 'xxx',
    region: 'xxx-xxx',
    objectKey: 'xxx',
    restoreRequest: COSRestoreRequest(
      days: 10,
      casJobParameters: COSCASJobParameters(tier: 'xxx'),
    ),
);
```

### 扩展其它接口

1. 实现具体Api

```
class XXXApi extends COSAbstractApi with COSApiMixin {
  XXXApi(super.config);
}  
```

2. 注册具体Api

```
COSApiFactory.createApi(
  key,
  XXXApi(COSApiFactory.config),
);
```

2. 使用具体Api
```
COSApiFactory.get<XXXApi>(key)
```

## 其它

[CSDN](https://blog.csdn.net/Ctrl_S/article/details/127407268?spm=1001.2014.3001.5502)

[掘金](https://juejin.cn/post/7156105555067535373)

[issues](https://github.com/TryImpossible/flutter-diy/issues)

如果遇到问题，请及时向我们反馈。若此插件对您产生帮助，麻烦为我点亮⭐⭐⭐
