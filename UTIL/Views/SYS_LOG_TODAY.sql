create or replace  view UTIL.SYS_LOG_TODAY as 
select sl.id,
       sl.appl_proc,
       sl.message,
       sl.status,
       sl.log_date
from util.sys_log sl;   

select *
from UTIL.SYS_LOG_TODAY slg
where slg.LOG_DATE = trunc(sysdate,'dd');
  
