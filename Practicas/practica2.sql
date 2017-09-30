-- Dar permisos al usuario para crear
-- GRANT CREATE PROCEDURE, ALTER ANY PROCEDURE, DROP ANY PROCEDURE, EXECUTE ANY PROCEDURE TO GIIC14;

/* Apartado 1
Procedimiento almacenado llamado PEDIDOS_CLIENTE que reciba como parámetro el DNI de un cliente y
muestre por pantalla sus datos personales, junto con un listado con los datos de los pedidos que ha realizado
(código de pedido, fecha, fecha de entrega, estado e importe del pedido), ordenados crecientemente por fecha.
En caso de error (DNI no existe, no hay pedidos para ese cliente, etc..), deberá mostrarse por pantalla un mensaje
de advertencia explicando el error.
Al finalizar el listado se deberá mostrar la suma de los importes de todos los pedidos del cliente.
Incluye un bloque de código anónimo para probar el procedimiento.
*/
CREATE OR REPLACE PROCEDURE PEDIDOS_CLIENTE (v_dni CLIENTES.DNI%TYPE) IS
  
	-- Declaraciones de variables y cursores
	excepcion_NoHayPedidos EXCEPTION;

	fila CLIENTES%ROWTYPE;
	ImporteTotal pedidos.importetotal%TYPE := 0;

	CURSOR cursorPedidos IS
	SELECT *
	FROM PEDIDOS p
	WHERE v_dni = p.cliente
	ORDER BY p.fecha_hora_pedido;

	cPedi cursorPedidos%ROWTYPE;
BEGIN
	-- Instrucciones PL/SQL
	SELECT * 
	into fila 
	FROM CLIENTES
	where DNI = v_dni;

	DBMS_OUTPUT.PUT_LINE (
	'   DNI    |       Nombre         |       Apellido     |        Calle        | Numero | Piso |  Localidad   | Codigo Postal |  Teléfono  |   Usuario   |   Contraseña'
	);
	DBMS_OUTPUT.PUT_LINE (
	fila.dni || ' | ' || fila.nombre || ' | ' || fila.apellido || ' | ' || fila.calle || ' | ' || fila.numero || ' | ' || fila.piso || ' | ' || fila.localidad || ' | ' || fila.codigopostal || '     |     ' || fila.telefono || ' | ' || fila.usuario || ' | ' || fila.contraseña
	);
	  
	open cursorPedidos;
	LOOP
		FETCH cursorPedidos INTO cPedi;
		exit when cursorPedidos%NOTFOUND;
	end loop;
  
	if (cursorPedidos%ROWCOUNT = 0) then
		close cursorPedidos;
		RAISE excepcion_NoHayPedidos;
	else
		close cursorPedidos;
    
		DBMS_OUTPUT.PUT_LINE (
		' CODIGO |  ESTADO   |  fecha_hora_pedido  | fecha_hora_entrega  | importetotal  | cliente | codigodescuento'
		);
		FOR cPedidos IN cursorPedidos LOOP
			ImporteTotal := cPedidos.importetotal + ImporteTotal;
			DBMS_OUTPUT.PUT_LINE (
			'      ' || cPedidos.codigo || ' | ' || cPedidos.estado || ' | ' || to_char(cPedidos.fecha_hora_pedido, 'DD/MM/YYYY HH24:MI:SS') || ' | ' || to_char(cPedidos.fecha_hora_entrega, 'DD/MM/YYYY HH24:MI:SS') || ' |       ' || cPedidos.importetotal || '      | ' || cPedidos.cliente || ' | ' || cPedidos.codigodescuento
			);
		end loop;
		
		DBMS_OUTPUT.PUT_LINE ('Importe total de los pedidos: ' || ImporteTotal);
	end if;
	
EXCEPTION
	-- Tratamiento de excepciones
	-- DNI no existe
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('No se encontro en la tabla Clientes el DNI ' || v_dni);

	-- No hay pedidos para ese cliente
	WHEN excepcion_NoHayPedidos THEN
		DBMS_OUTPUT.PUT_LINE('No se encontro ningun pedido para ese cliente');
    
	WHEN OTHERS THEN
	--	handle all other errors
		DBMS_OUTPUT.PUT_LINE('Error no incluido como excepcion');
END;
/
-- CALL PEDIDOS_CLIENTE('12345678M');
-- SHOW ERRORS;

