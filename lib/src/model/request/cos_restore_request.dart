import 'package:xml/xml.dart';

class COSRestoreRequest {
  num days;
  COSCASJobParameters casJobParameters;

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('RestoreRequest', nest: () {
      builder.xml(casJobParameters.toXmlString());
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  COSRestoreRequest({
    required this.days,
    required this.casJobParameters,
  });
}

class COSCASJobParameters {
  String tier;

  XmlDocument toXml() {
    final XmlBuilder builder = XmlBuilder();
    builder.element('CASJobParameters', nest: () {
      builder.element('tier', nest: tier);
    });
    return builder.buildDocument();
  }

  String toXmlString() {
    return toXml().toXmlString();
  }

  COSCASJobParameters({required this.tier});
}
