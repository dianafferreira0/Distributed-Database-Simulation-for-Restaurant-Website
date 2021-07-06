USE MASTER
GO

CREATE DATABASE TABD_RISTORANTIS_LOCAL
GO

USE TABD_RISTORANTIS_LOCAL
GO

--Ana Dias al69691
--Diana Alves al68557 
--Diana Ferreira al68938
--Rui Vaz al68565 

--- CRIAR O LINKED SERVER
exec sp_addlinkedserver 
@server='ServerRemoto',
@srvproduct='SQLServer Native Client OLEDB Provider',
@provider='SQLBCLI',
@datasrc='192.168.xxx.xxx'

--- ACESSO AO SERVIDOR REMOTO
exec sp_addlinkedsrvlogin
@rmtsrvname='ServerRemoto',
@useself='false',
@locallogin='sa',
@rmtuser='sa',
@rmtpassword='12345'


CREATE TABLE AdministradorAL(
	ID_Administrador	INTEGER NOT NULL,
	Username			NVARCHAR(10) UNIQUE NOT NULL,
	Password			NVARCHAR(10) NOT NULL,
	Email				NVARCHAR(200) UNIQUE NOT NULL, 
	Nome				NVARCHAR(150) NOT NULL,
	ID_Criador			INTEGER,

	Check(Nome<='L'), 

	PRIMARY KEY (ID_Administrador, Nome)
	--FOREIGN KEY(ID_CRIADOR) REFERENCES Administrador(Id_Administrador)
)

CREATE TABLE UtilizadorAL(
	ID_Utilizador	INTEGER NOT NULL, 
	Nome			NVARCHAR(150) NOT NULL,
	Email			NVARCHAR(200) UNIQUE NOT NULL,
	Username		NVARCHAR(10) UNIQUE NOT NULL,
	Password		NVARCHAR(10) NOT NULL,
	Estado			NVARCHAR(10) DEFAULT 'Registado' NOT NULL,
	Check(Nome<='L'),

	PRIMARY KEY (ID_Utilizador, Nome)
)

CREATE TABLE Cliente(
	ID_Cliente  INTEGER NOT NULL,

	PRIMARY KEY(ID_Cliente)
	--FOREIGN KEY(ID_Cliente) REFERENCES Utilizador(ID_Utilizador)
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

	PRIMARY KEY(ID_Restaurante)
	--FOREIGN KEY (ID_Restaurante) REFERENCES Utilizador(ID_Utilizador)
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
	FOREIGN KEY (ID_Restaurante) REFERENCES Restaurante(ID_Restaurante)
	--FOREIGN KEY (ID_Administrador) REFERENCES Administrador(ID_Administrador),	
)

CREATE TABLE Selecionar_R_Favoritos( 
	ID_Cliente				INTEGER  NOT NULL, 
	ID_Restaurante			INTEGER  NOT NULL,
	Notificacao_R			BIT  DEFAULT 0 NOT NULL,

	PRIMARY KEY(ID_Cliente, ID_Restaurante),
	FOREIGN KEY(ID_Cliente) REFERENCES Cliente(ID_Cliente)
	--FOREIGN KEY (ID_Restaurante) REFERENCES Restaurante(ID_Restaurante)
)

CREATE TABLE Bloquear(
	ID_Bloqueio			INTEGER IDENTITY(1,1),
	Data_Bloquear		DATE DEFAULT GETDATE() NOT NULL, 
	Motivo_Bloqueio		NVARCHAR (100) NOT NULL, 
	Data_Desbloqueio	DATE, --opcional--
	ID_Administrador	INTEGER  NOT NULL,
	ID_Utilizador		INTEGER NOT NULL,

	PRIMARY KEY(ID_Bloqueio)
	--FOREIGN KEY(ID_Administrador) REFERENCES Administrador(ID_Administrador),
	--FOREIGN KEY(ID_Utilizador) REFERENCES Utilizador(ID_Utilizador)
)

USE TABD_RISTORANTIS_LOCAL
GO