-- Bloque
SET SERVEROUTPUT ON SIZE 1000000;
BEGIN
   DBMS_OUTPUT.PUT_LINE('Apartado 1.');
   DBMS_OUTPUT.PUT_LINE('Prueba 1: Cliente con pedidos');
   PEDIDOS_CLIENTE('12345678M');
   
   DBMS_OUTPUT.PUT_LINE('');
   DBMS_OUTPUT.PUT_LINE('Prueba 2: Cliente sin pedidos');
   PEDIDOS_CLIENTE('0');
   
   DBMS_OUTPUT.PUT_LINE('');
   DBMS_OUTPUT.PUT_LINE('Prueba 3: Cliente que no existe');
   PEDIDOS_CLIENTE('1');
   
   EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM); -- Saca el texto del error
END;
/

/* Apartado 2:
Procedimiento almacenado llamado REVISA_PRECIO_CON_COMISION (sin argumentos) cuya misión es
comprobar la consistencia de los datos de todos los precios con comisión en la tabla Contiene. El campo “precio
con comisión” de la tabla “Contiene” debe almacenar el precio del plato incluyendo el porcentaje de la comisión
de su restaurante.
El procedimiento debe verificar y actualizar estos datos de modo que resulten consistentes. Si todos los datos son
correctos, se mostrará un mensaje indicando “Ningún cambio en los datos de Contiene”. En caso contrario se
indicará el número de filas modificadas en Contiene.
*/
CREATE OR REPLACE PROCEDURE REVISA_PRECIO_CON_COMISION IS
	-- Declaraciones de variables y cursores
	excepcion_NoHayPlato        EXCEPTION;
	excepcion_NoHayRestaurantes EXCEPTION;
  
  v_plato_no_encontrado       Contiene.plato%TYPE;
  v_restaurante_no_encontrado Contiene.Restaurante%TYPE;
  
	v_precio_con_comision       contiene.precioconcomision%TYPE := 0;
	v_cambios_contiene          number := 0;
	v_precio_plato              PLATOS.PRECIO%TYPE;
	v_comision_restaurante      RESTAURANTES.COMISION%TYPE;
  
	CURSOR cursorContiene IS
	SELECT *
	FROM CONTIENE;
  
	CURSOR cursorPlatos (v_nombre platos.nombre%TYPE) IS
	SELECT precio
	FROM platos
	WHERE platos.nombre = v_nombre;

	CURSOR cursorRestaurantes (v_restaurante PLATOS.RESTAURANTE%TYPE) IS
	SELECT comision
	FROM Restaurantes
	WHERE RESTAURANTES.CODIGO = v_restaurante;

  -- Variables de los cursores
	cContiene cursorContiene%ROWTYPE;
	cPlatos cursorPlatos%ROWTYPE;
	cRestaurantes cursorRestaurantes%ROWTYPE;

BEGIN
    
	-- 1. Comprueba el precioconcomision en Contiene
	DBMS_OUTPUT.PUT_LINE('1.Comprobando importe en tabla Contiene');
	FOR cContiene IN cursorContiene LOOP
    
		--Verificar precio en plato
		open cursorPlatos(cContiene.plato);
		FETCH cursorPlatos INTO v_precio_plato;
		
		if cursorPlatos%FOUND then
			v_precio_con_comision := v_precio_plato;
			close cursorPlatos;
		else
      v_plato_no_encontrado := cContiene.plato;
			close cursorPlatos;
			RAISE excepcion_NoHayPlato;
		end if;
		
		--Verificar precio en restaurante
		open cursorRestaurantes (cContiene.Restaurante);
		FETCH cursorRestaurantes INTO v_comision_restaurante;
		if cursorRestaurantes%FOUND then
			v_precio_con_comision := v_precio_con_comision + v_comision_restaurante;
		  
			if cContiene.precioconcomision is null OR v_precio_con_comision <> cContiene.precioconcomision then
				UPDATE Contiene SET precioconcomision = v_precio_con_comision
				WHERE Plato = cContiene.Plato and Restaurante = cContiene.Restaurante and Pedido = cContiene.Pedido;
				v_cambios_contiene := v_cambios_contiene + 1;
			end if;
			close cursorRestaurantes;
		else
      v_restaurante_no_encontrado := cContiene.Restaurante;
			close cursorRestaurantes;
			RAISE excepcion_NoHayRestaurantes;
		end if;
	end loop;
  
	if v_cambios_contiene = 0 then
		DBMS_OUTPUT.PUT_LINE('Ningún cambio en los datos en la tabla Contiene');
	end if;
  
	DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');
	DBMS_OUTPUT.PUT_LINE('RESUMEN TOTALES:');
	DBMS_OUTPUT.PUT_LINE('Cambios en la tabla Contiene: ' || v_cambios_contiene);
	DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');
  
