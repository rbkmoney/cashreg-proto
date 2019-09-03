/**
 * Определения и сервисы процессинга.
 */

include "base.thrift"
include "domain.thrift"
include "user_interaction.thrift"
include "cashreg_provider.thrift"

namespace java com.rbkmoney.damsel.cashreg_processing
namespace erlang cashregproc

typedef base.ID     CashRegID
typedef list<Event> Events

typedef domain.PartyID PartyID
typedef domain.ShopID  ShopID


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
    2: CashRegStatusChanged  status_changed
    3: CashRegSessionChange  session_change
}

union CashRegStatus {
    1: CashRegPending       pending
    2: CashRegDelivered     delivered
    3: CashRegFailed        failed
}

/**
 * Событие об изменении статуса
 */
struct CashRegStatusChanged {
    /* Новый статус */
    1: required CashRegStatus status
}

struct CashRegSessionChange {
    1: required SessionChangePayload payload
}

union SessionChangePayload {
    1: SessionStarted               session_started
    2: SessionFinished              session_finished
    3: SessionStateChanged          session_state_changed
}

struct SessionStarted {
    1: required domain.ProxyOptions options
}

struct SessionStateChanged {
    1: required cashreg_provider.AdapterState state
}

struct SessionFinished {
    1: required SessionResult result
}

union SessionResult {
    1: SessionSucceeded succeeded
    2: SessionFailed    failed
}

struct SessionSucceeded {
    1: optional cashreg_provider.CashRegInfo    info
}

struct SessionFailed {
    1: required domain.OperationFailure failure
}

/**
 * Событие о создании
 */
struct CashRegCreated {
    1: required PartyID                         party_id
    2: required ShopID                          shop_id
    3: required cashreg_provider.SourceCreation source_creation
    4: required cashreg_provider.CashRegType    type
}

/* Создается в статусе pending */
struct CashRegPending {
    1: required cashreg_provider.AccountInfo account_info
}

/* Помечается статусом delivered, когда удалось доставить */
struct CashRegDelivered {
    1: required cashreg_provider.CashRegInfo    info
}

/* Помечается статусом failed, когда не удалось доставить */
struct CashRegFailed {
    1: required domain.Failure failure
}
