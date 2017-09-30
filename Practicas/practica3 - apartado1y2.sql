-- Dar permisos al usuario para crear TRIGGER
-- GRANT CREATE TRIGGER, ALTER ANY TRIGGER, DROP ANY TRIGGER TO GIIC14;

/*
Apartado 1.
Crea la tabla REGISTRO_VENTAS(COD_REST, TOTAL_PEDIDOS, FECHA_ULT_PEDIDO).
Esta tabla contabilizará el importe total de los pedidos de cada restaurante, así como la fecha del último pedido realizado.
*/

CREATE TABLE REGISTRO_VENTAS (
  COD_REST NUMBER(8) PRIMARY KEY REFERENCES Restaurantes,
  TOTAL_PEDIDOS NUMBER,
  FECHA_ULT_PEDIDO DATE
);

-- Trigger del Apartado 2
-- DROP TRIGGER CONT_PEDIDOS_AFTER_DELETE;
CREATE OR REPLACE TRIGGER CONT_PEDIDOS_AFTER_DELETE after delete ON CONTIENE FOR EACH ROW
  DECLARE
      excepcion_NoExist                     EXCEPTION;            -- Apartado 2
      v_cod                                 PEDIDOS.CODIGO%TYPE;  -- Apartado 2
  BEGIN
      -- CASO PARA EL AFTER DELETE
      select CODIGO into v_cod from PEDIDOS where CODIGO = :OLD.PEDIDO;
      if v_cod is not null then
        UPDATE PEDIDOS SET IMPORTETOTAL = IMPORTETOTAL - :OLD.PRECIOCONCOMISION WHERE CODIGO = :OLD.PEDIDO;
      else
        RAISE excepcion_NoExist;
      end if;
  EXCEPTION
      --captura de excepciones
      WHEN excepcion_NoExist THEN
        DBMS_OUTPUT.PUT_LINE('No se ha encontrado el CODIGO en la tabla PEDIDOS');
END;
/
SHOW ERRORS;

-- DROP TRIGGER CONT_REG_VENTAS_BEFORE_DELETE;
CREATE OR REPLACE TRIGGER CONT_REG_VENTAS_BEFORE_DELETE before delete ON CONTIENE FOR EACH ROW
 DECLARE
  --declaraciones
    excep_NoExisteRegistroVentas          EXCEPTION;
    
    CURSOR cursorRegistroVentas(v_Restaurante RESTAURANTES.CODIGO%TYPE) IS
    SELECT *
    FROM REGISTRO_VENTAS v
    WHERE v.COD_REST = v_Restaurante;
    
    CURSOR cursorPedidosContiene(codPedido CONTIENE.PEDIDO%TYPE, codRestaurante CONTIENE.RESTAURANTE%TYPE) is
    select count(*), max(fecha_hora_pedido)
    from pedidos p, contiene c
    where p.codigo <> codPedido and c.restaurante=codRestaurante;
    
    cRegistroVentas   cursorRegistroVentas%ROWTYPE;
    nContiene     NUMBER;
    fechaPedidos  PEDIDOS.FECHA_HORA_PEDIDO%TYPE;
  
  BEGIN
  -- CASO PARA EL BEFORE DELETE
    DBMS_OUTPUT.PUT_LINE('TRIGGER DE UN BEFORE-DELETE DE LA TABLA CONTIENE:');
      open cursorRegistroVentas(:OLD.RESTAURANTE);
      FETCH cursorRegistroVentas INTO cRegistroVentas;
      if cursorRegistroVentas%FOUND then
          DBMS_OUTPUT.PUT_LINE('  Actualizamos en REGISTRO_VENTAS la fila con: COD_REST: ' || :OLD.RESTAURANTE);
          -- Actualiza el total de pedidos de un restaurante
          UPDATE REGISTRO_VENTAS SET TOTAL_PEDIDOS = TOTAL_PEDIDOS - :OLD.PRECIOCONCOMISION
          WHERE COD_REST = :OLD.RESTAURANTE;
      else
          RAISE excep_NoExisteRegistroVentas;
      end if;
      close cursorRegistroVentas;
      
  EXCEPTION
  --captura de excepciones
  WHEN excep_NoExisteRegistroVentas THEN
		DBMS_OUTPUT.PUT_LINE('No se ha encontrado el restaurante en la tabla Registro_Ventas');
