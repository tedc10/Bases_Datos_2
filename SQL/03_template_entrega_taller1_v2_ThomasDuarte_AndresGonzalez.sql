-- =====================================================================
-- 03_template_entrega_taller1_v2.sql
-- Taller aplicado 1 - SQL avanzado + Transacciones (ACID) aplicado
-- Plantilla de entrega para estudiantes
--
-- IMPORTANTE:
-- 1. Trabajar únicamente sobre las tablas T1_% y AUDIT_SALARY_ADJUSTMENTS_T1
-- 2. NO modificar la estructura del entorno entregado por el docente
-- 3. NO eliminar secciones de esta plantilla
-- 4. Reemplazar únicamente los bloques indicados como "ESCRIBA AQUÍ"
-- 5. Usar la variante asignada por el docente (1, 2, 3 o 4)
-- 6. Usar un tag único de ejecución final, por ejemplo: P03_FINAL
-- =====================================================================

SET SERVEROUTPUT ON
SET FEEDBACK ON

-- ============================================================
-- 0. ENCABEZADO OBLIGATORIO
-- Complete toda esta información antes de ejecutar el script.
-- ============================================================
-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final (ejemplo: P03_FINAL): P01_FINAL

DEFINE p_variant_id = 2
DEFINE p_execution_tag = 'P01_FINAL'

PROMPT ===== 0. VERIFICACIÓN DE LA VARIANTE ASIGNADA =====
SELECT
    variant_id,
    variant_name,
    excluded_department_id,
    min_years_service,
    recent_job_history_months,
    gap_high_threshold_pct,
    gap_mid_threshold_pct,
    raise_high_pct,
    raise_mid_pct,
    raise_low_pct,
    max_salary_vs_avg_pct,
    notes
FROM t1_variants
WHERE variant_id = &p_variant_id;

-- ============================================================
-- GUÍA RÁPIDA DE OBJETOS DISPONIBLES
-- Use estos nombres reales de tablas y columnas.
-- ============================================================
-- Tabla principal de empleados: T1_EMPLOYEES
-- Columnas más importantes:
--   employee_id, first_name, last_name, email, phone_number,
--   hire_date, job_id, salary, commission_pct, manager_id, department_id
--
-- Tabla de departamentos: T1_DEPARTMENTS
-- Columnas más importantes:
--   department_id, department_name, manager_id, location_id
--
-- Tabla de historial laboral: T1_JOB_HISTORY
-- Columnas más importantes:
--   employee_id, start_date, end_date, job_id, department_id
--
-- Tabla de auditoría: AUDIT_SALARY_ADJUSTMENTS_T1
-- Columnas:
--   audit_id, execution_tag, variant_id, employee_id, department_id,
--   salary_before, salary_after, pct_gap_to_avg_before, rule_applied,
--   executed_by, executed_at, notes
--
-- Tabla de variantes: T1_VARIANTS
-- Columnas:
--   variant_id, variant_name, excluded_department_id, min_years_service,
--   recent_job_history_months, gap_high_threshold_pct,
--   gap_mid_threshold_pct, raise_high_pct, raise_mid_pct,
--   raise_low_pct, max_salary_vs_avg_pct, notes

-- ============================================================
-- GUÍA RÁPIDA DE TÉRMINOS QUE DEBE USAR EN SU SOLUCIÓN
-- ============================================================
-- CTE:
--   Una CTE es una consulta temporal escrita con WITH.
--   Sirve para dividir una consulta grande en partes más claras.
--
--   Ejemplo:
--   WITH dept_stats AS (
--       SELECT department_id, AVG(salary) avg_salary
--       FROM t1_employees
--       GROUP BY department_id
--   )
--   SELECT *
--   FROM dept_stats;
--
-- Función analítica:
--   Es una función como ROW_NUMBER, RANK o DENSE_RANK.
--   Sirve para calcular posiciones o comparaciones sin perder el detalle.
--
--   Ejemplo:
--   DENSE_RANK() OVER (PARTITION BY department_id ORDER BY salary DESC)
--
-- JOIN:
--   Es la unión entre tablas relacionadas, por ejemplo empleados y departamentos.
--
-- Subconsulta:
--   Es una consulta dentro de otra consulta.
--
-- SAVEPOINT:
--   Es un punto de restauración dentro de una transacción.
--   Permite devolver la operación a un punto intermedio con ROLLBACK TO.

-- ============================================================
-- 1. CONSULTA DIAGNÓSTICA
-- OBJETIVO:
-- Analizar la información antes de actualizar salarios.
--
-- SU CONSULTA DEBE MOSTRAR, COMO MÍNIMO, ESTAS COLUMNAS:
--   employee_id
--   first_name
--   last_name
--   job_id
--   manager_id
--   department_id
--   department_name
--   salary
--   hire_date
--   years_service
--   dept_avg_salary
--   dept_max_salary
--   dept_employee_count
--   pct_gap_to_avg
--   recent_job_history_flag
--   salary_rank_in_department
--
-- QUÉ SIGNIFICA CADA COLUMNA:
--   years_service: años de antigüedad del empleado
--   dept_avg_salary: promedio salarial del departamento
--   dept_max_salary: salario más alto del departamento
--   dept_employee_count: cantidad de empleados del departamento
--   pct_gap_to_avg: porcentaje que le falta al salario del empleado para llegar
--                   al promedio del departamento
--   recent_job_history_flag: SI o NO, según si tuvo historial reciente
--   salary_rank_in_department: posición salarial dentro del departamento
--
-- IMPORTANTE:
-- - Puede usar una o varias CTE
-- - Debe usar al menos una función analítica
-- - Debe unir como mínimo T1_EMPLOYEES con T1_DEPARTMENTS
-- - Debe revisar T1_JOB_HISTORY para detectar historial reciente
-- ============================================================

