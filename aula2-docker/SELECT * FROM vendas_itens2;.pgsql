SELECT * FROM vendas_itens2;

SELECT
    venda_id,
    ROUND(SUM(quantidade * valor_unitario)::numeric,2) AS total_vendas
FROM
    vendas_itens2
GROUP BY venda_id
ORDER BY total_vendas;

SELECT 
    ROUND(AVG(total_vendas):: numeric,2) AS media_total_vendas
FROM
    (SELECT
        venda_id,
        ROUND(SUM(quantidade * valor_unitario) :: numeric,2) AS total_vendas
    FROM
        vendas_itens2
    GROUP BY venda_id) AS total_vendas;


SELECT
    MIN(total_vendas :: numeric) AS minimo_vendas,
    MAX(total_vendas :: numeric) as maximo_vendas
FROM
    (SELECT
        venda_id,
        ROUND(SUM(quantidade * valor_unitario) :: numeric,2) AS total_vendas
    FROM
        vendas_itens2
    GROUP BY venda_id) AS total_vendas;




SELECT
    venda_id, total_vendas
FROM
    (SELECT
        venda_id,
        ROUND(SUM(quantidade * valor_unitario),2) AS total_vendas
    FROM
        vendas_itens2
    GROUP BY venda_id) as vendas_totais
WHERE
    total_vendas =(
        SELECT
            MIN(total_vendas)
        FROM
            (SELECT
                venda_id,
                ROUND(SUM(quantidade * valor_unitario) :: numeric, 2) AS total_vendas
            FROM
                vendas_itens2
            GROUP BY venda_id) AS venda_minima
    );

SELECT
    produto_id,
    ROUND(produto_total_sub::numeric,2) AS produto_total,
    ROUND(quantidade_total_sub::numeric,2) AS produto_total,
    ROUND(produto_total_sub/NULLIF(quantidade_total_sub,0)::numeric,4) 
    AS valor_medio_por_unidade
FROM
    (
        SELECT
            produto_id,
            SUM(quantidade * valor_unitario) AS produto_total_sub,
            SUM(quantidade) AS quantidade_total_sub
        FROM
            vendas_itens2
        GROUP BY
            produto_id
    ) AS resumo_produto
ORDER BY
    produto_id;
