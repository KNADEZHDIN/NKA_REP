CREATE TABLE servers2 AS
SELECT *
FROM servers
WHERE 1=2;
 
DECLARE
 CURSOR s_cur IS
 SELECT *
 FROM servers;
--FORALL Insert
 TYPE fetch_array IS TABLE OF s_cur%ROWTYPE;
 s_array fetch_array;
BEGIN
  OPEN s_cur;
  LOOP
    FETCH s_cur BULK COLLECT INTO s_array LIMIT 1000;
 
    FORALL i IN 1..s_array.COUNT
    INSERT INTO servers2 VALUES s_array(i);
 
    EXIT WHEN s_cur%NOTFOUND;
  END LOOP;
  CLOSE s_cur;
  COMMIT;
END;
/
 
--FORALL Update      
SELECT DISTINCT srvr_id
FROM servers2
ORDER BY 1;
 
DECLARE
 TYPE myarray IS TABLE OF servers2.srvr_id%TYPE
 INDEX BY BINARY_INTEGER;
 
 d_array myarray;
BEGIN
  d_array(1) := 608;
  d_array(2) := 610;
  d_array(3) := 612;
 
  FORALL i IN d_array.FIRST .. d_array.LAST
  UPDATE servers2
  SET srvr_id = 0
  WHERE srvr_id = d_array(i);
 
  COMMIT;
END;
/
 
SELECT srvr_id
FROM servers2
WHERE srvr_id = 0;
 
--FORALL Delete       
SET serveroutput ON
 
DECLARE
 TYPE myarray IS TABLE OF servers2.srvr_id%TYPE
 INDEX BY BINARY_INTEGER;
 
 d_array myarray;
BEGIN
  d_array(1) := 614;
  d_array(2) := 615;
  d_array(3) := 616;
 
  FORALL i IN d_array.FIRST .. d_array.LAST
  DELETE servers2
  WHERE srvr_id = d_array(i);
 
  COMMIT;
 
  FOR i IN d_array.FIRST .. d_array.LAST LOOP
    DBMS_OUTPUT.put_line('Iteration #' || i || ' deleted ' ||
    SQL%BULK_ROWCOUNT(i) || ' rows.');
  END LOOP;
END;
/
 
SELECT srvr_id
FROM servers2
WHERE srvr_id IN (614, 615, 616);