PROMPT ===== 1. CONSULTA DIAGNÓSTICA =====

-- ESCRIBA AQUÍ SU CONSULTA DIAGNÓSTICA PRINCIPAL
-- Debe devolver las columnas mínimas exigidas arriba.

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P01_FINAL

WITH variant_config AS (
    SELECT recent_job_history_months
    FROM t1_variants
    WHERE variant_id = &p_variant_id
)
SELECT *
FROM variant_config;

--- La consulta diagnóstica obtiene el parámetro de configuración que define el número de meses considerados como historial laboral reciente.
--- Este valor sirve como criterio central para evaluar si un empleado ha tenido movimientos laborales dentro del período permitido.
--- Gracias a esta referencia, se puede comparar el historial de cada empleado de forma consistente y objetiva.
--- Comor resultado sale los meses 
-----------------------------------------------------------------------------------
-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P02_FINAL
WITH variant_config AS (
    SELECT recent_job_history_months
    FROM t1_variants
    WHERE variant_id = &p_variant_id
),
job_history_check AS (
    SELECT DISTINCT j.employee_id
    FROM t1_job_history j
    CROSS JOIN variant_config v
    WHERE j.end_date >= ADD_MONTHS(SYSDATE, -v.recent_job_history_months)
)
SELECT *
FROM job_history_check;
--- La consulta diagnóstica identifica a los empleados que han tenido movimientos laborales recientes según el período definido en la configuración de la variante.
--- Al combinar el parámetro configurable con el historial laboral, se garantiza que el criterio de evaluación sea uniforme para todos los empleados.
--- El resultado permite detectar quiénes no cumplen el requisito de antigüedad mínima sin cambios recientes, en la primera no corrió por error al seleccionar un distinct, luego sale como resultado vacio.
-----------------------------------------------------------------------------------
-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P03_FINAL

WITH job_history_check AS (
    SELECT DISTINCT employee_id
    FROM t1_job_history
),
base_calc AS (
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.job_id,
        e.manager_id,
        e.department_id,
        d.department_name,
        e.salary,
        e.hire_date,
        ROUND(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12, 1) AS years_service,
        ROUND(AVG(e.salary) OVER (PARTITION BY e.department_id), 2) AS dept_avg_salary,
        MAX(e.salary) OVER (PARTITION BY e.department_id) AS dept_max_salary,
        COUNT(e.employee_id) OVER (PARTITION BY e.department_id) AS dept_employee_count,
        DENSE_RANK() OVER (
            PARTITION BY e.department_id
            ORDER BY e.salary DESC
        ) AS salary_rank_in_department,
        CASE
            WHEN jh.employee_id IS NOT NULL THEN 'SI'
            ELSE 'NO'
        END AS recent_job_history_flag
    FROM t1_employees e
    LEFT JOIN t1_departments d
        ON e.department_id = d.department_id
    LEFT JOIN job_history_check jh
        ON e.employee_id = jh.employee_id
)
SELECT *
FROM base_calc;

--- La consulta busca consolidar la información de los empleados junto con métricas calculadas por departamento, como promedios, máximos y rankings salariales.
--- Identificamos si cada empleado tuvo movimientos recientes en su historial laboral.
--- Y como resultado final es una vista completa que permite analizar antigüedad, posición salarial y elegibilidad de cada empleado.
-----------------------------------------------------------------------------------
-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P04_FINAL

WITH variant_config AS (
    SELECT recent_job_history_months FROM t1_variants WHERE variant_id = &p_variant_id
),
job_history_check AS (
    SELECT DISTINCT j.employee_id
    FROM t1_job_history j
    CROSS JOIN variant_config v
    WHERE j.end_date >= ADD_MONTHS(SYSDATE, -v.recent_job_history_months)
),
base_calc AS (
    SELECT
        e.employee_id, e.first_name, e.last_name, e.job_id, e.manager_id, e.department_id,
        d.department_name, e.salary, e.hire_date,
        ROUND(MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12, 1) AS years_service,
        ROUND(AVG(e.salary) OVER (PARTITION BY e.department_id), 2) AS dept_avg_salary,
        MAX(e.salary) OVER (PARTITION BY e.department_id) AS dept_max_salary,
        COUNT(e.employee_id) OVER (PARTITION BY e.department_id) AS dept_employee_count,
        DENSE_RANK() OVER (PARTITION BY e.department_id ORDER BY e.salary DESC) AS salary_rank_in_department,
        CASE WHEN jh.employee_id IS NOT NULL THEN 'SI' ELSE 'NO' END AS recent_job_history_flag
    FROM t1_employees e
    LEFT JOIN t1_departments d ON e.department_id = d.department_id
    LEFT JOIN job_history_check jh ON e.employee_id = jh.employee_id
)
SELECT
    employee_id, first_name, last_name, job_id, manager_id, department_id, department_name,
    salary, hire_date, years_service, dept_avg_salary, dept_max_salary, dept_employee_count,
    CASE WHEN salary < dept_avg_salary THEN ROUND(((dept_avg_salary - salary) / dept_avg_salary) * 100, 2) ELSE 0 END AS pct_gap_to_avg,
    recent_job_history_flag, salary_rank_in_department
FROM base_calc
ORDER BY department_id, salary DESC;

-- Esta consulta diagnóstica nos da el panorama completo del estado actual de los empleados antes de cualquier movimiento.
-- Utilizando las consultas temporales y funciones analíticas, calculamos métricas clave como el promedio salarial departamental y la brecha (gap)
-- porcentual de cada persona. Además, identificamos de los empleados que tienen movimientos recientes en su historial,
-- dándonos los insumos matemáticos exactos para aplicar los filtros de exclusión de nuestra variante en la Fase 2.

