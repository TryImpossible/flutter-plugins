import 'package:xml/xml.dart';

import '../common/cos_common.dart';

class COSListBucketResult {
  String? name;
  String? encodingType;
  String? prefix;
  String? marker;
  int? maxKeys;
  String? delimiter;
  bool? isTruncated;
  String? nextMarker;
  List<COSCommonPrefixes>? commonPrefixes;
  List<COSContents>? contents;

  COSListBucketResult();

  factory COSListBucketResult.fromXml(XmlElement? xml) {
    return COSListBucketResult()
      ..name = xml?.getElement('Name')?.innerText
      ..encodingType = xml?.getElement('EncodingType')?.innerText
      ..prefix = xml?.getElement('Prefix')?.innerText
      ..marker = xml?.getElement('Marker')?.innerText
      ..maxKeys = int.tryParse(xml?.getElement('MaxKeys')?.innerText ?? '')
      ..delimiter = xml?.getElement('Delimiter')?.innerText
      ..isTruncated = xml?.getElement('IsTruncated')?.innerText == 'true'
      ..nextMarker = xml?.getElement('NextMarker')?.innerText
      ..name = xml?.getElement('Name')?.innerText
      ..commonPrefixes = xml
          ?.findElements('CommonPrefixes')
          .map((XmlElement xmlElement) => COSCommonPrefixes.fromXml(xmlElement))
          .toList()
      ..contents = xml
          ?.findElements('Contents')
          .map((XmlElement xmlElement) => COSContents.fromXml(xmlElement))
          .toList();
  }
}

class COSContents {
  String? key;
  String? lastModified;
  String? eTag;
  int? size;
  COSOwner? owner;
  String? storageClass;
  String? storageTier;

  COSContents();

  factory COSContents.fromXml(XmlElement? xml) {
    return COSContents()
      ..key = xml?.getElement('Key')?.innerText
      ..lastModified = xml?.getElement('LastModified')?.innerText
      ..eTag = xml?.getElement('ETag')?.innerText
      ..size = int.tryParse(xml?.getElement('Size')?.innerText ?? '')
      ..owner = COSOwner.fromXml(xml?.getElement('Owner'))
      ..storageClass = xml?.getElement('StorageClass')?.innerText
      ..storageTier = xml?.getElement('StorageTier')?.innerText;
  }
}
