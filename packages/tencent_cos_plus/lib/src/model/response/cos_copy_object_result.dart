import 'package:xml/xml.dart';

class COSCopyObjectResult {
  String? eTag;
  String? crc64;
  String? lastModified;
  String? versionId;

  COSCopyObjectResult();

  factory COSCopyObjectResult.fromXml(XmlElement? xml) {
    return COSCopyObjectResult()
      ..eTag = xml?.getElement('Key')?.innerText
      ..crc64 = xml?.getElement('IsLatest')?.innerText
      ..lastModified = xml?.getElement('LastModified')?.innerText
      ..versionId = xml?.getElement('versionId')?.innerText;
  }
}