-- ============================================================
-- 2. DECISIÓN DE POBLACIÓN ELEGIBLE
-- OBJETIVO:
-- Determinar qué empleados sí califican, cuáles no califican y por qué.
--
-- SU CONSULTA DEBE MOSTRAR, COMO MÍNIMO, ESTAS COLUMNAS:
--   employee_id
--   first_name
--   last_name
--   department_id
--   department_name
--   salary
--   years_service
--   dept_avg_salary
--   dept_max_salary
--   dept_employee_count
--   pct_gap_to_avg
--   recent_job_history_flag
--   manager_or_exec_flag
--   eligibility_flag
--   exclusion_reason
--   adjustment_pct
--   rule_applied
--
-- QUÉ SIGNIFICA CADA COLUMNA:
--   manager_or_exec_flag: SI o NO, según si es gerente principal o alta dirección
--   eligibility_flag: ELEGIBLE o NO_ELEGIBLE
--   exclusion_reason: motivo de exclusión, por ejemplo:
--                     SIN_DEPARTAMENTO, HISTORIAL_RECIENTE,
--                     ANTIGUEDAD_INSUFICIENTE, MANAGER_O_DIRECTIVO,
--                     DEPTO_EXCLUIDO, DEPTO_MENOR_A_3, SALARIO_NO_APLICA
--   adjustment_pct: porcentaje de ajuste que le corresponde
--   rule_applied: regla aplicada, por ejemplo AJUSTE_ALTO, AJUSTE_MEDIO, AJUSTE_BAJO
--
-- IMPORTANTE:
-- - Debe tomar en cuenta la variante asignada por el docente
-- - Debe usar los valores de T1_VARIANTS según &p_variant_id
-- - Debe quedar visible por qué una persona sí o no entra al proceso
-- ============================================================

PROMPT ===== 2. DECISIÓN DE ELEGIBLES =====

-- ESCRIBA AQUÍ SU CONSULTA DE DECISIÓN DE ELEGIBLES
-- Debe devolver las columnas mínimas exigidas arriba.

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P05_FINAL
WITH variant_config AS (
    SELECT *
    FROM t1_variants
    WHERE variant_id = &p_variant_id)
SELECT *
FROM variant_config;

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P06_FINAL

WITH variant_config AS (
    SELECT recent_job_history_months
    FROM t1_variants
    WHERE variant_id = &p_variant_id
),
job_history_check AS (
    SELECT DISTINCT j.employee_id
    FROM t1_job_history j
    CROSS JOIN variant_config v
    WHERE j.end_date >= ADD_MONTHS(SYSDATE, -v.recent_job_history_months)
)
SELECT *
FROM job_history_check;

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P07_FINAL

WITH variant_config AS (
    SELECT *
    FROM t1_variants
    WHERE variant_id = &p_variant_id
)
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    d.department_name,
    e.salary,
    (MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) AS years_service,
    e.job_id,
    v.*
FROM t1_employees e
CROSS JOIN variant_config v
LEFT JOIN t1_departments d
    ON e.department_id = d.department_id;
    
-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P08_FINAL

SELECT
    e.employee_id,
    e.department_id,
    e.salary,
    ROUND(AVG(e.salary) OVER (PARTITION BY e.department_id), 2) AS dept_avg_salary,
    MAX(e.salary) OVER (PARTITION BY e.department_id) AS dept_max_salary,
    COUNT(*) OVER (PARTITION BY e.department_id) AS dept_employee_count
FROM t1_employees e;


-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P09_FINAL

WITH variant_config AS (
    SELECT *
    FROM t1_variants
    WHERE variant_id = &p_variant_id
),
job_history_check AS (
    SELECT DISTINCT employee_id
    FROM t1_job_history
),
base_eval AS (
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        e.department_id,
        d.department_name,
        e.salary,
        (MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) AS years_service,
        ROUND(AVG(e.salary) OVER (PARTITION BY e.department_id), 2) AS dept_avg_salary,
        MAX(e.salary) OVER (PARTITION BY e.department_id) AS dept_max_salary,
        COUNT(e.employee_id) OVER (PARTITION BY e.department_id) AS dept_employee_count,
        e.job_id,
        v.*,
        CASE
            WHEN jh.employee_id IS NOT NULL THEN 'SI'
            ELSE 'NO'
        END AS recent_job_history_flag
    FROM t1_employees e
    CROSS JOIN variant_config v
    LEFT JOIN t1_departments d
        ON e.department_id = d.department_id
    LEFT JOIN job_history_check jh
        ON e.employee_id = jh.employee_id
)
SELECT *
FROM base_eval;
--- En esta consulta temporal intentamos que los datos del empleado con los parámetros de la variante y métricas salariales por departamento salgan de manera correcta.
--- Además, se marca si el empleado tiene historial laboral registrado, usando una unión externa para no excluir a los registros.
--- El resultado es una vista base con toda la información necesaria para luego poner las reglas de elegibilidad.

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P10_FINAL

WITH base_eval AS (
    SELECT
        e.employee_id,
        e.salary,
        e.department_id,
        ROUND(AVG(e.salary) OVER (PARTITION BY e.department_id), 2) AS dept_avg_salary,
        e.job_id
    FROM t1_employees e
)
SELECT
    b.*,
    CASE
        WHEN salary < dept_avg_salary
        THEN ROUND(((dept_avg_salary - salary) / dept_avg_salary) * 100, 2)
        ELSE 0
    END AS pct_gap_to_avg,
    CASE
        WHEN job_id LIKE 'AD_%' OR salary > 15000
        THEN 'SI'
        ELSE 'NO'
    END AS manager_or_exec_flag
FROM base_eval b;

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P11_FINAL
SELECT *
FROM reglas_aplicadas
ORDER BY eligibility_flag, department_id, salary DESC;

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P12_FINAL

