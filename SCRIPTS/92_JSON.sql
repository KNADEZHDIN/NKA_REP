SELECT
  TT.R030,
  TT.TXT,
  TT.RATE,
  TT.CUR,
  TO_DATE(TT.EXCHANGEDATE, 'dd.mm.yyyy') AS EXCHANGEDATE
FROM 
(SELECT '[
          {
            "r030": 36,
            "txt": "Австралійський долар",
            "rate": 20.6232,
            "cc": "AUD",
            "exchangedate": "26.05.2022"
          },
          {
            "r030": 124,
            "txt": "Канадський долар",
            "rate": 22.732,
            "cc": "CAD",
            "exchangedate": "26.05.2022"
          },
          {
            "r030": 156,
            "txt": "Юань Женьміньбі",
            "rate": 4.3701,
            "cc": "CNY",
            "exchangedate": "26.05.2022"
          }
        ]' AS C1 
FROM DUAL)
CROSS JOIN JSON_TABLE
                    (
                        C1, '$[*]'
                          COLUMNS 
                          (
                            R030           NUMBER        PATH '$.r030',
                            TXT            VARCHAR2(100) PATH '$.txt',
                            RATE           NUMBER        PATH '$.rate',
                            CUR            VARCHAR2(100) PATH '$.cc',
                            EXCHANGEDATE   VARCHAR2(100) PATH '$.exchangedate'
                          )
                    ) TT;
-----------------------------------------------------------
SELECT
  TT.R030,
  TT.TXT,
  TT.RATE,
  TT.CUR,
  TO_DATE(TT.EXCHANGEDATE, 'dd.mm.yyyy') AS EXCHANGEDATE
FROM TTT, JSON_TABLE
(
    C1, '$[*]'
      COLUMNS 
      (
        R030           NUMBER        PATH '$.r030',
        TXT            VARCHAR2(100) PATH '$.txt',
        RATE           NUMBER        PATH '$.rate',
        CUR            VARCHAR2(100) PATH '$.cc',
        EXCHANGEDATE   VARCHAR2(100) PATH '$.exchangedate'
      )
) TT;
-----------------------------------------------------------

SELECT JSON_ARRAYAGG (  
    JSON_OBJECT (*) RETURNING CLOB   
) AS JSON_DOC  
FROM TAB;

SELECT JSON_OBJECT('ID' IS EMPLOYEE_ID , 'FirstName' IS FIRST_NAME,'LastName' IS LAST_NAME) ||',' AS JSON_VIEW
FROM HR.EMPLOYEES
WHERE EMPLOYEE_ID < 103;


SELECT JSON_OBJECT(*)||',' AS JSON_VIEW
FROM HR.EMPLOYEES
WHERE EMPLOYEE_ID < 105;

-----------------------------------------------------------

select json_value(c1, '$[0].r030')         as r030,
       json_value(c1, '$[0].txt')          as txt,
       json_value(c1, '$[0].rate')         as rate,
       json_value(c1, '$[0].cc')           as cc,
       json_value(c1, '$[0].exchangedate') as exchangedate
from  
(
select 
'
[
  {
    "r030": 36,
    "txt": "Австралійський долар",
    "rate": 20.6232,
    "cc": "AUD",
    "exchangedate": "26.05.2022"
  },
  {
    "r030": 124,
    "txt": "Канадський долар",
    "rate": 22.732,
    "cc": "CAD",
    "exchangedate": "26.05.2022"
  },
  {
    "r030": 156,
    "txt": "Юань Женьміньбі",
    "rate": 4.3701,
    "cc": "CNY",
    "exchangedate": "26.05.2022"
  }
]
' as c1
from dual
) t;

-----------------------------------------------------------
SELECT  --JS, 
        CC, RR

        --json_value(JS, '$[0].r030')         as r030
       --,json_value(JS, '$[0].txt')          as txt
       --,json_value(JS, '$[0].rate')         as rate
       --,json_value(JS, '$[0].cc')           as cc
       --,json_value(JS, '$[0].exchangedate') as exchangedate

       --,t.JS.r030

FROM (
SELECT JS, CC, ROWNUM-1 AS RR
FROM (
SELECT  JS 
       ,REGEXP_COUNT(JS,'},')+1 AS CC
FROM (
SELECT 
CAST('[
  {
    "r030": 36,
    "txt": "Австралійський долар",
    "rate": 20.6232,
    "cc": "AUD",
    "exchangedate": "26.05.2022"
  },
  {
    "r030": 124,
    "txt": "Канадський долар",
    "rate": 22.732,
    "cc": "CAD",
    "exchangedate": "26.05.2022"
  },
  {
    "r030": 156,
    "txt": "Юань Женьміньбі",
    "rate": 4.3701,
    "cc": "CNY",
    "exchangedate": "26.05.2022"
  }
]' AS varchar2(1000)) JS
FROM DUAL))
CONNECT BY level <= CC) t;

-----------------------------------------------------------

create table t
(
  c1 varchar2(100) check ( c1 is json )
);

insert into t values 
(
'
{ 
  "relist":[{"name":"XYZ","action":["Manager","Specific User List"],"flag":false}] 
}
' 
);
commit;

select --t.c1.relist.name as v1,
       --t.c1.relist.action[0] as v2,
       --t.c1.relist.action[1] as v3--,

       json_value(c1, '$.relist.name') as v1,
       json_value(c1, '$.relist.action[0]') as v2,
       json_value(c1, '$.relist.action[1]') as v3
from   t;


select json_query (
c1, '$.relist.action'
) arr
from t t; 


select j.* from t, json_table (
  c1, '$.relist.action[*]'
  columns ( 
    v path '$'
  ) 
) j;


