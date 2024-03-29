CREATE OR REPLACE PACKAGE REPORT_TRANSIT IS
  --тип данных строки, возвращаемой GetTest
  TYPE ROWGETRES IS RECORD(
    NAPR      VARCHAR2(4000 BYTE),
    IN_CARR   VARCHAR2(20 BYTE),
    MANAGER   VARCHAR2(20 BYTE),
    OUT_CARR  VARCHAR2(20 BYTE),
    CNT       NUMBER,
    DUR       NUMBER,
    CURR_IN   VARCHAR2(3 BYTE),
    CURR_OUT  VARCHAR2(3 BYTE),
    RATE_IN   NUMBER,
    RATE_OUT  NUMBER,
    RATE_IN$  NUMBER,
    RATE_OUT$ NUMBER,
    COST_IN   NUMBER,
    COST_OUT  NUMBER,
    COST_ALL  NUMBER);
  TYPE ROWGETCROSSRATE IS RECORD(
    CROSSRATE NUMBER);

  TYPE TBLGETRES IS TABLE OF ROWGETRES;
  TYPE TBLGETCROSSRATE IS TABLE OF ROWGETCROSSRATE;

  FUNCTION GETREPTRANS(PARTUN    DATE DEFAULT SYSDATE,
                       SWITCH_ID NUMBER DEFAULT NULL) RETURN TBLGETRES
    PIPELINED;

  FUNCTION GETCROSSRATE(PARTUN DATE DEFAULT SYSDATE) RETURN TBLGETCROSSRATE
    PIPELINED;

  FUNCTION GET_STATUS(P_PERIOD IN DATE) RETURN VARCHAR2;

  PROCEDURE START_BUILD_DT;
  --RETURN VARCHAR2;

END REPORT_TRANSIT;
/

CREATE OR REPLACE PACKAGE BODY REPORT_TRANSIT
IS

/*
--SET SERVEROUTPUT ON -- NEED FIRST STAR
BEGIN
REPORT_TRANSIT.START_BUILD_DT();
END;
*/

FUNCTION GETCROSSRATE(
    PARTUN DATE DEFAULT SYSDATE)
  RETURN TBLGETCROSSRATE PIPELINED
IS
  A_FIRST_DATE  DATE;
  A_LAST_DATE   DATE;
  EXCHANGE_RATE NUMBER(12,6);
BEGIN
  A_FIRST_DATE := TRUNC(PARTUN,'MM');
  A_LAST_DATE   := ADD_MONTHS(A_FIRST_DATE,1);

  FOR CURR IN
  (
    SELECT EXCHANGE_RATE
    FROM
      (SELECT E.EXCHANGE_RATE,
        E.FROM_DATE
      FROM UT32.CURRENCY_RATE E
      WHERE E.FROM_DATE < A_LAST_DATE
      --AND E.FROM_DATE  >= A_FIRST_DATE
      AND E.CURR_CD     = 'EUR'
      ORDER BY E.FROM_DATE DESC
      )
    WHERE ROWNUM < 2
  )
  LOOP
    PIPE ROW (CURR);
  END LOOP;

END GETCROSSRATE;

FUNCTION GETREPTRANS(
    PARTUN DATE DEFAULT SYSDATE,
    SWITCH_ID NUMBER DEFAULT NULL)
  RETURN TBLGETRES PIPELINED
IS
  A_FIRST_DATE  DATE;
  A_LAST_DATE   DATE;
  EXCHANGE_RATE NUMBER(12,6);
  DATESTART     DATE;
  STATUS        NUMBER(20,0);
