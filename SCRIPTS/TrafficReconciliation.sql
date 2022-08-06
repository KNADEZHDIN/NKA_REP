DECLARE
  D NUMBER := 1;
BEGIN

  D := 1; -- количество секунд
  FOR C IN 1 .. 8 LOOP
    FOR CC IN (SELECT T.ROWID RID, T.DATE_BILL DT, T.NUM_B, ROUND(T.DUR_SEC) DUR_SEC FROM A_UKRTEL_OUT T WHERE OUT01 IS NULL) LOOP
      FOR CI IN (SELECT T.ROWID RID, T.*
                   FROM A_OPER_IN T
                  WHERE OUT01 IS NULL
                    AND NUM_B = CC.NUM_B
                     --AND RPAD(Num_B, LENGTH(Num_B) - 3)=RPAD(cc.Num_B, LENGTH(cc.Num_B) - 3)
                    AND (DATE_BILL BETWEEN CC.DT - D / 86400 AND CC.DT + D / 86400)
                    AND ROUND(DUR_SEC) BETWEEN CC.DUR_SEC - D AND CC.DUR_SEC + D
                  ORDER BY ABS(86400 * (DATE_BILL - CC.DT))) LOOP
        UPDATE A_UKRTEL_OUT
           SET OUT01 = D,
               OUT02 = CI.RID
         WHERE ROWID = CC.RID;
        UPDATE A_OPER_IN
           SET OUT01 = D,
               OUT02 = CC.RID
         WHERE ROWID = CI.RID;
        COMMIT;
        EXIT;
      END LOOP;
    END LOOP;
    D := D * 2;
  END LOOP;

END;
