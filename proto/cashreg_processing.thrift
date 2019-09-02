/**
 * Определения и сервисы процессинга.
 */

include "base.thrift"
include "domain.thrift"
include "user_interaction.thrift"
include "cashreg_provider.thrift"

namespace java com.rbkmoney.damsel.cashreg_processing
namespace erlang cashregproc

typedef base.ID CashRegID
typedef list<Event> Events


/**
 * Событие, атомарный фрагмент истории бизнес-объекта
 */
struct Event {

    /**
     * Идентификатор события.
     * Монотонно возрастающее целочисленное значение, таким образом на множестве
     * событий задаётся отношение полного порядка (total order)
     */
    1: required base.EventID id

    /**
     * Время создания события
     */
    2: required base.Timestamp created_at

    /**
     * Идентификатор бизнес-объекта, источника события
     */
    3: required EventSource source

    /**
     * Содержание события, состоящее из списка (возможно пустого)
     * изменений состояния бизнес-объекта, источника события
     */
    4: required EventPayload payload

}

/**
 * Источник события, идентификатор бизнес-объекта, который породил его в
 * процессе выполнения определённого бизнес-процесса
 */
union EventSource {
    /* Идентификатор, который породил событие */
    1: CashRegID cashreg_id
}

/**
 * Один из возможных вариантов содержания события
 */
union EventPayload {
    /* Набор изменений */
    1: list<CashRegChange> cashreg_changes
}

/**
 * Один из возможных вариантов события
 */
union CashRegChange {
    1: CashRegCreated        created
    2: CashRegStatusChanged  cashreg_status_changed
}

union CashRegStatus {
    1: CashRegVerification  verification
    2: CashRegPending       pending
    3: CashRegDisabled      disabled
    4: CashRegDelivered     delivered
    5: CashRegFailed        failed
}

/**
 * Событие об изменении статуса
 */
struct CashRegStatusChanged {
    /* Новый статус */
    1: required CashRegStatus status
}

/**
 * Событие о создании
 */
struct CashRegCreated {
    1: required cashreg_provider.CashRegContext context
}

/* Когда надо проверить, включена ли возможность отправки */
struct CashRegVerification {
    1: required cashreg_provider.CashRegContext context
}


/* Создается в статусе pending */
struct CashRegPending {
    1: required cashreg_provider.CashRegContext context
}

/* Помечается статусом disabled, когда взаимодействие с кассой прекращено */
struct CashRegDisabled {
 1: required domain.Failure failure
}

/* Помечается статусом delivered, когда удалось доставить */
struct CashRegDelivered {
    1: required cashreg_provider.CashRegContext context
    2: required cashreg_provider.CashRegInfo    info
}

/* Помечается статусом failed, когда не удалось доставить */
struct CashRegFailed {
 1: required domain.Failure failure
}
