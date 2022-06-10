DELIMITER $$
CREATE PROCEDURE `partition_maintenance_all`(SCHEMA_NAME VARCHAR(32))
BEGIN
    CALL partition_maintenance(SCHEMA_NAME, 'history', 180, 168, 26);
    CALL partition_maintenance(SCHEMA_NAME, 'history_log', 180, 168, 26);
    CALL partition_maintenance(SCHEMA_NAME, 'history_str', 180, 168, 26);
    CALL partition_maintenance(SCHEMA_NAME, 'history_text', 180, 168, 26);
    CALL partition_maintenance(SCHEMA_NAME, 'history_uint', 180, 168, 26);
    CALL partition_maintenance(SCHEMA_NAME, 'trends', 360, 168, 52);
    CALL partition_maintenance(SCHEMA_NAME, 'trends_uint', 360, 168, 52);
END$$
DELIMITER ;
