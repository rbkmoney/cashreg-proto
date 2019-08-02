include "base.thrift"
include "domain.thrift"


namespace java com.rbkmoney.cashreg.proto.provider
namespace erlang cashreg_proto_provider


/**
 * Непрозрачное для процессинга состояние адаптера,
 * связанное с определённой сессией взаимодействия с третьей стороной.
 */
typedef base.Opaque AdapterState

struct Debit { }
struct Credit { }
struct RefundDebit { }
struct RefundCredit { }

/**
 * Целевое значение статуса чека.
 */
union TargetCashRegStatus {

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


/**
 * Требование к процессингу, отражающее дальнейший прогресс сессии взаимодействия
 * с третьей стороной.
 */
union Intent {
    1: FinishIntent finish
    2: SleepIntent  sleep
}

/**
 * Требование завершить сессию взаимодействия с третьей стороной.
 */
struct FinishIntent {
    1: required FinishStatus status
}

struct Success {
}

/**
 * Требование прервать на определённое время сессию взаимодействия,
 * с намерением продолжить её потом.
 */
struct SleepIntent {
    /** Таймер, определяющий когда следует продолжить взаимодействие. */
    1: required base.Timer timer
}


/**
 * Статус, c которым завершилась сессия взаимодействия с третьей стороной.
 */
union FinishStatus {
    /** Успешное завершение взаимодействия. */
    1: Success          success
    /** Неуспешное завершение взаимодействия с пояснением возникшей проблемы. */
    2: domain.Failure   failure
}

struct CashRegResult {
    1: required Intent      intent
    2: optional CashRegInfo cashreg_info
}


struct CashRegInfo {
    1: required string          receipt_id
    2: optional base.Timestamp  timestamp //   2029-06-05T14:30:00Z
    3: optional string          total // 500
    4: optional string          fns_site // www.nalog.ru
    5: optional string          fn_number // 9289000144256552
    6: optional string          shift_number // 218
    7: optional base.Timestamp  receipt_datetime // 2029-06-05T14:29:00Z
    8: optional string          fiscal_receipt_number // 187
    9: optional string          fiscal_document_number // 85536
    10: optional string         ecr_registration_number // 0001411128011706
    11: optional string         fiscal_document_attribute // 36554593
    12: optional string         group_code // net_406
    13: optional string         daemon_code // prod-agnt-1
    14: optional string         device_code // KKT07513
    15: optional string         callback_url //
}

/**
 * Данные о текущем аккаунте
 **/
struct AccountInfo {
    1: required CompanyInfo company_info
}

struct CompanyInfo {
    1: required string name
    2: required string address
    3: required string email
    4: required string inn
    5: required TaxMode tax_mode
}

/**
 * Режим налогообложения
 *
 * «osn» – общая СН;
 * «usn_income» – упрощенная СН (доходы);
 * «usn_income_outcome» – упрощенная СН (доходы минус расходы);
 * «envd» – единый налог на вмененный доход;
 * «esn» – единый сельскохозяйственный налог;
 * «patent» – патентная СН.
 **/
enum TaxMode {
    osn
    usn_income
    usn_income_outcome
    envd
    esn
    patent
}


/**
 * Данные сессии взаимодействия с провайдером.
 *
 * В момент, когда приложение успешно завершает сессию взаимодействия, процессинг считает,
 * что поставленная цель достигнута, и чек перешёл в соответствующий статус.
 */
struct Session {
    1: required TargetCashRegStatus target
    2: optional AdapterState        state
}

/**
 * Данные платежа, необходимые для обращения к адаптеру
 */
struct PaymentInfo {
    1: required Invoice                 invoice
    2: required InvoicePayment          payment
    3: optional InvoicePaymentRefund    refund
    4: required domain.Cash             cash
    5: required Cart                    cart
}

struct Invoice {
    1: required domain.InvoiceID        id
    2: required base.Timestamp          created_at
    3: required base.Timestamp          due
    7: required domain.InvoiceDetails   details
    6: required Cash                    cash
}

struct InvoicePayment {
    1: required domain.InvoicePaymentID id
    2: required base.Timestamp          created_at
    3: optional domain.TransactionInfo  trx
    5: required Cash                    cash
    7: required domain.ContactInfo      contact_info
}

struct InvoicePaymentRefund {
    1: required domain.InvoicePaymentRefundID id
    2: required base.Timestamp                created_at
    4: required Cash                          cash
    3: optional domain.TransactionInfo        trx
}

struct Cash {
    1: required domain.Amount   amount
    2: required domain.Currency currency
}

/**
 * Корзина с товарами
 **/
struct Cart {
    1: required list<ItemsLine> lines
}

struct ItemsLine {
    1: required string      product
    2: required i32         quantity
    3: required domain.Cash price
    4: required string      tax
}

/**
 * Набор данных для взаимодействия с адаптером в рамках чеков онлайн.
 */
struct CashRegContext {
    1: required Session         session
    2: required PaymentInfo     payment_info
    3: required AccountInfo     account_info

    /**
     * Настройки для адаптера, могут различаться в разных адаптерах
     * Example:
     * url, login, pass, group_id, client_id, tax_id, tax_mode, payment_method,
      *payment_object, key, private_key
     **/
    4: optional domain.ProxyOptions    options      = {}
}


/**
 * Сервис для взаимодействия с kkt (Контрольно-кассовая техника, или ККТ)
 */
service CashRegProvider {

    CashRegResult Register (1: CashRegContext context)

}