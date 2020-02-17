def gitUrl = "git@github.com:csbsjy/hello-spring.git"

pipeline {

    agent any  

    stages {
        stage('Check Branch'){
           steps{
               sh ''' 
                if [ $ref != "refs/heads/master" ]
                    then echo "master branch 가 아닙니다!"
                    exit 1
                fi
               '''
           }
        }
        
        stage('Build') {           
            steps {
                git branch: "master", url: "${gitUrl}", credentialsId: "jenkins-server"
                sh "./gradlew clean build"
            }
        }        
        
        stage('Push RevisionFile ') {
            steps {  
               sh("""\
                aws deploy push \
                --application-name 'professor-lol'\
                --description 'professor-lol revision file'\
                --ignore-hidden-files \
                --s3-location 's3://professor-lol-revision-file/deploy.zip'\
                --source ./deploy \
                --region 'ap-northeast-2'
                """
               )
               
            }
        }
        
        stage('Call CodeDeploy'){
            steps{
                sh '''
                rm -rf deploy/libs 
                mv build/libs/ deploy/
                aws deploy create-deployment \
                --application-name "professor-lol" \
                --s3-location bucket="professor-lol-revision-file",key=deploy.zip,bundleType=zip \
                --deployment-group-name "jenkins-test" \
                --description "create deployment" \
                --region "ap-northeast-2"
                '''
            }
        }

  

    }

}

