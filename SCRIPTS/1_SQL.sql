/*+ FIRST_ROWS (T)*/
/*+ first_rows(10) */ --фетчить только первые 10 строк
/*+ FULL(T)*/ 
/*+ INDEX ( TT IDX_L_DT_ORX  ) */ -- https://docs.oracle.com/cd/B13789_01/server.101/b10752/hintsref.htm
/*+ INDEX ( T2 IDX_RIDI) INDEX (T1 IDX_RID) */ 
/*+ NO_INDEX(ch, CL_CLIENT_HISTORIES_CI) INDEX(ch, CLNH_CLNT_DATE_I)*/
/*+ NO_INDEX(TT NAME_IDX) */ 
/*+ PARALLEL(2)*/
/*+ parallel(32) Index_FFS (TT NAME_IDX) */
--index full scan - читается весь индекс в порядке сортировки строк в этом индексе.
--index fast full scan - индекс используется как несортированная (heap) таблица.
/*+ APPEND*/ -- для загрузки больших объёмов данных (паралельных)
/*+ DRIVING_SITE (TT) */ -- указывает оптимизатору выполнять запрос на сайте [сайте таблицы, указанной в хинте], отличном от выбранного бд [Oracle]
/*+ REMOTE_MAPPED (TT) */ -- указывает оптимизатору выполнять запрос на сайте [сайте таблицы, указанной в хинте], отличном от выбранного бд [Oracle]
/*+ leading(t1 p r s fpr) */ -- указывает оптимизатору использовать перечисленный порядок доступа к таблицам
/*+ ORDERED */ -- указывает Oracle [при выполнении запроса] проводить соединение таблиц в том же порядке, в котором таблицы перечислены в конструкции FROM
/*+ USE_NL ( T1 T2 ) */ -- Чудо хинт
/*+ ORDERED USE_NL(JA,CH,SSS,DV,SR) */ -- Еще чудо хинт
/*+USE_HASH(s, gp)*/

--план запроса
SELECT V.LAST_ACTIVE_TIME, V.*
  FROM GV$SQLAREA V
 WHERE 1=1
   AND V.SQL_TEXT NOT LIKE '%GV$SQLAREA%'
   AND V.SQL_TEXT NOT LIKE '%GET_FIRST_ACCOUNT_WITH_DEBT%'
   AND V.LAST_ACTIVE_TIME > TO_DATE('13.04.2021 17:09:00', 'DD.MM.YYYY HH24:MI:SS') 
   AND DBMS_LOB.INSTR(V."SQL_FULLTEXT", '5521723') > 0
   AND DBMS_LOB.INSTR(V."SQL_FULLTEXT", 'BO323307') > 0
   --AND V.SQL_ID='d6vu2ubx4m9ga'
 ORDER BY V.LAST_ACTIVE_TIME DESC;
 
-- шрифт для екселя - Courier
SELECT * 
FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('6n6qqkn7ysw93', '0', 'advanced'));

UTL_FILE.PUT_LINE(warning_file,
				  CONVERT('Дата/Время',
						  'CL8MSWIN1251') || ';' ||
				  CONVERT('Тип', 'CL8MSWIN1251') || ';' ||
				  CONVERT('Направление вызова',
						  'CL8MSWIN1251') || ';' ||
				  CONVERT('Номер телефона',
						  'CL8MSWIN1251') || ';' ||
				  CONVERT('Прод.(сек)',
						  'CL8MSWIN1251') || ';' ||
				  CONVERT('Стоимость балансовая',
						  'CL8MSWIN1251') || ';' ||
				  CONVERT('Стоимость справочная (нефискальная)',
						  'CL8MSWIN1251'));

select * 
from INFORMATION_SCHEMA.COLUMNS@BSTST_UNIBILL_BIS.KYIVSTAR.UA dh 
where TABLE_NAME = 'CLIENT_HISTORIES' ;

--СОБРАТЬ СТАТИСТИКУ
BEGIN
DBMS_STATS.gather_table_stats('WCB', 'JUR_ADDRESSES_T');
END;
/

Kitchen.bat /rep "PenrahoDI" /user:"admin" /pass:"password" /level:basic /job:"Job NP" /dir:"/home/admin/kostya"  

--с командной строки запустить файл
SQL> set define off
SQL> @Z:\Работа\5 Softengi\Задачи\0_Free month TV for FMC customers\DIFF for SVN\TEST\Srv_Fix_pck.sql

CREATE TABLE MY_TBL NOLOGGING PARALLEL 2 AS SELECT * FROM t@my_link;

exec dba_pack.change_password('логін', 'пароль'); -- изменить пароль на региональных БД

show parameter CPU; -- параметры CPU

show parameter target; -- параметры БД

show parameter compat; -- compatible parameter

select * from v$version; -- версия БД

select * from sys.v_$parameter where name = 'service_names';

--кодировка БД
SELECT *
FROM NLS_DATABASE_PARAMETERS;

SELECT DECODE (session_state, 'WAITING', event, NULL) event,WAIT_CLASS, session_state, COUNT(*), SUM (time_waited) time_waited
FROM v$active_session_history
WHERE 1=1
AND USER_ID=2971 
AND SESSION_ID = 7131 AND SESSION_SERIAL# = 1175
AND sample_time > SYSDATE - (2/24)
--AND EVENT = 'db file sequential read'
GROUP BY DECODE (session_state, 'WAITING', event, NULL),session_state,WAIT_CLASS
ORDER BY 5 DESC;

---------------------------------------
sqlplus / as sysdba

shutdown immediate

startup
----------------------------------------
sqlplus sys/oracle@80.64.80.199:1521/orclpdb
sqlplus / AS SYSDBA
sqlplus sys/oracle as sysdba
SYS as sysdba
cl scr; -- очистить экран sqlplus
----------------------------------------
sqlplus sys/oracle as sysdba
show con_name;
alter session set container = orclpdb;
show con_name;
----------------------------------------
sqlplus sys/oracle as sysdba;
alter session set container = orclpdb;
ALTER DATABASE OPEN;
alter pluggable database orclpdb save state;

SELECT name, open_mode FROM v$pdbs;
----------------------------------------
lsnrctl status/stop/start/reload
----------------------------------------
> sqlplus / as sysdba
SQL> alter user SYS identified by "NEWPASSWORD";
----------------------------------------

SELECT SYS_CONTEXT ('USERENV','IP_ADDRESS') IP FROM  DUAL;  -- УЗНАТЬ ИП
SELECT SYS_CONTEXT ('USERENV', 'SESSION_USER') FROM DUAL;   -- УЗНАТЬ USERNAME
SELECT SYS_CONTEXT ('USERENV', 'OS_USER') FROM DUAL;   -- УЗНАТЬ os_user
SELECT SYS_CONTEXT ('USERENV', 'DB_NAME') FROM DUAL;   -- УЗНАТЬ Название БД

-- экспортироать БД в дамп файл
echo 'cl_user/CL$USER$2015@VAZDB_WORK' | exp owner=cl_user file=/home/oracle/test_dump_ttm/ttm.dmp log=/home/oracle/test_dump_ttm/ttm.log 

select DBMS_METADATA.GET_DDL('TABLE','AAA_TEST_ASTLO') ddl from DUAL; -- узнать dll таблицы

--ЛОГИРОВАНИЕ ДЕЙСТВИЙ
SET SERVEROUTPUT ON -- NEED FIRST START
DECLARE
DBG NUMBER := 1; -- ПЕРЕМЕННАЯ ОПРЕДЕЛЯЮЩАЯ ВКЛЮЧЕН ЛИ РЕЖИМ ОТЛАДКИ (1 - ВКЛЮЧЕН, 0 - ВЫКЛЮЧЕН)
PROC VARCHAR2(30) := 'NAME_PROCESS';
DDL_STMT VARCHAR2(512);
BEGIN
  IF DBG != 0 THEN
    DDL_STMT := 'START CALCULATE ...';
    INSERT INTO VAZDB_LOG_BUILD(PROC, DESCRIPTION) VALUES(PROC, DDL_STMT); COMMIT;
  END IF;
  
