create or replace PACKAGE     Ogt_Pk_Predis AS
--AAGUIRRE
--VARIABLES GLOBALES
  mi_tipo_documento_op VARCHAR2(2) :='OP';
  mi_tipo_documento_ra VARCHAR2(2) :='RA';
  mi_tipo_documento_ar VARCHAR2(2) :='AR';
  mi_aprobado_uno      NUMBER(1) :=1;
  mi_aprobado_cero     NUMBER(1) :=0;
  mi_estado_uno        VARCHAR2(1) :='1';
  mi_estado_cero       VARCHAR2(1) :='0';
  mi_tipo_caja_menor   NUMBER(1) :=2;
  mi_valor_cero        NUMBER(1) :=0;
  mi_valor_uno         NUMBER(1) :=1;
  mi_tipo_vigencia_reserva VARCHAR2(1) :='R';
  mi_tipo_vigencia_actual  VARCHAR2(1) :='V';
  mi_tipo_vigencia_c       VARCHAR2(1) :='C';
  mi_entidad_reintegros    VARCHAR2(3) :='111';
  mi_unidad_ejecutora_reintegros VARCHAR2(2) := '01';
  mi_valor_op          NUMBER(20,2) := 0;
  mi_valor_ra          NUMBER(20,2) := 0;
  mi_valor_ar          NUMBER(20,2) := 0;
  --


   FUNCTION Ogt_Fn_Valor_Mes(una_vigencia NUMBER
                            ,una_entidad VARCHAR2
                            ,una_unidad_ejecutora VARCHAR2
                            ,un_mes NUMBER
                            ,un_rubro_interno NUMBER) RETURN NUMBER;
   FUNCTION OGT_FN_VALOR_ACUM(una_vigencia NUMBER
                             ,una_entidad VARCHAR2
                             ,una_unidad_ejecutora VARCHAR2
                             ,un_mes NUMBER
                             ,un_rubro_interno NUMBER) RETURN NUMBER;
   FUNCTION Ogt_Fn_Anul_Mes(una_vigencia NUMBER
                           ,una_entidad VARCHAR2
                           ,una_unidad_ejecutora VARCHAR2
                           ,un_mes NUMBER
                           ,un_rubro_interno NUMBER) RETURN NUMBER;
   FUNCTION OGT_FN_ANUL_ACUM(una_vigencia NUMBER
                            ,una_entidad VARCHAR2
                            ,una_unidad_ejecutora VARCHAR2
                            ,un_mes NUMBER
                            ,un_rubro_interno NUMBER) RETURN NUMBER;
   FUNCTION Ogt_Fn_Reint_Mes(una_vigencia NUMBER
                            ,una_entidad VARCHAR2
                            ,una_unidad_ejecutora VARCHAR2
                            ,un_mes NUMBER
                            ,un_rubro_interno NUMBER) RETURN NUMBER;
   FUNCTION OGT_FN_REINT_ACUM(una_vigencia NUMBER
                             ,una_entidad VARCHAR2
                             ,una_unidad_ejecutora VARCHAR2
                             ,un_mes NUMBER
                             ,un_rubro_interno NUMBER) RETURN NUMBER;
   -- FANNY 05-08-04
   -- FUNCION QUE RETORNA EL VALOR AJUSTADO EN UN MES
   FUNCTION OGT_FN_AJUSTE_MES(una_vigencia NUMBER
                             ,una_entidad VARCHAR2
                             ,una_unidad_ejecutora VARCHAR2
                             ,un_mes NUMBER
                             ,un_rubro_interno NUMBER) RETURN NUMBER;
   -- FANNY 05-08-04
   -- FUNCION QUE RETORNA EL VALOR AJUSTADO ACUMULADO DE UN A?O A UN MES
   FUNCTION OGT_FN_ACUM_AJUSTE(una_vigencia NUMBER
                             ,una_entidad VARCHAR2
                             ,una_unidad_ejecutora VARCHAR2
                             ,un_mes NUMBER
                             ,un_rubro_interno NUMBER) RETURN NUMBER;
