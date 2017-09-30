-- ----------------------------------------------------
-- Ejemplo de funcion plsql y bloque anonimo de llamada.
-- ----------------------------------------------------

SET SERVEROUTPUT ON;


CREATE OR REPLACE FUNCTION cuadrado(x NUMBER)
  RETURN NUMBER
IS
  res NUMBER;
BEGIN
  res := x*x;
  RETURN res;
END;
/

DECLARE
  V NUMBER;
  RES NUMBER;
BEGIN
  V := 18;
  RES := cuadrado(V);
  DBMS_OUTPUT.PUT_LINE('EL CUADRADO DE ' || to_char(V) || ' ES: ' || to_char(RES));
END;
