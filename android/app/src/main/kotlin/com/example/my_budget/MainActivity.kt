package com.example.my_budget

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private companion object {
        const val POST_NOTIFICATIONS_REQUEST = 1001
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        TransactionChannel.register(flutterEngine, applicationContext)

        requestNotificationPermissionIfNeeded()

        // Handle the intent that cold-started us from a notification tap.
        handleTransactionIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        setIntent(intent)
        handleTransactionIntent(intent)
    }

    private fun handleTransactionIntent(intent: Intent?) {
        val json = intent?.getStringExtra(TransactionNotifier.EXTRA_TRANSACTION_JSON) ?: return
        val notificationId = intent.getIntExtra(TransactionNotifier.EXTRA_NOTIFICATION_ID, -1)

        TransactionChannel.deliverTap(applicationContext, json, notificationId)

        // Clear it so a later resume doesn't replay the same transaction.
        intent.removeExtra(TransactionNotifier.EXTRA_TRANSACTION_JSON)
    }

    private fun requestNotificationPermissionIfNeeded() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.TIRAMISU) return

        val granted = checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED

        if (!granted) {
            requestPermissions(
                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                POST_NOTIFICATIONS_REQUEST
            )
        }
    }
}
