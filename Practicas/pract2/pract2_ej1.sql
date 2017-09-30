/* 1. Lista de libros disponibles con su autor y año de publicación ordenada por este último. */

SELECT Libro.Titulo, Libro.Año, Autor.Nombre
FROM Autor, Libro, Autor_Libro
WHERE libro.isbn = autor_libro.isbn and autor.idautor = autor_libro.autor
ORDER BY Año;

/* 2. Lista de libros disponibles publicados después del año 2000. */

SELECT Libro.Titulo, Libro.año
FROM Libro
WHERE libro.año > '2000';

/* 3. Lista de Clientes que han realizado algún pedido */

SELECT DISTINCT cliente.nombre
FROM Pedido, Cliente
WHERE cliente.idcliente = pedido.idcliente;

/* 4. Lista de clientes que han adquirido el libro con ISBN= 4554672899910. */

SELECT DISTINCT cliente.nombre
FROM Pedido, Cliente, Libros_Pedido
WHERE cliente.idcliente = pedido.idcliente and pedido.idpedido = libros_pedido.idpedido
        and libros_pedido.isbn = '4554672899910';

/* 5. Lista de los clientes y los libros adquiridos por ellos cuyo nombre (del cliente) contenga ‘San’. */

SELECT DISTINCT cliente.nombre
FROM Pedido, Cliente, Libros_Pedido, Libro
WHERE cliente.idcliente = pedido.idcliente and pedido.idpedido = libros_pedido.idpedido and libros_pedido.isbn = libro.isbn
          and cliente.nombre LIKE '%San%';

/* 6. Lista de Clientes que hayan comprado libros de más de 10 euros. */

SELECT DISTINCT cliente.nombre
FROM Pedido, Cliente, Libros_Pedido, Libro
WHERE cliente.idcliente = pedido.idcliente and pedido.idpedido = libros_pedido.idpedido and libros_pedido.isbn = libro.isbn
          and libro.precioventa > 10;

/* 7. Clientes y fecha de pedidos que han realizado que no han sido expedidos aun. */

SELECT DISTINCT cliente.nombre, pedido.fechapedido
FROM Pedido, Cliente, Libros_Pedido
WHERE cliente.idcliente = pedido.idcliente and pedido.idpedido = libros_pedido.idpedido
        and pedido.fechaexped is null;

/* 8. Lista de clientes que NO han comprado libros de precio superior a 10 euros */
insert into Cliente values ('0000007','Ramoncín Burro', 'Corral','1234567898765432');
insert into Libro values ('0000011111111', 'El rey leon', '2008', 9.45, 9.50);
insert into Pedido values ('0000007P','0000007', TO_DATE('01/12/2016'),TO_DATE('03/12/2011'));
insert into Libros_Pedido values ('0000011111111','0000007P', 1);

SELECT DISTINCT c1.nombre
FROM Pedido, Cliente c1, Libros_Pedido, Libro
WHERE c1.idcliente = pedido.idcliente and pedido.idpedido = libros_pedido.idpedido and libros_pedido.isbn = libro.isbn
          and libro.precioventa < 10
          and not exists (
              SELECT DISTINCT c2.nombre
              FROM Pedido, Cliente c2, Libros_Pedido, Libro
              WHERE c2.idcliente = pedido.idcliente and pedido.idpedido = libros_pedido.idpedido and libros_pedido.isbn = libro.isbn
                  and libro.precioventa >= 10 and c1.idcliente = c2.idcliente 
          )
UNION
SELECT DISTINCT cliente.nombre
FROM Cliente
WHERE NOT EXISTS (SELECT DISTINCT pedido.idcliente
                  FROM Pedido
                  WHERE Pedido.idcliente = cliente.idcliente
                  );

/* 9. Lista de libros vendidos con precio superior a 30 euros o publicados antes del año 2000 */
insert into Libro values ('0000022222222', 'Sexo en NY', '1999', 9.45, 30.50);

SELECT DISTINCT Libro.Titulo
FROM Libros_Pedido, Libro
WHERE libros_pedido.isbn = libro.isbn
          and ((libro.precioventa is not null and libro.precioventa > 30) or libro.año < 2000);

/* 10. Clientes que han hecho más de un pedido el mismo día. */
insert into Pedido values ('0000008P','0000007', TO_DATE('01/09/2016'),TO_DATE('03/12/2011'));

SELECT DISTINCT c1.nombre
FROM Pedido p1, Cliente c1
WHERE c1.idcliente = p1.idcliente
        and p1.FechaExped is not null and p1.FechaExped = ANY (
                              SELECT DISTINCT p2.FechaExped
                              FROM Pedido p2, Cliente c2
                              WHERE c2.idcliente = p2.idcliente and 
                                    c1.idcliente = c2.idcliente and p1.idpedido <> p2.idpedido
                                    and p2.FechaExped is not null /*and p1.Idpedido <> p2.Idpedido*/);

/* 11. Lista de títulos de libros vendidos y cantidad. */

SELECT DISTINCT Libro.Titulo, SUM(Libros_Pedido.Cantidad) AS CantidadesVendidas
FROM Libro, Libros_Pedido, Pedido
WHERE Libro.ISBN = Libros_Pedido.ISBN and Libros_Pedido.IDPEDIDO = Pedido.IDPEDIDO
GROUP BY Libro.Titulo;

/* 12. Lista de Clientes junto al importe total gastado en la librería */

SELECT DISTINCT Cliente.nombre, SUM(Libro.PrecioVenta*Libros_Pedido.cantidad) AS ImporteTotalGastado
FROM Cliente, Pedido, Libros_Pedido, Libro
WHERE Cliente.idcliente = Pedido.idcliente and Pedido.idpedido = Libros_Pedido.idpedido and Libros_Pedido.isbn = Libro.isbn
GROUP BY Cliente.nombre;