INSERT INTO TABLE ...

  IF DBG != 0 THEN
    DDL_STMT := 'FINISH CALCULATE ...';
    INSERT INTO VAZDB_LOG_BUILD(PROC, DESCRIPTION) VALUES(PROC, DDL_STMT); COMMIT;
  END IF;
END;

http://docs.oracle.com/cd/E25054_01/network.1111/e16543/vpd.htm 	https://habrahabr.ru/post/122784/ -- RLS
http://sadalage.com/blog/2009/08/10/materialized_views_and_databases/ --Materialized Views and Database Links in Oracle.
https://asktom.oracle.com/pls/asktom/f?p=100:11:0::::P11_QUESTION_ID:1101164500346436784 --INSERT SELECT vs CREATE AS SELECT  

PRAGMA AUTONOMOUS_TRANSACTION;
---------------------------------------------------------
SELECT REGEXP_SUBSTR(LIST_SRLS_ID, '[^,]+', 1, LEVEL) AS LIST_SRLS
FROM DUAL
CONNECT BY REGEXP_SUBSTR(LIST_SRLS_ID, '[^,]+', 1, LEVEL) IS NOT NULL
                             
&p_city_list : '113,342342,5252,5252'
---------------------------------------------------------
-- CREATE WITH NULL COLUMNS 
create TABLE TABLE_TEST
tablespace new_tablespace_name
as
select 
  cast( null as varchar2(10) ) a, 
  cast( null as date ) b, 
  cast( null as number ) c
from dual;

--Создать таблицу с параллелями
CREATE TABLE FCS.AAA_TEST PARALLEL 8 AS
SELECT *
FROM TABLE;
---------------------------------------------------------
WHERE BILL_DTM >= TO_DATE('01.12.2015 00:00:00', 'DD.MM.YYYY HH24:MI:SS') 
AND BILL_DTM <  TO_DATE('02.12.2015 00:00:00', 'DD.MM.YYYY HH24:MI:SS')

--Данные на указанную дату
AND TO_DATE('01.02.2020', 'DD.MM.YYYY') /*p_Date*/ BETWEEN J.START_DATE AND J.END_DATE
AND SCH.START_DATE <= TO_DATE('01.02.2020', 'DD.MM.YYYY') /*p_Date*/ AND SCH.END_DATE > TO_DATE('01.02.2020', 'DD.MM.YYYY') /*p_Date*/

select * from sys.dictionary /*dict это паблик синоним от dictionary*/; -- словарь данных

--10 процентов строк
select t.*
from (select t.*, count(*) over () as cnt
      from table t
      order by <whatever>
     ) t
where rownum <= 0.1 * cnt;

-- УЗНАТЬ ПОЛЕ ИНДЕКСА И ПАРТИЦИИ:
SELECT 'PARTITION_COLUMN' PART, COLUMN_NAME FROM ALL_PART_KEY_COLUMNS WHERE Owner='VAZ_REP' AND NAME='MS_REP_VRNTK_IN'
UNION
select 'INDEX_COLUMN' IDX, COLUMN_NAME FROM ALL_IND_COLUMNS WHERE INDEX_OWNER='VAZ_REP' AND TABLE_NAME='MS_REP_VRNTK_IN' 

select * from nls_session_parameters;

alter session set nls_date_format='DD.MM.YYYY HH24:MI:SS'; --sqlplus поменять формат даты

SELECT comp_name, version, status FROM dba_registry; --компоненты на БД

Id int NOT NULL UNIQUE -- уникальное поле 

Distinct -- выдает результат без одинаковых значений в таблице

GREATEST -- функция возвращает наибольшее значение в списке выражений (максимум из максимума)

substr -- позволяет извлечь из выражения его часть заданной длины, начиная от заданной начальной позиции

SUBSTR(MESSAGE, INSTR(MESSAGE, ';')+1)  -- Обрезать до оперделенного знака

IN –- конкретное значение из столбца, например: Where «назв. столб.» IN (100,200,300)

Like «S%» -- Отсортировать, все значение которые начинаться на «S»

--like '%\_NT%' ESCAPE '\' -- экранировать лайком

and translate(Tz_Num, 'x0123456789', 'x') is null -- только цифры

regexp_replace(str,'*[^[[:alpha:]]]*')  -- только символы

regexp_replace(str,'*[^[[:digit:]]]*') -- только цифры

abs(col) - модуль

SELECT REGEXP_REPLACE('1A23B$%C_z- 11вамя23d*_- ', '[^0-9]') DFV,
       REGEXP_REPLACE('1A23B$%C_z- 11вамя23d*_- ', '([^A-Za-z-а-н])([\S])') S,
       REGEXP_REPLACE('1A23B$%C_z- 11вамя23d*_- ', '[A-Za-z-а-н]') DFV,
       REGEXP_REPLACE(' 1A23B$%C_z- 11вамя23d*_Я- ', '[^A-Za-z-а-я]\S') DFV,
       REGEXP_REPLACE(' 1A23B$%C_z- 11вамя23dва АавБО*_- ', '[^ A-Za-z-А-я]') DFV,
       REGEXP_REPLACE(' 1A2903B$%C_z- 11вамя23dва АавБО*_- ', '([^ A-z-А-я])(\n)') DFV,
       REGEXP_REPLACE(' 1A23B$%C_z-9078 11вамя23dва АавБО*_- ', '[^ A-z-А-я-0-9]') DFV,
       REGEXP_REPLACE(' 1A23B$%C_z-9078 -11вамя23dва АавБО*_- ', '[^ A-z-А-я-0-9-]') DFV
FROM DUAL;

where ( regexp_like(Telefon,'[A-Z]') or regexp_like(Telefon,'[А-Я]') ) -- Маска

where regexp_like(a.n,'^[[ igit:]]*$') -- привязка к началу и к концу ЛЮБОГО КОЛИЧЕСТВА

where REGEXP_SUBSTR(param_list,'[0-9]{2}.[0-9]{2}.[0-9]{4}\s[0-9]{2}:[0-9]{2}:[0-9]{2}+') -- Еще Маска

INSTR(',' || V_RTPL_CHECK || ',', ',' || TO_CHAR(CC.RTPL_ID) || ',') = 0 -- проверить список

and v(uni_a) = 12 -- Длина

select LENGTH(111) from dual; -- узнать длину строки

NVL или COALESCE -- обработка значений NULL

RPAD('слово', LENGTH('слово') - 1) -- Обрезать справа 

SUBSTR(TBL_NAME, 1, LENGTH(TBL_NAME)-2 ) -- Обрезать справа 

BETWEEN -- данный оператор используется в условии WHERE для выбора данных между двумя значениями. Данные могут быть: тестом, числами, даты.

EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_NUMERIC_CHARACTERS=''.,'''; -- На уровне сессии поменять разделитель 
alter session set NLS_NUMERIC_CHARACTERS='.,';

ALTER SESSION SET NLS_LANGUAGE= 'AMERICAN';

--Переключить параметр только для текущей сессии (название dblink должно быть такое же, как вывод select global_name from global_name на базе, куда делается дблинк)
ALTER SESSION SET global_names=TRUE; 

SELECT Inst_Id, name, value FROM gv$parameter WHERE name = 'global_names'; -- узнать параметр global_names

count (*) -- показывает число выбранных рядов в результате запроса

trunc(trunc(sysdate, 'mm') -- данные за месяц 

trunc(trunc(sysdate, 'IW') -- групировка по неделе

select 'КВАРТАЛ - первый день', trunc(d,'Q') from t  -- ГРУПИРОВКА КВАРТАЛ (ПЕРВЫЙ ДЕНЬ)

select 'КВАРТАЛ - последний день', trunc(add_months(d, 3), 'Q')-1 from t -- ГРУПИРОВКА КВАРТАЛ (ПОСЛЕДНИЙ ДЕНЬ)

SELECT TO_CHAR(SYSDATE, 'Q') FROM dual; -- НОМЕР КВАРТАЛА

SELECT TO_CHAR(SYSTIMESTAMP, 'TZR') ZH FROM DUAL; -- часовой пояс БД. Еще есть TZH и TZM

SELECT tzname, tzabbrev, TZ_OFFSET(tzname) TZ FROM GV$TIMEZONE_NAMES; --Список часовых зон

SELECT ROUND((T2.DT_1-T1.DT_2)*24,2) SESSION_HOUR FROM DUAL;  -- ОТНЯТЬ ДАТЫ В ЧАСАХ

SELECT ROUND((T2.DT_1-T1.DT_2)*86400/60,2) SESSION_MIN FROM DUAL; -- ОТНЯТЬ ДАТЫ В МИНУТАХ

upper(to_char(SYSDATE,'day','NLS_DATE_LANGUAGE = RUSSIAN')) -- день недели /*dy;'NLS_DATE_LANGUAGE = AMERICAN'*/

( DURATION * 1000 + ( DT_CALL_END_100MS - DT_CHARGE_START_100MS ) ) /1000 -- сотые

select TO_CHAR(systimestamp,'DD.MM.YYYY HH24:MI:SS.FF1') FF from dual; -- сотые

SELECT SYSDATE, sysdate-1/84600, SYSDATE-INTERVAL '1' SECOND FROM DUAL; -- отнять одну секунду

select To_Char(sysdate, 'HH24:MI:SS'), To_Char(sysdate-1/24/60/60, 'HH24:MI:SS') from dual; -- отнять одну секунду

select trunc(trunc(sysdate,'MM')-1,'MM') , trunc(sysdate,'MM')-1/84600 from dual; -- отнять одну секунду

SELECT TO_CHAR(SYSTIMESTAMP, 'YYYY-MM-DD HH24:MI:SS.FF2') from dual; -- милисекунды -- FF2 или FF3 или FF4

select last_day(sysdate) FROM DAUL; -- ПОСЛЕДНИЙ ДЕНЬ МЕСЯЦА

select round((1-A1/A2)*100,3) "DIFF_%" from (select 5000 A1, 4970 A2 from dual); -- проценты

select 100-(round((1-A2/A1)*100,3)) "DIFF_%" from (select 1000 A1, 500 A2 from dual); -- другие проценты

select 
      abs(round((TO_DATE('23.09.2015 10:48:15', 'DD.MM.YYYY HH24:MI:SS')
      - 
      TO_DATE('23.09.2015 10:49:30', 'DD.MM.YYYY HH24:MI:SS')  )*86400,5) ) as dif_sec
from dual;  -- разница между датой и временем 

SELECT SYS_DATE, TRUNC(SYS_DATE-2,'MM') D1, TRUNC(SYS_DATE,'DD')+1 D2 
FROM 
(SELECT to_date ('03-09-2016','DD-MM-YYYY') SYS_DATE FROM DUAL);

SELECT first_time, LAG(first_time, 1) OVER (ORDER BY first_time) prev_time 
  FROM v$log_history -- разницу между двумя датами в соседних строках одного столбца (LEAD)

select * from dba_jobs;
select * from DBA_SCHEDULER_JOBS
___________________________________________________________________________________________________________________________________________________
SELECT 'JOBS' AS TYPE_JOB, COUNT(1) AS V_CHECK
FROM DBA_JOBS J
WHERE UPPER(J.WHAT) LIKE UPPER ('%NCE_SS_AUTO_RENEW%')

UNION ALL

SELECT 'SCHEDULER_JOBS' AS TYPE_JOB, COUNT(1) AS V_CHECK
FROM DBA_SCHEDULER_JOBS SJ
WHERE UPPER(SJ.JOB_ACTION) LIKE UPPER ('%NCE_SS_AUTO_RENEW%');
___________________________________________________________________________________________________________________________________________________
select rtrim(to_char(a1, 'fm9990d999'), '.,') num from (select to_char(0.111) a1 from dual); -- Отобразить ноль перед разделителем

select rtrim(to_char(a1, 'fm9990d999')) num from (select to_char(0.111) a1 from dual); -- Или так:Отобразить ноль перед разделителем

select rtrim(to_char(a1, 'fm9990d999'), substr(to_char(0,'fm0D'),-1)) num from (select to_char(0.111) a1 from dual); -- Или так:Отобразить ноль перед разделителем
_____________________________________________________________________________________________________________________________________________________________
SELECT OWNER, TABLE_NAME, COLUMN_NAME, COUNT(*) AS BUCKET_COUNT
FROM DBA_TAB_HISTOGRAMS
WHERE OWNER = 'NTK_DATA_KMF'
AND TABLE_NAME = UPPER('SD_TRAFFIC_GENERAL')
GROUP BY OWNER, TABLE_NAME, COLUMN_NAME  HAVING COUNT(*) > 2
ORDER BY COUNT(*) DESC;

--Очистка гистограмм 
EXEC DBMS_STATS.DELETE_COLUMN_STATS(OWNNAME=>'NTK_DATA_KMF', TABNAME=>'S_AMA_RECIPIENTS2', COLNAME=>'OPERATOR_TYPE', CASCADE_PARTS=>TRUE, COL_STAT_TYPE=>'HISTOGRAM')_________________________________________________________________________________________________________________________________________________________
--формировать XML
SELECT XMLSERIALIZE(CONTENT
                     XMLELEMENT("PARAMS",
                                XMLELEMENT("ASSC_ID", 11111),
                                XMLELEMENT("ADD_PACKS", 888888)) AS
                     VARCHAR2(1000)) as xml
FROM   DUAL;
_________________________________________________________________________________________________________________________________________________________


SELECT DBMS_RANDOM.RANDOM FROM DUAL; --  процедура генерирует случайное число

--ПРОВЕРКА НА ЧИСЛО
SELECT foo, translate(foo, '_0123456789', '_')
FROM ( SELECT 1 foo FROM DUAL)
WHERE translate(foo, '_0123456789', '_') IS NULL
-- WHERE REGEXP_LIKE (foo,'^[[:digit:]]+$')
;

SELECT DBMS_RANDOM.STRING('X',3)  FROM DUAL; --  процедура генерирует случайное символы

select ROUND(12.567, 2) from dual; -- Округлить до 2-х символов

TRUNC -- усечения даты в Oracle

CEIL -- округление в большую сторону

FLOOR -- округление в меньшую сторону

REPLACE(C,',','.') -- заменить

select sysdate+(10/24/60/60) from dual -- добавить 10 секунд

where upper(matr_cd) like upper ('vER%') -- не имеет значение регистр

SELECT * FROM all_tables where owner like upper ('ut%') and  table_name like '%TRUN%' -- вывести название таблиц

SELECT ST_ID,/* TR_ID,*/ COUNT(*)
FROM AA_ST_TR
GROUP BY rollup(ST_ID/*,TR_ID*/) -- Добавить итоги (промежуточные итоги)

select * 
from dba_constraints /*user_constraints*/ /*констрейны*/
where 1=1
--and constraint_type = 'P' 
and owner = 'MS_DATA_KIV'
and table_name = 'IP_COIALL';

SELECT * FROM dba_recyclebin; -- все корзины /*recyclebin - корзина пользователя*/; FLASHBACK TABLE my_dropped_table TO BEFORE DROP; /*Восстановить удалённую таблицу*/ 

PURGE TABLE "BIN$HGnf59/7rRPgQPeM/qQoRw==$0"; -- удалить объект в корзине; 	PURGE RECYCLEBIN - чистим корзину своей схемы; PURGE DBA_RECYCLEBIN - чистим все;

ALTER SYSTEM SET recyclebin=OFF SCOPE=SPFILE; SHUTDOWN IMMEDIATE; STARTUP; -- отключить корзину (нужен перезапуск БД), на уровне сесии - ALTER SESSION SET recyclebin=OFF;

select * from DBA_DB_LINK /*ALL_DB_LINKS, USER_DB_LINKS, v$dblink*/ -- дебелинки

SELECT * FROM DATABASE_PROPERTIES;  -- параметры БД

select * from dba_views; -- КОД ВЬЮШКИ

SELECT * FROM all_snapshots; --

select * from all_mviews; -- Материализованное представление

select * from dba_segments; --все сегменты и объекты  

select * from All_Objects; --все объекты

select * from dba_data_files /*v$datafile*/; -- путь к датафайлам %.DBF

select *  from DBA_TABLESPACES where Tablespace_Name like 'JIC%'; -- все таблспейсы

SELECT A.TABLESPACE_NAME, TOTALSPACE, NVL(FREESPACE,0) FREESPACE, -- определить объем свободного места в табличном пространстве (TABLESPACES)
   (TOTALSPACE-NVL(FREESPACE,0)) USED,
  ROUND(((TOTALSPACE-NVL(FREESPACE,0))/TOTALSPACE)*100,2) "%USED"
FROM
  (SELECT TABLESPACE_NAME, SUM(BYTES)/1048576 TOTALSPACE
   FROM DBA_DATA_FILES
   GROUP BY TABLESPACE_NAME) A,
  (SELECT TABLESPACE_NAME, SUM(BYTES)/1048576 FREESPACE
   FROM DBA_FREE_SPACE
   GROUP BY TABLESPACE_NAME) B
WHERE A.TABLESPACE_NAME = B.TABLESPACE_NAME (+)
  AND ((TOTALSPACE-NVL(FREESPACE,0))/TOTALSPACE)*100 > 90
 ORDER BY 5 DESC;

select * from ALL_TAB_PARTITIONS /*dba_tab_partitions*/; -- партиции

select * from all_constraints -- все констрейны

select * from DBA_TAB_COLUMNS /*или from cols или from USER_TAB_COLUMNS*/ where upper(column_name) like upper('IN_TRK_GRP') -- найти название столбца 

select 12 || 34 from dual; -- конкатенация

select BS.BSMTRFUNC_PG.f_GetFullTechCode@ASCR(1,2) from dual; -- Запуск процедуры по дебелинку

select * from Nadezhdin.B_NKA_CONN_INT AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '2' HOUR); -- СНИМОК ТАБЛИЦЫ

scn_to_timestamp(ORA_ROWSCN) -- узнать дату DML

select * from dba_role_privs -- просмотреть роли пользователя БД 

select * from dba_sys_privs  -- просмотреть системные роли пользователя БД 

SELECT * FROM ROLE_SYS_PRIVS -- привилегии у роли

select *  from DBA_TAB_PRIVS -- All grants on objects in the database

select * from dba_part_indexes /* --что бы увижеть статус (STATUS)*/; -- просмотреть локальные/глобальные индексы

select * from dba_indexes /*user_indexes*/; -- просмотреть все индексы

SELECT 'alter index '||t.index_name||' rebuild partition '||t.partition_name ||';'  FROM dba_ind_partitions t -- rebuild part index 
WHERE t.STATUS !='USABLE'; 

SELECT 'alter index '||t.index_name||' rebuild INDEX '||t.INDEX_NAME ||';' FROM DBA_INDEXES T  -- rebuild GLOBAL index 
WHERE OWNER IN ('NTKI_MAIN', 'MS_DATA_VOIP');

SELECT * FROM DBA_IND_COLUMNS; 

select * from dba_audit_session; --Логирование логоф/логон. Еще - aud$, dba_audit_trail

create procedure do_truncate( p_tname in varchar2 ) as
begin execute immediate 'truncate table ' || p_tname; end;
OCDM_RAW.do_truncate@DB_LINK_OCDMTS('TIC_OUT_VRNTK'); -- очистить (truncate) таблицу через дебелинк

--привилегии на вью (views grant)
SELECT * FROM ALL_TAB_PRIVS_MADE cc where cc.TABLE_NAME='OMS_FREEMONTH_VIEW';   
---------------------------------------------------------------------
--Переместить партиции
SELECT 'ALTER TABLE '||T.Table_Owner||'.'||T.TABLE_NAME||' MOVE PARTITION '|| T.PARTITION_NAME||' TABLESPACE NTK_DATA_200812_ARCH /*storage(initial 1M next 1M)*/ update indexes;' as ddl
FROM dba_TAB_PARTITIONS T
where t.table_name='TALKS' and t.partition_name like 'P_201512%';

--Переместить суб-партиции
SELECT Distinct 'ALTER TABLE '||T.Owner||'.'||T.Segment_Name||' MOVE SUBPARTITION '|| T.PARTITION_NAME||' TABLESPACE MS_MAIN_201607 update indexes;' as ddl
FROM Dba_Segments T
WHERE Owner='MS_OTS'
AND Tablespace_Name='MS_MAIN_201608'
AND Partition_Name LIKE 'P_201608%';

--Изменить метаданные (словарная операция) в партиции
SELECT 'ALTER TABLE '||T.Table_Owner||'.'||T.TABLE_NAME||' MODIFY DEFAULT ATTRIBUTES FOR PARTITION '|| T.PARTITION_NAME||' TABLESPACE MS_MAIN_201607;' as ddl
FROM dba_TAB_PARTITIONS T
WHERE TABLE_OWNER='MS_OTS'
AND Tablespace_Name='MS_MAIN_201608'
AND Partition_Name LIKE 'P_201608%';

--Переместить индексы (запускать лучше когда меньше людей)
select 'ALTER INDEX '||index_owner||'.'||index_name||' MOVE PARTITION '||partition_name||' TABLESPACE NTK_DATA_'||substr( partition_name, 3 )||';' as ddl
from dba_ind_partitions
where index_owner like 'NTK_DATA%' 
and partition_name != 'P_OTHERS' 
and tablespace_name = 'NTK_DATA'
order by index_owner, index_name, partition_name;

--Изменить таблспейс для индеков (запускать можно в любое время, это словарная операция - метаданные)
select 'ALTER INDEX '||owner||'.'||index_name||' MODIFY DEFAULT ATTRIBUTES TABLESPACE DEFAULT;' as ddl
from dba_part_indexes 
where owner like 'NTK_DATA%' 
and def_tablespace_name is not null
order by owner, index_name;

-----------------------------------------------------------------------
--Просмотреть есть ли данные в партициях 
Select 'select count(*) From '||TABLE_OWNER||'.'||TABLE_NAME||' PARTITION ('||Partition_Name||') union all' as ddl
from dba_tab_partitions 
where TABLE_OWNER='NADEZHDIN'
and TABLE_NAME='TRAFFIC_TELEFON'
order by TABLE_OWNER, Partition_Name;

--удалить партиции
select 'ALTER TABLE '||owner||'.'||segment_name||' DROP PARTITION '||Partition_Name||';' as ddl
from dba_segments 
where owner='MS_DATA_KOF'
and Segment_Type = 'TABLE PARTITION'
and Partition_Name like 'P_201508%'
and Tablespace_Name = 'MS_DATA_KOF_201508'
order by segment_name, Partition_Name;
-----------------------------------------------------------------------
--удалить все объекты схемы
select 'DROP '||object_type||' '||owner||'.'||object_name||decode(object_type, 'TABLE', ' CASCADE CONSTRAINTS', 'TYPE', ' FORCE')||';' DDL
from all_objects
where owner=upper('UT32') 
and object_type in ('TRIGGER', 'VIEW', 'PROCEDURE', 'FUNCTION', 'PACKAGE','TABLE', 'TYPE', 'SEQUENCE', 'SYNONYM','INDEX')
order by owner;

--удалить все роли схемы
select 'drop role'||' '||role||';'
from dba_roles 
where role like 'R%UT32%';
-----------------------------------------------------------------------
SELECT --A.TABLE_NAME, A.COLUMN_NAME, A.CONSTRAINT_NAME, C.OWNER, C.R_OWNER, C_PK.TABLE_NAME AS R_TABLE_NAME, C_PK.CONSTRAINT_NAME R_PK
       'DELETE FROM '||C.OWNER||'.'||A.TABLE_NAME||' WHERE '||A.COLUMN_NAME||' = 264;' as ddl
  FROM ALL_CONS_COLUMNS A
  JOIN ALL_CONSTRAINTS C
    ON A.OWNER = C.OWNER
   AND A.CONSTRAINT_NAME = C.CONSTRAINT_NAME
  JOIN ALL_CONSTRAINTS C_PK
    ON C.R_OWNER = C_PK.OWNER
   AND C.R_CONSTRAINT_NAME = C_PK.CONSTRAINT_NAME
 WHERE C.CONSTRAINT_TYPE = 'R'
   AND C.OWNER = 'BIS'
   AND A.TABLE_NAME <> 'PACKS'
   AND C_PK.TABLE_NAME /*R_TABLE_NAME*/ = 'PACKS'
   ;
-----------------------------------------------------------------------
--grant select all table to user
SELECT 'GRANT SELECT ON ' || OWNER ||'.'|| TABLE_NAME || ' TO NOVAPOSHTA' ||';'
FROM ALL_TABLES
WHERE OWNER = 'SIEBEL'

select * 
from role_tab_privs          -- просмотреть какая роль имеет роль
where role like '%UT32%'
and Table_Name like '%CDR%'  

SELECT * FROM session_roles  -- роли в сиссии пользователя (выполнять под нужным пользователем)

SELECT 
GRANTEE USERNAME,CREATED,ACCOUNT_STATUS,EXPIRY_DATE,LOCK_DATE,/*WMSYS.WM_CONCAT(GRANTED_ROLE)*/LISTAGG(GRANTED_ROLE,'; ')WITHIN GROUP(ORDER BY GRANTED_ROLE)GRANTED_ROLE
FROM DBA_ROLE_PRIVS T1, DBA_USERS T2 
WHERE T1.GRANTEE = T2.USERNAME
--AND T2.ACCOUNT_STATUS!='LOCKED'
AND T2.PROFILE='PROFILE_SAFETY_PSW'
AND CASE WHEN T2.ACCOUNT_STATUS LIKE 'EXPIRED%' THEN EXPIRY_DATE WHEN T2.ACCOUNT_STATUS LIKE 'LOCKED%' THEN LOCK_DATE ELSE SYSDATE END >= ADD_MONTHS(TRUNC(SYSDATE,'MM'),-2)
AND GRANTED_ROLE LIKE 'BIZ%'
--AND GRANTEE LIKE 'NMBUTOK'
GROUP BY GRANTEE,CREATED,ACCOUNT_STATUS,EXPIRY_DATE,LOCK_DATE
ORDER BY GRANTEE;

-----------------------------
with t as

 (select ', serhii.siryk222@kyivstar.net, , serhii.siryk333@kyivstar.net,     serhii.siryk@kyivstar.net, serhii.siryk222@kyivstar.net' txt
  from dual)

  select listagg(data,', ') WITHIN GROUP (ORDER BY NULL) as UNIQ_VAL 
  from

  (

    select distinct regexp_substr ( txt, '[^, ]+', 1, level) data

    from t CONNECT BY level <= length (txt) - length (replace (txt, ',')) + 1

  )
---------------------------------

select * from gv$active_session_history;

select T2.Username, t1.*
from DBA_HIST_ACTIVE_SESS_HISTORY t1, dba_users t2  -- просмотреть историю сессий
where t1.User_Id=t2.User_Id
and t1.sql_id = '95pjhf18y9nzw'  
_______________________________________________________________
SELECT 
grantee role, privilege, owner, table_name object_name
--Distinct table_name object_name
from  dba_tab_privs, dba_roles
where grantee = role
and role = 'BIZR_WORK_REG';
_______________________________________________________________

select * from dba_users -- просмотреть список дба пользователей (или - from all_users) 

select * from gv$parameter -- параметры базы

select * from GV$SESSION t where final_blocking_session is not null /*or sid = 19*/ -- смотрим на final_blocking_session, находим is null

SELECT * FROM GV$SESSION G WHERE G.SID IN (SELECT A.SESSION_ID FROM DBA_LOCK A WHERE A.BLOCKING_OTHERS <> 'Not Blocking'); -- блокирующие обьекты -- block object

SELECT (SELECT USERNAME FROM GV$SESSION T WHERE SID=ff.FINAL_BLOCKING_SESSION and INST_ID=ff.INST_ID) USERNAME_BLOCK,FINAL_BLOCKING_SESSION, FF.* 
FROM GV$SESSION FF
WHERE 1=1 -- БЛОКИРОВКИ
AND FINAL_BLOCKING_SESSION IS NOT NULL
--AND INST_ID = FINAL_BLOCKING_INSTANCE 
--AND SID = FINAL_BLOCKING_SESSION
--AND MACHINE LIKE '%KV-APP-22%'
ORDER BY ff.FINAL_BLOCKING_SESSION;

SELECT * FROM GV$SESSION T WHERE SID=358 
;

select * from gv$process order by Pga_Used_Mem desc;  -- Просмотреть кто сколько хавает SWAP_MEMORY

select * from gv$process where (inst_id,addr) in (select inst_id,paddr from gv$session where username like 'MS_L%Q'); --
______________________________________________________________________________________________________
--select name, value from v$parameter where name in ('sessions','processes');
select * from v$resource_limit where resource_name in ('processes','sessions');

MAX_UTILIZATION  это когда либо достигшее
CURRENT_UTILIZATION это текущее
INITIAL_AL - это какое установленно т.е. какого может достигнуть в принципе
______________________________________________________________________________________________________
-- BITMASK / БИТОВАЯ МАСКА
SELECT BIN_TO_NUM(1, 1, 0)
FROM DUAL;

with t as (select 3 as num from dual)
 
select decode(bitand(num,4),0,0,1) as flag_1
     ,decode(bitand(num,2),0,0,1) as flag_2
     ,decode(bitand(num,1),0,0,1) as flag_3
from t;
______________________________________________________________________________________________________

-- ORACLE 9i
ALTER SESSION SET EVENTS 'immediate trace name flush_cache'; -- очистка буферного кэша запросов
-- ORACLE 10g и выше
ALTER SYSTEM FLUSH BUFFER_CACHE; /*ALTER SYSTEM FLUSH SHARED_POOL;*/ -- очистка буферного кэша запросов


ALTER SYSTEM KILL SESSION '765,31339' IMMEDIATE;  --кильнуть сессию, указать sid,serial# (зайти через sqlplus на нужный инстанс, например - sqlplus dba_admin@VRNTK_INST1)

select * from all_constraints WHERE owner in ('DVOYNOSY') and constraint_type='R' -- просмотреть констрейны

alter index MS_KIV.UI_FRAUD_STAT_ZONES rebuild -- перекомпелить индекс

alter index IF1117PRICE_DEST_CODES_UNDO rebuild partition MAXVALUE; -- перекомпелить локальный индекс (партиционированный)

drop table OELISEEV.ROOMS cascade constraints; -- удалить таблицу вместе с constraints

DROP TABLE my_table PURGE; -- удалить таблицу минуя корзину

CREATE USER A_TEST IDENTIFIED BY a_test ; --создать пользователя 

GRANT CREATE ANY TABLE TO NOVAPOSHTA; -- 

CREATE USER KASTANTA91 IDENTIFIED BY "1331" 
DEFAULT TABLESPACE TBS_KASTANTA  -- УКАЗАТЬ TABLESPACE
TEMPORARY TABLESPACE TEMP_KASTANTA; -- УКАЗАТЬ TEMPORARY TABLESPACE

select * from dba_ts_quotas where username='NADEZHDIN'; -- квоты по TABLESPACE_NAME
alter user NADEZHDIN quota unlimited on BIZ_MAIN; -- дать квоты на TABLESPACE_NAME

alter user scott identified by tiger; -- поменять пароль

ALTER USER scott ACCOUNT UNLOCK; --разблокировать юзера

grant connect to a_test; -- дать грант

Grant Alter on MS_REP_VRNTK_OUT to OPBIL_USER;

grant SELECT on SCHEME.TABLE1 to USER1 /*with grant option*/ ;

REVOKE connect FROM a_test; --забрать роль

GRANT administer database trigger TO TLSNS_REP; -- 

GRANT EXECUTE ON BIS_HAS.BCM_HAS_INDIVID TO FCS;

CREATE SYNONYM BCM_HAS_INDIVID FOR BIS_HAS.BCM_HAS_INDIVID

CREATE OR REPLACE EDITIONABLE TRIGGER "NOVAPOSHTA"."TRG_UPDATE_NP_PARTY_PHONE" 
BEFORE INSERT OR UPDATE ON NP_PARTY_PHONE
FOR EACH ROW
BEGIN
:NEW.DT_UPDATE := sysdate;
END;
/
ALTER TRIGGER "NOVAPOSHTA"."TRG_UPDATE_NP_PARTY_PHONE" ENABLE;

CREATE SEQUENCE seq_test START WITH 1;
--тригер для заполнения ид
CREATE OR REPLACE TRIGGER TRG_INSERT_DM_NP_LOG
BEFORE INSERT ON DM_NP_LOG
--DECLARE
    --PRAGMA AUTONOMOUS_TRANSACTION;
FOR EACH ROW
 WHEN (new.ID_DES IS NULL) 
BEGIN
  SELECT seq_test.NEXTVAL 
  INTO :new.ID_DES
  FROM dual;
END;
--------------
V_TBL_NOT    EXCEPTION; -- Таблица не существует
PRAGMA       EXCEPTION_INIT(V_TBL_NOT,-00942);
-------------------

CREATE OR REPLACE TRIGGER KRONOS_DDL_BCS_TRIGGER
  BEFORE CREATE OR DROP /*OR ALTER*/ ON SCHEMA

BEGIN
  INSERT INTO FCS.KRONOS_DDL_LOG
    SELECT SYSDATE NAVI_DATE,
           ORA_SYSEVENT,
           ORA_DICT_OBJ_OWNER,
           ORA_DICT_OBJ_TYPE,
           ORA_DICT_OBJ_NAME,
           SYS_CONTEXT('USERENV', 'IP_ADDRESS') IP,
           SYS_CONTEXT('USERENV', 'TERMINAL') TERMINAL,
           SYS_CONTEXT('USERENV', 'OS_USER') OS_USER,
           SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA') CURRENT_SCHEMA,
           SYS_CONTEXT('USERENV', 'SESSION_USER') SESSION_USER,
           SYS_CONTEXT('USERENV', 'MODULE') MODULE,
           SYS_CONTEXT('USERENV', 'ACTION') ACTION,
           SYS_CONTEXT('USERENV', 'SID') SID
      FROM DUAL WHERE ORA_DICT_OBJ_NAME NOT LIKE 'SYS_PLSQL_%';
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END KRONOS_DDL_BCS_TRIGGER;


CREATE OR REPLACE TRIGGER KRONOS_DDL_LOG_TRG
  BEFORE DELETE ON FCS.KRONOS_DDL_LOG
  FOR EACH ROW
BEGIN
  RAISE_APPLICATION_ERROR(-20000, 'Уваснемаєправ);
END;


---------------------

CREATE SEQUENCE NADYEZHDINKA.seq_address_ch START WITH 1;

SELECT seq_address_ch.nextval
FROM dual;

-- только для БД12 сиквенс 
create table t1 (
    c1 NUMBER GENERATED ALWAYS as IDENTITY(START with 1 INCREMENT by 1),
    c2 VARCHAR2(10)
    );

alter SEQUENCE seq_test increment by -4 minvalue 0;
SELECT seq_test.NEXTVAL FROM dual;
alter SEQUENCE seq_test increment by 1 minvalue 0;

SELECT seq_test.NEXTVAL FROM dual;
alter sequence seq_test restart start with 5;
_______________________________________________________________
--найти блокировки по таблице
SELECT s.sid, s.serial#, username U_NAME, owner OBJ_OWNER,
object_name, object_type, s.osuser,
DECODE(l.block,
  0, 'Not Blocking',
  1, 'Blocking',
  2, 'Global') STATUS,
  DECODE(v.locked_mode,
    0, 'None',
    1, 'Null',
    2, 'Row-S (SS)',
    3, 'Row-X (SX)',
    4, 'Share',
    5, 'S/Row-X (SSX)',
    6, 'Exclusive', TO_CHAR(lmode)
  ) MODE_HELD
FROM gv$locked_object v, dba_objects d, gv$lock l, gv$session s
WHERE v.object_id = d.object_id
AND (v.object_id = l.id1)
AND v.session_id = s.sid
AND d.object_type = 'TABLE' 
and d.object_name='BREAK_IDSL'
ORDER BY username, session_id;
_______________________________________________________________
select username, 
       terminal, 
       max(timestamp) l_date
from dba_audit_session  -- аудит -- dba_audit_trail  -- Таблица AUD$
where username not in ('SYS', 'SYSTEM','DBSNMP','SYSMAN','SCOTT')
  and timestamp > sysdate-30    
group by username, terminal
_______________________________________________________________

/*+ parallel(4) */ --   -/+ включить/отключить параллели
________________________________________________________________
select *
from dba_tab_privs
where GRANTEE = 'EASKR'
and OWNER like '%CHK%'; --  просмотреть гранты 

________________________________________________________________
SELECT * FROM TABLE_1 PARTITION(ABC);   Партиция

SELECT * FROM TABLE_1 SUBPARTITION(ABC); субпартиция

SELECT * FROM TABLE_1 PARTITION(ABC)
UNION ALL
SELECT * FROM TABLE_1 PARTITION(CDE)


________________________________________________________________

TRUNCATE TABLE dba_admin.number1 - очистить табличку

INSERT INTO number1@vrntk_ms(NUM)
select telefon from SAR.TEST_SCORRING_DROP@MIXDB_SAR1  -  вставка в другую базу
________________________________________________________________

select *
from v$session - просмотреть сессию пользователя

SELECT SQ.PARSING_SCHEMA_NAME, SQ.FIRST_LOAD_TIME,SQ.LAST_LOAD_TIME, SQ.LAST_ACTIVE_TIME, SQ.*
FROM GV$SQL SQ
WHERE SQL_TEXT LIKE '%vq_tech_all2%'
AND PARSING_SCHEMA_NAME='MS_MAIN'
ORDER BY SQ.LAST_LOAD_TIME DESC 
;

select round(TIME_REMAINING/60,1) as "REMAINING~MIN", sl.*
from gv$session_longops sl  -- посмотреть статус длинных сессий
--where sid=476 and Serial#=45153
order by 1 desc;

SELECT *
FROM v$sql_monitor; -- монитор запросов

select s.sql_fulltext
, ses.username
, ses.osuser
from v$sql s
, v$session ses
where ses.sql_address=s.address; 
________________________________________________________________

Case - сделать столбцами

select uni_a, sum(obl),sum(ukr),sum(mir), sum(obl)+sum(ukr)+sum(mir) all_ from (
select Uni_A,
case
  when substr(Uni_B,1,5) = substr(Uni_a,1,5) then 1
  Else 0
end obl,
case
  when substr(Uni_B,1,5) != substr(Uni_a,1,5) and uni_b like '380%' then 1
  Else 0
end ukr,
case
  when uni_b not like '380%'  then 1
  Else 0
end mir
from aaa_taxphones
where Filiya = 'Львівська'
)
group by Uni_A
order by 4 desc

________________________________________________________________
Агрегатные функции:  
APPROX_COUNT_DISTINCT
AVG
COLLECT
CORR
CORR_*
COUNT
COVAR_POP
COVAR_SAMP
MEDIAN -- медиана
________________________________________________________________
-- Ранк (Топ/top, RANK) 
SELECT FIO, SUMMA, RANK() OVER(ORDER BY SUMMA DESC) RNK_SUM, ROW_NUMBER() OVER( /*partition BY CNT*/ ORDER BY SUMMA DESC) ROW_NUM, CNT, RANK() OVER(ORDER BY CNT DESC) RNK_CNT
FROM (
SELECT 'Мецкан Василь Георгійович' FIO,	315790 SUMMA, 5 CNT FROM DUAL UNION
SELECT 'Остренко Павло Вікторович' FIO,	297112 SUMMA, 10 CNT FROM DUAL UNION
SELECT 'Біліченко Вікторія Миколаївна' FIO,	191554 SUMMA, 15 CNT FROM DUAL UNION
SELECT 'Войціховський Андрій Петрович' FIO,	86172 SUMMA, 25 CNT FROM DUAL UNION
SELECT 'Галяшинський Антон Геннадійович' FIO,	95422 SUMMA, 35 CNT FROM DUAL UNION
SELECT 'Шевчук Ірина Анатоліївна' FIO,	79554 SUMMA, 35 CNT FROM DUAL UNION
SELECT 'Ганнота Олена Петрівна' FIO,	79554 SUMMA, 55 CNT FROM DUAL )
ORDER BY 5
;
________________________________________________________________
--Отнять даты с 
SELECT *
FROM
( SELECT ROW_NUMBER() OVER( partition BY agentID ORDER BY eventDateTime) ROW_NUM, agentID, eventDateTime, eventType 
  FROM AgentStateDetail WHERE AgentStateDetail.agentID IN (90,89) ) T1
LEFT JOIN
( SELECT ROW_NUMBER() OVER( partition BY agentID ORDER BY eventDateTime) ROW_NUM, agentID, eventDateTime, eventType 
  FROM AgentStateDetail WHERE AgentStateDetail.agentID IN (90,89) ) T2
ON T1.ROW_NUM = T2.ROW_NUM-1
AND T1.agentID = T2.agentID
ORDER BY T1.agentID, T1.eventDateTime, T1.ROW_NUM
;_____________________________________________________________
--PIVOT

select *
from 
(

select OPERATOR_ID,  day,  calls 
from (
(select '9999' OPERATOR_ID, to_number(05) day, 168 calls from dual
union all
select '9999' OPERATOR_ID, to_number(06) day, 230 calls from dual
union all
select '8888' OPERATOR_ID, to_number(05) day, 145 calls from dual
union all
select '8888' OPERATOR_ID, to_number(06) day, 784 calls from dual
union all
select '6666' OPERATOR_ID, to_number(05) day, 417 calls from dual
union all
select '6666' OPERATOR_ID, to_number(06) day, 788 calls from dual))

)
PIVOT            
(
sum(calls)
for day
in (04,05,06,07)
)
order by 1;
________________________________________________________________

--Развернуть строку в столбец
--connect by-ем
select 1 id, ' 1' || '; ' || '1.1' || '; ' || '1.1.1' || '; ' || '1.1.1.1' num from dual;

select num from (
select id, regexp_substr( t.num, '[^;]+', 1, level ) num
from ( select 1 id, ' 1' || '; ' || '1.1' || '; ' || '1.1.1' || '; ' || '1.1.1.1' num from dual ) t
where t.id = 1
connect by level <= length(regexp_replace(t.num, '[^;]+')) + 1
); 

--UNPIVOT-том
select * from 
       ( select '1' as g1, '1.1' as g11, '1.1.1' as g111, '1.1.1.1' as g1111 from dual ) 
UNPIVOT (g3 FOR g4 IN (g1, g11, g111, g1111))
;
________________________________________________________________
 --connect by
 
select to_char(level) xoxo
from dual
connect by level <= 5


select trunc(sysdate-10-1+level) daten, Dummy 
from dual
connect by level <= (sysdate-(sysdate-10));
________________________________________________________________

with parameter as 
(select A_FIRST_DATE, add_months(A_FIRST_DATE,1) A_LAST_DATE from (select to_date ('01-11-2014','DD-MM-YYYY') A_FIRST_DATE from DUAL))
Select d.dummy, p.A_FIRST_DATE, P.A_LAST_DATE from DUAL d, parameter p;

with parameter as 
(select A_FIRST_DATE, add_months(A_FIRST_DATE,1) A_LAST_DATE from (select TRUNC(add_months(sysdate,-1),'MM') A_FIRST_DATE from DUAL))
Select d.dummy, p.A_FIRST_DATE, P.A_LAST_DATE from DUAL d, parameter p;
________________________________________________________________

SELECT 
      DES_NAME, CODE, 
      /*nvl(*/substr( CODE, 1, instr( CODE, '(', 1, 1 ) - 1)/*, substr( CODE, 1, instr( CODE, ' ', 1, 1 ) - 1))*/ Country_Code, 
      case when CODE like '%(%' then 
      RPAD(substr(replace(replace(substr( CODE, instr( CODE, '(', 1, 1 )),'excl.',';'),' ',null),2), LENGTH(substr(replace(replace(substr( CODE, instr( CODE, '(', 1, 1 )),'excl.',','),' ',null),2)) - 1) 
            else replace(replace(substr( CODE, instr( CODE, '(', 1, 1 )),'excl.',';'),' ',null) end Codes
FROM (
SELECT 'Afghanistan (LCR sch)' DES_NAME, TRIM('93 (1-6,8-9)') CODE FROM DUAL UNION
SELECT 'Alaska (LCR sch)' DES_NAME, TRIM('1 907') CODE FROM DUAL UNION
SELECT 'Bahrain (LCR sch)' DES_NAME, TRIM('973') CODE FROM DUAL UNION
SELECT 'American Samoa' DES_NAME, TRIM('1684 (1-9 excl.252,254,256,258,272,733)') CODE FROM DUAL UNION
SELECT 'Venezuela mobile (LCR sch)' DES_NAME, TRIM('58 (4,6,8,15-16)') CODE FROM DUAL
);
__________________________________________________________________________________________
-- Генерация html таблицы
SELECT 
      '<!DOCTYPE html>
      <html>
          <head>
              <title></title>
              <style>
                  table, th, td {border: 1ßpx solid;}
                  .center{text-align: center;}
              </style>
          </head>
          <body>
              <table border=1 cellspacing=0 cellpadding=2 rules=GROUPS frame=HSIDES>
                  <thead>
                      <tr align=left>
                          <th>Послуга</th>
                          <th>Кількість</th>
                      </tr>
                  </thead>
                    <tbody>
                    '|| LIST_ORDER || '
                    </tbody>
              </table>
          </body>
      </html>' AS HTML_TABLE
FROM (
SELECT LISTAGG('<tr align=left> 
                   <td>' || SERV_NAME || '</td>' || '
                   <td class=''center''> ' || TOTAL_COUNT||'</td> 
               </tr>', '<tr>')
      WITHIN GROUP(ORDER BY TOTAL_COUNT) AS LIST_ORDER
 FROM ( SELECT 'Azure Stack vCPU, Шт.' AS SERV_NAME, 4 AS TOTAL_COUNT FROM DUAL 
         UNION ALL
        SELECT 'Azure Stack RAM, Gb' AS SERV_NAME, 16 AS TOTAL_COUNT FROM DUAL 
         UNION ALL
        SELECT 'Azure Stack Storage, Gb' AS SERV_NAME, 10 AS TOTAL_COUNT FROM DUAL ));
__________________________________________________________________________________________

Следующий оператор создает индекс CustNameldx, по столбцу Name таблицы CUSTOMER:

CREATE INDEX CustNameldx ON CUSTOMER(Name); -- глобальный индекс

CREATE UNIQUE INDEX u_ldx ON TMP_OUT_TRAF(cdr_id, rate); -- глобальный индекс

CREATE INDEX name_idx ON TMP_OUT_TRAF(cdr_id) LOCAL TABLESPACE SFFP_TS; -- локальный индекс

CREATE TABLESPACE BSW_AUDIT DATAFILE '+DG_DATA' SIZE 100M AUTOEXTEND ON NEXT 100M EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT AUTO; -- создать TABLESPACE
________________________________________________________________
--Перевернуть столбец в строку

select ''''||LISTAGG(tg, ''',''') WITHIN GROUP (ORDER BY tg DESC)||'''' tg from (
select tg from (
select 1111 tg from dual union all select 2222 tg from dual union all
select 3333 tg from dual union all select 4444 tg from dual));


