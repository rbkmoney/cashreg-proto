/**
 * Отметка во времени согласно RFC 3339.
 *
 * Строка должна содержать дату и время в UTC в следующем формате:
 * `2016-03-22T06:12:27Z`.
 */


namespace java com.rbkmoney.damsel.cashreg.base
namespace erlang cashreg_base

/** Идентификатор объекта */
typedef string ID

/** Идентификатор некоторого события */
typedef i64 EventID

struct EventRange {
    1: optional EventID after
    2: required i32     limit
}

/** Непрозрачный для участника общения набор данных */
typedef binary Opaque


/**
 * Отметка во времени согласно RFC 3339.
 *
 * Строка должна содержать дату и время в UTC в следующем формате:
 * `2016-03-22T06:12:27Z`.
 */
typedef string Timestamp

/** Отрезок времени в секундах */
typedef i32 Timeout


typedef i64 DataRevision
typedef i64 PartyRevision


/** Критерий остановки таймера */
union Timer {
    /** Отрезок времени, после истечения которого таймер остановится */
    1: Timeout timeout
    /** Отметка во времени, при пересечении которой таймер остановится */
    2: Timestamp deadline
}


/**
 * Ошибки
 *
 * Украдено из https://github.com/rbkmoney/damsel/blob/8235b6f6/proto/domain.thrift#L31
 */
struct Failure {
    1: required FailureCode     code;
    2: optional FailureReason   reason;
    3: optional SubFailure      sub;
}

typedef string FailureCode
typedef string FailureReason // причина возникшей ошибки и пояснение откуда она взялась

// возможность делать коды ошибок иерархическими
struct SubFailure {
    1: required FailureCode  code;
    2: optional SubFailure   sub;
}