BEGIN
  A_FIRST_DATE := TRUNC(PARTUN,'DD');
  A_LAST_DATE   := ADD_MONTHS(A_FIRST_DATE,1);

  SELECT CROSSRATE INTO EXCHANGE_RATE FROM TABLE(REPORT_TRANSIT.GETCROSSRATE(A_FIRST_DATE));

  SELECT COUNT (*) INTO STATUS FROM DOUBLE_TR_REP
  WHERE DT >= A_FIRST_DATE AND DT < A_LAST_DATE;


  IF (STATUS > 0 AND SWITCH_ID IS NULL) THEN
    FOR CURR IN
    (
      SELECT T.*,
      T.COST_IN - T.COST_OUT COST_ALL
    FROM
      (SELECT 
    --UT32.PG_AGR_MODEL.F_GET_CHARGE_BAND_NAME( CHARGE_BAND_ID ) NAPR_PAKET,
      T.CHARGE_BAND_NAME NAPR,
        IN_CARR,
        MANAGER,
        OUT_CARR,
        CNT,
        ROUND(DUR,1) DUR,
        CURR_IN,
        CURR_OUT,
        ROUND(RATE_IN,5),
        ROUND(RATE_OUT,5),
        ROUND(
        CASE
          WHEN CURR_IN = 'EUR'
          THEN RATE_IN*EXCHANGE_RATE
          ELSE RATE_IN
        END, 4) RATE_IN$,
        ROUND(
        CASE
          WHEN CURR_OUT = 'EUR'
          THEN RATE_OUT*EXCHANGE_RATE
          ELSE RATE_OUT
        END, 4) RATE_OUT$,
        ROUND(
        CASE
          WHEN CURR_IN = 'EUR'
          THEN DUR*RATE_IN*EXCHANGE_RATE
          ELSE DUR*RATE_IN
        END, 2) COST_IN,
        ROUND(
        CASE
          WHEN CURR_OUT = 'EUR'
          THEN DUR*RATE_OUT*EXCHANGE_RATE
          ELSE DUR*RATE_OUT
        END, 2) COST_OUT
      FROM
        (SELECT D.CHARGE_BAND_ID, VM.CHARGE_BAND_NAME,
          IN_CARR,
          CP.NAME MANAGER,
          OUT_CARR,
          RATE_OUT,
          CURR_OUT,
          RATE_IN,
          CURR_IN,
          SUM(CNT) CNT,
          ROUND(SUM(DUR)/60,1) DUR
        FROM DOUBLE_TR_REP D, UT32.VML_CHARGE_BAND VM, UT32.V_CARRIER_PERSON CP
        WHERE 1=1
    AND D.CHARGE_BAND_ID = VM.CHARGE_BAND_ID
    AND CP.POSITION_CD='MANAGER_FOR_UKR_TEL'
 AND CP.LANG_CD='RUS'
 AND CP.CARR_CD=D.IN_CARR
        AND DT >= A_FIRST_DATE
        AND DT < A_LAST_DATE
        GROUP BY D.CHARGE_BAND_ID, VM.CHARGE_BAND_NAME,
          IN_CARR,
          CP.NAME,
          OUT_CARR,
          RATE_OUT,
          CURR_OUT,
          RATE_IN,
          CURR_IN
        --ORDER BY 1,2,3
        ) T
      ) T
    ORDER BY NLSSORT(NAPR, 'NLS_SORT=RUSSIAN'),2,3
    )
    LOOP
      PIPE ROW (CURR);
    END LOOP;
  ELSIF (STATUS > 0 AND SWITCH_ID IS NOT NULL) THEN
    FOR CURR IN
    (
      SELECT T.*,
      T.COST_IN - T.COST_OUT COST_ALL
    FROM
      (SELECT 
      --UT32.PG_AGR_MODEL.F_GET_CHARGE_BAND_NAME( CHARGE_BAND_ID ) NAPR,
    T.CHARGE_BAND_NAME NAPR,
        IN_CARR,
        MANAGER,
        OUT_CARR,
        CNT,
        ROUND(DUR,1) DUR,
        CURR_IN,
        CURR_OUT,
        ROUND(RATE_IN,5),
        ROUND(RATE_OUT,5),
        ROUND(
        CASE
          WHEN CURR_IN = 'EUR'
          THEN RATE_IN*EXCHANGE_RATE
          ELSE RATE_IN
        END, 4) RATE_IN$,
        ROUND(
        CASE
          WHEN CURR_OUT = 'EUR'
          THEN RATE_OUT*EXCHANGE_RATE
          ELSE RATE_OUT
        END, 4) RATE_OUT$,
        ROUND(
        CASE
          WHEN CURR_IN = 'EUR'
          THEN DUR*RATE_IN*EXCHANGE_RATE
          ELSE DUR*RATE_IN
        END, 2) COST_IN,
        ROUND(
        CASE
          WHEN CURR_OUT = 'EUR'
          THEN DUR*RATE_OUT*EXCHANGE_RATE
          ELSE DUR*RATE_OUT
        END, 2) COST_OUT
      FROM
        (SELECT D.CHARGE_BAND_ID, VM.CHARGE_BAND_NAME,
          IN_CARR,
          CP.NAME MANAGER,
          OUT_CARR,
          RATE_OUT,
          CURR_OUT,
          RATE_IN,
          CURR_IN,
          SUM(CNT) CNT,
          ROUND(SUM(DUR)/60,1) DUR
        FROM DOUBLE_TR_REP D, UT32.VML_CHARGE_BAND VM, UT32.V_CARRIER_PERSON CP
        WHERE 1=1
    AND D.CHARGE_BAND_ID = VM.CHARGE_BAND_ID
        AND DT >= A_FIRST_DATE
        AND DT < A_LAST_DATE
        AND SWITCH_IN=SWITCH_OUT
         AND        CP.POSITION_CD='MANAGER_FOR_UKR_TEL'
 AND CP.LANG_CD='RUS'
 AND CP.CARR_CD=D.IN_CARR
        GROUP BY D.CHARGE_BAND_ID, VM.CHARGE_BAND_NAME,
          IN_CARR,
          CP.NAME,
          OUT_CARR,
          RATE_OUT,
          CURR_OUT,
          RATE_IN,
          CURR_IN
        --ORDER BY 1,2,3
        ) T
      ) T
    ORDER BY NLSSORT(NAPR, 'NLS_SORT=RUSSIAN'),2,3
    )
    LOOP
      PIPE ROW (CURR);
    END LOOP;
  ELSE
    --CREATE_JOB(A_FIRST_DATE);
    FOR CURR IN
    (SELECT 'Wait 10 minutes' NAPR,'' IN_CARR,
    '' MANAGER,
        '' OUT_CARR,
        0 CNT,
        0 DUR, 
        '' CURR_IN, 
        '' CURR_OUT,
        0 RATE_IN,
        0 RATE_OUT,
        0 RATE_IN$,
        0 RATE_OUT$,
        0 COST_IN,
        0 COST_OUT,
        0 COST_ALL FROM DUAL
    ) LOOP
      PIPE ROW (CURR);
    END LOOP;
  END IF;
  