--AAGUIRRE 26-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE LOS GIROS MENSUALES
--DE UN RUBRO DE UNA RESERVA
-- BASADA EN OGT_FN_VALOR_MES
   FUNCTION OGT_FN_GIROSMES_RESERVA(una_vigencia NUMBER
                           ,un_codigo_compania VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_mes VARCHAR2
                           ,un_interno NUMBER
         ) RETURN NUMBER;
   -- AAGUIRRE 23-11-2004 (Requerimiento 311)
   -- Funcion que devuelve el valor de los ajustes mensuales de rubro
   -- de una reserva
   FUNCTION OGT_FN_AJUSTESMES_RESERVA(una_vigencia NUMBER
                             ,un_codigo_compania VARCHAR2
                             ,un_codigo_unidad_ejecutora VARCHAR2
                             ,un_mes VARCHAR2
                             ,un_interno NUMBER
        ) RETURN NUMBER;
   -- AAGUIRRE 23-11-2004 O.K.
   -- FUNCION QUE RETORNA EL VALOR DE LOS REINTEGROS MENSUALES DE RUBRO DE
   -- UNA RESERVA
   -- BASADA EN OGT_FN_REINT_MES
   FUNCTION OGT_FN_REINTEGROSMES_RESERVA(una_vigencia NUMBER
                            ,un_codigo_compania   VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,un_mes VARCHAR2
                            ,un_interno VARCHAR2
       ) RETURN NUMBER;
   --AAGUIRRE 26-11-2004 O.K.
   --FUNCION QUE DEVUELVE EL VALOR DE LAS ANULACIONES MENSUALES DE RUBRO
   --DE UNA RESERVA
   -- BASADA EN OGT_FN_ANUL_MES
FUNCTION OGT_FN_ANULGIROSMES_RESERVA
                           (una_vigencia NUMBER
                           ,un_codigo_compania VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_mes VARCHAR2
                           ,un_interno NUMBER
         ) RETURN NUMBER;
--AAGUIRRE 26-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE LOS GIROS ACUMULADOS A UN MES
--DE UN RUBRO DE UNA RESERVA
-- BASADA EN OGT_FN_VALOR_MES
FUNCTION OGT_FN_GIROSACUM_RESERVA(una_vigencia NUMBER
                           ,un_codigo_compania VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_mes VARCHAR2
                           ,un_interno NUMBER
         ) RETURN NUMBER;
--AAGUIRRE 26-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE LOS AJUSTES ACUMULADOS  A UN MES
--MENSUALES DE RUBRO DE UNA RESERVA
--BASADA EN OGT_FN_ACUM_MES
FUNCTION OGT_FN_AJUSTESACUM_RESERVA(una_vigencia NUMBER
                           ,un_codigo_compania VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_mes VARCHAR2
                           ,un_interno NUMBER
         ) RETURN NUMBER;
--AAGUIRRE 26-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE LOS REINTEGROS ACUMULADOS
--DE RUBRO DE UNA RESERVA
--BASADA EN OGT_FN_REINT_MES
FUNCTION OGT_FN_REINTEGROSACUM_RESERVA(una_vigencia NUMBER
                           ,un_codigo_compania VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_mes VARCHAR2
                           ,un_interno NUMBER
         ) RETURN NUMBER;
--AAGUIRRE 26-11-2004
--FUNCION QUE DEVUELVE EL VALOR DE LAS ANULACIONES ACUMULADAS DE RUBRO DE
--UNA RESERVA
--BASADA EN OGT_FN_VALOR_ACUM
   FUNCTION OGT_FN_ANULGIROSACUM_RESERVA(una_vigencia NUMBER
                           ,un_codigo_compania VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_mes VARCHAR2
                           ,un_interno NUMBER
         ) RETURN NUMBER;
--AAGUIRRE 26-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR ORDENES DE PAGO Y RELACIONES DE AUTORIZACION
--ACUMULADO DE UNA RESERVA
--BASADA EN OGT_FN_VALOR_ACUM
   FUNCTION OGT_FN_GIROSACUM_RESERVA_FC(una_vigencia NUMBER
                           ,un_codigo_compania VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,numero_registro_presupuestal NUMBER
         ,un_interno NUMBER
         ,fecha_corte DATE) RETURN NUMBER;
