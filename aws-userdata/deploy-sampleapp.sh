echo "> create deploy directory"
mkdir /home/ec2-user/deploy
cd /home/ec2-user/deploy

echo "> git clone"
git clone https://github.com/csbsjy/hello-spring.git
cd hello-spring

echo "> start gradle build"
./gradlew clean build

echo "> start deploy jar"
nohup java -jar build/libs/*.jar > /dev/null 2> /dev/null < /dev/null &



check_Keyword = "version"

for retry_count in {1..10}
do
  sleep 10
  response=$(curl -XGET http://localhost:8888/home)
  check_count=$(echo $response | grep ${check_keyword} | wc -l)

  if [ $check_count -ge 1 ]
  then # $check_count >= 1 (${check_keyword})
      echo "> Deployment Complete"
      echo "> Complet reponse: ${response}"
      break
  else
      echo "> Not yet"
      echo "> response ${response}"
  fi
  echo "> Retry ..."
done

