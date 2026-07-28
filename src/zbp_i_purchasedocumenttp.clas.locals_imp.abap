CLASS lhc_PurchaseDocument DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE PurchaseDocument.

    METHODS Approve_Order FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseDocument~Approve_Order RESULT result.

    METHODS Reject_Order FOR MODIFY
      IMPORTING keys FOR ACTION PurchaseDocument~Reject_Order RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
  IMPORTING REQUEST requested_authorizations FOR PurchaseDocument RESULT result.


ENDCLASS.

CLASS lhc_PurchaseDocument IMPLEMENTATION.

  METHOD get_global_authorizations.
    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.
  ENDMETHOD.



METHOD earlynumbering_create.



ENDMETHOD.





  METHOD Approve_Order.
    " NOTE: table name assumed as ZPURCHDOC to match the .bdef's
    " "persistent table zpurchdoc" clause. Please confirm in SE11 —
    " your original code referenced ZPURCHDOCUMENT, which does not
    " match the behavior definition and was the root cause of the
    " "component not found" errors.

    MODIFY ENTITIES OF Z_I_PurchaseDocumentTP IN LOCAL MODE
      ENTITY PurchaseDocument
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( PurchaseDocument = key-PurchaseDocument
                                         Status           = 2 ) )
      FAILED   DATA(lt_failed_approve)
      REPORTED DATA(lt_reported_approve).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key_approve>).
      APPEND VALUE #( purchasedocument = <fs_key_approve>-PurchaseDocument
                       %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '002' v1 = <fs_key_approve>-PurchaseDocument severity = if_abap_behv_message=>severity-success )
                       %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-PurchaseDocument.
    ENDLOOP.
  ENDMETHOD.

  METHOD Reject_Order.
    " NOTE: same table-name assumption as Approve_Order above — verify ZPURCHDOC.

    MODIFY ENTITIES OF Z_I_PurchaseDocumentTP IN LOCAL MODE
      ENTITY PurchaseDocument
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys ( PurchaseDocument = key-PurchaseDocument
                                         Status           = 3 ) )
      FAILED   DATA(lt_failed_reject)
      REPORTED DATA(lt_reported_reject).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<fs_key_reject>).
      APPEND VALUE #( purchasedocument = <fs_key_reject>-PurchaseDocument
                       %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '003' v1 = <fs_key_reject>-PurchaseDocument severity = if_abap_behv_message=>severity-success )
                       %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-PurchaseDocument.
    ENDLOOP.

* Sample for Failed Scenario
*    APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument ) TO failed-purchasedocument.
*    APPEND VALUE #(  purchasedocument = ls_purchdocument-purchasedocument
*                         %msg = new_message( id = 'ZPURCHDOC_EXCEPTIONS' number = '003' v1 = <fs_PurchaseDocument>-PurchaseDocument    severity = if_abap_behv_message=>severity-error )
*                        %element-purchasedocument = cl_abap_behv=>flag_changed ) TO reported-purchasedocument.
  ENDMETHOD.

ENDCLASS.
