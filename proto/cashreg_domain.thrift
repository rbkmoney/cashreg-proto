
namespace java com.rbkmoney.damsel.cashreg_domain
namespace erlang cashregprocdomain

include "domain.thrift"
include "cashreg_receipt.thrift"

/**
 * Данные платежа, необходимые для обращения к адаптеру
 */
struct PaymentInfo {
    1: required domain.Cash     cash
    2: required cashreg_receipt.Cart    cart
    3: required string          email
}

struct Cash {
    1: required domain.Amount   amount
    2: required domain.Currency currency
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

