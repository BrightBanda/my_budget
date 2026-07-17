package com.example.my_budget

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
 * - Method channel: Dart pulls the pending queue and inspects/requests the listener permission.
 * - Event channel: a payload-free ping telling Dart "something new landed, drain now".
 */
object TransactionChannel {

    private const val METHOD_CHANNEL = "com.example.my_budget/transactions"
    private const val EVENT_CHANNEL = "com.example.my_budget/transactions_events"

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    fun register(engine: FlutterEngine, context: Context) {
        MethodChannel(engine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "drainPending" -> result.success(PendingTransactionStore.drain(context))
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

    /** Nudges Dart to drain. No-op when the engine isn't running — the queue keeps the detection. */
    fun notifyPending() {
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
