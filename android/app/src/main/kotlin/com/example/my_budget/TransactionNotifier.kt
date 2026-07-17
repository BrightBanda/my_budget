package com.example.my_budget

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import java.util.concurrent.atomic.AtomicInteger

/**
 * Posts Budgeteer's own "add this transaction?" notification for a detected payment.
 *
 * Tapping it opens the app carrying the transaction as JSON, so Dart can pre-fill the
 * add-transaction sheet. Nothing is written to the database here — the user confirms
 * manually in the app.
 */
object TransactionNotifier {

    const val EXTRA_TRANSACTION_JSON = "transaction_json"
    const val EXTRA_NOTIFICATION_ID = "notification_id"

    private const val CHANNEL_ID = "budgeteer_capture"
    private const val CHANNEL_NAME = "Detected transactions"

    private val nextId = AtomicInteger(1000)

    fun notify(context: Context, detected: DetectedTransaction) {
        val manager = context.getSystemService(NotificationManager::class.java) ?: return

        ensureChannel(manager)

        val notificationId = nextId.incrementAndGet()

        val tapIntent = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_NEW_TASK)
            putExtra(EXTRA_TRANSACTION_JSON, detected.toJson())
            putExtra(EXTRA_NOTIFICATION_ID, notificationId)
        }

        val pendingIntent = PendingIntent.getActivity(
            context,
            notificationId,
            tapIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val text = summary(detected)

        val builder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL_ID)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(context)
        }

        val notification = builder
            .setSmallIcon(context.applicationInfo.icon)
            .setContentTitle("Add this transaction?")
            .setContentText(text)
            .setStyle(Notification.BigTextStyle().bigText(text))
            .setAutoCancel(true)
            .setContentIntent(pendingIntent)
            .build()

        manager.notify(notificationId, notification)
    }

    /** "Sent 2,600 to ESTHER NGANGURA · Airtel Money" — a glanceable one-liner. */
    private fun summary(detected: DetectedTransaction): String {
        val verb = if (detected.type == "income") "Received" else "Sent"
        val amount = formatAmount(detected.amount)
        val who = detected.counterparty?.let {
            if (detected.type == "income") " from $it" else " to $it"
        } ?: ""

        return "$verb $amount$who · ${detected.provider}"
    }

    private fun formatAmount(amount: Double): String {
        // Drop the decimal when it's a whole number, e.g. 2600.0 -> "2,600".
        return if (amount % 1.0 == 0.0) {
            "%,d".format(amount.toLong())
        } else {
            "%,.2f".format(amount)
        }
    }

    private fun ensureChannel(manager: NotificationManager) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        if (manager.getNotificationChannel(CHANNEL_ID) != null) return

        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = "Prompts to add transactions detected from Airtel Money & Mpamba alerts"
        }

        manager.createNotificationChannel(channel)
    }
}
