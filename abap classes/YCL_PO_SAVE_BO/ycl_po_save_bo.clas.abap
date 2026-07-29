CLASS ycl_po_save_bo DEFINITION
  PUBLIC
  INHERITING FROM cl_abap_behv
  FINAL
  CREATE PROTECTED .
  PUBLIC SECTION.
    TYPES: tt_po_hdr TYPE STANDARD TABLE OF ytb_po_hdr,
           tt_po_itm TYPE STANDARD TABLE OF ytb_po_itm.

    TYPES: tt_po_failed    TYPE TABLE FOR FAILED yi_poh_head,
           tt_po_reported  TYPE TABLE FOR REPORTED yi_poh_head,
           tt_itm_failed   TYPE TABLE FOR FAILED yi_po_item,
           tt_itm_reported TYPE TABLE FOR REPORTED yi_po_item.

    CLASS-METHODS: get_instance RETURNING VALUE(ro_instance) TYPE REF TO ycl_po_save_bo.
    METHODS: create_po
      IMPORTING
        is_po_hdr         TYPE ytb_po_hdr
        it_po_itm         TYPE tt_po_itm OPTIONAL
        iv_numbering_mode TYPE /dmo/if_flight_legacy=>t_numbering_mode OPTIONAL
      EXPORTING
        es_po_hdr         TYPE ytb_po_hdr
        et_po_itm         TYPE tt_po_itm
        et_messages       TYPE /dmo/t_message.

    METHODS: save_po.
    METHODS: save_item.
    METHODS: clean_po.
    METHODS: clean_itm.
    METHODS map_po_messages
      IMPORTING
        cid          TYPE string         OPTIONAL
        po_num       TYPE ebeln OPTIONAL
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_po_failed
        reported     TYPE tt_po_reported.

    METHODS map_item_messages
      IMPORTING
        cid          TYPE string         OPTIONAL
        is_dependend TYPE abap_bool       DEFAULT  abap_false
        messages     TYPE /dmo/t_message
      EXPORTING
        failed_added TYPE abap_bool
      CHANGING
        failed       TYPE tt_itm_failed
        reported     TYPE tt_itm_reported.
  PROTECTED SECTION.
    DATA: mt_create_hdr_buffer TYPE tt_po_hdr,
          mt_update_hdr_buffer TYPE tt_po_hdr,
          mt_delete_hdr_buffer TYPE tt_po_hdr.

    DATA: mt_create_itm_buffer TYPE tt_po_itm,
          mt_update_itm_buffer TYPE tt_po_itm,
          mt_delete_itm_buffer TYPE tt_po_itm.

  PRIVATE SECTION.
    METHODS get_cause_from_message
      IMPORTING
        msgid             TYPE symsgid
        msgno             TYPE symsgno
        is_dependend      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(fail_cause) TYPE if_abap_behv=>t_fail_cause.


    CLASS-DATA: gr_instance TYPE REF TO ycl_po_save_bo.
ENDCLASS.