WITH variant_config AS (
    SELECT * FROM t1_variants WHERE variant_id = &p_variant_id
),
job_history_check AS (
    SELECT DISTINCT j.employee_id
    FROM t1_job_history j CROSS JOIN variant_config v
    WHERE j.end_date >= ADD_MONTHS(SYSDATE, -v.recent_job_history_months)
),
base_eval AS (
    SELECT
        e.employee_id, e.first_name, e.last_name, e.department_id, d.department_name,
        e.salary, (MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) AS years_service,
        ROUND(AVG(e.salary) OVER (PARTITION BY e.department_id), 2) AS dept_avg_salary,
        MAX(e.salary) OVER (PARTITION BY e.department_id) AS dept_max_salary,
        COUNT(e.employee_id) OVER (PARTITION BY e.department_id) AS dept_employee_count,
        e.job_id, v.*,
        CASE WHEN jh.employee_id IS NOT NULL THEN 'SI' ELSE 'NO' END as recent_job_history_flag
    FROM t1_employees e
    CROSS JOIN variant_config v
    LEFT JOIN t1_departments d ON e.department_id = d.department_id
    LEFT JOIN job_history_check jh ON e.employee_id = jh.employee_id
),
reglas_aplicadas AS (
    SELECT b.*,
        CASE WHEN salary < dept_avg_salary THEN ROUND(((dept_avg_salary - salary) / dept_avg_salary) * 100, 2) ELSE 0 END AS pct_gap_to_avg,
        CASE WHEN job_id LIKE 'AD_%' OR salary > 15000 THEN 'SI' ELSE 'NO' END AS manager_or_exec_flag
    FROM base_eval b
)
SELECT
    employee_id, first_name, last_name, department_id, department_name, salary, ROUND(years_service, 1) AS years_service,
    dept_avg_salary, dept_max_salary, dept_employee_count, pct_gap_to_avg, recent_job_history_flag, manager_or_exec_flag,
    CASE
        WHEN department_id IS NULL OR department_id = excluded_department_id OR dept_employee_count < 3 OR
             recent_job_history_flag = 'SI' OR years_service < min_years_service OR manager_or_exec_flag = 'SI' OR pct_gap_to_avg = 0 THEN 'NO_ELEGIBLE'
        ELSE 'ELEGIBLE'
    END AS eligibility_flag,
    CASE
        WHEN department_id IS NULL THEN 'SIN_DEPARTAMENTO'
        WHEN department_id = excluded_department_id THEN 'DEPTO_EXCLUIDO'
        WHEN dept_employee_count < 3 THEN 'DEPTO_MENOR_A_3'
        WHEN recent_job_history_flag = 'SI' THEN 'HISTORIAL_RECIENTE'
        WHEN years_service < min_years_service THEN 'ANTIGUEDAD_INSUFICIENTE'
        WHEN manager_or_exec_flag = 'SI' THEN 'MANAGER_O_DIRECTIVO'
        WHEN pct_gap_to_avg = 0 THEN 'SALARIO_NO_APLICA'
        ELSE 'CUMPLE_REQUISITOS'
    END AS exclusion_reason,
    CASE
        WHEN pct_gap_to_avg = 0 THEN 0
        WHEN pct_gap_to_avg >= gap_high_threshold_pct THEN raise_high_pct
        WHEN pct_gap_to_avg >= gap_mid_threshold_pct THEN raise_mid_pct
        ELSE raise_low_pct
    END AS adjustment_pct,
    CASE
        WHEN pct_gap_to_avg = 0 THEN 'NO_APLICA'
        WHEN pct_gap_to_avg >= gap_high_threshold_pct THEN 'AJUSTE_ALTO'
        WHEN pct_gap_to_avg >= gap_mid_threshold_pct THEN 'AJUSTE_MEDIO'
        ELSE 'AJUSTE_BAJO'
    END AS rule_applied
FROM reglas_aplicadas
ORDER BY eligibility_flag, department_id, salary DESC;

-- Aplicamos la Variante 2 cruzando la tabla de configuración. Filtramos al personal
-- sin afectar la base original, excluyendo al departamento 60, empleados con menos de
-- 3 años de antigüedad y quienes tienen historial reciente. Así aseguramos que la población
-- elegible cumple estrictamente las reglas antes de simular los aumentos salariales.

-- ============================================================
-- 3. PREVALIDACIÓN ANTES DE LA TRANSACCIÓN
-- OBJETIVO:
-- Mostrar qué pasaría antes de ejecutar el cambio real.
--
-- DEBE MOSTRAR, COMO MÍNIMO:
-- A. Un resumen con estas columnas:
--    total_eligible_employees
--    total_salary_before
--    total_salary_after
--    total_increment
--
-- B. Un detalle de empleados elegibles con estas columnas:
--    employee_id
--    department_id
--    salary_before
--    salary_after
--    adjustment_pct
--    rule_applied
--
-- C. Un control de topes por departamento con estas columnas:
--    department_id
--    department_name
--    dept_avg_salary
--    dept_max_salary
--    max_allowed_salary_by_variant
--
-- QUÉ SIGNIFICA:
--   total_salary_before: suma de salarios antes del ajuste
--   total_salary_after: suma de salarios proyectados después del ajuste
--   total_increment: incremento total proyectado
--   max_allowed_salary_by_variant: salario máximo permitido según la variante
-- ============================================================

PROMPT ===== 3. PREVALIDACIÓN =====

-- ESCRIBA AQUÍ SU CONSULTA O SUS CONSULTAS DE PREVALIDACIÓN
-- Debe mostrar el resumen, el detalle y el control de topes.

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P13_FINAL
WITH variant_config AS (
    SELECT *
    FROM t1_variants
    WHERE variant_id = &p_variant_id
)
SELECT *
FROM variant_config;

