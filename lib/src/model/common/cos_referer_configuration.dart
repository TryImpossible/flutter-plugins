import 'package:xml/xml.dart';

class COSRefererConfiguration {
  String? status;
  String? refererType;
  COSDomainList? domainList;
  String? emptyReferConfiguration;

  COSRefererConfiguration();

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('RefererConfiguration', nest: () {
      builder.element('Status', nest: status);
      builder.element('RefererType', nest: refererType);
      final String? domainListXml = domainList?.toXmlString();
      if (domainListXml?.isNotEmpty ?? false) {
        builder.xml(domainListXml!);
      }
      builder.element('EmptyReferConfiguration', nest: emptyReferConfiguration);
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  factory COSRefererConfiguration.fromXml(XmlElement? xml) {
    return COSRefererConfiguration()
      ..status = xml?.getElement('Status')?.innerText
      ..refererType = xml?.getElement('RefererType')?.innerText
      ..domainList = COSDomainList.fromXml(xml?.getElement('DomainList'))
      ..emptyReferConfiguration =
          xml?.getElement('EmptyReferConfiguration')?.innerText;
  }
}

class COSDomainList {
  List<String>? domains;

  COSDomainList();

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('DomainList', nest: () {
      domains?.forEach((String domain) {
        builder.element('Domain', nest: domain);
      });
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  factory COSDomainList.fromXml(XmlElement? xml) {
    return COSDomainList()
      ..domains = xml
          ?.findElements('Domain')
          .map((XmlElement xmlElement) => xmlElement.innerText)
          .toList();
  }
}
