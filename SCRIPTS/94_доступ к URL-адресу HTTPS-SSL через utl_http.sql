--https://doyensys.com/blogs/how-to-access-https-ssl-url-via-utl-http-using-the-orapki-wallet-command/
--https://stackoverflow.com/questions/26697841/oracle-error-ora-28759-failure-to-open-file-when-requesting-utl-http-package

--orapki wallet create -wallet C:\oracle19_db_home\soddba\wallet\bank_gov -pwd Orasod437 -auto_login
--orapki wallet add -wallet C:\oracle19_db_home\soddba\wallet\bank_gov -trusted_cert -cert "C:\bank_gov1.crt" -pwd Orasod437
--orapki wallet add -wallet C:\oracle19_db_home\soddba\wallet\bank_gov -trusted_cert -cert "C:\bank_gov2.crt" -pwd Orasod437

orapki wallet create -wallet C:\oracle19_db_home\soddba\wallet -pwd Orasod437 -auto_login
orapki wallet add -wallet C:\oracle19_db_home\soddba\wallet -trusted_cert -cert "C:\db_cer1.cer" -pwd Orasod437
orapki wallet add -wallet C:\oracle19_db_home\soddba\wallet -trusted_cert -cert "C:\db_cer2.cer" -pwd Orasod437

SELECT * FROM DBA_NETWORK_ACLS;
SELECT * FROM DBA_NETWORK_ACL_PRIVILEGES;

create directory NBU_CURR as 'C:\odb19\DIR_FILES\curr';

SELECT * 
FROM NLS_DATABASE_PARAMETERS 
--WHERE parameter IN ('NLS_CHARACTERSET','NLS_NCHAR_CHARACTERSET')
;

SELECT grantee , table_name , privilege
from dba_tab_privs
where table_name = 'UTL_HTTP';

grant execute on utl_http to GSMADMIN_INTERNAL;

DECLARE
  L_ACL_NAME VARCHAR2(100) := 'sysdba-ch-permissions.xml';
BEGIN

  DBMS_NETWORK_ACL_ADMIN.CREATE_ACL(ACL => L_ACL_NAME,
                                    DESCRIPTION => 'Permissions for sysdba network',
                                    PRINCIPAL => 'GSMADMIN_INTERNAL',
                                    IS_GRANT => TRUE,
                                    PRIVILEGE => 'connect',
                                    START_DATE => SYSDATE,
                                    END_DATE => TO_DATE('31.12.2999', 'DD.MM.YYYY'));

  DBMS_NETWORK_ACL_ADMIN.ASSIGN_ACL(ACL => L_ACL_NAME,
                                    HOST => '*.sysdba.ch',
                                    LOWER_PORT => 80,
                                    UPPER_PORT => NULL);

/*DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(host => 'www.bank.gov.ua',
                                       ace  =>  xs$ace_type(privilege_list => xs$name_list('connect', 'resolve'),
                                       principal_name => 'GSMADMIN_INTERNAL',
                                       principal_type => xs_acl.ptype_db));*/

-- remove                                     
/*dbms_network_acl_admin.remove_host_ace(
  host => 'www.bank.gov.ua',
  ace  =>  xs$ace_type(privilege_list => xs$name_list('connect', 'resolve'),
                       principal_name => 'GSMADMIN_INTERNAL',
                       principal_type => xs_acl.ptype_db));*/

/*
 DBMS_NETWORK_ACL_ADMIN.APPEND_WALLET_ACE (wallet_path => 'file: C:\oracle19_db_home\soddba\wallet\bank_gov',
                                           ace         => xs$ace_type(privilege_list => xs$name_list('use_passwords', 'use_client_certificates'),
                                           principal_name => 'GSMADMIN_INTERNAL',
                                           principal_type => xs_acl.ptype_db));*/

-- remove     
/*
dbms_network_acl_admin.remove_wallet_ace(wallet_path    => 'file: C:\oracle19_db_home\soddba\wallet',
                                         ace            =>  xs$ace_type(privilege_list => xs$name_list('use_passwords'),
                                         principal_name => 'GSMADMIN_INTERNAL',
                                         principal_type => xs_acl.ptype_db));*/

  COMMIT;

