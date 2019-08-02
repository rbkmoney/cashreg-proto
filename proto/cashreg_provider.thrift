include "base.thrift"
include "domain.thrift"


namespace java com.rbkmoney.cashreg.proto.provider
namespace erlang cashreg_proto_provider


/**
 * Непрозрачное для процессинга состояние адаптера,
 * связанное с определённой сессией взаимодействия с третьей стороной.
 */
typedef base.Opaque AdapterState

struct CashRegDebit { }
struct CashRegCredit { }
struct CashRegRefundDebit { }
struct CashRegRefundCredit { }

/**
 * Целевое значение статуса чека.
 */
union TargetCashRegStatus {

    /**
     * Чек на Приход (доход)
     */
    1: CashRegDebit         debit

    /**
     * Чек на Расход
     */
    2: CashRegCredit        credit

    /**
     * Возврат прихода (дохода)
     */
    3: CashRegRefundDebit   refund_debit

    /**
     * Чек на Возврат расхода
     */
    4: CashRegRefundCredit  refund_credit

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
    2: optional base.Timestamp  timestamp // 05.06.2029 14:30:00
    3: optional string          total // 500
    4: optional string          fns_site // www.nalog.ru
    5: optional string          fn_number // 9289000144256552
    6: optional string          shift_number // 218
    7: optional string          receipt_datetime // 05.06.2029 14:29:00
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
    1: required Payer           payer
    2: required domain.Cash     cash
    3: required Cart            cart
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
 * Данные по плательщику
 **/
struct Payer {
    1: required domain.ContactInfo contact_info
}

/**
 * Набор данных для взаимодействия с адаптером в рамках чеков онлайн.
 */
struct CashRegContext {
    1: required Session         session

    // Уникальный идентификатор запроса
    2: required string          request_id
    3: required PaymentInfo     payment_info
    4: required AccountInfo     account_info

    /**
     * Настройки для адаптера, могут различаться в разных адаптерах
     * Example:
     * url, login, pass, group_id, client_id, tax_id, tax_mode, payment_method,
      *payment_object, key, private_key
     **/
    5: optional domain.ProxyOptions    options      = {}
}


/**
 * Сервис для взаимодействия с kkt (Контрольно-кассовая техника, или ККТ)
 */
service CashRegProvider {

    CashRegResult Register (1: CashRegContext context)

}