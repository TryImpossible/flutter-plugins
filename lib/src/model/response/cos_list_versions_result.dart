import 'package:xml/xml.dart';

import '../common/cos_common.dart';

class COSListVersionsResult {
  String? encodingType;
  String? name;
  String? prefix;
  String? keyMarker;
  String? versionIdMarker;
  int? maxKeys;
  bool? isTruncated;
  String? nextKeyMarker;
  String? nextVersionIdMarker;
  String? delimiter;
  List<COSCommonPrefixes>? commonPrefixes;
  List<COSVersion>? versions;
  List<COSDeleteMarker>? deleteMarkers;

  COSListVersionsResult();

  factory COSListVersionsResult.fromXml(XmlElement? xml) {
    return COSListVersionsResult()
      ..encodingType = xml?.getElement('EncodingType')?.innerText
      ..name = xml?.getElement('Name')?.innerText
      ..prefix = xml?.getElement('Prefix')?.innerText
      ..keyMarker = xml?.getElement('KeyMarker')?.innerText
      ..versionIdMarker = xml?.getElement('VersionIdMarker')?.innerText
      ..maxKeys = int.tryParse(xml?.getElement('MaxKeys')?.innerText ?? '')
      ..isTruncated = xml?.getElement('IsTruncated')?.innerText == 'true'
      ..nextKeyMarker = xml?.getElement('NextKeyMarker')?.innerText
      ..nextVersionIdMarker = xml?.getElement('NextVersionIdMarker')?.innerText
      ..delimiter = xml?.getElement('Delimiter')?.innerText
      ..commonPrefixes = xml
          ?.findElements('CommonPrefixes')
          .map((XmlElement xmlElement) => COSCommonPrefixes.fromXml(xmlElement))
          .toList()
      ..versions = xml
          ?.findElements('Version')
          .map((XmlElement xmlElement) => COSVersion.fromXml(xmlElement))
          .toList()
      ..deleteMarkers = xml
          ?.findElements('DeleteMarker')
          .map((XmlElement xmlElement) => COSDeleteMarker.fromXml(xmlElement))
          .toList();
  }
}

class COSVersion {
  String? key;
  String? versionId;
  bool? isLatest;
  String? lastModified;
  String? eTag;
  int? size;
  String? storageClass;
  String? storageTier;
  COSOwner? owner;

  COSVersion();

  factory COSVersion.fromXml(XmlElement? xml) {
    return COSVersion()
      ..key = xml?.getElement('Key')?.innerText
      ..versionId = xml?.getElement('versionId')?.innerText
      ..isLatest = xml?.getElement('IsLatest')?.innerText == 'true'
      ..lastModified = xml?.getElement('LastModified')?.innerText
      ..eTag = xml?.getElement('ETag')?.innerText
      ..size = int.tryParse(xml?.getElement('Size')?.innerText ?? '')
      ..storageClass = xml?.getElement('StorageClass')?.innerText
      ..storageTier = xml?.getElement('StorageTier')?.innerText
      ..owner = COSOwner.fromXml(xml?.getElement('Owner'));
  }
}

class COSDeleteMarker {
  String? key;
  String? versionId;
  bool? isLatest;
  String? lastModified;
  COSOwner? owner;

  COSDeleteMarker();

  factory COSDeleteMarker.fromXml(XmlElement? xml) {
    return COSDeleteMarker()
      ..key = xml?.getElement('Key')?.innerText
      ..versionId = xml?.getElement('versionId')?.innerText
      ..isLatest = xml?.getElement('IsLatest')?.innerText == 'true'
      ..lastModified = xml?.getElement('LastModified')?.innerText
      ..owner = COSOwner.fromXml(xml?.getElement('Owner'));
  }
}
