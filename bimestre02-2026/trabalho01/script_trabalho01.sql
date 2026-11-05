-- Limpeza
DROP TABLE IF EXISTS pagamento;
DROP TABLE IF EXISTS item_pedido;
DROP TABLE IF EXISTS pedido;
DROP TABLE IF EXISTS cliente;
DROP TABLE IF EXISTS produto;
DROP TABLE IF EXISTS fabricante;
DROP TABLE IF EXISTS categoria;

-- Tabelas
CREATE TABLE categoria (
    id_categoria  SERIAL       PRIMARY KEY,
    nome          VARCHAR(50)  NOT NULL UNIQUE,
    descricao     VARCHAR(200)
);

CREATE TABLE fabricante (
    id_fabricante  SERIAL       PRIMARY KEY,
    nome           VARCHAR(50)  NOT NULL UNIQUE,
    pais_origem    VARCHAR(40)  NOT NULL,
    site           VARCHAR(100)
);

CREATE TABLE produto (
    id_produto      SERIAL         PRIMARY KEY,
    nome            VARCHAR(100)   NOT NULL,
    id_categoria    INTEGER        NOT NULL REFERENCES categoria(id_categoria),
    id_fabricante   INTEGER        NOT NULL REFERENCES fabricante(id_fabricante),
    preco           NUMERIC(10,2)  NOT NULL CHECK (preco > 0),
    estoque         INTEGER        NOT NULL DEFAULT 0 CHECK (estoque >= 0),
    garantia_meses  INTEGER        NOT NULL DEFAULT 12 CHECK (garantia_meses BETWEEN 3 AND 60),
    ativo           BOOLEAN        NOT NULL DEFAULT TRUE
);

