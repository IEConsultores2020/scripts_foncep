PROCEDURE my_exec_sql IS

STR_QUERY VARCHAR2(5000);
connection_id EXEC_SQL.CONNTYPE;
cursorID EXEC_SQL.CURSTYPE;
bIsConnected BOOLEAN;
nRes PLS_INTEGER;
BEGIN
    STR_QUERY := 'select a.stercero, b.cc, SUM(valor) valor, SUM(valor_saldo) valor_saldo '||
        'from rh_t_lm_valores a, rh_lm_cuenta b, rh_lm_centros_costo c '||
        'where stipo_funcionario = a.stipofuncionario and '||
        'b.sconcepto = a.sconcepto and '||
        'b.cc = c.codigo and a.periodo =to_date(''30-04-2025 12:00:00 AM'',''DD-MM-YYYY HH:MI:SS AM'') and '||
        'a.ntipo_nomina = 0 AND a.sdevengado IN (0,1) AND '||
        'C.CODIGO NOT IN (2,3,4,5) AND A.NRO_RA = 8 AND B.SCOMPANIA = ''206'' AND '||
        'b.tipo_ra = ''1'' AND b.grupo_ra in (''5'') AND b.ncierre = 1  '||
        'AND b.dfecha_inicio_vig <= to_date(''30-04-2025 12:00:00 AM'',''DD-MM-YYYY HH:MI:SS AM'') and '||
        '(b.dfecha_final_vig >= to_date(''30-04-2025 12:00:00 AM'',''DD-MM-YYYY HH:MI:SS AM'')  '||
        ' OR b.dfecha_final_vig IS NULL)  AND b.cc = 7 '||
        ' group by a.stercero, b.cc '||
        ' order by b.cc, a.stercero ';
    EXEC_SQL.Default_Connection;
    BEGIN
        IF NOT BISCONNECTED THEN
            MESSAGE('NOT CONNECTED');
        END IF;
        cursorID := EXEC_SQL.OPEN_CURSOR(connection_id);
        EXEC_SQL.PARSE(connection_id, cursorID, STR_QUERY, exec_sql.V7); nRes := EXEC_SQL.EXECUTE(CONNECTION_ID,cursorID);
        EXEC_SQL.CLOSE_CURSOR(CURSORID);
    EXCEPTION
        when exec_sql.package_error then
            MESSAGE('Error in updating.'|| chr(10) || EXEC_SQL.LAST_ERROR_MESG(connection_id));
            EXEC_SQL.CLOSE_CURSOR(CURSORID);
            EXEC_SQL.CLOSE_CONNECTION(CONNECTION_ID);
            RAISE FORM_TRIGGER_FAILURE;
    END;
END;