connect ogt/:pwdogt@:bd

CREATE TABLE ogt.ogt_detalle_pensionado
        (
        id                  NUMBER(10)   not null,           --pk
        doc_numero          VARCHAR2(30 BYTE),   --fk  
        doc_tipo            VARCHAR2(10 BYTE),  --fk
        id_ingreso          NUMBER(10),         --fk
        tercero_origen      NUMBER(20,0),
        tercero_pensionado  NUMBER(20,0),
        cote_id             VARCHAR2(20 BYTE),
        valor               NUMBER
        )
        SEGMENT CREATION IMMEDIATE 
        PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
        NOCOMPRESS LOGGING
        STORAGE(INITIAL 22216704 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
        PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
        BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    TABLESPACE "OGTDAT" ;

    CREATE UNIQUE INDEX "OGT"."DP_PK" ON "OGT"."OGT_DETALLE_PENSIONADO" ("ID") 
    PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
    STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
    PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
    BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
    TABLESPACE "OGTIND" ;

    ALTER TABLE "OGT"."OGT_DETALLE_PENSIONADO" ADD CONSTRAINT "DP_PK" PRIMARY KEY ("ID")
    USING INDEX "OGT"."DP_PK"  ENABLE;

    ALTER TABLE "OGT"."OGT_DETALLE_PENSIONADO" ADD CONSTRAINT "DP_ING_FK" FOREIGN KEY ("ID_INGRESO")
	REFERENCES "OGT"."OGT_INGRESO" ("ID") ENABLE;

    COMMENT ON COLUMN "OGT"."OGT_DETALLE_PENSIONADO"."ID"                   IS 'Identificador único del detalle pensionado';
    COMMENT ON COLUMN "OGT"."OGT_DETALLE_PENSIONADO"."DOC_NUMERO"           IS 'Número del documento del ingreso';
    COMMENT ON COLUMN "OGT"."OGT_DETALLE_PENSIONADO"."DOC_TIPO"             IS 'Tipo del documento del ingreso';
    COMMENT ON COLUMN "OGT"."OGT_DETALLE_PENSIONADO"."ID_INGRESO"           IS 'Identificador del ingreso';
    COMMENT ON COLUMN "OGT"."OGT_DETALLE_PENSIONADO"."TERCERO_ORIGEN"       IS 'Administrador pensión';
    COMMENT ON COLUMN "OGT"."OGT_DETALLE_PENSIONADO"."TERCERO_PENSIONADO"   IS 'Pensionado beneficiario';
    COMMENT ON COLUMN "OGT"."OGT_DETALLE_PENSIONADO"."COTE_ID"              IS 'Identificador centro de costo';
    COMMENT ON COLUMN "OGT"."OGT_DETALLE_PENSIONADO"."VALOR"                IS 'Valor del ingreso asignado al pensionado';

    GRANT SELECT, INSERT, UPDATE, DELETE ON OGT.OGT_DETALLE_PENSIONADO TO OGT_ADMIN;

    CREATE OR REPLACE PUBLIC SYNONYM OGT_DETALLE_PENSIONADO FOR OGT.OGT_DETALLE_PENSIONADO;

    CREATE SEQUENCE OGT.OGT_DETALLE_PENSIONADO_SEQ
    START WITH 1      -- The first ID generated will be 1
    INCREMENT BY 1    -- Each subsequent ID will be 1 greater than the last
    NOCACHE;     

    CREATE OR REPLACE TRIGGER OGT.TRG_OGT_DETALLE_PENSION_BIU
    BEFORE INSERT ON OGT_DETALLE_PENSIONADO
    FOR EACH ROW
    BEGIN
        -- Check if the primary key column (:NEW.ID) is NULL.
        -- This allows the application to optionally provide its own ID,
        -- but if it doesn't, the sequence will provide one.
        IF :NEW.ID IS NULL THEN
            -- Assign the next sequential value to the ID column
            :NEW.ID := OGT_DETALLE_PENSIONADO_SEQ.NEXTVAL;
        END IF;
    END;
    /


/*/
    select *
    from ogt_detalle_pensionado;

    insert into ogt_detalle_pensionado (doc_numero) values ('999');

    select * from 
    --delete 
    ogt_detalle_pensionado;

    commit;
*/
