/**
 * Статусы
 */

namespace java com.rbkmoney.damsel.cashreg.status
namespace erlang cashreg_status

include "base.thrift"
typedef base.Failure          Failure

union Status {
    1: Pending pending
    2: Delivered delivered
    3: Failed failed
}

struct Pending {}
struct Delivered {}
struct Failed {
    1: required Failure failure
}
