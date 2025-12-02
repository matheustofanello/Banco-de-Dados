-----------------------------------------------------------
-- TABELA DE COMBUSTÍVEIS
-----------------------------------------------------------
CREATE TABLE combustivel (
  combustivel_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, 
  -- ID único do combustível, gerado automaticamente
  nome VARCHAR(100) NOT NULL,
  -- Nome do combustível (ex.: Gasolina, Etanol)
  estoque_l NUMERIC(12,3) NOT NULL DEFAULT 0,
  -- Quantidade de litros em estoque, com 3 casas decimais
  -- Se não informado, inicia em 0
  CONSTRAINT combustivel_nome_uniq UNIQUE (nome)
  -- Garante que não haja dois combustíveis com o mesmo nome
);

-----------------------------------------------------------
-- TABELA DE FUNCIONÁRIOS
-----------------------------------------------------------
CREATE TABLE funcionario (
  funcionario_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  -- ID único do funcionário, gerado automaticamente
  nome VARCHAR(150) NOT NULL,
  -- Nome completo do funcionário
  ativo BOOLEAN NOT NULL DEFAULT true
  -- Indica se o funcionário está ativo (true por padrão)
);

-----------------------------------------------------------
-- TABELA DE VENDAS
-----------------------------------------------------------
CREATE TABLE venda (
  venda_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  -- ID único da venda
  data_hora TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Data e hora da venda, preenchida automaticamente com o horário atual
  funcionario_id INT REFERENCES funcionario(funcionario_id) ON DELETE SET NULL,
  -- Referência ao funcionário que realizou a venda
  -- Se o funcionário for deletado, este campo vira NULL
  total NUMERIC(12,2) NOT NULL CHECK (total >= 0)
  -- Total da venda, não permite valores negativos
);

-----------------------------------------------------------
-- TABELA DE ITENS DA VENDA
-----------------------------------------------------------
CREATE TABLE venda_item (
  venda_item_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  -- ID único do item da venda
  venda_id INT NOT NULL REFERENCES venda(venda_id) ON DELETE CASCADE,
  -- Referência à venda correspondente
  -- Se a venda for deletada, todos os itens associados também são deletados
  combustivel_id INT NOT NULL REFERENCES combustivel(combustivel_id),
  -- Combustível vendido neste item
  quantidade_l NUMERIC(12,3) NOT NULL CHECK (quantidade_l >= 0),
  -- Quantidade de litros vendidos, não permite valores negativos
  preco_unitario NUMERIC(12,4) NOT NULL CHECK (preco_unitario >= 0)
  -- Preço por litro, não permite valores negativos
);

-----------------------------------------------------------
-- ÍNDICES PARA ACELERAR CONSULTAS
-----------------------------------------------------------
CREATE INDEX idx_venda_data_hora ON venda (data_hora);
-- Índice para acelerar consultas que filtram por data/hora da venda

CREATE INDEX idx_venda_item_combustivel ON venda_item (combustivel_id);
-- Índice para acelerar consultas que filtram por combustível vendido

-----------------------------------------------------------
-- CONSULTA SIMPLES: LISTAR COMBUSTÍVEIS ORDENADOS POR ESTOQUE
-----------------------------------------------------------
SELECT
  c.combustivel_id,
  c.nome,
  c.estoque_l
FROM combustivel AS c
ORDER BY c.estoque_l DESC;
-- Ordena os combustíveis do maior para o menor estoque

-----------------------------------------------------------
-- INSERÇÃO DE DADOS NAS TABELAS
-----------------------------------------------------------
INSERT INTO combustivel (nome, estoque_l) VALUES
  ('Gasolina', 1200.5),
  ('Etanol',  800.25),
  ('Diesel S10', 1500.0);
-- Insere os combustíveis iniciais no sistema

INSERT INTO funcionario (nome, ativo) VALUES
  ('Ana Silva', true),
  ('José Maria', true);
-- Insere funcionários

