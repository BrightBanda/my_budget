package com.example.my_budget

/**
 * Turns an Airtel Money / TNM Mpamba notification into a [DetectedTransaction].
 *
 * Pure logic, no Android dependencies — everything here is unit-testable on the JVM
 * (see `TransactionParserTest`). The regexes are built from real message samples:
 *
 *   Mpamba:  "Money Sent to 0888349730 CHIKUMBUTSO MHANGO on 25/04/2026 16:46:19.
 *             Amount: 2,092.00MWK Fee: 19.00MWK VAT: Ref: DDP22VAI9MU Bal: 3,602.82MWK"
 *   Airtel:  "MWK2,600 sent: 1084669 ESTHER NGANGURA on 16/07/26 08:04 PM.
 *             Fee: MWK200, Levy: MK0.0. Bal: MWK105652.73 TID:CO260716.2004.RW9065."
 *
 * Two currency conventions have to coexist: Mpamba writes the unit *after* the number
 * (`2,092.00MWK`) while Airtel writes it *before* (`MWK2,600`, `MK 95,000`).
 */
object TransactionParser {

    /** A number carrying a currency marker on either side. Group 1 = prefixed, group 2 = suffixed. */
    private val AMOUNT_TOKEN = Regex(
        """(?:mwk|mk)\s?([0-9][0-9,]*(?:\.[0-9]{1,2})?)|([0-9][0-9,]*(?:\.[0-9]{1,2})?)\s?(?:mwk|mk)\b""",
        RegexOption.IGNORE_CASE
    )

    private val REFERENCE = Regex(
        """(?:ref(?:erence)?|txn\s*id|trans(?:action)?\s*id|tid)\s*[:.#]?\s*([a-z0-9][a-z0-9._-]{3,})""",
        RegexOption.IGNORE_CASE
    )

    /**
     * Counterparty name, sitting between the direction keyword and the ` on <date>` tail that
     * every sample ends the name with. A leading account/phone id is stripped afterwards.
     */
    private val COUNTERPARTY = Regex(
        """(?:\bto\b|\bfrom\b|\bsent:)\s+([A-Za-z0-9][A-Za-z0-9 .'&_-]*?)\s+on\b""",
        RegexOption.IGNORE_CASE
    )

    private val LEADING_ID = Regex("""^[0-9]+[-\s]*""")

    private val INCOME_WORDS = listOf("received", "cash in", "deposited", "credited", "refund")

    private val EXPENSE_WORDS = listOf(
        "sent", "paid", "payment", "withdrawn", "withdraw",
        "bought", "purchase", "debited", "cash out"
    )

    /** Labels that mark an amount as something other than the transaction value. */
    private val FEE_KEYWORDS = listOf("fee")
    private val NON_VALUE_KEYWORDS = listOf("fee", "bal", "levy", "vat", "charge")

    /** How far back to look for an amount's label. Labels ("Fee: ", "Bal: ") sit right before it. */
    private const val LABEL_WINDOW = 16

    fun parse(title: String?, text: String?, detectedAt: Long): DetectedTransaction? {
        val raw = listOfNotNull(title, text).joinToString(" ").trim()
        if (raw.isEmpty()) return null

        val provider = TransactionDetector.provider(title, text) ?: return null
        val type = resolveType(raw) ?: return null

        val lower = raw.lowercase()
        val amounts = AMOUNT_TOKEN.findAll(raw).toList()
        if (amounts.isEmpty()) return null

        // The transaction value is the first amount not tagged as a fee, levy, VAT or balance.
        val valueMatch = amounts.firstOrNull {
            !precededByAny(lower, it.range.first, NON_VALUE_KEYWORDS)
        } ?: return null
        val amount = toAmount(amountText(valueMatch)) ?: return null
        if (amount <= 0) return null

        val feeMatch = amounts.firstOrNull { precededByAny(lower, it.range.first, FEE_KEYWORDS) }
        val fee = feeMatch?.let { toAmount(amountText(it)) }?.takeIf { it > 0 }

        return DetectedTransaction(
            provider = provider,
            type = type,
            amount = amount,
            fee = fee,
            reference = REFERENCE.find(raw)?.groupValues?.get(1)?.trimEnd('.'),
            rawMessage = raw,
            counterparty = counterparty(raw),
            detectedAt = detectedAt
        )
    }

    private fun resolveType(raw: String): String? {
        val lower = raw.lowercase()

        // Income first: a "received ... cash out fee" message reads as income, not an expense.
        INCOME_WORDS.firstOrNull { lower.contains(it) }?.let { return "income" }
        EXPENSE_WORDS.firstOrNull { lower.contains(it) }?.let { return "expense" }

        return null
    }

    private fun counterparty(raw: String): String? {
        val captured = COUNTERPARTY.find(raw)?.groupValues?.get(1)?.trim() ?: return null
        val cleaned = captured.replace(LEADING_ID, "").trim()

        return cleaned.ifEmpty { null }
    }

    /** Value of an [AMOUNT_TOKEN] match, from whichever branch (prefix or suffix) fired. */
    private fun amountText(match: MatchResult): String =
        match.groupValues[1].ifEmpty { match.groupValues[2] }

    private fun precededByAny(lower: String, index: Int, keywords: List<String>): Boolean {
        val start = (index - LABEL_WINDOW).coerceAtLeast(0)
        val window = lower.substring(start, index)

        return keywords.any { window.contains(it) }
    }

    private fun toAmount(value: String): Double? =
        value.replace(",", "").replace(" ", "").toDoubleOrNull()
}
