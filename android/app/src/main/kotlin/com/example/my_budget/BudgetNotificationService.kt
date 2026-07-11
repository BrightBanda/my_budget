package com.example.my_budget

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class BudgetNotificationService : NotificationListenerService() {

    companion object {
        private const val TAG = "BudgeteerNotification"
    }

    override fun onCreate() {
        super.onCreate()
        Log.i(TAG, "Service Created")
    }

    override fun onListenerConnected() {
        super.onListenerConnected()

        Log.i(TAG, "Listener Connected")

        try {

            val notifications = activeNotifications

            Log.i(TAG, "Active notifications: ${notifications.size}")

        } catch (e: Exception) {

            Log.e(TAG, "Error", e)

        }
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {

        try {

            val extras = sbn.notification.extras

            val title =
                extras.getString(Notification.EXTRA_TITLE)

            val text =
                extras.getCharSequence(Notification.EXTRA_TEXT)?.toString()

            Log.i(TAG, "========== NEW NOTIFICATION ==========")
            Log.i(TAG, "Package : ${sbn.packageName}")
            Log.i(TAG, "Title   : $title")
            Log.i(TAG, "Text    : $text")

            if (
                TransactionDetector.isTransaction(
                    title,
                    text
                )
            ) {

                val provider =
                    TransactionDetector.provider(title, text)

                Log.i(TAG, "TRANSACTION DETECTED")
                Log.i(TAG, "Provider: $provider")

                // Parser will go here next
            }

        } catch (e: Exception) {

            Log.e(TAG, "Notification Error", e)

        }
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification) {

        Log.i(TAG, "Notification Removed")

    }

    override fun onListenerDisconnected() {

        super.onListenerDisconnected()

        Log.i(TAG, "Listener Disconnected")

    }

    override fun onDestroy() {

        super.onDestroy()

        Log.i(TAG, "Service Destroyed")

    }
}