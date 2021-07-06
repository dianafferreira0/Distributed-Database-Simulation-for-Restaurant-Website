CREATE DATABASE TABD_RISTORANTIS_REMOTO
GO

--Ana Dias al69691
--Diana Alves al68557 
--Diana Ferreira al68938
--Rui Vaz al68565 

USE TABD_RISTORANTIS_REMOTO
GO

exec sp_addlinkedserver 
@server='ServerLocal',
@srvproduct='SQLServer Native Client OLEDB Provider',
@provider='SQLBCLI',
@datasrc='192.168.xxx.xxx'

--- ACESSO AO SERVIDOR REMOTO
exec sp_addlinkedsrvlogin
@rmtsrvname='ServerLocal',
@useself='false',
@locallogin='sa',
@rmtuser='sa',
@rmtpassword='12345'

---ENTIDADES--- 

CREATE TABLE AdministradorMZ(
	ID_Administrador	INTEGER NOT NULL,
	Username			NVARCHAR(10) UNIQUE NOT NULL,
	Password			NVARCHAR(10) NOT NULL,
	Email				NVARCHAR(200) UNIQUE NOT NULL, 
	Nome				NVARCHAR(150) NOT NULL,
	ID_Criador			INTEGER,
	Check(Nome>='M'),

	PRIMARY KEY (ID_Administrador, Nome)
)

CREATE TABLE UtilizadorMZ(
	ID_Utilizador	INTEGER NOT NULL, 
	Nome			NVARCHAR(150) NOT NULL,
	Email			NVARCHAR(200) UNIQUE NOT NULL,
	Username		NVARCHAR(10) UNIQUE NOT NULL,
	Password		NVARCHAR(10) NOT NULL,
	Estado			NVARCHAR(10) DEFAULT 'Registado' NOT NULL,
	Check(Nome>='M'),

	PRIMARY KEY (ID_Utilizador, Nome)
)

CREATE TABLE Tipo_PratoDoDia(
	ID_Tipo_P		INTEGER IDENTITY(1,1) NOT NULL,
	Nome_tipo_P		NVARCHAR(50) NOT NULL

	PRIMARY KEY (ID_Tipo_P)
)
INSERT INTO Tipo_PratoDoDia
VALUES	('Carne'),
		('Peixe'),
		('Vegan')
GO

CREATE TABLE Nome_Prato(
	ID_Prato				INTEGER IDENTITY(1,1) NOT NULL, 
	Nome					NVARCHAR(50) UNIQUE NOT NULL,
	Tipo					INTEGER NOT NULL,

	PRIMARY KEY (ID_Prato),
	Foreign Key(Tipo) references Tipo_PratoDoDia(ID_Tipo_P)
)

CREATE TABLE Detalhes_Prato (
	ID_Detalhes				INTEGER IDENTITY(1,1) NOT NULL,
	Fotografia				NVARCHAR(MAX),   --opcional--
	Descricao				NVARCHAR(50) NOT NULL, 
	Preco					MONEY NOT NULL,
	ID_Nome_Prato			INTEGER NOT NULL,
	ID_Restaurante			INTEGER NOT NULL

	PRIMARY KEY (ID_Detalhes),
	Foreign Key(ID_Nome_Prato) references Nome_Prato(ID_Prato)
	--Foreign Key(ID_Restaurante) references Restaurante(ID_Restaurante)
)

---RELACIONAMENTOS---
CREATE TABLE PratoDiario (
	ID_PratoDiario			INTEGER IDENTITY(1,1) NOT NULL,
	ID_Restaurante			INTEGER NOT NULL,
	ID_DetalhesPrato		INTEGER NOT NULL,
	Data_Disponibilidade	DATE NOT NULL,	

	PRIMARY KEY (ID_PratoDiario),
	--FOREIGN KEY (ID_Restaurante) REFERENCES Restaurante(ID_Restaurante),
	FOREIGN KEY (ID_DetalhesPrato) REFERENCES Detalhes_Prato(ID_Detalhes) ON DELETE CASCADE,
)

CREATE TABLE Selecionar_P_Favoritos(
	ID_Cliente				INTEGER  NOT NULL, 
	ID_Prato				INTEGER  NOT NULL,
	Notificacao_P			BIT NOT NULL,

	PRIMARY KEY (ID_Cliente, ID_Prato)
	--FOREIGN KEY(ID_Cliente) REFERENCES Cliente(ID_Cliente),
	--FOREIGN KEY(ID_Prato) REFERENCES Nome_Prato(ID_Prato)
)

USE TABD_RISTORANTIS_REMOTO
GO

CREATE VIEW Utilizador
AS
SELECT * FROM UtilizadorMZ
UNION ALL
SELECT * FROM ServerLocal.TABD_RISTORANTIS_LOCAL.dbo.UtilizadorAL
GO

