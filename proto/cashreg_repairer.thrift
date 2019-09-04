
namespace java com.rbkmoney.damsel.cashreg.repairer
namespace erlang cashreg_repairer

include "base.thrift"

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
