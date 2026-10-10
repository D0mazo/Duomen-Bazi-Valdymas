--1
SELECT
    pp.papildomosPaslaugosPavadinimas AS paslauga, 
    opp.kaina
FROM dbo.OperatoriausPapildomaPaslauga opp
INNER JOIN dbo.Operatorius o        ON o.operatoriausID = opp.operatoriausID
INNER JOIN dbo.PapildomaPaslauga pp ON pp.papildomosPaslaugosID = opp.papildomosPaslaugosID
WHERE o.operatoriausPavadinimas = N'Tele2'
ORDER BY opp.kaina;

--2
SELECT
    o.operatoriausPavadinimas         AS operatorius,
    pp.papildomosPaslaugosPavadinimas AS paslauga,
    opp.kaina
FROM dbo.OperatoriausPapildomaPaslauga opp
INNER JOIN dbo.Operatorius o        ON o.operatoriausID = opp.operatoriausID
INNER JOIN dbo.PapildomaPaslauga pp ON pp.papildomosPaslaugosID = opp.papildomosPaslaugosID
WHERE opp.papildomosPaslaugosID IN (
    SELECT papildomosPaslaugosID
    FROM dbo.OperatoriausPapildomaPaslauga
    GROUP BY papildomosPaslaugosID
    HAVING COUNT(DISTINCT operatoriausID) = (SELECT COUNT(*) FROM dbo.Operatorius)
)
ORDER BY paslauga, operatorius;


-- 3. Valstybių skaičius kiekvienoje zonoje
SELECT
    z.zonosPavadinimas  AS zona,
    COUNT(s.saliesKodas) AS valstybiuSkaicius
FROM dbo.Zona z
LEFT JOIN dbo.Salis s ON s.zonosID = z.zonosID
GROUP BY z.zonosPavadinimas
ORDER BY valstybiuSkaicius DESC;


-- 4. Brangiausi skambučiai į Meksiką
SELECT TOP 1 WITH TIES
    o.operatoriausPavadinimas AS operatorius,
    pkz.kaina                 AS kainaUzMin
FROM dbo.PaslaugosKainaZonoje pkz
INNER JOIN dbo.Operatorius o ON o.operatoriausID = pkz.operatoriausID
INNER JOIN dbo.Salis s       ON s.zonosID = pkz.zonosID
WHERE pkz.paslaugosID = 4                        
  AND s.saliesPavadinimas = N'Meksika'
ORDER BY pkz.kaina DESC;


-- 5. Pigiausias 1 MB interneto plane
SELECT TOP 1 WITH TIES
    o.operatoriausPavadinimas AS operatorius,
    ip.intPlanoPavadinimas    AS internetoPlanas,
    CAST(ip.kaina / ip.kiekisMB AS DECIMAL(10,4)) AS kaina1MB
FROM dbo.InternetoPlanas ip
INNER JOIN dbo.Operatorius o ON o.operatoriausID = ip.operatoriausID
WHERE NOT EXISTS (SELECT 1 FROM dbo.Planas p
                  WHERE p.internetoPlanoID = ip.internetoPlanoID)
  AND ip.kiekisMB > 0
ORDER BY ip.kaina / ip.kiekisMB;


-- 6. Abonentų pasiskirstymas tarp operatorių (%)
SELECT
    o.operatoriausPavadinimas AS operatorius,
    COUNT(*) AS abonentai,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(5,2)) AS procentai
FROM dbo.Abonentas ab
INNER JOIN dbo.Planas p      ON p.planoID = ab.planoID
INNER JOIN dbo.Operatorius o ON o.operatoriausID = p.operatoriausID
GROUP BY o.operatoriausPavadinimas
ORDER BY procentai DESC;


-- 7. TOP 3 populiariausi planai
SELECT TOP 3 WITH TIES
    p.planoPavadinimas,
    COUNT(*) AS abonentuKiekis
FROM dbo.Abonentas ab
INNER JOIN dbo.Planas p ON p.planoID = ab.planoID
GROUP BY p.planoID, p.planoPavadinimas
ORDER BY abonentuKiekis DESC;


-- 8. 10 atsitiktinių abonentų
SELECT TOP 10
    a.vardas + N' ' + a.pavarde AS pilnasVardas,
    m.miestoPavadinimas         AS miestas,
    ab.numeris,
    ab.sutartiesPradzia,
    ab.sutartiesPabaiga,
    o.operatoriausPavadinimas   AS operatorius,
    p.planoPavadinimas,
    CASE WHEN EXISTS (SELECT 1 FROM dbo.UzsakytasInternetoPlanas u
                      WHERE u.abonentoID = ab.abonentoID)
         THEN N'Taip' ELSE N'Ne' END AS papildomasInternetas,
    CASE WHEN EXISTS (SELECT 1 FROM dbo.UzsakytaPapildomaPaslauga up
                      WHERE up.abonentoID = ab.abonentoID)
         THEN N'Taip' ELSE N'Ne' END AS papildomosPaslaugos
FROM dbo.Abonentas ab
INNER JOIN dbo.Asmuo a       ON a.asmensID = ab.asmensID
LEFT JOIN  dbo.Miestas m     ON m.miestoID = a.miestoID
INNER JOIN dbo.Planas p      ON p.planoID = ab.planoID
INNER JOIN dbo.Operatorius o ON o.operatoriausID = p.operatoriausID
ORDER BY NEWID();


-- 9. TOP 5 abonentai pagal skambučius Lietuvoje 2015 m. spalį ???? tik 2025 neebent ? 
SELECT TOP 5 WITH TIES
    a.vardas + N' ' + a.pavarde AS pilnasVardas,
    ab.numeris,
    COUNT(*) AS skambuciuKiekis
FROM dbo.RysysP2P r
INNER JOIN dbo.Abonentas ab ON ab.abonentoID = r.abonentoID
INNER JOIN dbo.Asmuo a      ON a.asmensID = ab.asmensID
WHERE r.paslaugosID = 1                      
  AND r.rysioInicializavimoVieta IS NULL     
  AND r.rysioPradzia >= '20251001'
  AND r.rysioPradzia <  '20251101'
GROUP BY a.vardas, a.pavarde, ab.numeris
ORDER BY skambuciuKiekis DESC;

-- 10. Populiariausia užsienio šalis pagal skambučius
SELECT TOP 1 WITH TIES
    s.saliesPavadinimas AS salis,
    COUNT(*)            AS skambuciuKiekis
FROM dbo.RysysP2P r
INNER JOIN dbo.Salis s ON s.saliesKodas = r.adresatoSalis
WHERE r.paslaugosID = 4                           
GROUP BY s.saliesPavadinimas
ORDER BY skambuciuKiekis DESC;
