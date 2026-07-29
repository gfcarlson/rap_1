@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Document Item'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity YC_PO_ITEM as projection on YI_PO_ITEM
{
    key PoNum,
    key PoItem,
    ItemText,
    Material,
    Plant,
    StorageLoc,
    @Semantics.quantity.unitOfMeasure: 'Uom'
    Qty,
    Uom,
    @Semantics.amount.currencyCode: 'PriceUnit'
    ProductPrice,
    PriceUnit,
    ChangedBy,
    ChangedDateTime,
    ChangedLocalDateTime,
    /* Associations */
    _head: redirected to parent YC_POH_HEAD
}
