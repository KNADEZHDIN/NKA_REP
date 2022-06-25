BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB(JOB_NAME            => 'NBU_LOAD_JOB',
                                JOB_TYPE            => 'PLSQL_BLOCK',
                                JOB_ACTION          => 'BEGIN 
                                                        UTIL.APL_UTILS.DOWNLOAD_CUR_EXCH_RATE();
                                                        UTIL.APL_UTILS.ACTION_CUR_EXCH_RATE();
                                                        UTIL.APL_UTILS.LOAD_ACTION_CUR_FROM_FILE();
                                                        END;',
                                START_DATE          => TO_DATE('26-06-2022 06:00:00', 'dd-mm-yyyy hh24:mi:ss'),
                                REPEAT_INTERVAL     => 'FREQ=DAILY; BYHOUR=6',
                                END_DATE            => TO_DATE(NULL),
                                JOB_CLASS           => 'DEFAULT_JOB_CLASS',
                                ENABLED             => TRUE,
                                AUTO_DROP           => TRUE,
                                COMMENTS            => 'запуск процедур кожен день о 6 ранку');
END;
/

SELECT * 
FROM ALL_SCHEDULER_JOBS T WHERE T.JOB_NAME = 'NBU_LOAD_JOB';

BEGIN

    DBMS_SCHEDULER.RUN_JOB(JOB_NAME => 'UTIL.NBU_LOAD_JOB', 

                           USE_CURRENT_SESSION => FALSE);

END;

/
