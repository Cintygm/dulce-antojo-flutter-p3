package com.moraymiel.app

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Actividad principal de Mora & Miel.
 *
 * Expone un MethodChannel propio para que Dart conozca la versión de
 * Android (API level). Se usa para decidir qué permiso de galería pedir:
 * READ_MEDIA_IMAGES (Android 13+) o READ_EXTERNAL_STORAGE (Android 12 o menor).
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CANAL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sdkInt" -> result.success(Build.VERSION.SDK_INT)
                    else -> result.notImplemented()
                }
            }
    }

    companion object {
        private const val CANAL = "com.moraymiel.app/dispositivo"
    }
}