CREATE VIEW Utilizador
AS
SELECT * FROM UtilizadorAL
UNION ALL
SELECT * FROM ServerRemoto.TABD_RISTORANTIS_REMOTO.dbo.UtilizadorMZ
GO

CREATE VIEW Administrador
AS
SELECT * FROM AdministradorAL
UNION ALL
SELECT * FROM ServerRemoto.TABD_RISTORANTIS_REMOTO.dbo.AdministradorMZ
GO

CREATE VIEW Tipo_PratoDoDia
AS
SELECT * FROM ServerRemoto.TABD_RISTORANTIS_REMOTO.dbo.Tipo_PratoDoDia
GO

CREATE VIEW Nome_Prato
AS
SELECT * FROM ServerRemoto.TABD_RISTORANTIS_REMOTO.dbo.Nome_Prato
GO

CREATE VIEW Detalhes_Prato
AS
SELECT * FROM ServerRemoto.TABD_RISTORANTIS_REMOTO.dbo.Detalhes_Prato
GO

CREATE VIEW PratoDiario
AS
SELECT * FROM ServerRemoto.TABD_RISTORANTIS_REMOTO.dbo.PratoDiario
GO

CREATE VIEW Selecionar_P_Favoritos
AS
SELECT * FROM ServerRemoto.TABD_RISTORANTIS_REMOTO.dbo.Selecionar_P_Favoritos
GO

SET IMPLICIT_TRANSACTIONS OFF

--- POLÍTICAS DE SEGURANÇA E ACESSO A DADOS
--CRIAÇÃO DE LOGINS
CREATE LOGIN ADMINISTRADOR WITH PASSWORD='12345'
CREATE LOGIN CLIENTE WITH PASSWORD='12345'
CREATE LOGIN RESTAURANTE WITH PASSWORD='12345'
CREATE LOGIN VISITANTE WITH PASSWORD= '12345'

-- CRIAÇÃO DE USERS
USE TABD_RISTORANTIS_LOCAL
GO

exec sp_addlinkedsrvlogin
@rmtsrvname='ServerRemoto',
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



--- ATRIBUIÇÃO DE PERMISSÕES NAS TABELAS
--- PERMISSÕES DOS VISITANTE
USE TABD_RISTORANTIS_LOCAL
GO

GRANT SELECT, INSERT ON Restaurante TO VisitanteRole
GRANT SELECT ON UtilizadorAL(ID_Utilizador, Nome, Email, Estado) TO VisitanteRole
GRANT SELECT, INSERT ON Selecionar_Servico TO VisitanteRole
GRANT SELECT ON Tipo_Servico TO VisitanteRole

GRANT INSERT ON UtilizadorAL TO VisitanteRole
GRANT INSERT ON Cliente TO VisitanteRole
GRANT INSERT ON Pedir_Registo TO VisitanteRole

--- PERMISSÕES DOS CLIENTE
USE TABD_RISTORANTIS_LOCAL
GO

GRANT SELECT ON Cliente TO ClienteRole
GRANT SELECT ON Restaurante TO ClienteRole
GRANT SELECT ON Selecionar_Servico TO ClienteRole
GRANT SELECT ON Tipo_Servico TO ClienteRole
GRANT SELECT ON UtilizadorAL TO ClienteRole
GRANT UPDATE ON UtilizadorAL(ID_Utilizador, Nome, Email, Username, Password) TO ClienteRole
GRANT SELECT ON Bloquear TO ClienteRole
GRANT SELECT, INSERT, UPDATE, DELETE ON Selecionar_R_Favoritos TO ClienteRole

--- PERMISSÕES DOS RESTAURANTE
USE TABD_RISTORANTIS_LOCAL
GO

GRANT SELECT ON UtilizadorAL TO RestauranteRole
GRANT UPDATE ON UtilizadorAL(Nome, Email, Username, Password) TO RestauranteRole
GRANT SELECT, UPDATE ON Restaurante TO RestauranteRole
GRANT SELECT, INSERT, DELETE ON Selecionar_Servico TO RestauranteRole
GRANT SELECT ON Tipo_Servico TO RestauranteRole
GRANT SELECT ON Pedir_Registo TO RestauranteRole
GRANT SELECT ON Bloquear TO RESTAURANTE

