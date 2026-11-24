--CUENTAS DE COBRO EN SISLA
select e.nro_referencia_pago,
       e.estado eest,
       e.valor_referencia evalor,
       e.centro_costo centro_costo,
       --cc.id ctac_id,
       cc.id_cuenta_cobro,
       cc.codigo_entidad centi,
       --cc.id_encabezado,
       cc.estado cest,
       --cc.valor_capital cvcapital,
       --cc.valor_intereses cvinteres,
      -- e.*,
       --l.id li_id,
      -- l.estado li_est,
       l.interno_persona id_persona, 
       l.valor_capital capital, l.valor_interes interes /*,
       l.*, p.**/
       --select e.*
  from sl_pcp_encabezado e,
       sl_pcp_cuenta_cobro cc,
       sl_pcp_liquidaciones l,
       sl_pcp_pago p
 where e.id = cc.id_encabezado
   and cc.id = l.id_det_cuenta_cobro
   and e.nro_referencia_pago = p.nro_referencia_pago
   and e.nro_referencia_pago in ('2026000230'); 


----------------------------------------------------------------------
---VERIFICACIONES EN OPGET

--Verifica si el acta ya fue creada
select * 
from  
ogt_documento
where tipo='ALE'
and unte_codigo='FINANCIERO'
--and numero in (58824)
and numero_externo in ('2026000524','2026000525','2026000526')
AND extract(year from fecha) IN (2026)
;


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
----Inicio verificaciones y borrado
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

--Verifica ingreso
select *
from  
-- delete
 ogt_ingreso
where --id=68375 and doc_numero='55608' 
extract(year from fecha_consignacion)=2026
and doc_numero||'-'||doc_tipo --in ('58824-XYZ')
in
  (select  doc_numero||'-'||doc_tipo
    from ogt_detalle_documento 
    where doc_numero||'-'||doc_tipo -- = '58824-XYZ' 
    in
        (
        select numero_legal||'-'||tipo 
            from ogt_documento
        where numero_legal in --('2026000525') 
          ( select numero --, numero_externo
            from  ogt_documento
            where tipo='ALE'
            --and estado='AP'
             and unte_codigo='FINANCIERO'
             and extract(year from fecha)=2026
             --and numero = '58824'
            AND numero_externo = '2026000525' --in  ('2026000525','2026000525','2026000526') 
          )
            and tipo='XYZ'  
            --and estado = 'AP'
        )
  )
order by id desc
;


--OGT.INCU_DEIN_FK
--INFO CUENTA DEPENDE
--DEIN_CUCO_CODIGO, DEIN_ING_ID, DEIN_ID
--CUCO_CODIGO, ING_ID, ID

select *
from 
-- delete
ogt_info_cuenta
where DEIN_CUCO_CODIGO||''||DEIN_ING_ID||''|| DEIN_ID in 
      (
        select CUCO_CODIGO||''||ING_ID||''||ID
        from  ogt_detalle_ing 
        where ing_id in 
          (
            select id
            from   ogt_ingreso
            where --id=68375 and
            /*doc_numero>='55502' and 
            doc_tipo='XYZ'*/
            doc_numero||'-'||doc_tipo in -- ('58818-XYZ')))
              (
                select doc_numero||'-'||doc_tipo
                from ogt_detalle_documento 
                where doc_numero||'-'||doc_tipo in
                    (select numero_legal||'-'||tipo
                        from ogt_documento
                    where numero_legal in -- '55502'
                      ( select numero
                        from ogt_documento
                        where tipo='ALE'
                        --and estado='AP'
                        and unte_codigo='FINANCIERO'
                        AND numero_externo in  ('2026000524','2026000525','2026000526')
                      )
                        and tipo='XYZ'  
                      -- and estado = 'RE'
                    )
              )
          )
      )
    ;

----OGT ----OGT ----OGT ----OGT ----OGT ----OGT ----OGT 
----Verifica detalles ingreso


select *
from  
-- delete
ogt_detalle_ing 
where ing_id in 
  (
    select id
    from   ogt_ingreso
    where --id=68375 and
    /*doc_numero>='55502' and 
    doc_tipo='XYZ'*/
    doc_numero||'-'||doc_tipo in --('58824-XYZ'))
      (select doc_numero||'-'||doc_tipo
        from ogt_detalle_documento 
        where doc_numero||'-'||doc_tipo in
            (select numero_legal||'-'||tipo
                from ogt_documento
            where numero_legal in -- '55502'
              ( select numero
                from --DELETE 
                ogt_documento
                where tipo='ALE'
                --and estado<>'AP'
                and unte_codigo='FINANCIERO'
                and numero_externo = '2026000525' -- in ('2026000524','2026000525','2026000526')
              )
                and tipo='XYZ'  
            )
      )
  )
;

--Verificar pensionado
select *
from 
-- delete 
ogt_detalle_pensionado dp
where dp.id_ingreso in 
  (select id
    from ogt_ingreso
    where doc_numero||'-'||doc_tipo in --= '55502-XYZ'
    (
      select doc_numero||'-'||doc_tipo
      from ogt_detalle_documento 
      where doc_numero||'-'||doc_tipo in
          (select numero_legal||'-'||tipo
              from ogt_documento
          where numero_legal in --'58818'
            ( select numero
              from --DELETE 
              ogt_documento
              where tipo='ALE'
             -- and estado='RE'
              and unte_codigo='FINANCIERO'
              AND numero_externo in ('2026000524','2026000525','2026000526')
            )
              and tipo='XYZ'  
             -- and estado = 'RE'
          )  
    )
  )
