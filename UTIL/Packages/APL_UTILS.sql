CREATE OR REPLACE PACKAGE APL_UTILS AS

  -- Процедура збагачення полей curr_type и json_value у таблиці util.cur_exch_rate из API NBU (SM-110/SM-111)
  PROCEDURE DOWNLOAD_CUR_EXCH_RATE;

  -- Процедура збагачення всіх полей таблиці util.cur_exch_rate и util.cur_exch_rate_history із вью util.cur_exch_rate_v (SM-112/SM-113)
  PROCEDURE ACTION_CUR_EXCH_RATE;

  -- Процедура збагачення усіх полей таблиці util.cur_exch_rate и util.cur_exch_rate_history за криптовалютою із Linux сервера (SM-114)
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
  
    -- 1. зафіксувати старт запуску процедури до таблиці логов
	
    INSERT INTO UTIL.SYS_LOG
      (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
    VALUES
      ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
       'DOWNLOAD_CUR_EXCH_RATE',
       'Процедуру DOWNLOAD_CUR_EXCH_RATE запущено',
       'WARNING',
       SYSDATE);
  
    -- 2. видалення значення CURR_TYPE з таблиці CUR_EXCH_RATE з типом PRE_METAL', 'MONEY'
	
    DELETE FROM UTIL.CUR_EXCH_RATE
     WHERE CURR_TYPE IN ('PRE_METAL', 'MONEY');
  
    -- 3. вибір з циклу курс валют з типом PRE_METAL', 'MONEY'
	
    FOR CC IN (SELECT CT.CURR_CODE
                 FROM UTIL.CURR_TYPE CT
                WHERE CT.CURR_TYPE IN ('MONEY', 'PRE_METAL')) LOOP
    
      BEGIN
        V_ID := GET_MAX_ID;
      
        -- 4. записати JSON відповідь з циклу до таблиці CUR_EXCH_RATE в поле JSON_VALUE, а поле CURR_TYPE поле CURR_TYPE з циклу 

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
      
      -- 5. якщо сталася будь-яка помилка зафіксувати її у таблиці логов 
    
      EXCEPTION
        WHEN OTHERS THEN
          INSERT INTO UTIL.SYS_LOG 
            (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
          VALUES
            ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
             'DOWNLOAD_CUR_EXCH_RATE',
             'процедуру призупинено DOWNLOAD_CUR_EXCH_RATE сталася помилка',
             'BAD',
             SYSDATE);
      END;
    
    END LOOP;
  
    -- 6. зафіксувати завершення процедури у таблиці логов
  
    INSERT INTO UTIL.SYS_LOG
      (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
    VALUES
      ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
       'DOWNLOAD_CUR_EXCH_RATE',
       'Процедуру DOWNLOAD_CUR_EXCH_RATE завершено',
       'OK',
       SYSDATE);
    -- 7. зафіксувати DML операцію 
    COMMIT;
  
  END DOWNLOAD_CUR_EXCH_RATE;

  -- Процедура для обогащения всех полей таблицы util.cur_exch_rate и util.cur_exch_rate_history из вью util.cur_exch_rate_v (SM-112/SM-113)
  
 PROCEDURE ACTION_CUR_EXCH_RATE IS
  
  BEGIN
  
    -- 1. зафіксувати старт запуску процедури до таблиці логов
	
    INSERT INTO UTIL.SYS_LOG
      (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
    VALUES
      ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
       'ACTION_CUR_EXCH_RATE',
       'Процедуру ACTION_CUR_EXCH_RATE запущено',
       'WARNING',
       SYSDATE);
       
   -- 2. оновити данні у актуальній таблиці валют CUR_EXCH_RATE із вью СUR_EXCH_RATE_V
   
    BEGIN
     	  
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
    
      -- 3. додати данні до історичної таблиці CUR_EXCH_RATE_HISTORY із вью СUR_EXCH_RATE_V
	  
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
    -- 4. якщо сталася будь-яка помилка зафіксувати її у таблиці логов 
	
    EXCEPTION
      WHEN OTHERS THEN
        INSERT INTO UTIL.SYS_LOG 
          (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
        VALUES
          ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
           'ACTION_CUR_EXCH_RATE',
           'процедуру призупинено ACTION_CUR_EXCH_RATE сталася помилка',
           'BAD',
           SYSDATE);
    END;
  
    -- 5. афіксувати завершення процедури у таблиці логов
	
    INSERT INTO UTIL.SYS_LOG
      (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
    VALUES
      ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
       'ACTION_CUR_EXCH_RATE',
       'Процедуру ACTION_CUR_EXCH_RATE завершено',
       'OK',
       SYSDATE);
       
    -- 6. зафіксувати DML операцію
    COMMIT;
  
  END ACTION_CUR_EXCH_RATE;
  -- Процедура для обогащения всех полей таблицы util.cur_exch_rate и util.cur_exch_rate_history по криптовалюте из Linux сервера (SM-114)