/* 13. Ganancias obtenidas por la librería con las ventas */

SELECT SUM(Libro.PrecioVenta*Libros_Pedido.cantidad - Libro.PrecioCompra*Libros_Pedido.cantidad) AS Ganancias
FROM Pedido, Libros_Pedido, Libro
WHERE Pedido.idpedido = Libros_Pedido.idpedido and Libros_Pedido.isbn = Libro.isbn;

/* 14. Lista de importe total de pedidos por fecha, que se hayan realizado después del 01/12/2011 y no hayan sido expedidos */
insert into Libros_Pedido values ('0000011111111','0000006P', 1);
delete from Libros_Pedido where ISBN = '0000011111111' and IDPEDIDO = '0000006P';

SELECT DISTINCT Pedido.Idpedido, Pedido.FechaPedido, SUM(Libro.PrecioVenta*Libros_Pedido.cantidad) AS ImporteTotal
FROM Pedido, Libros_Pedido, Libro
WHERE Pedido.idpedido = Libros_Pedido.idpedido and Libros_Pedido.isbn = Libro.isbn
        and Pedido.FechaPedido > '01/12/2011' and Pedido.FechaExped is null
GROUP BY Pedido.Idpedido, Pedido.FechaPedido
ORDER BY Pedido.FechaPedido;

/* 15. Pedidos con importe superior a 100 euros */

SELECT Pedido.Idpedido, SUM(Libro.PrecioVenta*Libros_Pedido.cantidad) AS Importe
FROM Libro, Libros_Pedido, Pedido
WHERE Libro.ISBN = Libros_Pedido.ISBN and Libros_Pedido.IDPEDIDO = Pedido.IDPEDIDO
GROUP BY Pedido.Idpedido
HAVING SUM(Libro.PrecioVenta*Libros_Pedido.cantidad) > 100;

/* 16. Pedidos con importe total que contengan más de un titulo */

SELECT P1.Idpedido, SUM(L1.PrecioVenta*LP1.cantidad) AS ImporteTotal
FROM Libro L1, Libros_Pedido LP1, Pedido P1
WHERE L1.ISBN = LP1.ISBN and LP1.Idpedido = P1.Idpedido
        and EXISTS ( 
                      SELECT P2.Idpedido
                      FROM Libro L2, Libros_Pedido LP2, Pedido P2
                      WHERE L2.ISBN = LP2.ISBN and LP2.Idpedido = P2.Idpedido
                            and P1.idpedido = P2.idpedido and L1.Titulo <> L2.Titulo
                    )
GROUP BY P1.Idpedido;

/* 17. Pedidos con importe total que contengan más de 4 libros (ejemplares) */
insert into Libros_Pedido values ('0000022222222','0000007P', 1);
insert into Libro values ('0000033333333', 'Toy Story I', '2000', 10, 12.5);
insert into Libros_Pedido values ('0000033333333','0000007P', 1);
insert into Libro values ('0000044444444', 'Toy Story II', '2004', 12.5, 15);
insert into Libros_Pedido values ('0000044444444','0000007P', 1);
insert into Libro values ('0000055555555', 'Toy Story III', '2009', 15, 20);
insert into Libros_Pedido values ('0000055555555','0000007P', 1);
delete from Libro where ISBN = '0000033333333';
delete from Libro where ISBN = '0000044444444';
delete from Libro where ISBN = '0000055555555';

SELECT P1.Idpedido, SUM(L1.PrecioVenta*LP1.cantidad) AS ImporteTotal
FROM Libro L1, Libros_Pedido LP1, Pedido P1
WHERE L1.ISBN = LP1.ISBN and LP1.Idpedido = P1.Idpedido    
GROUP BY P1.Idpedido
HAVING COUNT (*) > 4;

/* 18. Lista de libros más caros. */
SELECT Libro.Titulo, Libro.PrecioVenta
FROM Libro
ORDER BY Libro.PrecioVenta DESC;

/* 19. Libros de los que no se haya vendido ningún ejemplar o cuyo beneficio sea inferior a 5 euros */

SELECT Libro.Titulo
FROM Libro
WHERE Libro.ISBN NOT IN (
                  SELECT Libros_Pedido.ISBN
                  FROM Libros_Pedido
                  )
UNION
SELECT Libro.Titulo
FROM Libro
WHERE (Libro.PrecioVenta - Libro.PrecioCompra) < 5;

/* 20. Clientes que hayan comprado más de un ejemplar de un título en alguna ocasión */

SELECT DISTINCT Cliente.Nombre
FROM Libros_Pedido, Pedido, Cliente
WHERE Libros_Pedido.IdPedido = Pedido.IdPedido and Pedido.IdCliente = Cliente.IdCliente
      and Libros_Pedido.Cantidad > 1;

/* 21. Lista de Nombre de cliente, numero de pedido, isbn y título de libros adquiridos. Si no han adquirido ningún libro mostrar el nombre del cliente también. */

SELECT DISTINCT Cliente.Nombre, Pedido.IdPedido, Libro.ISBN, Libro.Titulo
FROM Libro, Libros_Pedido, Pedido, Cliente
WHERE Libro.ISBN = Libros_Pedido.ISBN and Libros_Pedido.IdPedido = Pedido.IdPedido and Pedido.IdCliente = Cliente.IdCliente
UNION
SELECT DISTINCT Cliente.Nombre, NULL, NULL, NULL
FROM Cliente
WHERE Cliente.IdCliente NOT IN (  SELECT Pedido.IdCliente
                                  FROM Pedido
                                );

