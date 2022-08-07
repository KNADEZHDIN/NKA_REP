--Associative Arrays (ассоциативный массив) https://oracleplsql.ru/associative-arrays-oracle-plsql.html
DECLARE
  TYPE PAR_TABLE IS TABLE OF VARCHAR2(500) INDEX BY VARCHAR2(100);
  PAR_VALUE PAR_TABLE;

  V_NAME VARCHAR2(100);

BEGIN

  PAR_VALUE('par1') := 'test1';
  PAR_VALUE('par2') := 'test2';
  PAR_VALUE('par3') := 'test3';
  PAR_VALUE('par4') := 'test4';

  V_NAME := PAR_VALUE.FIRST;

  WHILE V_NAME IS NOT NULL LOOP
  
    --DBMS_OUTPUT.PUT_LINE(V_NAME);
  
    DBMS_OUTPUT.PUT_LINE( V_NAME ||'; '|| PAR_VALUE(V_NAME) );
  
    V_NAME := PAR_VALUE.NEXT(V_NAME); -- Get next element of array
  
  END LOOP;

  --DBMS_OUTPUT.PUT_LINE(PAR_VALUE.FIRST);
  --DBMS_OUTPUT.PUT_LINE(PAR_VALUE('par1'));

  --PAR_VALUE.delete;
  --DBMS_OUTPUT.PUT_LINE(PAR_VALUE.count);

END;
/

-- ЗА СЧЕТ ПАРАМЕТРА ВСЕ ЗАПИСИ ИЛИ ТОЛЬКО КОНКРЕТНАЯ ЗАПИСЬ
DECLARE
  --P_ACCOUNT VARCHAR2(100) NULL;
  P_ACCOUNT VARCHAR2(100) := '2926427';
BEGIN

  FOR CC IN (SELECT CH.ACCOUNT
               FROM WCB.CLIENT_HISTORIES_V CH
              WHERE 1 = 1
                --AND (CH.ACCOUNT = P_ACCOUNT OR P_ACCOUNT IS NULL)
                AND (INSTR(',' || P_ACCOUNT || ',', ',' || TO_CHAR(CH.ACCOUNT) || ',') > 0 OR P_ACCOUNT IS NULL)
                AND ROWNUM <= 10) LOOP
  
    DBMS_OUTPUT.PUT_LINE(CC.ACCOUNT);
  
  END LOOP;

END;
/

--ТРИГГЕР КОТОРЫЙ ПРОВЕРЯЕТ ГРАНТЫ
set serveroutput on -- Need first start
DECLARE
v_account_old  client_histories.account%TYPE;
ST_ROLE VARCHAR2(200);
EXE_ROLE_RATE VARCHAR2(200);
EXE_ROLE_CARR VARCHAR2(200);
BEGIN

EXE_ROLE_RATE:='Grant select on ut32.currency_rate to MS_REP_VAZDB';
EXE_ROLE_CARR:='Grant select on ut32.v_carrier_person to MS_REP_VAZDB';

SELECT CASE WHEN COUNT(*)=0 THEN 'NOT_PRIV_TLSNS' ELSE 'YES_PRIV_TLSNS' END
INTO ST_ROLE
FROM DBA_TAB_PRIVS
WHERE GRANTEE LIKE 'MS_REP_VAZDB'
AND TABLE_NAME IN ('V_CARRIER_PERSON','CURRENCY_RATE')
AND PRIVILEGE = 'SELECT' AND OWNER = 'UT32';

IF ST_ROLE = 'NOT_PRIV_TLSNS' THEN EXECUTE IMMEDIATE EXE_ROLE_RATE; END IF;
IF ST_ROLE = 'NOT_PRIV_TLSNS' THEN EXECUTE IMMEDIATE EXE_ROLE_CARR; END IF;
--DBMS_OUTPUT.put_line (ST_ROLE);
END;

--Булевые значения
BEGIN
  DBMS_OUTPUT.PUT_LINE(SYS.DIUTIL.BOOL_TO_INT(FALSE));
  DBMS_OUTPUT.PUT_LINE(SYS.DIUTIL.BOOL_TO_INT(TRUE));
