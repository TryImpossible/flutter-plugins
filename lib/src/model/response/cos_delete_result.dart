import 'package:xml/xml.dart';

import '../common/cos_common.dart';

class COSDeleteResult {
  List<COSDeleted>? deleteds;
  Error? error;

  COSDeleteResult();

  factory COSDeleteResult.fromXml(XmlElement? xml) {
    return COSDeleteResult()
      ..deleteds = xml
          ?.findElements('Deleted')
          .map((XmlElement xmlElement) => COSDeleted.fromXml(xmlElement))
          .toList()
      ..error = Error.fromXml(xml?.getElement('Error'));
  }
}

class COSDeleted {
  String? key;
  String? deleteMarker;
  String? deleteMarkerVersionId;
  String? versionId;

  COSDeleted();

  factory COSDeleted.fromXml(XmlElement? xml) {
    return COSDeleted()
      ..key = xml?.getElement('Key')?.innerText
      ..deleteMarker = xml?.getElement('DeleteMarker')?.innerText
      ..deleteMarkerVersionId =
          xml?.getElement('DeleteMarkerVersionId')?.innerText
      ..versionId = xml?.getElement('VersionId')?.innerText;
  }
}