--AAGUIRRE 29-11-2004 O.K.
   --FUNCION QUE DEVUELVE EL VALOR DE LAS ANULACIONES MENSUALES DE ORDENES DE PAGO
   --Y RELACIONES DE AUTORIZACION DE UNA RESERVA
   --BASADA EN OGT_FN_ANUL_MES
   FUNCTION OGT_FN_ANULACUMGIRO_RESERVA_FC(una_vigencia NUMBER
                           ,un_codigo_compania VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,numero_registro_presupuestal NUMBER
         ,un_interno NUMBER
         ,fecha_corte DATE) RETURN NUMBER;
--AAGUIRRE 29-11-2004 O.K
--FUNCION QUE DEVUELVE EL VALOR DE LOS GIROS ACUMULADOS A UN MES
--DE UN RUBRO
-- BASADA EN OGT_FN_VALOR_MES
FUNCTION OGT_FN_GIROSMES_VIGENCIA(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,un_mes NUMBER
                            ,un_interno NUMBER) RETURN NUMBER;
--AAGUIRRE 29-11-2004 OK
--FUNCION QUE DEVUELVE EL VALOR DE LOS AJUSTES ACUMULADOS MENSUALES DE RUBRO
--BASADA EN OGT_FN_ACUM_MES
   FUNCTION OGT_FN_AJUSTESMES_VIGENCIA(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,un_mes NUMBER
                            ,un_interno NUMBER) RETURN NUMBER;
--AAGUIRRE 29-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE LOS REINTEGROS MENSUALES DE RUBRO
--BASADA EN OGT_FN_REINT_MES
   FUNCTION OGT_FN_REINTEGROSMES_VIGENCIA(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,un_mes NUMBER
                            ,un_interno NUMBER
       ) RETURN NUMBER;
--AAGUIRRE 29-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE LAS ANULACIONES MENSUALES DE RUBRO
--BASADA EN OGT_FN_ANUL_MES
   FUNCTION OGT_FN_ANULGIROSMES_VIGENCIA
                          (una_vigencia NUMBER
                           ,un_codigo_compania VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_mes NUMBER
                           ,un_interno NUMBER
         ) RETURN NUMBER;
--AAGUIRRE 29-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE LOS GIROS ACUMULADOS A UN MES
--BASADA OGT_FN_GIROSMES_VIGENCIA
FUNCTION OGT_FN_GIROSACUM_VIGENCIA(una_vigencia NUMBER
                                  ,un_codigo_compania VARCHAR2
                                  ,un_codigo_unidad_ejecutora VARCHAR2
                                  ,un_mes NUMBER
                                  ,un_interno NUMBER) RETURN NUMBER;
--AAGUIRRE 30-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE LOS AJUSTES ACUMULADOS MENSUALES
--DE RUBRO
--BASADO EN OGT_FN_ACUM_AJUSTE
   FUNCTION OGT_FN_AJUSTESACUM_VIGENCIA(una_vigencia NUMBER
                             ,un_codigo_compania VARCHAR2
                             ,un_codigo_unidad_ejecutora VARCHAR2
                             ,un_mes NUMBER
                             ,un_interno VARCHAR2
        ) RETURN NUMBER;
--AAGUIRRE 30-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE LOS REINTEGROS ACUMULADOS
--DE RUBRO
--BASADO EN OGT_FN_REINT_MES
  FUNCTION OGT_FN_REINTEGROSACUM_VIGENCIA(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,un_mes NUMBER
                            ,un_interno VARCHAR2
       ) RETURN NUMBER;
--AAGUIRRE 30-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE LAS ANULACIONES ACUMULADAS
--DE RUBRO
--BASADO EN OGT_FN_ANUL_ACUM
--OGT_FN_ANULGIRO_VIGENCIA
   FUNCTION OGT_FN_ANULGIROSACUM_VIGENCIA(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,un_mes NUMBER
                            ,un_interno NUMBER
       ) RETURN NUMBER;