--- PERMISSÕES DOS ADMINISTRADOR
USE TABD_RISTORANTIS_LOCAL
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON AdministradorAL TO AdministradorRole
GRANT SELECT, UPDATE ON Pedir_Registo TO AdministradorRole
GRANT SELECT ON Restaurante TO AdministradorRole
GRANT SELECT ON Selecionar_Servico TO AdministradorRole
GRANT SELECT ON Tipo_Servico TO AdministradorRole
GRANT SELECT ON UtilizadorAL TO AdministradorRole
GRANT SELECT, INSERT, UPDATE ON Bloquear TO AdministradorRole
GRANT UPDATE ON UtilizadorAL(Estado) TO AdministradorRole
GRANT SELECT ON Cliente TO AdministradorRole


--PROCEDURES
--VISITANTE
GRANT EXECUTE ON Criar_Utilizador TO VisitanteRole
GRANT EXECUTE ON Criar_Cliente TO VisitanteRole
GRANT EXECUTE ON Criar_Restaurante TO VisitanteRole

--CLIENTE
GRANT EXECUTE ON Alterar_Utilizador TO ClienteRole
GRANT EXECUTE ON Selecionar_R_Favorito TO ClienteRole
GRANT EXECUTE ON Eliminar_Selecionar_R_Favoritos TO ClienteRole
GRANT EXECUTE ON Selecionar_P_Favorito TO ClienteRole
GRANT EXECUTE ON Eliminar_Selecionar_P_Favoritos TO ClienteRole

--ADMINISTRADOR
GRANT EXECUTE ON Novo_Administrador TO AdministradorRole
GRANT EXECUTE ON Alterar_Administrador TO AdministradorRole
GRANT EXECUTE ON Bloquear_Utilizador TO AdministradorRole
GRANT EXECUTE ON Desbloquear_Utilizador TO AdministradorRole
GRANT EXECUTE ON Verificar_Pedido_Registo TO AdministradorRole

--RESTAURANTE
GRANT EXECUTE ON Alterar_Utilizador TO RestauranteRole
GRANT EXECUTE ON Alterar_Restaurante TO RestauranteRole
GRANT EXECUTE ON Registar_Novo_Prato TO RestauranteRole
GRANT EXECUTE ON Criar_Detalhes_PratoDia TO RestauranteRole
GRANT EXECUTE ON Alterar_Detalhes_PratoDia TO RestauranteRole
GRANT EXECUTE ON Apagar_Detalhes_PratoDia TO RestauranteRole
GRANT EXECUTE ON Criar_PratoDiario TO RestauranteRole
GRANT EXECUTE ON Alterar_PratoDiario TO RestauranteRole
GRANT EXECUTE ON Apagar_PratoDiario TO RestauranteRole


--PROCEDURES DOS VISITANTE
USE TABD_RISTORANTIS_LOCAL
GO

CREATE PROCEDURE Criar_Utilizador
	@nome			NVARCHAR(150),
	@email			NVARCHAR(200),
	@username		NVARCHAR(10),
	@password		NVARCHAR(10)
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN DISTRIBUTED TRANSACTION Novo_Utilizador
	IF ( (EXISTS (SELECT * FROM Administrador A WHERE (A.Username=@username))) OR (EXISTS (SELECT * FROM Administrador A WHERE (A.Email=@email))) )
		GOTO ERRO
	ELSE
		INSERT INTO Utilizador(Nome, Email, Username, Password)
		VALUES (@nome, @email, @username, @password)
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT TRANSACTION Novo_Utilizador
RETURN 1

ERRO:
	ROLLBACK TRANSACTION Novo_Utilizador
	RETURN -1
GO

CREATE PROCEDURE Criar_Cliente
	@id_utilizador INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
		IF ((SELECT U.Estado FROM Utilizador U WHERE (U.ID_Utilizador=@id_utilizador)) = 'Registado')
		BEGIN
			INSERT INTO Cliente(ID_Cliente)
			VALUES (@id_utilizador)
			IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
				GOTO ERRO

			UPDATE Utilizador
			SET Estado = 'Ativo'
			WHERE ID_Utilizador=@id_utilizador
			IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
				GOTO ERRO
		END

