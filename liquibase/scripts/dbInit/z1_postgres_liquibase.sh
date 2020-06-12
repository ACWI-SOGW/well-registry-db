#!/bin/bash
set -e
set -o pipefail

# postgres to postgres db scripts
${LIQUIBASE_HOME}/liquibase \
	--classpath=${LIQUIBASE_HOME}/lib/${JDBC_JAR} \
	--changeLogFile=${LIQUIBASE_WORKSPACE}/postgres/postgres/changeLog.yml \
	--driver=org.postgresql.Driver \
	--url=jdbc:postgresql://${DATABASE_HOST}:5432/postgres \
	--username=postgres \
	--password=${POSTGRES_PASSWORD} \
	--logLevel=info\
	--liquibaseCatalogName=public \
	--liquibaseSchemaName=public \
	update \
	-DAPP_DATABASE_NAME=${APP_DATABASE_NAME} \
	-DAPP_DB_OWNER_USERNAME=${APP_DB_OWNER_USERNAME} \
	-DAPP_DB_OWNER_PASSWORD=${APP_DB_OWNER_PASSWORD} \
	-DAPP_SCHEMA_OWNER_USERNAME=${APP_SCHEMA_OWNER_USERNAME} \
	-DAPP_SCHEMA_OWNER_PASSWORD=${APP_SCHEMA_OWNER_PASSWORD}

# postgres to capture db scripts
${LIQUIBASE_HOME}/liquibase \
	--classpath=${LIQUIBASE_HOME}/lib/${JDBC_JAR} \
	--changeLogFile=${LIQUIBASE_WORKSPACE}/postgres/wellRegistry/changeLog.yml \
	--driver=org.postgresql.Driver \
	--url=jdbc:postgresql://${DATABASE_HOST}:5432/${APP_DATABASE_NAME} \
	--username=postgres \
	--password=${POSTGRES_PASSWORD} \
	--logLevel=info\
	--liquibaseCatalogName=public \
	--liquibaseSchemaName=public \
	update \
	-DAPP_SCHEMA_OWNER_USERNAME=${APP_SCHEMA_OWNER_USERNAME} \
	-DAPP_SCHEMA_NAME=${APP_SCHEMA_NAME}
