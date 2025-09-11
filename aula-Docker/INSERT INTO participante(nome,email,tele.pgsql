INSERT INTO participante(nome,email,telefone) VALUES
('Arthur Roque', 'tofab@unipam.edu.br', '39218739218'),
('Tofa pai', 'tofa2@unipam.edu.br', '392118739218'),
('Tofa filho', 'tofa3@unipam.edu.br', '3921187392218');


INSERT INTO evento(nome,descricao,local,data) VALUES
('Tofa atleticano', 'Festa na arena meu rival vence', 'Arena MRV', '2025-08-23'),
('Tofa palmeirense', 'festinha', 'alianz park', '2024-06-07');

INSERT INTO inscricao(id_evento, id_participante, data_inscricao, status) VALUES
(1,1,'2025-09-10', 'confirmada');

INSERT INTO pagamento(id_inscricao, valor, data_pagamento,status) VALUES
(1,150.00,'2025-09-10', 'pago');