END GETREPTRANS;


FUNCTION GET_STATUS(P_PERIOD IN DATE)
RETURN VARCHAR2
IS
  DDL_STMT VARCHAR2(512);
  ST        NUMBER;
  DT_OLD    DATE;
  A_FIRST_DATE  DATE;
  A_LAST_DATE   DATE;
  UNIQUE_CONSTRAINT  EXCEPTION;
  PRAGMA EXCEPTION_INIT(UNIQUE_CONSTRAINT, -00001);
BEGIN
  A_FIRST_DATE := TRUNC(P_PERIOD,'MM');
  A_LAST_DATE   := ADD_MONTHS(A_FIRST_DATE,1);

  BEGIN
    SELECT STATUS,DATESTART INTO ST,DT_OLD FROM QUEUE_REP WHERE PERIOD = TRUNC(P_PERIOD,'MM');
    EXCEPTION
    WHEN NO_DATA_FOUND THEN ST := NULL;
  END;
  
  IF (ST IS NULL) THEN
    BEGIN
      INSERT INTO QUEUE_REP (ID,PERIOD,STATUS) VALUES (SEQ_QUEUE_REP.NEXTVAL,TRUNC(P_PERIOD,'MM'),1);
      COMMIT;
      EXCEPTION
        WHEN UNIQUE_CONSTRAINT THEN NULL;
        --DBMS_OUTPUT.PUT_LINE ('unique_constraint');
      --WHEN OTHERS THEN NULL;
    END;
    RETURN 'start';
  ELSIF (ST=1) THEN
    RETURN 'wait';
  ELSIF (ST=2 AND DT_OLD<TRUNC(SYSDATE)) THEN
    UPDATE QUEUE_REP SET STATUS=1 WHERE PERIOD = TRUNC(P_PERIOD,'MM');
    DELETE FROM DOUBLE_TR_REP WHERE DT >= A_FIRST_DATE AND DT < A_LAST_DATE;

    COMMIT;
    RETURN 'start';
  ELSE
    RETURN 'ok';
  
  END IF;
  RETURN NULL;
