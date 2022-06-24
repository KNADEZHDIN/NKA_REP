CREATE OR REPLACE PACKAGE APL_UTILS AS

  -- Процедура для обогащения полей curr_type и json_value в таблице util.cur_exch_rate из API NBU (SM-110/SM-111)
  PROCEDURE DOWNLOAD_CUR_EXCH_RATE;
  
  -- Процедура для обогащения всех полей таблицы util.cur_exch_rate и util.cur_exch_rate_history из вью util.cur_exch_rate_v (SM-112/SM-113)
  PROCEDURE ACTION_CUR_EXCH_RATE;
  
  -- Процедура для обогащения всех полей таблицы util.cur_exch_rate и util.cur_exch_rate_history по криптовалюте из Linux сервера (SM-114)
  PROCEDURE LOAD_ACTION_CUR_FROM_FILE;

END APL_UTILS;
/

CREATE OR REPLACE PACKAGE BODY APL_UTILS AS

  V_ID NUMBER := 0;

  -- Внутреняя функция, которая определяет значения для идентификатора по полю util.cur_exch_rate.id
  FUNCTION GET_MAX_ID RETURN NUMBER IS
    V_MAX_ID NUMBER;
  BEGIN
    SELECT NVL(MAX(CR.ID), 0) + 1 INTO V_MAX_ID FROM UTIL.CUR_EXCH_RATE CR;
    RETURN V_MAX_ID;
  END GET_MAX_ID;

  -- Внутреняя функция, которая определяет значения для идентификатора по полю util.cur_exch_rate.id
  FUNCTION GET_MAX_HIST_ID RETURN NUMBER IS
    V_MAX_ID NUMBER;
  BEGIN
    SELECT NVL(MAX(CR.ID), 0) + 1
      INTO V_MAX_ID
      FROM UTIL.CUR_EXCH_RATE_HISTORY CR;
    RETURN V_MAX_ID;
  END GET_MAX_HIST_ID;

  -- Процедура для обогащения полей curr_type и json_value в таблице util.cur_exch_rate из API NBU (SM-110/SM-111)
  PROCEDURE DOWNLOAD_CUR_EXCH_RATE IS
  
  BEGIN
  
    -- 1.
    INSERT INTO UTIL.SYS_LOG
      (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
    VALUES
      ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
       'DOWNLOAD_CUR_EXCH_RATE',
       'Процедуру DOWNLOAD_CUR_EXCH_RATE запущено',
       'WARNING',
       SYSDATE);
  
    -- 2.
    DELETE FROM UTIL.CUR_EXCH_RATE
     WHERE CURR_TYPE IN ('PRE_METAL', 'MONEY');
  
    -- 3.
    FOR CC IN (SELECT CT.CURR_CODE
                 FROM UTIL.CURR_TYPE CT
                WHERE CT.CURR_TYPE IN ('MONEY', 'PRE_METAL')) LOOP
    
      BEGIN
        V_ID := GET_MAX_ID;
      
        -- 4.
        INSERT INTO UTIL.CUR_EXCH_RATE
          (ID, CURR_TYPE, JSON_VALUE)
          SELECT V_ID,
                 CASE
                   WHEN J.JSON LIKE '%XAU%' OR J.JSON LIKE '%XAG%' THEN
                    'PRE_METAL'
                   ELSE
                    'MONEY'
                 END AS CURR_TYPE,
                 J.JSON
            FROM (SELECT SYS.GET_CURR_NBU(CC.CURR_CODE) AS JSON FROM DUAL) J;
      
      EXCEPTION
        WHEN OTHERS THEN
          INSERT INTO UTIL.SYS_LOG -- 5.
            (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
          VALUES
            ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
             'DOWNLOAD_CUR_EXCH_RATE',
             'процедуру призупинено DOWNLOAD_CUR_EXCH_RATE сталася помилка',
             'BAD',
             SYSDATE);
      END;
    
    END LOOP;
  
    -- 6.
    INSERT INTO UTIL.SYS_LOG
      (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
    VALUES
      ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
       'DOWNLOAD_CUR_EXCH_RATE',
       'Процедуру DOWNLOAD_CUR_EXCH_RATE завершено',
       'OK',
       SYSDATE);
  
    COMMIT;
  
  END DOWNLOAD_CUR_EXCH_RATE;

  -- Процедура для обогащения всех полей таблицы util.cur_exch_rate и util.cur_exch_rate_history из вью util.cur_exch_rate_v (SM-112/SM-113)
 
 PROCEDURE ACTION_CUR_EXCH_RATE IS
  
  BEGIN
   INSERT INTO UTIL.SYS_LOG
      (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
    VALUES
      ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
       'ACTION_CUR_EXCH_RATE',
       'Процедуру ACTION_CUR_EXCH_RATE запущено',
       'WARNING',
       SYSDATE);
    BEGIN
      -- 2
      MERGE INTO UTIL.CUR_EXCH_RATE CR
      USING (SELECT CE.ID,
                    CE.R030,
                    CE.TXT,
                    CE.RATE,
                    CE.CUR,
                    CE.CURR_TYPE,
                    CE.EXCHANGEDATE
               FROM UTIL.CUR_EXCH_RATE_V CE
              WHERE CE.CURR_TYPE IN ('MONEY', 'PRE_METAL')) FN
      ON (CR.ID = FN.ID)
      WHEN MATCHED THEN
        UPDATE
           SET CR.CURR_ID   = FN.R030,
               CR.CURR_TEXT = FN.TXT,
               CR.RATE      = FN.RATE,
               CR.CURR_CODE = FN.CUR;
    
      -- 3
      FOR CC IN (SELECT CE.CURR_ID,
                        CE.CURR_TEXT,
                        CE.RATE,
                        CE.CURR_CODE,
                        CE.CURR_TYPE,
                        CE.EXCHANGEDATE
                   FROM UTIL.CUR_EXCH_RATE CE
                  WHERE CE.CURR_TYPE IN ('MONEY', 'PRE_METAL')) LOOP
      
        V_ID := GET_MAX_HIST_ID;
      
        INSERT INTO UTIL.CUR_EXCH_RATE_HISTORY
          (ID,
           CURR_ID,
           CURR_TEXT,
           RATE,
           CURR_CODE,
           CURR_TYPE,
           EXCHANGEDATE)
        VALUES
          (V_ID,
           CC.CURR_ID,
           CC.CURR_TEXT,
           CC.RATE,
           CC.CURR_CODE,
           CC.CURR_TYPE,
           CC.EXCHANGEDATE);
      
      END LOOP;
    
    EXCEPTION
      WHEN OTHERS THEN
       INSERT INTO UTIL.SYS_LOG
            (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
          VALUES
            ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
             'ACTION_CUR_EXCH_RATE',
             'процедуру призупинено ACTION_CUR_EXCH_RATE сталася помилка',
             'BAD',
             SYSDATE); -- 4. TODO: если любая ошибка, фиксировать в логи
    END;
  INSERT INTO UTIL.SYS_LOG
      (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
    VALUES
      ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
       'ACTION_CUR_EXCH_RATE',
       'Процедуру ACTION_CUR_EXCH_RATE завершено',
       'OK',
       SYSDATE);
       COMMIT;
  END ACTION_CUR_EXCH_RATE;
  
  -- Процедура для обогащения всех полей таблицы util.cur_exch_rate и util.cur_exch_rate_history по криптовалюте из Linux сервера (SM-114)
  PROCEDURE LOAD_ACTION_CUR_FROM_FILE IS
  
  BEGIN
    
    DBMS_OUTPUT.PUT_LINE('ТЕСТ :-) '||TO_CHAR(SYSDATE,'DD.MM.YYYY HH24:MI:SS'));
  
  END LOAD_ACTION_CUR_FROM_FILE;

END APL_UTILS;
/