END;
/

--------------------------------SET SERVEROUTPUT ON
--SET SERVEROUTPUT ON
DECLARE
  LO_REQ   UTL_HTTP.REQ;
  LO_RESP  UTL_HTTP.RESP;
  V_ANSWER VARCHAR2(1024);
BEGIN

  UTL_HTTP.SET_WALLET('file:C:\oracle19_db_home\soddba\wallet\bank_gov','Orasod437'); ----!!!!!!!!!!!!!!!!!!!!!! БЕЗ ПРОБЕЛОВ!!!!!
  --LO_REQ := UTL_HTTP.BEGIN_REQUEST('www.bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json');   
  LO_REQ := UTL_HTTP.BEGIN_REQUEST('www.bank.gov.ua/NBUStatService/v1/statdirectory/exchange?valcode=USD&date=20200302&json');
  UTL_HTTP.SET_HEADER(LO_REQ, 'User-Agent', 'Mozilla/4.0');
  UTL_HTTP.SET_BODY_CHARSET(LO_REQ, 'UTF8');

  LO_RESP := UTL_HTTP.GET_RESPONSE(LO_REQ);

  LOOP
    UTL_HTTP.READ_LINE(LO_RESP, V_ANSWER, TRUE);
    V_ANSWER := CONVERT(V_ANSWER, 'AL32UTF8', 'UTF8');
    DBMS_OUTPUT.PUT_LINE(V_ANSWER);
  END LOOP;

  --DBMS_OUTPUT.PUT_LINE(LO_RESP.STATUS_CODE);

  UTL_HTTP.END_RESPONSE(LO_RESP);

EXCEPTION
  WHEN UTL_HTTP.END_OF_BODY THEN
    UTL_HTTP.END_RESPONSE(LO_RESP);
  
END;
/
------------------------------
--SET SERVEROUTPUT ON
DECLARE
  LO_REQ  UTL_HTTP.REQ;
  LO_RESP UTL_HTTP.RESP;
BEGIN

UTL_HTTP.SET_BODY_CHARSET('UTF-8');

UTL_HTTP.SET_WALLET('file:C:\oracle19_db_home\soddba\wallet\bank_gov','Orasod437'); ----!!!!!!!!!!!!!!!!!!!!!! Без пробелов!!!!!

--LO_REQ := UTL_HTTP.BEGIN_REQUEST('www.google.com'); 

--lo_req := UTL_HTTP.begin_request('www.bank.gov.ua');-- https://

lo_req := UTL_HTTP.begin_request('www.bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json'); 

LO_RESP := UTL_HTTP.GET_RESPONSE(LO_REQ);

DBMS_OUTPUT.PUT_LINE(LO_RESP.STATUS_CODE);

UTL_HTTP.END_RESPONSE(LO_RESP);

END;
/

select utl_http.request('https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?json',
                        null,
                        'file:C:\oracle19_db_home\soddba\wallet\bank_gov','Orasod437') as v_json
from dual;

--------------------------


BEGIN
  -- Если вы хотите предоставить несколько пользователей, вы должны использовать процедуру DBMS_NETWORK_ACL.ADD_PRIVILEGE для добавления пользователей.
  DBMS_NETWORK_ACL_ADMIN.ADD_PRIVILEGE(ACL => 'sysdba-ch-permissions.xml',
                                       PRINCIPAL => 'GSMADMIN_INTERNAL', 
                                       IS_GRANT => TRUE,
                                       PRIVILEGE => 'resolve',
                                       START_DATE => SYSDATE,
                                       END_DATE => TO_DATE('31.12.2999', 'DD.MM.YYYY'));
END;
/
									   

BEGIN
  DBMS_NETWORK_ACL_ADMIN.DROP_ACL(ACL => 'sysdba-ch-permissions.xml');
END;
/								   