--1
SELECT
    pp.papildomosPaslaugosPavadinimas AS paslauga, 
    opp.kaina
FROM dbo.OperatoriausPapildomaPaslauga opp
INNER JOIN dbo.Operatorius o        ON o.operatoriausID = opp.operatoriausID
INNER JOIN dbo.PapildomaPaslauga pp ON pp.papildomosPaslaugosID = opp.papildomosPaslaugosID
WHERE o.operatoriausPavadinimas = N'Tele2'
ORDER BY opp.kaina;

