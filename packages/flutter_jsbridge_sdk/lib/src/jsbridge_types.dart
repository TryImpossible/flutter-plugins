typedef JSBridgeHandler<T extends Object?> = Future<T> Function(Object? data);

typedef JSBridgeMessageExecutor = Future<void> Function(
    String javascriptString);

typedef JSBridgeMessageHandler = void Function(String javascriptString);