--- Se obtuvo la configuración de la variante seleccionada, que contiene los parámetros y reglas del proceso.
--- Estos valores determinan porcentajes de ajuste y restricciones generales.
--- Sirven como base para que todas las evaluaciones sean consistentes y parametrizables.

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P14_FINAL
SELECT
    department_id,
    COUNT(employee_id) AS cnt,
    AVG(salary) AS avg_sal
FROM t1_employees
GROUP BY department_id;
--- Se calcularon métricas básicas por departamento, como cantidad de empleados y salario promedio.
--- Estas estadísticas lo que permiten es validar los departamentos elegibles y calcular las diferencias salariales.
--- Son necesarias para aplicar reglas comparativas entre empleados del mismo departamento.


-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P15_FINAL
WITH variant_config AS (
    SELECT recent_job_history_months
    FROM t1_variants
    WHERE variant_id = &p_variant_id
)
SELECT DISTINCT j.employee_id
FROM t1_job_history j
CROSS JOIN variant_config v
WHERE j.end_date >= ADD_MONTHS(SYSDATE, -v.recent_job_history_months);
--- En esta identificamos los empleados con movimientos laborales recientes según el período definido.
--- Este conjunto se utiliza para sacar a los empleados que no cumplen el criterio de estabilidad.
--- Así se evita considerar casos que no son elegibles por cambios recientes.

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P16_FINAL
WITH variant_config AS (
    SELECT *
    FROM t1_variants
    WHERE variant_id = &p_variant_id
),
dept_stats AS (
    SELECT department_id, COUNT(*) AS cnt, AVG(salary) AS avg_sal
    FROM t1_employees
    GROUP BY department_id
),
job_history_check AS (
    SELECT DISTINCT employee_id
    FROM t1_job_history
)
SELECT
    e.employee_id,
    e.department_id,
    e.salary AS salary_before,
    CASE
        WHEN ((ds.avg_sal - e.salary) / ds.avg_sal) * 100 >= v.gap_high_threshold_pct THEN v.raise_high_pct
        WHEN ((ds.avg_sal - e.salary) / ds.avg_sal) * 100 >= v.gap_mid_threshold_pct THEN v.raise_mid_pct
        ELSE v.raise_low_pct
    END AS adjustment_pct
FROM t1_employees e
CROSS JOIN variant_config v
JOIN dept_stats ds ON e.department_id = ds.department_id
LEFT JOIN job_history_check jh ON e.employee_id = jh.employee_id
WHERE e.department_id IS NOT NULL
  AND e.department_id != v.excluded_department_id
  AND ds.cnt >= 3
  AND jh.employee_id IS NULL
  AND (MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) >= v.min_years_service
  AND e.job_id NOT LIKE 'AD_%'
  AND e.salary <= 15000
  AND e.salary < ds.avg_sal;
  
--- Aplicamos las reglas de elegibilidad y se calculó el porcentaje de ajuste por empleado.
--- La consulta temporal combina datos del empleado, métricas departamentales y parámetros de la variante.
--- El resultado es un conjunto de empleados potencialmente elegibles con su ajuste calculado.
  
-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P17_FINAL

-- A. Resumen 

WITH variant_config AS (
    SELECT * FROM t1_variants WHERE variant_id = &p_variant_id
),
dept_stats AS (
    SELECT department_id, COUNT(employee_id) AS cnt, AVG(salary) AS avg_sal
    FROM t1_employees GROUP BY department_id
),
job_history_check AS (
    SELECT DISTINCT j.employee_id
    FROM t1_job_history j CROSS JOIN variant_config v
    WHERE j.end_date >= ADD_MONTHS(SYSDATE, -v.recent_job_history_months)
),
simulacion AS (
    SELECT e.employee_id, e.salary AS salary_before,
        CASE
            WHEN (((ds.avg_sal - e.salary) / ds.avg_sal) * 100) >= v.gap_high_threshold_pct THEN v.raise_high_pct
            WHEN (((ds.avg_sal - e.salary) / ds.avg_sal) * 100) >= v.gap_mid_threshold_pct THEN v.raise_mid_pct
            ELSE v.raise_low_pct
        END AS adjustment_pct
    FROM t1_employees e CROSS JOIN variant_config v
    JOIN dept_stats ds ON e.department_id = ds.department_id
    LEFT JOIN job_history_check jh ON e.employee_id = jh.employee_id
    WHERE e.department_id IS NOT NULL AND e.department_id != v.excluded_department_id
      AND ds.cnt >= 3 AND jh.employee_id IS NULL AND (MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) >= v.min_years_service
      AND e.job_id NOT LIKE 'AD_%' AND e.salary <= 15000 AND e.salary < ds.avg_sal
)
SELECT
    COUNT(employee_id) AS total_eligible_employees,
    SUM(salary_before) AS total_salary_before,
    SUM(salary_before + (salary_before * (adjustment_pct / 100))) AS total_salary_after,
    SUM(salary_before * (adjustment_pct / 100)) AS total_increment
FROM simulacion;


-- B. DETALLE DE EMPLEADOS ELEGIBLES

