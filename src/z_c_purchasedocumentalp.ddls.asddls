@AbapCatalog.sqlViewName: 'ZCPRCHDCCUBE'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Documents ALP'
@Metadata.allowExtensions:true
@Analytics.query: true
//@OData.publish: true
@VDM.viewType: #CONSUMPTION
define view Z_C_PurchaseDocumentALP as select from Z_I_PurchaseDocumentCube
{
  @AnalyticsDetails.query.display: #KEY_TEXT
  @ObjectModel.text.element:['PurchaseDocumentName']
  @Consumption.semanticObject: 'PurchasingDocument'
  @AnalyticsDetails:{ query : { axis : #ROWS } }
key  PurchaseDocument,  
  @AnalyticsDetails.query.display: #KEY_TEXT
  @ObjectModel.text.element:['Description']
  @EndUserText.label: 'Purchase Document Item'  
  @AnalyticsDetails:{ query : { axis : #ROWS } }  
key  PurchaseDocumentItem,

  @Semantics.text: true
  @EndUserText.label: 'Purchase Document Name'
  PurchaseDocumentName,
  
  @Semantics.text: true

@EndUserText.label: 'Purchae Document Item Name'
@AnalyticsDetails:{ query : { axis : #ROWS } }    
  Description,
  
  @EndUserText.label: 'Price'
  @Semantics.amount.currencyCode: 'Currency'
  Price,
  @EndUserText.label: 'Currency'
  @Semantics.currencyCode: true
  Currency,
  @AnalyticsDetails.query.display: #KEY_TEXT
  @EndUserText.label: 'Priority'
  @Consumption.filter: { selectionType: #RANGE, multipleSelections: true , mandatory: false}
  Priority,
  @AnalyticsDetails.query.display: #KEY_TEXT
  @EndUserText.label: 'Status'
  @Consumption.filter: { selectionType: #RANGE, multipleSelections: true , mandatory: false}
  Status,
  @AnalyticsDetails.query.display: #KEY_TEXT
  @EndUserText.label: 'Vendor'
  @Consumption.filter: { selectionType: #RANGE, multipleSelections: true , mandatory: false}
  Vendor,
  @AnalyticsDetails.query.display: #KEY_TEXT
  @EndUserText.label: 'Vendor Type'
  @Consumption.filter: { selectionType: #RANGE, multipleSelections: true , mandatory: false}
  VendorType,
  @AnalyticsDetails.query.display: #KEY_TEXT
  @EndUserText.label: 'Purchasing Organization'
  @Consumption.filter: { selectionType: #RANGE, multipleSelections: true , mandatory: false}
  PurchasingOrganization,
  @EndUserText.label: 'Number of Document Items'
  NumberOfDocuments,
  @EndUserText.label: 'Quantity'
  @Semantics.quantity.unitOfMeasure: 'QuantityUnit'
  @AnalyticsDetails:{ query : { axis : #COLUMNS } }
  Quantity,
  @EndUserText.label: 'Quantity Unit'
  @Semantics.unitOfMeasure: true
  QuantityUnit,
  
  @EndUserText.label: 'Overall Item Price'
  OverallItemPrice,
  @EndUserText.label: 'Created On'
  CreatedOn

}
