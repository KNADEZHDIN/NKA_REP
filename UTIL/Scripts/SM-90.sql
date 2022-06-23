CREATE INDEX sys_idx ON util.sys_log (LOG_DATE) GLOBAL;

CREATE INDEX cur_hist_idx ON util.cur_exch_rate_history (CURR_CODE) GLOBAL;

CREATE INDEX CUR_HIST_DATE_IDX ON util.cur_exch_rate_history (EXCHANGEDATE) GLOBAL;