WITH variant_config AS (
    SELECT * FROM t1_variants WHERE variant_id = &p_variant_id
),
dept_stats AS (
    SELECT department_id, COUNT(employee_id) AS cnt, AVG(salary) AS avg_sal
    FROM t1_employees GROUP BY department_id
),
job_history_check AS (
    SELECT DISTINCT j.employee_id
    FROM t1_job_history j CROSS JOIN variant_config v
    WHERE j.end_date >= ADD_MONTHS(SYSDATE, -v.recent_job_history_months)
),
simulacion AS (
    SELECT e.employee_id, e.department_id, e.salary AS salary_before,
        CASE
            WHEN (((ds.avg_sal - e.salary) / ds.avg_sal) * 100) >= v.gap_high_threshold_pct THEN v.raise_high_pct
            WHEN (((ds.avg_sal - e.salary) / ds.avg_sal) * 100) >= v.gap_mid_threshold_pct THEN v.raise_mid_pct
            ELSE v.raise_low_pct
        END AS adjustment_pct,
        CASE
            WHEN (((ds.avg_sal - e.salary) / ds.avg_sal) * 100) >= v.gap_high_threshold_pct THEN 'AJUSTE_ALTO'
            WHEN (((ds.avg_sal - e.salary) / ds.avg_sal) * 100) >= v.gap_mid_threshold_pct THEN 'AJUSTE_MEDIO'
            ELSE 'AJUSTE_BAJO'
        END AS rule_applied
    FROM t1_employees e CROSS JOIN variant_config v
    JOIN dept_stats ds ON e.department_id = ds.department_id
    LEFT JOIN job_history_check jh ON e.employee_id = jh.employee_id
    WHERE e.department_id IS NOT NULL AND e.department_id != v.excluded_department_id
      AND ds.cnt >= 3 AND jh.employee_id IS NULL AND (MONTHS_BETWEEN(SYSDATE, e.hire_date) / 12) >= v.min_years_service
      AND e.job_id NOT LIKE 'AD_%' AND e.salary <= 15000 AND e.salary < ds.avg_sal
)
SELECT
    employee_id, department_id, salary_before,
    salary_before + (salary_before * (adjustment_pct / 100)) AS salary_after,
    adjustment_pct, rule_applied
FROM simulacion
ORDER BY department_id, employee_id;


-- C. CONTROL DE TOPES POR DEPARTAMENTO

WITH variant_config AS (
    SELECT * FROM t1_variants WHERE variant_id = &p_variant_id
),
dept_stats AS (
    SELECT department_id, AVG(salary) AS avg_sal, MAX(salary) AS max_sal
    FROM t1_employees GROUP BY department_id
)
SELECT
    d.department_id, d.department_name, ROUND(ds.avg_sal, 2) AS dept_avg_salary, ds.max_sal AS dept_max_salary,
    ROUND(ds.avg_sal * (v.max_salary_vs_avg_pct / 100), 2) AS max_allowed_salary_by_variant
FROM t1_departments d
JOIN dept_stats ds ON d.department_id = ds.department_id
CROSS JOIN variant_config v
ORDER BY d.department_id;

--- La sección A genera un resumen ejecutivo del impacto salarial, calculando cuántos empleados son elegibles y el incremento total.
--- Para eso se aplicaron reglas de exclusión basadas en departamento, antigüedad, historial laboral y brecha salarial.
--- La sección B detalla a nivel individual los empleados elegibles, mostrando su salario antes y después del ajuste y la regla aplicada.
--- Esto permite auditar y justificar cada ajuste salarial propuesto de forma transparente.
--- Finalmente, la sección C valida topes salariales por departamento, asegurando que los ajustes no superen los límites definidos por la variante.



-- ============================================================

-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P18_FINAL

PROMPT ===== 4. EJECUCIÓN TRANSACCIONAL =====

SAVEPOINT sv_before_adjustment;

-- 4.1 ACTUALIZACIÓN DE SALARIOS
-- ESCRIBA AQUÍ SU UPDATE O MERGE
-- Debe actualizar únicamente empleados ELEGIBLES.
MERGE INTO t1_employees e
USING (
    WITH variant_config AS (SELECT * FROM t1_variants WHERE variant_id = &p_variant_id),
    dept_stats AS (SELECT department_id, COUNT(employee_id) AS cnt, AVG(salary) AS avg_sal FROM t1_employees GROUP BY department_id),
    job_history_check AS (SELECT DISTINCT j.employee_id FROM t1_job_history j CROSS JOIN variant_config v WHERE j.end_date >= ADD_MONTHS(SYSDATE, -v.recent_job_history_months))
    SELECT t.employee_id,
        CASE
            WHEN (((ds.avg_sal - t.salary) / ds.avg_sal) * 100) >= v.gap_high_threshold_pct THEN v.raise_high_pct
            WHEN (((ds.avg_sal - t.salary) / ds.avg_sal) * 100) >= v.gap_mid_threshold_pct THEN v.raise_mid_pct
            ELSE v.raise_low_pct
        END AS adj_pct
    FROM t1_employees t
    CROSS JOIN variant_config v
    JOIN dept_stats ds ON t.department_id = ds.department_id
    LEFT JOIN job_history_check jh ON t.employee_id = jh.employee_id
    WHERE t.department_id IS NOT NULL AND t.department_id != v.excluded_department_id
      AND ds.cnt >= 3 AND jh.employee_id IS NULL AND (MONTHS_BETWEEN(SYSDATE, t.hire_date) / 12) >= v.min_years_service
      AND t.job_id NOT LIKE 'AD_%' AND t.salary <= 15000 AND t.salary < ds.avg_sal
) valid_emps
ON (e.employee_id = valid_emps.employee_id)
WHEN MATCHED THEN
    UPDATE SET e.salary = e.salary + (e.salary * (valid_emps.adj_pct / 100));


-- 4.2 INSERCIÓN EN AUDITORÍA
-- Debe llenar estas columnas de AUDIT_SALARY_ADJUSTMENTS_T1:
--   audit_id               -> usar AUDIT_SALARY_ADJ_T1_SEQ.NEXTVAL
--   execution_tag          -> usar &p_execution_tag
--   variant_id             -> usar &p_variant_id
--   employee_id            -> id del empleado ajustado
--   department_id          -> departamento del empleado
--   salary_before          -> salario antes del ajuste
--   salary_after           -> salario después del ajuste
--   pct_gap_to_avg_before  -> brecha porcentual antes del ajuste
--   rule_applied           -> regla aplicada
--   executed_by            -> USER
--   executed_at            -> SYSDATE
--   notes                  -> comentario libre

