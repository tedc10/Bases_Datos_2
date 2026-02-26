Ejercicios base de datos 2. 

1:  

-- Cuantos empleados han pasado por más de un cargo en la compañía 

-- Columnas necesarias: Nombre empleado, apellido empleado, cantidad trabajos  

  

SELECT E.FIRST_NAME, E.LAST_NAME, H.EMPLOYEE_ID, COUNT(*) AS cantidad 

FROM HR.JOB_HISTORY H JOIN HR.EMPLOYEES E 

ON H.EMPLOYEE_ID = E.EMPLOYEE_ID 

GROUP BY 

E.FIRST_NAME, E.LAST_NAME, H.EMPLOYEE_ID 

HAVING COUNT (*) > 1; 

 

2: 

--Identifique todos los empleados que vivan o trabajen en Europa y tengan rango entre un salario entre 4 mil dólares y 6 mil dólares. 

-- Columnas necesarias: Nombre y apellidos una solo columna, País al que pertenece, Salario que tiene 

 

SELECT CONCAT (E.FIRST_NAME, ' ', E.LAST_NAME) AS NAME, C.COUNTRY_NAME AS COUNTRY, E.SALARY 

FROM 

HR.EMPLOYEES E JOIN HR.DEPARTMENTS D 

ON E.DEPARTMENT_ID = D.DEPARTMENT_ID 

JOIN HR.LOCATIONS L 

ON L.LOCATION_ID = D.LOCATION_ID 

JOIN HR.COUNTRIES C 

ON L.COUNTRY_ID = C.COUNTRY_ID 

JOIN HR.REGIONS R 

ON C.REGION_ID = R.REGION_ID 

WHERE R.REGION_ID = 10 AND E.SALARY BETWEEN 4000 AND 6000 

 

3:  

-- Proyectar en orden jerárquico de los cargos de los empleados, mostrar el nombre del empelado y sus jefes 

-- empleado, jefe, extraer emails de los dos (Las primeras 3 letras, luego rellenar 6 asteriscos a la izquierda)  

 

SELECT 

    E.FIRST_NAME || ' ' || E.LAST_NAME AS EMPLEADO, 

    '******' || SUBSTR(E.EMAIL, 1, 3) AS EMAIL_EMPLEADO, 

 

    M.FIRST_NAME || ' ' || M.LAST_NAME AS JEFE, 

    '******' || SUBSTR(M.EMAIL, 1, 3) AS EMAIL_JEFE 

 

FROM HR.EMPLOYEES E 

LEFT JOIN HR.EMPLOYEES M  

    ON E.MANAGER_ID = M.EMPLOYEE_ID 

ORDER BY E.LAST_NAME; 

 

4: 

-- = ESTO ES PARA COPIAR LA TABLA  

 CREATE TABLE EMPLOYEES_2 AS SELECT * FROM HR.EMPLOYEES; 

 

-- CREATE TABLA EMPLOYEES_2 SELECT FIRST_NAME, LAST_NAME FROM HR.EMPLOYEES WHERE DEPT=80; = SOLO ALGUNAS COLUMNAS ESPECIFICAS  

-- CREATE TABLE EMPLOYEES_2 SELECT e* FROM HR.EMPLOYEES; = COPIAR TODAS LAS TABLAS 

 
(Clase del dia 11 de febrero hicimos capitulo 1 "learn sql")
 

 