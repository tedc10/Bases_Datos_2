-- ============================================================
-- TALLER AVANZADO PL/SQL — SETUP SCRIPT
-- Sistema de Liquidación de Nómina — HotelGroup S.A.
-- Oracle Database 19c
-- Ejecutar este script al inicio del taller (5 min)
-- ============================================================
SET SERVEROUTPUT ON;

/*
Autor: Thomas Duarte Cano y Andres Felipe Gonzalez
Fecha: 20/04/2026
Punto 1
*/
 
DECLARE
    vn_id_emp        EMPLEADOS.id_empleado%TYPE   := 1003; -- Cambiar para probar otros
    vv_nombre        EMPLEADOS.nombre%TYPE;
    vv_tipo          EMPLEADOS.tipo_contrato%TYPE;
    vn_salario       EMPLEADOS.salario_base%TYPE;
    vd_ingreso       EMPLEADOS.fecha_ingreso%TYPE;
    vv_sede          EMPLEADOS.cod_sede%TYPE;
 
    vv_quincena      VARCHAR2(15) := '2026-Q1-ENE';
 
    vn_base_q        NUMBER(12,2) := 0;
    vn_recargos      NUMBER(12,2) := 0;
    vn_bonif         NUMBER(12,2) := 0;
    vn_valor_hora    NUMBER(12,4) := 0;
    vn_antiguedad    NUMBER(3)    := 0;
    vn_sanciones     NUMBER(3)    := 0;
    vn_pct_bonif     NUMBER(5,2)  := 0;
    vn_subtotal      NUMBER(12,2) := 0;
 
    vn_pct_noct      NUMBER(5,2);
    vn_pct_dom       NUMBER(5,2);
    vn_pct_ndom      NUMBER(5,2);
    vn_ret_serv      NUMBER(5,2);
 
    CURSOR cur_horas(param_emp NUMBER, param_quin VARCHAR2) IS
        SELECT tipo_hora, cantidad_horas
        FROM   HORAS_TRABAJADAS
        WHERE  id_empleado = param_emp
        AND    id_quincena = param_quin;
 