COMMIT TRANSACTION
RETURN 1

ERRO:
	ROLLBACK TRANSACTION
	RETURN -1
GO

CREATE TYPE ServicoType AS TABLE(ID INTEGER)
GO

CREATE PROCEDURE Criar_Restaurante
	@id_utilizador			INTEGER, 
	@telefone				NVARCHAR(9),
	@localizacao_GPS		NVARCHAR(100), 
	@Codigo_Postal			NVARCHAR(8), 
	@Morada					NVARCHAR(50), 
	@Localidade				NVARCHAR(50), 
	@horario				NVARCHAR(MAX), 
	@fotografia				NVARCHAR(MAX),
	@dia_descanso			NVARCHAR(50),
	@id_servico				ServicoType READONLY
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION Novo_Restaurante
	IF ((SELECT U.Estado FROM Utilizador U WHERE (U.ID_Utilizador=@id_utilizador)) = 'Registado')
		BEGIN
			INSERT INTO Restaurante(ID_Restaurante, Telefone, Localizacao_GPS, 
			Endereco_Codigo_Postal, Endereco_Morada, Endereco_Localidade, Horario, Fotografia, Dia_Descanso)
			VALUES (@id_utilizador, @telefone, @localizacao_GPS, @Codigo_Postal, @Morada, @Localidade,
			@horario, @fotografia, @dia_descanso)

			IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
			GOTO ERRO

			--Variável que guarda o número de serviços que um restaurante tem
			DECLARE @nr_servicos INTEGER
			DECLARE @servico INTEGER
			SET @nr_servicos = (SELECT COUNT(*) FROM @id_servico)

			IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
			GOTO ERRO

			WHILE @nr_servicos > 0 
			BEGIN 
				SET @servico = (SELECT ID FROM (SELECT ROW_NUMBER() OVER (ORDER BY ID ASC) AS RowNum, * FROM @id_servico) T2 WHERE RowNum = @nr_servicos)
				IF (EXISTS (SELECT * FROM Tipo_Servico T WHERE (T.ID_Servico = @servico)))
				BEGIN
					INSERT INTO Selecionar_Servico(ID_Restaurante, ID_Servico)
					VALUES (@id_utilizador, @servico)

					IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
						GOTO ERRO
				END
				SET @nr_servicos = @nr_servicos - 1
			END

			INSERT INTO Pedir_Registo(ID_Restaurante)
			VALUES (@id_utilizador)
		
			IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
			GOTO ERRO

			UPDATE Utilizador
			SET Estado = 'Espera'
			WHERE ID_Utilizador=@id_utilizador

			IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
			GOTO ERRO
		END
	
	COMMIT TRANSACTION Novo_Restaurante
	RETURN 1

ERRO:
	ROLLBACK TRANSACTION Novo_Restaurante
	RETURN -1
GO

--DECLARE @lista ServicoType;
--INSERT @lista VALUES (1),(2)
--EXECUTE Criar_Restaurante '3','123456789','','4960-236','','','','','',@lista
--GO

--PROCEDURES DOS CLIENTE
USE TABD_RISTORANTIS_LOCAL
GO

CREATE PROCEDURE Alterar_Utilizador
	@id				INTEGER,
	@nome			NVARCHAR(150),
	@email			NVARCHAR(200),
	@username		NVARCHAR(10),
	@password		NVARCHAR(10) 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN DISTRIBUTED TRANSACTION
	IF (EXISTS (SELECT * FROM Administrador A WHERE (A.Username=@username)) OR EXISTS (SELECT * FROM Administrador A WHERE (A.Email=@email)) )
		GOTO ERRO
	ELSE
	BEGIN
		UPDATE Utilizador
		SET Nome = @nome, Email = @email, Username = @username, Password = @password 
		WHERE (ID_Utilizador = @id)
	END
				
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO
COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1 
GO

