create or replace procedure pr_rh_demandante (
    un_funcionario  number,
    un_beneficiario varchar2,
    un_acto_adm     varchar2
) as


  type demandante_type is record(
    mi_cod_ddte      number(10),
    mi_tipo_doc_ddte varchar2(30),
    mi_nro_doc_ddte  varchar2(20),
    mi_nombre_ddte   varchar2(100)
  );

    mi_cod_ddte      number(10);
    mi_tipo_doc_ddte varchar2(30);
    mi_nro_doc_ddte  varchar2(20);
    mi_nombre_ddte   varchar2(100);

  mi_demandante   demandante_type;
  /*
  un_beneficiario varchar2(10) := '413839';
  un_funcionario  number := 658;
  un_acto_adm     varchar2(2) :='2';
  */

  cursor c_demandante is
    select b.codigo,
           b.tipo_documento,
           b.numero_documento,          
           b.nombres || ' ' || b.apellidos
      from rh_descuentos_f a, rh_embargos_beneficiario b
     where b.codigo = a.demandante
       and a.beneficiario = un_beneficiario
       and a.funcionario = un_funcionario
       and a.numero_descuento = un_acto_adm;

begin
  --mi_demandante := null;
  open c_demandante;
  dbms_output.put_line('Abriendo cursor campo a campo');
  fetch c_demandante
    into mi_cod_ddte, mi_tipo_doc_ddte, mi_nro_doc_ddte,  mi_nombre_ddte
    ; 
  close c_demandante;
  dbms_output.put_line('mi_cod_ddte: ' ||
                       mi_cod_ddte);
  dbms_output.put_line('mi_tipo_doc_ddte: ' ||
                       mi_tipo_doc_ddte);
  dbms_output.put_line('mi_nro_doc_ddte: ' ||
                       mi_nro_doc_ddte);
  dbms_output.put_line('mi_nombre_ddte: ' ||
                       mi_nombre_ddte);

  dbms_output.put_line('Cargando al cursor *******************');
  open c_demandante;
  fetch c_demandante into mi_demandante;
  close c_demandante;        
  dbms_output.put_line('mi_demandante.mi_cod_ddte: ' ||
                       mi_demandante.mi_cod_ddte);
  dbms_output.put_line('mi_demandante.mi_tipo_doc_ddte: ' ||
                       mi_demandante.mi_tipo_doc_ddte);
  dbms_output.put_line('mi_demandante.mi_nro_doc_ddte: ' ||
                       mi_demandante.mi_nro_doc_ddte);
  dbms_output.put_line('mi_demandante.mi_nombre_ddte: ' ||
                       mi_demandante.mi_nombre_ddte);
exception
  when others then
    dbms_output.put_line('sqlerrm : ' || sqlerrm);
	close c_demandante;
end;
