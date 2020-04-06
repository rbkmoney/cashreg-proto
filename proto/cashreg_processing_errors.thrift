
namespace java com.rbkmoney.damsel.cashreg.processing.errors
namespace erlang cashreg_processing_errors

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
  * CashregFailure{
  *     verification_failure = VerificationFailure{
  *         unknown = GeneralFailure{
  *         }
  *     }
  * }
  * ```
  *
  *
  * ### Текстовое представление (нужно только если есть желание представлять ошибки в виде текста)
  *
  * `verification_failure:unknown`
  *
  *
  * ### Динамически типизированное представление
  *
  * ```
  * domain.Failure{
  *     code = "verification_failure",
  *     reason = "error — description",
  *     sub = domain.SubFailure{
  *         code = "unknown",
  *     }
  * }
  * ```
  *
  */

union CashregFailure {
    1: GeneralFailure       unknown
    2: VerificationFailure  verification_failure
    3: DeliveryFailure      delivery_failure
}

union DeliveryFailure {
    1: GeneralFailure       unknown
    2: GeneralFailure       certificate_expired
}

union VerificationFailure {
     1: GeneralFailure    unknown
     2: GeneralFailure    merchant_blocked
     3: GeneralFailure    account_not_found
     4: GeneralFailure    account_blocked
}

struct GeneralFailure {}
