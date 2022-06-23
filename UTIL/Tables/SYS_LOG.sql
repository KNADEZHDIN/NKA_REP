CREATE TABLE UTIL.SYS_LOG
(
ID NUMBER NOT NULL ENABLE,
APPL_PROC VARCHAR2(50) NOT NULL ENABLE,
MESSAGE VARCHAR2(2000),
STATUS VARCHAR2(10),
CHECK (STATUS IN ('OK','WARNING','BAD')),
LOG_DATE DATE DEFAULT SYSDATE
)
;

COMMENT ON COLUMN UTIL.SYS_LOG.ID IS 'Первинний ключ таблиці SYS_LOG.';
COMMENT ON COLUMN UTIL.SYS_LOG.APPL_PROC IS 'Назва процедури програми.';
COMMENT ON COLUMN UTIL.SYS_LOG.MESSAGE IS 'Повідомлення програми про перебіг/результат процедури.';
COMMENT ON COLUMN UTIL.SYS_LOG.STATUS IS 'Статус процедури. Значення статусу процедури має бути "OK", "WARNING" або "BAD" ';
COMMENT ON COLUMN UTIL.SYS_LOG.LOG_DATE IS 'Дата події. Системна дата за замовчуванням. Ненулевий стовпець.';