--dá para adicionar na tabela caso ainda nao exista, ou alterar caso já exista
CREATE PROCEDURE Selecionar_R_Favorito
	@id_Cliente				INTEGER, 
	@id_Restaurante			INTEGER,
	@notificacao			BIT
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	IF (EXISTS (SELECT * FROM Selecionar_R_Favoritos R WHERE (R.ID_Cliente=@id_Cliente AND R.ID_Restaurante=@id_Restaurante)))
	BEGIN
		UPDATE Selecionar_R_Favoritos
		SET Notificacao_R=@notificacao
		WHERE (ID_Cliente=@id_Cliente AND ID_Restaurante=@id_Restaurante)
	END
	ELSE
	BEGIN
		IF (EXISTS (SELECT * FROM Cliente C WHERE ( C.ID_Cliente = @id_Cliente)) AND EXISTS (SELECT * FROM Restaurante R WHERE ( R.ID_Restaurante = @id_Restaurante)))
			INSERT INTO Selecionar_R_Favoritos(ID_Cliente,ID_Restaurante, Notificacao_R)
			VALUES (@id_Cliente, @id_Restaurante, @notificacao)
	END
	
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Eliminar_Selecionar_R_Favoritos
	@id_Cliente				INTEGER, 
	@id_Restaurante			INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION 
	IF (EXISTS (SELECT * FROM Selecionar_R_Favoritos R WHERE ( R.ID_Cliente = @id_Cliente AND R.ID_Restaurante = @id_Restaurante)))
		DELETE FROM Selecionar_R_Favoritos
		WHERE (ID_Cliente=@id_Cliente AND ID_Restaurante=@id_Restaurante)
		
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO
COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

--dá para adicionar na tabela caso ainda nao exista, ou alterar caso já exista
CREATE PROCEDURE Selecionar_P_Favorito
	@id_Cliente				INTEGER, 
	@id_Prato				INTEGER,
	@notificacao			BIT
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	IF (EXISTS (SELECT * FROM Selecionar_P_Favoritos P WHERE (P.ID_Cliente=@id_Cliente AND P.ID_Prato=@id_Prato)))
	BEGIN
		UPDATE Selecionar_P_Favoritos
		SET Notificacao_P=@notificacao
		WHERE (ID_Cliente=@id_Cliente AND ID_Prato=@id_Prato)
	END
	ELSE
	BEGIN
		IF (EXISTS (SELECT * FROM Cliente C WHERE ( C.ID_Cliente = @id_Cliente)) AND EXISTS (SELECT * FROM Nome_Prato P WHERE ( P.ID_Prato = @id_Prato)))
			INSERT INTO Selecionar_P_Favoritos(ID_Cliente,ID_Prato, Notificacao_P)
			VALUES (@id_Cliente, @id_Prato, @notificacao)
	END
	
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Eliminar_Selecionar_P_Favoritos
	@id_Cliente				INTEGER, 
	@id_Prato			INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION 
	IF (EXISTS (SELECT * FROM Selecionar_P_Favoritos P WHERE ( P.ID_Cliente = @id_Cliente AND P.ID_Prato = @id_Prato)))
		DELETE FROM Selecionar_P_Favoritos
		WHERE (ID_Cliente=@id_Cliente AND ID_Prato=@id_Prato)

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
	GOTO ERRO
COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

--PROCEDURES DOS ADMINISTRADOR
USE TABD_RISTORANTIS_LOCAL
GO

CREATE PROCEDURE Novo_Administrador
	@username			NVARCHAR(10),
	@password			NVARCHAR(10),
	@email				NVARCHAR(200), 
	@nome				NVARCHAR(150),
	@id_criador			INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN DISTRIBUTED TRANSACTION
	IF (NOT EXISTS (SELECT * FROM Utilizador U WHERE (U.Username=@username)) OR (NOT EXISTS (SELECT * FROM Utilizador U WHERE (U.Email=@email))))
	BEGIN
		INSERT INTO Administrador(Username, Password, Email, Nome, ID_Criador)
		VALUES(@username, @password, @email, @nome, @id_criador)
	END
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
	GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Alterar_Administrador
	@id				INTEGER,
	@username		NVARCHAR(10),
	@password		NVARCHAR(10),
	@email			NVARCHAR(200),
	@nome			NVARCHAR(150)	
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN DISTRIBUTED TRANSACTION
	IF ( NOT EXISTS (SELECT * FROM Utilizador u WHERE (u.Username=@username)) OR ( NOT EXISTS (SELECT * FROM Utilizador u WHERE (u.Email=@email))))
	BEGIN
		UPDATE Administrador
		SET Nome = @nome, Email = @email, Username = @username, Password = @password 
		WHERE (ID_Administrador = @id)
	END
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO
COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Bloquear_Utilizador
	@id_Utilizador		INTEGER,
	@id_Administrador	INTEGER,
	@motivo_Bloqueio	NVARCHAR(100)

AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
		
	INSERT INTO Bloquear(Motivo_Bloqueio, ID_Administrador, ID_Utilizador)
	VALUES(@motivo_Bloqueio, @id_Administrador, @id_Utilizador)

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
	GOTO ERRO

	UPDATE Utilizador
	SET Estado = 'Bloqueado'
	WHERE (ID_Utilizador=@id_Utilizador)

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
	GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Desbloquear_Utilizador
	@id_Bloqueio		INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	IF ((SELECT U.Estado FROM Bloquear B INNER JOIN Utilizador U ON B.ID_Utilizador=U.ID_Utilizador WHERE (B.ID_Bloqueio=@id_Bloqueio))='Bloqueado')
		BEGIN
			UPDATE Bloquear
			SET Data_Desbloqueio= GETDATE()
			WHERE (ID_Bloqueio=@id_Bloqueio)

			IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
			GOTO ERRO

			UPDATE Utilizador
			SET Estado = 'Ativo'
			WHERE (ID_Utilizador=(SELECT U.ID_Utilizador FROM Utilizador U INNER JOIN Bloquear B ON U.ID_Utilizador=B.ID_Utilizador WHERE (B.ID_Bloqueio=@id_Bloqueio)))
		END

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Verificar_Pedido_Registo
	@id_Pedir_Registo		INTEGER,
	@resultado				BIT,
	@motivo_Rejeicao		NVARCHAR(100),
	@id_Administrador		INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	UPDATE Pedir_Registo
	SET Data_Resultado= GETDATE(), Resultado=@resultado, Motivo_Rejeicao=@motivo_Rejeicao, ID_Administrador=@id_Administrador
	WHERE (ID_Pedir_Registo=@id_Pedir_Registo)

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

	UPDATE Utilizador
	SET Estado = 'Ativo'
	WHERE ID_Utilizador = (SELECT P.ID_Restaurante FROM Pedir_Registo P WHERE P.ID_Pedir_Registo=@id_Pedir_Registo)
	
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

--PROCEDURES DOS RESTAURANTE