END;
/
SHOW ERRORS;

-- DROP TRIGGER CONT_REG_VENTAS_AFTER_INSERT;
CREATE OR REPLACE TRIGGER CONT_REG_VENTAS_AFTER_INSERT after insert ON CONTIENE FOR EACH ROW
  DECLARE
  --declaraciones
    excep_NoExisteRegistroVentas          EXCEPTION;
    v_fecha_ult_pedido                    PEDIDOS.FECHA_HORA_PEDIDO%TYPE;
    
    excepcion_NoExist                     EXCEPTION;            -- Apartado 2
    v_cod                                 PEDIDOS.CODIGO%TYPE;  -- Apartado 2
    
    CURSOR cursorRegistroVentas(v_Restaurante RESTAURANTES.CODIGO%TYPE) IS
    SELECT *
    FROM REGISTRO_VENTAS v
    WHERE v.COD_REST = v_Restaurante;
    
	cRegistroVentas   cursorRegistroVentas%ROWTYPE;
  
  BEGIN
  -- CASO PARA EL AFTER INSERT
    SELECT FECHA_HORA_PEDIDO INTO v_fecha_ult_pedido
    FROM PEDIDOS
    WHERE CODIGO = :NEW.PEDIDO;
          
    DBMS_OUTPUT.PUT_LINE('TRIGGER DE UN AFTER-INSERT DE LA TABLA CONTIENE:');
      open cursorRegistroVentas(:NEW.RESTAURANTE);
      FETCH cursorRegistroVentas INTO cRegistroVentas;
      if cursorRegistroVentas%FOUND then
          DBMS_OUTPUT.PUT_LINE('  Actualizamos en REGISTRO_VENTAS la fila con: COD_REST: ' || :NEW.RESTAURANTE);
          -- Actualiza el total de pedidos de un restaurante
          UPDATE REGISTRO_VENTAS SET TOTAL_PEDIDOS = TOTAL_PEDIDOS + :NEW.PRECIOCONCOMISION
          WHERE COD_REST = :NEW.RESTAURANTE;
          -- La fecha del ultimo pedido se modificara si es mas reciente
          if v_fecha_ult_pedido is not null then
              UPDATE REGISTRO_VENTAS SET FECHA_ULT_PEDIDO = v_fecha_ult_pedido
              WHERE (COD_REST = :NEW.RESTAURANTE and FECHA_ULT_PEDIDO is null) or (COD_REST = :NEW.RESTAURANTE and FECHA_ULT_PEDIDO < v_fecha_ult_pedido);
          end if;
      else
          DBMS_OUTPUT.PUT_LINE('  Insertamos en REGISTRO_VENTAS una nueva fila con: COD_REST: ' || :NEW.RESTAURANTE);
          INSERT INTO REGISTRO_VENTAS (COD_REST, TOTAL_PEDIDOS, FECHA_ULT_PEDIDO) VALUES (:NEW.RESTAURANTE, :NEW.PRECIOCONCOMISION, v_fecha_ult_pedido);
      end if;
      close cursorRegistroVentas;
	  
	  -- Apartado 2
      select CODIGO into v_cod from PEDIDOS where CODIGO = :NEW.PEDIDO;
      if v_cod is not null then
        UPDATE PEDIDOS SET IMPORTETOTAL = IMPORTETOTAL + :NEW.PRECIOCONCOMISION WHERE CODIGO = :NEW.PEDIDO;
      else
        RAISE excepcion_NoExist;
      end if;
EXCEPTION
  --captura de excepciones
  WHEN excepcion_NoExist THEN
		DBMS_OUTPUT.PUT_LINE('No se ha encontrado el CODIGO en la tabla PEDIDOS');

END;
/
SHOW ERRORS;

--******************************************************************************

