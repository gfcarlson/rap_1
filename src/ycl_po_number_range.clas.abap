CLASS ycl_po_number_range DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ycl_po_number_range IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
  DATA: lt_interval TYPE cl_numberrange_intervals=>NR_INTERVAL,
        ls_interval TYPE cl_numberrange_intervals=>nr_nriv_line.

  ls_interval-nrrangenr = 'PO'. " Interval Number
  ls_interval-fromnumber = '4560000000'. " Start Number
  ls_interval-tonumber = '4569999999'. " End Number
  ls_interval-procind = 'I'. " Internal or External ('E')
  APPEND ls_interval TO lt_interval.

  TRY.
      cl_numberrange_intervals=>create(
        EXPORTING
          object   = 'YRAP_PO' " Replace with your NRO name
          interval = lt_interval
        IMPORTING
          error    = DATA(ld_error)
          error_inf = DATA(ls_error_inf)
      ).
      IF ld_error = abap_false.
        " Success
        out->write( 'Number Ranged Created successfully' ).
        else.
        out->write( ls_error_inf-fieldname  ).
      ENDIF.
    CATCH cx_number_ranges INTO DATA(lo_error).
      " Handle Exception
      out->write( lo_error->get_text( ) ).
  ENDTRY.
  ENDMETHOD.
ENDCLASS.
