Select 'C' Tipo_Cta
      ,ICA-BIENES' Cuenta_Contable
      ,Round(Sum(v.Valor_Retencion) *
             (1 - (%%b_Alm_Ingreso.Valor_Anticipo%% /
              %%b_Alm_Ingreso.Cuantia%%))) Valor
  From (Select Sum(d.Valor_Unitario) * Ae.Retencion Valor_Retencion
          From Alm_Dtlle_Ingreso_d    d
              ,Co_Actividad_Economica Ae
              ,Co_Dtlle_Orden_d       Dod
              ,Co_Orden_Contrato      Coc
              ,Co_Orden_e_d           Ced
         Where
         (Ae.Ciiu = Nvl(Dod.Codigo_Ciiu, Coc.Ciiu)
         and Ae.Vigencia = Dod.Vigencia
         And d.Elemento_Mov = Dod.Id     

         And d.consecutivo = Dod.consecutivo)

         and (Dod.Interno_Oc = %%b_Alm_Ingreso.Id_Contrato%%
         and Coc.Interno_Oc = %%b_Alm_Ingreso.Id_Contrato%%
         and d.Id_Ingreso = %%b_Alm_Ingreso.Id_Ingreso%%)
         and Dod.Vigencia = Ced.Vigencia
         and Dod.Num_Sol_Adq = Ced.Num_Sol_Adq
         and Dod.Interno_Oc = Ced.Interno_Oc
  and  d.valor_unitario=ced.valor_unitario
         and Dod.id = Ced.Id
         and Dod.Consecutivo = Ced.Consecutivo
        /* and Ced.Num_Entrega = %%b_Alm_Ingreso.Numero_Entrega%%*/
         Group By Ae.Retencion, Dod.Codigo_Ciiu
         Union All
        Select Sum(d.Valor_Unitario * d.Cantidad) * Ae.Retencion
          From Alm_Dtlle_Ingreso_c    d
              ,Co_Actividad_Economica Ae
              ,Co_Dtlle_Orden_c       Dod
              ,Co_Orden_Contrato      Coc
              ,Co_Orden_e_c              Cec
         Where (Ae.Ciiu = Nvl(Dod.Codigo_Ciiu, Coc.Ciiu) And
               Ae.Vigencia = Dod.Vigencia And d.Elemento_Mov = Dod.Id)
               /*And (Dod.Interno_Oc = %%b_Alm_Ingreso.Id_Contrato%%
               And Coc.Interno_Oc = %%b_Alm_Ingreso.Id_Contrato%%*/
               And d.Id_Ingreso = %%b_Alm_Ingreso.Id_Ingreso%%)              
          And Dod.Vigencia = Cec.Vigencia
          And Dod.Num_Sol_Adq = Cec.Num_Sol_Adq
         And Dod.Interno_Oc = Cec.Interno_Oc
         And Dod.id = Cec.Id
         And Dod.Consecutivo = Cec.Consecutivo
         /And Cec.Num_Entrega = %%b_Alm_Ingreso.Numero_Entrega%%/
         Group By Ae.Retencion, Dod.Codigo_Ciiu
        Union All
        Select Sum(Ent.Cantidad * Det.Valor_Unitario) * Ae.Retencion
          From Co.Co_Orden_e_s        Ent
              ,Co_Dtlle_Orden_s       Det
              ,Co_Actividad_Economica Ae
              ,Co_Orden_Contrato      Coc
         Where (Det.Interno_Oc = Ent.Interno_Oc And Det.Id = Ent.Id And
               Det.Vigencia = Ent.Vigencia And
               Det.Num_Sol_Adq = Ent.Num_Sol_Adq And Det.Id = Ent.Id And
               Det.Consecutivo = Ent.Consecutivo And
               Det.Num_Modificacion = Ent.Num_Modificacion And
               Ae.Ciiu = Nvl(Det.Codigo_Ciiu, Coc.Ciiu) And
               Ae.Vigencia = Det.Vigencia)
          /* And (Coc.Interno_Oc = %%b_Alm_Ingreso.Id_Contrato%% And
               %%b_Alm_Ingreso.Id_Contrato%% = Det.Interno_Oc And
               %%b_Alm_Ingreso.Numero_Entrega%% = Num_Entrega)*/
         Group By Ae.Retencion, Det.Codigo_Ciiu
Union All Select 0 Valor from dual
) v