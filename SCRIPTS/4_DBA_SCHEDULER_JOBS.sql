SELECT * FROM DBA_SCHEDULER_JOBS WHERE LOWER(JOB_NAME) LIKE '%gis%';


BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB(JOB_NAME            => 'FCS.SyncAdressNatec',
                                JOB_TYPE            => 'PLSQL_BLOCK',
                                JOB_ACTION          => 'BEGIN FCS.SYNC_ADDRESS_CHANGE; END;',
                                START_DATE          => TO_DATE('14-08-2019 13:03:20', 'dd-mm-yyyy hh24:mi:ss'),
                                REPEAT_INTERVAL     => 'Freq=daily;ByHour=0;ByMinute=30;BySecond=0',
                                END_DATE            => TO_DATE(NULL),
                                JOB_CLASS           => 'DEFAULT_JOB_CLASS',
                                ENABLED             => TRUE,
                                AUTO_DROP           => FALSE,
                                COMMENTS            => 'Daily FCS SYNC change Adress - ks_synch2gis_pg');
END;
/