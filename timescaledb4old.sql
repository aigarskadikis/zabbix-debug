SELECT create_hypertable('history_old', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('history_uint_old', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('history_log_old', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('history_text_old', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('history_str_old', 'clock', chunk_time_interval => 86400, migrate_data => true);
SELECT create_hypertable('trends_old', 'clock', chunk_time_interval => 2592000, migrate_data => true);
SELECT create_hypertable('trends_uint_old', 'clock', chunk_time_interval => 2592000, migrate_data => true);
UPDATE config SET db_extension='timescaledb',hk_history_global=1,hk_trends_global=1;
UPDATE config SET compression_status=1,compress_older='7d';
