USE TABD_RISTORANTIS
GO

--Ana Dias al69691
--Diana Alves al68557 
--Diana Ferreira al68938
--Rui Vaz al68565 

SET IMPLICIT_TRANSACTIONS OFF

--- POLÍTICAS DE SEGURANÇA E ACESSO A DADOS
--CRIAÇÃO DE LOGINS
CREATE LOGIN ADMINISTRADOR WITH PASSWORD='12345'
CREATE LOGIN CLIENTE WITH PASSWORD='12345'
CREATE LOGIN RESTAURANTE WITH PASSWORD='12345'

-- CRIAÇÃO DE USERS
USE TABD_RISTORANTIS
GO

CREATE USER ADMINISTRADOR1 FOR LOGIN ADMINISTRADOR
CREATE USER CLIENTE1 FOR LOGIN CLIENTE
CREATE USER RESTAURANTE1 FOR LOGIN RESTAURANTE
CREATE USER VISITANTE1 WITHOUT LOGIN

--CRIAÇÃO DE ROLES
CREATE ROLE ADMINISTRADORES
CREATE ROLE CLIENTES
CREATE ROLE RESTAURANTES
CREATE ROLE VISITANTES
ALTER ROLE ADMINISTRADORES ADD MEMBER ADMINISTRADOR1
ALTER ROLE CLIENTES ADD MEMBER CLIENTE1
ALTER ROLE RESTAURANTES ADD MEMBER RESTAURANTE1
ALTER ROLE VISITANTES ADD MEMBER VISITANTE1

--- ATRIBUIÇÃO DE PERMISSÕES NAS TABELAS
--- PERMISSÕES DOS VISITANTES
USE TABD_RISTORANTIS
GO

GRANT SELECT, INSERT ON Restaurante TO VISITANTES
GRANT SELECT ON Utilizador(ID_Utilizador, Nome, Email, Estado) TO VISITANTES
GRANT SELECT, INSERT ON Selecionar_Servico TO VISITANTES
GRANT SELECT ON Tipo_Servico TO VISITANTES
GRANT SELECT ON Nome_Prato TO VISITANTES
GRANT SELECT ON Tipo_PratoDoDia TO VISITANTES
GRANT SELECT ON Detalhes_Prato TO VISITANTES
GRANT SELECT ON PratoDiario TO VISITANTES

GRANT INSERT ON Utilizador TO VISITANTES
GRANT INSERT ON Cliente TO VISITANTES
GRANT INSERT ON Pedir_Registo TO VISITANTES

--- PERMISSÕES DOS CLIENTES
USE TABD_RISTORANTIS
GO

GRANT SELECT ON Cliente TO CLIENTES
GRANT SELECT ON Restaurante TO CLIENTES
GRANT SELECT ON Selecionar_Servico TO CLIENTES
GRANT SELECT ON Tipo_Servico TO CLIENTES
GRANT SELECT ON Utilizador TO CLIENTES
GRANT UPDATE ON Utilizador(ID_Utilizador, Nome, Email, Username, Password) TO CLIENTES
GRANT SELECT ON Nome_Prato TO CLIENTES
GRANT SELECT ON Tipo_PratoDoDia TO CLIENTES
GRANT SELECT ON Detalhes_Prato TO CLIENTES
GRANT SELECT ON PratoDiario TO CLIENTES
GRANT SELECT ON Bloquear TO CLIENTES
GRANT SELECT, INSERT, UPDATE, DELETE ON Selecionar_R_Favoritos TO CLIENTES
GRANT SELECT, INSERT, UPDATE, DELETE ON Selecionar_P_Favoritos TO CLIENTES

--- PERMISSÕES DOS RESTAURANTES
USE TABD_RISTORANTIS
GO

GRANT SELECT ON Utilizador TO RESTAURANTES
GRANT UPDATE ON Utilizador(Nome, Email, Username, Password) TO RESTAURANTES
GRANT SELECT, UPDATE ON Restaurante TO RESTAURANTES
GRANT SELECT, INSERT, DELETE ON Selecionar_Servico TO RESTAURANTES
GRANT SELECT ON Tipo_Servico TO RESTAURANTES
GRANT SELECT ON Pedir_Registo TO RESTAURANTES
GRANT SELECT, INSERT ON Nome_Prato TO RESTAURANTES
GRANT SELECT ON Tipo_PratoDoDia TO RESTAURANTES
GRANT SELECT, INSERT, UPDATE, DELETE ON Detalhes_Prato TO RESTAURANTES
GRANT SELECT, INSERT, UPDATE, DELETE ON PratoDiario TO RESTAURANTES
GRANT SELECT ON Bloquear TO RESTAURANTES

