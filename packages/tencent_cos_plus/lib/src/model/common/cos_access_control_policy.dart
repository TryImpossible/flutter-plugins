import 'package:xml/xml.dart';

import 'cos_common.dart';

class COSAccessControlPolicy {
  COSOwner? owner;
  List<COSGrant>? accessControlList;

  COSAccessControlPolicy();

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('AccessControlPolicy', nest: () {
      if (owner != null) {
        builder.xml(owner!.toXmlString());
      }
      builder.element('AccessControlList', nest: () {
        accessControlList?.forEach((COSGrant grant) {
          builder.xml(grant.toXmlString());
        });
      });
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  factory COSAccessControlPolicy.fromXml(XmlElement? xml) {
    return COSAccessControlPolicy()
      ..owner = COSOwner.fromXml(xml?.getElement('Owner'))
      ..accessControlList =
          xml?.findAllElements('Grant').map((XmlElement xmlElement) {
        return COSGrant.fromXml(xmlElement);
      }).toList();
  }
}

class COSGrant {
  String? permission;
  COSGrantee? grantee;

  COSGrant();

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('Grant', nest: () {
      if (grantee != null) {
        builder.xml(grantee!.toXmlString());
      }
      if (permission != null) {
        builder.element('Permission', nest: permission);
      }
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  factory COSGrant.fromXml(XmlElement? xml) {
    return COSGrant()
      ..permission = xml?.getElement('Permission')?.innerText
      ..grantee = COSGrantee.fromXml(xml?.getElement('Grantee'));
  }
}

class COSGrantee {
  String? attributeXmlnsXsi;
  String? attributeXsiType;
  String? uri;
  String? id;
  String? displayName;

  COSGrantee();

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('Grantee', nest: () {
      if (attributeXmlnsXsi != null) {
        builder.attribute('xmlns:xsi', attributeXmlnsXsi!);
      }
      if (attributeXsiType != null) {
        builder.attribute('xsi:type', attributeXsiType!);
      }
      if (uri != null) {
        builder.element('URI', nest: uri);
      }
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

  factory COSGrantee.fromXml(XmlElement? xml) {
    return COSGrantee()
      ..attributeXmlnsXsi = xml?.getAttribute('xmlns:xsi')
      ..attributeXsiType = xml?.getAttribute('xsi:type')
      ..uri = xml?.getElement('URI')?.innerText
      ..id = xml?.getElement('ID')?.innerText
      ..displayName = xml?.getElement('DisplayName')?.innerText;
  }
}