select colum_1, sys_xmlagg(xmlelement(col,name_colum||',')).EXTRACT('/ROWSET/COL/text()').getclobval() as colum_2
from table
group by colum_1


select vname from (
select PERSONALACCOUNT, wmsys.wm_concat(vname) vname
from EASKR_CLIENTS
group by PERSONALACCOUNT);
__________________________________________________________________

select qq, sum(ww) ww from (   
SELECT  trunc(DT_MODIFIED,'HH') qq, COUNT(*) ww
FROM ms_data_kiv.V_REG_FILES_OUT
WHERE 1=1
AND DT_MODIFIED >= TRUNC(SYSDATE)-2
GROUP BY trunc(DT_MODIFIED,'HH')

union all

SELECT (TRUNC(sysdate))+(LEVEL-1)/24 dt,0 cnt
FROM DUAL
CONNECT BY 24 >= LEVEL 
)group by qq
ORDER BY 1 DESC;
_______________________________________________________________

CREATE TABLE TABLE_TEST
(
P_Id int /*NOT NULL*/ UNIQUE
)
________________________________________________________________
--Создавать партиции

   PARTITION BY RANGE (REG_DATE)
( PARTITION P_201403 VALUES LESS THAN (TO_DATE('01-04-2014','dd-mm-yyyy'))
);

