@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Document Item'
@Metadata.ignorePropagatedAnnotations: true
define view entity YI_PO_ITEM
  as select from ytb_po_itm
  association to parent YI_POH_HEAD as _head on $projection.PoNum = _head.PoNum
{
  key po_num                  as PoNum,
  key po_item                 as PoItem,
      item_text               as ItemText,
      material                as Material,
      plant                   as Plant,
      storage_loc             as StorageLoc,
      @Semantics.quantity.unitOfMeasure: 'Uom'
      qty                     as Qty,
      uom                     as Uom,
      @Semantics.amount.currencyCode: 'PriceUnit'
      product_price           as ProductPrice,
      price_unit              as PriceUnit,
      discount as discount,
      changed_by              as ChangedBy,
      changed_date_time       as ChangedDateTime,
      changed_local_date_time as ChangedLocalDateTime,
      _head // Make association public
}
