-- ============================================================
-- PetHealthAPI — Script de criação do banco (Oracle)
-- Challenge FIAP 2026 — DevOps Tools & Cloud Computing
-- ============================================================

-- ------------------------------------------------------------
-- TABELA: TB_PH_TUTOR
-- Donos dos pets cadastrados na plataforma
-- ------------------------------------------------------------
CREATE TABLE TB_PH_TUTOR (
    ID_TUTOR      NUMBER          NOT NULL,
    NM_TUTOR      VARCHAR2(100)   NOT NULL,
    DS_EMAIL      VARCHAR2(150)   NOT NULL,
    NR_TELEFONE   VARCHAR2(20)    NOT NULL,
    DS_ENDERECO   VARCHAR2(200),
    DT_CADASTRO   DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT PK_TB_PH_TUTOR PRIMARY KEY (ID_TUTOR),
    CONSTRAINT UQ_TB_PH_TUTOR_EMAIL UNIQUE (DS_EMAIL)
);

COMMENT ON TABLE TB_PH_TUTOR IS 'Tutores (donos) responsaveis pelos pets cadastrados na plataforma Pet Health';
COMMENT ON COLUMN TB_PH_TUTOR.ID_TUTOR IS 'Identificador unico do tutor';
COMMENT ON COLUMN TB_PH_TUTOR.NM_TUTOR IS 'Nome completo do tutor';
COMMENT ON COLUMN TB_PH_TUTOR.DS_EMAIL IS 'Email do tutor, unico no sistema';
COMMENT ON COLUMN TB_PH_TUTOR.NR_TELEFONE IS 'Telefone de contato do tutor';
COMMENT ON COLUMN TB_PH_TUTOR.DS_ENDERECO IS 'Endereco residencial do tutor';
COMMENT ON COLUMN TB_PH_TUTOR.DT_CADASTRO IS 'Data em que o tutor foi cadastrado na plataforma';

CREATE SEQUENCE SEQ_TB_PH_TUTOR START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER TRG_TB_PH_TUTOR
BEFORE INSERT ON TB_PH_TUTOR
FOR EACH ROW
WHEN (NEW.ID_TUTOR IS NULL)
BEGIN
    SELECT SEQ_TB_PH_TUTOR.NEXTVAL INTO :NEW.ID_TUTOR FROM DUAL;
END;

-- ------------------------------------------------------------
-- TABELA: TB_PH_PET
-- Pets cadastrados, vinculados a um tutor
-- ------------------------------------------------------------
CREATE TABLE TB_PH_PET (
    ID_PET          NUMBER          NOT NULL,
    NM_PET          VARCHAR2(100)   NOT NULL,
    DS_ESPECIE      VARCHAR2(50)    NOT NULL,
    DS_RACA         VARCHAR2(80),
    NR_IDADE        NUMBER(3),
    NR_PESO         NUMBER(6,2),
    DS_SEXO         VARCHAR2(10),
    FL_CASTRADO     NUMBER(1)       DEFAULT 0 NOT NULL,
    DS_ALERGIAS     VARCHAR2(300),
    DT_NASCIMENTO   DATE,
    DT_CADASTRO     DATE            DEFAULT SYSDATE NOT NULL,
    ID_TUTOR        NUMBER          NOT NULL,
    CONSTRAINT PK_TB_PH_PET PRIMARY KEY (ID_PET),
    CONSTRAINT FK_PET_TUTOR FOREIGN KEY (ID_TUTOR)
        REFERENCES TB_PH_TUTOR (ID_TUTOR) ON DELETE CASCADE,
    CONSTRAINT CK_PET_CASTRADO CHECK (FL_CASTRADO IN (0,1))
);

COMMENT ON TABLE TB_PH_PET IS 'Pets cadastrados na plataforma, vinculados a um tutor';
COMMENT ON COLUMN TB_PH_PET.ID_PET IS 'Identificador unico do pet';
COMMENT ON COLUMN TB_PH_PET.NM_PET IS 'Nome do pet';
COMMENT ON COLUMN TB_PH_PET.DS_ESPECIE IS 'Especie do pet (ex: Cao, Gato)';
COMMENT ON COLUMN TB_PH_PET.DS_RACA IS 'Raca do pet';
COMMENT ON COLUMN TB_PH_PET.NR_IDADE IS 'Idade do pet em anos (0 a 30)';
COMMENT ON COLUMN TB_PH_PET.NR_PESO IS 'Peso do pet em kg (0.1 a 200)';
COMMENT ON COLUMN TB_PH_PET.DS_SEXO IS 'Sexo do pet';
COMMENT ON COLUMN TB_PH_PET.FL_CASTRADO IS 'Indica se o pet e castrado (1) ou nao (0)';
COMMENT ON COLUMN TB_PH_PET.DS_ALERGIAS IS 'Alergias conhecidas do pet';
COMMENT ON COLUMN TB_PH_PET.DT_NASCIMENTO IS 'Data de nascimento do pet';
COMMENT ON COLUMN TB_PH_PET.DT_CADASTRO IS 'Data de cadastro do pet na plataforma';
COMMENT ON COLUMN TB_PH_PET.ID_TUTOR IS 'Chave estrangeira para o tutor responsavel (TB_PH_TUTOR)';