ALTER TABLE MS_DATA_KIV.IP_COIALL_new ADD PARTITION P_201404 VALUES LESS THAN (to_date('201405','YYYYMM')) TABLESPACE MS_DATA_KIV_201403;

ALTER TABLE BP_CALLS SPLIT PARTITION p_others AT (to_date('02.12.2015', 'dd.mm.yyyy') ) INTO (PARTITION p_20151201  tablespace MS_DATA_KHR_201512, PARTITION p_others) UPDATE INDEXES;



ALTER TABLE t1 DROP PARTITION p0, p1;


авто:

CREATE TABLE SFFP_USER.TRAFFIC_INTERNET 
(	
COD_FIL VARCHAR2(10 BYTE),
ORAX VARCHAR2(64 BYTE),
US_ID NUMBER, 
LOGIN VARCHAR2(500 BYTE), 
CONN_BEGIN DATE, 
CONN_END DATE, 
DURATION NUMBER, 
IN_BYTES NUMBER, 
OUT_BYTES NUMBER
) 
  --PARTITION BY RANGE (CONN_BEGIN) INTERVAL (NUMTOYMINTERVAL (1, 'MONTH'))  -- партиции по месячно 
    PARTITION BY RANGE (CONN_BEGIN) INTERVAL (NUMTODSINTERVAL (1, 'DAY'))   -- партиции по дням  
 ( 
  PARTITION PART_000001  VALUES LESS THAN (TO_DATE('1990-01-01 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN'))
  );
 
