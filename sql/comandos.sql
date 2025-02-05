-- Novo Bairro para endere�o
INSERT INTO brh.endereco (cep, uf, cidade, bairro) VALUES ('11015-003', 'SP', 'Santos', 'Vila Mathias');

-- Novo Colaborador
INSERT INTO brh.colaborador (matricula, nome, cpf, salario, departamento, cep, logradouro, complemento_endereco) 
VALUES ('A124', 'Guilherme', '368.174.850-02', 10000, 'DEPTI', '11015-003', 'Av. Conselheiro N�bias', '309');

-- Novos Telefones: Celular ('M'), Residencial ('R') e Corporativo ('C').
INSERT INTO brh.telefone_colaborador (colaborador, numero, tipo) 
VALUES ('A124', '(13) 97483-7325', 'M');
INSERT INTO brh.telefone_colaborador (colaborador, numero, tipo) 
VALUES ('A124', '(13) 3361-2052', 'R');
INSERT INTO brh.telefone_colaborador (colaborador, numero, tipo) 
VALUES ('A124', '(13) 2105-7764', 'C');

-- Novos E-mails: Particular ('P') e Corporativo ('T').
INSERT INTO brh.email_colaborador (colaborador, email, tipo) 
VALUES ('A124', 'guilherme@email.com', 'P');
INSERT INTO brh.email_colaborador (colaborador, email, tipo) 
VALUES ('A124', 'guilherme@corporativo.com', 'T');

-- Dependentes
INSERT INTO brh.dependente (cpf, colaborador, nome, parentesco, data_nascimento) 
VALUES ('373.554.600-56', 'A124', 'Adelaide', 'Cônjuge', to_date('1991-11-10', 'yyyy-mm-dd'));
INSERT INTO brh.dependente (cpf, colaborador, nome, parentesco, data_nascimento) 
VALUES ('575.362.630-07', 'A124', 'Luiza', 'Filho(a)', to_date('2018-06-02', 'yyyy-mm-dd'));

-- Novo Projeto
INSERT INTO brh.projeto (id, nome, responsavel, inicio, fim) 
VALUES (5, 'BI', 'A124', to_date('2023-09-25', 'yyyy-mm-dd'), null);

-- Papel do Colaborador no Projeto BI
INSERT INTO brh.atribuicao (projeto, colaborador, papel) VALUES (5, 'A124', 1);

-- Relat�rio de C�njuges
SELECT
  C.nome AS "Nome do Colaborador",
  D.nome AS "Nome do C�njuge",
  D.data_nascimento AS "Data de Nascimento do C�njuge"
FROM
  brh.colaborador C
JOIN
  brh.dependente D
ON 
  C.matricula = D.colaborador
WHERE
  D.parentesco = 'Cônjuge'
ORDER BY
  C.nome;
 
-- Filtrar Dependentes
SELECT
  C.nome AS "Nome do Colaborador",
  D.nome AS "Nome do Dependente",
  D.parentesco AS "Parentesco",
  D.data_nascimento AS "Data de Nascimento do Dependente"
FROM
  brh.colaborador C
JOIN
  brh.dependente D
ON 
  C.matricula = D.colaborador
WHERE
  (EXTRACT(MONTH FROM D.data_nascimento) IN (4, 5, 6) OR D.nome LIKE '%h%')
ORDER BY
  D.nome;

-- Listar colaborador com maior sal�rio
SELECT
  nome AS "Nome do Colaborador",
  salario AS "Sal�rio"
FROM
  brh.colaborador
WHERE
  salario = (SELECT MAX(salario) FROM brh.colaborador);

-- Relat�rio de Senioridade
SELECT
    matricula, nome, salario,
    CASE
        WHEN salario <= 3000 THEN 'Junior'
        WHEN salario <= 6000 THEN 'Pleno'
        WHEN salario <= 20000 THEN 'S�nior'
        ELSE 'Corpo Diretor'
    END AS nivel_senioridade
FROM
    brh.colaborador
ORDER BY 
    nivel_senioridade, nome;
    
-- Relat�rio de Contatos
SELECT
    C.nome AS "Nome do Colaborador",
    E.email AS "Email de Trabalho",
    TC.numero AS "Telefone Celular"
FROM
    brh.colaborador C
LEFT JOIN
    brh.email_colaborador E
ON
    C.matricula = E.colaborador
    AND E.tipo = 'T'
LEFT JOIN
    brh.telefone_colaborador TC
ON
    C.matricula = TC.colaborador
    AND TC.tipo = 'M'
ORDER BY
    "Nome do Colaborador";

-- Listar colaboradores com mais dependentes
SELECT
  C.nome AS "Nome do Colaborador",
  COUNT(D.colaborador) AS "Quantidade de Dependentes"
FROM
  brh.colaborador C
LEFT JOIN
  brh.dependente D
ON 
  C.matricula = D.colaborador
GROUP BY
  C.matricula, C.nome
HAVING
  COUNT(D.colaborador) >= 2
ORDER BY
  COUNT(D.colaborador) DESC, "Nome do Colaborador" ASC;

-- Relat�rio de dependentes menores de idade
SELECT
  C.nome AS "Nome do Colaborador",
  D.nome AS "Nome do(a) Filho(a)",
  TRUNC(MONTHS_BETWEEN(SYSDATE, D.data_nascimento) / 12) AS "Idade do(a) Filho(a)"
FROM
  brh.colaborador C
JOIN
  brh.dependente D
ON 
  C.matricula = D.colaborador
WHERE
  TRUNC(MONTHS_BETWEEN(SYSDATE, D.data_nascimento) / 12) < 18
ORDER BY
  C.nome, D.nome;

-- Relat�rio An�litico de Equipes
SELECT
    D.nome AS "Nome do Departamento",
    C1.nome AS "Nome do Chefe do Departamento",
    C2.nome AS "Nome do Colaborador",
    P.nome AS "Nome do Projeto",
    PA.nome AS "Nome do Papel",
    TC.numero AS "N�mero de Telefone",
    DP.nome AS "Nome do Dependente"
FROM
    brh.departamento D
LEFT JOIN
    brh.colaborador C1
ON
    D.chefe = C1.matricula
LEFT JOIN
    brh.colaborador C2
ON
    D.sigla = C2.departamento
LEFT JOIN
    brh.atribuicao A
ON
    C2.matricula = A.colaborador
LEFT JOIN
    brh.projeto P
ON
    A.projeto = P.id
LEFT JOIN
    brh.papel PA
ON
    A.papel = PA.id
LEFT JOIN
    brh.telefone_colaborador TC
ON
    C2.matricula = TC.colaborador
    AND TC.tipo = 'M' 
LEFT JOIN
    brh.dependente DP
ON
    C2.matricula = DP.colaborador
ORDER BY
    "Nome do Projeto", "Nome do Colaborador", "Nome do Dependente";

-- Listar quantidade de colaboradores em projetos
SELECT 
    d.nome AS "Nome do Departamento",
    p.nome AS "Nome do Projeto",
    COUNT(a.colaborador) AS "Quantidade de Colaboradores"
FROM 
    brh.atribuicao a
JOIN 
    brh.projeto p ON a.projeto = p.id
JOIN 
    brh.colaborador c ON a.colaborador = c.matricula
JOIN 
    brh.departamento d ON c.departamento = d.sigla
GROUP BY 
    d.nome, p.nome
ORDER BY 
    d.nome, p.nome;