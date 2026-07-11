package com.example.my_budget

object TransactionDetector {

    fun isTransaction(
        title: String?,
        text: String?
    ): Boolean {

        val content = "${title.orEmpty()} ${text.orEmpty()}".lowercase()

        return when {

            content.contains("airtel money") -> true

            content.contains("mpamba") -> true

            else -> false
        }
    }

    fun provider(
        title: String?,
        text: String?
    ): String? {

        val content = "${title.orEmpty()} ${text.orEmpty()}".lowercase()

        return when {

            content.contains("airtel money") -> "Airtel Money"

            content.contains("mpamba") -> "TNM Mpamba"

            else -> null
        }
    }
}