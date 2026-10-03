--1
SELECT COUNT(*) AS MiestuKiekis
FROM dbo.Miestas;

--2
SELECT
    p.planoPavadinimas,
    p.kaina                    AS planoKaina,
    ip.intPlanoPavadinimas     AS internetoPlanas,
    ip.kiekisMB                AS suteiktaMB,
    ip.kaina                   AS internetoPlanoKaina,
    o.operatoriausPavadinimas  AS operatorius
FROM dbo.Planas p
INNER JOIN dbo.InternetoPlanas ip ON ip.internetoPlanoID = p.internetoPlanoID
INNER JOIN dbo.Operatorius o      ON o.operatoriausID = p.operatoriausID
ORDER BY p.planoPavadinimas;

--3
SELECT
    o.operatoriausPavadinimas  AS operatorius,
    x.planoPavadinimas,
    x.kaina
FROM dbo.Operatorius o
LEFT JOIN (
    SELECT DISTINCT p.operatoriausID, p.planoPavadinimas, p.kaina
    FROM dbo.Planas p
    INNER JOIN dbo.PlanoRinkinys pr ON pr.planoID = p.planoID
    INNER JOIN dbo.Lengvata l       ON l.rinkinioID = pr.rinkinioID
    INNER JOIN dbo.Paslauga ps      ON ps.paslaugosID = pr.paslaugosID
    WHERE ps.paslaugosPavadinimas LIKE N'Skambučiai į Lietuvos%'
      AND l.kiekis >= 100
) x ON x.operatoriausID = o.operatoriausID
ORDER BY o.operatoriausPavadinimas, x.planoPavadinimas;

--4
SELECT
    m.miestoPavadinimas       AS miestas,
    COUNT(a.asmensID)         AS naudotojuKiekis
FROM dbo.Miestas m
LEFT JOIN dbo.Asmuo a ON a.miestoID = m.miestoID
GROUP BY m.miestoPavadinimas
ORDER BY naudotojuKiekis DESC;

--5
SELECT m.miestoPavadinimas AS miestas
FROM dbo.Miestas m
WHERE NOT EXISTS (
    SELECT 1
    FROM dbo.Asmuo a
    WHERE a.miestoID = m.miestoID
)
ORDER BY m.miestoPavadinimas;

--6
--1)
SELECT AVG(CAST(x.kiekis AS DECIMAL(10,2))) AS vidutinisNaudotojuKiekis
FROM (
    SELECT a.miestoID, COUNT(*) AS kiekis
    FROM dbo.Asmuo a
    GROUP BY a.miestoID
) x;

--2)
SELECT AVG(CAST(x.kiekis AS DECIMAL(10,2))) AS vidutinisNaudotojuKiekis
FROM (
    SELECT m.miestoID, COUNT(a.asmensID) AS kiekis
    FROM dbo.Miestas m
    LEFT JOIN dbo.Asmuo a ON a.miestoID = m.miestoID
    GROUP BY m.miestoID
) x;


--7
SELECT TOP 1 WITH TIES
    o.operatoriausPavadinimas  AS operatorius,
    COUNT(p.planoID)           AS planuKiekis
FROM dbo.Operatorius o
INNER JOIN dbo.Planas p ON p.operatoriausID = o.operatoriausID
GROUP BY o.operatoriausPavadinimas
ORDER BY COUNT(p.planoID) DESC;

--8
SELECT
    a.vardas,
    a.pavarde,
    p.planoPavadinimas,
    ab.sutartiesPradzia
FROM dbo.Abonentas ab
INNER JOIN dbo.Asmuo a  ON a.asmensID = ab.asmensID
INNER JOIN dbo.Planas p ON p.planoID = ab.planoID
WHERE ab.sutartiesPradzia >= '20130103'
  AND ab.sutartiesPradzia <  '20130111'
ORDER BY ab.sutartiesPradzia;

--9
SELECT
    o.operatoriausPavadinimas            AS operatorius,
    CAST(AVG(p.kaina) AS DECIMAL(10,2))  AS vidutineKaina
FROM dbo.Operatorius o
INNER JOIN dbo.Planas p ON p.operatoriausID = o.operatoriausID
GROUP BY o.operatoriausPavadinimas
ORDER BY vidutineKaina DESC;

--10
SELECT
    o.operatoriausPavadinimas    AS operatorius,
    COUNT(opp.operatoriausID)    AS paslauguKiekis
FROM dbo.Operatorius o
LEFT JOIN dbo.OperatoriausPapildomaPaslauga opp
       ON opp.operatoriausID = o.operatoriausID
GROUP BY o.operatoriausPavadinimas
ORDER BY paslauguKiekis DESC;