CLASS ycl_po_save_bo IMPLEMENTATION.
  METHOD get_instance.
    ro_instance = COND #( WHEN gr_instance IS NOT BOUND
                          THEN NEW #(  )
                          ELSE gr_instance ).
  ENDMETHOD.
  METHOD map_item_messages.
    ASSERT cid IS NOT INITIAL.  "In a create case, the %cid has to be present
    failed_added = abap_false.
    LOOP AT messages INTO DATA(lw_message).
      IF ( lw_message-msgty = 'E' OR lw_message-msgty = 'A' ) AND
         ( NOT line_exists( failed[ KEY cid COMPONENTS %cid = cid ] ) ).
        APPEND VALUE #( %cid        = cid
                        %fail-cause = get_cause_from_message(
                                        msgid = lw_message-msgid
                                        msgno = lw_message-msgno
                                        is_dependend = is_dependend
                                      ) )
               TO failed.
        failed_added = abap_true.
      ENDIF.

      APPEND VALUE #( %msg          = new_message(
                                        id       = lw_message-msgid
                                        number   = lw_message-msgno
                                        severity = if_abap_behv_message=>severity-error
                                        v1       = lw_message-msgv1
                                        v2       = lw_message-msgv2
                                        v3       = lw_message-msgv3
                                        v4       = lw_message-msgv4 )
                      %cid          = cid )
             TO reported.
    ENDLOOP.

  ENDMETHOD.

  METHOD map_po_messages.

    failed_added = abap_false.
    LOOP AT messages ASSIGNING FIELD-SYMBOL(<lfs_message>).
      IF ( <lfs_message>-msgty = 'A' OR <lfs_message>-msgty = 'E' ) AND
         ( NOT line_exists( failed[ KEY entity COMPONENTS %cid = cid  PoNum = Po_num ] ) ).

        APPEND VALUE #( %cid        = cid
                       PoNum    = po_num
                       %fail-cause = /dmo/cl_travel_auxiliary=>get_cause_from_message(
                                       msgid = <lfs_message>-msgid
                                       msgno = <lfs_message>-msgno
                                     ) )
              TO failed.
        failed_added = abap_true.
      ENDIF.

      APPEND VALUE #( %msg          = new_message(
                                        id       = <lfs_message>-msgid
                                        number   = <lfs_message>-msgno
                                        severity = if_abap_behv_message=>severity-error
                                        v1       = <lfs_message>-msgv1
                                        v2       = <lfs_message>-msgv2
                                        v3       = <lfs_message>-msgv3
                                        v4       = <lfs_message>-msgv4 )
                      %cid          = cid
                      PoNum      = po_num )
             TO reported.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_cause_from_message.
    fail_cause = if_abap_behv=>cause-unspecific.

    IF msgid = 'YRAP_PO'.
      CASE msgno.
        WHEN '009'  "Purchase number Key initial
          OR '016'  "PO does not exist
          OR '017'  "Item does not exist
          OR '021'. "Vendor does not exist
          IF is_dependend = abap_true.
            fail_cause = if_abap_behv=>cause-dependency.
          ELSE.
            fail_cause = if_abap_behv=>cause-not_found.
          ENDIF.
        WHEN '032'. "PO is locked
          fail_cause = if_abap_behv=>cause-locked.
        WHEN '046'. "You are not authorized
          fail_cause = if_abap_behv=>cause-unauthorized.
      ENDCASE.
    ENDIF.
  ENDMETHOD.

  METHOD create_po.
    DATA: lv_numbering_mode TYPE /dmo/if_flight_legacy=>t_numbering_mode.
    DATA: ls_po_hdr TYPE ytb_po_hdr,
          ls_po_itm TYPE ytb_po_itm,
          lt_po_itm TYPE tt_po_itm.

    IF iv_numbering_mode IS SUPPLIED.
      IF iv_numbering_mode IS INITIAL.
        lv_numbering_mode = /dmo/if_flight_legacy=>numbering_mode-early.
      ELSE.
        lv_numbering_mode = iv_numbering_mode.
      ENDIF.

      " Numbering mode has to be either Early or Late.
      ASSERT iv_numbering_mode EQ /dmo/if_flight_legacy=>numbering_mode-early OR
             iv_numbering_mode EQ /dmo/if_flight_legacy=>numbering_mode-late.
    ELSE.
      IF is_po_hdr-po_num IS INITIAL.
        TRY.
            cl_numberrange_runtime=>number_get(
              EXPORTING
                nr_range_nr       = 'PO'
                object            = 'YRAP_PO'
                quantity          = '1'
              IMPORTING
                number            = DATA(lv_po_number)
                returncode        = DATA(lv_return_code)
                returned_quantity = DATA(lv_returned_quantity)
            ).
          CATCH cx_number_ranges INTO DATA(lx_number_ranges).
            APPEND VALUE #(  msgty = 'E'
                             msgid = 'YRAP_PO'
                             msgno = '000'
                             msgv1 = lx_number_ranges->get_text(  )
                           ) TO et_messages.
            EXIT.
        ENDTRY.
      ENDIF.
    ENDIF.

    CLEAR es_po_hdr.
    CLEAR et_po_itm.
    CLEAR et_messages.

    ls_po_hdr = CORRESPONDING #( is_po_hdr ).

    " standard determinations
    IF ls_po_hdr-po_num IS INITIAL.
      ls_po_hdr-po_num = CONV #( lv_po_number ).
    ENDIF.
    ls_po_hdr-created_by = sy-uname.
    GET TIME STAMP FIELD ls_po_hdr-create_date_time.
    ls_po_hdr-changed_local_date_time = ls_po_hdr-create_date_time.
    ls_po_hdr-status = 'A'.

    IF ls_po_hdr IS NOT INITIAL.
      INSERT ls_po_hdr INTO TABLE mt_create_hdr_buffer.
    ENDIF.
    es_po_hdr = ls_po_hdr.

    IF it_po_itm IS SUPPLIED.

      SELECT po_num, po_item FROM ytb_po_itm
      FOR ALL ENTRIES IN @it_po_itm
      WHERE po_num = @it_po_itm-po_num AND
            po_item = @it_po_itm-po_item
      INTO TABLE @DATA(lt_items).
      IF sy-subrc IS INITIAL.
        SORT lt_items BY po_num po_item.
      ENDIF.

      LOOP AT it_po_itm INTO DATA(ls_itm).
        ls_po_itm = CORRESPONDING #( ls_itm ).
        " PO Item key must not be initial
        IF ls_po_itm-po_item IS INITIAL.
          APPEND VALUE #(  msgty = 'E'
                             msgid = 'YRAP_PO'
                             msgno = '002'
                          ) TO et_messages.
          RETURN.
        ENDIF.

        READ TABLE lt_items TRANSPORTING NO FIELDS
                            WITH KEY po_num = ls_po_itm-po_num
                                     po_item = ls_po_itm-po_item.
        IF sy-subrc IS INITIAL.
          APPEND VALUE #(  msgty = 'E'
                           msgid = 'YRAP_PO'
                           msgno = '001'
                           msgv1 = CONV #( ls_po_itm-po_item  )
                             ) TO et_messages.
          RETURN.
        ENDIF.

        READ TABLE mt_create_itm_buffer TRANSPORTING NO FIELDS
                            WITH KEY po_num = ls_po_itm-po_num
                                     po_item = ls_po_itm-po_item.
        IF sy-subrc IS INITIAL.
          APPEND VALUE #(  msgty = 'E'
                           msgid = 'YRAP_PO'
                           msgno = '001'
                           msgv1 = CONV #( ls_po_itm-po_item  )
                             ) TO et_messages.
          RETURN.
        ENDIF.

        ls_po_itm-changed_by = sy-uname.
        GET TIME STAMP FIELD ls_po_itm-changed_date_time.
        ls_po_itm-changed_local_date_time = ls_po_itm-changed_date_time.
        APPEND CORRESPONDING #( ls_po_itm ) TO et_po_itm.

        INSERT ls_po_itm INTO TABLE mt_create_itm_buffer.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
  METHOD save_po.
    " Make sure no preliminary travel_id is remaining (late numbering use-case)
    " If this dump happens, call adjust numbers before executing save
    IF mt_create_hdr_buffer IS NOT INITIAL.
      INSERT  ytb_po_hdr FROM TABLE @mt_create_hdr_buffer.
    ENDIF.
    IF mt_update_hdr_buffer IS NOT INITIAL.
      UPDATE ytb_po_hdr FROM TABLE @mt_update_hdr_buffer.
    ENDIF.
    IF mt_delete_hdr_buffer IS NOT INITIAL.
      DELETE ytb_po_hdr FROM TABLE @( CORRESPONDING #( mt_delete_hdr_buffer ) ).
    ENDIF.

  ENDMETHOD.

  METHOD save_item.
    " Make sure no preliminary travel_id is remaining (late numbering use-case)
    " If this dump happens, call adjust numbers before executing save
    IF mt_create_itm_buffer IS NOT INITIAL.
      INSERT  ytb_po_itm FROM TABLE @mt_create_itm_buffer.
    ENDIF.
    IF mt_update_itm_buffer IS NOT INITIAL.
      UPDATE ytb_po_itm FROM TABLE @mt_update_itm_buffer.
    ENDIF.
    IF mt_delete_itm_buffer IS NOT INITIAL.
      DELETE ytb_po_itm FROM TABLE @( CORRESPONDING #( mt_delete_itm_buffer ) ).
    ENDIF.

  ENDMETHOD.

  METHOD clean_po.
    CLEAR: mt_create_hdr_buffer, mt_update_hdr_buffer, mt_delete_hdr_buffer.

  ENDMETHOD.

  METHOD clean_itm.
    CLEAR: mt_create_itm_buffer, mt_update_itm_buffer, mt_delete_itm_buffer.
  ENDMETHOD.

ENDCLASS.
