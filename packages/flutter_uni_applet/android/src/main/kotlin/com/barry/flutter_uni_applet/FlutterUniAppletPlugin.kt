package com.barry.flutter_uni_applet

import android.content.Context
import android.os.Build
import android.util.Log
import io.dcloud.feature.sdk.DCSDKInitConfig
import io.dcloud.feature.sdk.DCUniMPSDK
import io.dcloud.feature.sdk.Interface.IDCUniMPPreInitCallback
import io.dcloud.feature.sdk.MenuActionSheetItem
import io.dcloud.feature.unimp.config.UniMPOpenConfiguration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


/** FlutterUniAppletPlugin */
class FlutterUniAppletPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var context: Context;

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_uni_applet")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext;

        //初始化 uni小程序SDK ----start----------
        val item = MenuActionSheetItem("关于", "gy")

        val item1 = MenuActionSheetItem("获取当前页面url", "hqdqym")
        val item2 = MenuActionSheetItem("跳转到宿主原生测试页面", "gotoTestPage")
        val sheetItems: MutableList<MenuActionSheetItem> = ArrayList<MenuActionSheetItem>()
        sheetItems.add(item)
        sheetItems.add(item1)
        sheetItems.add(item2)
        Log.i("unimp", "onCreate----")
        val config: DCSDKInitConfig = DCSDKInitConfig.Builder()
            .setCapsule(false)
            .setMenuDefFontSize("16px")
            .setMenuDefFontColor("#ff00ff")
            .setMenuDefFontWeight("normal")
            .setMenuActionSheetItems(sheetItems)
            .setEnableBackground(true) //开启后台运行
            .setUniMPFromRecents(false).build()


        DCUniMPSDK.getInstance().initialize(context, config,
            IDCUniMPPreInitCallback { b -> Log.d("unimpaa", "onInitFinished----$b") })
        //初始化 uni小程序SDK ----end----------
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "getPlatformVersion") {
            result.success("Android ${Build.VERSION.RELEASE}")
        } else if (call.method == "openApplet") {
            val uniMPOpenConfiguration = UniMPOpenConfiguration()
            uniMPOpenConfiguration.splashClass = this::class.java
            uniMPOpenConfiguration.extraData.put("darkmode", "light")
            val uniMP = DCUniMPSDK.getInstance()
                .openUniMP(context, "__UNI__F743940", uniMPOpenConfiguration)

            result.success(true);
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
