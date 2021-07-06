USE MASTER
GO

CREATE DATABASE TABD_RISTORANTIS
GO
--Ana Dias al69691
--Diana Alves al68557 
--Diana Ferreira al68938
--Rui Vaz al68565 

USE TABD_RISTORANTIS
GO

---ENTIDADES--- 

CREATE TABLE Administrador(
	ID_Administrador	INTEGER IDENTITY (1,1) NOT NULL,
	Username			NVARCHAR(10) NOT NULL,
	Password			NVARCHAR(10) NOT NULL,
	Email				NVARCHAR(200) NOT NULL, 
	Nome				NVARCHAR(150) NOT NULL,
	ID_Criador			INTEGER,

	PRIMARY KEY (ID_Administrador),
	FOREIGN KEY(ID_CRIADOR) REFERENCES Administrador(Id_Administrador)
)

CREATE TABLE Utilizador(
	ID_Utilizador	INTEGER IDENTITY(1,1) NOT NULL, 
	Nome			NVARCHAR(150) NOT NULL,
	Email			NVARCHAR(200) NOT NULL,
	Username		NVARCHAR(10) NOT NULL,
	Password		NVARCHAR(10) NOT NULL,
	Estado			NVARCHAR(10) DEFAULT 'Registado' NOT NULL,  

	PRIMARY KEY (ID_Utilizador)
)

CREATE TABLE Cliente(
	ID_Cliente  INTEGER NOT NULL,

	PRIMARY KEY(ID_Cliente),
	FOREIGN KEY(ID_Cliente) REFERENCES Utilizador(ID_Utilizador)
)

CREATE TABLE Restaurante(
	ID_Restaurante			INTEGER NOT NULL, 
	Telefone				NVARCHAR(9) NOT NULL,
	Localizacao_GPS			NVARCHAR(100) NOT NULL, 
	Endereco_Codigo_Postal  NVARCHAR(8) NOT NULL, 
	Endereco_Morada			NVARCHAR(50) NOT NULL, 
	Endereco_Localidade		NVARCHAR(50) NOT NULL, 
	Horario					NVARCHAR(MAX) NOT NULL, 
	Fotografia				NVARCHAR(MAX) NOT NULL,
	Dia_Descanso			NVARCHAR(50) NOT NULL,

	CHECK(Telefone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CHECK(Endereco_Codigo_Postal LIKE '[0-9][0-9][0-9][0-9]-[0-9][0-9][0-9]'),

	PRIMARY KEY(ID_Restaurante),
	FOREIGN KEY (ID_Restaurante) REFERENCES Utilizador(ID_Utilizador)
)

CREATE TABLE Tipo_Servico(
	ID_Servico		INTEGER IDENTITY(1,1) NOT NULL,
	Nome_Tipo_S		NVARCHAR(50) NOT NULL,

	PRIMARY KEY(ID_Servico)
)
INSERT INTO Tipo_Servico
VALUES	('Local'),
		('Take-Away'),
		('Entrega')
GO

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
	Nome					NVARCHAR(50) NOT NULL,
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
	Foreign Key(ID_Nome_Prato) references Nome_Prato(ID_Prato),
	Foreign Key(ID_Restaurante) references Restaurante(ID_Restaurante)
)

---RELACIONAMENTOS---
CREATE TABLE PratoDiario (
	ID_PratoDiario			INTEGER IDENTITY(1,1) NOT NULL,
	ID_Restaurante			INTEGER NOT NULL,
	ID_DetalhesPrato		INTEGER NOT NULL,
	Data_Disponibilidade	DATE NOT NULL,	

	PRIMARY KEY (ID_PratoDiario),
	FOREIGN KEY (ID_Restaurante) REFERENCES Restaurante(ID_Restaurante),
	FOREIGN KEY (ID_DetalhesPrato) REFERENCES Detalhes_Prato(ID_Detalhes) ON DELETE CASCADE,
)

CREATE TABLE Selecionar_Servico(
	ID_Servico		INTEGER  NOT NULL, 
	ID_Restaurante  INTEGER  NOT NULL,

	PRIMARY KEY(ID_Servico,ID_Restaurante),
	FOREIGN KEY(ID_Servico) REFERENCES Tipo_Servico(ID_Servico),
	FOREIGN KEY(ID_Restaurante) REFERENCES Restaurante(ID_Restaurante)
) 

CREATE TABLE Pedir_Registo (
	ID_Pedir_Registo		INTEGER IDENTITY(1,1) NOT NULL,
	Data_Pedido				DATE DEFAULT GETDATE() NOT NULL, 
	Data_Resultado			DATE,
	Resultado				BIT, --ou é aceite ou nao
	Motivo_Rejeicao			NVARCHAR(100), --opcional--
	ID_Restaurante			INTEGER NOT NULL, 
	ID_Administrador		INTEGER,

	PRIMARY KEY (ID_Pedir_Registo),
	FOREIGN KEY (ID_Restaurante) REFERENCES Restaurante(ID_Restaurante),
	FOREIGN KEY (ID_Administrador) REFERENCES Administrador(ID_Administrador),	
)

CREATE TABLE Selecionar_R_Favoritos( 
	ID_Cliente				INTEGER  NOT NULL, 
	ID_Restaurante			INTEGER  NOT NULL,
	Notificacao_R			BIT  DEFAULT 0 NOT NULL,

	PRIMARY KEY(ID_Cliente, ID_Restaurante),
	FOREIGN KEY(ID_Cliente) REFERENCES Cliente(ID_Cliente),
	FOREIGN KEY (ID_Restaurante) REFERENCES Restaurante(ID_Restaurante)
)

CREATE TABLE Selecionar_P_Favoritos(
	ID_Cliente				INTEGER  NOT NULL, 
	ID_Prato				INTEGER  NOT NULL,
	Notificacao_P			BIT NOT NULL,

	PRIMARY KEY (ID_Cliente, ID_Prato),
	FOREIGN KEY(ID_Cliente) REFERENCES Cliente(ID_Cliente),
	FOREIGN KEY(ID_Prato) REFERENCES Nome_Prato(ID_Prato)
)

CREATE TABLE Bloquear(
	ID_Bloqueio			INTEGER IDENTITY(1,1),
	Data_Bloquear		DATE DEFAULT GETDATE() NOT NULL, 
	Motivo_Bloqueio		NVARCHAR (100) NOT NULL, 
	Data_Desbloqueio	DATE, --opcional--
	ID_Administrador	INTEGER  NOT NULL,
	ID_Utilizador		INTEGER NOT NULL,

	PRIMARY KEY(ID_Bloqueio),
	FOREIGN KEY(ID_Administrador) REFERENCES Administrador(ID_Administrador),
	FOREIGN KEY(ID_Utilizador) REFERENCES Utilizador(ID_Utilizador)
)
