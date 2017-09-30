/*DROP TABLE Restaurantes;*/
CREATE TABLE Restaurantes(
codigo NUMBER(8) NOT NULL
, nombre CHAR(20) NOT NULL
, calle CHAR(30) NOT NULL
, codigoPostal CHAR(5) NOT NULL
, comision NUMBER(8,2)
, PRIMARY KEY(codigo)
);

/*DROP TABLE AreasCobertura;*/
CREATE TABLE AreasCobertura(
restaurante NUMBER(8) NOT NULL
, codigoPostal CHAR(5) NOT NULL
, PRIMARY KEY (restaurante, codigoPostal)
, FOREIGN KEY (restaurante) REFERENCES Restaurantes (codigo)
);


/*DROP TABLE Horarios;*/
CREATE TABLE Horarios(
restaurante Number(8) NOT NULL
, diaSemana Char(1) NOT NULL
, horaApertura Date NOT NULL
, horaCierre Date NOT NULL
, PRIMARY KEY (restaurante, diaSemana)
, FOREIGN KEY (restaurante) REFERENCES Restaurantes (codigo)
);

/*DROP TABLE Platos;*/
CREATE TABLE Platos(
restaurante Number(8) NOT NULL
, nombre Char(20) NOT NULL
, precio Number(8,2)
, descripcion Char(30)
, categoria Char(20)
, PRIMARY KEY (restaurante, nombre)
, FOREIGN KEY (restaurante) REFERENCES Restaurantes (codigo) ON DELETE CASCADE
);

/*DROP TABLE Clientes;*/
CREATE TABLE Clientes(
DNI Char(9) NOT NULL
, nombre Char(20) NOT NULL
, apellido Char(20) NOT NULL
, calle Char(20)
, numero Number(4) NOT NULL
, piso Char(5)
, localidad Char(15)
, codigoPostal Char(5)
, telefono Char(9)
, usuario Char(8) NOT NULL UNIQUE
, contraseña Char(8)  DEFAULT 'Notpass' NOT NULL
, PRIMARY KEY(DNI)
);

/*DROP TABLE Descuentos;*/
CREATE TABLE Descuentos(
codigo NUMBER(8) NOT NULL
, fecha_caducidad DATE
, porcentajeDescuento NUMBER(3) CHECK (porcentajeDescuento >0 AND porcentajeDescuento <= 100)
, PRIMARY KEY(codigo));

CREATE SEQUENCE Seq_CodPedidos INCREMENT BY 1 START WITH 1
NOMAXVALUE;

/*DROP TABLE Pedidos;*/
CREATE TABLE Pedidos(
codigo NUMBER(8) NOT NULL
, estado CHAR(9) DEFAULT 'REST' NOT NULL
, fecha_hora_pedido DATE NOT NULL
, fecha_hora_entrega DATE
, importeTotal NUMBER(8,2)
, cliente CHAR(9) NOT NULL REFERENCES Clientes(DNI)
, codigoDescuento Number(8) REFERENCES Descuentos(codigo) ON
DELETE SET NULL
, PRIMARY KEY(codigo)
, CHECK (estado IN ('REST', 'CANCEL', 'RUTA', 'ENTREGADO',
'RECHAZADO'))
);

/*DROP TABLE Contiene;*/
CREATE TABLE Contiene(
restaurante NUMBER(8)
, plato CHAR(20)
, pedido NUMBER(8) REFERENCES Pedidos(codigo) ON DELETE
CASCADE
, precioConComision NUMBER(8,2)
, unidades NUMBER(4)NOT NULL
, PRIMARY KEY(restaurante, plato, pedido)
, FOREIGN KEY(restaurante, plato) REFERENCES
Platos(restaurante, nombre)
);

CREATE INDEX I_CatPlatos ON Platos(categoria);

INSERT INTO Restaurantes (codigo,nombre,calle,codigoPostal,comision) VALUES (1, '0', '0', '0', null);
/*INSERT INTO Contiene VALUES (1234, '0',1,null,2);*/
/*INSERT INTO Descuentos VALUES (1100, to_date('20-04-09'), 50);*/
/*INSERT INTO AreasCobertura VALUES (1,'28000'); */
INSERT INTO Clientes VALUES ('0', '0', '0' , '0', 1,'0','0','0','0','0','0'); 
INSERT INTO Descuentos VALUES (1,null,null); 

DELETE FROM Contiene;
DELETE FROM Pedidos;
DELETE FROM Descuentos;
DELETE FROM Clientes;
DELETE FROM AreasCobertura;
DELETE FROM Horarios;
DELETE FROM Platos;
DELETE FROM Restaurantes;

--Drop table Contiene;
--Drop table Pedidos;
--Drop table Descuentos;
--Drop table Clientes;
--Drop table AreasCobertura;
--Drop table Horarios;
--Drop table Platos;
--drop table registro_ventas;
--Drop table Restaurantes;

commit;