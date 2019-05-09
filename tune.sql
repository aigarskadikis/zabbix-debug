
/* https://dba.stackexchange.com/questions/27328/how-large-should-be-mysql-innodb-buffer-pool-size */

SELECT CEILING(Total_InnoDB_Bytes*1.6/POWER(1024,3)) RIBPS FROM
(SELECT SUM(data_length+index_length) Total_InnoDB_Bytes
FROM information_schema.tables WHERE engine='InnoDB') A;