/* David Tanarro de las Heras y Javier Ortiz Iniesta 2ºA

Ejercicio 1. Escribe un procedimiento PL/SQL denominado AvionesVuelo que reciba como parametro de entrada
un numero de vuelo y que que escriba en pantalla (PUT LINE) todos los modelos de avion que pueden realizar el
trayecto. Por cada modelo de avion, debe escribir el numero total de empleados certicados para ese modelo y su
salario medio.
*/
--SHOW ERRORS;
CREATE OR REPLACE PROCEDURE AvionesVuelo (n_vuelo VUELO.FLNO%TYPE) IS
	-- Declaraciones de variables y cursores
  excepcion_NoHayAvion EXCEPTION;
  n_empleados NUMBER := 0;
  salario_medio EMPLEADO.SALARIO%TYPE := 0;
  
	CURSOR cursorVuelos IS
	SELECT AVION.AID, AVION.NOMBRE
	FROM VUELO, AVION
	WHERE VUELO.FLNO = n_vuelo and AVION.AUTONOMIA >= VUELO.DISTANCIA;

	cVuelos cursorVuelos%ROWTYPE;
  
  -- opcional
  cursor cursorPilotos is
  select EMPLEADO.nombre, EMPLEADO.salario, AVION.aid
  from EMPLEADO, CERTIFICADO, AVION
  where EMPLEADO.EID = CERTIFICADO.EID 
        and CERTIFICADO.AID = AVION.AID;
  
  cPilotos cursorPilotos%ROWTYPE;
  
  
BEGIN
	-- Instrucciones PL/SQL
	DBMS_OUTPUT.PUT_LINE ('-------------------------------------------------------------');
	DBMS_OUTPUT.PUT_LINE ('Aviones para el vuelo ' || n_vuelo);
	DBMS_OUTPUT.PUT_LINE ('-------------------------------------------------------------');
	DBMS_OUTPUT.PUT_LINE ('   Modelo de avion              Num.emp.       Salario medio');
	DBMS_OUTPUT.PUT_LINE ('-------------------------------------------------------------');
	  
	open cursorVuelos;
	LOOP
		FETCH cursorVuelos INTO cVuelos;
		exit when cursorVuelos%NOTFOUND;
	end loop;
  
	if (cursorVuelos%ROWCOUNT = 0) then
        close cursorVuelos;
        RAISE excepcion_NoHayAvion;
	else
        close cursorVuelos;
    
        FOR cVuelos IN cursorVuelos LOOP      
                n_empleados := 0;
                salario_medio := 0;
  
                SELECT COUNT(*), AVG(EMPLEADO.SALARIO) into n_empleados, salario_medio
                FROM EMPLEADO,CERTIFICADO
                WHERE EMPLEADO.EID = CERTIFICADO.EID 
                      and CERTIFICADO.AID = cVuelos.AID;
                DBMS_OUTPUT.PUT_LINE (cVuelos.NOMBRE || '                         ' || n_empleados || '              ' || salario_medio);
                
                if n_empleados > 0 then
                    FOR cPilotos in cursorPilotos loop
                        IF cPilotos.aid = cVuelos.aid then
                              DBMS_OUTPUT.PUT_LINE ('                         ' || cPilotos.nombre || '              ' || cPilotos.salario);
                        end if;
                    end loop;
                end if;
                
      	end loop;
	end if;
	
EXCEPTION
	-- Tratamiento de excepciones
  WHEN excepcion_NoHayAvion THEN
		DBMS_OUTPUT.PUT_LINE('No se encontro ningun avion');
    
--	WHEN OTHERS THEN
	--	handle all other errors
--		DBMS_OUTPUT.PUT_LINE('Error no incluido como excepcion');
END;
/
SET SERVEROUTPUT ON SIZE 1000000;
BEGIN
  AvionesVuelo(99);
END;
/




/*
Ejercicio 2. Debes escribir dos triggers como se indican a continuacion:
El primer trigger debe dispararse cuando se modique el salario de un empleado. Si el salario se ha incrementado,
debe insertar una fila en una tabla de log denominada incidencias con las siguientes columnas y
contenidos:
 Fecha y hora de la incidencia: debe contener el instante en el que ha ocurrido la incidencia (SYSDATE).
 Usuario: el identicador del usuario con el que se ha producido la incidencia (USER).
 Descripcion: Texto de la incidencia. En este caso: 'Se ha incrementado el salario del empleado
X de Y a Z.', donde X es el nombre del empleado, Y es el sueldo antes del cambio y Z es el sueldo
despues del cambio.

Crea otro trigger sobre la tabla certificado que se dispare cuando se inserte o elimine una fila de la tabla.
Cuando se inserte una fla, debe incrementar el salario del empleado afectado un 3 %. Cuando se elimine una
fila, debe comprobar que el avion pueda realizar algun vuelo. Si es as, debe insertar en la tabla incidencias
una fila con el texto 'El avion X tiene un empleado certificado menos.'.
Comprueba el funcionamiento de los triggers realizando modificaciones en las tablas afectadas. En particular,
comprueba que cuando se inserta una fila en la tabla certificado se a~nade automaticamente una fila en la tabla
incidencias.
*/

--drop table INCIDENCIAS;
CREATE TABLE INCIDENCIAS (
    FECHA DATE,
    IDUSUARIO VARCHAR(10),
    DESCRIPCION VARCHAR(100),
    PRIMARY KEY (IDUSUARIO)
);

--SHOW ERRORS;
CREATE OR REPLACE TRIGGER AFTER_UPDATE_SALARY after INSERT or UPDATE or DELETE on EMPLEADO FOR EACH ROW
DECLARE
    aux INCIDENCIAS.DESCRIPCION%TYPE := '';
