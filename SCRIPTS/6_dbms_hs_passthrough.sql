http://www.dba-oracle.com/t_packages_dbms_hs_passthrough.htm

Oracle Streams is a powerful tool which can be configured in a heterogeneous environment; for example, with a replication between an Oracle Database and a SQL Server database. This package provides the functionality to send a command directly to a non-Oracle database.

Several SQL commands can be navigated across non-Oracle databases:  create table, alter table, select, update, delete and many others. It is also possible to use bind variables within these commands as will be shown in the following examples. 

We are creating a Streams replication environment with an Oracle source database and the destination is an SQL Server database. we want to create the table that will be replicated on the SQL Server to begin configuring my Streams replication. This example will show one of the main procedures of dbms_hs_passthrough  (execute_immediate) used to run any non query SQL in the non-Oracle database immediately.

In this example, we create a table in an SQL Server database by using a database link named sqlserverdb configured with a transparent gateway.

declare
ret integer;
begin
ret := dbms_hs_passthrough.execute_immediate@sqlserverdb(
'create table str_dest.test_table
(id_inst                      int NOT NULL,
id_role_inst          char(2) NOT NULL,
id_direct_status            tinyint,
flg_generate_title   numeric(1))');
end;
/
commit;

--Add primary key on a table on a non-oracle database
declare
ret integer;
begin
ret := dbms_hs_passthrough.execute_immediate@sqlserverdb(
'alter table str_dest.test_table
add constraint tit_cont_tit_ser_plan_dt_mod_1
primary key nonclustered(
id_inst)');
end;
/

In the second example, we will execute a query using bind variables that are specified by the bind_variable procedure  of the dbms_hs_passthrough package. This is one of many procedures available to deal with bind variables when using this package. 

--Using bind variables in a query
declare 
v_cursor binary_integer; 
v_ret binary_integer; 
v_id integer; 
v_first_name varchar2(30); 
v_last_name varchar2(30); 
v_bind_id integer; 
v_bind_first_name varchar2(30); 
begin 
     v_cursor:=dbms_hs_passthrough.open_cursor@sqlserver; 
     dbms_hs_passthrough.parse@sqlserver(v_cursor,'select id, first_name, last_name from test_table where id = - and first_name = ?'); 
     v_bind_id := 10 
     v_bind_first_name := 'paulo'
     dbms_hs_passthrough.bind_variable@sqlserver(v_cursor,1,v_bind_id); 
     dbms_hs_passthrough.bind_variable@sqlserver(v_cursor,2,v_bind_first_name);
     begin 
        v_ret:=0; 
        while (true) 
        loop 
            v_ret:=dbms_hs_passthrough.fetch_row@sqlserver(v_cursor,false); 
            dbms_hs_passthrough.get_value@sqlserver(v_cursor,1,v_id); 
            dbms_hs_passthrough.get_value@sqlserver (v_cursor,2,v_first_name); 
            dbms_hs_passthrough.get_value@sqlserver (v_cursor,3,v_last_name);

dbms_output.put_line('First Name '||v_first_name);

dbms_output.put_line(Last Name '||v_last_name); 
       end loop; 
       exception 
       when no_data_found then 
       begin 
           dbms_output.put_line('no more rows found!'); 
           dbms_hs_passthrough.close_cursor@sqlserver(v_cursor); 
       end; 
     end; 
end; 
/


'Note that when querying data from a non-Oracle database, the execute_immediate procedure cannot be used; instead, use procedures to open and fetch a cursor in order to get a query value.