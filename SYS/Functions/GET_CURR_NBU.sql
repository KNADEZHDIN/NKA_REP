CREATE OR REPLACE NONEDITIONABLE FUNCTION SYS.GET_CURR_NBU(P_VALCODE IN VARCHAR2 DEFAULT 'USD',
                                                       P_DATE    IN DATE DEFAULT SYSDATE)
  RETURN VARCHAR2 IS
  V_JSON VARCHAR2(1000);
  V_DATE VARCHAR2(15) := TO_CHAR(P_DATE, 'YYYYMMDD');
BEGIN

  SELECT (UTL_HTTP.REQUEST('https://bank.gov.ua/NBUStatService/v1/statdirectory/exchange?valcode=' ||
                           P_VALCODE || '&date=' || V_DATE || '&json',
                           NULL,
                           'file:C:\oracle19_db_home\soddba\wallet\bank_gov',
                           'Orasod437'))
    INTO V_JSON
    FROM DUAL;

  IF V_JSON LIKE '%unsuccessful%' THEN
    RETURN 'Request unsuccessful';
  ELSE
    RETURN V_JSON;
  END IF;

  RETURN V_JSON;

END GET_CURR_NBU;
/