-- DROP TRIGGER CONT_CONTIENE_TO_PLATOS;
CREATE OR REPLACE TRIGGER CONT_CONTIENE_TO_PLATOS after update ON PLATOS FOR EACH ROW
  BEGIN
    -- CASO PARA EL UPDATE
    DBMS_OUTPUT.PUT_LINE('TRIGGER DE UN UPDATE DE LA TABLA PLATOS:');
    if :NEW.PRECIO <> :OLD.PRECIO then
      UPDATE CONTIENE SET PRECIOCONCOMISION = PRECIOCONCOMISION + :NEW.PRECIO WHERE RESTAURANTE = :NEW.RESTAURANTE and PLATO = :NEW.NOMBRE;
      UPDATE CONTIENE SET PRECIOCONCOMISION = PRECIOCONCOMISION - :OLD.PRECIO WHERE RESTAURANTE = :OLD.RESTAURANTE and PLATO = :OLD.NOMBRE;
    end if;
END;
/
SHOW ERRORS;

-- DROP TRIGGER CONT_CONTIENE_TO_RESTAU;
CREATE OR REPLACE TRIGGER CONT_CONTIENE_TO_RESTAU after update ON RESTAURANTES FOR EACH ROW
  BEGIN
    -- CASO PARA EL UPDATE
    DBMS_OUTPUT.PUT_LINE('TRIGGER DE UN UPDATE DE LA TABLA RESTAURANTES:');
    if :NEW.COMISION <> :OLD.COMISION then
      UPDATE CONTIENE SET PRECIOCONCOMISION = PRECIOCONCOMISION + :NEW.COMISION WHERE RESTAURANTE = :NEW.CODIGO;
      UPDATE CONTIENE SET PRECIOCONCOMISION = PRECIOCONCOMISION - :OLD.COMISION WHERE RESTAURANTE = :OLD.CODIGO;
    end if;
END;
/
SHOW ERRORS;

