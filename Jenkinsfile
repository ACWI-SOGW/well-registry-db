pipeline {
  agent {
    node {
      label 'team:iow'
    }
  }
  stages {
    stage('Set Build Description') {
      steps {
        script {
          currentBuild.description = "Deploy to ${env.DEPLOY_STAGE}"
        }
      }
    }
    stage('Clean Workspace') {
      steps {
        cleanWs()
      }
    }
    stage('Git Clone') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/master']],
        doGenerateSubmoduleConfigurations: false,
        userRemoteConfigs: [[credentialsId: 'CIDA-Jenkins-GitHub',
        url: 'https://github.com/ACWI-SOGW/well-registry-db.git']]])
      }
    }
    stage('Download liquibase jar') {
      steps {
        sh '''mkdir $WORKSPACE/rc
          /usr/local/bin/aws s3 cp s3://owi-common-resources/resources/InstallFiles/liquibase/liquibase-$LIQUIBASE_VERSION.tar.gz $WORKSPACE/rc/liquibase.tar.gz
          /usr/bin/tar xzf $WORKSPACE/rc/liquibase.tar.gz --overwrite -C $WORKSPACE/rc
          /usr/local/bin/aws s3 cp s3://owi-common-resources/resources/InstallFiles/postgres/$JDBC_JAR $WORKSPACE/rc/lib/$JDBC_JAR
        '''
      }
    }
    stage('Run liquibase') {
      steps {
        script {
          def secretsString = sh(script: '/usr/local/bin/aws ssm get-parameter --name "/aws/reference/secretsmanager/MON-LOC-$DEPLOY_STAGE" --query "Parameter.Value" --with-decryption --output text --region "us-west-2"', returnStdout: true).trim()
          def secretsJson =  readJSON text: secretsString
          env.DATABASE_HOST = secretsJson.DATABASE_HOST
          env.APP_DATABASE_NAME = secretsJson.DATABASE_NAME
          env.APP_DB_OWNER_USERNAME = secretsJson.DB_OWNER_USERNAME
          env.APP_DB_OWNER_PASSWORD = secretsJson.DB_OWNER_PASSWORD
          env.APP_SCHEMA_NAME = secretsJson.SCHEMA_NAME
          env.APP_SCHEMA_OWNER_USERNAME = secretsJson.SCHEMA_OWNER_USERNAME
          env.APP_SCHEMA_OWNER_PASSWORD = secretsJson.SCHEMA_OWNER_PASSWORD

          sh '''
            export POSTGRES_PASSWORD=$(/usr/local/bin/aws ssm get-parameter --name "/MON-LOC-TEST_SU_PW" --query "Parameter.Value"  --with-decryption --output text --region "us-west-2")

            export LIQUIBASE_HOME=$WORKSPACE/rc
            export LIQUIBASE_WORKSPACE=$WORKSPACE/liquibase/changeLogs

            chmod +x $WORKSPACE/liquibase/scripts/dbInit/z1_postgres_liquibase.sh
            $WORKSPACE/liquibase/scripts/dbInit/z1_postgres_liquibase.sh
          '''
        }
      }
    }
  }
}
