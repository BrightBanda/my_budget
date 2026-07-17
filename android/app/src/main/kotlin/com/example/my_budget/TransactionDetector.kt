package com.example.my_budget

/**
 * Decides whether a notification is a mobile-money transaction and, if so, which provider.
 *
 * Detection keys off the notification title (the SMS sender: `MPAMBA`, `AIRTELMONEY`) as well
 * as the body, so it works whether or not the body repeats the provider name.
 */
object TransactionDetector {

    fun isTransaction(title: String?, text: String?): Boolean =
        provider(title, text) != null

    fun provider(title: String?, text: String?): String? {
        val content = "${title.orEmpty()} ${text.orEmpty()}".lowercase()

        // These strings must match the Dart TransactionProvider constants exactly —
        // they flow straight through to the transaction rows.
        return when {
            // Sender shows as "AIRTELMONEY" (no space) in the notification title,
            // while body text says "Airtel Money" — accept both.
            content.contains("airtel money") || content.contains("airtelmoney") ->
                "Airtel Money"

            content.contains("mpamba") -> "TNM Mpamba"

            else -> null
        }
    }
}
