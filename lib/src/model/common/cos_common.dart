import 'package:xml/xml.dart';

class COSOwner {
  String? id;
  String? displayName;

  COSOwner();

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('Owner', nest: () {
      if (id != null) {
        builder.element('ID', nest: id);
      }
      if (displayName != null) {
        builder.element('DisplayName', nest: displayName);
      }
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  factory COSOwner.fromXml(XmlElement? xml) {
    return COSOwner()
      ..id = xml?.getElement('ID')?.innerText
      ..displayName = xml?.getElement('DisplayName')?.innerText;
  }
}

class COSCommonPrefixes {
  String? prefix;

  COSCommonPrefixes();

  factory COSCommonPrefixes.fromXml(XmlElement? xml) {
    return COSCommonPrefixes()..prefix = xml?.getElement('Prefix')?.innerText;
  }
}

class COSObject {
  String key;
  String? versionId;

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('Object', nest: () {
      builder.element('Key', nest: key);
      if (versionId != null) {
        builder.element('VersionId', nest: versionId);
      }
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  COSObject({required this.key, this.versionId});

  factory COSObject.fromXml(XmlElement? xml) {
    return COSObject(
      key: xml?.getElement('Key')?.innerText ?? '',
      versionId: xml?.getElement('VersionId')?.innerText,
    );
  }
}

class Error {
  String? key;
  String? versionId;
  String? code;
  String? message;

  Error();

  factory Error.fromXml(XmlElement? xml) {
    return Error()
      ..key = xml?.getElement('Key')?.innerText
      ..versionId = xml?.getElement('VersionId')?.innerText
      ..code = xml?.getElement('Code')?.innerText
      ..message = xml?.getElement('Message')?.innerText;
  }
}
