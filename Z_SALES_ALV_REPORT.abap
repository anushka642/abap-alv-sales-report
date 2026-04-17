REPORT z_sales_alv_report.

TABLES: vbak, vbap, kna1.

TYPES: BEGIN OF ty_data,
         vbeln TYPE vbak-vbeln,
         kunnr TYPE vbak-kunnr,
         name1 TYPE kna1-name1,
         erdat TYPE vbak-erdat,
         matnr TYPE vbap-matnr,
         netwr TYPE vbap-netwr,
       END OF ty_data.

DATA: lt_data TYPE TABLE OF ty_data,
      wa_data TYPE ty_data.

DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat TYPE slis_fieldcat_alv.

PARAMETERS: p_date TYPE vbak-erdat.
SELECT-OPTIONS: s_kunnr FOR vbak-kunnr.

START-OF-SELECTION.

  PERFORM fetch_data.
  PERFORM build_fieldcat.
  PERFORM display_alv.

FORM fetch_data.

  SELECT a~vbeln
         a~kunnr
         c~name1
         a~erdat
         b~matnr
         b~netwr
    INTO TABLE lt_data
    FROM vbak AS a
    INNER JOIN vbap AS b
      ON a~vbeln = b~vbeln
    INNER JOIN kna1 AS c
      ON a~kunnr = c~kunnr
    WHERE a~kunnr IN s_kunnr
      AND a~erdat = p_date.

ENDFORM.

FORM build_fieldcat.

  PERFORM add_field USING 'VBELN' 'Sales Order'.
  PERFORM add_field USING 'KUNNR' 'Customer'.
  PERFORM add_field USING 'NAME1' 'Customer Name'.
  PERFORM add_field USING 'ERDAT' 'Date'.
  PERFORM add_field USING 'MATNR' 'Material'.
  PERFORM add_field USING 'NETWR' 'Amount'.

ENDFORM.

FORM add_field USING p_field p_text.

  CLEAR wa_fieldcat.
  wa_fieldcat-fieldname = p_field.
  wa_fieldcat-seltext_m = p_text.

  IF p_field = 'VBELN'.
    wa_fieldcat-hotspot = 'X'.
  ENDIF.

  APPEND wa_fieldcat TO lt_fieldcat.

ENDFORM.

FORM display_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      it_fieldcat = lt_fieldcat
    TABLES
      t_outtab = lt_data.

ENDFORM.

FORM user_command USING r_ucomm LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.

  IF r_ucomm = '&IC1'.
    READ TABLE lt_data INTO wa_data INDEX rs_selfield-tabindex.
    IF sy-subrc = 0.
      MESSAGE |Sales Order { wa_data-vbeln } clicked| TYPE 'I'.
    ENDIF.
  ENDIF.

ENDFORM.