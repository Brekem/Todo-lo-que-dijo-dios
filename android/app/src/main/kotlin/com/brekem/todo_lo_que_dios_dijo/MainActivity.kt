package com.brekem.todo_lo_que_dios_dijo

import android.Manifest
import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
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

        // La voz del teléfono no es un reproductor de audio: con la pantalla
        // apagada Android duerme el procesador entre frase y frase y la
        // lectura se para. Mientras se escucha, el procesador sigue despierto.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "todo_lo_que_dios_dijo/energia")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "despierto" -> {
                        despierto(call.arguments as? Boolean ?: false)
                        result.success(null)
                    }
                    "sinAhorroDeBateria" -> {
                        pedirSinAhorroDeBateria()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun despierto(on: Boolean) {
        val lock = wakeLock ?: (applicationContext.getSystemService(Context.POWER_SERVICE) as PowerManager)
            .newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "TodoLoQueDiosDijo:lectura")
            .apply { setReferenceCounted(false) }
            .also { wakeLock = it }
        if (on) {
            // Se renueva en cada frase; si algo falla, se suelta solo.
            lock.acquire(60 * 60 * 1000L)
        } else if (lock.isHeld) {
            lock.release()
        }
    }

    /** Algunos teléfonos cortan las apps en segundo plano para ahorrar batería. Se pide una vez. */
    @SuppressLint("BatteryLife")
    private fun pedirSinAhorroDeBateria() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return
        val prefs = getSharedPreferences("energia", Context.MODE_PRIVATE)
        if (prefs.getBoolean("pedido", false)) return
        val power = getSystemService(Context.POWER_SERVICE) as PowerManager
        if (power.isIgnoringBatteryOptimizations(packageName)) return
        prefs.edit().putBoolean("pedido", true).apply()
        try {
            startActivity(
                Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS)
                    .setData(Uri.parse("package:$packageName"))
            )
        } catch (e: Exception) {
            // Sin esa pantalla en este teléfono: se sigue igual.
        }
    }

    companion object {
        // Compartido: el motor sigue vivo aunque la actividad se cierre.
        private var wakeLock: PowerManager.WakeLock? = null
    }
}
