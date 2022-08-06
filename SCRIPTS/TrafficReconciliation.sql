DECLARE 
d NUMBER:=1;
BEGIN

      d:=1; -- количество секунд
      FOR c IN 1..8 loop
        FOR cc IN ( SELECT t.rowid rid, t.DATE_BILL dt, t.NUM_B, round(t.DUR_SEC) DUR_SEC 
					FROM A_UKRTEL_OUT t 
					WHERE out01 IS NULL ) loop
          FOR ci IN ( SELECT t.rowid rid, t.* 
                       FROM A_OPER_IN t 
                       WHERE out01 IS NULL
                       AND NUM_B=cc.NUM_B
		       --AND RPAD(Num_B, LENGTH(Num_B) - 3)=RPAD(cc.Num_B, LENGTH(cc.Num_B) - 3)
                       AND ( DATE_BILL BETWEEN cc.dt-d/86400 AND cc.dt+d/86400 )
                       AND round(DUR_SEC) BETWEEN cc.DUR_SEC-d AND cc.DUR_SEC+d
                    ORDER BY abs(86400*(DATE_BILL-cc.dt))
            ) loop
            UPDATE A_UKRTEL_OUT SET OUT01=d, OUT02=ci.rid WHERE rowid=cc.rid;
            UPDATE A_OPER_IN SET OUT01=d, OUT02=cc.rid WHERE rowid=ci.rid;
            commit;
            exit;
          END loop;
        END loop;
        d:=d*2;
      END loop;

END;