CREATE SEQUENCE SEQ_TB_PH_PET START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER TRG_TB_PH_PET
BEFORE INSERT ON TB_PH_PET
FOR EACH ROW
WHEN (NEW.ID_PET IS NULL)
BEGIN
    SELECT SEQ_TB_PH_PET.NEXTVAL INTO :NEW.ID_PET FROM DUAL;
END;

-- ------------------------------------------------------------
-- TABELA: TB_PH_VACINA
-- Carteira de vacinacao digital dos pets
-- ------------------------------------------------------------
CREATE TABLE TB_PH_VACINA (
    ID_VACINA           NUMBER          NOT NULL,
    NM_VACINA           VARCHAR2(150)   NOT NULL,
    DT_APLICACAO        DATE            NOT NULL,
    DT_PROXIMA_DOSE     DATE,
    NM_FABRICANTE       VARCHAR2(100),
    NR_LOTE             VARCHAR2(80),
    NM_VETERINARIO      VARCHAR2(150),
    DS_OBSERVACOES      VARCHAR2(300),
    ID_PET              NUMBER          NOT NULL,
    CONSTRAINT PK_TB_PH_VACINA PRIMARY KEY (ID_VACINA),
    CONSTRAINT FK_VACINA_PET FOREIGN KEY (ID_PET)
        REFERENCES TB_PH_PET (ID_PET) ON DELETE CASCADE
);

COMMENT ON TABLE TB_PH_VACINA IS 'Registro de vacinas aplicadas nos pets';
COMMENT ON COLUMN TB_PH_VACINA.ID_VACINA IS 'Identificador unico do registro de vacina';
COMMENT ON COLUMN TB_PH_VACINA.NM_VACINA IS 'Nome da vacina aplicada';
COMMENT ON COLUMN TB_PH_VACINA.DT_APLICACAO IS 'Data em que a vacina foi aplicada';
COMMENT ON COLUMN TB_PH_VACINA.DT_PROXIMA_DOSE IS 'Data prevista para a proxima dose';
COMMENT ON COLUMN TB_PH_VACINA.NM_FABRICANTE IS 'Fabricante da vacina';
COMMENT ON COLUMN TB_PH_VACINA.NR_LOTE IS 'Numero do lote da vacina';
COMMENT ON COLUMN TB_PH_VACINA.NM_VETERINARIO IS 'Veterinario responsavel pela aplicacao';
COMMENT ON COLUMN TB_PH_VACINA.DS_OBSERVACOES IS 'Observacoes adicionais sobre a aplicacao';
COMMENT ON COLUMN TB_PH_VACINA.ID_PET IS 'Chave estrangeira para o pet vacinado (TB_PH_PET)';

CREATE SEQUENCE SEQ_TB_PH_VACINA START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER TRG_TB_PH_VACINA
BEFORE INSERT ON TB_PH_VACINA
FOR EACH ROW
WHEN (NEW.ID_VACINA IS NULL)
BEGIN
    SELECT SEQ_TB_PH_VACINA.NEXTVAL INTO :NEW.ID_VACINA FROM DUAL;
END;

-- ------------------------------------------------------------
-- TABELA: TB_PH_CONSULTA
-- Historico clinico — consultas veterinarias dos pets
-- ------------------------------------------------------------
CREATE TABLE TB_PH_CONSULTA (
    ID_CONSULTA       NUMBER          NOT NULL,
    DT_CONSULTA       DATE            NOT NULL,
    DS_MOTIVO         VARCHAR2(200)   NOT NULL,
    NM_VETERINARIO    VARCHAR2(150),
    NM_CLINICA        VARCHAR2(150),
    DS_DIAGNOSTICO    VARCHAR2(500),
    DS_TRATAMENTO     VARCHAR2(500),
    VL_CUSTO          NUMBER(10,2),
    DT_RETORNO        DATE,
    DS_OBSERVACOES    VARCHAR2(300),
    ID_PET            NUMBER          NOT NULL,
    CONSTRAINT PK_TB_PH_CONSULTA PRIMARY KEY (ID_CONSULTA),
    CONSTRAINT FK_CONSULTA_PET FOREIGN KEY (ID_PET)
        REFERENCES TB_PH_PET (ID_PET) ON DELETE CASCADE
);

