CLASS lhc_PO_HDR DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE po_hdr.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE po_hdr.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE po_hdr.

    METHODS read FOR READ
      IMPORTING keys FOR READ po_hdr RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK po_hdr.

    METHODS rba_Items FOR READ
      IMPORTING keys_rba FOR READ po_hdr\_Items FULL result_requested RESULT result LINK association_links.

    METHODS cba_Items FOR MODIFY
      IMPORTING entities_cba FOR CREATE po_hdr\_Items.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR po_hdr RESULT result.

    METHODS change_status FOR MODIFY
      IMPORTING keys FOR ACTION po_hdr~change_status RESULT result.

ENDCLASS.

CLASS lhc_PO_HDR IMPLEMENTATION.

  METHOD create.
    DATA: ls_po_hdr TYPE ytb_po_hdr.
    DATA: ls_po_hdr_out TYPE ytb_po_hdr.
    DATA: lt_messages   TYPE /dmo/t_message.

    LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_po_create>).
      ls_po_hdr = CORRESPONDING #( <lfs_po_create> MAPPING FROM ENTITY USING CONTROL ).

      ycl_po_save_bo=>get_instance( )->create_po(
          EXPORTING
            is_po_hdr         = CORRESPONDING ytb_po_hdr( ls_po_hdr )
          IMPORTING
            es_po_hdr         = ls_po_hdr_out
            et_messages       = lt_messages ).

      ycl_po_save_bo=>get_instance( )->map_po_messages(
           EXPORTING
             cid       = <lfs_po_create>-%cid
             messages  = lt_messages
           IMPORTING
             failed_added = DATA(failed_added)
           CHANGING
             failed    = failed-po_hdr
             reported  = reported-po_hdr
         ).

      IF failed_added = abap_false.
        INSERT VALUE #(
            %cid     = <lfs_po_create>-%cid
            PoNum = ls_po_hdr_out-po_num )
          INTO TABLE mapped-po_hdr.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    DATA: ls_po_hdr    TYPE ytb_po_hdr,
          ls_po_entity TYPE yi_poh_head.

    READ TABLE entities ASSIGNING FIELD-SYMBOL(<lfs_po_entity>) INDEX 1.
    IF sy-subrc IS INITIAL.
      SELECT SINGLE * FROM ytb_po_hdr
      WHERE po_num = @<lfs_po_entity>-PoNum
      INTO @ls_po_hdr.
      IF sy-subrc IS INITIAL.
        IF <lfs_po_entity>-DocCat IS NOT INITIAL.
          ls_po_hdr-doc_cat = <lfs_po_entity>-DocCat.
        ENDIF.

        IF <lfs_po_entity>-Type IS NOT INITIAL.
          ls_po_hdr-type = <lfs_po_entity>-type.
        ENDIF.

        IF <lfs_po_entity>-org IS NOT INITIAL.
          ls_po_hdr-org = <lfs_po_entity>-org.
        ENDIF.

        IF <lfs_po_entity>-vendor IS NOT INITIAL.
          ls_po_hdr-vendor = <lfs_po_entity>-vendor.
        ENDIF.

        IF <lfs_po_entity>-status IS NOT INITIAL.
          ls_po_hdr-status = <lfs_po_entity>-status.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD rba_Items.
  ENDMETHOD.

  METHOD cba_Items.
  ENDMETHOD.

  METHOD get_instance_features.
    READ ENTITIES OF yi_poh_head IN LOCAL MODE
    ENTITY po_hdr
    FIELDS ( PoNum )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_po_result)
    FAILED failed.
    IF lt_po_result IS NOT INITIAL.
      result = VALUE #(  FOR ls_po IN lt_po_result
      ( %key = ls_po-%key
        %features-%action-change_status = COND #( WHEN ls_po-status = 'B'
                                                  THEN if_abap_behv=>fc-o-disabled
                                                  ELSE if_abap_behv=>fc-o-enabled )
          )
      ).
    ENDIF.
  ENDMETHOD.

  METHOD change_status.
  ENDMETHOD.

ENDCLASS.

CLASS lhc_PO_ITM DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE po_itm.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE po_itm.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE po_itm.

    METHODS read FOR READ
      IMPORTING keys FOR READ po_itm RESULT result.

    METHODS rba_Head FOR READ
      IMPORTING keys_rba FOR READ po_itm\_Head FULL result_requested RESULT result LINK association_links.

ENDCLASS.

CLASS lhc_PO_ITM IMPLEMENTATION.

  METHOD create.

  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.
  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD rba_Head.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_YI_POH_HEAD DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_YI_POH_HEAD IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
    ycl_po_save_bo=>get_instance( )->save_po( ).
    ycl_po_save_bo=>get_instance( )->save_item( ).
  ENDMETHOD.

  METHOD cleanup.
    ycl_po_save_bo=>get_instance( )->clean_po( ).
    ycl_po_save_bo=>get_instance( )->clean_itm( ).
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
