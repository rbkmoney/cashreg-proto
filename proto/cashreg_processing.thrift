
namespace java com.rbkmoney.damsel.cashreg.processing
namespace erlang cashreg_processing

include "cashreg_receipt.thrift"
include "base.thrift"
include "cashreg_receipt_status.thrift"
include "cashreg_receipt_type.thrift"
include "domain.thrift"
include "msgpack.thrift"
include "cashreg_adapter.thrift"
include "cashreg_domain.thrift"

typedef base.ID                             CashRegisterProviderID
typedef base.ID                             SessionID
typedef base.EventRange                     EventRange
typedef base.EventID                        EventID
typedef cashreg_receipt_status.Status       Status
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
    1: required Receipt receipt
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
    1: required cashreg_receipt.ReceiptInfo info
}

struct SessionFailed {
    1: required base.Failure failure
}

struct Receipt {
    1: required cashreg_receipt.ReceiptID       receipt_id
    2: required PartyID                         party_id
    3: required ShopID                          shop_id
    4: required CashRegisterProviderID          cashreg_provider_id
    5: required cashreg_domain.PaymentInfo      payment_info
    6: required cashreg_receipt_type.Type       type
    7: required Status                          status
    8: required cashreg_domain.AccountInfo      account_info
    9: required domain.DataRevision             domain_revision
    10: optional domain.PartyRevision           party_revision
    11: optional cashreg_receipt.ReceiptInfo    info
}

struct CashRegisterProvider {
    1: required CashRegisterProviderID          cash_register_provider_id
    2: required map<string, string>             cash_register_provider_params
}

struct ReceiptParams {
    1: required cashreg_receipt.ReceiptID       receipt_id
    2: required PartyID                         party_id
    3: required ShopID                          shop_id
    4: required list<CashRegisterProvider>      cash_register_providers
    5: required cashreg_domain.PaymentInfo      payment_info
    6: required cashreg_receipt_type.Type       type
}

service Management {

    void Create(1: ReceiptParams receipt_params)
        throws (
            1: cashreg_receipt.ReceiptNotFound  ex1
        )

    Receipt Get(1: cashreg_receipt.ReceiptID receipt_id)
        throws (
            1: cashreg_receipt.ReceiptNotFound ex1
         )

    list<Event> GetEvents(
        1: cashreg_receipt.ReceiptID receipt_id
        2: EventRange range)
        throws (
            1: cashreg_receipt.ReceiptNotFound ex1
        )
}