--AAGUIRRE 30-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR ORDENES DE PAGO Y RELACIONES DE AUTORIZACION ACUMULADO
--DE UN REGISTRO PRESUPUESTAL
--BASADO EN OGT_FN_ANUL_ACUM
--   FUNCTION OGT_FN_GIROSACUM_REGISTRO(una_vigencia NUMBER
--                            ,un_codigo_compania VARCHAR2
--                            ,un_codigo_unidad_ejecutora VARCHAR2
--                            ,numero_registro_presupuestal NUMBER
--          ,un_interno NUMBER
--       ,fecha_corte DATE
--       ) RETURN NUMBER;
---
--
---
--AAGUIRRE
--FUNCION QUE DEVUELVE UN CURSOR CON LAS ORDENES DE PAGO Y
--RELACIONES DE AUTORIZACION DE RESERVAS
  TYPE CUR_GIROS_RESERVAS          IS REF CURSOR;
  FUNCTION OGT_FN_GIROS_RESERVAS
                     (UNA_VIGENCIA             NUMBER
               ,UN_CODIGO_COMPANIA      VARCHAR2
                 ,UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2
      ) RETURN CUR_GIROS_RESERVAS;
--
--AAGUIRRE
--FUNCION QUE DEVUELVE UN CURSOR CON LOS ANULACIONES DE ORDENES DE PAGO Y
--RELACIONES DE AUTORIZACION DE RESERVAS
--
TYPE CUR_ANULGIROS_RESERVAS          IS REF CURSOR;
  FUNCTION OGT_FN_ANULGIROS_RESERVAS
                     (UNA_VIGENCIA             NUMBER
               ,UN_CODIGO_COMPANIA      VARCHAR2
                 ,UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2
      ) RETURN CUR_ANULGIROS_RESERVAS;
--AAGUIRRE
--FUNCION QUE DEVUELVE UN CURSOR CON LAS ORDENES DE PAGO Y
--RELACIONES DE AUTORIZACION DE VIGENCIA
  TYPE CUR_GIROS_VIGENCIA          IS REF CURSOR;
  FUNCTION OGT_FN_GIROS_VIGENCIA
                     (UNA_VIGENCIA             NUMBER
               ,UN_CODIGO_COMPANIA      VARCHAR2
                 ,UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2)
      RETURN CUR_GIROS_VIGENCIA;
--AAGUIRRE
--FUNCION QUE DEVUELVE UN CURSOR CON LAS ANULACIONES DE ORDENES DE PAGO Y
--RELACIONES DE AUTORIZACION DE VIGENCIA
 TYPE CUR_ANULGIRO_VIGENCIA          IS REF CURSOR;
  FUNCTION OGT_FN_ANULGIRO_VIGENCIA
                     (UNA_VIGENCIA             NUMBER
               ,UN_CODIGO_COMPANIA      VARCHAR2
                 ,UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2)
      RETURN CUR_ANULGIRO_VIGENCIA;
--AAGUIRRE
--FUNCION QUE DEVUELVE UN CURSOR CON LOS AJUSTES A ORDENES DE PAGO
-- Y RELACIONES DE AUTORIZACION DE VIGENCIA
 TYPE CUR_AJUS_VIGENCIA          IS REF CURSOR;
  FUNCTION OGT_FN_AJUSTES_VIGENCIA
                     (UNA_VIGENCIA             NUMBER
               ,UN_CODIGO_COMPANIA      VARCHAR2
                 ,UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2)
      RETURN CUR_AJUS_VIGENCIA;
--AAGUIRRE
--FUNCION QUE DEVUELVE UN CURSOR CON LOS REINTEGROS DE ORDENES DE PAGO
-- Y RELACIONES DE AUTORIZACION DE VIGENCIA
 TYPE CUR_REINT_VIGENCIA          IS REF CURSOR;
  FUNCTION OGT_FN_REINTEGROS_VIGENCIA
                     (UNA_VIGENCIA             NUMBER
               ,UN_CODIGO_COMPANIA      VARCHAR2
                 ,UN_CODIGO_UNIDAD_EJECUTORA VARCHAR2)
      RETURN CUR_REINT_VIGENCIA ;
