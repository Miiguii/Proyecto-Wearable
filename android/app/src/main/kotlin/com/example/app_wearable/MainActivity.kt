package com.example.app_wearable

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "com.goalify/ble_server"
    private var bleServer: BleGattServerManager? = null
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)

        // El manager notifica hacia Flutter cada comando que llega del reloj.
        bleServer = BleGattServerManager(applicationContext) { commandJson ->
            methodChannel?.invokeMethod("onCommand", commandJson)
        }

        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startServer" -> {
                    bleServer?.start()
                    result.success(null)
                }
                "stopServer" -> {
                    bleServer?.stop()
                    result.success(null)
                }
                "pushState" -> {
                    val json = call.argument<String>("json")
                    if (json != null) {
                        bleServer?.pushState(json)
                        result.success(null)
                    } else {
                        result.error("BAD_ARGS", "Falta 'json' en pushState", null)
                    }
                }
                "isBluetoothReady" -> {
                    result.success(bleServer?.isBluetoothReady() ?: false)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        bleServer?.stop()
        super.onDestroy()
    }
}
