Select interno_persona, NUMERO_IDENTIFICACION, NOMBRES || ' ' || PRIMER_APELLIDO || ' ' || SEGUNDO_APELLIDO Nombre,
Replace(SCONCEPTO, 'PROV_', '') Concepto, DECODE(SCONCEPTO, 'PROV_INTERESESCESANTIAS', DECODE(TO_CHAR(:P_Fecha, 'MM'), '01', 0, VALOR_SALDO), VALOR_SALDO) VALOR_SALDO, 
GreaTest (VALOR - DECODE(SCONCEPTO, 'PROV_INTERESESCESANTIAS', DECODE(TO_CHAR(:P_Fecha, 'MM'), '01', 0, VALOR_SALDO), VALOR_SALDO), 0) Alicuota
From rh_personas, rh_t_lm_valores
Where numero_identificacion=51753989 --- nfuncionario = interno_persona
and PERIODO = :P_Fecha
 AND SDEVENGADO = 5
Order By to_number(NUMERO_IDENTIFICACION);