CREATE TABLE cliente (
    id_cliente     SERIAL        PRIMARY KEY,
    nome           VARCHAR(100)  NOT NULL,
    cpf            CHAR(11)      NOT NULL UNIQUE CHECK (cpf ~ '^[0-9]{11}$'),
    email          VARCHAR(100)  NOT NULL UNIQUE CHECK (email LIKE '%@%.%'),
    telefone       VARCHAR(15),
    cidade         VARCHAR(60)   NOT NULL,
    uf             CHAR(2)       NOT NULL,
    data_cadastro  DATE          NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE pedido (
    id_pedido    SERIAL       PRIMARY KEY,
    id_cliente   INTEGER      NOT NULL REFERENCES cliente(id_cliente),
    data_pedido  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    canal        VARCHAR(10)  NOT NULL DEFAULT 'SITE'
                 CHECK (canal IN ('SITE', 'LOJA')),
    status       VARCHAR(15)  NOT NULL DEFAULT 'ABERTO'
                 CHECK (status IN ('ABERTO', 'PAGO', 'ENVIADO', 'ENTREGUE', 'CANCELADO'))
);

CREATE TABLE item_pedido (
    id_item         SERIAL         PRIMARY KEY,
    id_pedido       INTEGER        NOT NULL REFERENCES pedido(id_pedido),
    id_produto      INTEGER        NOT NULL REFERENCES produto(id_produto),
    quantidade      INTEGER        NOT NULL CHECK (quantidade > 0),
    preco_unitario  NUMERIC(10,2)  NOT NULL CHECK (preco_unitario > 0),
    UNIQUE (id_pedido, id_produto)
);

CREATE TABLE pagamento (
    id_pagamento    SERIAL         PRIMARY KEY,
    id_pedido       INTEGER        NOT NULL UNIQUE REFERENCES pedido(id_pedido),
    forma           VARCHAR(10)    NOT NULL CHECK (forma IN ('PIX', 'CREDITO', 'DEBITO', 'BOLETO')),
    valor           NUMERIC(10,2)  NOT NULL CHECK (valor > 0),
    parcelas        INTEGER        NOT NULL DEFAULT 1 CHECK (parcelas BETWEEN 1 AND 12),
    data_pagamento  DATE           NOT NULL DEFAULT CURRENT_DATE
);

-- Dados

INSERT INTO categoria (nome, descricao) VALUES
('Placa de Vídeo', 'GPUs para jogos e renderização'),
('Processador',    'CPUs para desktops'),
('Memória RAM',    'Módulos DDR4 e DDR5'),
('Armazenamento',  'SSDs NVMe, SATA e HDs'),
('Periféricos',    'Teclados, mouses e headsets gamer'),
('Notebook Gamer', 'Notebooks voltados para jogos'),
('Fonte',          'Fontes de alimentação com certificação 80 Plus');

INSERT INTO fabricante (nome, pais_origem, site) VALUES
('NVIDIA',   'Estados Unidos', 'www.nvidia.com'),
('AMD',      'Estados Unidos', 'www.amd.com'),
('Intel',    'Estados Unidos', 'www.intel.com'),
('Corsair',  'Estados Unidos', 'www.corsair.com'),
('Kingston', 'Estados Unidos', 'www.kingston.com'),
('Logitech', 'Suíça',          'www.logitechg.com'),
('ASUS',     'Taiwan',         'www.asus.com'),
('Redragon', 'China',          'www.redragon.com.br');

INSERT INTO produto (nome, id_categoria, id_fabricante, preco, estoque, garantia_meses) VALUES
('GeForce RTX 4060 8GB',          1, 1, 2099.90, 12, 36),
('GeForce RTX 4070 Super 12GB',   1, 1, 4299.90,  5, 36),
('Radeon RX 7600 8GB',            1, 2, 1799.90,  8, 36),
('Ryzen 5 7600',                  2, 2, 1249.90, 15, 36),
('Core i5-14400F',                2, 3, 1099.90, 10, 36),
('Vengeance DDR5 16GB 5200MHz',   3, 4,  449.90, 30, 60),
('Fury Beast DDR4 8GB 3200MHz',   3, 5,  159.90, 40, 60),
('SSD NV2 1TB NVMe',              4, 5,  399.90, 25, 36),
('Mouse G203 Lightsync',          5, 6,  129.90, 50, 24),
('Teclado Kumara K552',           5, 8,  199.90, 20, 12),
('Notebook ROG Strix G16',        6, 7, 9499.00,  3, 12),
('Fonte RM750e 750W 80 Plus Gold',7, 4,  699.90,  9, 60);

INSERT INTO cliente (nome, cpf, email, telefone, cidade, uf, data_cadastro) VALUES
('Lucas Almeida',     '12345678901', 'lucas.almeida@email.com',  '35999990001', 'São Sebastião do Paraíso', 'MG', '2026-01-10'),
('Mariana Souza',     '23456789012', 'mariana.souza@email.com',  '35999990002', 'Passos',                   'MG', '2026-02-05'),
('Pedro Henrique',    '34567890123', 'pedro.h@email.com',        '16999990003', 'Franca',                   'SP', '2026-02-20'),
('Ana Beatriz Lima',  '45678901234', 'ana.lima@email.com',       '16999990004', 'Ribeirão Preto',           'SP', '2026-03-15'),
('Gabriel Costa',     '56789012345', 'gabriel.costa@email.com',  '35999990005', 'São Sebastião do Paraíso', 'MG', '2026-04-01'),
('Juliana Ferreira',  '67890123456', 'ju.ferreira@email.com',    '35999990006', 'Guaxupé',                  'MG', '2026-05-12'),
('Rafael Oliveira',   '78901234567', 'rafael.oli@email.com',     '16999990007', 'Franca',                   'SP', '2026-06-30');

INSERT INTO pedido (id_cliente, data_pedido, canal, status) VALUES
(1, '2026-08-02 14:30', 'LOJA', 'ENTREGUE'),
(2, '2026-08-15 10:10', 'SITE', 'ENTREGUE'),
(3, '2026-09-01 19:45', 'SITE', 'ENVIADO'),
(1, '2026-09-20 16:00', 'SITE', 'PAGO'),
(4, '2026-10-03 11:20', 'LOJA', 'ENTREGUE'),
(5, '2026-10-18 21:05', 'SITE', 'ABERTO'),
(6, '2026-10-25 09:40', 'SITE', 'CANCELADO'),
(7, '2026-11-01 15:15', 'LOJA', 'PAGO');

INSERT INTO item_pedido (id_pedido, id_produto, quantidade, preco_unitario) VALUES
(1, 1, 1, 2099.90),
(1, 4, 1, 1249.90),
(1, 6, 2,  449.90),
(2, 9, 1,  129.90),
(2, 10,1,  199.90),
(3, 2, 1, 4299.90),
(3, 12,1,  699.90),
(4, 8, 2,  399.90),
(5, 11,1, 9499.00),
(5, 9, 1,  129.90),
(6, 3, 1, 1799.90),
(6, 5, 1, 1099.90),
(7, 7, 2,  159.90),
(8, 1, 1, 2049.90);

INSERT INTO pagamento (id_pedido, forma, valor, parcelas, data_pagamento) VALUES
(1, 'CREDITO', 4249.60, 10, '2026-08-02'),
(2, 'PIX',      329.80,  1, '2026-08-15'),
(3, 'CREDITO', 4999.80, 12, '2026-09-01'),
(4, 'PIX',      799.80,  1, '2026-09-20'),
(5, 'CREDITO', 9628.90, 12, '2026-10-03'),
(8, 'DEBITO',  2049.90,  1, '2026-11-01');

-- Consultas

SELECT p.nome AS produto, c.nome AS categoria, f.nome AS fabricante,
       p.preco, p.estoque
FROM produto p
JOIN categoria  c ON c.id_categoria  = p.id_categoria
JOIN fabricante f ON f.id_fabricante = p.id_fabricante
ORDER BY c.nome, p.preco DESC;

SELECT nome, estoque
FROM produto
WHERE estoque < 10 AND ativo = TRUE
ORDER BY estoque;

SELECT pe.id_pedido, cl.nome AS cliente, pe.data_pedido, pe.status,
       SUM(ip.quantidade * ip.preco_unitario) AS total_pedido
FROM pedido pe
JOIN cliente     cl ON cl.id_cliente = pe.id_cliente
JOIN item_pedido ip ON ip.id_pedido  = pe.id_pedido
GROUP BY pe.id_pedido, cl.nome, pe.data_pedido, pe.status
ORDER BY pe.id_pedido;

SELECT c.nome AS categoria,
       SUM(ip.quantidade) AS itens_vendidos,
       SUM(ip.quantidade * ip.preco_unitario) AS faturamento
FROM item_pedido ip
JOIN produto   p  ON p.id_produto   = ip.id_produto
JOIN categoria c  ON c.id_categoria = p.id_categoria
JOIN pedido    pe ON pe.id_pedido   = ip.id_pedido
WHERE pe.status <> 'CANCELADO'
GROUP BY c.nome
ORDER BY faturamento DESC;

SELECT cl.nome, COUNT(DISTINCT pe.id_pedido) AS qtd_pedidos,
       SUM(ip.quantidade * ip.preco_unitario) AS total_gasto
FROM cliente cl
JOIN pedido      pe ON pe.id_cliente = cl.id_cliente
JOIN item_pedido ip ON ip.id_pedido  = pe.id_pedido
WHERE pe.status <> 'CANCELADO'
GROUP BY cl.nome
HAVING SUM(ip.quantidade * ip.preco_unitario) > 1000
ORDER BY total_gasto DESC;

SELECT f.nome AS fabricante, COUNT(p.id_produto) AS qtd_produtos,
       ROUND(AVG(p.preco), 2) AS preco_medio
FROM fabricante f
LEFT JOIN produto p ON p.id_fabricante = f.id_fabricante
GROUP BY f.nome
ORDER BY qtd_produtos DESC;

SELECT forma, COUNT(*) AS qtd_pagamentos, SUM(valor) AS total_recebido
FROM pagamento
GROUP BY forma
ORDER BY total_recebido DESC;

SELECT pe.id_pedido, cl.nome AS cliente, pe.status
FROM pedido pe
JOIN cliente cl ON cl.id_cliente = pe.id_cliente
LEFT JOIN pagamento pg ON pg.id_pedido = pe.id_pedido
WHERE pg.id_pagamento IS NULL;

SELECT cl.uf, pe.canal, COUNT(*) AS qtd_pedidos
FROM cliente cl
JOIN pedido pe ON pe.id_cliente = cl.id_cliente
GROUP BY cl.uf, pe.canal
ORDER BY cl.uf, qtd_pedidos DESC;