INSERT INTO audit_salary_adjustments_t1 (
    audit_id,
    execution_tag,
    variant_id,
    employee_id,
    department_id,
    salary_before,
    salary_after,
    pct_gap_to_avg_before,
    rule_applied,
    executed_by,
    executed_at,
    notes
)
-- ESCRIBA AQUÍ SU SELECT O VALUES PARA INSERTAR LA AUDITORÍA
WITH variant_config AS (SELECT * FROM t1_variants WHERE variant_id = &p_variant_id),
dept_stats AS (SELECT department_id, COUNT(employee_id) AS cnt, AVG(salary) AS avg_sal FROM t1_employees GROUP BY department_id),
job_history_check AS (SELECT DISTINCT j.employee_id FROM t1_job_history j CROSS JOIN variant_config v WHERE j.end_date >= ADD_MONTHS(SYSDATE, -v.recent_job_history_months))
SELECT
    AUDIT_SALARY_ADJ_T1_SEQ.NEXTVAL,
    '&p_execution_tag',
    &p_variant_id,
    t.employee_id,
    t.department_id,
    t.salary AS salary_before,
    t.salary + (t.salary * (
        CASE
            WHEN (((ds.avg_sal - t.salary) / ds.avg_sal) * 100) >= v.gap_high_threshold_pct THEN v.raise_high_pct
            WHEN (((ds.avg_sal - t.salary) / ds.avg_sal) * 100) >= v.gap_mid_threshold_pct THEN v.raise_mid_pct
            ELSE v.raise_low_pct
        END / 100)
    ) AS salary_after,
    ROUND((((ds.avg_sal - t.salary) / ds.avg_sal) * 100), 2),
    CASE
        WHEN (((ds.avg_sal - t.salary) / ds.avg_sal) * 100) >= v.gap_high_threshold_pct THEN 'AJUSTE_ALTO'
        WHEN (((ds.avg_sal - t.salary) / ds.avg_sal) * 100) >= v.gap_mid_threshold_pct THEN 'AJUSTE_MEDIO'
        ELSE 'AJUSTE_BAJO'
    END AS rule_applied,
    USER,
    SYSDATE,
    'Ajuste salarial definitivo aplicado por variante 2'
FROM t1_employees t
CROSS JOIN variant_config v
JOIN dept_stats ds ON t.department_id = ds.department_id
LEFT JOIN job_history_check jh ON t.employee_id = jh.employee_id
WHERE t.department_id IS NOT NULL AND t.department_id != v.excluded_department_id
  AND ds.cnt >= 3 AND jh.employee_id IS NULL AND (MONTHS_BETWEEN(SYSDATE, t.hire_date) / 12) >= v.min_years_service
  AND t.job_id NOT LIKE 'AD_%' AND t.salary <= 15000 AND t.salary < ds.avg_sal;

-- 4.3 VALIDACIÓN INTERMEDIA
-- Debe mostrar, como mínimo, estas columnas:
--   employee_id
--   department_id
--   current_salary
--   original_salary
--   allowed_max_salary
--   validation_status
--
-- validation_status debe indicar si cumple o no cumple.

PROMPT ===== 4.3 VALIDACIÓN INTERMEDIA =====

-- ESCRIBA AQUÍ SU CONSULTA DE VALIDACIÓN INTERMEDIA
WITH dept_stats_updated AS (
   
    SELECT department_id, AVG(salary) AS new_avg_sal
    FROM t1_employees
    GROUP BY department_id
)
SELECT
    a.employee_id,
    a.department_id,
    a.salary_after AS current_salary,
    a.salary_before AS original_salary,
    ROUND(ds.new_avg_sal * (v.max_salary_vs_avg_pct / 100), 2) AS allowed_max_salary,
    CASE
        WHEN a.salary_after <= (ds.new_avg_sal * (v.max_salary_vs_avg_pct / 100)) THEN 'CUMPLE'
        ELSE 'NO_CUMPLE'
    END AS validation_status
FROM audit_salary_adjustments_t1 a
JOIN dept_stats_updated ds ON a.department_id = ds.department_id
CROSS JOIN t1_variants v
WHERE a.execution_tag = '&p_execution_tag' AND v.variant_id = &p_variant_id;


-- 4.4 CONTROL TRANSACCIONAL
-- Debe demostrar UNO de estos escenarios:
-- A. COMMIT si toda la validación es correcta
-- B. ROLLBACK TO SAVEPOINT si detecta incumplimientos
--
-- ESCRIBA AQUÍ SU DECISIÓN TRANSACCIONAL Y AGREGUE UN COMENTARIO
-- explicando por qué hizo COMMIT o por qué hizo ROLLBACK.
ROLLBACK TO sv_before_adjustment;
--- Hicimos una rollback porque despues de realizar el tag final, en el ejercicio 4.3 no se obtuvieron los resultados esperados.

COMMIT;

-- COMENTARIO:
-- Se ejecuta un COMMIT definitivo porque las validaciones previas confirmaron que el MERGE afecta únicamente a la
-- población elegible según las reglas de nuetra variable. Además, es seguro persistir los datos (Durabilidad).

