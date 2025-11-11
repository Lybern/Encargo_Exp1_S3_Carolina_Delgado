/*
-- CASO 1: Listado de Clientes con Rango de Renta
Consulta que genera un informe de clientes filtrados por un rango de renta ingresado por el usuario (RENTA_MINIMA, RENTA_MAXIMA).
*/

SELECT
-- 1. RUT Cliente: Formatea el RUT con puntos de miles (G) y guion.
    TO_CHAR(numrut_cli, 'FM999G999G990') || '-' || dvrut_cli AS "RUT Cliente",

-- 2. Nombre Completo: Unir nombre y apellidos.
    nombre_cli || ' ' || appaterno_cli || ' ' || apmaterno_cli AS "Nombre Completo Cliente",

-- 3. Dirección Cliente
    direccion_cli AS "Dirección Cliente",

-- 4. Renta Cliente: Formatea la renta con símbolo de moneda local (L) y separador de miles (G).
    TO_CHAR(renta_cli, '$999G999G990', 'NLS_NUMERIC_CHARACTERS = '',.''' ) AS "Renta Cliente",

-- 5. Celular Cliente: Aplica el formato '0X-XXX-XXXX' visto en la Figura 2.
    '0' || SUBSTR(TO_CHAR(celular_cli), 1, 1) || '-' ||
    SUBSTR(TO_CHAR(celular_cli), 2, 3) || '-' ||
    SUBSTR(TO_CHAR(celular_cli), 5, 4) AS "Celular Cliente",

-- 6. Trama Renta: Clasifica la renta usando CASE según las reglas.
    CASE
        WHEN renta_cli > 500000 THEN 'TRAMO 1'
        WHEN renta_cli BETWEEN 400000 AND 500000 THEN 'TRAMO 2'
        WHEN renta_cli BETWEEN 200000 AND 399999 THEN 'TRAMO 3'
        ELSE 'TRAMO 4'
    END AS "Trama Renta Cliente"
FROM
    cliente
WHERE
-- 7. Filtro 1: Rango de renta paramétrico.
    renta_cli BETWEEN &RENTA_MINIMA AND &RENTA_MAXIMA
-- 8. Filtro 2: Solo clientes con celular registrado.
    AND celular_cli IS NOT NULL
ORDER BY
-- 9. Ordenamiento: Por nombre completo ascendente.
    "Nombre Completo Cliente" ASC;
    
/*
 CASO 2: Sueldo Promedio por Categoría de Empleado
Consulta que genera un informe que agrupa a los empleados por su categoría y sucursal. Calcula el total de empleados y el sueldo promedio para cada uno de estos grupos.
*/

SELECT
    e.id_categoria_emp AS "CODIGO_CATEGORIA",
    ce.desc_categoria_emp AS "DESCRIPCION_CATEGORIA",
    COUNT(e.numrut_emp) AS "CANTIDAD_EMPLEADOS",
    s.desc_sucursal AS "SUCURSAL",
    
-- 4. Formatea el sueldo promedio.
-- Se usa ROUND() para redondear a entero
-- Se usa TO_CHAR con 'FML' (moneda local) y 'G' (separador de miles)
    TO_CHAR(ROUND(AVG(e.sueldo_emp)), 'FML999G999G990', 'NLS_NUMERIC_CHARACTERS = '',.''') AS "SUELDO_PROMEDIO"
FROM
-- 1. Unir las tres tablas necesarias
    empleado e
JOIN
    categoria_empleado ce ON e.id_categoria_emp = ce.id_categoria_emp
JOIN
    sucursal s ON e.id_sucursal = s.id_sucursal
GROUP BY
-- 2. Agrupar por las columnas no agregadas
    e.id_categoria_emp,
    ce.desc_categoria_emp,
    s.desc_sucursal
HAVING
-- 5. Filtrar grupos usando la variable de sustitución.
-- Se filtra sobre el valor numérico, no el formateado.
    AVG(e.sueldo_emp) > &SUELDO_PROMEDIO_MINIMO
ORDER BY
-- 6. Ordenar por el valor numérico descendente, no por el string formateado.
    AVG(e.sueldo_emp) DESC;

    
/*
CASO 3: Arriendo Promedio por Tipo de Propiedad
Consulta que genera un informe que agrupa las propiedades por su tipo,calculando el total, promedios de arriendo y superficie, y el valor promedio de arriendo por metro cuadrado (m2).
*/

SELECT
    p.id_tipo_propiedad AS "CODIGO_TIPO",
    tp.desc_tipo_propiedad AS "DESCRIPCION_TIPO",
    
-- 1. Total de propiedades (conteo)
    COUNT(p.nro_propiedad) AS "TOTAL_PROPIEDADES",
    
-- 2. Promedio de arriendo (formateado)
    TO_CHAR(ROUND(AVG(p.valor_arriendo)), 'FML999G999G990', 'NLS_NUMERIC_CHARACTERS = '',.''') AS "PROMEDIO_ARRIENDO",
    
-- 3. Promedio de superficie (formateado con 2 decimales y coma)
    TO_CHAR(
        ROUND(AVG(p.superficie), 2), 
        'FM999G990D00', 
        'NLS_NUMERIC_CHARACTERS = '',.'''
    ) AS "PROMEDIO_SUPERFICIE",
    
-- 4. Valor promedio arriendo por m2 (calculado y formateado)
    TO_CHAR(
        ROUND(AVG(p.valor_arriendo / p.superficie)), 
        'FML999G990'
    ) AS "VALOR_ARRIENDO_M2",
    
-- 5. Clasificación (usando el valor numérico del promedio m2)
    CASE
        WHEN AVG(p.valor_arriendo / p.superficie) < 5000 THEN 'Económico'
        WHEN AVG(p.valor_arriendo / p.superficie) BETWEEN 5000 AND 10000 THEN 'Medio'
        ELSE 'Alto'
    END AS "CLASIFICACION"
FROM
    propiedad p
JOIN
    tipo_propiedad tp ON p.id_tipo_propiedad = tp.id_tipo_propiedad
GROUP BY
-- Agrupamos por las columnas no agregadas
    p.id_tipo_propiedad,
    tp.desc_tipo_propiedad
HAVING
-- 6. Filtramos los grupos según el requerimiento (valor > 1000)
    AVG(p.valor_arriendo / p.superficie) > 1000
ORDER BY
-- 7. Ordenamos por el valor numérico.
    AVG(p.valor_arriendo / p.superficie) DESC;