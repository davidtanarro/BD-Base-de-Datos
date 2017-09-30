-- ----------------------------------------------------
-- Ejemplo de bloque anonimo plsql.
-- ----------------------------------------------------
-- Recorre con un bucle LOOP un cursor y muestra el
-- resultado en la consola.  
-- ----------------------------------------------------

SET SERVEROUTPUT ON;


DECLARE
  CURSOR cLibrosAutores IS
    SELECT l.titulo, a.nombre 
    FROM libro l JOIN autor_libro al on l.ISBN=al.ISBN
    JOIN autor a ON a.IDAUTOR=al.AUTOR;
  v_nombre AUTOR.NOMBRE%TYPE;
  v_titulo libro.titulo%TYPE;
BEGIN
  OPEN cLibrosAutores;
  LOOP
    FETCH cLibrosAutores INTO v_titulo, v_nombre;
    EXIT WHEN cLibrosAutores%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_nombre || ',' || v_titulo);
  END LOOP;
  CLOSE cLibrosAutores;
END;

