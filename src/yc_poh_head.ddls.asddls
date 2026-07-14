@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Document Header'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity YC_POH_HEAD  provider contract transactional_query 
as projection on YI_POH_HEAD
{
    key PoNum,
    DocCat,
    Type,
    CompCode,
    Org,
    Status,
    Vendor,
    Plants,
    CreatedBy,
    CreateDateTime,
    ChangedBy,
    ChangedDateTime,
    ChangedLocalDateTime,
    /* Associations */
    _items: redirected to composition child YC_PO_ITEM
}
