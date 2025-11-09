--CUENTAS DE COBRO EN SISLA
select e.nro_referencia_pago,
       e.estado eest,
       e.valor_referencia evalor,
       e.centro_costo centro_costo,
       cc.id ctac_id,
       cc.codigo_entidad centi,
       cc.id_encabezado,
       cc.estado cest,
       cc.valor_capital cvcapital,
       cc.valor_intereses cvinteres,
      -- e.*,
       l.id li_id,
       l.estado li_est,
       l.interno_persona li_ipers,
       p.*
  from sl_pcp_encabezado e,
       sl_pcp_cuenta_cobro cc,
       sl_pcp_liquidaciones l,
       sl_pcp_pago p
 where e.id = cc.id_encabezado
   and cc.id = l.id_det_cuenta_cobro
   and e.nro_referencia_pago = p.nro_referencia_pago
   and e.nro_referencia_pago in ('2025000001','2025000003');

   select *
   from sl_pcp_cuenta_cobro


----------------------------------------------------------------------
---VERIFICACIONES EN OPGET

--Verifica si el acta ya fue creada
select * 
from  ogt_documento
where tipo='ALE'
--and estado='AP'
and unte_codigo='FINANCIERO'
and numero in (55502,55503,54861)
and numero_externo in ('2025000001','2025000003','2025000012')
AND extract(year from fecha) IN (2025)

;

--Verifica si el documento fue creado
select * /*ogt_documento.numero, ogt_documento.numero_legal, 
          ogt_documento.numero, ogt_documento.tipo,
          ogt_documento.fecha, ogt_documento.fecha_emision_titulo, 
          ogt_documento.fecha_compra_titulo*/
from ogt_documento
where numero_legal in ('55502','55503','54914','56826')
--and  bin_tipo_cuenta = 'FD'
AND  extract(year from fecha) IN (2025)
AND extract(month from fecha) IN (10,11)
;*/

     ( select numero
      from --DELETE 
      ogt_documento
      where tipo='ALE'
      and estado='RE'
      and unte_codigo='FINANCIERO'
      AND numero_externo in ('2025000001','2025000003','2025000012'))
  and tipo='XYZ'
  and estado = 'RE'
--and fecha = SYSDATE
;

---Post query documento
  select pk_sit_infbasica.sit_fn_existe_id(:ogt_documento.ter_id_receptor
;


--Verifica detalle documento
select *
from ogt_detalle_documento --where valor = 822356068.70 
where doc_numero in ('55503','55502','54861')
where numero||'-'||tipo in
  (select   
          ogt_documento.numero||'-'||ogt_documento.tipo
    from ogt_documento
   
    where numero_legal in ('55502','55503','54914','56826')
    and extract(year from fecha) IN (2025)
  )
      ;
     ( select numero
      from --DELETE 
      ogt_documento
      where tipo='ALE'
      and estado='AP'
      and unte_codigo='FINANCIERO'
      AND numero_externo = '2025000001')
      and tipo='XYZ'  
    --  and estado = 'RE'
  )
;


--Verifica ingreso
select *
from   ogt_ingreso
where --id=68375 and
/*doc_numero>='55502' and 
doc_tipo='XYZ'*/
doc_numero||'-'||doc_tipo in --('5502-XYZ','5503-XYZ')
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
            and estado='AP'
            and unte_codigo='FINANCIERO'
            AND numero_externo = '2025000003')
            and tipo='XYZ'  
            and estado = 'RE'
        )
  )
order by id desc
;

----OGT ----OGT ----OGT ----OGT ----OGT ----OGT ----OGT 
----Verifica detalles ingreso

select *
from  ogt_detalle_ing 
where ing_id in 
  (select * --id
  from   ogt_ingreso
  where --id=68375 and
  /*doc_numero>='55502' and 
  doc_tipo='XYZ'*/
  doc_numero||'-'||doc_tipo in ('55502-XYZ','54914-XYZ'))
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
              and estado='AP'
              and unte_codigo='FINANCIERO'
              AND numero_externo = '2025000001')
              and tipo='XYZ'  
              and estado = 'RE'
          )
    ))
;

--
select *
from ogt_info_cuenta
where DEIN_CUCO_CODIGO||''||DEIN_ING_ID||''|| DEIN_ID in 
      (select CUCO_CODIGO||''||ING_ID||''||ID
      from  ogt_detalle_ing 
      where ing_id in 
        (select id
        from   ogt_ingreso
        where --id=68375 and
        /*doc_numero>='55502' and 
        doc_tipo='XYZ'*/
        doc_numero||'-'||doc_tipo in  ('55502-XYZ','54914-XYZ')))
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
                    and estado='AP'
                    and unte_codigo='FINANCIERO'
                    AND numero_externo = '2025000001')
                    and tipo='XYZ'  
                    and estado = 'RE'
                )
          ))
      )
    ;

--Verificar pensionado
select *
from ogt_detalle_pensionado dp
where dp.id_ingreso in 
  (select id
    from ogt_ingreso
    where doc_numero||'-'||doc_tipo in --= '55502-XYZ'
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
              and estado='RE'
              and unte_codigo='FINANCIERO'
              AND numero_externo = '2025000001')
              and tipo='XYZ'  
              and estado = 'RE'
          )
    ))
order by id desc
;

--Reporte
select *
from ogt_documento acta, ogt_documento d, ogt_detalle_documento dd, ogt_ingreso i, ogt_detalle_pensionado p
where acta.tipo='ALE' AND acta.estado='AP' AND acta.unte_codigo='FINANCIERO' and acta.numero_externo= :nro_referencia_pago /*'2025000001'*/ AND 
      d.tipo='XYZ' AND d.estado='RE' AND acta.numero = d.numero_legal and
      d.numero_legal||'-'||d.tipo = dd.doc_numero||'-'|| dd.doc_tipo and
      dd.doc_numero||'-'||dd.doc_tipo = i.doc_numero||'-'||i.doc_tipo and 
      i.id = p.id_ingreso
order by i.id desc
;



--No se usa para obtener el centro de costo. Se toma de sisla.
select * 
  from ogt_tercero_cc
 where id_tercero in --400293
      (select id_limay
        from sl_relacion_tac)
 ;

select id_limay, id_sisla centro_costo
  from sl_relacion_tac
 where codigo_compa = 107766;

select rt.codigo_compa, rt.id_limay, rt.id_sisla, tc.id_tercero, tc.cod_centro_costo
from sl_relacion_tac rt, ogt_tercero_cc tc
where rt.id_limay = tc.id_tercero
;

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