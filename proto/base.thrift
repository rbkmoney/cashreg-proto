namespace java com.rbkmoney.file.storage.base
namespace erlang file_storage_base

/** Сумма в минимальных денежных единицах. */
typedef i64 Amount

enum CashRegStatus {
    none
    error
    ready
    sent
    fail
    done
    timeout
    unknown
}

/* Currencies */

/** Символьный код, уникально идентифицирующий валюту. */
typedef string CurrencySymbolicCode

/** Валюта. */
struct Currency {
    1: required string name
    2: required CurrencySymbolicCode symbolic_code
    3: required i16 numeric_code
    4: required i16 exponent
}


typedef map<string, string> StringMap

typedef StringMap Options

/** Контактная информация. **/
struct ContactInfo {
    1: optional string phone_number
    2: optional string email
}

struct Cash {
    1: required Amount amount
    2: required Currency currency
}
