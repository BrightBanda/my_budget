package com.example.my_budget

import org.json.JSONObject

data class DetectedTransaction(
    val provider: String,
    val type: String,
    val amount: Double,
    val fee: Double?,
    val reference: String?,
    val rawMessage: String,
    val counterparty: String?,
    val detectedAt: Long
) {
    fun toJson(): String = JSONObject().apply {
        put("provider", provider)
        put("type", type)
        put("amount", amount)
        put("fee", fee ?: JSONObject.NULL)
        put("reference", reference ?: JSONObject.NULL)
        put("rawMessage", rawMessage)
        put("counterparty", counterparty ?: JSONObject.NULL)
        put("detectedAt", detectedAt)
    }.toString()
}
