-- Ejercicio 2
CREATE TABLE MODELOS(
cod_modelo NUMBER(8) NOT NULL
, nombre VARCHAR(25) NOT NULL
, apellido1 VARCHAR(25) NOT NULL
, apellido2 VARCHAR(25) NOT NULL
, fecha_nacimiento DATE
, sexo VARCHAR(6) NOT NULL
, altura NUMBER(8) NOT NULL
, numero_desfiles NUMERIC DEFAULT 0 not null
, PRIMARY KEY(cod_modelo)
, CONSTRAINT cnt_sexo CHECK (sexo IN ('HOMBRE', 'MUJER'))
, CONSTRAINT cnt_altura CHECK (altura >= 100 AND altura <= 220)
);
--DROP TABLE MODELOS;

INSERT INTO MODELOS VALUES (0, 'DANI', 'RODRI', 'GUEZ', null, 'HOMBRE', 180, 1);
INSERT INTO MODELOS VALUES (1, 'DANIELA', 'RODRI', 'GUEZ', null, 'MUJER', 180, 1);
INSERT INTO MODELOS VALUES (2, 'DANIEL', 'RODRI', 'GUEZ', null, 'HOMBRE', 180, 1);
INSERT INTO MODELOS VALUES (3, 'ADRY', 'RODRI', 'GUEZ', null, 'HOMBRE', 180, 1);
--UPDATE MODELOS SET sexo = 'MUJER' WHERE COD_MODELO = 1;
--UPDATE MODELOS SET NUMERO_DESFILES = NUMERO_DESFILES+1 WHERE COD_MODELO = 0;



CREATE TABLE CERTAMENES(
cod_certamen NUMBER(8) NOT NULL
, nombre VARCHAR(25) NOT NULL
, temporada VARCHAR(100) NOT NULL
, ciudad VARCHAR(20) NOT NULL
, fecha_inicio DATE NOT NULL
, fecha_fin DATE NOT NULL
, PRIMARY KEY(cod_certamen)
, CONSTRAINT cnt_cod_certamen CHECK (cod_certamen >= 0)
);
-- DROP TABLE CERTAMENES;
INSERT INTO CERTAMENES VALUES (12, 'DUODECIMA', '2017', 'MADRID', to_date('20-04-09'), to_date('20-04-09'));




CREATE TABLE DISENIADORES(
cod_diseniador NUMBER(8) NOT NULL
, nombre VARCHAR(25) NOT NULL
, pais VARCHAR(20) NOT NULL
, anio_inicio NUMBER(8) NOT NULL
, PRIMARY KEY(cod_diseniador)
, CONSTRAINT cnt_cod_diseniador CHECK (cod_diseniador >= 0)
, CONSTRAINT cnt_anio_inicio CHECK (anio_inicio >= 1900 AND anio_inicio <= 2100)
);
-- DROP TABLE DISENIADORES;
INSERT INTO DISENIADORES VALUES (500, 'GIORGIO ARMANI', 'ITALIA', 1900);
INSERT INTO DISENIADORES VALUES (501, 'AGATHA RUIZ DE LA PRADA', 'ITALIA', 1900);



CREATE TABLE DESFILES(
cod_certamen NUMBER(8)
, cod_modelo NUMBER(8)
, cod_diseniador NUMBER(8)
, fecha DATE
, CONSTRAINT PK PRIMARY KEY(cod_certamen, cod_modelo, cod_diseniador, fecha)
, CONSTRAINT DESFILES_FK1 foreign key (cod_certamen) references CERTAMENES (cod_certamen) ON DELETE CASCADE
, CONSTRAINT DESFILES_FK2 foreign key (cod_modelo) references MODELOS (cod_modelo) ON DELETE CASCADE
, CONSTRAINT DESFILES_FK3 foreign key (cod_diseniador) references DISENIADORES (cod_diseniador) ON DELETE CASCADE
);
-- DROP TABLE DESFILES;

INSERT INTO DESFILES VALUES (12, 0, 500, to_date('20-04-09'));
INSERT INTO DESFILES VALUES (12, 0, 501, to_date('20-04-09'));
INSERT INTO DESFILES VALUES (12, 1, 500, to_date('20-05-09'));
INSERT INTO DESFILES VALUES (12, 2, 500, to_date('20-05-02'));
INSERT INTO DESFILES VALUES (12, 3, 500, to_date('20-05-02'));
INSERT INTO DESFILES VALUES (12, 3, 500, to_date('21-05-02'));
DELETE FROM DESFILES WHERE COD_MODELO = 3;



-- Ejercicio 3
/*
    a) INSERT INTO DISENIADORES VALUES (500, 'GIORGIO ARMANI', 'ITALIA', 1900);
    
    b) 
*/

        SELECT NOMBRE
        FROM DISENIADORES
        WHERE ANIO_INICIO < 2000;
        
/*
    c)
*/
        SELECT m.NOMBRE
        FROM MODELOS m, DESFILES d
        WHERE m.COD_MODELO = d.COD_MODELO
              and 5 = EXTRACT(MONTH FROM d.FECHA)
              and 2017 = EXTRACT(YEAR FROM d.FECHA);
              
/*
    d)
*/
        SELECT NOMBRE
        FROM MODELOS
        WHERE COD_MODELO NOT IN ( SELECT m.COD_MODELO
                                  FROM MODELOS m, DESFILES d
                                  WHERE m.COD_MODELO = d.COD_MODELO
                                        and 5 = EXTRACT(MONTH FROM d.FECHA)
                                        and 2017 = EXTRACT(YEAR FROM d.FECHA));

/*
    e)
*/
        SELECT DISTINCT m.NOMBRE
        FROM MODELOS m, DESFILES de, DISENIADORES di
        WHERE m.COD_MODELO = de.COD_MODELO
              and di.COD_DISENIADOR = de.COD_DISENIADOR
              and di.NOMBRE = 'AGATHA RUIZ DE LA PRADA'
        INTERSECT
        SELECT DISTINCT m.NOMBRE
        FROM MODELOS m, DESFILES de, DISENIADORES di
        WHERE m.COD_MODELO = de.COD_MODELO
              and di.COD_DISENIADOR = de.COD_DISENIADOR
              and di.NOMBRE = 'GIORGIO ARMANI';
              
/*
      f)
*/
        SELECT *
        FROM (  SELECT NOMBRE
                FROM MODELOS
                ORDER BY FECHA_NACIMIENTO DESC)
        WHERE rownum <= 1;



--  Ejercicio 4

CREATE OR REPLACE TRIGGER actualiza_desfiles
BEFORE INSERT OR UPDATE OR DELETE ON DESFILES
FOR EACH ROW
BEGIN
	IF INSERTING THEN
		
		UPDATE MODELOS SET numero_desfiles = numero_desfiles+1 WHERE cod_modelo = :NEW.cod_modelo;
		
	ELSIF DELETING THEN
		
		UPDATE MODELOS SET numero_desfiles = numero_desfiles-1 WHERE cod_modelo = :OLD.cod_modelo;
		
	END IF;
END;
show errors;