--AAGUIRRE 30-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR ORDENES DE PAGO Y RELACIONES DE AUTORIZACION ACUMULADO
--DE UN REGISTRO PRESUPUESTAL
--BASADO EN OGT_FN_VALOR_ACUM
   FUNCTION OGT_FN_GIROSACUM_REGISTRO(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,numero_registro_presupuestal NUMBER
                 ,un_interno NUMBER
       ,fecha_corte DATE
       ) RETURN NUMBER;
--AAGUIRRE 30-11-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE ANULACIONES ACUMULADAS DE ORDENES DE PAGO
--Y RELACIONES DE AUTORIZACION
--BASADO EN OGT_FN_ANUL_ACUM
   FUNCTION OGT_FN_ANULACUMGIRO_REGISTRO(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,numero_registro_presupuestal NUMBER
                 ,un_interno NUMBER
       ,fecha_corte DATE
       ) RETURN NUMBER;
--AAGUIRRE 06-12-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE AJUSTES ACUMULADOS DE ORDENES DE PAGO
--Y RELACIONES DE AUTORIZACION
--BASADO EN OGT_FN_ACUM_AJUSTE
   FUNCTION OGT_FN_AJUSTEACUM_REGISTRO(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,numero_registro_presupuestal NUMBER
                 ,un_interno NUMBER
       ,fecha_corte DATE
       ) RETURN NUMBER;
--AAGUIRRE 06-12-2004 O.K.
--FUNCION QUE DEVUELVE EL VALOR DE REINTEGROS
--ACUMULADOS A UNA FECHA DE CORTE
--BASADO EN OGT_FN_REINT_ACUM
   FUNCTION OGT_FN_REINTACUM_REGISTRO(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,numero_registro_presupuestal NUMBER
                 ,un_interno NUMBER
       ,fecha_corte DATE
       ) RETURN NUMBER;
--req 79-2005
--aaguirre 24-02-2005
--funcion que devuelve el valor de los ajustes en la vigencia
--a una fecha de corte
  FUNCTION OGT_FN_AJUSTEACUM(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,un_rubro_interno NUMBER
                            ,fecha_corte DATE
       ) RETURN NUMBER;
--req 79-2005
--aaguirre 24-02-2005
--funcion que devuelve el valor de los ajustes en la vigencia
--en un rango de fechas
  FUNCTION OGT_FN_AJUSTEACUMF(una_vigencia NUMBER
                            ,un_codigo_compania VARCHAR2
                            ,un_codigo_unidad_ejecutora VARCHAR2
                            ,un_rubro_interno NUMBER
                            ,fecha_inicial DATE
                            ,fecha_final   DATE
       ) RETURN NUMBER;
--req 79-2005
--aaguirre 24-02-2005
--funcion que devuelve el valor de los reintegros en la vigencia
--en una fecha de corte
  FUNCTION OGT_FN_REINTEGROSACUM(una_vigencia               NUMBER
                                 ,un_codigo_compania         VARCHAR2
                                 ,un_codigo_unidad_ejecutora VARCHAR2
                                 ,un_rubro_interno           NUMBER
                                 ,fecha_corte                 DATE

           ) RETURN NUMBER;
--req 79-2005
--aaguirre 24-02-2005
--funcion que devuelve el valor de los reintegros en la vigencia
--en un rango de fechas
  FUNCTION OGT_FN_REINTEGROSACUMF(una_vigencia               NUMBER
                                 ,un_codigo_compania         VARCHAR2
                                 ,un_codigo_unidad_ejecutora VARCHAR2
                                 ,un_rubro_interno           NUMBER
                                 ,fecha_inicial              DATE
                                 ,fecha_final                DATE
                                 ) RETURN NUMBER;
--REQ 79-2005
--AAGUIRRE 24-02-2005
--funcion que devuelve el valor de las ordenes de pago de una vigencia
--a una fecha de corte
FUNCTION OGT_FN_GIROSFC(una_vigencia               NUMBER
                        ,un_codigo_compania         VARCHAR2
                        ,un_codigo_unidad_ejecutora VARCHAR2
                        ,un_rubro_interno           NUMBER
                        ,fecha_corte                DATE
                        ) RETURN NUMBER;
