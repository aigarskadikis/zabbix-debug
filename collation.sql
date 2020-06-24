
DROP PROCEDURE IF EXISTS zbx_convert_utf8;

DELIMITER $$
CREATE PROCEDURE zbx_convert_utf8 (
)

BEGIN
	declare cmd varchar(255) default "";
	declare finished integer default 0;

	declare cur_command cursor for 
		SELECT command
		FROM
		    (/* This 'select' statement deals with 'text' type columns to prevent
		        their automatic conversion into 'mediumtext' type.
		        The goal is to produce statements like
		         ALTER TABLE zabbix.hosts MODIFY COLUMN description text CHARACTER SET utf8 COLLATE utf8_bin not null;
		     */
		     SELECT table_name AS sort1,
		                   'A' AS sort2,
		            CONCAT('ALTER TABLE ', table_schema, '.', table_name,
		                   ' MODIFY COLUMN ', column_name, ' ', column_type,
		                   ' CHARACTER SET utf8 COLLATE utf8_bin',
		                case
		                    when column_default is null then ''
		                    else concat(' default ', column_default, ' ')
		                end,
		                case
		                    when is_nullable = 'no' then ' not null '
		                    else ''
		                end,
		            ';') AS command
		        FROM information_schema.columns
		        WHERE table_schema = 'zabbix'        
		           AND column_type = 'text'
		    UNION
		     /* This 'select' statement deals with setting character set and collation for
		        each table and converting varchar fields on a per-table basis.
		        It is necessary to process all tables (even those with numeric-only columns)
		        otherwise in future Zabbix upgrades text (e.g. varchar) columns may be added
		        to these tables or numeric columns can be turned into text ones and
		        the old character set/collation can reappear again.
		        The goal is to produce statements like
		         ALTER TABLE zabbix.hosts CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin;
		     */
		     SELECT table_name AS sort1,
		                   'B' AS sort2,
		            CONCAT('ALTER TABLE ', table_schema, '.', table_name,
		                   ' CONVERT TO CHARACTER SET utf8 COLLATE utf8_bin;') AS command
		        FROM information_schema.tables
		        WHERE table_schema = 'zabbix') s
		/* Sorting is important: 'MODIFY COLUMN' statements should precede 'CONVERT TO' ones
		   for each table. */
		ORDER BY sort1, sort2;
	
	declare continue handler for not found set finished = 1;

	open cur_command;
	cmd_loop: loop
		fetch cur_command into cmd;
		if finished = 1 then
			leave cmd_loop;
		end if;
		PREPARE stmt FROM cmd;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	end loop cmd_loop;
	close cur_command;

END$$

DELIMITER ;

CALL zbx_convert_utf8();

DROP PROCEDURE zbx_convert_utf8;
