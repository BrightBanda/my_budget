package com.example.my_budget

import android.content.Context
import org.json.JSONArray

/**
 * Durable FIFO queue of detections waiting to reach Flutter.
 *
 * [BudgetNotificationService] fires whether or not the Flutter engine is alive, so a detection
 * is always persisted here first. Dart drains the queue when it next runs. This — not the
 * event channel — is the source of truth, which keeps a live ping and a cold drain from
 * importing the same transaction twice.
 */
object PendingTransactionStore {

    private const val PREFS = "budgeteer_pending_transactions"
    private const val KEY = "queue"
    private const val MAX_ENTRIES = 200

    private val lock = Any()

    fun add(context: Context, transaction: DetectedTransaction) = synchronized(lock) {
        val queue = readArray(context)
        queue.put(transaction.toJson())

        // Bound the queue so an uninstalled-but-listening app can't grow it forever.
        val trimmed = if (queue.length() > MAX_ENTRIES) {
            JSONArray().apply {
                for (i in (queue.length() - MAX_ENTRIES) until queue.length()) put(queue.getString(i))
            }
        } else {
            queue
        }

        write(context, trimmed)
    }

    /** Returns every queued detection and clears the queue in one atomic step. */
    fun drain(context: Context): List<String> = synchronized(lock) {
        val queue = readArray(context)
        val items = (0 until queue.length()).map { queue.getString(it) }

        write(context, JSONArray())

        return items
    }

    private fun readArray(context: Context): JSONArray {
        val stored = prefs(context).getString(KEY, null) ?: return JSONArray()

        return try {
            JSONArray(stored)
        } catch (e: Exception) {
            JSONArray()
        }
    }

    private fun write(context: Context, queue: JSONArray) {
        prefs(context).edit().putString(KEY, queue.toString()).apply()
    }

    private fun prefs(context: Context) =
        context.applicationContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}