EXCEPTION
	WHEN excepcion_NoHayPlato THEN
		DBMS_OUTPUT.PUT_LINE('No se ha encontrado el plato' || v_plato_no_encontrado || 'de la tabla Contiene en la tabla Platos');
	WHEN excepcion_NoHayRestaurantes THEN
		DBMS_OUTPUT.PUT_LINE('No se ha encontrado el restaurante' || v_restaurante_no_encontrado || 'de la tabla Contiene en la tabla Restaurantes');
    
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error no incluido como excepcion');
END;
/
-- SHOW ERRORS;

-- Bloque
SET SERVEROUTPUT ON SIZE 1000000;
BEGIN
  -- La base de datos se encuentra actualizada, primero desactualizarla.
  DBMS_OUTPUT.PUT_LINE('Apartado 2.');
	DBMS_OUTPUT.PUT_LINE('Prueba: ');
	REVISA_PRECIO_CON_COMISION();
	
	EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM); -- Saca el texto del error
END;
/
/* Apartado 3:
Procedimiento almacenado llamado REVISA_PEDIDOS (sin argumentos) cuya misión es comprobar la
consistencia de los datos de todos los pedidos. El campo “importe total” de la tabla “Pedidos” debe almacenar la
suma de los “precio con comisión” de los platos del pedido multiplicados por su cuantía.
Se pide usar un cursor FOR UPDATE
El procedimiento debe verificar y actualizar estos datos para todos los pedidos, de modo que resulten consistentes.
Si todos los datos son correctos, se mostrará un mensaje indicando “Ningún cambio en los datos de la tabla
Pedidos”. En caso contrario se indicará el número de filas modificadas en en la tabla Pedidos.
*/
CREATE OR REPLACE PROCEDURE REVISA_PEDIDOS IS

v_ImporteTotal              pedidos.importetotal%TYPE := 0;
v_cambios_pedidos           number := 0;
	v_n_platos                  number;

CURSOR cursorPedidosEnContiene (v_pedido contiene.pedido%TYPE) IS
	SELECT SUM(CONTIENE.PRECIOCONCOMISION) AS suma, COUNT (*) cuenta
	FROM CONTIENE
	WHERE pedido = v_pedido;
  
  
	CURSOR cursorPedidos IS
	SELECT p.CODIGO, p.IMPORTETOTAL, p.CLIENTE, d.PORCENTAJEDESCUENTO, d.FECHA_CADUCIDAD, p.FECHA_HORA_PEDIDO
	FROM PEDIDOS p left join DESCUENTOS d
	on p.CODIGODESCUENTO = d.CODIGO;
BEGIN
  -- 1. Comprueba importe total de la tabla Pedidos
  DBMS_OUTPUT.PUT_LINE('1.Comprobando importe en tabla Pedidos');
  FOR cPedidos IN cursorPedidos LOOP
  open cursorPedidosEnContiene (cPedidos.codigo);
  FETCH cursorPedidosEnContiene INTO v_ImporteTotal, v_n_platos;
  close cursorPedidosEnContiene;
  
  IF cPedidos.FECHA_CADUCIDAD is not null and cPedidos.FECHA_CADUCIDAD > cPedidos.FECHA_HORA_PEDIDO THEN
    v_ImporteTotal := v_ImporteTotal *(100 - cPedidos.PorcentajeDescuento)/100;
  END IF;
  if v_ImporteTotal <> cPedidos.importetotal then
    UPDATE Pedidos SET importetotal = v_ImporteTotal
    WHERE Codigo = cPedidos.Codigo;
    v_cambios_pedidos := v_cambios_pedidos + 1;
  end if;
  end loop;
  
  if v_cambios_pedidos = 0 then
    DBMS_OUTPUT.PUT_LINE('Ningún cambio en los datos en la tabla Pedidos');
  end if;
  
	DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');
	DBMS_OUTPUT.PUT_LINE('RESUMEN TOTALES:');
	DBMS_OUTPUT.PUT_LINE('Cambios en la tabla Pedidos: ' || v_cambios_pedidos);
	DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');
END;
/
-- Bloque
SET SERVEROUTPUT ON SIZE 1000000;
BEGIN
  -- La base de datos se encuentra actualizada, primero desactualizarla.
  DBMS_OUTPUT.PUT_LINE('Apartado 3.');
	DBMS_OUTPUT.PUT_LINE('Prueba: ');
	REVISA_PEDIDOS();
	
	EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM); -- Saca el texto del error
END;
/

/* Apartado 4:
1. Crea un procedimiento DATOS_CLIENTES que recorra todos los Clientes con un FOR y
muestre todos sus datos junto con la suma de importe total de todos sus pedidos.
2. Finalmente se mostrará la suma total de los importes de todos los pedidos de todos los clientes.
*/

CREATE OR REPLACE PROCEDURE DATOS_CLIENTES IS

