include "base.thrift"

namespace java com.rbkmoney.cashreg.proto.provider
namespace erlang cashreg_proto_provider


/**
 * Требование адаптера, отражающее дальнейший прогресс сессии взаимодействия с третьей стороной.
 */
union Intent {
    1: FinishIntent finish
}

/**
 * Требование завершить сессию взаимодействия с третьей стороной.
 */
struct FinishIntent {
    1: required FinishStatus status
}

/**
 * Статус, c которым завершилась сессия взаимодействия с третьей стороной.
 */
union FinishStatus {
    /** Успешное завершение взаимодействия. */
    1: Success success
    /** Неуспешное завершение взаимодействия с пояснением возникшей проблемы. */
    2: Failure failure
}

struct Success {
    // Если нужно еще запросить статус или продолжить поллинг
    1: optional string uuid
    // Получаем финальный ответ
    2: optional Payload payload
}

struct Payload {
    // Уникальный идентификатор по которому необходимо будет запросить статус
    1: optional string  uuid // 57969c81-ee1e-4fee-b2ae-8e3a652893ab
    2: optional string  total // 500
    3: optional string  fns_site // www.nalog.ru
    4: optional string  fn_number // 9289000144256552
    5: optional string  shift_number // 218
    6: optional string  receipt_datetime // 05.06.2029 14:29:00
    7: optional string  fiscal_receipt_number // 187
    8: optional string  fiscal_document_number // 85536
    9: optional string  ecr_registration_number // 0001411128011706
    10: optional string fiscal_document_attribute // 36554593
    11: optional string group_code // net_406
    12: optional string daemon_code // prod-agnt-1
    13: optional string device_code // KKT07513
    14: optional string timestamp // 05.06.2029 14:30:00
    15: optional string callback_url //
}

struct Failure {
    1: required string code
    2: optional string description
}

/**
 * Данные платежа, необходимые для обращения к адаптеру
 */
struct PaymentInfo {
    1: required Payer       payer
    2: required base.Cash   cash
    3: required Cart        cart
}

/**
 * Данные по плательщику
 **/
struct Payer {
    1: required base.ContactInfo contact_info
}

/**
 * Корзина с товарами
 **/
struct Cart {
    1: required list<ItemsLine> lines
}

struct ItemsLine {
    1: required string  product
    2: required i32     quantity
    3: required         base.Cash price
    4: required string  tax
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
 * Набор данных для взаимодействия с адаптером в рамках чеков онлайн.
 */
struct CashRegContext {
    // Уникальный идентификатор запроса
    1: required string          request_id
    2: required PaymentInfo     payment_info
    3: required AccountInfo     account_info

    /**
     * Настройки для адаптера, могут различаться в разных адаптерах
     * Example:
     * url, login, pass, group_id, client_id, tax_id, tax_mode, payment_method, payment_object, key, private_key
     **/
    4: optional base.Options    options      = {}
}


struct CashRegResult {
    1: required Intent intent
    // Необходимо для сохранения в базу, чтобы не искать по логам
    2: required string originalResponse
}

/**
 * Сервис для взаимодействия с kkt (Контрольно-кассовая техника, или ККТ)
 */
service CashRegProvider {

    // Приход (доход)
    CashRegResult Debit (1: CashRegContext context)

    // Расход
    CashRegResult Credit (1: CashRegContext context)

    // Возврат прихода (дохода)
    CashRegResult RefundDebit (1: CashRegContext context)

    // Возврат расхода
    CashRegResult RefundCredit (1: CashRegContext context)

    // Запросить статус
    CashRegResult GetStatus (1: CashRegContext context)

}