CLASS ycl_purchage_upload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_purchage_upload IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    DATA: lt_po_hdr TYPE STANDARD TABLE OF ytb_po_hdr,
          lt_po_itm TYPE STANDARD TABLE OF ytb_po_itm.

    DELETE FROM ytb_po_hdr.
    lt_po_hdr = VALUE #( ( client = '100' po_num = '4560000001' doc_cat = 'B' type = 'NB' comp_code = '3000' org = '0196' status = 'B' vendor = '0021000001' plants = '3000'  )
                         ( client = '100' po_num = '4560000002' doc_cat = 'B' type = 'NB' comp_code = '2000' org = '0196' status = 'A' vendor = '0021000001' plants = '3000'  )
                         ( client = '100' po_num = '4560000003' doc_cat = 'B' type = 'NB' comp_code = '3000' org = '0196' status = 'B' vendor = '0021000123' plants = '3000'  )
                         ( client = '100' po_num = '4560000004' doc_cat = 'B' type = 'NB' comp_code = '2000' org = '0196' status = 'C' vendor = '0021000001' plants = '3000'  )
                         ( client = '100' po_num = '4560000005' doc_cat = 'B' type = 'NB' comp_code = '3000' org = '0196' status = 'B' vendor = '0021000245' plants = '3000'  )
                         ( client = '100' po_num = '4560000006' doc_cat = 'B' type = 'NB' comp_code = '2000' org = '0196' status = 'A' vendor = '0021000045' plants = '3000'  )
                         ( client = '100' po_num = '4560000007' doc_cat = 'B' type = 'NB' comp_code = '3000' org = '0196' status = 'B' vendor = '0021000023' plants = '3000'  ) ).

    IF lt_po_hdr IS NOT INITIAL.
      INSERT ytb_po_hdr FROM TABLE @lt_po_hdr.
      IF sy-subrc IS INITIAL.
        out->write( 'Po Header data uploaded Successfully' ).
      ENDIF.
    ENDIF.

    DELETE FROM ytb_po_itm.
    lt_po_itm = VALUE #( ( client = '100' po_num = '4560000001' po_item = '00010' item_text = 'Laptop' material = 'IT/LENOVO-THINPAD' storage_loc = '3000' qty = '10' uom = 'ST' product_price = '1000000' price_unit = 'INR' plant = '3000'  )
                         ( client = '100' po_num = '4560000002' po_item = '00010' item_text = 'Laptop' material = 'IT/LENOVO-THINPAD' storage_loc = '3000' qty = '20' uom = 'ST' product_price = '2000000' price_unit = 'INR' plant = '3000'  )
                         ( client = '100' po_num = '4560000003' po_item = '00010' item_text = 'Laptop' material = 'IT/LENOVO-THINPAD' storage_loc = '3000' qty = '5'  uom = 'ST' product_price = '500000'  price_unit = 'INR' plant = '3000'  )
                         ( client = '100' po_num = '4560000004' po_item = '00010' item_text = 'Laptop' material = 'IT/LENOVO-THINPAD' storage_loc = '3000' qty = '10' uom = 'ST' product_price = '1000000' price_unit = 'INR' plant = '3000'  )
                         ( client = '100' po_num = '4560000005' po_item = '00010' item_text = 'Laptop' material = 'IT/LENOVO-THINPAD' storage_loc = '3000' qty = '30' uom = 'ST' product_price = '3000000' price_unit = 'INR' plant = '3000'  )
                         ( client = '100' po_num = '4560000006' po_item = '00010' item_text = 'Laptop' material = 'IT/LENOVO-THINPAD' storage_loc = '3000' qty = '40' uom = 'ST' product_price = '4000000' price_unit = 'INR' plant = '3000'  )
                         ( client = '100' po_num = '4560000007' po_item = '00010' item_text = 'Laptop' material = 'IT/LENOVO-THINPAD' storage_loc = '3000' qty = '10' uom = 'ST' product_price = '1000000' price_unit = 'INR' plant = '3000'  ) ).
  IF lt_po_itm IS NOT INITIAL.
      INSERT ytb_po_itm FROM TABLE @lt_po_itm.
      IF sy-subrc IS INITIAL.
        out->write( 'Po Item data uploaded Successfully' ).
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