order by id desc
;


--Verifica detalle documento
select *
from 
-- delete
ogt_detalle_documento 
--set ter_id_recaudador=49
where doc_numero||'-'||doc_tipo in
  (select ogt_documento.numero||'-'||ogt_documento.tipo
    from ogt_documento
    where numero_externo in  ('2026000524','2026000525','2026000526')   ---56361 de 2025
    and extract(year from fecha) IN (2026)
  )
;


--Verifica si el ACTA fue creado
select * /*ogt_documento.numero, ogt_documento.numero_legal, 
          ogt_documento.numero, ogt_documento.tipo,
          ogt_documento.fecha, ogt_documento.fecha_emision_titulo, 
          ogt_documento.fecha_compra_titulo*/
from 
-- delete
ogt_documento
where /*bin_tipo_cuenta = 'FD'
and extract(year from fecha) IN (2026)
and*/ numero_legal in --('58824')
    ( select numero
      from --DELETE 
      ogt_documento
      where tipo='ALE'
     -- and estado='AP'
      and unte_codigo='FINANCIERO'
      AND numero_externo in ('2026000524','2026000525','2026000526')
    )
  and tipo='XYZ'
 -- and estado = 'AP'
--and fecha = SYSDATE
;

select * 
from  
-- delete
ogt_documento
where tipo='ALE'
--and estado='AP'
and unte_codigo='FINANCIERO'
--and numero in (58824)
and numero_externo in ('2026000524','2026000525','2026000526')
AND extract(year from fecha) IN (2026)
;

--Si borra detalle documento, debe cambiar el encabezado a PAG
select nro_referencia_pago, estado
from 
-- update
sl_pcp_encabezado
set estado = 'PAG'
where nro_referencia_pago in  ('2026000524','2026000525','2026000526');

-- commit

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
-----FIN VERIFICACION Y/O BORRADO
-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

declare
  mi_consecutivo number;
begin
  mi_consecutivo := pk_secuencial.fn_traer_consecutivo(
                  'OPGET','ACTA_LEGAL_ID','0000','000');
  dbms_output.put_line('DOC_NUM: '||mi_consecutivo);
    mi_consecutivo := pk_secuencial.fn_traer_consecutivo(
            'OPGET','DOC_NUM','2002','000');
  dbms_output.put_line('DOC_NUM: '||mi_consecutivo);
  commit;
end;

select *
from binconsecutivo
where grupo='OPGET'
and nombre='DOC_NUM'
and vigencia='2002'
and codigo_compania='000';


--sl_id_tercero_y_centro_costo( mi_rec_cuenta_cobro.codigo_entidad, mi_id_tercero_origen, mi_centro_costo,p_resp);
select id_limay, id_sisla
        from sl_relacion_tac
       where codigo_compa = 107766;

--Postquery 
--pk_sit_infbasica.sit_fn_existe_id('1209')
SELECT id
FROM shd_terceros
WHERE (id in (67896,5924))
;

--pk_sit_infbasica.sit_fn_nombre(:ogt_detalle_documento.ter_id_origen,SYSDATE);
SELECT id, shd_informacion_basica.ib_primer_nombre,
               shd_informacion_basica.ib_segundo_nombre,
               shd_informacion_basica.ib_primer_apellido,
               shd_informacion_basica.ib_segundo_apellido
        FROM shd_informacion_basica
        WHERE id IN (5924,400293) AND ib_fecha_inicial<=sysdate AND
              (ib_fecha_final>=sysdate OR ib_fecha_final IS NULL)
              ;

--mi_inf_basica_origen:=pk_sit_infbasica.sit_fn_infbasica(:ogt_detalle_documento.ter_id_origen,SYSDATE);
SELECT *
FROM shd_informacion_basica
WHERE id = 67869 AND ib_fecha_inicial <= sysdate AND
      (ib_fecha_final >= sysdate OR ib_fecha_final IS NULL);      


select * from ogt_documento
where numero_legal||tipo_legal in
(select numero||tipo
           from --DELETE 
            ogt_documento
          where tipo = 'ALE'
            --and estado = 'AP'
            and unte_codigo = 'FINANCIERO'
            and numero_externo = '2025000001' --p_nro_referencia_pago
)
;

select id,
             nro_referencia_pago,
             id_banco,
             cod_autorizacion,
             fecha_autorizacion,
             metodo_recaudo,
             canal,
             jornada,
             codigo_oficina
        from sl_pcp_pago
       where nro_referencia_pago = '2025000001'


-----spool off
--Novedad 10,12,13 en id novedad
select * from sl_novedad_x_cc_cp       
where id_cuenta_cobro in (
select cc.id_cuenta_cobro
  from sl_pcp_encabezado e,
       sl_pcp_cuenta_cobro cc
 where e.id = cc.id_encabezado
   and e.nro_referencia_pago in ('2025000001'));

   commit;


   DELETE OGT_DOCUMENTO where numero=60061

   commit