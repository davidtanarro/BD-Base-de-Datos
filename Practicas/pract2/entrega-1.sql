/*DAVID TANARRO DE LAS HERAS Y JAVIER ORTIZ INIESTA*/


insert into lIBRO values ('9999999999999', 'Novelas Ejemplares', '2014', 9.45, 13.45);
/*insert into Autor values (4,'Miguel de Cervantes');*/
insert into Autor_lIBRO values ('9999999999999',4);
insert into Pedido values ('0000010P','0000003', TO_DATE('29/11/2016'),TO_DATE('29/11/2016'));
insert into Pedido values ('0000011P','0000005', TO_DATE('29/11/2016'),TO_DATE('29/11/2016'));
insert into Pedido values ('0000012P','0000006', TO_DATE('29/11/2016'),TO_DATE('29/11/2016'));
insert into Libros_Pedido values ('9999999999999','0000010P', 3);
insert into Libros_Pedido values ('9999999999999','0000011P', 2);
insert into Libros_Pedido values ('9999999999999','0000012P', 2);



/* a. Lista de los autores y el numero de ejemplares vendidos de cada autor, en orden decreciente de ventas. */

SELECT nombre, SUM (cantidad) AS SUMA
FROM (  SELECT autor.nombre, libros_pedido.cantidad
        FROM Autor, Autor_Libro, Libros_Pedido
        WHERE Autor.idautor = Autor_Libro.Autor AND Autor_Libro.ISBN = Libros_Pedido.ISBN 
        )
GROUP BY nombre
ORDER BY SUM (cantidad) DESC
;

SELECT autor.nombre, SUM (libros_pedido.cantidad) AS SUMA
FROM Autor, Autor_Libro, Libros_Pedido
WHERE Autor.idautor = Autor_Libro.Autor AND Autor_Libro.ISBN = Libros_Pedido.ISBN 
GROUP BY autor.nombre
ORDER BY SUM (libros_pedido.cantidad) DESC
;


/*b. Lista de los autores y el numero de clientes distintos que han comprado sus libros, en orden decreciente de
numero de clientes.*/

SELECT DISTINCT Autor.nombre, COUNT (cliente.idcliente) AS CUENTA
FROM Cliente, Pedido, Libros_Pedido, Autor_Libro, Autor
WHERE Cliente.IdCliente = Pedido.IdCliente AND Pedido.IDPEDIDO = Libros_Pedido.IDPEDIDO AND Autor_Libro.ISBN = Libros_Pedido.ISBN AND  Autor.idautor = Autor_Libro.Autor
GROUP BY autor.nombre
ORDER BY COUNT (cliente.idcliente) DESC
;

/*c. Lista de los autores y el numero de ejemplares vendidos de aquellos autores que han vendido tantos ejemplares
como el Autor con IdAutor = 1.*/

SELECT nombre, SUM (cantidad) AS SUMA
FROM (  SELECT autor.idautor, autor.nombre, libros_pedido.cantidad
        FROM Autor, Autor_Libro, Libros_Pedido
        WHERE Autor.idautor = Autor_Libro.Autor AND Autor_Libro.ISBN = Libros_Pedido.ISBN 
        )
GROUP BY idautor, nombre
HAVING SUM (cantidad) = (  SELECT SUM(libros_pedido.cantidad)
                              FROM Autor, Autor_Libro, Libros_Pedido
                              WHERE Autor.idautor = Autor_Libro.Autor AND Autor_Libro.ISBN = Libros_Pedido.ISBN
                                      AND Autor.idautor = 1 ) AND idautor <> 1
;

/*d. Lista de los autores y su rentabilidad en orden decreciente de rentabilidad. La rentabilidad es el dinero que
ha ganado la librera con todas las ventas de libros de ese autor. Considera como venta realizada todos los
pedidos, aunque no se hayan expedido aun.*/

SELECT AUTOR.NOMBRE, SUM(Libro.PrecioVenta*Libros_Pedido.cantidad - Libro.PrecioCompra*Libros_Pedido.cantidad) AS Ganancias
FROM Pedido, Libros_Pedido, Libro, Autor_Libro, Autor
WHERE Pedido.idpedido = Libros_Pedido.idpedido and Libros_Pedido.isbn = Libro.isbn AND libro.isbn = autor_libro.isbn AND autor_libro.autor = autor.idautor
GROUP BY AUTOR.nombre
ORDER BY Ganancias DESC
;

/*e. Lista de los autores que han tenido para la tienda una rentabilidad mayor que la rentabilidad media de los
autores de libros disponibles en la tienda, en orden alfabetico (En esta consulta puedes utilizar una vista, pero
hacerlo sin utilizar vistas es un buen ejercicio).*/

SELECT AUTOR.NOMBRE, SUM(Libro.PrecioVenta*Libros_Pedido.cantidad - Libro.PrecioCompra*Libros_Pedido.cantidad) AS Ganancias
FROM Pedido, Libros_Pedido, Libro, Autor_Libro, Autor
WHERE Pedido.idpedido = Libros_Pedido.idpedido and Libros_Pedido.isbn = Libro.isbn AND libro.isbn = autor_libro.isbn AND autor_libro.autor = autor.idautor
GROUP BY AUTOR.nombre
HAVING SUM(Libro.PrecioVenta*Libros_Pedido.cantidad - Libro.PrecioCompra*Libros_Pedido.cantidad)  > (   SELECT AVG(Libro.PrecioVenta*Libros_Pedido.cantidad - Libro.PrecioCompra*Libros_Pedido.cantidad) AS Ganancias
                                                                                                        FROM Pedido, Libros_Pedido, Libro, Autor_Libro, Autor
                                                                                                        WHERE Pedido.idpedido = Libros_Pedido.idpedido and Libros_Pedido.isbn = Libro.isbn AND libro.isbn = autor_libro.isbn AND autor_libro.autor = autor.idautor
                                                                                                        )
ORDER BY AUTOR.NOMBRE DESC
;

/*a. Nombre de los aviones tales que todos los pilotos certicados para operar con ellos tengan salarios superiores
a 80.000 euros.*/

SELECT DISTINCT a1.Nombre
FROM Avion a1, Certificado c1, Empleado e1
WHERE a1.aid = c1.aid and c1.eid = e1.eid
        and 80000 < ANY ( SELECT e2.salario
                          FROM Certificado c2, Empleado e2
                          WHERE c2.eid = e2.eid
                                  and a1.aid = c2.aid
                          )
;

/*b. Calcular la diferencia entre la media salarial de todos los empleados (incluidos los pilotos) y la de los pilotos.*/

SELECT ABS(MEDIA_SALARIAL_EMPLEADOS - MEDIA_SALARIAL_PILOTOS) AS DIFERENCIA_SALARIOS
FROM (SELECT AVG(Empleado.Salario) AS MEDIA_SALARIAL_EMPLEADOS
      FROM Empleado),
     (SELECT AVG(Empleado.Salario) AS MEDIA_SALARIAL_PILOTOS
      FROM Empleado, Certificado
      WHERE Certificado.eid = Empleado.eid)
;