-- DROP TRIGGER CONT_REG_VENTAS_TO_CONT;
CREATE OR REPLACE TRIGGER CONT_REG_VENTAS_TO_CONT after update ON CONTIENE FOR EACH ROW
DECLARE
    v_NuevoPrecio    PLATOS.PRECIO%TYPE;
    v_ViejoPrecio    PLATOS.PRECIO%TYPE;
    v_NuevaComision  RESTAURANTES.COMISION%TYPE;
    v_ViejaComision  RESTAURANTES.COMISION%TYPE;
    v_NuevaFecha     PEDIDOS.FECHA_HORA_PEDIDO%TYPE;
    
    excepcion_NoExist                     EXCEPTION;            -- Apartado 2
    v_cod                                 PEDIDOS.CODIGO%TYPE;  -- Apartado 2
    
    CURSOR cursorPlatos(v_plato CONTIENE.PLATO%TYPE) IS
    SELECT PRECIO
    FROM PLATOS
    WHERE NOMBRE = v_plato;
    
    CURSOR cursorRestaurantes(v_Restaurante CONTIENE.RESTAURANTE%TYPE) IS
    SELECT COMISION
    FROM RESTAURANTES
    WHERE CODIGO = v_Restaurante;
    
    CURSOR cursorPedidos(v_Pedido CONTIENE.PEDIDO%TYPE) IS
    SELECT FECHA_HORA_PEDIDO
    FROM PEDIDOS
    WHERE CODIGO = v_Pedido;
    
  BEGIN
    -- CASO PARA EL UPDATE
      DBMS_OUTPUT.PUT_LINE('TRIGGER DE UN UPDATE DE LA TABLA CONTIENE:');
   
    IF :NEW.PRECIOCONCOMISION <> :OLD.PRECIOCONCOMISION then
      UPDATE REGISTRO_VENTAS SET TOTAL_PEDIDOS = TOTAL_PEDIDOS + :NEW.PRECIOCONCOMISION WHERE COD_REST = :NEW.RESTAURANTE;
      UPDATE REGISTRO_VENTAS SET TOTAL_PEDIDOS = TOTAL_PEDIDOS - :OLD.PRECIOCONCOMISION WHERE COD_REST = :OLD.RESTAURANTE;
      
      -- Apartado 2
      select CODIGO into v_cod from PEDIDOS where CODIGO = :OLD.PEDIDO;
      if v_cod is not null then
          UPDATE PEDIDOS SET IMPORTETOTAL = IMPORTETOTAL + :NEW.PRECIOCONCOMISION WHERE CODIGO = :NEW.PEDIDO;
          UPDATE PEDIDOS SET IMPORTETOTAL = IMPORTETOTAL - :OLD.PRECIOCONCOMISION WHERE CODIGO = :OLD.PEDIDO;
      else
          RAISE excepcion_NoExist;
      end if;
    
    ELSE
      if :NEW.PLATO <> :OLD.PLATO then
        open cursorPlatos (:NEW.PLATO);
        FETCH cursorPlatos INTO v_NuevoPrecio;
        close cursorPlatos;
        open cursorPlatos (:OLD.PLATO);
        FETCH cursorPlatos INTO v_ViejoPrecio;
        close cursorPlatos;
        if v_NuevoPrecio is not null and v_ViejoPrecio is not null then
          UPDATE REGISTRO_VENTAS SET TOTAL_PEDIDOS = TOTAL_PEDIDOS + v_NuevoPrecio WHERE COD_REST = :NEW.RESTAURANTE;
          UPDATE REGISTRO_VENTAS SET TOTAL_PEDIDOS = TOTAL_PEDIDOS - v_ViejoPrecio WHERE COD_REST = :OLD.RESTAURANTE;
        end if;
      end if;
      
      if :NEW.RESTAURANTE <> :OLD.RESTAURANTE then
        open cursorRestaurantes (:NEW.RESTAURANTE);
        FETCH cursorRestaurantes INTO v_NuevaComision;
        close cursorRestaurantes;
        open cursorRestaurantes (:OLD.RESTAURANTE);
        FETCH cursorRestaurantes INTO v_ViejaComision;
        close cursorRestaurantes;
        if v_NuevaComision is not null and v_ViejaComision is not null then
          UPDATE REGISTRO_VENTAS SET TOTAL_PEDIDOS = TOTAL_PEDIDOS + v_NuevaComision WHERE COD_REST = :NEW.RESTAURANTE;
          UPDATE REGISTRO_VENTAS SET TOTAL_PEDIDOS = TOTAL_PEDIDOS - v_ViejaComision WHERE COD_REST = :OLD.RESTAURANTE;
        end if;
      end if;
      
      if :NEW.PEDIDO <> :OLD.PEDIDO then
        open cursorPedidos (:NEW.PEDIDO);
        FETCH cursorPedidos INTO v_NuevaFecha;
        close cursorPedidos;
        if v_NuevaFecha is not null then
          UPDATE REGISTRO_VENTAS SET FECHA_ULT_PEDIDO = v_NuevaFecha WHERE COD_REST = :NEW.RESTAURANTE AND FECHA_ULT_PEDIDO < v_NuevaFecha;
        end if;
      end if;
    END IF;
EXCEPTION
  --captura de excepciones
  WHEN excepcion_NoExist THEN
    DBMS_OUTPUT.PUT_LINE('No se ha encontrado el CODIGO en la tabla PEDIDOS');

END;
/
SHOW ERRORS;

--******************************************************************************

