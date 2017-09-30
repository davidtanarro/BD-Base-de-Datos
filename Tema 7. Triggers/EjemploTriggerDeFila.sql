-- ----------------------------------------------------
-- Ejemplo de triggers de fila
-- ----------------------------------------------------


set serveroutput on;

CREATE OR REPLACE TRIGGER antesDeInsertLibro
BEFORE INSERT ON Libro
REFERENCING NEW AS nuevoLibro
FOR EACH ROW
BEGIN
  DBMS_OUTPUT.PUT_LINE('Se va a insertar el libro: ' || :nuevoLibro.Titulo);
END;
/

insert into libro values ('11111','Lo que el viento se llevó',1937,15,18);
commit;
rollback;
delete from libro where isbn='11111';

CREATE OR REPLACE TRIGGER antesDeUpdateLibro
BEFORE UPDATE OF precioCompra,precioVenta ON Libro
FOR EACH ROW
WHEN (NEW.precioCompra < OLD.precioCompra OR NEW.precioVenta < OLD.precioVenta)
BEGIN
  IF (:NEW.precioCompra != :OLD.precioCompra) THEN
    DBMS_OUTPUT.PUT_LINE('OJO: se va a cambiar el precio de compra de ' 
      || :OLD.precioCompra || ' a ' || :NEW.precioCompra);
  END IF;
  IF (:NEW.precioVenta != :OLD.precioVenta) THEN
    DBMS_OUTPUT.PUT_LINE('OJO: se va a cambiar el precio de venta de ' 
      || :OLD.precioVenta || ' a ' || :NEW.precioVenta);
  END IF;
END;
/

UPDATE libro SET precioCompra = 13 WHERE isbn = '11111';

UPDATE libro SET precioVenta = 13 WHERE isbn = '11111';