--- PERMISSÕES DOS ADMINISTRADORES
USE TABD_RISTORANTIS
GO

GRANT SELECT, INSERT, UPDATE, DELETE ON Administrador TO ADMINISTRADORES
GRANT SELECT, UPDATE ON Pedir_Registo TO ADMINISTRADORES
GRANT SELECT ON Restaurante TO ADMINISTRADORES
GRANT SELECT ON Selecionar_Servico TO ADMINISTRADORES
GRANT SELECT ON Tipo_Servico TO ADMINISTRADORES
GRANT SELECT ON Utilizador TO ADMINISTRADORES
GRANT SELECT, INSERT, UPDATE ON Bloquear TO ADMINISTRADORES
GRANT UPDATE ON Utilizador(Estado) TO ADMINISTRADORES
GRANT SELECT ON Cliente TO ADMINISTRADORES


--PROCEDURES
--VISITANTES
GRANT EXECUTE ON Criar_Utilizador TO VISITANTES
GRANT EXECUTE ON Criar_Cliente TO VISITANTES
GRANT EXECUTE ON Criar_Restaurante TO VISITANTES

--CLIENTES
GRANT EXECUTE ON Alterar_Utilizador TO CLIENTES
GRANT EXECUTE ON Selecionar_R_Favorito TO CLIENTES
GRANT EXECUTE ON Eliminar_Selecionar_R_Favoritos TO CLIENTES
GRANT EXECUTE ON Selecionar_P_Favorito TO CLIENTES
GRANT EXECUTE ON Eliminar_Selecionar_P_Favoritos TO CLIENTES

--ADMINISTRADOR
GRANT EXECUTE ON Novo_Administrador TO ADMINISTRADORES
GRANT EXECUTE ON Alterar_Administrador TO ADMINISTRADORES
GRANT EXECUTE ON Bloquear_Utilizador TO ADMINISTRADORES
GRANT EXECUTE ON Desbloquear_Utilizador TO ADMINISTRADORES
GRANT EXECUTE ON Verificar_Pedido_Registo TO ADMINISTRADORES

--RESTAURANTES
GRANT EXECUTE ON Alterar_Utilizador TO RESTAURANTES
GRANT EXECUTE ON Alterar_Restaurante TO RESTAURANTES
GRANT EXECUTE ON Registar_Novo_Prato TO RESTAURANTES
GRANT EXECUTE ON Criar_Detalhes_PratoDia TO RESTAURANTES
GRANT EXECUTE ON Alterar_Detalhes_PratoDia TO RESTAURANTES
GRANT EXECUTE ON Apagar_Detalhes_PratoDia TO RESTAURANTES
GRANT EXECUTE ON Criar_PratoDiario TO RESTAURANTES
GRANT EXECUTE ON Alterar_PratoDiario TO RESTAURANTES
GRANT EXECUTE ON Apagar_PratoDiario TO RESTAURANTES


--PROCEDURES DOS VISITANTES
USE TABD_RISTORANTIS
GO

CREATE PROCEDURE Criar_Utilizador
	@nome			NVARCHAR(150),
	@email			NVARCHAR(200),
	@username		NVARCHAR(10),
	@password		NVARCHAR(10) 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION Novo_Utilizador
	IF ((EXISTS (SELECT * FROM Utilizador U WHERE (U.Username=@username))) OR (EXISTS (SELECT * FROM Administrador A WHERE (A.Username=@username))))
		PRINT 'Username já existente!'
	ELSE IF ((EXISTS (SELECT * FROM Utilizador U WHERE (U.Email=@email))) OR (EXISTS (SELECT * FROM Administrador A WHERE (A.Email=@email))))
		PRINT 'Email já existente!'
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
BEGIN TRANSACTION
	IF (EXISTS (SELECT * FROM Utilizador U WHERE (U.ID_Utilizador=@id_utilizador)))
	BEGIN
		IF ((SELECT U.Estado FROM Utilizador U WHERE (U.ID_Utilizador=@id_utilizador)) = 'Registado')
		BEGIN
			INSERT INTO Cliente(ID_Cliente)
			VALUES (@id_utilizador)

			UPDATE Utilizador
			SET Estado = 'Ativo'
			WHERE ID_Utilizador=@id_utilizador
		END
		ELSE
		BEGIN
			IF (EXISTS (SELECT * FROM Restaurante R WHERE R.ID_Restaurante=@id_utilizador)) 
				PRINT 'Utilizador é restaurante!'
			ELSE IF ((SELECT U.Estado FROM Utilizador U WHERE (U.ID_Utilizador=@id_utilizador)) = 'Ativo')
				PRINT 'Cliente já registado!'
		END
	END
	ELSE
		PRINT 'Utilizador não existe!'
		
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
		GOTO ERRO