-- Declaraciones de variables y cursores

  v_importe_total             pedidos.importetotal%TYPE := 0;
  v_importe_total_de_pedidos  pedidos.importetotal%TYPE := 0;
  
	CURSOR cursorClientes IS
	SELECT *
	FROM CLIENTES;
  
  CURSOR cursorPedidos (v_cliente clientes.dni%TYPE) IS
	SELECT SUM(IMPORTETOTAL) AS suma
	FROM PEDIDOS
	WHERE CLIENTE = v_cliente;

  -- Variable del cursor
	cClientes cursorClientes%ROWTYPE;
	cPedidos cursorPedidos%ROWTYPE;

BEGIN
    
	-- 1. Recorrer todos los Clientes y mostrar todos sus datos junto con la suma de importe total de todos sus pedidos.
	DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');
	DBMS_OUTPUT.PUT_LINE('   DNI    |        NOMBRE        |      APELLIDO      |        CALLE        |NUMERO|PISO| LOCALIDAD  |CODIGOPOSTAL|TELEFONO|  USUARIO |   CONTRASEÑA    |   IMPORTE TOTAL');
	FOR cClientes IN cursorClientes LOOP
    v_importe_total := 0;
    -- Muestra los datos del cliente
    DBMS_OUTPUT.PUT(
      cClientes.DNI || '   ' || cClientes.NOMBRE || '  ' || cClientes.APELLIDO || '  ' || cClientes.CALLE || '   ' || cClientes.NUMERO || '    ' ||
      cClientes.PISO || '  ' || cClientes.LOCALIDAD || '  ' || cClientes.CODIGOPOSTAL || '  ' || cClientes.TELEFONO || '  ' ||
      cClientes.USUARIO || '  ' || cClientes.CONTRASEÑA
    );
    
		-- Muestra la suma de importe total de todos los pedidos de ese cliente
    open cursorPedidos (cClientes.dni);
		FETCH cursorPedidos INTO v_importe_total;
    close cursorPedidos;
    if v_importe_total is null then
      v_importe_total := 0;
    end if;
  
    DBMS_OUTPUT.PUT_LINE('             ' || v_importe_total);
    v_importe_total_de_pedidos := v_importe_total_de_pedidos + v_importe_total;
    
	end loop;
	DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');
  
  -- 2. Finalmente se mostrará la suma total de los importes de todos los pedidos de todos los clientes.
	DBMS_OUTPUT.PUT_LINE('La suma del importe total de los pedidos es ' || v_importe_total_de_pedidos);
	DBMS_OUTPUT.PUT_LINE('---------------------------------------------------------');
  
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error no incluido como excepcion');
END;
/
-- SHOW ERRORS;

-- Bloque
SET SERVEROUTPUT ON SIZE 1000000;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Apartado 4.');
	DBMS_OUTPUT.PUT_LINE('Prueba: ');
	DATOS_CLIENTES();
	
	EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM); -- Saca el texto del error
END;
/

/* Apartado 5:
Crea un procedimiento que llame a REVISA_PRECIO_CON_COMISION, REVISA_PEDIDOS y DATOS_CLIENTES.
Incluye un bloque anónimo de prueba.
*/
CREATE OR REPLACE PROCEDURE AP5 IS

BEGIN
  DBMS_OUTPUT.PUT_LINE('Apartado 1.');
  PEDIDOS_CLIENTE('12345678M');
  DBMS_OUTPUT.PUT_LINE('');

  DBMS_OUTPUT.PUT_LINE('Apartado 2.');
	REVISA_PRECIO_CON_COMISION();
  DBMS_OUTPUT.PUT_LINE('');
  
  DBMS_OUTPUT.PUT_LINE('Apartado 3.');
  REVISA_PEDIDOS();
  DBMS_OUTPUT.PUT_LINE('');

  DBMS_OUTPUT.PUT_LINE('Apartado 4.');
	DATOS_CLIENTES();
END;
/

-- Bloque
SET SERVEROUTPUT ON SIZE 1000000;
BEGIN

  DBMS_OUTPUT.PUT_LINE('Apartado 5.');
  DBMS_OUTPUT.PUT_LINE('**********************************************************');
	AP5();
  DBMS_OUTPUT.PUT_LINE('**********************************************************');
	
	EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM); -- Saca el texto del error
END;

/*
-- Pequeña modificacion de la tabla Contiene
UPDATE Contiene SET precioconcomision = 28.2
WHERE Plato = 'vege-burguer' and Restaurante = 3456 and Pedido = 2;

-- Pequeña modificacion de la tabla Pedidos
UPDATE Pedidos SET importetotal = 38.5
WHERE Codigo = 3;
*/