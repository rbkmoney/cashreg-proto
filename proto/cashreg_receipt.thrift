
namespace java com.rbkmoney.damsel.cashreg_receipt
namespace erlang cashreg_receipt

include "base.thrift"
include "domain.thrift"

exception ReceiptNotFound        {}
exception CashRegSessionNotFound {}
exception MachineAlreadyWorking  {}
exception IDExists               {}
exception OperationNotPermitted { 1: optional string details }


struct ReceiptInfo {
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