BEGIN
    IF INSERTING THEN
          aux := 'Se ha incrementado el salario del empleado ' || :NEW.NOMBRE || ' de 0 a ' || :NEW.SALARIO || '.';
          INSERT INTO INCIDENCIAS VALUES (SYSDATE, :NEW.EID, aux);
          DBMS_OUTPUT.PUT_LINE('Se ha insertado en incidencias');
    ELSIF UPDATING THEN
          aux := 'Se ha incrementado el salario del empleado ' || :OLD.NOMBRE || ' de ' || :OLD.SALARIO || ' a ' || :NEW.SALARIO || '.';
          UPDATE INCIDENCIAS SET FECHA = SYSDATE, DESCRIPCION = aux WHERE IDUSUARIO = :NEW.EID;
          DBMS_OUTPUT.PUT_LINE('Se ha modificado incidencias');
    ELSE
          --aux := 'Se ha incrementado el salario del empleado ' || :OLD.NOMBRE || ' de ' || :OLD.SALARIO || ' a 0.';
          DELETE FROM INCIDENCIAS WHERE IDUSUARIO = :OLD.EID;
          DBMS_OUTPUT.PUT_LINE('Se ha borrado en incidencias');
    END IF;
    
EXCEPTION
	WHEN OTHERS THEN
	--	handle all other errors
		DBMS_OUTPUT.PUT_LINE('Error no incluido como excepcion');
END;
/

--SHOW ERRORS;
CREATE OR REPLACE TRIGGER AFT_INS_DEL_CERT after INSERT or DELETE on CERTIFICADO FOR EACH ROW
DECLARE
    cuenta NUMBER := 0;
    nombreAvion AVION.NOMBRE%TYPE := '';
    aux INCIDENCIAS.DESCRIPCION%TYPE := '';
BEGIN
    IF INSERTING THEN
          UPDATE EMPLEADO SET SALARIO = SALARIO + SALARIO * 0.03 WHERE EID = :NEW.EID;
    ELSE
          SELECT COUNT(*), AVION.NOMBRE INTO cuenta, nombreAvion
          FROM VUELO, AVION
          WHERE AVION.AID = :OLD.AID AND AVION.AUTONOMIA > VUELO.DISTANCIA
          GROUP BY AVION.NOMBRE;
          
          DBMS_OUTPUT.PUT_LINE('El avion ' || nombreAvion || ' puede realizar ' || cuenta || ' vuelos' );
          
          IF cuenta > 0 THEN
                aux := 'El avion ' || nombreAvion || ' tiene un empleado certificado menos.';
                
                SELECT COUNT(*) INTO cuenta FROM INCIDENCIAS WHERE IDUSUARIO = :OLD.EID;
                -- cuenta pasa a valer si ha encontrado o no el usuario en la tabla incidencias
                if cuenta = 0 then
                    INSERT INTO INCIDENCIAS VALUES (SYSDATE, :OLD.EID, aux);
                else
                    UPDATE INCIDENCIAS SET FECHA = SYSDATE, DESCRIPCION = aux WHERE IDUSUARIO = :OLD.EID;
                END IF;
                
                DBMS_OUTPUT.PUT_LINE('Se ha modificado la tabla incidencias');
          END IF;
    END IF;
    
EXCEPTION
	WHEN OTHERS THEN
	--	handle all other errors
		DBMS_OUTPUT.PUT_LINE('Error no incluido como excepcion');
END;

/

SET SERVEROUTPUT ON SIZE 1000000;
DECLARE
    auxTable INCIDENCIAS%ROWTYPE;
BEGIN
    INSERT INTO EMPLEADO VALUES (1, 'DAVID', 1000000);
        SELECT * INTO auxTable FROM INCIDENCIAS WHERE IDUSUARIO = 1;
        dbms_output.put_line(auxTable.IDUSUARIO || '    ' || TO_CHAR(auxTable.FECHA) || '   ' || auxTable.DESCRIPCION );
    
    INSERT INTO CERTIFICADO VALUES (1, 15);
        SELECT * INTO auxTable FROM INCIDENCIAS WHERE IDUSUARIO = 1;
        dbms_output.put_line(auxTable.IDUSUARIO || '    ' || TO_CHAR(auxTable.FECHA) || '   ' || auxTable.DESCRIPCION );
    
    UPDATE empleado set SALARIO = 2000000 where EID = 1;
        SELECT * INTO auxTable FROM INCIDENCIAS WHERE IDUSUARIO = 1;
        dbms_output.put_line(auxTable.IDUSUARIO || '    ' || TO_CHAR(auxTable.FECHA) || '   ' || auxTable.DESCRIPCION );
    
    DELETE FROM CERTIFICADO WHERE EID = 1;
        SELECT * INTO auxTable FROM INCIDENCIAS WHERE IDUSUARIO = 1;
        dbms_output.put_line(auxTable.IDUSUARIO || '    ' || TO_CHAR(auxTable.FECHA) || '   ' || auxTable.DESCRIPCION );
    
    DELETE FROM EMPLEADO WHERE EID = 1;
    
END;
/

/*Ejercicio 3. Indica las operaciones que se deben realizar sobre la tabla incidencias en dos sesiones distintas para
que cada sesion tenga una fila que no aparece en la otra sesion.*/
/*
SESION A 															SESION B
-- A
																-- B
																DELETE FROM CERTIFICADO WHERE EID = 142519864 AND AID = 1;
-- En A no se ve que se ha modificado la tabla Incidencias
																-- En B se ve una nueva fila en la tabla incidencias (mostrando que un nuevo avion tiene un certificado menos)
*/