PROCEDURE LOAD_ACTION_CUR_FROM_FILE IS
  
   BEGIN
  
    -- 1. зафіксувати старт запуску процедури до таблиці логов
	
    INSERT INTO UTIL.SYS_LOG
      (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
    VALUES
      ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
       'LOAD_ACTION_CUR_FROM_FILE',
       'Процедуру LOAD_ACTION_CUR_FROM_FILE запущено',
       'WARNING',
       SYSDATE);
       
  -- 2. видалення значення CURR_TYPE з таблиці CUR_EXCH_RATE з типом 'CRYPTO'
	
    DELETE FROM UTIL.CUR_EXCH_RATE
     WHERE CURR_TYPE = 'CRYPTO';
     
    -- 3. рахувати дані по курсу кріптовалют з файлу на Linux сервері
    
    FOR CC IN (SELECT TT.R030,
                      TT.TXT,
                      TT.RATE,
                      TT.CUR,
                      'CRYPTO' AS CURR_TYPE,
                      TO_DATE(TT.EXCHANGEDATE, 'dd.mm.yyyy') AS EXCHANGEDATE,
                      JSON_VALUE
                    FROM (SELECT SYS.READ_FILE(P_LOCATION => 'CRYPTO_CURR', P_FILENAME => 'crypto.json') JSON_VALUE FROM DUAL) CC, JSON_TABLE
                    (
                        JSON_VALUE, '$[*]'
                          COLUMNS 
                          (
                            R030           NUMBER        PATH '$.r030',
                            TXT            VARCHAR2(100) PATH '$.txt',
                            RATE           NUMBER        PATH '$.rate',
                            CUR            VARCHAR2(100) PATH '$.cc',
                            EXCHANGEDATE   VARCHAR2(100) PATH '$.exchangedate'
                          )
                    ) TT) LOOP
      
      BEGIN
      
        V_ID := GET_MAX_ID;
      
        -- 4.записати данні до актуальної таблиці CUR_EXCH_RATE з циклу 
        
        INSERT INTO UTIL.CUR_EXCH_RATE
          (ID,
           CURR_ID,
           CURR_TEXT,
           RATE,
           CURR_CODE,
           CURR_TYPE,
           EXCHANGEDATE,
           JSON_VALUE)
        VALUES
          (V_ID,
           CC.R030,
           CC.TXT,
           CC.RATE,
           CC.CUR,
           CC.CURR_TYPE,
           CC.EXCHANGEDATE,
           CC.JSON_VALUE);
      
        V_ID := GET_MAX_HIST_ID;
      
        -- 5. додати данні до історичної таблиці CUR_EXCH_RATE_HISTOR із циклу 
        
        INSERT INTO UTIL.CUR_EXCH_RATE_HISTORY
          (ID, CURR_ID, CURR_TEXT, RATE, CURR_CODE, CURR_TYPE, EXCHANGEDATE)
        VALUES
          (V_ID,
           CC.R030,
           CC.TXT,
           CC.RATE,
           CC.CUR,
           CC.CURR_TYPE,
           CC.EXCHANGEDATE);
	   
         -- 6. якщо сталася будь-яка помилка зафіксувати її у таблиці логов 
	
    EXCEPTION
      WHEN OTHERS THEN
        INSERT INTO UTIL.SYS_LOG 
          (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
        VALUES
          ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
           'LOAD_ACTION_CUR_FROM_FILE',
           'процедуру призупинено LOAD_ACTION_CUR_FROM_FILE сталася помилка',
           'BAD',
           SYSDATE);
    END;
     
    END LOOP;
    
      -- 7. зафіксувати завершення процедури у таблиці логов
	
    INSERT INTO UTIL.SYS_LOG
      (ID, APPL_PROC, MESSAGE, STATUS, LOG_DATE)
    VALUES
      ((SELECT NVL(MAX(ID), 0) + 1 FROM UTIL.SYS_LOG),
       'LOAD_ACTION_CUR_FROM_FILE',
       'Процедуру LOAD_ACTION_CUR_FROM_FILE завершено',
       'OK',
       SYSDATE);
       
    -- 8. зафіксувати DML операцію
    
    COMMIT;
  
  END LOAD_ACTION_CUR_FROM_FILE;

END APL_UTILS;
/