ALTER TABLE t1 DROP PARTITION p0; 
________________________________________________________________
--СУБ-ПАРТИЦИИ

CREATE TABLE SFFP_USER.TRAFFIC_INTERNET_2 
(	
COD_FIL VARCHAR2(10 BYTE),
ORAX VARCHAR2(64 BYTE),
US_ID NUMBER, 
LOGIN VARCHAR2(500 BYTE), 
CONN_BEGIN DATE, 
CONN_END DATE, 
DURATION NUMBER, 
IN_BYTES NUMBER, 
OUT_BYTES NUMBER
) 

  --PARTITION BY RANGE (CONN_BEGIN) INTERVAL (NUMTOYMINTERVAL(1, 'MONTH'))  -- партиции по месячно 
  PARTITION BY RANGE (CONN_BEGIN) INTERVAL (INTERVAL'1'DAY) -- партиции по дням  

  --SUBPARTITION BY HASH (COD_FIL) SUBPARTITIONS 25 -- указать поле относящееся к субпартициям + кол-во субпартиции 
  
  --SUBPARTITION BY LIST (FILID)
       
  /* BY RANGE(FILID)
     SUBPARTITION TEMPLATE
    ( SUBPARTITION p_low VALUES LESS THAN (1000)
    , SUBPARTITION p_medium VALUES LESS THAN (4000)
    , SUBPARTITION p_high VALUES LESS THAN (8000)
    , SUBPARTITION p_ultimate VALUES LESS THAN (maxvalue)
    )*/

(
   PARTITION init_p0 VALUES LESS THAN (TO_DATE('01-01-1991', 'DD-MM-YYYY'))
)
;
______________________________________________________________________________________________________

  PARTITION BY HASH (FILIAL) PARTITIONS 25;

----------------------------------------------------------------------------------------------------------------------------------------------------------
MSSQL:

-- Все столбцы и таблицы (MSSQL)
SELECT o.Name                   as Table_Name
     , c.Name                   as Field_Name
     , t.Name                   as Data_Type
     , t.length                 as Length_Size
     , t.prec                   as Precision_
FROM syscolumns c 
     INNER JOIN sysobjects o ON o.id = c.id
     LEFT JOIN  systypes t on t.xtype = c.xtype  
WHERE o.type = 'U' 
ORDER BY o.Name, c.Name;

--Дата в формате dd.mm.yyyy (MSSQL)
WHERE mesg_crea_date_time BETWEEN CONVERT(DATETIME, '01.12.2018', 104) AND CONVERT(DATETIME, '03.12.2018', 104)