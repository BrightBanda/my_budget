package com.example.my_budget

data class DetectedTransaction(
    val provider: String,
    val type: String,
    val amount: Double,
    val fee: Double?,
    val reference: String?,
    val rawMessage: String
)