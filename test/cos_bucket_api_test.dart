import 'dart:io';

import 'package:http/http.dart';
import 'package:tencent_cos_plus/tencent_cos_plus.dart';
import 'package:test/test.dart';

void main() {
  group('cos bucket api tests', () {
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

    test('GetService Test', () async {
      try {
        final COSListAllMyBucketsResult result =
            await COSApiFactory.bucketApi.getService(region: 'xxx-xxx');
        result.buckets?.forEach((element) {
          print('${element.name}\b');
        });
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('PutBucket Test', () async {
      try {
        final Response result = await COSApiFactory.bucketApi.putBucket(
          bucketName: 'xxx',
          region: 'xxx-xxx',
        );
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('HeadBucket Test', () async {
      try {
        final Response result = await COSApiFactory.bucketApi.headBucket();
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('DeleteBucket Test', () async {
      try {
        final Response result = await COSApiFactory.bucketApi.deleteBucket();
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('PutBucketACL Test', () async {
      try {
        final Response result = await COSApiFactory.bucketApi.putBucketACL(
          bucketName: 'xxx',
          region: 'xxx-xxx',
          bucketACLHeader: COSBucketACLHeader()..xCosAcl = 'public-read',
        );
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });

    test('GetBucketACL Test', () async {
      try {
        final COSAccessControlPolicy result =
            await COSApiFactory.bucketApi.getBucketACL(
          bucketName: 'xxx',
          region: 'xxx-xxx',
        );
        expect(result, isNotNull);
      } on SocketException catch (_) {
        fail('Did not expect a socket exception.');
      }
    });
  });

  test('PutBucketCORS Test', () async {
    try {
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
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('GetBucketCORS Test', () async {
    try {
      final COSCORSConfiguration result =
          await COSApiFactory.bucketApi.getBucketCORS(
        bucketName: 'xxx',
        region: 'xxx-xxx',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('DeleteBucketCORS Test', () async {
    try {
      final Response result = await COSApiFactory.bucketApi.deleteBucketCORS(
        bucketName: 'xxx',
        region: 'xxx-xxx',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('PutBucketReferer Test', () async {
    try {
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
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('GetBucketReferer Test', () async {
    try {
      final COSRefererConfiguration result =
          await COSApiFactory.bucketApi.getBucketReferer(
        bucketName: 'xxx',
        region: 'xxx-xxx',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('PutBucketAccelerate Test', () async {
    try {
      final Response response =
          await COSApiFactory.bucketApi.putBucketAccelerate(
        bucketName: 'xxx',
        region: 'xxx-xxx',
        accelerateConfiguration: COSAccelerateConfiguration()
          ..status = 'Enabled',
      );
      expect(response, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });

  test('GetBucketAccelerate Test', () async {
    try {
      final COSAccelerateConfiguration result =
          await COSApiFactory.bucketApi.getBucketAccelerate(
        bucketName: 'xxx',
        region: 'xxx-xxx',
      );
      expect(result, isNotNull);
    } on SocketException catch (_) {
      fail('Did not expect a socket exception.');
    }
  });
}
