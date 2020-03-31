include "base.thrift"
include "domain.thrift"
include "cashreg_domain.thrift"
include "cashreg_receipt.thrift"
include "cashreg_receipt_type.thrift"


namespace java com.rbkmoney.damsel.cashreg.adapter
namespace erlang cashreg_adapter


typedef base.ID     CashregID

/**
 * Непрозрачное для процессинга состояние адаптера,
 * связанное с определённой сессией взаимодействия с третьей стороной.
 */
typedef base.Opaque AdapterState

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

struct CashregResult {
    1: required Intent                      intent
    2: optional AdapterState                state
    3: optional cashreg_receipt.ReceiptInfo info
}

/**
 * Данные сессии взаимодействия с провайдером.
 *
 * В момент, когда приложение успешно завершает сессию взаимодействия, процессинг считает,
 * что поставленная цель достигнута, и чек перешёл в соответствующий статус.
 */
struct Session {
    1: required cashreg_receipt_type.Type   type
    2: optional AdapterState        state
}

union SourceCreation {
    1: cashreg_domain.PaymentInfo payment
}
/**
 * Набор данных для взаимодействия с адаптером в рамках чеков онлайн.
 */
struct CashregContext {
    1: required CashregID                       cashreg_id
    2: required Session                         session
    3: required SourceCreation                  source_creation
    4: required cashreg_domain.AccountInfo      account_info

    /**
     * Настройки для адаптера, могут различаться в разных адаптерах
     * Example:
     * url, login, pass, group_id, client_id, tax_id, tax_mode, payment_method,
     * payment_object, key, private_key и т.д.
     **/
    5: optional domain.ProxyOptions             options      = {}
}

/**
 * Сервис для взаимодействия с kkt (Контрольно-кассовая техника, или ККТ)
 */
service CashregAdapter {

    CashregResult Register (1: CashregContext context)

}