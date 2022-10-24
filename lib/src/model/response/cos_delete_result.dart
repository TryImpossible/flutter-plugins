import 'package:xml/xml.dart';

class COSDeleteResult {
  List<COSDeleted>? deleteds;
  COSDeleteError? error;

  COSDeleteResult();

  factory COSDeleteResult.fromXml(XmlElement? xml) {
    return COSDeleteResult()
      ..deleteds = xml
          ?.findElements('Deleted')
          .map((XmlElement xmlElement) => COSDeleted.fromXml(xmlElement))
          .toList()
      ..error = COSDeleteError.fromXml(xml?.getElement('Error'));
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


class COSDeleteError {
  String? key;
  String? versionId;
  String? code;
  String? message;

  COSDeleteError();

  factory COSDeleteError.fromXml(XmlElement? xml) {
    return COSDeleteError()
      ..key = xml?.getElement('Key')?.innerText
      ..versionId = xml?.getElement('VersionId')?.innerText
      ..code = xml?.getElement('Code')?.innerText
      ..message = xml?.getElement('Message')?.innerText;
  }
}