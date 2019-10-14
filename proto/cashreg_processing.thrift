
namespace java com.rbkmoney.damsel.cashreg_processing
namespace erlang cashregproc

include "cashreg.thrift"
include "base.thrift"
include "cashreg_status.thrift"
include "cashreg_type.thrift"
include "domain.thrift"
include "cashreg_repairer.thrift"
include "msgpack.thrift"
include "cashreg_provider.thrift"
include "cashreg_domain.thrift"

typedef base.ID                             CashRegID
typedef base.ID                             SessionID
typedef base.EventRange                     EventRange
typedef base.EventID                        EventID
typedef cashreg_status.Status               Status
typedef cashreg_provider.CashRegContext     ContextStatus
typedef domain.PartyID                      PartyID
typedef domain.ShopID                       ShopID

/**
 * Непрозрачное для процессинга состояние адаптера,
 * связанное с определённой сессией взаимодействия с третьей стороной.
 */
typedef base.Opaque AdapterState


struct Event {
    1: required EventID              event
    2: required base.Timestamp       occured_at
    3: required Change               change
}

union Change {
    1: CreatedChange    created
    2: StatusChange     status_changed
    3: SessionChange    session
}

struct CreatedChange {
    1: required CashReg cashreg
}

struct StatusChange {
    1: required Status status
}

struct SessionChange {
    1: required SessionID               id
    2: required SessionChangePayload    payload
}

union SessionChangePayload {
    1: SessionStarted               started
    2: SessionFinished              finished
    3: SessionAdapterStateChanged   session_adapter_state_changed
}

struct SessionStarted {}

struct SessionFinished {
    1: required SessionResult result
}

struct SessionAdapterStateChanged {
    1: required msgpack.Value state
}

union SessionResult {
    1: SessionSucceeded succeeded
    2: SessionFailed    failed
}

struct SessionSucceeded {
    1: required cashreg.CashRegInfo info
}

struct SessionFailed {
    1: required base.Failure failure
}

struct CashReg {
    1: required CashRegID                       id
    2: required PartyID                         party_id
    3: required ShopID                          shop_id
    4: required cashreg_domain.PaymentInfo      payment_info
    5: required cashreg_type.Type               type
    6: required Status                          status
    7: required cashreg_domain.AccountInfo      account_info
    8: required domain.DataRevision             domain_revision
    9: optional domain.PartyRevision            party_revision
    10: optional cashreg.CashRegInfo            info
    11: required domain.CashRegProviderRef      cashreg_provider_ref
}

struct CashRegParams {
    1: required CashRegID                       id
    2: required PartyID                         party_id
    3: required ShopID                          shop_id
    4: required domain.CashRegProviderRef       cashreg_provider_ref
    5: required cashreg_domain.PaymentInfo      payment_info
    6: required cashreg_type.Type               type
}

service Management {

    void Create(1: CashRegParams params)
        throws (
            1: cashreg.CashRegNotFound  ex1
        )

    CashReg Get(1: CashRegID id)
        throws ( 1: cashreg.CashRegNotFound ex1)

    list<Event> GetEvents(
        1: CashRegID id
        2: EventRange range)
        throws (
            1: cashreg.CashRegNotFound ex1
        )
}


/// Repair

union RepairScenario {
    1: AddEventsRepair add_events
}

struct AddEventsRepair {
    1: required list<Change>                    events
    2: optional cashreg_repairer.ComplexAction  action
}

service Repairer {
    void Repair(1: CashRegID id, 2: RepairScenario scenario)
        throws (
            1: cashreg.CashRegNotFound ex1
            2: cashreg.MachineAlreadyWorking ex2
        )
}