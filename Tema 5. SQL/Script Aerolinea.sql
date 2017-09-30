drop table vuelo cascade constraints;
drop table avion cascade constraints;
drop table empleado cascade constraints;
drop table certificado cascade constraints;

create table vuelo(
	flno number(4,0) primary key,
	origen varchar2(20),
	destino varchar2(20),
	distancia number(6,0),
	salida date,
	llegada date,
	precio number(7,2));

create table avion(
	aid number(9,0) primary key,
	nombre varchar2(30),
	autonomia number(6,0));

create table empleado(
	eid number(9,0) primary key,
	nombre varchar2(30),
	salario number(10,2));

create table certificado(
	eid number(9,0),
	aid number(9,0),
	primary key(eid,aid),
	foreign key(eid) references empleado,
	foreign key(aid) references avion); 

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (99.0,'Los Angeles','Washington D.C.',2308.0,to_date('04/12/2005 09:30', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 09:40', 'dd/mm/yyyy HH24:MI'),235.98);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (13.0,'Los Angeles','Chicago',1749.0,to_date('04/12/2005 08:45', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 08:45', 'dd/mm/yyyy HH24:MI'),220.98);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (346.0,'Los Angeles','Dallas',1251.0,to_date('04/12/2005 11:50', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 07:05', 'dd/mm/yyyy HH24:MI'),225-43);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (387.0,'Los Angeles','Boston',2606.0,to_date('04/12/2005 07:03', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 05:03', 'dd/mm/yyyy HH24:MI'),261.56);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (7.0,'Los Angeles','Sydney',7487.0,to_date('04/12/2005 05:30', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 11:10', 'dd/mm/yyyy HH24:MI'),278.56);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (2.0,'Los Angeles','Tokyo',5478.0,to_date('04/12/2005 06:30', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 03:55', 'dd/mm/yyyy HH24:MI'),780.99);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (33.0,'Los Angeles','Honolulu',2551.0,to_date('04/12/2005 09:15', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 11:15', 'dd/mm/yyyy HH24:MI'),375.23);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (34.0,'Los Angeles','Honolulu',2551.0,to_date('04/12/2005 12:45', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 03:18', 'dd/mm/yyyy HH24:MI'),425.98);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (76.0,'Chicago','Los Angeles',1749.0,to_date('04/12/2005 08:32', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 10:03', 'dd/mm/yyyy HH24:MI'),220.98);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (68.0,'Chicago','New York',802.0,to_date('04/12/2005 09:00', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 12:02', 'dd/mm/yyyy HH24:MI'),202.45);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (7789.0,'Madison','Detroit',319.0,to_date('04/12/2005 06:15', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 08:19', 'dd/mm/yyyy HH24:MI'),120.33);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (701.0,'Detroit','New York',470.0,to_date('04/12/2005 08:55', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 10:26', 'dd/mm/yyyy HH24:MI'),180.56);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (702.0,'Madison','New York',789.0,to_date('04/12/2005 07:05', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 10:12', 'dd/mm/yyyy HH24:MI'),202.34);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (4884.0,'Madison','Chicago',84.0,to_date('04/12/2005 10:12', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 11:02', 'dd/mm/yyyy HH24:MI'),112.45);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (2223.0,'Madison','Pittsburgh',517.0,to_date('04/12/2005 08:02', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 10:01', 'dd/mm/yyyy HH24:MI'),189.98);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (5694.0,'Madison','Minneapolis',247.0,to_date('04/12/2005 08:32', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 09:33', 'dd/mm/yyyy HH24:MI'),120.11);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (304.0,'Minneapolis','New York',991.0,to_date('04/12/2005 10:00', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 01:39', 'dd/mm/yyyy HH24:MI'),101.56);

INSERT INTO VUELO (FLNO, ORIGEN, DESTINO, DISTANCIA, SALIDA, LLEGADA, PRECIO) VALUES (149.0,'Pittsburgh','New York',303.0,to_date('04/12/2005 09:42', 'dd/mm/yyyy HH24:MI'),to_date('04/12/2005 12:09', 'dd/mm/yyyy HH24:MI'),1165.00);

Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('1','Boeing 747-400','8430');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('2','Boeing 737-800','3383');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('3','Airbus A340-300','7120');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('4','British Aerospace Jetstream 41','1502');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('5','Embraer ERJ-145','1530');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('6','SAAB 340','2128');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('7','Piper Archer III','520');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('8','Tupolev 154','4103');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('16','Schwitzer 2-33','30');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('9','Lockheed L1011','6900');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('10','Boeing 757-300','4010');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('11','Boeing 777-300','6441');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('12','Boeing 767-400ER','6475');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('13','Airbus A320','2605');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('14','Airbus A319','1805');
Insert into AVION (AID,NOMBRE,AUTONOMIA) values ('15','Boeing 727','1504');


Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('242518965','James Smith','120433');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('141582651','Mary Johnson','178345');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('11564812','John Williams','153972');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('567354612','Lisa Walker','256481');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('552455318','Larry West','101745');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('550156548','Karen Scott','205187');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('390487451','Lawrence Sperry','212156');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('274878974','Michael Miller','99890');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('254099823','Patricia Jones','24450');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('356187925','Robert Brown','44740');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('355548984','Angela Martinez','212156');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('310454876','Joseph Thompson','212156');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('489456522','Linda Davis','27984');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('489221823','Richard Jackson','23980');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('548977562','William Ward','84476');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('310454877','Chad Stewart','33546');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('142519864','Betty Adams','227489');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('269734834','George Wright','289950');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('287321212','Michael Miller','48090');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('552455348','Dorthy Lewis','152013');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('248965255','Barbara Wilson','43723');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('159542516','William Moore','48250');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('348121549','Haywood Kelly','32899');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('90873519','Elizabeth Taylor','32021');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('486512566','David Anderson','43001');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('619023588','Jennifer Thomas','54921');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('15645489','Donald King','18050');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('556784565','Mark Young','205187');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('573284895','Eric Cooper','114323');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('574489456','William Jones','105743');
Insert into EMPLEADO (EID,NOMBRE,SALARIO) values ('574489457','Milo Brooks','20');


Insert into CERTIFICADO (EID,AID) values ('11564812','2');
Insert into CERTIFICADO (EID,AID) values ('11564812','10');
Insert into CERTIFICADO (EID,AID) values ('90873519','6');
Insert into CERTIFICADO (EID,AID) values ('141582651','2');
Insert into CERTIFICADO (EID,AID) values ('141582651','10');
Insert into CERTIFICADO (EID,AID) values ('141582651','12');
Insert into CERTIFICADO (EID,AID) values ('142519864','1');
Insert into CERTIFICADO (EID,AID) values ('142519864','2');
Insert into CERTIFICADO (EID,AID) values ('142519864','3');
Insert into CERTIFICADO (EID,AID) values ('142519864','7');
Insert into CERTIFICADO (EID,AID) values ('142519864','10');
Insert into CERTIFICADO (EID,AID) values ('142519864','11');
Insert into CERTIFICADO (EID,AID) values ('142519864','12');
Insert into CERTIFICADO (EID,AID) values ('142519864','13');
Insert into CERTIFICADO (EID,AID) values ('159542516','5');
Insert into CERTIFICADO (EID,AID) values ('159542516','7');
Insert into CERTIFICADO (EID,AID) values ('242518965','2');
Insert into CERTIFICADO (EID,AID) values ('242518965','10');
Insert into CERTIFICADO (EID,AID) values ('269734834','1');
Insert into CERTIFICADO (EID,AID) values ('269734834','2');
Insert into CERTIFICADO (EID,AID) values ('269734834','3');
Insert into CERTIFICADO (EID,AID) values ('269734834','4');
Insert into CERTIFICADO (EID,AID) values ('269734834','5');
Insert into CERTIFICADO (EID,AID) values ('269734834','6');
Insert into CERTIFICADO (EID,AID) values ('269734834','7');
Insert into CERTIFICADO (EID,AID) values ('269734834','8');
Insert into CERTIFICADO (EID,AID) values ('269734834','9');
Insert into CERTIFICADO (EID,AID) values ('269734834','10');
Insert into CERTIFICADO (EID,AID) values ('269734834','11');
Insert into CERTIFICADO (EID,AID) values ('269734834','12');
Insert into CERTIFICADO (EID,AID) values ('269734834','13');
Insert into CERTIFICADO (EID,AID) values ('269734834','14');
Insert into CERTIFICADO (EID,AID) values ('269734834','15');
Insert into CERTIFICADO (EID,AID) values ('274878974','10');
Insert into CERTIFICADO (EID,AID) values ('274878974','12');
Insert into CERTIFICADO (EID,AID) values ('310454876','8');
Insert into CERTIFICADO (EID,AID) values ('310454876','9');
Insert into CERTIFICADO (EID,AID) values ('355548984','8');
Insert into CERTIFICADO (EID,AID) values ('355548984','9');
Insert into CERTIFICADO (EID,AID) values ('356187925','6');
Insert into CERTIFICADO (EID,AID) values ('390487451','3');
Insert into CERTIFICADO (EID,AID) values ('390487451','13');
Insert into CERTIFICADO (EID,AID) values ('390487451','14');
Insert into CERTIFICADO (EID,AID) values ('548977562','7');
Insert into CERTIFICADO (EID,AID) values ('550156548','1');
Insert into CERTIFICADO (EID,AID) values ('550156548','12');
Insert into CERTIFICADO (EID,AID) values ('552455318','2');
Insert into CERTIFICADO (EID,AID) values ('552455318','7');
Insert into CERTIFICADO (EID,AID) values ('552455318','14');
Insert into CERTIFICADO (EID,AID) values ('556784565','2');
Insert into CERTIFICADO (EID,AID) values ('556784565','3');
Insert into CERTIFICADO (EID,AID) values ('556784565','5');
Insert into CERTIFICADO (EID,AID) values ('567354612','1');
Insert into CERTIFICADO (EID,AID) values ('567354612','2');
Insert into CERTIFICADO (EID,AID) values ('567354612','3');
Insert into CERTIFICADO (EID,AID) values ('567354612','4');
Insert into CERTIFICADO (EID,AID) values ('567354612','5');
Insert into CERTIFICADO (EID,AID) values ('567354612','7');
Insert into CERTIFICADO (EID,AID) values ('567354612','9');
Insert into CERTIFICADO (EID,AID) values ('567354612','10');
Insert into CERTIFICADO (EID,AID) values ('567354612','11');
Insert into CERTIFICADO (EID,AID) values ('567354612','12');
Insert into CERTIFICADO (EID,AID) values ('567354612','15');
Insert into CERTIFICADO (EID,AID) values ('573284895','3');
Insert into CERTIFICADO (EID,AID) values ('573284895','4');
Insert into CERTIFICADO (EID,AID) values ('573284895','5');
Insert into CERTIFICADO (EID,AID) values ('574489456','6');
Insert into CERTIFICADO (EID,AID) values ('574489456','8');
Insert into CERTIFICADO (EID,AID) values ('574489457','7');

commit;
