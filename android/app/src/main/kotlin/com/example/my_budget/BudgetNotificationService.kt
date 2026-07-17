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

            // Persist first, ping second: if the engine is dead the ping is dropped but the
            // detection still reaches Dart on the next drain.
            PendingTransactionStore.add(applicationContext, detected)
            TransactionChannel.notifyPending()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to handle notification", e)
        }
    }

    override fun onListenerDisconnected() {
        super.onListenerDisconnected()

        Log.i(TAG, "Listener disconnected")
    }
}