COMMIT TRANSACTION
RETURN 1

ERRO:
	ROLLBACK TRANSACTION
	RETURN -1
GO

CREATE TYPE ServicoType AS TABLE(ID INTEGER)
GO

--DECLARE @lista ServicoType;
--INSERT @lista VALUES (1),(2)
--EXECUTE Criar_Restaurante '3','123456789','','4960-236','','','','','',@lista
--GO

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
BEGIN TRANSACTION Novo_Restaurante
	IF (EXISTS (SELECT * FROM Utilizador U WHERE (U.ID_Utilizador=@id_utilizador)))
	BEGIN
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
			WHILE @nr_servicos > 0 
			BEGIN 
				SET @servico = (SELECT ID FROM (SELECT ROW_NUMBER() OVER (ORDER BY ID ASC) AS RowNum, * FROM @id_servico) T2 WHERE RowNum = @nr_servicos)
				IF (EXISTS (SELECT * FROM Tipo_Servico T WHERE (T.ID_Servico = @servico)))
				BEGIN
					INSERT INTO Selecionar_Servico(ID_Restaurante, ID_Servico)
					VALUES (@id_utilizador, @servico)
				END
				ELSE
				BEGIN
					PRINT 'Tipo de serviço não existe!'
				END

				SET @nr_servicos = @nr_servicos - 1
			END

			IF (@@ERROR <> 0)
			GOTO ERRO

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
		ELSE IF ((SELECT U.Estado FROM Utilizador U WHERE (U.ID_Utilizador=@id_utilizador)) = 'Ativo')
		BEGIN
			IF (EXISTS (SELECT * FROM Cliente C WHERE C.ID_Cliente=@id_utilizador)) 
				PRINT 'Utilizador é cliente!'
			ELSE
				PRINT 'Restaurante já registado!'
		END
		ELSE IF ((SELECT U.Estado FROM Utilizador U WHERE (U.ID_Utilizador=@id_utilizador)) = 'Espera')
			PRINT 'Restaurante a aguardar aprovação!'

	END
	ELSE
		PRINT 'Utilizador não existe!'
	
	COMMIT TRANSACTION Novo_Restaurante
	RETURN 1

ERRO:
	ROLLBACK TRANSACTION Novo_Restaurante
	RETURN -1
GO

--PROCEDURES DOS CLIENTES
USE TABD_RISTORANTIS
GO

CREATE PROCEDURE Alterar_Utilizador
	@id				INTEGER,
	@nome			NVARCHAR(150),
	@email			NVARCHAR(200),
	@username		NVARCHAR(10),
	@password		NVARCHAR(10) 
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION
	IF ( NOT EXISTS (SELECT * FROM Utilizador u WHERE (u.ID_Utilizador=@id)))
		PRINT 'ID de Utilizador não existe!'
	ELSE IF ( EXISTS (SELECT * FROM Utilizador u WHERE (u.Username=@username) AND u.ID_Utilizador<>@id ) OR EXISTS (SELECT * FROM Administrador A WHERE (A.Username=@username)))
		PRINT 'Username já existente!'
	ELSE IF ( EXISTS (SELECT * FROM Utilizador u WHERE (u.Email=@email) AND u.ID_Utilizador<>@id ) OR EXISTS (SELECT * FROM Administrador A WHERE (A.Email=@email)))
		PRINT 'Email já existente!'
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
BEGIN TRANSACTION
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
		ELSE
			PRINT 'Não existe nenhum Cliente ou Restaurante com os dados indicados!'
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
BEGIN TRANSACTION 
	IF (EXISTS (SELECT * FROM Selecionar_R_Favoritos R WHERE ( R.ID_Cliente = @id_Cliente AND R.ID_Restaurante = @id_Restaurante)))
		DELETE FROM Selecionar_R_Favoritos
		WHERE (ID_Cliente=@id_Cliente AND ID_Restaurante=@id_Restaurante)
	ELSE
		PRINT 'Não existe nenhum Favorito com os dados indicados!'
	
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
BEGIN TRANSACTION
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
		ELSE
			PRINT 'Não existe nenhum Cliente ou Prato com os dados indicados!'
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
BEGIN TRANSACTION 
	IF (EXISTS (SELECT * FROM Selecionar_P_Favoritos P WHERE ( P.ID_Cliente = @id_Cliente AND P.ID_Prato = @id_Prato)))
		DELETE FROM Selecionar_P_Favoritos
		WHERE (ID_Cliente=@id_Cliente AND ID_Prato=@id_Prato)
	ELSE
		PRINT 'Não existe nenhum Favorito com os dados indicados!'

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
	GOTO ERRO
COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

--PROCEDURES DOS ADMINISTRADOR
USE TABD_RISTORANTIS
GO

CREATE PROCEDURE Novo_Administrador
	@username			NVARCHAR(10),
	@password			NVARCHAR(10),
	@email				NVARCHAR(200), 
	@nome				NVARCHAR(150),
	@id_criador			INTEGER
AS
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
BEGIN TRANSACTION
	IF ((EXISTS (SELECT * FROM Utilizador U WHERE (U.Username=@username))) OR (EXISTS (SELECT * FROM Administrador A WHERE (A.Username=@username))))
		PRINT 'Username já existente!'
	ELSE IF ((EXISTS (SELECT * FROM Utilizador U WHERE (U.Email=@email))) OR (EXISTS (SELECT * FROM Administrador A WHERE (A.Email=@email))))
		PRINT 'Email já existente!'
	ELSE
	BEGIN
		INSERT INTO Administrador(Username, Password, Email, Nome, ID_Criador)
		VALUES(@username, @password, @email, @nome, @id_criador)
	END
	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
	GOTO ERRO

	IF ((NOT EXISTS (SELECT * FROM Administrador A WHERE (A.ID_Administrador=@id_criador))) AND @id_criador <> NULL)
		BEGIN
			PRINT 'Administrador criador não existe!'
			GOTO ERRO
		END
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
BEGIN TRANSACTION
	IF ( NOT EXISTS (SELECT * FROM Administrador A WHERE (A.ID_Administrador=@id)))
		PRINT 'ID de Administrador não existe!'
	ELSE IF ( EXISTS (SELECT * FROM Utilizador u WHERE (u.Username=@username)) OR EXISTS (SELECT * FROM Administrador A WHERE (A.Username=@username) AND A.ID_Administrador<>@id ))
		PRINT 'Username já existente!'
	ELSE IF ( EXISTS (SELECT * FROM Utilizador u WHERE (u.Email=@email)) OR EXISTS (SELECT * FROM Administrador A WHERE (A.Email=@email) AND A.ID_Administrador<>@id ))
		PRINT 'Email já existente!'
	ELSE
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
BEGIN TRANSACTION
	IF (NOT EXISTS (SELECT * FROM Utilizador U WHERE (U.ID_Utilizador=@id_Utilizador)))
		PRINT 'Username não existe!'
	ELSE IF (NOT EXISTS (SELECT * FROM Administrador A WHERE (A.ID_Administrador=@id_Administrador)))
		PRINT 'Administrador não existe!'
	ELSE
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
BEGIN TRANSACTION
	IF (EXISTS (SELECT * FROM Bloquear B INNER JOIN Utilizador U ON B.ID_Utilizador=U.ID_Utilizador WHERE (B.ID_Bloqueio=@id_Bloqueio)))
	BEGIN
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

			IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
			GOTO ERRO
		END
		ELSE
			PRINT 'Utilizador não está bloqueado!'
	END
	ELSE
		PRINT 'ID de Bloqueio incorreto!'

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
BEGIN TRANSACTION
	IF (EXISTS (SELECT * FROM Pedir_Registo P WHERE (P.ID_Pedir_Registo=@id_Pedir_Registo)))
	BEGIN
		IF (EXISTS (SELECT * FROM Administrador A WHERE (A.ID_Administrador=@id_Administrador)))
		BEGIN
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
		END
		ELSE
			PRINT 'Administrador não existe!'
	END
	ELSE
		PRINT 'Pedido de Registo não existe!'

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO

--PROCEDURES DOS RESTAURANTES

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
BEGIN TRANSACTION
	IF (EXISTS (SELECT * FROM Restaurante R WHERE ( R.ID_Restaurante = @id_utilizador)))
	BEGIN
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
			ELSE
			BEGIN
				PRINT 'Tipo de serviço não existe!'
			END
		SET @nr_servicos = @nr_servicos - 1
		END

		IF (@@ERROR <> 0)
			GOTO ERRO
		
	END
	ELSE
		PRINT 'Restaurante não existe!'
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
BEGIN TRANSACTION
	IF (EXISTS (SELECT * FROM Tipo_PratoDoDia T WHERE ( T.ID_Tipo_P = @tipo)))
	BEGIN
		IF (NOT EXISTS (SELECT * FROM Nome_Prato N WHERE ( N.Nome = @nome)))
		BEGIN
			INSERT INTO Nome_Prato(Nome, Tipo)
			VALUES (@nome, @tipo)
		END
		ELSE
			PRINT 'Prato já existe!'
	END
	ELSE
		PRINT 'Tipo de prato não existe!'

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
BEGIN TRANSACTION
	IF ( (EXISTS (SELECT * FROM Nome_Prato N WHERE ( N.ID_Prato = @id_Nome_Prato))) 
		AND (EXISTS (SELECT * FROM Restaurante R WHERE (R.ID_Restaurante = @id_restaurante))))
	BEGIN
		INSERT INTO Detalhes_Prato(Fotografia, Descricao, Preco, ID_Nome_Prato, ID_Restaurante)
		VALUES (@fotografia, @descricao, @preco, @id_Nome_Prato, @id_restaurante)
	END
	ELSE
		PRINT 'Não existe nenhum restaurante ou nome de prato com os dados indicados!'

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
BEGIN TRANSACTION
	IF (EXISTS (SELECT * FROM Detalhes_Prato D WHERE (D.ID_Detalhes = @id_detalhes)))
	BEGIN
		IF (EXISTS (SELECT * FROM Nome_Prato N WHERE ( N.ID_Prato = @id_Nome_Prato)))
		BEGIN
			UPDATE Detalhes_Prato
			SET Fotografia=@fotografia, Descricao=@descricao, Preco=@preco, ID_Nome_Prato=@id_Nome_Prato
			WHERE ID_Detalhes=@id_detalhes
		END
		ELSE
			PRINT 'Não existe nenhum nome de prato com o ID indicado!'
	END
	ELSE
		PRINT 'Não existe nenhum prato com o ID indicado!'

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
BEGIN TRANSACTION
	IF (EXISTS (SELECT * FROM Detalhes_Prato D WHERE ( D.ID_Detalhes = @id_detalhes)))
	BEGIN
		DELETE FROM Detalhes_Prato
		WHERE ID_Detalhes=@id_detalhes
	END
	ELSE
			PRINT 'Não existe nenhum prato com os dados indicados!'

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
BEGIN TRANSACTION
	IF ( (EXISTS (SELECT * FROM Detalhes_Prato D WHERE ( D.ID_Detalhes = @id_detalhes))) 
		AND (EXISTS (SELECT * FROM Restaurante R WHERE (R.ID_Restaurante = @id_restaurante))))
	BEGIN
		IF (NOT EXISTS (SELECT * FROM PratoDiario P WHERE ( P.ID_Restaurante = @id_restaurante AND P.ID_DetalhesPrato = @id_detalhes AND P.Data_Disponibilidade = @data_Disponibilidade)))
		BEGIN
			INSERT INTO PratoDiario(ID_Restaurante, ID_DetalhesPrato, Data_Disponibilidade)
			VALUES (@id_restaurante, @id_detalhes, @data_Disponibilidade)
		END
		ELSE
			PRINT 'Prato já existe no dia indicado!'
	END
	ELSE
			PRINT 'Não existe nenhum restaurante ou prato com os dados indicados!'

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
BEGIN TRANSACTION
	IF (EXISTS (SELECT * FROM PratoDiario P WHERE ( P.ID_PratoDiario = @id_pratodiario)))
	BEGIN
		UPDATE PratoDiario
			SET Data_Disponibilidade=@data_Disponibilidade
			WHERE ID_PratoDiario=@id_pratodiario
	END
	ELSE
		PRINT 'Não existe nenhum prato diário com o ID indicado!'

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
BEGIN TRANSACTION
	IF (EXISTS (SELECT * FROM PratoDiario P WHERE ( P.ID_PratoDiario = @id_pratodiario)))
	BEGIN
		DELETE FROM PratoDiario
		WHERE ID_PratoDiario=@id_pratodiario
	END
	ELSE
		PRINT 'Não existe nenhum prato diário com o ID indicado!'

	IF (@@ERROR <> 0) OR (@@ROWCOUNT = 0)
	GOTO ERRO

COMMIT
RETURN 1

ERRO:
	ROLLBACK
	RETURN -1
GO