include "base.thrift"
include "domain.thrift"
include "cashreg.thrift"
include "cashreg_type.thrift"


namespace java com.rbkmoney.damsel.cashreg.provider
namespace erlang cashreg_provider


typedef base.ID     CashRegID

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

struct CashRegResult {
    1: required Intent              intent
    2: optional cashreg.CashRegInfo cashreg_info
}


/**
 * Данные о текущем аккаунте
 **/
struct AccountInfo {
    1: required LegalEntity legal_entity
}

union LegalEntity {
    1: RussianLegalEntity russian_legal_entity
}

/** Юридическое лицо-резидент РФ */
struct RussianLegalEntity {
    /* Наименование */
    1: required string registered_name
    /* ОГРН */
    2: required string registered_number
    /* ИНН/КПП */
    3: required string inn
    /* Адрес места нахождения */
    4: required string actual_address
    /* Адрес для отправки корреспонденции (почтовый) */
    5: required string post_address
    /* Электронный адрес */
    6: required string email
    /* Наименование должности ЕИО/представителя */
    7: required string representative_position
    /* ФИО ЕИО/представителя */
    8: required string representative_full_name
    /* Наименование документа, на основании которого действует ЕИО/представитель */
    9: required string representative_document
    /* Реквизиты юр.лица */
    10: required RussianBankAccount russian_bank_account
    /* Режим налогообложения */
    11: required TaxMode tax_mode
}

/** Банковский счёт. */

struct RussianBankAccount {
    1: required string account
    2: required string bank_name
    3: required string bank_post_account
    4: required string bank_bik
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
    1: required cashreg_type.Type   type
    2: optional AdapterState        state
}

/**
 * Данные платежа, необходимые для обращения к адаптеру
 */
struct PaymentInfo {
    1: required CashRegID               id
    4: required domain.Cash             cash
    5: required Cart                    cart
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

union SourceCreation {
    1: PaymentInfo payment
}
/**
 * Набор данных для взаимодействия с адаптером в рамках чеков онлайн.
 */
struct CashRegContext {
    1: required Session         session
    2: required SourceCreation  source_creation
    3: required AccountInfo     account_info

    /**
     * Настройки для адаптера, могут различаться в разных адаптерах
     * Example:
     * url, login, pass, group_id, client_id, tax_id, tax_mode, payment_method,
     * payment_object, key, private_key и т.д.
     **/
    4: optional domain.ProxyOptions    options      = {}
}


/**
 * Сервис для взаимодействия с kkt (Контрольно-кассовая техника, или ККТ)
 */
service CashRegProvider {

    CashRegResult Register (1: CashRegContext context)

}