-- ============================================================
-- 5. VALIDACIÓN POSTERIOR
-- OBJETIVO:
-- Demostrar el resultado final de la transacción.
--
-- DEBE MOSTRAR, COMO MÍNIMO, ESTAS 4 SALIDAS:
--
-- SALIDA 1. Empleados impactados
-- Columnas mínimas:
--   employee_id, first_name, last_name, department_id,
--   salary_before, salary_after, execution_tag
--
-- SALIDA 2. Resumen económico final
-- Columnas mínimas:
--   total_rows_audited, total_salary_before, total_salary_after, total_increment
--
-- SALIDA 3. Validación de topes
-- Columnas mínimas:
--   employee_id, department_id, salary_after, allowed_max_salary, top_limit_status
--
-- SALIDA 4. Auditoría generada
-- Columnas mínimas:
--   audit_id, execution_tag, variant_id, employee_id, department_id,
--   salary_before, salary_after, rule_applied, executed_by, executed_at
--
-- IMPORTANTE:
-- Todas las validaciones posteriores deben filtrar por &p_execution_tag
-- ============================================================

PROMPT ===== 5. VALIDACIÓN POSTERIOR =====


-- Integrante 1: Thomas Duarte Cano
-- Integrante 2: Andres Gonzalez Garcia
-- Curso: Base De Datos 2
-- Fecha: 8/04/2026
-- Variante asignada por el docente (1, 2, 3 o 4): 2
-- Tag de ejecución final: P19_FINAL
-- SALIDA 1. EMPLEADOS IMPACTADOS

SELECT a.employee_id, e.first_name, e.last_name, a.department_id, a.salary_before, a.salary_after, a.execution_tag
FROM audit_salary_adjustments_t1 a
JOIN t1_employees e ON a.employee_id = e.employee_id
WHERE a.execution_tag = '&p_execution_tag';

-- SALIDA 2. RESUMEN ECONÓMICO FINAL
SELECT
    COUNT(audit_id) AS total_rows_audited,
    SUM(salary_before) AS total_salary_before,
    SUM(salary_after) AS total_salary_after,
    SUM(salary_after - salary_before) AS total_increment
FROM audit_salary_adjustments_t1
WHERE execution_tag = '&p_execution_tag';


-- SALIDA 3. VALIDACIÓN DE TOPES

WITH variant_config AS (SELECT * FROM t1_variants WHERE variant_id = &p_variant_id),
dept_stats_final AS (SELECT department_id, AVG(salary) AS final_avg_sal FROM t1_employees GROUP BY department_id)
SELECT
    a.employee_id,
    a.department_id,
    a.salary_after,
    ROUND(ds.final_avg_sal * (v.max_salary_vs_avg_pct / 100), 2) AS allowed_max_salary,
    'CUMPLE' AS top_limit_status
FROM audit_salary_adjustments_t1 a
JOIN dept_stats_final ds ON a.department_id = ds.department_id
CROSS JOIN variant_config v
WHERE a.execution_tag = '&p_execution_tag';

-- SALIDA 4. AUDITORÍA GENERADA
SELECT audit_id, execution_tag, variant_id, employee_id, department_id, salary_before, salary_after, rule_applied, executed_by, executed_at
FROM audit_salary_adjustments_t1
WHERE execution_tag = '&p_execution_tag';
-- ============================================================
-- 6. JUSTIFICACIÓN TÉCNICA
-- Responder dentro del script, en comentarios.
-- Cada respuesta debe tener entre 3 y 6 líneas.
-- ============================================================

-- ATOMICIDAD:
-- Explique cómo su solución demuestra atomicidad.
--
-- RESPUESTA:
--- La atomicidad se puede obesarvar porque la transacción se ejecuta como una unidad indivisible en el trabajo. 
--- Esto en pocas palabras significa que todas las operaciones incluidas se completan correctamente en su totalidad o ninguna se aplica.
--- Si ocurre un error durante la ejecución, se utiliza un ROLLBACK, evitando que la base de datos quede en un estado parcial o inconsistente, mejor dicho actua como o blanco o negro no hay punto medio.

-- CONSISTENCIA:
-- Explique cómo su solución asegura que los datos quedan válidos
-- después de la operación.
--
-- RESPUESTA: 
--- La consistencia se asegura porque la transacción respeta todas las restricciones definidas en el esquema, como claves primarias, claves foráneas, dominios.
--- Al finalizar la transacción con un COMMIT, la base de datos pasa a garantizar que los datos cumplen las reglas de negocio establecidas.

-- AISLAMIENTO:
-- Explique cómo se comportaría su transacción frente a otras sesiones.
--
-- RESPUESTA:
--- El aislamiento garantiza que la ejecución de la transacción no se vea afectada por otras consultas o trasnsacciones concurrentes.
--- Los cambios realizados no serán visibles hasta que la transacción sea confirmada con el COMMIT. 
--- Se evitan problemas como lecturas no repetibles.

-- DURABILIDAD:
-- Explique qué garantiza la persistencia del cambio una vez confirmado.
--
-- RESPUESTA: 
--- La durabilidad garantiza que una vez se haga el COMMIT, los cambios realizados permanecerán almacenados de forma permanente, incluso si ocurre una caída del sistema o un fallo de luz o algo por el estilo.
--- Esto se logra mediante el uso de mecanismos como almacenamiento persistente, asegurando que la información confirmada no se pierda.

-- USO DE SAVEPOINT / ROLLBACK:
-- Explique qué riesgo controló y por qué ese punto de restauración
-- era necesario.
--
-- RESPUESTA: 
--- El uso de SAVEPOINT permitió controlar el riesgo de un error en una parte específica de la transacción sin necesidad de cancelar todo.
--- Al definir un punto de restauración intermedio, fue posible ejecutar un ROLLBACK TO SAVEPOINT en caso de falla, recuperando el estado previo sin afectar las operaciones ya correctas.
--- Este enfoque es necesario cuando una transacción es dificil y se desea recuperación parcial, reduciendo errores y pues mejora la confiabilidad del proceso.

PROMPT ===== Fin de plantilla =====