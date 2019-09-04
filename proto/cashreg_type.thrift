
namespace java com.rbkmoney.damsel.cashreg.type
namespace erlang cashreg_type


struct Debit { }
struct Credit { }
struct RefundDebit { }
struct RefundCredit { }

/**
 * Целевое значение статуса чека.
 */
union Type {

    /**
     * Чек на Приход (доход)
     */
    1: Debit         debit

    /**
     * Чек на Расход
     */
    2: Credit        credit

    /**
     * Возврат прихода (дохода)
     */
    3: RefundDebit   refund_debit

    /**
     * Чек на Возврат расхода
     */
    4: RefundCredit  refund_credit

}