END GET_STATUS;


PROCEDURE START_BUILD_DT/*(P_PERIOD IN DATE)*/
--RETURN VARCHAR2
IS
  A_FIRST_DATE  DATE;
  A_LAST_DATE   DATE;
  LV_SQL        VARCHAR2(32000);
  ST        NUMBER;
  CNT        NUMBER;
  DT_OLD    DATE;
  MIN_CDR VARCHAR2 (9500);
  MAX_CDR VARCHAR2 (9500);
  CDR_SUM_MIN VARCHAR2 (9500);
  CDR_SUM_MAX VARCHAR2 (9500);

  D NUMBER:=1; -- КОЛИЧЕСТВО СЕКУНД
  DDL_STMT VARCHAR2(512);

  UNIQUE_CONSTRAINT  EXCEPTION;
  PRAGMA EXCEPTION_INIT(UNIQUE_CONSTRAINT, -00001);

BEGIN

  BEGIN
    SELECT STATUS,PERIOD INTO ST,DT_OLD FROM (SELECT STATUS,PERIOD FROM QUEUE_REP WHERE STATUS=1 ORDER BY ID) WHERE ROWNUM < 2;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN ST := NULL;
  END;
  
  IF (ST = 1) THEN

  A_FIRST_DATE := TRUNC(DT_OLD,'MM');
  A_LAST_DATE  := ADD_MONTHS(A_FIRST_DATE,1);

  SELECT MIN(PRIM_KEY_MIN) INTO MIN_CDR FROM ( SELECT P.PRIM_KEY_MIN, P.PRIM_KEY_MAX 
  FROM DBA_TAB_PARTITIONS S, UT32.PART_LIST P
  WHERE P.PART_TABLE='CDR' AND S.TABLE_NAME=P.PART_TABLE AND S.PARTITION_NAME=P.PART_NAME 
  AND P.DATE_MAX >= A_FIRST_DATE
  AND P.DATE_MIN <  A_LAST_DATE );

  SELECT MAX(PRIM_KEY_MAX) INTO MAX_CDR FROM ( SELECT P.PRIM_KEY_MIN, P.PRIM_KEY_MAX 
  FROM DBA_TAB_PARTITIONS S, UT32.PART_LIST P
  WHERE P.PART_TABLE='CDR' AND S.TABLE_NAME=P.PART_TABLE AND S.PARTITION_NAME=P.PART_NAME 
  AND P.DATE_MAX >= A_FIRST_DATE
  AND P.DATE_MIN <  A_LAST_DATE ); 
  
  SELECT
  TO_CHAR(TO_NUMBER (TO_CHAR(TRUNC(A_FIRST_DATE,'YY'),'YYYY')) - TO_NUMBER(TO_CHAR(TO_DATE(2008,'YYYY'),'YYYY')))
  || TO_CHAR(A_FIRST_DATE,'DDD') || '0000000000' C INTO CDR_SUM_MIN 
  FROM DUAL;
  
  SELECT
  TO_CHAR(TO_NUMBER (TO_CHAR(TRUNC(A_LAST_DATE,'YY'),'YYYY')) - TO_NUMBER(TO_CHAR(TO_DATE(2008,'YYYY'),'YYYY')))
  || TO_CHAR(A_LAST_DATE,'DDD') || '0000000000' C INTO CDR_SUM_MAX 
  FROM DUAL;
    
  DBMS_OUTPUT.PUT_LINE(SYSDATE);
  
    DBMS_UTILITY.EXEC_DDL_STATEMENT ('truncate table CDR_SEL_TEMP');
    INSERT INTO CDR_SEL_TEMP
    --CREATE TABLE CDR_SEL_TEMP AS 
      SELECT /*+ PARALLEL(8) USE_HASH(SS CS) */
        CS.CDR_SUM_ID
        , ES.ENDMONTH_SUM_ID
        , CS.CDR_GROUP_ID
        --, ST.AMOUNT
        , ES.NO_OF_CALLS -- КОЛ-ВО ЗВОНКОВ ЗА МЕСЯЦ
        , ES.ROUND_AMOUNT  -- КОЛ-ВО МИНУТ ЗА МЕСЯЦ
        , ES.RATE
        , ES.CURR_CD
        , SS.STL_DIR_CD --НАПРАВЛЕНИЕ ПЛАТЕЖА
        , CS.IN_OR_OUT --НАПРАВЛЕНИЕ ТРАФИКА
        , MV.CHARGE_BAND_ID
        , MV.PRODUCT
        , SS.TARGET_CARR_CD CARR_CD
    , CG.OUT_DES_CD -- ID_DIR_B
        , CG.IN_DES_CD  -- ID_DIR_A
        FROM UT32.ENDMONTH_VERSION EV, UT32.ENDMONTH_SUMMARY ES, UT32.CDR_SUMMARY CS, UT32.STL_SUMMARY SS, UT32.CDR_STL ST, 
         UT32.MV_AGREE_ENDMONTH MV, UT32.MEASURE_UNIT MC, UT32.MEASURE_UNIT MP, UT32.CDR_GROUP CG
        WHERE 1=1
          AND EV.END_DATE >= TRUNC(A_FIRST_DATE,'MM') 
          AND EV.END_DATE <  ADD_MONTHS(TRUNC(A_LAST_DATE,'MM'),1)
          AND EV.ENDMONTH_ID = ES.ENDMONTH_ID
          AND ES.PHASE_CD = '4'
          AND ES.EOP_MAN_ID IS NULL
          AND MV.ENDMONTH_SUM_ID = ES.ENDMONTH_SUM_ID
          AND MC.MEAS_CD = MV.CDR_MEAS_CD
          AND MP.MEAS_CD = MV.PRICE_MEAS_CD
          AND SS.ENDMONTH_SUM_ID = ES.ENDMONTH_SUM_ID
          AND CG.CDR_GROUP_ID = CS.CDR_GROUP_ID
          AND CS.PHASE_CD = '4'
          AND CS.EXCEPT_ID IS NULL
          AND CS.IGNORE IS NULL
          AND ST.NO_OF_CALLS !=0
          AND ES.RATE !=0
          AND CS.CDR_SUM_ID >= CDR_SUM_MIN         --UT32.PG_COMMON.F_DATE2CDR_SUM_ID(A_FIRST_DATE)             
          AND CS.CDR_SUM_ID <  CDR_SUM_MAX         --UT32.PG_COMMON.F_DATE2CDR_SUM_ID(ADD_MONTHS(A_FIRST_DATE,1))
          AND CS.CDR_SUM_ID = ST.CDR_SUM_ID 
          AND ST.CDR_SUM_ID >= CDR_SUM_MIN         --UT32.PG_COMMON.F_DATE2CDR_SUM_ID(A_FIRST_DATE)
          AND ST.CDR_SUM_ID <  CDR_SUM_MAX         --UT32.PG_COMMON.F_DATE2CDR_SUM_ID(ADD_MONTHS(A_FIRST_DATE,1))
          AND ST.STL_SUM_ID = SS.STL_SUM_ID
          AND SS.EXCEPT_ID IS NULL
          AND SS.THE_DATE >= A_FIRST_DATE
          AND SS.THE_DATE <  A_LAST_DATE 
      ;
  
    DBMS_UTILITY.EXEC_DDL_STATEMENT ('truncate table CDR_SEL_RES');
    LV_SQL := 'insert into CDR_SEL_RES
      SELECT /*+ ORDERED parallel(4) */
           C.CDR_ID
    , C.RECORD_CODE
    , C.SEIZURE_TM
    , C.DISCONNECT_TM
    , C.SWITCH_CD
    , C.CALLED_NUM
    , C.IN_TRK_GRP
    --, C.SEQUENCE_NO
    --, C.ANSWER_TM
    , C.CALLING_NUM
    --, C.CALLING_PARTY
    , C.ORIG_CALLED_NUM
    , C.ORIG_CALLING_NUM
    , TM.ENDMONTH_SUM_ID
    --, TM.CDR_GROUP_ID
    , TM.NO_OF_CALLS -- Кол-во звонков за месяц
    , TM.ROUND_AMOUNT  -- кол-во минут за месяц
    , TM.RATE
    , TM.CURR_CD
    , TM.STL_DIR_CD --направление платежа
    , TM.IN_OR_OUT --Направление трафика
    , TM.charge_band_id
    , TM.product
    , TM.carr_cd
  , c.OUT_TRK_GRP
  , TM.out_des_cd -- id_dir_b
    , TM.in_des_cd  -- id_dir_a
    FROM CDR_SEL_TEMP TM, ut32.cdr_detail cd, ut32.cdr c
    WHERE 1=1
    AND c.cdr_id = cd.cdr_id
    AND C.DISCONNECT_TM > C.SEIZURE_TM
    AND tm.cdr_sum_id = cd.cdr_sum_id
    AND ( c.cdr_id BETWEEN '||MIN_CDR||' AND '||MAX_CDR||' )'
  ;
      
  EXECUTE IMMEDIATE LV_SQL;
  
  COMMIT;
  
  DBMS_UTILITY.EXEC_DDL_STATEMENT ('TRUNCATE TABLE TMP_IN_TRAF');
  
  INSERT INTO  TMP_IN_TRAF (CDR_ID, CARR_CD, SEIZURE_TM, DUR, CALLING_NUM, CALLED_NUM, SWITCH_CD, RATE, CURR_CD, COST, IN_OR_OUT,CHARGE_BAND_ID,PRODUCT)
  SELECT 
  /*+ PARALLEL(4) */ CDR_ID, CARR_CD, SEIZURE_TM, ROUND((DISCONNECT_TM-SEIZURE_TM)*86400) DUR, CALLING_NUM, CALLED_NUM, SWITCH_CD,
  RATE, CURR_CD, ROUND((DISCONNECT_TM-SEIZURE_TM)*1440*RATE, 4) COST, IN_OR_OUT,CHARGE_BAND_ID,PRODUCT
  FROM CDR_SEL_RES
  WHERE 1=1
  AND IN_OR_OUT = 'I';
  
  COMMIT;
  
  DBMS_UTILITY.EXEC_DDL_STATEMENT ('TRUNCATE TABLE TMP_OUT_TRAF');
  
  INSERT INTO  TMP_OUT_TRAF (CDR_ID, CARR_CD, SEIZURE_TM, DUR, CALLING_NUM, CALLED_NUM, SWITCH_CD, RATE, CURR_CD, COST, IN_OR_OUT,CHARGE_BAND_ID,PRODUCT)
  SELECT 
  /*+ PARALLEL(4) */ CDR_ID, CARR_CD, SEIZURE_TM, ROUND((DISCONNECT_TM-SEIZURE_TM)*86400) DUR, CALLING_NUM, CALLED_NUM, SWITCH_CD,
  RATE, CURR_CD, ROUND((DISCONNECT_TM-SEIZURE_TM)*1440*RATE, 4) COST, IN_OR_OUT,CHARGE_BAND_ID,PRODUCT
  FROM CDR_SEL_RES
  WHERE 1=1
  AND IN_OR_OUT = 'O';

  COMMIT;
                   
      D:=1; -- КОЛИЧЕСТВО СЕКУНД
      FOR C IN 1..10 LOOP
        FOR CC IN ( SELECT T.CDR_ID, T.IN_OR_OUT, T.SEIZURE_TM DT, T.CALLED_NUM, ROUND(T.DUR) DUR FROM TMP_OUT_TRAF T 
          WHERE OUT01 IS NULL AND T.SEIZURE_TM >= A_FIRST_DATE AND T.SEIZURE_TM < A_LAST_DATE ) LOOP
          FOR CI IN ( SELECT T.* 
                        FROM TMP_IN_TRAF T 
                       WHERE OUT01 IS NULL
                       AND T.SEIZURE_TM >= A_FIRST_DATE AND T.SEIZURE_TM < A_LAST_DATE
                       AND CALLED_NUM=CC.CALLED_NUM
                       AND T.IN_OR_OUT != CC.IN_OR_OUT
                       AND (SEIZURE_TM BETWEEN CC.DT-D/86400 AND CC.DT+D/86400 /*OR SEIZURE_TM BETWEEN CC.DT-7/24-D/86400 AND CC.DT-7/24+D/86400*/ )
                       AND ROUND(DUR) BETWEEN CC.DUR-1 AND CC.DUR+1
                    ORDER BY ABS(86400*(SEIZURE_TM-CC.DT))
            ) LOOP
            UPDATE TMP_OUT_TRAF SET OUT01=D, OUT02=CI.CDR_ID WHERE CDR_ID=CC.CDR_ID;
            UPDATE TMP_IN_TRAF SET OUT01=D, OUT02=CC.CDR_ID WHERE CDR_ID=CI.CDR_ID;
            --COMMIT;
            EXIT;
          END LOOP;
        END LOOP;
        D:=D+1;
      END LOOP;
  
  COMMIT;

  DELETE FROM DOUBLE_TR_REP WHERE DT >= A_FIRST_DATE AND DT < A_LAST_DATE;
    
    --CREATE TABLE DOUBLE_TR_REP AS
    INSERT INTO DOUBLE_TR_REP
    SELECT TRUNC(T1.SEIZURE_TM,'HH24') DT,
    T2.CHARGE_BAND_ID CHARGE_BAND_ID, T1.CARR_CD IN_CARR,T2.CARR_CD OUT_CARR, T2.RATE RATE_OUT,T2.CURR_CD CURR_OUT, T1.RATE RATE_IN,T1.CURR_CD CURR_IN,
    T1.SWITCH_CD SWITCH_IN, T2.SWITCH_CD SWITCH_OUT,
    COUNT(T2.DUR) CNT, SUM(T2.DUR) DUR
    FROM TMP_IN_TRAF T1,TMP_OUT_TRAF T2
    WHERE T1.CDR_ID = T2.OUT02
    AND T1.SEIZURE_TM >= A_FIRST_DATE
    AND T1.SEIZURE_TM <  A_LAST_DATE
    GROUP BY TRUNC(T1.SEIZURE_TM,'HH24'),T2.CHARGE_BAND_ID, T1.CARR_CD,T2.CARR_CD,T2.RATE,T2.CURR_CD,T1.RATE,T1.CURR_CD,T1.SWITCH_CD, T2.SWITCH_CD;

    SELECT COUNT(*),ROUND(SUM(DUR)/60) INTO CNT,D 
    FROM TMP_IN_TRAF
    WHERE OUT02 IS NULL
    AND PRODUCT IN ('TDM_IDDD','VOIP_IDDD')
    AND SEIZURE_TM >= A_FIRST_DATE
    AND SEIZURE_TM <  A_LAST_DATE;
  
    SELECT STATUS,PERIOD INTO ST,DT_OLD FROM (SELECT STATUS,PERIOD FROM QUEUE_REP WHERE STATUS=1 ORDER BY ID) WHERE ROWNUM < 2;
    IF (TRUNC(DT_OLD,'MM')>=TRUNC(SYSDATE-2,'MM')) THEN
      UPDATE QUEUE_REP SET STATUS = 2, DATESTART=SYSDATE, CNT_UNIQ = CNT, DUR_UNIQ = D WHERE PERIOD = TRUNC(DT_OLD,'MM');
    ELSE
      UPDATE QUEUE_REP SET STATUS = 3, DATESTART=SYSDATE, CNT_UNIQ = CNT, DUR_UNIQ = D WHERE PERIOD = TRUNC(DT_OLD,'MM');
    END IF;
    COMMIT;
  END IF;

    DBMS_OUTPUT.PUT_LINE(SYSDATE);

END START_BUILD_DT;

END REPORT_TRANSIT;
/