CREATE PROCEDURE Alterar_Restaurante
	@id_utilizador			INTEGER, 
	@telefone				NVARCHAR(9),
	@localizacao_GPS		NVARCHAR(100), 
	@Codigo_Postal			NVARCHAR(8), 
	@Morada					NVARCHAR(50), 
	@Localidade				NVARCHAR(50), 
	@horario				NVARCHAR(MAX), 
	@fotografia				NVARCHAR(MAX),
	@dia_descanso			NVARCHAR(50),
	@id_servico				ServicoType READONLY
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	UPDATE Restaurante
	SET Telefone = @telefone, Localizacao_GPS = @localizacao_GPS, Endereco_Codigo_Postal = @Codigo_Postal, Endereco_Morada=@Morada, Endereco_Localidade=@Localidade,
	Horario=@horario, Fotografia=@fotografia, Dia_Descanso=@dia_descanso
	WHERE (ID_Restaurante = @id_utilizador)

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO
			   
	--Variável que guarda o número de serviços que um restaurante tem
	DECLARE @nr_servicos INTEGER
	DECLARE @servico INTEGER
	SET @nr_servicos = (SELECT COUNT(*) FROM @id_servico)
	DELETE FROM Selecionar_Servico
	WHERE ID_Restaurante=@id_utilizador

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

	WHILE @nr_servicos > 0 
	BEGIN 
		SET @servico = (SELECT ID FROM (SELECT ROW_NUMBER() OVER (ORDER BY ID ASC) AS RowNum, * FROM @id_servico) T2 WHERE RowNum = @nr_servicos)
		IF (EXISTS (SELECT * FROM Tipo_Servico T WHERE (T.ID_Servico = @servico)))
		BEGIN
			INSERT INTO Selecionar_Servico(ID_Restaurante, ID_Servico)
			VALUES (@id_utilizador, @servico)

			IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
				GOTO ERRO
		END
		SET @nr_servicos = @nr_servicos - 1
	END

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Registar_Novo_Prato
	@nome			NVARCHAR(50), 
	@tipo			INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	IF (EXISTS (SELECT * FROM Tipo_PratoDoDia T WHERE ( T.ID_Tipo_P = @tipo)))
	BEGIN
		INSERT INTO Nome_Prato(Nome, Tipo)
		VALUES (@nome, @tipo)
	END
	ELSE
		GOTO ERRO

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Criar_Detalhes_PratoDia
	@fotografia				NVARCHAR(MAX),
	@descricao				NVARCHAR(50), 
	@preco					MONEY, 
	@id_Nome_Prato			INTEGER,	
	@id_restaurante			INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	IF ( (EXISTS (SELECT * FROM Nome_Prato N WHERE ( N.ID_Prato = @id_Nome_Prato))) 
		AND (EXISTS (SELECT * FROM Restaurante R WHERE (R.ID_Restaurante = @id_restaurante))))
	BEGIN
		INSERT INTO Detalhes_Prato(Fotografia, Descricao, Preco, ID_Nome_Prato, ID_Restaurante)
		VALUES (@fotografia, @descricao, @preco, @id_Nome_Prato, @id_restaurante)
	END

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Alterar_Detalhes_PratoDia
	@id_detalhes			INTEGER,
	@fotografia				NVARCHAR(MAX),
	@descricao				NVARCHAR(50), 
	@preco					MONEY, 
	@id_Nome_Prato			INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	UPDATE Detalhes_Prato
	SET Fotografia=@fotografia, Descricao=@descricao, Preco=@preco, ID_Nome_Prato=@id_Nome_Prato
	WHERE ID_Detalhes=@id_detalhes

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Apagar_Detalhes_PratoDia
	@id_detalhes			INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	DELETE FROM Detalhes_Prato
	WHERE ID_Detalhes=@id_detalhes
	
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Criar_PratoDiario
	@id_restaurante			INTEGER,
	@id_detalhes			INTEGER,
	@data_Disponibilidade	DATE
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	IF ( (EXISTS (SELECT * FROM Detalhes_Prato D WHERE ( D.ID_Detalhes = @id_detalhes))) 
		AND (EXISTS (SELECT * FROM Restaurante R WHERE (R.ID_Restaurante = @id_restaurante))))
	BEGIN
		IF (NOT EXISTS (SELECT * FROM PratoDiario P WHERE ( P.ID_Restaurante = @id_restaurante AND P.ID_DetalhesPrato = @id_detalhes AND P.Data_Disponibilidade = @data_Disponibilidade)))
		BEGIN
			INSERT INTO PratoDiario(ID_Restaurante, ID_DetalhesPrato, Data_Disponibilidade)
			VALUES (@id_restaurante, @id_detalhes, @data_Disponibilidade)
		END
		ELSE
			GOTO ERRO
	END
	ELSE
		GOTO ERRO

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Alterar_PratoDiario
	@id_pratodiario			INTEGER,
	@data_Disponibilidade	DATE
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION

	UPDATE PratoDiario
	SET Data_Disponibilidade=@data_Disponibilidade
	WHERE ID_PratoDiario=@id_pratodiario
	
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

CREATE PROCEDURE Apagar_PratoDiario
	@id_pratodiario			INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ COMMITTED
BEGIN DISTRIBUTED TRANSACTION
	DELETE FROM PratoDiario
	WHERE ID_PratoDiario=@id_pratodiario

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO