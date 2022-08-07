create or replace type p_type as object (
    v_name varchar(400),
    d_date date,
    i_val number 
);

create or replace type p_table as table of p_type;

create or replace function get_info return p_table pipelined 
is
    c number;
begin
    --c := 1;
    for i in ( SELECT NAME, CONTRACT_DATE, ASSC_ID FROM bis.associations ass where ass.assc_id in (318,319,320) ) loop
        pipe row( p_type(
                    v_name => i.NAME,
                    d_date => i.CONTRACT_DATE,
                    i_val  => i.ASSC_ID
            ) );
        --c := c + 1;
    end loop;
    return;
end;


CREATE VIEW vw_info AS 
    select * from table(get_info);