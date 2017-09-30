/* 1. Código y nombre de los pilotos certificados para pilotar aviones Boeing. */

SELECT DISTINCT Empleado.eid, Empleado.nombre
FROM  Empleado, Certificado, Avion
WHERE Empleado.eid = Certificado.eid and Certificado.aid = Avion.aid
        and Avion.NOMBRE LIKE 'Boeing%';

/* 2. Código de aviones que pueden hacer el recorrido de Los Ángeles a Chicago sin repostar. */

SELECT DISTINCT Avion.aid
FROM  Vuelo, Avion
WHERE Vuelo.distancia <= Avion.autonomia and Vuelo.origen = 'Los Angeles' and Vuelo.destino = 'Chicago';

/* 3. Pilotos certificados para operar con aviones con una autonomía superior a 3000 millas pero no certificados para aviones Boeing. */

SELECT DISTINCT Empleado.NOMBRE
FROM  Vuelo, Empleado, Certificado, Avion
WHERE Empleado.eid = Certificado.eid and Certificado.aid = Avion.aid
        and Avion.autonomia > 3000 and Empleado.nombre NOT IN ( SELECT DISTINCT Empleado.nombre
                                                                FROM  Empleado, Certificado, Avion
                                                                WHERE Empleado.eid = Certificado.eid and Certificado.aid = Avion.aid
                                                                  and Avion.NOMBRE LIKE 'Boeing%');

/* 4. Empleados con el salario más elevado. */

SELECT Empleado.nombre, Empleado.Salario
FROM  Empleado
WHERE Empleado.Salario = (SELECT MAX(Empleado.Salario) AS Salario_Maximo
                          FROM  Empleado
                          );
                          
SELECT *
FROM (  SELECT Empleado.nombre, Empleado.Salario
        FROM  Empleado
        ORDER BY Empleado.Salario DESC)
WHERE rownum <= 1;

/* 5. Empleados con el segundo salario más alto. */

SELECT Empleado.nombre, Empleado.Salario
FROM  Empleado
WHERE Empleado.Salario = (SELECT MAX(Empleado.Salario) AS Segundo_salario_Maximo
                          FROM  Empleado
                          WHERE  Empleado.Salario <> (SELECT MAX(Empleado.Salario) AS Salario_Maximo
                                                      FROM  Empleado)
                          );

/* 6. Empleados con mayor número de certificaciones para volar. */

SELECT *
FROM (  SELECT Empleado.Nombre, COUNT(*) AS CUENTA
        FROM  Empleado, Certificado
        WHERE Empleado.eid = Certificado.eid
        GROUP BY Empleado.Nombre
        ORDER BY CUENTA DESC)
WHERE rownum <= 1; -- equivalente a: WHERE rownum <= 1; ó WHERE rownum < 2;

/* 7. Empleados certificados para 3 modelos de avión. */

SELECT Empleado.Nombre
FROM  Empleado
WHERE Empleado.eid IN ( SELECT Certificado.eid
                        FROM Certificado, Avion
                        WHERE Certificado.aid = Avion.aid 
                        GROUP BY Certificado.eid
                        HAVING COUNT (*) > 3
                        );

/* 8. Nombre de los aviones tales que todos los pilotos certificados para operar con ellos tengan salarios superiores a 80.000 euros. */ 

SELECT DISTINCT a1.Nombre
FROM Avion a1, Certificado c1, Empleado e1
WHERE a1.aid = c1.aid and c1.eid = e1.eid
        and 80000 > ANY ( SELECT e2.salario
                          FROM Certificado c2, Empleado e2
                          WHERE c2.eid = e2.eid
                                  and a1.aid = c2.aid
                          );

/* 9. Para cada piloto certificado para operar con más de 3 modelos de avión indicar el código de empleado y la autonomía máxima de los aviones que puede pilotar. */

SELECT Empleado.Nombre, Empleado.Eid, MAX(Avion.autonomia) AS MAX_AUTONOMIA
FROM  Empleado, Certificado, Avion
WHERE Avion.aid = Certificado.aid and Certificado.eid = Empleado.eid
       and Empleado.eid IN ( SELECT Certificado.eid
                        FROM Certificado, Avion
                        WHERE Certificado.aid = Avion.aid 
                        GROUP BY Certificado.eid
                        HAVING COUNT (*) > 3
                        )
GROUP BY Empleado.Nombre, Empleado.Eid;

/* 10. Nombre de los pilotos cuyo salario es inferior a la ruta más barata entre Los Ángeles y Honolulu. */

SELECT Empleado.Nombre, Empleado.Salario
FROM  Empleado, Certificado
WHERE Certificado.eid = Empleado.eid
GROUP BY Empleado.Nombre, Empleado.Salario
HAVING Empleado.Salario < ( SELECT MIN(Vuelo.precio)
                            FROM Vuelo
                            WHERE Vuelo.Origen = 'Los Angeles' and Vuelo.Destino = 'Honolulu');

/* 11. Mostrar el nombre de los aviones con autonomía de vuelo superior a 1.000 millas junto con la media salarial de los pilotos certificados. */

SELECT *
FROM (SELECT DISTINCT Avion.nombre
      FROM Avion
      WHERE Avion.autonomia > 1000),
      (SELECT AVG(Empleado.Salario) AS MEDIA_SALARIAL_PILOTOS
      FROM Empleado, Certificado
      WHERE Certificado.eid = Empleado.eid);

/* 12. Calcular la diferencia entre la media salarial de todos los empleados (incluidos los pilotos) y la de los pilotos. */

SELECT ABS(MEDIA_SALARIAL_EMPLEADOS - MEDIA_SALARIAL_PILOTOS) AS DIFERENCIA_SALARIOS
FROM (SELECT AVG(Empleado.Salario) AS MEDIA_SALARIAL_EMPLEADOS
      FROM Empleado),
     (SELECT AVG(Empleado.Salario) AS MEDIA_SALARIAL_PILOTOS
      FROM Empleado, Certificado
      WHERE Certificado.eid = Empleado.eid);

/* 13. Listar el nombre y los salarios de los empleados (no pilotos) cuyo salario sea superior a la media salarial de los pilotos. */
insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('111111111','Ramoncín burro','250000');

SELECT *
FROM (SELECT DISTINCT Empleado.nombre, Empleado.Salario
      FROM Empleado
      WHERE Empleado.EID NOT IN ( SELECT DISTINCT Certificado.eid
                                  FROM Certificado)
      ),
     (SELECT AVG(Empleado.Salario) AS MEDIA_SALARIAL_PILOTOS
      FROM Empleado, Certificado
      WHERE Certificado.eid = Empleado.eid)
WHERE Salario > MEDIA_SALARIAL_PILOTOS;

/* 14. Nombre de los pilotos certificados solo para modelos con autonomía superior a 1.000 millas. */

SELECT DISTINCT Empleado.nombre
FROM Empleado, Certificado
WHERE Certificado.eid = Empleado.eid
      and Certificado.aid IN (SELECT DISTINCT Avion.aid
                              FROM Avion
                              WHERE Avion.autonomia > 1000);