--REQ 79-2005
--AAGUIRRE 24-02-2005
--funcion que devuelve el valor de las ordenes de pago de una vigencia
--en un rango de fechas
FUNCTION OGT_FN_GIROS(una_vigencia               NUMBER
                      ,un_codigo_compania         VARCHAR2
                      ,un_codigo_unidad_ejecutora VARCHAR2
                      ,un_rubro_interno           NUMBER
                      ,fecha_inicial              DATE
                      ,fecha_final                DATE
                      ) RETURN NUMBER;
--REQ 79-2005
--AAGUIRRE 24-02-2005
--funcion que devuelve el valor de las anulaciones de ordenes de pago de una vigencia
--en una fecha de corte
FUNCTION OGT_FN_ANULGIROFC(una_vigencia                NUMBER
                           ,un_codigo_compania         VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_rubro_interno           NUMBER
                           ,fecha_corte                DATE
                           ) RETURN NUMBER;
--REQ 79-2005
--AAGUIRRE 24-02-2005
--funcion que devuelve el valor de las anulaciones de ordenes de pago de una vigencia
--en un rango de fechas
FUNCTION OGT_FN_ANULGIRO(una_vigencia                NUMBER
                           ,un_codigo_compania       VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_rubro_interno         NUMBER
                           ,fecha_inicial            DATE
                           ,fecha_final              DATE ) RETURN NUMBER;
--REQ 324-2005
--AAGUIRRE 28-03-2005
--funcion que devuelve el valor de las ordenes de pago de una vigencia
--en un rango de fechas y que efectivamente se pagaron por tesoreria
FUNCTION OGT_FN_GIROS_PAGADOS(una_vigencia               NUMBER
                      ,un_codigo_compania         VARCHAR2
                      ,un_codigo_unidad_ejecutora VARCHAR2
                      ,un_rubro_interno           NUMBER
                      ,fecha_inicial              DATE
                      ,fecha_final                DATE
                      ) RETURN NUMBER;
--REQ 375-2005
--AAGUIRRE 01-04-2005
--funcion que retorna el valor total (incluyendo las anuladas) de las ordenes
--de pago de reservas a una fecha de corte.
FUNCTION OGT_FN_GIROSFC_RESERVA(una_vigencia               NUMBER
                        ,un_codigo_compania         VARCHAR2
                        ,un_codigo_unidad_ejecutora VARCHAR2
                        ,un_rubro_interno           NUMBER
                        ,fecha_corte                DATE
                        ) RETURN NUMBER;
--REQ 375-2005
--AAGUIRRE 01-04-2005
--funcion que retorna el valor de las ordenes de pago anuladas
--de reservas a una fecha de corte
FUNCTION OGT_FN_ANULGIROFC_RESERVA(una_vigencia                NUMBER
                           ,un_codigo_compania         VARCHAR2
                           ,un_codigo_unidad_ejecutora VARCHAR2
                           ,un_rubro_interno           NUMBER
                           ,fecha_corte                DATE
                           ) RETURN NUMBER;
--REQ 375-2005
--AAGUIRRE 01-04-2005
--FUNCION QUE DEVUELVE EL VALOR DE LOS AJUSTES DE RESERVAS
--A UNA FECHA DE CORTE
  FUNCTION OGT_FN_AJUSTEFC_RESERVA(una_vigencia               NUMBER,
                             un_codigo_compania         VARCHAR2,
                             un_codigo_unidad_ejecutora VARCHAR2,
                             un_rubro_interno           NUMBER,
                             fecha_corte                DATE) RETURN NUMBER;
--req 375-2005
--aaguirre 01-04-2005
--funcion que devuelve el valor de los reintegros de reservas
--en una fecha de corte
FUNCTION OGT_FN_REINTEGROFC_RESERVA(una_vigencia                NUMBER
                               ,un_codigo_compania         VARCHAR2
                               ,un_codigo_unidad_ejecutora VARCHAR2
                               ,un_rubro_interno           NUMBER
                               ,fecha_corte                DATE
                               ) RETURN NUMBER;
END;