INSERT INTO venda (data_hora, funcionario_id, total) VALUES
  ('2025-11-01 09:15:00-03', 1, 210.04),
  ('2025-11-01 10:05:00-03', 2, 150.12),
  ('2025-11-01 11:00:00-03', 1,  50.15),
  ('2025-11-01 11:30:00-03', 1,  80.28),
  ('2025-11-01 11:32:00-03', 2, 110.16),
  ('2025-11-01 12:32:00-03', 2, 217.50);
-- Insere várias vendas com datas, funcionários e total

INSERT INTO venda_item (venda_id, combustivel_id, quantidade_l, preco_unitario) VALUES
  (1, 1, 35.6, 5.9),
  (2, 2, 41.7, 3.6),
  (3, 1,  8.5, 5.9),
  (4, 2, 22.3, 3.6),
  (5, 2, 30.6, 3.6),
  (6, 3, 37.5, 5.8);
-- Insere os itens de cada venda

-----------------------------------------------------------
-- CONSULTA: TOTAL VENDIDO POR FUNCIONÁRIO
-----------------------------------------------------------
SELECT
  f.nome,
  SUM(v.total) as total_funcionario
FROM funcionario f
JOIN venda v ON v.funcionario_id = f.funcionario_id
GROUP BY f.nome;
-- Mostra o total vendido por cada funcionário

-----------------------------------------------------------
-- CONSULTA: TOTAL VENDIDO POR COMBUSTÍVEL
-----------------------------------------------------------
SELECT
  c.combustivel_id,
  c.nome,
  SUM(vi.quantidade_l * vi.preco_unitario) AS total_vendido
FROM combustivel c
JOIN venda_item vi ON vi.combustivel_id = c.combustivel_id
GROUP BY c.combustivel_id, c.nome;
-- Calcula o total arrecadado por tipo de combustível

-----------------------------------------------------------
-- CRIAÇÃO DE UMA VIEW: RESUMO DE VENDAS POR COMBUSTÍVEL
-----------------------------------------------------------
CREATE VIEW resumo_venda_combustivel AS
SELECT
  c.combustivel_id,
  c.nome,
  SUM(vi.quantidade_l) AS litros_vendidos,
  SUM(vi.quantidade_l * vi.preco_unitario) AS valor_vendido
FROM combustivel c
JOIN venda_item vi ON vi.combustivel_id = c.combustivel_id
GROUP BY c.combustivel_id, c.nome;
-- Cria uma visão que mostra o total de litros e valor vendido de cada combustível

-----------------------------------------------------------
-- EXEMPLO DE INNER JOIN (apenas correspondências)
-----------------------------------------------------------
SELECT
  v.venda_id,
  v.data_hora,
  f.nome
FROM venda v
INNER JOIN funcionario f ON v.funcionario_id = f.funcionario_id;
-- INNER JOIN retorna apenas registros que têm correspondência em ambas as tabelas
-- Ou seja, só vendas com funcionário registrado

-----------------------------------------------------------
-- EXEMPLO DE LEFT JOIN (todos os funcionários)
-----------------------------------------------------------
SELECT
  f.nome,
  v.venda_id
FROM funcionario f
LEFT JOIN venda v ON v.funcionario_id = f.funcionario_id;
-- LEFT JOIN retorna todos os funcionários
-- Se o funcionário não tiver vendas, a coluna venda_id será NULL

-----------------------------------------------------------
-- EXEMPLO DE RIGHT JOIN (todos os registros da tabela à direita)
-----------------------------------------------------------
SELECT f.nome, 
       v.venda_id 
FROM funcionario f 
RIGHT JOIN venda v 
    ON v.funcionario_id = f.funcionario_id;
-- RIGHT JOIN retorna todas as vendas
-- Se não houver funcionário correspondente, f.nome será NULL

SELECT v.venda_id, 
       v.data_hora,
       f.nome 
FROM venda v 
RIGHT JOIN funcionario f 
    ON v.funcionario_id = f.funcionario_id;
-- RIGHT JOIN também poderia ser usado para garantir todos os funcionários,
-- mas normalmente usamos LEFT JOIN para a mesma finalidade

