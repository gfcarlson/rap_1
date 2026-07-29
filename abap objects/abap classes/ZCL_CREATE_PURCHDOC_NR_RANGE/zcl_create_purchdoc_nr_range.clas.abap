CLASS zcl_create_purchdoc_nr_range DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_create_purchdoc_nr_range IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    TRY.
        cl_numberrange_intervals=>create(
        EXPORTING
        interval = VALUE #( ( nrrangenr = '01'
        fromnumber = '0000000001'
        tonumber = '9999999999'
        procind = 'I' )
        )
         object = 'ZTG_PDOC'
         importing
         error = DATA(ld_error)
         error_inf = DATA(ls_error)
         error_iv = DATA(lt_error_iv)
         warning = DATA(ld_warning) ).

         CATCH cx_root INTO DATA(lo_error).
        out->write(  lo_error->get_text( ) ).
    ENDTRY.

    out->write(  |error: {  ld_error }| ).
    out->write(  ls_error ).
    out->write( lt_error_iv ).
    out->write( |warning {  ld_warning }| ).

  ENDMETHOD.





ENDCLASS.
