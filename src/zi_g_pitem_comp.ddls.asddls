//@AbapCatalog.sqlViewName: 'ZIPURCHDOCITEMTP'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Document Item'
//@AbapCatalog.preserveKey: true
//@ObjectModel.writeActivePersistence: 'ZPURCHDOCITEM'
@VDM.viewType: #COMPOSITE
@Metadata.allowExtensions:true
define view entity ZI_G_PItem_COMP
  as select from ZI_G_PItem
  association to parent ZI_G_PDoc_RV_COMP as _PurchaseDocument on $projection.PurchaseDocument = _PurchaseDocument.PurchaseDocument
{

  key PurchaseDocumentItem,
  key PurchaseDocument,
      Description,
      Vendor,
      VendorType,
      Price,
      Currency,
      Quantity,
      QuantityUnit,
      OverallItemPrice,     
      PurchaseDocumentItemImageURL,

      // BOPF Admin Data
      crea_date_time,
      crea_uname,
      lchg_date_time,
      lchg_uname,

      /* Associations */
      _Currency,
      _PurchaseDocument,
      _QuantityUnitOfMeasure,
      _VendorType

}
