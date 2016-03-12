
${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgcentral.* TO browser@'%' IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, ALTER, CREATE TEMPORARY TABLES on hgfixed.* TO browser@'%' IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT FILE on *.* TO browser@'%' IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT,FILE on *.* TO readonly@'%' IDENTIFIED BY 'access';" mysql
${MYSQL} -e "GRANT SELECT on mysql.* TO browser@'%' IDENTIFIED BY 'genome';" mysql
${MYSQL} -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER on hgcentral.* TO readwrite@'%' IDENTIFIED BY 'update';" mysql
${MYSQL} -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on customTrash.* TO readwrite@'%' IDENTIFIED by 'update';" mysql
${MYSQL} -e "FLUSH PRIVILEGES;"
