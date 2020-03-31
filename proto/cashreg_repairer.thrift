
namespace java com.rbkmoney.damsel.cashreg.repairer
namespace erlang cashreg_repairer

include "base.thrift"
include "cashreg_processing.thrift"
include "cashreg_receipt.thrift"

struct ComplexAction {
    1: optional TimerAction    timer
    3: optional RemoveAction   remove
}

union TimerAction {
    1: SetTimerAction          set_timer
    2: UnsetTimerAction        unset_timer
}

struct SetTimerAction {
    1: required Timer          timer
}

struct UnsetTimerAction {}

typedef i32 Timeout  # in seconds

union Timer {
    1: Timeout timeout
    2: base.Timestamp deadline
}

struct RemoveAction {}

union RepairScenario {
    1: AddEventsRepair add_events
}

struct AddEventsRepair {
    1: required list<cashreg_processing.Change> events
    2: optional ComplexAction                   action
}

service Repairer {
    void Repair(1: cashreg_receipt.ReceiptID receipt_id, 2: RepairScenario scenario)
        throws (
            1: cashreg_receipt.ReceiptNotFound ex1
            2: cashreg_receipt.MachineAlreadyWorking ex2
        )
}