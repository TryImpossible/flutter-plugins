import 'package:xml/xml.dart';

import '../common/cos_common.dart';

class COSListAllMyBucketsResult {
  COSOwner? owner;
  List<COSBucket>? buckets;

  COSListAllMyBucketsResult();

  factory COSListAllMyBucketsResult.fromXml(XmlElement? xml) {
    final COSOwner owner = COSOwner.fromXml(xml?.getElement('Owner'));
    final List<COSBucket>? buckets = xml
        ?.getElement('Buckets')
        ?.childElements
        .map((XmlElement xmlElement) => COSBucket.fromXml(xmlElement))
        .toList();
    return COSListAllMyBucketsResult()
      ..owner = owner
      ..buckets = buckets;
  }
}

class COSBucket {
  String? name;
  String? location;
  String? creationDate;
  String? bucketType;

  COSBucket();

  factory COSBucket.fromXml(XmlElement? xml) {
    return COSBucket()
      ..name = xml?.getElement('Name')?.innerText
      ..location = xml?.getElement('Location')?.innerText
      ..creationDate = xml?.getElement('CreationDate')?.innerText
      ..bucketType = xml?.getElement('BucketType')?.innerText;
  }
}
