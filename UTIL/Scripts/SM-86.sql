ALTER TABLE util.sys_log
ADD CONSTRAINT sys_id_pk PRIMARY KEY (ID);

ALTER TABLE util.cur_exch_rate_history
ADD CONSTRAINT cur_hist_id_pk PRIMARY KEY (ID);

ALTER TABLE util.cur_exch_rate
ADD CONSTRAINT cur_exch_id_pk PRIMARY KEY (ID);
