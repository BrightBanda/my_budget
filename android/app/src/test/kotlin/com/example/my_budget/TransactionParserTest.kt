package com.example.my_budget

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * Every message here is a real Airtel Money / TNM Mpamba notification. When these providers
 * change their wording, add the new sample here first, watch it fail, then fix the parser.
 */
class TransactionParserTest {

    private fun parse(title: String, body: String) =
        TransactionParser.parse(title, body, detectedAt = 0L)

    // ---- TNM Mpamba ---------------------------------------------------------

    @Test
    fun mpamba_moneySent_isExpenseWithFee() {
        val t = parse(
            "MPAMBA",
            "Money Sent to 0888349730 CHIKUMBUTSO MHANGO on 25/04/2026 16:46:19. " +
                "Amount: 2,092.00MWK Fee: 19.00MWK VAT: Ref: DDP22VAI9MU Bal: 3,602.82MWK"
        )!!

        assertEquals("TNM Mpamba", t.provider)
        assertEquals("expense", t.type)
        assertEquals(2092.00, t.amount, 0.001)
        assertEquals(19.00, t.fee!!, 0.001)
        assertEquals("DDP22VAI9MU", t.reference)
        assertEquals("CHIKUMBUTSO MHANGO", t.counterparty)
    }

    @Test
    fun mpamba_cashIn_isIncomeAndDropsZeroFee() {
        val t = parse(
            "MPAMBA",
            "Cash In from 131234-INNOCENT GONDWE OUTLET 1 on 25/04/2026 16:59:31. " +
                "Amt: 4,000.00MWK Fee: 0.00MWK Ref: DDP52VAK4FD Bal: 7,602.82MWK"
        )!!

        assertEquals("income", t.type)
        assertEquals(4000.00, t.amount, 0.001)
        assertNull(t.fee)
        assertEquals("DDP52VAK4FD", t.reference)
        assertEquals("INNOCENT GONDWE OUTLET 1", t.counterparty)
    }

    @Test
    fun mpamba_received_withCashOutFee_isIncomePlusFee() {
        val t = parse(
            "MPAMBA",
            "You have received 2,000.00MWK and cash out fee of 91.00MWK from " +
                "265881154426 ESTHER MOYO on 25/04/2026 17:34:21. Ref: DDP02VAPDWM Bal: 5,693.82MWK"
        )!!

        assertEquals("income", t.type)
        assertEquals(2000.00, t.amount, 0.001)
        assertEquals(91.00, t.fee!!, 0.001)
        assertEquals("ESTHER MOYO", t.counterparty)
    }

    @Test
    fun mpamba_moneyReceived_isIncomeNoFee() {
        val t = parse(
            "MPAMBA",
            "Money Received from 265884142129 EDMOND BANDA on 21/04/2026 17:58:32. " +
                "Amount: 14,000.00MWK Ref: DDL62UXJC78 Bal: 14,223.82MWK"
        )!!

        assertEquals("income", t.type)
        assertEquals(14000.00, t.amount, 0.001)
        assertNull(t.fee)
        assertEquals("EDMOND BANDA", t.counterparty)
    }

    // ---- Airtel Money -------------------------------------------------------

    @Test
    fun airtel_sent_isExpenseWithFee() {
        val t = parse(
            "AIRTELMONEY",
            "MWK2,600 sent: 1084669 ESTHER NGANGURA on 16/07/26 08:04 PM. " +
                "Fee: MWK200, Levy: MK0.0. Bal: MWK105652.73 TID:CO260716.2004.RW9065."
        )!!

        assertEquals("Airtel Money", t.provider)
        assertEquals("expense", t.type)
        assertEquals(2600.00, t.amount, 0.001)
        assertEquals(200.00, t.fee!!, 0.001)
        assertEquals("CO260716.2004.RW9065", t.reference)
        assertEquals("ESTHER NGANGURA", t.counterparty)
    }

    @Test
    fun airtel_received_isIncomeNoFee() {
        val t = parse(
            "AIRTELMONEY",
            "BW260717.1451.869448. You have received MK 95,000 from NATIONAL BANK " +
                "on 17/07/26 02:51 PM. Ref FT26198PRDKP Bal: MK 199052.73."
        )!!

        assertEquals("income", t.type)
        assertEquals(95000.00, t.amount, 0.001)
        assertNull(t.fee)
        assertEquals("FT26198PRDKP", t.reference)
        assertEquals("NATIONAL BANK", t.counterparty)
    }

    // ---- Negative cases -----------------------------------------------------

    @Test
    fun promotionalMessage_isIgnored() {
        assertNull(
            parse("MPAMBA", "Dial *444# to buy data bundles and win airtime this weekend!")
        )
    }

    @Test
    fun nonProviderNotification_isIgnored() {
        assertNull(parse("WhatsApp", "You sent MWK500 to a friend"))
    }

    @Test
    fun levyIsNeverMistakenForTheValue() {
        // Levy sits before Bal and after Fee; the value must still be the leading amount.
        val t = parse(
            "AIRTELMONEY",
            "MWK1,500 sent: 10229409 ZIKIEL MASAUTSO on 17/07/26 06:36 AM. " +
                "Fee: MWK100, Levy: MK0.0. Bal: MWK104052.73 TID:CO260717.0636.YX6735."
        )!!

        assertEquals(1500.00, t.amount, 0.001)
        assertEquals(100.00, t.fee!!, 0.001)
        assertTrue(t.fee!! > 0)
    }
}
