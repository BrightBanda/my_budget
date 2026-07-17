package com.example.my_budget

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class BudgetNotificationService : NotificationListenerService() {

    companion object {
        private const val TAG = "BudgeteerNotification"
    }

    override fun onListenerConnected() {
        super.onListenerConnected()

        Log.i(TAG, "Listener connected")
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        try {
            // Ignore our own prompts, or we'd loop on them forever.
            if (sbn.packageName == packageName) return

            val extras = sbn.notification.extras

            val title = extras.getString(Notification.EXTRA_TITLE)
            val text = extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()

            if (!TransactionDetector.isTransaction(title, text)) return

            val detected = TransactionParser.parse(title, text, sbn.postTime)

            if (detected == null) {
                Log.w(TAG, "Provider matched but message did not parse: $title | $text")
                return
            }

            Log.i(TAG, "Detected ${detected.type} of ${detected.amount} via ${detected.provider}")

            // Prompt the user to add it — no silent writes. Tapping opens the app pre-filled.
            TransactionNotifier.notify(applicationContext, detected)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to handle notification", e)
        }
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()

        Log.i(TAG, "Listener disconnected")
    }
}
