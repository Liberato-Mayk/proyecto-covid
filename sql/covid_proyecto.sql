SELECT COUNT(*) FROM paises;
SELECT * FROM paises LIMIT 5;
SELECT COUNT(*) FILTER (WHERE "Letalidad" IS NULL) AS letalidad_nulos FROM paises;

SELECT column_name
FROM information_schema.columns
WHERE table_name = 'paises';

/*datos del peru*/
SELECT *
FROM paises
WHERE "Pais" = 'Peru';

/*confirmados por pais*/
SELECT "Pais", "Confirmados"
FROM paises
ORDER BY "Confirmados" DESC
LIMIT 10;

/*condirmados y muertos por paises americanos*/
SELECT "Pais", "Confirmados", "Muertes"
FROM paises
WHERE "Region_OMS" = 'Americas' AND "Confirmados" > 100000
ORDER BY "Confirmados" DESC;

/*datos por continentes*/
SELECT "Region_OMS",
       COUNT(*) AS paises,
       SUM("Confirmados") AS total_casos,
       SUM("Muertes") AS total_muertes,
       SUM("Recuperados") AS total_recuperados,
       ROUND(SUM("Muertes") * 100.0 / SUM("Confirmados"), 2) AS letalidad_pct
FROM paises
GROUP BY "Region_OMS"
ORDER BY total_casos DESC;

/*regiones con mas de 1000000 de casos*/
SELECT "Region_OMS", SUM("Confirmados") AS total_casos
FROM paises
GROUP BY "Region_OMS"
HAVING SUM("Confirmados") > 1000000;

/*cantidad de paises pro niver de crecimiento*/
SELECT "Nivel_crecimiento", COUNT(*) AS cantidad
FROM paises
GROUP BY "Nivel_crecimiento"
ORDER BY cantidad DESC;

/*promedio de la letalidad*/
SELECT "Tamano_brote",
        ROUND(AVG("Letalidad")::NUMERIC, 2) AS letalidad_promedio
FROM paises
GROUP BY "Tamano_brote"
ORDER BY letalidad_promedio DESC;

/*promedio de letalidad por pais*/
SELECT "Pais", ROUND("Letalidad"::NUMERIC, 2) AS "Letalidad"
FROM paises
WHERE "Confirmados" > 1000
  AND "Letalidad" > (SELECT AVG("Letalidad") FROM paises WHERE "Confirmados" > 1000)
ORDER BY "Letalidad" DESC;

/*ranking de los paises dentro de la region*/
SELECT "Region_OMS", "Pais", "Confirmados",
       RANK() OVER (PARTITION BY "Region_OMS" 
	   ORDER BY "Confirmados" DESC) AS ranking_region
FROM paises;

/*top 3 por cada region*/
WITH ranking AS
(SELECT "Region_OMS", "Pais", "Confirmados",
           ROW_NUMBER() OVER (PARTITION BY "Region_OMS" 
		   ORDER BY "Confirmados" DESC) AS posicion
FROM paises)
SELECT "Region_OMS", "Pais", "Confirmados", posicion
FROM ranking
WHERE posicion <= 3
ORDER BY "Region_OMS", posicion;

/*porcentaje de cada pais, y de region*/
SELECT "Region_OMS", "Pais", "Confirmados",
       ROUND("Confirmados" * 100.0 / SUM("Confirmados") 
	   OVER (PARTITION BY "Region_OMS"), 2) AS pct_en_region
FROM paises
ORDER BY "Region_OMS", pct_en_region DESC;

/*peru conparado con la region*/
SELECT p."Pais",
       p."Letalidad",
       ROUND(AVG(r."Letalidad")::NUMERIC, 2) AS letalidad_promedio_region,
       ROUND((p."Letalidad" - AVG(r."Letalidad"))::NUMERIC, 2) AS diferencia
FROM paises p
JOIN paises r ON r."Region_OMS" = p."Region_OMS"
WHERE p."Pais" = 'Peru'
GROUP BY p."Pais", p."Letalidad";

/*paises con crecimiento alto y pocos recuperados*/
SELECT "Pais", "Aumento_pct_1_semana", "Tasa_recuperacion"
FROM paises
WHERE "Nivel_crecimiento" = 'Alto' AND "Tasa_recuperacion" < 50
ORDER BY "Aumento_pct_1_semana" DESC;

