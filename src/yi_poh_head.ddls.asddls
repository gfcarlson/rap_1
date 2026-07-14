@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Document Header'
@Metadata.ignorePropagatedAnnotations: true
define root view entity YI_POH_HEAD
  as select from ytb_po_hdr
  composition [0..*] of YI_PO_ITEM as _items
{
  key po_num                  as PoNum,
      doc_cat                 as DocCat,
      type                    as Type,
      comp_code               as CompCode,
      org                     as Org,
      status                  as Status,
      vendor                  as Vendor,
      plants                  as Plants,
      discount as discount,
      created_by              as CreatedBy,
      create_date_time        as CreateDateTime,
      changed_by              as ChangedBy,
      changed_date_time       as ChangedDateTime,
      changed_local_date_time as ChangedLocalDateTime,
      _items // Make association public
}