COMMENT ON TABLE TB_PH_CONSULTA IS 'Historico de consultas veterinarias realizadas pelos pets';
COMMENT ON COLUMN TB_PH_CONSULTA.ID_CONSULTA IS 'Identificador unico da consulta';
COMMENT ON COLUMN TB_PH_CONSULTA.DT_CONSULTA IS 'Data em que a consulta foi realizada';
COMMENT ON COLUMN TB_PH_CONSULTA.DS_MOTIVO IS 'Motivo da consulta';
COMMENT ON COLUMN TB_PH_CONSULTA.NM_VETERINARIO IS 'Veterinario que realizou o atendimento';
COMMENT ON COLUMN TB_PH_CONSULTA.NM_CLINICA IS 'Clinica onde a consulta foi realizada';
COMMENT ON COLUMN TB_PH_CONSULTA.DS_DIAGNOSTICO IS 'Diagnostico dado pelo veterinario';
COMMENT ON COLUMN TB_PH_CONSULTA.DS_TRATAMENTO IS 'Tratamento prescrito';
COMMENT ON COLUMN TB_PH_CONSULTA.VL_CUSTO IS 'Custo da consulta';
COMMENT ON COLUMN TB_PH_CONSULTA.DT_RETORNO IS 'Data agendada para retorno, se houver';
COMMENT ON COLUMN TB_PH_CONSULTA.DS_OBSERVACOES IS 'Observacoes adicionais sobre a consulta';
COMMENT ON COLUMN TB_PH_CONSULTA.ID_PET IS 'Chave estrangeira para o pet atendido (TB_PH_PET)';

CREATE SEQUENCE SEQ_TB_PH_CONSULTA START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER TRG_TB_PH_CONSULTA
BEFORE INSERT ON TB_PH_CONSULTA
FOR EACH ROW
WHEN (NEW.ID_CONSULTA IS NULL)
BEGIN
    SELECT SEQ_TB_PH_CONSULTA.NEXTVAL INTO :NEW.ID_CONSULTA FROM DUAL;
END;

-- ------------------------------------------------------------
-- TABELA: TB_PH_MEDICAMENTO
-- Registro e controle de medicamentos dos pets
-- ------------------------------------------------------------
CREATE TABLE TB_PH_MEDICAMENTO (
    ID_MEDICAMENTO              NUMBER          NOT NULL,
    NM_MEDICAMENTO               VARCHAR2(150)   NOT NULL,
    DS_DOSAGEM                   VARCHAR2(100)   NOT NULL,
    DS_FREQUENCIA                VARCHAR2(100)   NOT NULL,
    DT_INICIO                    DATE            NOT NULL,
    DT_FIM                       DATE,
    NM_VETERINARIO_PRESCREVEU    VARCHAR2(150),
    FL_ATIVO                     NUMBER(1)       DEFAULT 1 NOT NULL,
    DS_OBSERVACOES               VARCHAR2(300),
    ID_PET                       NUMBER          NOT NULL,
    CONSTRAINT PK_TB_PH_MEDICAMENTO PRIMARY KEY (ID_MEDICAMENTO),
    CONSTRAINT FK_MEDICAMENTO_PET FOREIGN KEY (ID_PET)
        REFERENCES TB_PH_PET (ID_PET) ON DELETE CASCADE,
    CONSTRAINT CK_MEDICAMENTO_ATIVO CHECK (FL_ATIVO IN (0,1))
);

COMMENT ON TABLE TB_PH_MEDICAMENTO IS 'Medicamentos prescritos e em uso pelos pets';
COMMENT ON COLUMN TB_PH_MEDICAMENTO.ID_MEDICAMENTO IS 'Identificador unico do medicamento prescrito';
COMMENT ON COLUMN TB_PH_MEDICAMENTO.NM_MEDICAMENTO IS 'Nome do medicamento';
COMMENT ON COLUMN TB_PH_MEDICAMENTO.DS_DOSAGEM IS 'Dosagem prescrita';
COMMENT ON COLUMN TB_PH_MEDICAMENTO.DS_FREQUENCIA IS 'Frequencia de administracao';
COMMENT ON COLUMN TB_PH_MEDICAMENTO.DT_INICIO IS 'Data de inicio do tratamento';
COMMENT ON COLUMN TB_PH_MEDICAMENTO.DT_FIM IS 'Data prevista para o fim do tratamento';
COMMENT ON COLUMN TB_PH_MEDICAMENTO.NM_VETERINARIO_PRESCREVEU IS 'Veterinario que prescreveu o medicamento';
COMMENT ON COLUMN TB_PH_MEDICAMENTO.FL_ATIVO IS 'Indica se o medicamento esta em uso (1) ou nao (0)';
COMMENT ON COLUMN TB_PH_MEDICAMENTO.DS_OBSERVACOES IS 'Observacoes adicionais sobre o medicamento';
COMMENT ON COLUMN TB_PH_MEDICAMENTO.ID_PET IS 'Chave estrangeira para o pet medicado (TB_PH_PET)';

CREATE SEQUENCE SEQ_TB_PH_MEDICAMENTO START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE OR REPLACE TRIGGER TRG_TB_PH_MEDICAMENTO
BEFORE INSERT ON TB_PH_MEDICAMENTO
FOR EACH ROW
WHEN (NEW.ID_MEDICAMENTO IS NULL)
BEGIN
    SELECT SEQ_TB_PH_MEDICAMENTO.NEXTVAL INTO :NEW.ID_MEDICAMENTO FROM DUAL;
END;