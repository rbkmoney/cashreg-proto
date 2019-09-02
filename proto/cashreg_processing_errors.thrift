namespace java com.rbkmoney.damsel.cashreg_processing.errors
namespace erlang cashregprocerr

/**
  *
  *
  * # Статическое представление ошибок. (динамическое представление — domain.Failure)
  *
  * При переводе из статического в динамические формат представления следующий.
  * В поле code пишется строковое представления имени варианта в union,
  * далее если это не структура, а юнион, то в поле sub пишется SubFailure,
  * который рекурсивно обрабатывается по аналогичном правилам.
  *
  * Текстовое представление аналогично через имена вариантов в юнион с разделителем в виде двоеточия.
  *
  *
  * ## Например
  *
  *
  * ### Статически типизированное представление
  *
  * ```
  * PaymentFailure{
  *     authorization_failed = AuthorizationFailure{
  *         payment_tool_rejected = PaymentToolReject{
  *             bank_card_rejected = BankCardReject{
  *                 cvv_invalid = GeneralFailure{}
  *             }
  *         }
  *     }
  * }
  * ```
  *
  *
  * ### Текстовое представление (нужно только если есть желание представлять ошибки в виде текста)
  *
  * `authorization_failed:payment_tool_rejected:bank_card_rejected:cvv_invalid`
  *
  *
  * ### Динамически типизированное представление
  *
  * ```
  * domain.Failure{
  *     code = "authorization_failed",
  *     reason = "sngb error '87' — 'Invalid CVV'",
  *     sub = domain.SubFailure{
  *         code = "payment_tool_rejected",
  *         sub = domain.SubFailure{
  *             code = "bank_card_rejected",
  *             sub = domain.SubFailure{
  *                 code = "cvv_invalid"
  *             }
  *         }
  *     }
  * }
  * ```
  *
  */

union CashRegFailure {
    2: GeneralFailure       preauthorization_failed
    3: AuthorizationFailure authorization_failed
}

union AuthorizationFailure {
     1: GeneralFailure    unknown
     2: GeneralFailure    merchant_blocked
     3: GeneralFailure    operation_blocked
     4: GeneralFailure    account_not_found
     5: GeneralFailure    account_blocked
     6: GeneralFailure    account_stolen
     7: GeneralFailure    incorrect_currency
     8: GeneralFailure    temporarily_unavailable
     9: GeneralFailure    certificate_expired
}

struct GeneralFailure {}
