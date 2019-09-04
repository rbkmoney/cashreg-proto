
namespace java com.rbkmoney.damsel.cashreg_processing
namespace erlang cashregproc

include "cashreg.thrift"
include "base.thrift"
include "cashreg_status.thrift"
include "cashreg_type.thrift"
include "domain.thrift"
include "cashreg_repairer.thrift"

typedef base.ID                 CashRegID
typedef base.ID                 SessionID
typedef base.EventRange         EventRange
typedef base.EventID            EventID
typedef cashreg_status.Status   Status
typedef domain.PartyID          PartyID
typedef domain.ShopID           ShopID


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
    1: required SessionID id
    2: required SessionChangePayload payload
}

union SessionChangePayload {
    1: SessionStarted   started
    2: SessionFinished  finished
}

struct SessionStarted {}
struct SessionFinished {}


struct CashReg {
    1: required PartyID             party_id
    2: required ShopID              shop_id
    3: required PaymentInfo         payment_info
    4: required cashreg_type.Type   type
    5: optional Status              status
    6: optional CashRegInfo         info
}

struct CashRegParams {
    1: required PartyID             party_id
    2: required ShopID              shop_id
    3: required PaymentInfo         payment_info
    4: required cashreg_type.Type   type
}

struct CashRegInfo {
    1: required string          receipt_id
    2: optional base.Timestamp  timestamp //   2029-06-05T14:30:00Z
    3: optional string          total // 500
    4: optional string          fns_site // www.nalog.ru
    5: optional string          fn_number // 9289000144256552
    6: optional string          shift_number // 218
    7: optional base.Timestamp  receipt_datetime // 2029-06-05T14:29:00Z
    8: optional string          fiscal_receipt_number // 187
    9: optional string          fiscal_document_number // 85536
    10: optional string         ecr_registration_number // 0001411128011706
    11: optional string         fiscal_document_attribute // 36554593
    12: optional string         group_code // net_406
    13: optional string         daemon_code // prod-agnt-1
    14: optional string         device_code // KKT07513
    15: optional string         callback_url //
}

/**
 * Данные платежа, необходимые для обращения к адаптеру
 */
struct PaymentInfo {
    1: required CashRegID               cashreg_id
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

service Management {

    CashReg Create(1: CashRegParams params)
        throws (
            1: cashreg.IDExists                    ex1
            2: cashreg.CashRegNotFound             ex2
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