-- Bloque 1
SET SERVEROUTPUT ON SIZE 1000000;
BEGIN
  DBMS_OUTPUT.PUT_LINE('  -> Insertamos en PEDIDOS una fila con: CODIGO: 100, ESTADO: REST, FECHA_HORA_PEDIDO: 31/12/15, FECHA_HORA_ENTREGA: null, IMPORTETOTAL: null, CLIENTE: 45678901Y, CODIGODESCUENTO: null');
  INSERT INTO PEDIDOS (CODIGO, ESTADO, FECHA_HORA_PEDIDO, FECHA_HORA_ENTREGA, IMPORTETOTAL, CLIENTE, CODIGODESCUENTO) VALUES(100, 'REST', to_date('31/12/15'), null, null, '45678901Y', null);
  -- Se actualiza la tabla Registro Ventas
  DBMS_OUTPUT.PUT_LINE('  -> Insertamos en CONTIENE una fila con: RESTAURANTE: 1234, PLATO: pizza arrabiata, PEDIDO: 100, PRECIOCONCOMISION: 50, UNIDADES: 1');
  INSERT INTO CONTIENE (RESTAURANTE, PLATO, PEDIDO, PRECIOCONCOMISION, UNIDADES) VALUES(1234,	'pizza arrabiata', 100, 50, 1);
  -- Se vuelve a actualizar la tabla Registro Ventas
  DBMS_OUTPUT.PUT_LINE('  -> Modificamos en PEDIDOS una fila donde CODIGO: 100, cambiando el fecha_hora_pedido = 07/01/16');
  UPDATE      PEDIDOS SET fecha_hora_pedido = to_date('07/01/16') WHERE CODIGO = 100;
  -- Se borra de Contiene la fila con el codigo 100 para poder cambiar el codigo de pedido en la tabla pedidos
  DBMS_OUTPUT.PUT_LINE('  -> Borramos en CONTIENE una fila donde RESTAURANTE: 1234, PLATO: pizza arrabiata, PEDIDO: 100');
  DELETE FROM CONTIENE WHERE PEDIDO = 100;
  
  DBMS_OUTPUT.PUT_LINE('');
  
  DBMS_OUTPUT.PUT_LINE('  -> Modificamos en Pedidos una fila que cumple que ESTADO: REST y CLIENTE: 45678901Y cambiando el CODIGO = 101');
  UPDATE      PEDIDOS SET CODIGO = 101 WHERE ESTADO = 'REST' and CLIENTE = '45678901Y';
  -- Se actualiza la tabla Registro Ventas
  DBMS_OUTPUT.PUT_LINE('  -> Insertamos en CONTIENE una fila con: RESTAURANTE: 1234, PLATO: pizza arrabiata, PEDIDO: 101, PRECIOCONCOMISION: 50, UNIDADES: 1');
  INSERT INTO CONTIENE (RESTAURANTE, PLATO, PEDIDO, PRECIOCONCOMISION, UNIDADES) VALUES(1234,	'pizza arrabiata', 101, 50, 1);
  -- Se vuelve a actualizar la tabla Registro Ventas
  DBMS_OUTPUT.PUT_LINE('  -> Modificamos en PEDIDOS una fila donde CODIGO: 101, cambiando el fecha_hora_pedido = 07/01/16');
  UPDATE      PEDIDOS SET fecha_hora_pedido = to_date('31/01/16') WHERE CODIGO = 101;
  -- Se borra de Contiene las filas con los pedidos 101, se actualiza la tabla registro ventas y se borra de Pedidos la fila con el pedido 101
  DBMS_OUTPUT.PUT_LINE('  -> Borramos en PEDIDOS una fila donde CODIGO = 101, CLIENTE = 45678901Y');
  
  DELETE FROM CONTIENE WHERE PEDIDO = 101;
  DELETE FROM PEDIDOS WHERE CODIGO = 101 and CLIENTE = '45678901Y';
END;

