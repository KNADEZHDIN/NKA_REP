CREATE VIEW CUR_EXCH_RATE_V AS
SELECT
  TT.R030,
  TT.TXT,
  TT.RATE,
  TT.CUR,
  CC.CURR_TYPE,
  TO_DATE(TT.EXCHANGEDATE, 'dd.mm.yyyy') AS EXCHANGEDATE
FROM UTIL.CUR_EXCH_RATE CC, JSON_TABLE
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
) TT
;

SELECT * 
FROM UTIL.CUR_EXCH_RATE_V;