CREATE VIEW Administrador
AS
SELECT * FROM AdministradorMZ
UNION ALL
SELECT * FROM ServerLocal.TABD_RISTORANTIS_LOCAL.dbo.AdministradorAL
GO

CREATE VIEW Cliente
AS
SELECT * FROM ServerLocal.TABD_RISTORANTIS_LOCAL.dbo.Cliente
GO

CREATE VIEW Restaurante
AS
SELECT * FROM ServerLocal.TABD_RISTORANTIS_LOCAL.dbo.Restaurante
GO

CREATE VIEW Tipo_Servico
AS
SELECT * FROM ServerLocal.TABD_RISTORANTIS_LOCAL.dbo.Tipo_Servico
GO

CREATE VIEW Selecionar_Servico
AS
SELECT * FROM ServerLocal.TABD_RISTORANTIS_LOCAL.dbo.Selecionar_Servico
GO

CREATE VIEW Pedir_Registo
AS
SELECT * FROM ServerLocal.TABD_RISTORANTIS_LOCAL.dbo.Pedir_Registo
GO

CREATE VIEW Selecionar_R_Favoritos
AS
SELECT * FROM ServerLocal.TABD_RISTORANTIS_LOCAL.dbo.Selecionar_R_Favoritos
GO

CREATE VIEW Bloquear
AS
SELECT * FROM ServerLocal.TABD_RISTORANTIS_LOCAL.dbo.Bloquear
GO

CREATE LOGIN ADMINISTRADOR WITH PASSWORD='12345'
CREATE LOGIN CLIENTE WITH PASSWORD='12345'
CREATE LOGIN RESTAURANTE WITH PASSWORD='12345'
CREATE LOGIN VISITANTE WITH PASSWORD= '12345'

exec sp_addlinkedsrvlogin
@rmtsrvname='ServerLocal',
@useself='true'

CREATE USER ADMINISTRADOR FOR LOGIN ADMINISTRADOR
CREATE USER CLIENTE FOR LOGIN CLIENTE
CREATE USER RESTAURANTE FOR LOGIN RESTAURANTE
CREATE USER VISITANTE FOR LOGIN VISITANTE

--CRIAÇÃO DE ROLES
CREATE ROLE VisitanteRole
EXECUTE sp_addrolemember 'VisitanteRole', 'VISITANTE'
CREATE ROLE AdministradorRole
EXECUTE sp_addrolemember 'AdministradorRole', 'ADMINISTRADOR'
CREATE ROLE ClienteRole
EXECUTE sp_addrolemember 'ClienteRole', 'CLIENTE'
CREATE ROLE RestauranteRole
EXECUTE sp_addrolemember 'RestauranteRole', 'RESTAURANTE'

USE TABD_RISTORANTIS_REMOTO
GO

GRANT SELECT ON UtilizadorMZ(ID_Utilizador, Nome, Email, Estado) TO VisitanteRole
GRANT SELECT ON Nome_Prato TO VisitanteRole
GRANT SELECT ON Tipo_PratoDoDia TO VisitanteRole
GRANT SELECT ON Detalhes_Prato TO VisitanteRole
GRANT SELECT ON PratoDiario TO VisitanteRole
GRANT INSERT ON UtilizadorMZ TO VisitanteRole


USE TABD_RISTORANTIS_REMOTO
GO

GRANT SELECT ON UtilizadorMZ TO ClienteRole
GRANT UPDATE ON UtilizadorMZ(ID_Utilizador, Nome, Email, Username, Password) TO
ClienteRole
GRANT SELECT ON Nome_Prato TO ClienteRole
GRANT SELECT ON Tipo_PratoDoDia TO ClienteRole
GRANT SELECT ON Detalhes_Prato TO ClienteRole
GRANT SELECT ON PratoDiario TO ClienteRole
GRANT SELECT, INSERT, UPDATE, DELETE ON Selecionar_P_Favoritos TO ClienteRole


--- PERMISSÕES DOS RESTAURANTES
USE TABD_RISTORANTIS_REMOTO
GO
GRANT SELECT ON UtilizadorMZ TO RestauranteRole
GRANT UPDATE ON UtilizadorMZ(Nome, Email, Username, Password) TO RestauranteRole
GRANT SELECT, INSERT ON Nome_Prato TO RestauranteRole
GRANT SELECT ON Tipo_PratoDoDia TO RestauranteRole
GRANT SELECT, INSERT, UPDATE, DELETE ON Detalhes_Prato TO RestauranteRole
GRANT SELECT, INSERT, UPDATE, DELETE ON PratoDiario TO RestauranteRole


--- PERMISSÕES DOS ADMINISTRADORES
USE TABD_RISTORANTIS_REMOTO
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON AdministradorMZ TO AdministradorRole
GRANT SELECT ON UtilizadorMZ TO AdministradorRole
GRANT UPDATE ON UtilizadorMZ(Estado) TO AdministradorRole
