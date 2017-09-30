/*
Editorial(Nombre, Direcci´on, Tel´efono)
*/
/*DROP TABLE Editorial;*/
CREATE TABLE Editorial (
    nombre varchar(20) not null,
    direccion varchar(20) not null,
    telefono number(9) not null, 
    CONSTRAINT editorial_PK primary key (nombre)
);
/*
Publicacion(ISBN, T´?tulo, Idioma, NEditorial)
(Con clave externa referenciada a Editorial)
*/
/*DROP TABLE Publicacion; */
CREATE TABLE Publicacion(
    isbn number(13) not null,
    titulo varchar(20) not null,
    idioma varchar(20) not null,
    neditorial varchar(20) not null,
    CONSTRAINT publicacion_PK primary key(isbn),
    CONSTRAINT publicacion_FK foreign key (neditorial) references Editorial(nombre) ON DELETE CASCADE
);

/*Biblioteca(Distrito)*/
/*DROP TABLE Biblioteca; */
CREATE TABLE Biblioteca (
    distrito varchar(20) not null,
    CONSTRAINT biblioteca_PK primary key(distrito)
);

/*
Socio(NCarnet, Nombre, DNI, email, Distrito)
(Con clave externa referenciada a Biblioteca)
*/
/*DROP TABLE Socio; */
CREATE TABLE Socio (
    ncarnet number not null,
    nombre varchar(20) not null,
    dni varchar(9) not null,
    email varchar(20) not null,
    distrito varchar(20) not null,
    CONSTRAINT socio_PK primary key (ncarnet),
    CONSTRAINT socio_FK foreign key (distrito) references Biblioteca (distrito) ON DELETE CASCADE
);

/*
Revista(ISBN,Periodo)
(Con clave externa referenciada a Publicaci´on)
*/
/*DROP TABLE Revista; */
CREATE TABLE Revista (
    isbn number(13) not null,
    periodo number not null,
    CONSTRAINT revista_PK primary key (isbn),
    CONSTRAINT revista_FK foreign key (isbn) references Publicacion (isbn) ON DELETE CASCADE
);

/*
Libro(ISBN, Edici´on, Fecha)
(Con clave externa referenciada a Publicaci´on)
*/
/*DROP TABLE Libro; */
CREATE TABLE Libro (
    isbn number(13) not null,
    edicion varchar(20) not null,
    fecha date not null,
    CONSTRAINT libro_PK primary key (isbn),
    CONSTRAINT libro_FK foreign key (isbn) references Publicacion (isbn) ON DELETE CASCADE
);

/*
Tema(IdTema, Descripci´on
*/
/*DROP TABLE Tema; */
CREATE TABLE Tema (
    idtema number not null,
    descripcion varchar(20) not null,
    CONSTRAINT tema_PK primary key (idtema)
);

/*
Clasifica(ISBN, IdTema)
(Con claves externas referenciadas a Publicaci´on y Tema)
*/
/*DROP TABLE Clasifica; */
CREATE TABLE Clasifica (
    isbn number(13) not null,
    idtema number not null,
    CONSTRAINT clasifica_PK primary key (isbn, idtema),
    CONSTRAINT clasifica_FK1 foreign key (isbn) references Publicacion (isbn) ON DELETE CASCADE,
    CONSTRAINT clasifica_FK2 foreign key (idtema) references Tema (idtema) ON DELETE CASCADE
);

/*
Ejemplar_Libro(ISBN, Distrito, N´umero, FechaCompra, NSocio?, FechaP?)
(Con claves externas referenciadas a Libro, Biblioteca y Socio)
*/
/*DROP TABLE Ejemplar_Libro; */
CREATE TABLE Ejemplar_Libro (
    isbn number(13) not null,
    distrito varchar(20) not null,
    numero number not null,
    fechacompra date not null,
    nsocio number,
    fechap date,
    CONSTRAINT ejemplar_libro_PK primary key (isbn, distrito, numero),
    CONSTRAINT ejemplar_libro_FK1 foreign key (isbn) references Libro (isbn) ON DELETE CASCADE,
    CONSTRAINT ejemplar_libro_FK2 foreign key (distrito) references Biblioteca (distrito) ON DELETE CASCADE,
    CONSTRAINT ejemplar_libro_FK3 foreign key (numero) references Socio (ncarnet) ON DELETE CASCADE
);

/*
Suscripcion(ISBN, Distrito, FechaSuscripci´on)
(Con claves externas referenciadas a Revista y Biblioteca)
*/
/*DROP TABLE Suscripcion; */
CREATE TABLE Suscripcion (
    isbn number(13) not null,
    distrito varchar(20) not null,
    fechasuscripcion date not null,
    CONSTRAINT suscripcion_PK primary key (isbn, distrito),
    CONSTRAINT suscripcion_FK1 foreign key (isbn) references Revista (isbn) ON DELETE CASCADE,
    CONSTRAINT suscripcion_FK2 foreign key (distrito) references Biblioteca (distrito) ON DELETE CASCADE
);

/*
Ejemplar_Revista(ISBN, Distrito, N´umero, FechaCompra, NSocio?, FechaP?)
(Con claves externas referenciadas a Libro, Biblioteca y Socio)
*/
/*DROP TABLE Ejemplar_Revista; */
CREATE TABLE Ejemplar_Revista (
    isbn number(13) not null,
    distrito varchar(20) not null,
    numero number not null,
    fechacompra date not null,
    nsocio number,
    fechap date,
    CONSTRAINT ejemplar_revista_PK primary key (isbn, distrito, numero),
    CONSTRAINT ejemplar_revista_FK1 foreign key (isbn) references Libro (isbn) ON DELETE CASCADE,
    CONSTRAINT ejemplar_revista_FK2 foreign key (distrito) references Biblioteca (distrito) ON DELETE CASCADE,
    CONSTRAINT ejemplar_revista_FK3 foreign key (numero) references Socio (ncarnet) ON DELETE CASCADE
);