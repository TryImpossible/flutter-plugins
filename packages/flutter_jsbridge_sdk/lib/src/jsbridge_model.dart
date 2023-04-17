int _handlerId = 0;

class JSBridgeMessage {
  String get action => _action;
  final String _action;

  Object? get data => _data;
  final Object? _data;

  int get id => _id;
  final int _id;
  final String _type;

  bool get isResolved => _resolved;
  final bool _resolved;

  bool get isRejected => _rejected;
  final bool _rejected;

  JSBridgeMessage._({
    required String action,
    required Object? data,
    required int id,
    required String type,
    required bool resolved,
    required bool rejected,
  })  : _action = action,
        _data = data,
        _id = id,
        _type = type,
        _resolved = resolved,
        _rejected = rejected;

  JSBridgeMessage.request({
    required String action,
    required Object? data,
  })  : _action = action,
        _data = data,
        _id = _handlerId++,
        _type = 'request',
        _resolved = false,
        _rejected = false;

  JSBridgeMessage.response({
    required String action,
    required Object? data,
    required int id,
    required bool resolved,
    required bool rejected,
  })  : _action = action,
        _data = data,
        _id = id,
        _type = 'response',
        _resolved = resolved,
        _rejected = rejected;

  bool get isRequest => _type == 'request';

  bool get isResponse => _type == 'response';

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'action': _action,
      if (_data != null) 'data': _data,
      'id': _id,
      'type': _type,
      'resolved': _resolved,
      'rejected': _rejected,
    };
  }

  factory JSBridgeMessage.fromJson(Map<String, dynamic> json) {
    return JSBridgeMessage._(
      action: json['action'] ?? '',
      data: json['data'] ?? '',
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      resolved: json['resolved'] ?? false,
      rejected: json['rejected'] ?? false,
    );
  }
}
