package com.brekem.todo_lo_que_dios_dijo

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// La actividad comparte el motor de Flutter con el servicio de reproducción,
// para que la lectura siga con la pantalla apagada o en otra app.
class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Android 13+: sin permiso de notificaciones algunos teléfonos
        // esconden el reproductor de la barra de notificaciones.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "todo_lo_que_dios_dijo/notificaciones")
            .setMethodCallHandler { call, result ->
                if (call.method != "pedirPermiso") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU &&
                    checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
                    PackageManager.PERMISSION_GRANTED
                ) {
                    requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1)
                }
                result.success(null)
            }
    }
}
