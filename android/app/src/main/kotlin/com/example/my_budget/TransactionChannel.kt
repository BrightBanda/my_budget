package com.example.my_budget

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/**
 * The Kotlin -> Dart bridge for auto-captured transactions.
 *
 * A tapped notification hands its transaction JSON to [deliverTap]. Dart pulls it with
 * the `consumePrefill` method call — on startup, on resume, and whenever the event
 * channel pings that a fresh tap arrived while the app was already open.
 */
object TransactionChannel {

    private const val METHOD_CHANNEL = "com.example.my_budget/transactions"
    private const val EVENT_CHANNEL = "com.example.my_budget/transactions_events"

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    /** The most recent tapped transaction awaiting pickup by Dart. */
    private var pendingTapJson: String? = null

    fun register(engine: FlutterEngine, context: Context) {
        MethodChannel(engine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "consumePrefill" -> {
                    result.success(pendingTapJson)
                    pendingTapJson = null
                }
                "isListenerEnabled" -> result.success(isListenerEnabled(context))
                "openListenerSettings" -> {
                    openListenerSettings(context)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(engine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    /**
     * Holds a tapped transaction for Dart and nudges a running app to pull it. When the
     * app is cold-starting the ping is dropped, but Dart still reads [pendingTapJson] on
     * startup — so nothing is lost.
     */
    fun deliverTap(context: Context, json: String, notificationId: Int) {
        pendingTapJson = json

        if (notificationId > 0) {
            context.getSystemService(NotificationManager::class.java)?.cancel(notificationId)
        }

        mainHandler.post { eventSink?.success(true) }
    }

    fun isListenerEnabled(context: Context): Boolean {
        val enabled = Settings.Secure.getString(
            context.contentResolver,
            "enabled_notification_listeners"
        ) ?: return false

        return enabled.split(":").any { it.contains(context.packageName) }
    }

    private fun openListenerSettings(context: Context) {
        val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        context.startActivity(intent)
    }
}
