import 'package:xml/xml.dart';

class COSTagging {
  COSTagSet? tagSet;

  COSTagging();

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('COSTagging', nest: () {
      if (tagSet != null) {
        builder.xml(tagSet!.toXmlString());
      }
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  factory COSTagging.fromXml(XmlElement? xml) {
    return COSTagging()..tagSet = COSTagSet.fromXml(xml?.getElement('TagSet'));
  }
}

class COSTagSet {
  List<COSTag>? tags;

  COSTagSet();

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('TagSet', nest: () {
      tags?.forEach((COSTag tag) {
        builder.xml(tag.toXmlString());
      });
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  factory COSTagSet.fromXml(XmlElement? xml) {
    return COSTagSet()
      ..tags = xml
          ?.findElements('Tag')
          .map((XmlElement xmlElement) => COSTag.fromXml(xmlElement))
          .toList();
  }
}

class COSTag {
  String? key;
  String? value;

  COSTag();

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('Tag', nest: () {
      if (key != null) {
        builder.element('Key', nest: key);
      }
      if (value != null) {
        builder.element('Value', nest: value);
      }
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  factory COSTag.fromXml(XmlElement? xml) {
    return COSTag()
      ..key = xml?.getElement('Key')?.innerText
      ..value = xml?.getElement('Value')?.innerText;
  }
}
