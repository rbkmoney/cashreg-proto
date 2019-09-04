
namespace java com.rbkmoney.damsel.cashreg
namespace erlang cashreg


exception CashRegNotFound        {}
exception CashRegSessionNotFound {}
exception MachineAlreadyWorking  {}
exception IDExists               {}
exception OperationNotPermitted { 1: optional string details }