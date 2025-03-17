```
git init .
django-admin startproject <project name> . --template ../app-base/ -e yml -e sh -n .env.example -n Dockerfile
cp docker/.env.example docker/.env
# edit docker/.env to taste
./dup.sh
./ddj.sh test project_test
```