BEGIN
    SELECT nombre, tipo_contrato, salario_base, fecha_ingreso, cod_sede
    INTO   vv_nombre, vv_tipo, vn_salario, vd_ingreso, vv_sede
    FROM   EMPLEADOS
    WHERE  id_empleado = vn_id_emp;
 
    SELECT MAX(CASE WHEN cod_parametro = 'RECARGO_NOCTURNO'  THEN valor_numerico END),
           MAX(CASE WHEN cod_parametro = 'RECARGO_DOMINICAL' THEN valor_numerico END),
           MAX(CASE WHEN cod_parametro = 'RECARGO_NOCT_DOM'  THEN valor_numerico END),
           MAX(CASE WHEN cod_parametro = 'RET_SERVICIOS'     THEN valor_numerico END)
    INTO   vn_pct_noct, vn_pct_dom, vn_pct_ndom, vn_ret_serv
    FROM   PARAMETROS;
 
    -- Aplicaciòn de la regla 1:
    IF vv_tipo = 'PLANTA' THEN
        vn_base_q     := vn_salario / 2;
        vn_valor_hora := vn_salario / 240;
    ELSIF vv_tipo = 'TEMPORAL' THEN
        SELECT NVL(cantidad_horas, 0) INTO vn_base_q
        FROM   HORAS_TRABAJADAS
        WHERE  id_empleado = vn_id_emp AND id_quincena = vv_quincena AND tipo_hora = 'NORMAL';
        vn_base_q     := vn_salario * vn_base_q;
        vn_valor_hora := vn_salario;
    ELSIF vv_tipo = 'SERVICIOS' THEN
        vn_base_q := (vn_salario - (vn_salario * vn_ret_serv / 100)) / 2;
    END IF;
 
    -- Aplicaciòn de la regla 2:
    IF vv_tipo != 'SERVICIOS' THEN
        FOR r IN cur_horas(vn_id_emp, vv_quincena) LOOP
            IF r.tipo_hora = 'NOCTURNA' THEN
                vn_recargos := vn_recargos + r.cantidad_horas * vn_valor_hora * (vn_pct_noct / 100);
            ELSIF r.tipo_hora = 'DOMINICAL' THEN
                vn_recargos := vn_recargos + r.cantidad_horas * vn_valor_hora * (vn_pct_dom / 100);
            ELSIF r.tipo_hora = 'NOCTURNA_DOM' THEN
                vn_recargos := vn_recargos + r.cantidad_horas * vn_valor_hora * (vn_pct_ndom / 100);
            END IF;
        END LOOP;
    END IF;
 
    -- Aplicaciòn de la regla 3: 
    IF vv_tipo != 'SERVICIOS' THEN
        vn_antiguedad := TRUNC(MONTHS_BETWEEN(SYSDATE, vd_ingreso) / 12);
 
        SELECT COUNT(*) INTO vn_sanciones
        FROM   SANCIONES
        WHERE  id_empleado  = vn_id_emp
        AND    fecha_sancion >= ADD_MONTHS(SYSDATE, -6);
 
        IF vn_sanciones <= 2 THEN
            vn_pct_bonif := CASE
                WHEN vn_antiguedad BETWEEN 3 AND 5   THEN 3
                WHEN vn_antiguedad BETWEEN 6 AND 10  THEN 6
                WHEN vn_antiguedad > 10              THEN 10
                ELSE 0
            END;
        END IF;
 
        vn_bonif := vn_base_q * vn_pct_bonif / 100;
    END IF;
 
    vn_subtotal := vn_base_q + vn_recargos + vn_bonif;
 
    DBMS_OUTPUT.PUT_LINE('=== LIQUIDACIÓN QUINCENAL ===');
    DBMS_OUTPUT.PUT_LINE('Empleado:       ' || vv_nombre || ' (' || vn_id_emp || ')');
    DBMS_OUTPUT.PUT_LINE('Sede:           ' || vv_sede);
    DBMS_OUTPUT.PUT_LINE('Tipo contrato:  ' || vv_tipo);
    DBMS_OUTPUT.PUT_LINE('Antigüedad:     ' || vn_antiguedad || ' años');
    DBMS_OUTPUT.PUT_LINE('-----------------------------');
    DBMS_OUTPUT.PUT_LINE('Salario base Q: ' || TO_CHAR(vn_base_q,   'FM999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('Recargos:       ' || TO_CHAR(vn_recargos,  'FM999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('Bonificación:   ' || TO_CHAR(vn_bonif,     'FM999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('-----------------------------');
    DBMS_OUTPUT.PUT_LINE('SUBTOTAL:       ' || TO_CHAR(vn_subtotal,  'FM999,999,990.00'));
    DBMS_OUTPUT.PUT_LINE('=============================');
END;
/

/*
Autor: Thomas Duarte Cano y Andres Felipe Gonzalez
Fecha: 20/04/2026
Punto 2
*/

-- Aplicaciòn de la regla 1: calcula el salario base quincenal
CREATE OR REPLACE FUNCTION fn_salario_base_q(
    param_id_emp  NUMBER,
    param_id_quin VARCHAR2
) RETURN NUMBER IS
    vv_tipo       EMPLEADOS.tipo_contrato%TYPE;
    vn_salario    EMPLEADOS.salario_base%TYPE;
    vn_horas_norm NUMBER(5,1) := 0;
    vn_ret_serv   NUMBER(5,2);
BEGIN
    SELECT tipo_contrato, salario_base
    INTO   vv_tipo, vn_salario
    FROM   EMPLEADOS
    WHERE  id_empleado = param_id_emp;
 
    SELECT valor_numerico
    INTO   vn_ret_serv
    FROM   PARAMETROS
    WHERE  cod_parametro = 'RET_SERVICIOS';
 
    IF vv_tipo = 'PLANTA' THEN
        RETURN vn_salario / 2;
 
    ELSIF vv_tipo = 'TEMPORAL' THEN
        SELECT NVL(cantidad_horas, 0)
        INTO   vn_horas_norm
        FROM   HORAS_TRABAJADAS
        WHERE  id_empleado = param_id_emp
        AND    id_quincena = param_id_quin
        AND    tipo_hora   = 'NORMAL';
        RETURN vn_salario * vn_horas_norm;
 
    ELSIF vv_tipo = 'SERVICIOS' THEN
        RETURN (vn_salario - (vn_salario * vn_ret_serv / 100)) / 2;
    END IF;
 
    RETURN 0;
END fn_salario_base_q;
/
 
-- Aplicaciòn de la regla 2: calcula recargos usando cursor con parametro
CREATE OR REPLACE FUNCTION fn_recargos(
    param_id_emp  NUMBER,
    param_id_quin VARCHAR2
) RETURN NUMBER IS
    vv_tipo       EMPLEADOS.tipo_contrato%TYPE;
    vn_salario    EMPLEADOS.salario_base%TYPE;
    vn_valor_hora NUMBER(12,4) := 0;
    vn_recargos   NUMBER(12,2) := 0;
    vn_pct_noct   NUMBER(5,2);
    vn_pct_dom    NUMBER(5,2);
    vn_pct_ndom   NUMBER(5,2);
 
    CURSOR cur_horas(param_emp NUMBER, param_quin VARCHAR2) IS
        SELECT tipo_hora, cantidad_horas
        FROM   HORAS_TRABAJADAS
        WHERE  id_empleado = param_emp
        AND    id_quincena = param_quin;
BEGIN
    SELECT tipo_contrato, salario_base
    INTO   vv_tipo, vn_salario
    FROM   EMPLEADOS
    WHERE  id_empleado = param_id_emp;
 
    IF vv_tipo = 'SERVICIOS' THEN
        RETURN 0;
    END IF;
 
    SELECT MAX(CASE WHEN cod_parametro = 'RECARGO_NOCTURNO'  THEN valor_numerico END),
           MAX(CASE WHEN cod_parametro = 'RECARGO_DOMINICAL' THEN valor_numerico END),
           MAX(CASE WHEN cod_parametro = 'RECARGO_NOCT_DOM'  THEN valor_numerico END)
    INTO   vn_pct_noct, vn_pct_dom, vn_pct_ndom
    FROM   PARAMETROS;
 
    IF vv_tipo = 'PLANTA' THEN
        vn_valor_hora := vn_salario / 240;
    ELSE
        vn_valor_hora := vn_salario;
    END IF;
 
    -- Recorrer horas y sumar recargos establecidos
    FOR r IN cur_horas(param_id_emp, param_id_quin) LOOP
        IF r.tipo_hora = 'NOCTURNA' THEN
            vn_recargos := vn_recargos + r.cantidad_horas * vn_valor_hora * (vn_pct_noct / 100);
        ELSIF r.tipo_hora = 'DOMINICAL' THEN
            vn_recargos := vn_recargos + r.cantidad_horas * vn_valor_hora * (vn_pct_dom / 100);
        ELSIF r.tipo_hora = 'NOCTURNA_DOM' THEN
            vn_recargos := vn_recargos + r.cantidad_horas * vn_valor_hora * (vn_pct_ndom / 100);
        END IF;
    END LOOP;
 
    RETURN NVL(vn_recargos, 0);
END fn_recargos;
/
 
-- Aplicaciòn de la regla 3: bonificacion por antiguedad con verificacion de sanciones
CREATE OR REPLACE FUNCTION fn_bonificacion(
    param_id_emp NUMBER
) RETURN NUMBER IS
    vv_tipo       EMPLEADOS.tipo_contrato%TYPE;
    vd_ingreso    EMPLEADOS.fecha_ingreso%TYPE;
    vn_antiguedad NUMBER(3);
    vn_sanciones  NUMBER(3);
    vn_pct        NUMBER(5,2) := 0;
BEGIN
    SELECT tipo_contrato, fecha_ingreso
    INTO   vv_tipo, vd_ingreso
    FROM   EMPLEADOS
    WHERE  id_empleado = param_id_emp;
 
    -- Los servicios nunca tiene bonificacion
    IF vv_tipo = 'SERVICIOS' THEN
        RETURN 0;
    END IF;
 
    vn_antiguedad := TRUNC(MONTHS_BETWEEN(SYSDATE, vd_ingreso) / 12);
 
    SELECT COUNT(*)
    INTO   vn_sanciones
    FROM   SANCIONES
    WHERE  id_empleado  = param_id_emp
    AND    fecha_sancion >= ADD_MONTHS(SYSDATE, -6);
 
    -- Especificacion sobre que si un empleado tiene màs de 2 sanciones pues pierde bonificacion
    IF vn_sanciones > 2 THEN
        RETURN 0;
    END IF;
 
    IF    vn_antiguedad BETWEEN 3 AND 5  THEN vn_pct := 3;
    ELSIF vn_antiguedad BETWEEN 6 AND 10 THEN vn_pct := 6;
    ELSIF vn_antiguedad > 10             THEN vn_pct := 10;
    END IF;
 
    RETURN fn_salario_base_q(param_id_emp, '2026-Q1-ENE') * vn_pct / 100;
END fn_bonificacion;
/
 
--Aplicaciòn de las reglas 4 Y 5: Y se hace el calculo del bruto total
CREATE OR REPLACE FUNCTION fn_bruto(
    param_id_emp  NUMBER,
    param_id_quin VARCHAR2
) RETURN NUMBER IS
    vv_tipo       EMPLEADOS.tipo_contrato%TYPE;
    vn_salario    EMPLEADOS.salario_base%TYPE;
    vv_sede       EMPLEADOS.cod_sede%TYPE;
    vn_base_q     NUMBER(12,2);
    vn_aux_transp NUMBER(12,2) := 0;
    vn_bono_sede  NUMBER(12,2) := 0;
    vn_smlmv      NUMBER(12,2);
    vn_aux_mens   NUMBER(12,2);
    vn_base_mens  NUMBER(12,2);
    vn_horas_norm NUMBER(5,1)  := 0;
BEGIN
    SELECT tipo_contrato, salario_base, cod_sede
    INTO   vv_tipo, vn_salario, vv_sede
    FROM   EMPLEADOS
    WHERE  id_empleado = param_id_emp;
 
    SELECT MAX(CASE WHEN cod_parametro = 'SMLMV'          THEN valor_numerico END),
           MAX(CASE WHEN cod_parametro = 'AUX_TRANSPORTE' THEN valor_numerico END)
    INTO   vn_smlmv, vn_aux_mens
    FROM   PARAMETROS;
 
    vn_base_q := fn_salario_base_q(param_id_emp, param_id_quin);
 
    -- Aplicaciòn de la regla 4: Auxilio transporte (solo PLANTA y TEMPORAL)
    IF vv_tipo = 'PLANTA' THEN
        vn_base_mens := vn_salario;
    ELSIF vv_tipo = 'TEMPORAL' THEN
        SELECT NVL(cantidad_horas, 0)
        INTO   vn_horas_norm
        FROM   HORAS_TRABAJADAS
        WHERE  id_empleado = param_id_emp
        AND    id_quincena = param_id_quin
        AND    tipo_hora   = 'NORMAL';
        vn_base_mens := vn_salario * vn_horas_norm * 2;
    END IF;
 
    IF vv_tipo != 'SERVICIOS' AND vn_base_mens <= 2 * vn_smlmv THEN
        vn_aux_transp := vn_aux_mens / 2;
    END IF;
 
    -- Aplicaciòn de la regla 5: Bono sede Santa Marta (solo PLANTA y TEMPORAL)
    IF vv_tipo != 'SERVICIOS' AND vv_sede = 'SMA' THEN
        SELECT valor_numerico
        INTO   vn_bono_sede
        FROM   PARAMETROS
        WHERE  cod_parametro = 'BONO_CLIMA_SMA';
    END IF;
 
    -- Aplicaciòn de la regla 6: Bruto = base + recargos + bonif + aux + bono
    -- Regla 6: Bruto = base + recargos + bonif + aux + bono
    RETURN vn_base_q
         + fn_recargos(param_id_emp, param_id_quin)
         + fn_bonificacion(param_id_emp)
         + vn_aux_transp
         + vn_bono_sede;
END fn_bruto;
/

-- Prueba del talller: SELECT fn_bruto(1003, '2026-Q1-ENE') FROM DUAL;---- si funciona :)

/*
Autor: Thomas Duarte Cano y Andres Felipe Gonzalez
Fecha: 20/04/2026
Punto 3
*/

CREATE OR REPLACE PROCEDURE sp_liquidar_empleado (
    param_id_emp  NUMBER,
    param_id_quin VARCHAR2
) IS

    vv_estado     empleados.estado%TYPE;
    vv_tipo       empleados.tipo_contrato%TYPE;
    vv_sede       empleados.cod_sede%TYPE;
    vv_ap_vol     empleados.acepta_aporte_vol%TYPE;
    vn_bruto      NUMBER(12, 2);
    vn_base_q     NUMBER(12, 2);
    vn_salud      NUMBER(12, 2) := 0;
    vn_pension    NUMBER(12, 2) := 0;
    vn_fondo      NUMBER(12, 2) := 0;
    vn_embargo    NUMBER(12, 2) := 0;
    vn_libranzas  NUMBER(12, 2) := 0;
    vn_aporte_vol NUMBER(12, 2) := 0;
    vn_total_ded  NUMBER(12, 2) := 0;
    vn_neto       NUMBER(12, 2) := 0;
    vn_pct_salud  NUMBER(5, 2);
    vn_pct_pens   NUMBER(5, 2);
    vn_pct_fondo  NUMBER(5, 2);
    vn_umbral     NUMBER(5, 2);
    vn_smlmv      NUMBER(12, 2);
    vn_aporte_bog NUMBER(12, 2);
    vn_pct_emb    NUMBER(5, 2);
    vn_cnt        NUMBER(3);
BEGIN
-- Validacion de si existe el empleado
    BEGIN
        SELECT
            estado,
            tipo_contrato,
            cod_sede,
            acepta_aporte_vol
        INTO
            vv_estado,
            vv_tipo,
            vv_sede,
            vv_ap_vol
        FROM
            empleados
        WHERE
            id_empleado = param_id_emp;

    EXCEPTION
        WHEN no_data_found THEN
            raise_application_error(-20001, 'Empleado no encontrado: ' || param_id_emp);
    END;
 
-- Validacion si el empleado esta activo
    IF vv_estado != 'ACTIVO' THEN
        raise_application_error(-20002, 'Empleado no activo: estado = ' || vv_estado);
    END IF;
 
-- Validacion que no exista ya una liquidación para ese empleado y quincena 
    SELECT
        COUNT(*)
    INTO vn_cnt
    FROM
        liquidacion
    WHERE
            id_empleado = param_id_emp
        AND id_quincena = param_id_quin;

    IF vn_cnt > 0 THEN
        raise_application_error(-20003, 'Liquidacion ya existe para empleado '
                                        || param_id_emp
                                        || ' quincena '
                                        || param_id_quin);
    END IF;
 
-- Calcular bruto si se cumplen las validaciones
    vn_bruto := fn_bruto(param_id_emp, param_id_quin);
    vn_base_q := fn_salario_base_q(param_id_emp, param_id_quin);
 
-- Se lee todosparametros para deducciones
    SELECT
        MAX(
            CASE
                WHEN cod_parametro = 'PCT_SALUD' THEN
                    valor_numerico
            END
        ),
        MAX(
            CASE
                WHEN cod_parametro = 'PCT_PENSION' THEN
                    valor_numerico
            END
        ),
        MAX(
            CASE
                WHEN cod_parametro = 'PCT_FONDO_SOLIDARIDAD' THEN
                    valor_numerico
            END
        ),
        MAX(
            CASE
                WHEN cod_parametro = 'UMBRAL_FONDO_SMLMV' THEN
                    valor_numerico
            END
        ),
        MAX(
            CASE
                WHEN cod_parametro = 'SMLMV' THEN
                    valor_numerico
            END
        ),
        MAX(
            CASE
                WHEN cod_parametro = 'APORTE_VOL_BOG' THEN
                    valor_numerico
            END
        )
    INTO
        vn_pct_salud,
        vn_pct_pens,
        vn_pct_fondo,
        vn_umbral,
        vn_smlmv,
        vn_aporte_bog
    FROM
        parametros;
 
-- Regla 7: Las deduciones en orden
    vn_salud := vn_bruto * vn_pct_salud / 100;
    vn_pension := vn_bruto * vn_pct_pens / 100;
    IF ( vn_bruto * 2 ) > ( vn_umbral * vn_smlmv ) THEN
        vn_fondo := vn_bruto * vn_pct_fondo / 100;
    END IF;

    SELECT
        nvl(
            sum(porcentaje),
            0
        )
    INTO vn_pct_emb
    FROM
        embargos
    WHERE
            id_empleado = param_id_emp
        AND estado = 'ACTIVO';

    vn_embargo := ( vn_bruto - vn_salud - vn_pension - vn_fondo ) * vn_pct_emb / 100;
    SELECT
        nvl(sum(cuota_mensual) / 2,
            0)
    INTO vn_libranzas
    FROM
        libranzas
    WHERE
            id_empleado = param_id_emp
        AND estado = 'ACTIVA';

    IF
        vv_sede = 'BOG'
        AND vv_ap_vol = 'S'
    THEN
        vn_aporte_vol := vn_aporte_bog;
    END IF;
    vn_total_ded := vn_salud + vn_pension + vn_fondo + vn_embargo + vn_libranzas + vn_aporte_vol;
    vn_neto := vn_bruto - vn_total_ded;
 
-- Regla 8: El neto nnegativo
    IF vn_neto < 0 THEN
        vn_total_ded := vn_total_ded - vn_embargo;
        vn_embargo := 0;
        vn_neto := vn_bruto - vn_total_ded;
    END IF;

    IF vn_neto < 0 THEN
        vn_total_ded := vn_total_ded - vn_libranzas;
        vn_libranzas := 0;
        vn_neto := vn_bruto - vn_total_ded;
    END IF;
 
-- Insertar resultado en la tabla de LIQUIDACION
    INSERT INTO liquidacion (
        id_liquidacion,
        id_empleado,
        id_quincena,
        salario_base_q,
        recargos,
        bonificacion,
        auxilio_transp,
        bono_sede,
        bruto,
        deduccion_salud,
        deduccion_pension,
        fondo_solidaridad,
        embargo,
        libranzas,
        aporte_voluntario,
        total_deducciones,
        neto
    ) VALUES ( seq_liquidacion.NEXTVAL,
               param_id_emp,
               param_id_quin,
               vn_base_q,
               fn_recargos(param_id_emp, param_id_quin),
               fn_bonificacion(param_id_emp),
               vn_bruto - vn_base_q - fn_recargos(param_id_emp, param_id_quin) - fn_bonificacion(param_id_emp),
               0,
               vn_bruto,
               vn_salud,
               vn_pension,
               vn_fondo,
               vn_embargo,
               vn_libranzas,
               vn_aporte_vol,
               vn_total_ded,
               vn_neto );

    COMMIT;
END sp_liquidar_empleado;
/

-- Prueba 3.1: Empleado que no existe
EXEC sp_liquidar_empleado(9999, '2026-Q1-ENE');

-- Prueba 3.2: Empleado inactivo 
EXEC sp_liquidar_empleado(1005, '2026-Q1-ENE');

-- Prueba 3.3: Liquidación duplicada
EXEC sp_liquidar_empleado(1001, '2026-Q1-ENE');

/*
Autor: Thomas Duarte Cano y Andres Felipe Gonzalez
Fecha: 20/04/2026
Punto 4
*/



/*
Autor: Thomas Duarte Cano y Andres Felipe Gonzalez
Fecha: 20/04/2026
Punto 5
*/

CREATE OR REPLACE TRIGGER TGR_liq_nomina
FOR INSERT ON LIQUIDACION
COMPOUND TRIGGER

    vb_ajustado BOOLEAN := FALSE;

    BEFORE EACH ROW IS
    BEGIN
        IF :NEW.salario_base_q < 0 THEN
            RAISE_APPLICATION_ERROR(-20010, 'Salario base no puede ser negativo');
        END IF;

        IF :NEW.neto < 0 THEN
            :NEW.total_deducciones := :NEW.total_deducciones - :NEW.embargo;
            :NEW.embargo           := 0;
            :NEW.neto              := :NEW.bruto - :NEW.total_deducciones;
            vb_ajustado            := TRUE;

            IF :NEW.neto < 0 THEN
                :NEW.total_deducciones := :NEW.total_deducciones - :NEW.libranzas;
                :NEW.libranzas         := 0;
                :NEW.neto              := :NEW.bruto - :NEW.total_deducciones;
            END IF;
        END IF;
    END BEFORE EACH ROW;

    AFTER EACH ROW IS
    BEGIN

        IF vb_ajustado THEN
            INSERT INTO LOG_NOMINA (id_log, operacion, usuario, detalle)
            VALUES (SEQ_LOG.NEXTVAL, 'ALERTA_NETO_NEGATIVO', USER,
                    'Emp ' || :NEW.id_empleado || ' quin ' || :NEW.id_quincena || ' neto ajustado a: ' || :NEW.neto);
            vb_ajustado := FALSE;
        END IF;

        IF :NEW.libranzas > 0 THEN
            UPDATE LIBRANZAS
            SET    saldo_pendiente = saldo_pendiente - :NEW.libranzas
            WHERE  id_empleado = :NEW.id_empleado AND estado = 'ACTIVA';

            UPDATE LIBRANZAS
            SET    estado = 'PAGADA'
            WHERE  id_empleado = :NEW.id_empleado AND estado = 'ACTIVA' AND saldo_pendiente <= 0;
        END IF;
    END AFTER EACH ROW;

    AFTER STATEMENT IS
    BEGIN
        INSERT INTO LOG_NOMINA (id_log, operacion, usuario, detalle)
        VALUES (SEQ_LOG.NEXTVAL, 'INSERT_LIQUIDACION', USER,
                'Lote procesado a las ' || TO_CHAR(SYSTIMESTAMP, 'HH24:MI:SS.FF3'));
    END AFTER STATEMENT;

END TGR_liq_nomina;
/

-- PUNTO 6
-- PUNTO 7
-- PUNTO 8