END;
/

set SERVEROUTPUT on -- Need first start
BEGIN
  FOR cc IN ( select ss.sid, ss.serial#
               from sys.gv$session ss
               where ss.schemaname = 'HR' ) LOOP
  DBMS_OUTPUT.PUT_LINE('ALTER SYSTEM KILL SESSION '''||cc.sid||', '||cc.SERIAL#||''' IMMEDIATE'); --вывод на экран 
  --EXECUTE IMMEDIATE 'ALTER SYSTEM KILL SESSION '''||cc.sid||', '||cc.SERIAL#||''' IMMEDIATE';
  END LOOP;
END;
/


DECLARE
  V_ID NUMBER;
BEGIN

  FOR CC IN (SELECT '1' DD FROM DUAL UNION ALL SELECT '2' FROM DUAL UNION ALL SELECT 'x' FROM DUAL UNION ALL SELECT '4' FROM DUAL) LOOP
  
    BEGIN
      V_ID := TO_NUMBER(CC.DD);
    
      --DBMS_OUTPUT.PUT_LINE(V_ID);
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
        --DBMS_OUTPUT.PUT_LINE('LOG - ' || CC.DD || ' - ' || SQLERRM);
        CONTINUE;
        --EXIT;
    END;
  
    DBMS_OUTPUT.PUT_LINE(CC.DD);
  
  END LOOP;

END;
/

--пример простой ф-и
----------------------------
  FUNCTION GETSYSIDFCS RETURN NUMBER IS
    V_SYSIDFCS NUMBER;
  BEGIN
    BEGIN
      SELECT P.VALUE_NUMBER INTO V_SYSIDFCS FROM FCS.FCS_PARAMETERS P WHERE P.PARAM_NAME = 'FCS_SYSTEM_ID';
    EXCEPTION
      WHEN OTHERS THEN
        V_SYSIDFCS := NULL;
    END;
    RETURN V_SYSIDFCS;
  END;
----------------------------
DBMS_LOCK.SLEEP(3); --спим 3 сек
----------------------------
SQL%ROWCOUNT
SQL%FOUND
SQL%NOTFOUND
$$PLSQL_UNIT
$$plsql_line
----------------------------
EXCEPTION:
NO_DATA_FOUND
DUP_VAL_ON_INDEX
RAISE_APPLICATION_ERROR(-20101, 'На данный момент в таблице адресов доставки (WCB.DLV_HISTORIES) нет данных'); 
SQLERRM
SQLCODE
----------------------------
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        IF P_IS_FIRST_ADDRESS = 1 THEN NULL;
           ELSE
            RAISE_APPLICATION_ERROR(-20101, 'На данный момент в таблице адресов абонентов (WCB.SUBS_ADR_HISTORIES) нет данных'); 
        END IF;
      WHEN OTHERS THEN
        IF P_IS_FIRST_ADDRESS = 1 THEN NULL;
           ELSE
            RAISE_APPLICATION_ERROR(-20101, 'По таблице адресов абонентов (WCB.SUBS_ADR_HISTORIES) при считывании исторических данных возникли технические проблемы'|| SQLERRM);
         END IF;
----------------------------		 
--обьявить функцию в анонимном блоке
DECLARE
V_VAR VARCHAR2(1000);
FUNCTION CVAL(OLD_VALUE VARCHAR2,
              NEW_VALUE VARCHAR2) RETURN VARCHAR2 IS
BEGIN
  -- проверка если NULL передали текстом
  IF UPPER(NEW_VALUE) = 'NULL' THEN
    RETURN NULL;
  END IF;

  IF NEW_VALUE IS NOT NULL THEN
    IF (UPPER(NEW_VALUE) <> 'NUL') THEN
      RETURN NEW_VALUE;
    ELSE
      RETURN NULL;
    END IF;
  ELSE
    RETURN OLD_VALUE;
  END IF;
END;
 
BEGIN
  V_VAR :=  NVL(CVAL(OLD_VALUE => 11, NEW_VALUE =>04071), 0);
  DBMS_OUTPUT.put_line (V_VAR);
END;
/
---------------------------
--обьявить процедуру в анонимном блоке
declare 
  procedure runLogRow(
    p_inq_id     fcs.wcb_inquiry_log.inq_id%type               ,
    p_inq_method fcs.wcb_inquiry_log.inq_type%type default null,
    p_inq_url    fcs.wcb_inquiry_log.inq_url%type  default null,
    p_req_body   fcs.wcb_inquiry_log.req_body%type default null,
    p_inq_guid   fcs.wcb_inquiry_log.inq_guid%type default null
  )
  is
   
  begin
    NULL;
  end;
begin
  runLogRow(
    p_inq_id => 3356,
    p_inq_guid => '9C54245154D2D41BE05309C5310A7562'
  ); 
end;
/
----------------------------


declare
V_ASSC_REC         WCB.ASSOCIATIONS%ROWTYPE;
begin
-- Получаем данные по ассоциации
    SELECT * INTO V_ASSC_REC FROM WCB.ASSOCIATIONS WHERE ASSC_ID = P_ASSC_ID;
-- Получаем параметр P_NAME - Наименование ассоциации
    V_NAME := NVL(P_NAME, V_ASSC_REC.NAME);
end;

--Конкатенация сообщения с новой строки 
V_MESSAGE := V_MESSAGE || 'Л/С: ' || V_CUR1.ACCOUNT || '; Дата изменения: ' || V_CUR1.NAVI_DATE || '; Эксперт: ' || V_CUR1.NAVI_USER ||
		 '; Канал: ' || V_CUR1.CHANNEL || '; Статус услуги: ' || V_CUR1.STS || '; Действие: ' || V_CUR1.ACTION || ';' ||
		 CHR(10) || CHR(13);
________________________________________________________________

-- Private type declarations. типа pivot
  FUNCTION FC_DELEMITER_CODE(VCODETESTOUT VARCHAR2,
                             VDELIMITER   VARCHAR2 DEFAULT ',',
                             VNULL        NUMBER DEFAULT 0) RETURN TT_STRING
    PIPELINED AS
    V_DELIMITER VARCHAR2(10);
    V_STR       VARCHAR2(4000);
    V_COUNT     NUMBER;
  BEGIN
    V_STR       := VCODETESTOUT;
    V_DELIMITER := NVL(VDELIMITER, ',');
    V_COUNT     := REGEXP_COUNT(V_STR, V_DELIMITER) + 1;

    FOR CUR IN (SELECT VALUE
                  FROM (SELECT REGEXP_SUBSTR(VALUE,
                                             '[^' || V_DELIMITER || ']+',
                                             1,
                                             LEVEL) VALUE,
                               LEVEL
                          FROM (SELECT V_STR AS VALUE FROM DUAL)
                        CONNECT BY LEVEL <= V_COUNT
                         ORDER BY LEVEL)) LOOP
      IF CUR.VALUE IS NULL THEN
        IF VNULL = 1 THEN
          PIPE ROW(CUR.VALUE);
        END IF;
      ELSE
        PIPE ROW(CUR.VALUE);
      END IF;
    END LOOP;
  END;
________________________________________________________________

Создание процедуры:
CREATE OR REPLACE PROCEDURE Customer_Insert AS 

set serveroutput on -- Need first start
DECLARE

        A_FIRST_DATE  DATE;
        A_LAST_DATE   DATE;
        
BEGIN 

        A_FIRST_DATE := TRUNC(sysdate,'MM');
        A_LAST_DATE := add_months(A_FIRST_DATE,1);
        DBMS_OUTPUT.put_line (A_FIRST_DATE);
        DBMS_OUTPUT.put_line (A_LAST_DATE);

END;
________________________________________________________________
--Автономные транзакции 
  PROCEDURE TO_LOG(TEXT VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO AAA_NATEC_TEST VALUES(TEXT,SYSDATE);
    COMMIT;
  END;
  
--------------
V_TBL_NOT    EXCEPTION; -- Таблица не существует
PRAGMA       EXCEPTION_INIT(V_TBL_NOT,-00942);
--------------------------------------------------------------
  --запишем обращение в лог
  PROCEDURE save_in_log(v_func      VARCHAR2,
                        v_params    VARCHAR2,
                        v_par_out   VARCHAR2,
                        err_code    NUMBER,
                        err_message VARCHAR2) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    SET TRANSACTION READ WRITE;
    INSERT INTO NP_LOG
    VALUES
      (v_func,
       substr(v_params, 1, 2000),
       v_par_out,
       err_code,
       err_message,
       SYSDATE,
       USER);
    COMMIT;
    NULL;
  END;
  ______________________________________________________________

set serveroutput on
declare
  dt Varchar2(20);
  sql_p Varchar2(100);
  dd date;  
begin
select 'sysdate' ff 
       into dt
from dual;
sql_p:='select '||dt||' from dual';
  --DBMS_OUTPUT.put_line (sql_p);
  EXECUTE IMMEDIATE sql_p into dd;
  DBMS_OUTPUT.put_line (dd);
end;

________________________________________________________________

set SERVEROUTPUT on -- Need first start
begin
for T in (select sysdate+ level vl from DUAL connect by level < 10)
LOOP
--DBMS_OUTPUT.enable;
DBMS_OUTPUT.PUT_LINE(t.vl);
end LOOP;
end;


declare
line_out Varchar2(100);
begin
for T in (select No_Of_Calls c, Curr_Cd s from ut32.endmonth_summary  where Rownum <= 5 )
LOOP
line_out := to_char(t.c) || ' ' || to_char(t.s);
DBMS_OUTPUT.PUT_LINE(line_out);
--DBMS_OUTPUT.PUT_LINE(t.s);
end LOOP;
end;


--set SERVEROUTPUT on -- Need first start
declare
line_out Varchar2(100);
begin
for T in (select 'kostya ' n, 'nadezhdin ' f, 'kiyv ' c from DUAL)
LOOP
--DBMS_OUTPUT.enable;
--DBMS_OUTPUT.ENABLE(1000000);
DBMS_OUTPUT.ENABLE(BUFFER_SIZE => NULL); -- Отключить верхний предел в байтах для буферизованной информации
line_out := to_char(t.n) || to_char(t.f) || to_char(t.c);
DBMS_OUTPUT.PUT_LINE(line_out);
end LOOP;
end;
________________________________________________________________
set SERVEROUTPUT on
declare
LV_SQL Varchar2(15000);
A_FIRST_DATE  DATE;
A_LAST_DATE   DATE;
begin

A_FIRST_DATE := TRUNC(sysdate,'MM');
A_LAST_DATE   := add_months(A_FIRST_DATE,1);

/*DBMS_UTILITY.EXEC_DDL_STATEMENT ('truncate table CDR_SEL_TEMP');*/

DBMS_OUTPUT.PUT_LINE(A_FIRST_DATE );
DBMS_OUTPUT.PUT_LINE(A_LAST_DATE);

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
    FROM CDR_SEL_TEMP TM, ut32.cdr_detail cd, ut32.cdr c
    WHERE 1=1
    AND c.cdr_id = cd.cdr_id
    AND C.DISCONNECT_TM > C.SEIZURE_TM
    AND tm.cdr_sum_id = cd.cdr_sum_id
    AND c.cdr_id >= 
                (
                  SELECT  MIN(PRIM_KEY_MIN) min_cdr  FROM 
                  (
					  SELECT P.PRIM_KEY_MIN, P.PRIM_KEY_MAX
					  FROM DBA_TAB_PARTITIONS S, UT32.PART_LIST P
					  WHERE P.PART_TABLE=''CDR''
					  AND S.TABLE_NAME=P.PART_TABLE
					  AND S.PARTITION_NAME=P.PART_NAME
					  AND P.DATE_MAX >= to_date('''||A_FIRST_DATE||''',''dd.mm.yyyy hh24:mi:ss'')
					  AND P.DATE_MIN < to_date('''||A_LAST_DATE||''',''dd.mm.yyyy hh24:mi:ss'')
                  )
                )
     AND c.cdr_id <
                (
                  SELECT  MAX(PRIM_KEY_MAX) max_cdr  FROM 
                  (
					  SELECT P.PRIM_KEY_MIN, P.PRIM_KEY_MAX
					  FROM DBA_TAB_PARTITIONS S, UT32.PART_LIST P
					  WHERE P.PART_TABLE=''CDR''
					  AND S.TABLE_NAME=P.PART_TABLE
					  AND S.PARTITION_NAME=P.PART_NAME
					  AND P.DATE_MAX >= to_date('''||A_FIRST_DATE||''',''dd.mm.yyyy hh24:mi:ss'')
					  AND P.DATE_MIN < to_date('''||A_LAST_DATE||''',''dd.mm.yyyy hh24:mi:ss'')
                  )
                )'
				;
    
    DBMS_OUTPUT.PUT_LINE(LV_SQL); --вывод на экран
    
	
	/*EXECUTE IMMEDIATE LV_SQL;*/ -- запустить LV_SQL
	
    /*DBMS_UTILITY.EXEC_DDL_STATEMENT ('truncate table AAA_TIC_CURR_MNTH');*/
	
	 END;
	________________________________________________________________
-- объявлять селект который выводит несколько значение (циклом)
declare
min_cdr Varchar2 (9500);
max_cdr Varchar2 (9500);

begin

FOR RC IN (  
           SELECT MIN(PRIM_KEY_MIN) min_cdr_id FROM ( SELECT P.PRIM_KEY_MIN, P.PRIM_KEY_MAX 
           FROM DBA_TAB_PARTITIONS S, UT32.PART_LIST P
           WHERE P.PART_TABLE='CDR' AND S.TABLE_NAME=P.PART_TABLE AND S.PARTITION_NAME=P.PART_NAME 
           AND P.DATE_MAX >= A_FIRST_DATE
           AND P.DATE_MIN <  A_LAST_DATE ) 
          )
LOOP
min_cdr :=  RC.min_cdr_id;
END LOOP;
________________________________________________________________
-- объявлять селект который выводит одно значение (функцией into)	

declare
min_cdr Varchar2 (9500);
max_cdr Varchar2 (9500);
begin

SELECT MIN(PRIM_KEY_MIN) into min_cdr FROM ( SELECT P.PRIM_KEY_MIN, P.PRIM_KEY_MAX 
FROM DBA_TAB_PARTITIONS S, UT32.PART_LIST P
WHERE P.PART_TABLE='CDR' AND S.TABLE_NAME=P.PART_TABLE AND S.PARTITION_NAME=P.PART_NAME 
AND P.DATE_MAX >= A_FIRST_DATE
AND P.DATE_MIN <  A_LAST_DATE );

SELECT MAX(PRIM_KEY_MAX) into max_cdr FROM ( SELECT P.PRIM_KEY_MIN, P.PRIM_KEY_MAX 
FROM DBA_TAB_PARTITIONS S, UT32.PART_LIST P
WHERE P.PART_TABLE='CDR' AND S.TABLE_NAME=P.PART_TABLE AND S.PARTITION_NAME=P.PART_NAME 
AND P.DATE_MAX >= A_FIRST_DATE
AND P.DATE_MIN <  A_LAST_DATE ); 	

	
________________________________________________________________	
После того как содали констрейн, сделать инсерт минуя ошибку

BEGIN

if dt_old = TRUNC(sysdate,'MM') then

   for tab in  (SELECT /*+ parallel(4) */ CDR_ID ,CARR_CD, SEIZURE_TM, round((disconnect_tm-SEIZURE_TM)*86400) dur, 
                calling_num, called_num, SWITCH_CD, rate, CURR_CD, round((disconnect_tm-SEIZURE_TM)*1440*rate, 4) COST, IN_OR_OUT,CHARGE_BAND_ID,PRODUCT
                FROM CDR_SEL_RES
                WHERE 1=1
				        AND Seizure_Tm >= trunc(sysdate,'DD') -5
                AND in_or_out = 'O'
                )loop
                
  begin
  INSERT INTO  tmp_out_traf (CDR_ID, CARR_CD, SEIZURE_TM, dur, calling_num, called_num, 
          SWITCH_CD, rate, CURR_CD, COST, IN_OR_OUT,CHARGE_BAND_ID,PRODUCT)
  VALUES (tab.CDR_ID, tab.CARR_CD, tab.SEIZURE_TM, tab.dur, tab.calling_num, tab.called_num, 
          tab.SWITCH_CD, tab.rate, tab.CURR_CD, tab.COST, tab.IN_OR_OUT,tab.CHARGE_BAND_ID,tab.PRODUCT);
  EXCEPTION 
  WHEN DUP_VAL_ON_INDEX then null;
  end;

END LOOP; 

    commit;  
	
END;
________________________________________________________________
--UPDATE циклом

BEGIN

--if dt_old = TRUNC(sysdate,'MM') then

   for tab in  (SELECT /*+ parallel(4) */ CDR_ID ,CARR_CD, SEIZURE_TM, round((disconnect_tm-SEIZURE_TM)*86400) dur, 
                calling_num, called_num, SWITCH_CD, rate, CURR_CD, round((disconnect_tm-SEIZURE_TM)*1440*rate, 4) COST, IN_OR_OUT,CHARGE_BAND_ID,PRODUCT
                FROM CDR_SEL_RES
                WHERE in_or_out = 'O'
                )loop
                
   UPDATE tmp_out_traf SET rate=tab.rate, COST = tab.COST, CURR_CD=tab.CURR_CD, CHARGE_BAND_ID=tab.CHARGE_BAND_ID  
   WHERE CDR_ID = tab.CDR_ID AND IN_OR_OUT = tab.IN_OR_OUT AND rate != tab.rate;
   
END LOOP; 
    --end if;
	commit;
	
END; 
________________________________________________________________
--COLLECT AND CURSOR
DECLARE
  type C1REC IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
  type C2REC IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  prow C1REC;
  prec C1REC;
  plen C2REC;

  CURSOR c1 IS
    SELECT t.rowid
          ,SORT_STRING_INSIDE(upper(t.fio)) s
          ,length(t.fio) l
    FROM TCH_PARTY_PHONE t
    WHERE t.status=0
    ;
BEGIN

  OPEN c1;

  LOOP
    FETCH c1 BULK COLLECT
      INTO prow
          ,prec
          ,plen LIMIT 10000;
    FORALL j IN prow.FIRST .. prow.LAST
      UPDATE TCH_PARTY_PHONE f
      SET f.sortfio = prec(j)
         ,f.lenfio  = plen(j)
      WHERE f.rowid = prow(j);
    COMMIT;
    EXIT WHEN prow.COUNT = 0;
  END LOOP;
  COMMIT;
  CLOSE c1;

END;
________________________________________________________________

Склейка сдр-записей

declare
d NUMBER:=1; -- количество секунд

BEGIN

    FOR c IN 1..3 loop
      FOR cc IN ( SELECT t.CDR_ID, t.IN_OR_OUT, t.SEIZURE_TM dt, t.called_num, round(t.dur) dur FROM tmp_in_traf t WHERE out01 IS NULL AND product IN ('TDM_IDDD','VOIP_IDDD')) loop
        FOR ci IN ( SELECT t.* 
                      FROM TMP_OUT_TRAF t 
                     WHERE out01 IS NULL
                     AND called_num=cc.called_num
                     AND t.IN_OR_OUT != cc.IN_OR_OUT
                     AND (SEIZURE_TM BETWEEN cc.dt-d/86400 AND cc.dt+d/86400 or SEIZURE_TM-7/24 BETWEEN cc.dt-d/86400 AND cc.dt+d/86400)
                     AND round(dur) BETWEEN cc.dur-1 AND cc.dur+1
                  ORDER BY abs(86400*(SEIZURE_TM-cc.dt))
          ) loop
          UPDATE tmp_in_traf SET OUT01=d, OUT02=ci.CDR_ID WHERE CDR_ID=cc.CDR_ID;
          UPDATE TMP_OUT_TRAF SET OUT01=d, OUT02=cc.CDR_ID WHERE CDR_ID=ci.CDR_ID;
          commit;
          exit;
        END loop;
      END loop;
      d:=d*2;
    END loop;  
	
END;	
________________________________________________________________
инсерт циклом

BEGIN

    for tab in ( select uni_a from a_temp_adamovich )loop
   
    insert into IN_TRAFF_IVF_2 (FL,BILL_DTM,UNI_A,UNI_B,DURATION)
    
    select switch_id,BILL_DTM, UNI_A, UNI_B, round(DURATION) DURATION 
    from ms_data_khr.vq_sec2@hr_ms
    where orig_dtm >= to_date('01.02.2015','dd.mm.yyyy')
    and orig_dtm < to_date('01.04.2015','dd.mm.yyyy')
    and DURATION > 0 and uni_b not like '38062%'and uni_b not like '380800%'
    and uni_a = tab.uni_a;
	
	--commit;
               
END LOOP; 

END;
________________________________________________________________
--Сортировка внутри строки
--https://forum.shelek.ru/index.php/topic,20951.0.html
create or replace FUNCTION SORT_STRING_INSIDE(p_str VARCHAR2) RETURN VARCHAR2 DETERMINISTIC AS
  n  NUMBER;
  s  VARCHAR2(2000);
  st char_table_t := char_table_t();
BEGIN
  IF p_str IS NOT NULL THEN
    FOR n IN 1 .. LENGTH(p_str) LOOP
      st.EXTEND;
      st(n) := SUBSTR(p_str
                     ,n
                     ,1);
    END LOOP;
  
    SELECT CAST(MULTISET (SELECT *
                 FROM TABLE(st)
                 ORDER BY 1) AS char_table_t)
    INTO st
    FROM DUAL;
  
    FOR n IN st.FIRST .. st.LAST LOOP
      s := s || st(n);
    END LOOP;
  END IF;
  RETURN s;
END;

--SELECT SORT_STRING_INSIDE('6CD25A3478') str FROM DUAL;
________________________________________________________________
--инсерт циклом по дням

set serveroutput on -- Need first start
DECLARE

        d NUMBER;
		LV_SQL Varchar2(15000);

begin

d:=0;

	FOR cc IN 1..30 /*указать последний день месяца*/ loop

LV_SQL := 
'
insert into table
select *
from VQ_SEC2_KMF_LITE
where bill_dtm >= to_date(''01.09.2015'',''dd.mm.yyyy'')+'||d||'
and bill_dtm < to_date(''01.09.2015'',''dd.mm.yyyy'')+'||d||'+1
'
;
  DBMS_OUTPUT.PUT_LINE(LV_SQL); -- вывод на экран      
  --EXECUTE IMMEDIATE LV_SQL;       -- запустить LV_SQL
  
  commit;

d:=d+1;

    END LOOP; 
END;
________________________________________________________________

DECLARE

  TABLENAME      VARCHAR2(200) := 'WCB.SUBSCRIBERS_V';
  CUR            SYS_REFCURSOR;
  V_SQL          VARCHAR2(2000);
  STR_ROW        VARCHAR2(32000);
  
BEGIN

  V_SQL := 'SELECT CLNT_CLNT_ID as STR_ROW
            FROM ' || TABLENAME || ' D
            WHERE D.SUBS_ID IN (14793279, 14793281, 14793282, 14793283, 14793285, 14597041)';

  OPEN CUR FOR V_SQL;
  LOOP
    FETCH CUR
      INTO STR_ROW;
    EXIT WHEN CUR%NOTFOUND;
  
    DBMS_OUTPUT.PUT_LINE(STR_ROW);
  
  END LOOP;
  CLOSE CUR;

END;
________________________________________________________________

--1
create package test_cross is

type rowGetCROSSRATE is record(
CROSSRATE NUMBER
);

type tblGetCROSSRATE is table of rowGetCROSSRATE;

function GetCROSSRATE_2
(partun date default sysdate)
return tblGetCROSSRATE
pipelined; 

end test_cross;

--2
create or replace PACKAGE body test_cross
IS

FUNCTION GetCROSSRATE_2(
    partun DATE DEFAULT sysdate)
  RETURN tblGetCROSSRATE pipelined
IS
  A_FIRST_DATE  DATE;
  A_LAST_DATE   DATE;
  EXCHANGE_RATE NUMBER(12,6);
BEGIN
  A_FIRST_DATE := TRUNC(partun,'MM');
  A_LAST_DATE   := add_months(A_FIRST_DATE,1);

  FOR curr IN
  (
    SELECT EXCHANGE_RATE
    FROM
      (SELECT e.EXCHANGE_RATE,
        e.FROM_DATE
      FROM ut32.currency_rate e
      WHERE e.FROM_DATE < A_LAST_DATE
      --AND e.FROM_DATE  >= A_FIRST_DATE
      AND e.CURR_CD     = 'EUR'
      ORDER BY e.FROM_DATE DESC
      )
    WHERE ROWNUM < 2
  )
  LOOP
    pipe row (curr);
  END LOOP;

END GetCROSSRATE_2;

END test_cross;

--3
select CROSSRATE from TABLE(test_cross.GetCROSSRATE_2(sysdate+1));
________________________________________________________________

SET serveroutput ON -- Нужно запустить один раз (что бы был вывод на экран)
DECLARE

        d NUMBER:=1;
        dd NUMBER;
        
BEGIN 
select to_number(substr(LAST_DAY(trunc(sysdate,'MM')),1,2)) into dd from dual;
d:=0;

FOR cc IN 1..dd loop
 
    FOR tab IN ( SELECT TRUNC(sysdate,'MM')+d A_FIRST_DATE FROM dual )loop
      
    DBMS_OUTPUT.put_line (tab.A_FIRST_DATE); -- вывод на экран первую дату
    END LOOP; 

d:=d+1;

END LOOP; 
 
END;
________________________________________________________________


________________________________________________________________

begin
  for c in ( select uni_a, row_number() over( partition by uni_a order by bill_dtm desc ) rn from ms_kiv.calls ) loop
    ...
  end loop;
end;
________________________________________________________________

если для все логинов диапазон дат один, то, думаю, лучший вариант  будет 

begin
  for c in ( select * from (
               select uni_a, row_number() over( partition by uni_a order by bill_dtm desc ) rn
               from ms_kiv.calls
               where bill_dtm between дата с and дата по
             ) where rn = 1 ) loop
    обработка();
  end loop;
end;

но если число интересных логинов относительно мало (пару процентов от общего их числа) и есть индекс по логинам и датам, 

begin
  for c in ( select uni_a, row_number() over( partition by uni_a order by bill_dtm desc ) rn
             from ms_kiv.calls
             where uni_a = логин and
                   bill_dtm between дата с and дата по ) loop
    обработка();
    exit;
  end loop;
end;
________________________________________________________________
--------------------------------------------------------------------------------------
--function view pipelined
--1
CREATE OR REPLACE PACKAGE test AS

    TYPE measure_record IS RECORD(
       CLNT_CLNT_ID NUMBER(10) ,
       CLIS_CLIS_ID number(10) ,
       name  varchar2(240) ,
       start_date  date ,
       end_date  date ,
       hist_jrtp_id  number(10) );

    TYPE measure_table IS TABLE OF measure_record;

    FUNCTION client_histories(foo NUMBER)
        RETURN measure_table
        PIPELINED;
END;

--2
CREATE OR REPLACE PACKAGE BODY test AS

    FUNCTION client_histories(foo number)
        RETURN measure_table
        PIPELINED IS

        rec            measure_record;

    BEGIN

   FOR REC IN (
      SELECT CLNT_CLNT_ID,CLIS_CLIS_ID,name,start_date,end_date,hist_jrtp_id
      FROM BIS.client_histories SS 
      WHERE SS.CLNT_CLNT_ID=foo 
                                  ) LOOP

        PIPE ROW (rec);

        END LOOP;

        RETURN;
    END client_histories;
END;
-------------------------------------------------------------------------------------