-- Bloque 1.1
SET SERVEROUTPUT ON SIZE 1000000;
DECLARE
  temp_v_precio_con_comision    CONTIENE.PRECIOCONCOMISION%TYPE := 0;
  temp_v_total_pedidos          CONTIENE.PRECIOCONCOMISION%TYPE := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('  -> Insertamos en REGISTRO_VENTAS una fila con: COD_REST: 2345, TOTAL_PEDIDOS: 17, FECHA: null');
  insert into REGISTRO_VENTAS VALUES (2345,17,null);
  
  SELECT PRECIOCONCOMISION INTO temp_v_precio_con_comision FROM CONTIENE WHERE RESTAURANTE = 2345 AND PLATO ='pollo tikka';
  SELECT TOTAL_PEDIDOS INTO temp_v_total_pedidos FROM REGISTRO_VENTAS WHERE COD_REST = 2345;
  DBMS_OUTPUT.PUT_LINE('  En la tabla CONTIENE el precio_con_comision vale: ' || temp_v_precio_con_comision);
  DBMS_OUTPUT.PUT_LINE('  En la tabla PEDIDOS el total_pedidos vale: ' || temp_v_total_pedidos);
  
  DBMS_OUTPUT.PUT_LINE(' ');
  
  DBMS_OUTPUT.PUT_LINE('  -> Modificamos en PLATOS una fila donde nombre: pollo tikka, cambiando el precio = 20');
  update Platos set precio = 20 where nombre = 'pollo tikka';
  
  SELECT PRECIOCONCOMISION INTO temp_v_precio_con_comision FROM CONTIENE WHERE RESTAURANTE = 2345 AND PLATO ='pollo tikka';
  SELECT TOTAL_PEDIDOS INTO temp_v_total_pedidos FROM REGISTRO_VENTAS WHERE COD_REST = 2345;
  DBMS_OUTPUT.PUT_LINE('  En la tabla CONTIENE el precio_con_comision vale: ' || temp_v_precio_con_comision);
  DBMS_OUTPUT.PUT_LINE('  En la tabla PEDIDOS el total_pedidos vale: ' || temp_v_total_pedidos);
  
  -- RETORNA A LOS VALORES INICIALES
  update Platos set precio = 10 where nombre = 'pollo tikka';
  DELETE FROM REGISTRO_VENTAS;
END;

-- Bloque 2
SET SERVEROUTPUT ON SIZE 1000000;
DECLARE
  temp_v_importe  PEDIDOS.IMPORTETOTAL%TYPE := 0;
BEGIN
  SELECT IMPORTETOTAL INTO temp_v_importe FROM PEDIDOS WHERE CODIGO = 1;
  DBMS_OUTPUT.PUT_LINE('  Valor inicial del importe total en Pedidos sobre el pedido 1: ' || temp_v_importe);
  
  DBMS_OUTPUT.PUT_LINE('');
  INSERT INTO CONTIENE (RESTAURANTE, PLATO, PEDIDO, PRECIOCONCOMISION, UNIDADES) VALUES(1234, 'pizza margarita', 1, 101, 1);
  DBMS_OUTPUT.PUT_LINE('  Insertado de nueva(s) fila(s) en la tabla Contiene:');
  DBMS_OUTPUT.PUT_LINE('  Codigo de restaurante: 1234, Plato: pizza margarita, Pedido: 1, Precio con comision: 101 y Unidades: 1');
  SELECT IMPORTETOTAL INTO temp_v_importe FROM PEDIDOS WHERE CODIGO = 1;
  DBMS_OUTPUT.PUT_LINE('  Actualizado el importe total en Pedidos sobre el pedido 1: ' || temp_v_importe);
  
  DBMS_OUTPUT.PUT_LINE('');
  UPDATE CONTIENE SET PRECIOCONCOMISION = 201 WHERE RESTAURANTE = 1234 and PLATO = 'pizza margarita' and UNIDADES = 1;
  DBMS_OUTPUT.PUT_LINE('  Actualizacion de fila(s) en la tabla Contiene:');
  DBMS_OUTPUT.PUT_LINE('  Codigo de restaurante: 1234, Plato: pizza margarita, Pedido: 1, Precio con comision: 201 y Unidades: 1');
  SELECT IMPORTETOTAL INTO temp_v_importe FROM PEDIDOS WHERE CODIGO = 1;
  DBMS_OUTPUT.PUT_LINE('  Actualizado el importe total en Pedidos sobre el pedido 1: ' || temp_v_importe);
  
  DBMS_OUTPUT.PUT_LINE('');
  DELETE FROM CONTIENE WHERE RESTAURANTE = 1234 and PRECIOCONCOMISION = 201;
  DBMS_OUTPUT.PUT_LINE('  Borrado de fila(s) en la tabla Contiene:');
  SELECT IMPORTETOTAL INTO temp_v_importe FROM PEDIDOS WHERE CODIGO = 1;
  DBMS_OUTPUT.PUT_LINE('  Actualizado el importe total en Pedidos sobre el pedido 1: ' || temp_v_importe);
  
END;
