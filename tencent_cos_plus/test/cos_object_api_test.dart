import 'dart:io';

import 'package:http/http.dart';
import 'package:tencent_cos_plus/tencent_cos_plus.dart';
import 'package:test/test.dart';

void main() {
  group('cos object api tests', () {
    setUp(() {
      COSApiFactory.initialize(
        config: COSConfig(
          appId: 'xxx',
          secretId: 'xxxxxxxxx',
          secretKey: 'xxxxxxxxx',
        ),
        bucketName: 'xxx',
        region: 'xxx-xxx',
      );
    });

    test('ListObjects Test', () async {
      try {
        final COSListBucketResult result =
            await COSApiFactory.objectApi.listObjects(
          bucketName: 'xxx',
          region: 'xxx-xxx',
          listObjectHeader: COSListObjectHeader()..prefix = 'xxx',
        );
        result.contents?.forEach((element) {
          print('${element.key}\b');
        });
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('ListObjectVersions Test', () async {
      try {
        final COSListVersionsResult result =
            await COSApiFactory.objectApi.listObjectVersions(
          bucketName: 'xxx',
          region: 'xxx-xxx',
          listObjectHeader: COSListObjectHeader()..prefix = 'xxx',
        );
        result.versions?.forEach((element) {
          print('${element.key}\b');
        });
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('PutObject Test', () async {
      try {
        final Response result = await COSApiFactory.objectApi.putObject(
          bucketName: 'xxx',
          region: 'xxx-xxx',
          objectKey: 'xxx.png',
          objectValue: File('xxx.png').readAsBytesSync(),
          contentType: 'image/png',
        );
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('PutObjectCopy Test', () async {
      try {
        final COSCopyObjectResult result =
            await COSApiFactory.objectApi.putObjectCopy(
          bucketName: 'xxx',
          region: 'xxx-xxx',
          objectKey: 'xxx',
          xCOSCopySource: 'xxx',
          contentType: 'xxx',
        );
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('GetObject Test', () async {
      try {
        final Response result = await COSApiFactory.objectApi.getObject(
          bucketName: 'xxx',
          region: 'xxx-xxx',
          objectKey: 'xxx',
          getObjectQuery: COSGetObjectQuery()..responseCacheControl = 'xxx',
        );
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('HeadObject Test', () async {
      try {
        final Response result = await COSApiFactory.objectApi.headObject(
          bucketName: 'xxx',
          region: 'xxx-xxx',
          objectKey: 'xxx',
        );
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('DeleteObject Test', () async {
      try {
        final Response result = await COSApiFactory.objectApi.deleteObject(
          objectKey: 'xxx',
        );
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('DeleteMultipleObjects Test', () async {
      try {
        dynamic result;
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
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('OptionsObject Test', () async {
      try {
        final Response result = await COSApiFactory.objectApi.optionsObject(
          bucketName: 'xxx',
          region: 'xxx-xxx',
          objectKey: 'xxx',
          origin: 'xxx',
          accessControlRequestMethod: 'xxx',
        );
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });
  });

  test('PostObjectRestore Test', () async {
    try {
      final Response result = await COSApiFactory.objectApi.postObjectRestore(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        objectKey: 'xxx',
        restoreRequest: COSRestoreRequest(
          days: 10,
          casJobParameters: COSCASJobParameters(tier: 'xxx'),
        ),
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('PutFileObject Test', () async {
    try {
      final Response result = await COSApiFactory.objectApi.putFileObject(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        objectKey: 'xxx.png',
        filePath: 'xxx.png',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('PutFolderObject Test', () async {
    try {
      final Response result = await COSApiFactory.objectApi.putFolderObject(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        objectKey: '/folder',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('UploadDirectory Test', () async {
    try {
      final bool result = await COSApiFactory.objectApi.putDirectory(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        directory: '/directory',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('DeleteDirectory Test', () async {
    try {
      final bool result = await COSApiFactory.objectApi.deleteDirectory(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        directory: '/directory',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('PutObjectACL Test', () async {
    try {
      final Response result = await COSApiFactory.objectApi.putObjectACL(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        objectKey: 'xxx',
        aclHeader: COSACLHeader()..xCosAcl = 'public-read',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('GetObjectACL Test', () async {
    try {
      final COSAccessControlPolicy result =
          await COSApiFactory.objectApi.getObjectACL(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        objectKey: 'xxx',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('PutObjectTagging Test', () async {
    try {
      final COSTagSet tagSet = COSTagSet()
        ..tags = <COSTag>[
          COSTag()
            ..key = 'xxx'
            ..value = 'xxx'
        ];
      final COSTagging tagging = COSTagging()..tagSet = tagSet;

      final Response result = await COSApiFactory.objectApi.putObjectTagging(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        objectKey: 'xxx',
        tagging: tagging,
        versionId: 'xxx',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('getObjectTagging Test', () async {
    try {
      final COSTagging result = await COSApiFactory.objectApi.getObjectTagging(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        objectKey: 'xxx',
        versionId: 'xxx',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('DeleteObjectTagging Test', () async {
    try {
      final Response result = await COSApiFactory.objectApi.deleteObjectTagging(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        objectKey: 'xxx',
        versionId: 'xxx',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });
}
