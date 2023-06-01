# flutter_st_ble_sensor

flutter_st_ble_sensor是对[STBLESensor_iOS](https://github.com/STMicroelectronics/BlueSTSDK_iOS)和[STBlueMS_Android](https://github.com/STMicroelectronics/STBlueMS_Android)开源项目的封装，仅实现了ota升级功能

## Getting Started

```yaml
  dependencies:
    flutter_st_ble_sensor:
      git:
        url: https://github.com/TryImpossible/flutter-plugins.git
        path: packages/flutter_st_ble_sensor
```

### android

AndroidManifest配置
```
 <!-- install only in device with ble -->
    <uses-feature
        android:name="android.hardware.bluetooth_le"
        android:required="true" />

    <!-- use the bluetooth -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <!-- search for new devices -->
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <!-- need for search for new devices for api >23 ! -->
    <uses-permission-sdk-23 android:name="android.permission.ACCESS_FINE_LOCATION" />

    <!-- store log files -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <!-- read log files -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```
### ios

info.plist
```
    <key>CFBundleDocumentTypes</key>
	<array>
		<dict>
			<key>CFBundleTypeIconFiles</key>
			<array/>
			<key>CFBundleTypeName</key>
			<string>UCF File</string>
			<key>CFBundleTypeRole</key>
			<string>Editor</string>
			<key>LSHandlerRank</key>
			<string>Owner</string>
			<key>LSItemContentTypes</key>
			<array>
				<string>ucf</string>
			</array>
		</dict>
	</array>
	
	<key>LSSupportsOpeningDocumentsInPlace</key>
	<true/>

    <key>NSBluetoothAlwaysUsageDescription</key>
	<string>App needs Bluetooth to discover new nodes  </string>
	<key>NSBluetoothPeripheralUsageDescription</key>
	<string>App needs Bluetooth to discover new nodes  </string>
	<key>NSUserTrackingUsageDescription</key>
	<string>App requires to collect data in order to detect which firmwares and BLE peripheral are mainly used.</string>
	
	<key>UIFileSharingEnabled</key>
	<true/>
```

### dart

进入设备列表
```dart
    FlutterStBleSensor().startScan()
```
参考[main.dart](example/lib/main.dart)