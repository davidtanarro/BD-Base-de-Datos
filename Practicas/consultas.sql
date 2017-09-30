	/* 1. Listado con todos los datos de los clientes, ordenados por apellidos.*/
	SELECT DNI, NOMBRE, APELLIDO, CALLE, NUMERO, PISO, LOCALIDAD, CODIGOPOSTAL, TELEFONO, USUARIO, CONTRASEÑA
  FROM Clientes
  ORDER BY APELLIDO;
  
	/* 2. Horarios de cada uno de los restaurantes. Para cada restaurante aparecerá su nombre y el día de la
	semana (sustituyendo la letra por el nombre completo del día) y la hora de apertura y de cierre, en
	formato HH:MM*/
  SELECT Restaurantes.nombre, REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE( REPLACE (Horarios.diasemana,'L','Lunes'),'M','Martes'),'X', 'Miercoles'),'J','Jueves'),'V','Viernes'),'S','Sabado'),'D','Domingo') AS dia, to_char(Horarios.HORAAPERTURA,'HH24:MI') AS apertura, to_char(Horarios.HORACIERRE,'HH24:MI')AS cierre
  FROM Restaurantes, Horarios
  WHERE Restaurantes.codigo=Horarios.restaurante;
  
	/* 3. Qué clientes (DNI, nombre y apellidos) han pedido alguna vez platos de la categoría “picante”?*/
	SELECT Clientes.DNI, Clientes.nombre, Clientes.apellido
	FROM Clientes, Pedidos, Contiene, Platos
	WHERE Clientes.DNI = Pedidos.cliente AND Pedidos.codigo = Contiene.pedido AND Contiene.plato = Platos.nombre AND Platos.categoria = 'picante';

	/* 4. ¿Qué clientes (DNI, nombre y apellidos) han pedido platos en todos los restaurantes?*/
  SELECT Clientes.DNI, Clientes.nombre, Clientes.apellido
	FROM Clientes, Pedidos, Contiene, Platos, Restaurantes
	WHERE Clientes.DNI = Pedidos.cliente  
  AND Contiene.plato = Platos.nombre 
  AND Pedidos.codigo = Contiene.pedido
  AND Platos.restaurante = ALL(SELECT codigo FROM Restaurantes);
  
	/* 5. ¿Qué clientes (DNI, nombre y apellidos) no han recibido aún sus pedidos?*/
  SELECT Clientes.DNI, Clientes.nombre, Clientes.apellido
	FROM Clientes, Pedidos
  WHERE pedidos.estado='RUTA'and Clientes.DNI = Pedidos.cliente;
  
	/* 6. Muestra todos los datos (salvo los platos que lo componen) del pedido (o pedidos) de mayor importe
	total. Considera que puede haber varios pedidos con el mismo importe.*/
  SELECT *
  FROM Pedidos 
  WHERE Pedidos.importetotal = (SELECT MAX(Pedidos.importeTotal)  FROM Pedidos );
  
	/* 7. Obtén el valor medio de los pedidos de cada cliente, mostrando su DNI, nombre y apellidos.*/
  SELECT DISTINCT Clientes.DNI, Clientes.nombre, Clientes.apellido, AVG(Pedidos.importeTotal) AS VALOR_MEDIO
  FROM Clientes, Pedidos
  WHERE (Clientes.DNI = Pedidos.CLIENTE)
  GROUP BY Clientes.DNI, Clientes.NOMBRE, Clientes.APELLIDO;
  
	/* 8. Muestra para cada restaurante (código y nombre) el número total de platos vendidos y el precio
	acumulado que obtuvieron.*/
  SELECT Restaurantes.codigo, Restaurantes.nombre,SUM(Contiene.Unidades)AS unidades, SUM(Pedidos.importeTotal) AS suma
  FROM Restaurantes, Platos, Contiene, Pedidos
  WHERE Platos.restaurante = Restaurantes.codigo
  AND Contiene.plato = Platos.nombre 
  AND Contiene.pedido=Pedidos.codigo 
  AND (pedidos.estado='RUTA'OR pedidos.estado='REST' OR pedidos.estado='ENTREGADO')
	GROUP BY  Restaurantes.nombre, Restaurantes.codigo;
	
  /* 9. Nombre y apellidos de aquellos clientes que pidieron platos de más de 15 €.*/
  SELECT DISTINCT Clientes.NOMBRE, Clientes.APELLIDO
  FROM Platos, Contiene, Pedidos, Clientes
  WHERE  Pedidos.codigo = Contiene.pedido AND Clientes.DNI = Pedidos.cliente AND Contiene.plato = Platos.nombre AND Platos.precio > 15;
	
	/* 10. Para cada cliente (mostrar DNI, nombre y apellidos) mostrar el número de restaurantes que cubren el
	área en el que vive el cliente. Si algún cliente no está cubierto por ninguno, debe aparecer 0. */
  SELECT Clientes.DNI, Clientes.nombre, Clientes.apellido, 0 AS RESTAURANTES_ZONA
  FROM Clientes
  WHERE Clientes.DNI NOT IN(
    SELECT Clientes.DNI
    FROM Clientes, AreasCobertura
    WHERE  AreasCobertura.codigoPostal = Clientes.codigoPostal
    GROUP BY Clientes.DNI, Clientes.codigoPostal
  )
  UNION ALL SELECT Clientes.DNI, Clientes.nombre, Clientes.apellido, COUNT(Clientes.codigoPostal) as RESTAURANTES_ZONA
       FROM Clientes, AreasCobertura
       WHERE AreasCobertura.codigoPostal=Clientes.codigoPostal 
       GROUP BY Clientes.DNI, Clientes.nombre, Clientes.apellido,  Clientes.codigoPostal;

SET AUTOCOMMIT ON;