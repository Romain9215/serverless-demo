Romain.D
.romain.d
Invisible

boris9306 — Hier à 11:39
-------------------------------
6 - Trigger Action dans GitHub

.github/workflows/trigger-jenkins.yml

Attention à l'URL de votre serveur Jenkins et vous avez besoin de créer un Token dans Jenkins


name: Trigger Jenkins

on:
  push:
    branches: main

jobs:
  trigger-jenkins:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Jenkins build
        run: |
          curl -X POST http://ip10-0-8-5-cvmigib6221h46l2ts3g-8080.direct.lab-boris.fr/job/iac-pipeline/build --user "bstocker:11c916326397ff8cda153b6ab4a9c2ebe5" 


Ne pas oublier de se créer un Jeton dans Jenkins
boris9306 — Hier à 12:06
------------------------------
Observation :
A chaque Commit dans GitHub (c'est à dire une modification de votre code), Terraform (via Jenkins) cherchera à créer une instance EC2 sur LocalStack (ami-12345678).Toutefois, si l'instance existe déjà, Terraform ne fait rien (logique).
Visualisons cette instance EC2 avec AWS-CLI
Depuis une nouvelle Instance dans le laboratoire (+ADD NEW INSTANCE)
apk add aws-cli
aws configure
AWS Access Key ID [None]: test
AWS Secret Access Key [None]: test
Default region name [None]: us-east-1
Default output format [None]: json
//Commande AWS
aws --endpoint-url=http://ip10-0-5-4-d0dgq9g05akh4glkf8pg-4566.direct.lab-boris.fr \
    ec2 describe-instances \
    --query "Reservations[*].Instances[*].[InstanceId,ImageId]" \
    --output table

-------
Travail demandé : Faites une capture d'écran de la création de votre instance EC2 sur LocalStack via AWS_CLI
boris9306 — Hier à 12:36
Exercice : 
Modifier votre solution afin de provoquer la construction d'une nouvelle instance à chaque commit GitHub (avec un ImageID différent à chaque fois).
boris9306 — Hier à 14:14
------------------------------------------------------------------------------------------------------------
Séquence 2 : Automatisation des tests
------------------------------------------------------------------------------------------------------------
Scénario 1 : Automatisation des tests compilés 
Forker le repository suivant : https://github.com/OpenRSI/Atelier_CMAKE
Réaliser les exercices demandés
Travail demandé : Copier/coller l'URL de votre Repository GitHub dans le canal general-infra de ce Discord
boris9306 — Hier à 15:22
---------------------------------------------------
Scénario 2 : Automatiser ses tests d'API
Talend API Tester :
Talend API Tester (à l'instar de Postman ou https://hoppscotch.io/) est un module Chrome ou Edge permettant la scénarisation des tests API.
--------------------------------
Installation :

https://chromewebstore.google.com/detail/talend-api-tester-free-ed/aejoelaoggembcahagimdiliamlcdmfm

ou

https://help.talend.com/fr-FR/api-tester-user-guide/Cloud/installing-talend-cloud-api-tester-google-chrome-extension

Votre module est installé et accessible depuis votre navigateur (icone du puzzle en haut à droite).
--------------------------------
Présentation d'un catalogue d'API :
https://petstore.swagger.io/#/
Le serveur de production est :
https://petstore.swagger.io/v2/
boris9306 — Hier à 15:29
--------------------------------
Créer un projet avec un scénario (case à cocher lors de la création du projet).
Test GET : 
Add a request
Method GET https://petstore.swagger.io/v2/pet/10
Play -> Vert si tout est ok. L'API fonctionne bien
Test POST :
Exemple pour d'un POST pour vérifier la création d'un USER :

https://petstore.swagger.io/v2/user

Créez un test de type POST et mettre dans le body une structure sous cette forme
{
  "id": 2000,
  "username": "Momo",
  "firstName": "Michel",
  "lastName": "LECONVENANT",
  "email": "boris@gmail.com",
  "password": "123456",
  "phone": "0102030405",
  "userStatus": 0
}
------------------------------------
Exercice : Créer le scénario de tests suivant

1° - Créer un nouveau User
2° - Vérifier son existence dans la base (l'utilisateur a-t-il bien été créé ?)
3° - Vérifier que le login/password fonctionne bien pour ce nouveau utilisateur
4° - Supprimer ce nouvel utilisateur pour ne pas polluer la base de données

Exporter votre Scénario avec votre Nom Prénom (ex : STOCKER_Boris.json) et envoyez le par mail à l'adresse suivante : boris.stocker@gmail.com
boris9306 — Hier à 16:17
--------------------------------------------------------
Scénario 3 : Automatiser les tests WEB UX
Nous allons utiliser SELENIUM
//Se connecter au laboratoire numérique :
http://lab-boris.fr/
+ ADD NEW INSTANCE

----------------------
Astuce 1 : Passage en grand écran -> Alt+Enter

Astuce 2 : Coller du code dans le navigateur
 
Coller dans Chrome -> Ctrl+Shift+v
Coller dans Firefox ->  Shift+Insert
Coller dans EI et Safari -> Ctrl+v
-----------------------
#Installation du Contexte : Copier/Coller le code suivant dans l'instance Linux

apk update
apk upgrade
apk add python3 py3-pip
apk add firefox
apk add xvfb
apk add bash
apk add nano
apk add msttcorefonts-installer fontconfig
update-ms-fonts
fc-cache -f
pip install selenium --break-system-packages
wget https://github.com/mozilla/geckodriver/releases/download/v0.33.0/geckodriver-v0.33.0-linux64.tar.gz
tar -xvzf geckodriver-v0.33.0-linux64.tar.gz
mv geckodriver /usr/local/bin/
chmod +x /usr/local/bin/geckodriver
// Créez le fichier run_selenium.sh (Firefox pour Selenium)

nano run_selenium.sh
----------------
#!/bin/bash

# Démarrer Xvfb
Xvfb :99 -screen 0 1024x768x16 &
XVFB_PID=$!

# Définir la variable d'affichage
export DISPLAY=:99

# Définir un gestionnaire pour tuer Xvfb quand le script se termine ou est interrompu
cleanup() {
  kill $XVFB_PID
}
trap cleanup EXIT

# Exécuter le script Python
python3 test.py

# Tuer le processus Xvfb
kill $XVFB_PID

----------------
Ctrl+s
Ctrl+x
// On donne les bons droits à ce script
chmod +x run_selenium.sh
// Créez le fichier test.py
nano test.py
boris9306 — Hier à 16:24
---------------------------------
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.common.by import By

# Spécifiez le chemin vers l'exécutable geckodriver
service = Service(executable_path='/usr/local/bin/geckodriver')

# Initialisez les options Firefox
options = Options()
options.add_argument('--headless')  # Pour exécuter Firefox en mode headless

# Initialisez le pilote Firefox avec le service et les options
driver = webdriver.Firefox(service=service, options=options)

# Ouvrir le site Python
driver.get("https://www.python.org")

# Afficher le titre de la page
print(driver.title)

# Trouver l'élément de la barre de recherche par son attribut name
search_bar = driver.find_element(By.NAME, "q")

# Effacer la barre de recherche s'il y a du texte dedans
search_bar.clear()

# Entrer la requête de recherche dans la barre de recherche
search_bar.send_keys("getting started with python")

# Simuler la pression de la touche Entrée
search_bar.send_keys(Keys.RETURN)

# Afficher l'URL actuelle
print(driver.current_url)

# Fermer le navigateur
driver.close()

---------
Ctrl+s
Ctrl+x
// Exécutez le script de tests automatique
./run_selenium.sh
Si vous avez bien fait votre travail vous aurez à l'écran :
Welcome to Python.org
https://www.python.org/
-------------------------------------------------------------
Atelier 1 : Test de connexion réussit
Le site à tester : https://www.saucedemo.com/
Testez la connexion de l'utilisateur standard_user (pwd : secret_sauce)
Les étapes :
1° - Entrer un login
2° - Entrer le mot de passe
3° - Appuyer sur le bouton
4° - Vérifier l'URL qui doit contenir la chaine de caratère "inventory"
Deux possibilités : Connexion réussit ou non
boris9306 — Hier à 16:36
Travail demandé :  Capture d'écran de votre réussite
boris9306 — Hier à 16:50
Correction exercice :
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.common.by import By

# Spécifiez le chemin vers l'exécutable geckodriver
service = Service(executable_path='/usr/local/bin/geckodriver')

# Initialisez les options Firefox
options = Options()
options.add_argument('--headless')  # Pour exécuter Firefox en mode headless

# Initialisez le pilote Firefox avec le service et les options
driver = webdriver.Firefox(service=service, options=options)

# Ouvrir le site Python
driver.get("https://www.saucedemo.com/")

# Afficher le titre de la page
print(driver.title)

# Trouver l'élément login
login_val = driver.find_element(By.NAME, "user-name")

# Effacer le contenu s'il y a du texte dedans
login_val.clear()

# Entrer la requête de recherche dans la barre de recherche
login_val.send_keys("standard_user")

# Trouver l'élément Password
pwd_val = driver.find_element(By.NAME, "password")

# Effacer le contenu s'il y a du texte dedans
pwd_val.clear()

# Entrer la requête de recherche dans la barre de recherche
pwd_val.send_keys("secret_sauce")

# Trouver l'élément Password
envoie_val = driver.find_element(By.NAME, "login-button")

# Simuler la pression de la touche Entrée
envoie_val.send_keys(Keys.RETURN)

# Afficher l'URL actuelle
current_url = driver.current_url
print(current_url)

if "inventory" in current_url:
    print("Connexion réussie.")
else:
    print("Connexion échouée.")

# Fermer le navigateur
driver.close()
----------------
Exercice 2 : 
Faire un boucle pour tester tous les logins
boris9306 — Hier à 17:12
--------------------------------------------------------------------------------------------------------
Séquence 3 : La qualité du code (Sonarcube)
--------------------------------------------------------------------------------------------------------
Atelier SonarQube

La qualimétrie de votre code GitHUB avec SonarQub :
La prochaine étape est de sécuriser votre code à la source. C'est-à-dire, contrôler automatiquement la qualité de votre code depuis GitHUB via la solution SonarQub.
Le processus est le suivant (niveau de difficulté simple) :
Vous avez à votre disposition un serveur SonarQube pour analyser la qualité de votre code. Celui-ci est accessible via l'URL suivante :
http://ec2-13-37-232-203.eu-west-3.compute.amazonaws.com:9000/ Login : esieet et Pwd : tests2024 
Atelier :
Procéder à un audit du projet https://github.com/OpenRSI/Flask_Projet_SQLite
Faites un fork de ce projet puis retournez sur le serveur SonarQube et suivez les instructions suivantes :

Create Projet -> Manually -> Projet Display name = Votre nom -> Use the global setting -> With GitHub Actions -> et suivre les instructions SonarQub ...

Remarque : Votre projet est en Python.
Si vous besoin de savoir comment créer un secret dans GitHUb, voici une petite vidéo d'explication : https://www.youtube.com/watch?v=pi80zRdrJyQ
boris9306 — Hier à 17:28
Exercice 2 :
Trouver le mot de passe dans le projet suivant : https://github.com/minio/minio.git
Saurez vous trouver le mot de passe ?
-------------------------------------------------------------------------------------------------
Cadeaux du jour (magazines Programmez) :

Terraform (IaC) :
https://1drv.ms/b/s!AgvsSD-da1M_nMVg98TfvzgJdfj22A?e=51rl7j

GitHub :
https://1drv.ms/b/c/3f536b9d3f48ec0b/EUzhO5xm8u9Op2b7ggePLFkB5FwXwylrLw7W-Xq0CdHG-Q?e=4HEqbM

Python :
https://1drv.ms/b/s!AgvsSD-da1M_nK4AUvHNzx9H6AAEFw?e=zyuj14
boris9306 — 09:15
----------------------------------------------------------------------------------------------------
Séquence 4 : Architecture serverless : Création d'un site Web full serverless (AWS)
----------------------------------------------------------------------------------------------------
Notre processus pour cet atelier
Frontend (index.html)
        ↓
API Gateway (2 routes /hello et /contact) : https://www.youtube.com/watch?v=x6oPMfWG9RA
        ↓
Lambda handler (Python) : https://www.youtube.com/watch?v=JEv8_tMdgNk
        ↓
Enregistrement dans DynamoDB (LocalStack) : https://www.youtube.com/watch?v=CuHze8ix-_o
------
Arborescence de notre projet GitHub 

serverless-demo/
├── .github/
│   └── workflows/trigger-jenkins.yml
├── frontend/
│   └── index.html
├── lambda/
│   └── handler.py
├── terraform/
│   ├── main.tf
│   ├── outputs.tf
└── README.md
---
Etape 1 : Création du repository GitHub serverless-demo
--- 
Etape 2 : Installation de votre environnement AWS avec LocalStack
//Se connecter au laboratoire numérique :
http://lab-boris.fr/
+ ADD NEW INSTANCE

----------------------
Astuce 1 : Passage en grand écran -> Alt+Enter

Astuce 2 : Coller du code dans le navigateur
 
Coller dans Chrome -> Ctrl+Shift+v
Coller dans Firefox ->  Shift+Insert
Coller dans EI et Safari -> Ctrl+v
-----------------------
//Installation d'un éditeur de texte
//Copier/Coller cette commande
apk add nano
Ajout des services lambda, apigateway, dynamodb et iam dans docker-compose
nano docker-compose.yml
boris9306 — 09:22
version: "3.8"

services:
  localstack:
    container_name: localstack
    image: localstack/localstack
    ports:
      - "4566:4566"
      - "4571:4571"
    environment:
      - SERVICES=lambda,apigateway,dynamodb,iam
      - DEBUG=1
      - DOCKER_HOST=unix:///var/run/docker.sock
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock"
Ctrl+s
Ctrl+x
docker-compose up -d
Cliquez sur le bouton [OPEN PORT] -> 4566

Copier l'URL de votre instance qui sera votre environnement AWS (lambda,apigateway,dynamodb,).
boris9306 — 09:46
Etape 3 : Installation de Jenkins
+ADD NEW INSTANCE

mkdir $HOME/jenkins


docker volume create --opt type=none \
--opt device=$HOME/jenkins \
--opt o=bind \
jenkins-volume
docker run --name jenkins -d -p 8080:8080 -p 50000:50000  -v jenkins-volume:/var/jenkins_home -e JAVA_OPTS="-Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true"  jenkins/jenkins:lts
Etape 3.1  - Installation de Terraform sur le serveur Jenkins

docker exec -u root -it jenkins /bin/bash


apt update && apt install -y wget lsb-release docker.io


wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg


echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com bookworm main" > /etc/apt/sources.list.d/hashicorp.list

apt update

apt install terraform

terraform --version
boris9306 — 09:57
Toujours sur l'instance Jenkins/Terraform cliquez sur le  [OPEN PORT] -> 8080
Vous pouvez utiliser le bouton [EDITOR] pour copier votre clé qui se trouve dans le fichier suivant :
/root/Jenkins/secrets/initialAdminPassword
Installer les plugings sugérés et n'oubliez pas de conserver l'URL de votre API Jenkins
Profitez-en pour créer un token (on en aura besion pour la suite)
Etape 4 : Le trigger d'action Github .github/workflows/trigger-jenkins.yml
name: Trigger Jenkins

on:
  push:
    branches: main

jobs:
  trigger-jenkins:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger Jenkins build
        run: |
          curl -X POST http://ip10-0-6-6-cvhtafqb9qb14bivkpqg-8080.direct.lab-boris.fr/job/serverless-demo/build --user "bstocker:11d2d339af459a5f0d5909dadfbdad7af1" 
boris9306 — 10:07
Etape 5 : Le pipeline Jenkins intitulé serverless-demo

N'oubliez pas de modifier dans ce script l'url de votre Repository GitHub

pipeline {
  agent any

  stages {
    stage('Checkout') {
      steps {
        git branch: 'main', url: 'https://github.com/bstocker/serverless-demo.git'
      }
    }

    stage('Package Lambda') {
      steps {
        dir('lambda') {
          sh 'zip ../terraform/lambda.zip handler.py'
        }
      }
    }

    stage('Deploy with Terraform') {
      steps {
        dir('terraform') {
          sh 'terraform init'
          sh 'terraform apply -auto-approve'
        }
      }
    }
  }
}
Etape 6 - Le script Terraform dans Github  pour la création de l'environnement AWS (LocalStack)
Dans GitHub : terraform/main.tf
N'oubliez de modifier vos endpoints pour les faire pointer sur votre AWS (LocalStack)
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  token                       = ""
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    lambda     = "http://ip10-0-7-4-cvi159ib9qb14bivkpt0-4566.direct.lab-boris.fr"
    apigateway = "http://ip10-0-7-4-cvi159ib9qb14bivkpt0-4566.direct.lab-boris.fr"
    iam        = "http://ip10-0-7-4-cvi159ib9qb14bivkpt0-4566.direct.lab-boris.fr"
    dynamodb   = "http://ip10-0-7-4-cvi159ib9qb14bivkpt0-4566.direct.lab-boris.fr"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_function" "api" {
  function_name = "hello-api"
  handler       = "handler.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")
  timeout       = 15
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contacts.name
    }
  }
}

resource "aws_dynamodb_table" "contacts" {
  name         = "contacts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "hello-api"
  description = "API REST simulÃ©e"
}

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_resource" "contact" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "hello" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "contact" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.contact.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.hello.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

resource "aws_api_gateway_integration" "contact" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.contact.id
... (56lignes restantes)
Réduire
message.txt
5 Ko
Dans GitHub : terraform/outputs.tf

output "api_id" {
  value = aws_api_gateway_rest_api.api.id
}

output "lambda_env_table_name" {
  value = aws_dynamodb_table.contacts.name
}
﻿
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  token                       = ""
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    lambda     = "http://ip10-0-55-4-d34gvivtq0k1c7corn90-4566.direct.lab-boris.fr"
    apigateway = "http://ip10-0-55-4-d34gvivtq0k1c7corn90-4566.direct.lab-boris.fr"
    iam        = "http://ip10-0-55-4-d34gvivtq0k1c7corn90-4566.direct.lab-boris.fr"
    dynamodb   = "http://ip10-0-55-4-d34gvivtq0k1c7corn90-4566.direct.lab-boris.fr"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_function" "api" {
  function_name = "hello-api"
  handler       = "handler.handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_exec.arn
  filename      = "lambda.zip"
  source_code_hash = filebase64sha256("lambda.zip")
  timeout       = 15
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contacts.name
    }
  }
}

resource "aws_dynamodb_table" "contacts" {
  name         = "contacts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_api_gateway_rest_api" "api" {
  name        = "hello-api"
  description = "API REST simulÃ©e"
}

resource "aws_api_gateway_resource" "hello" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "hello"
}

resource "aws_api_gateway_resource" "contact" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "hello" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.hello.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "contact" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.contact.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.hello.id
  http_method             = aws_api_gateway_method.hello.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

resource "aws_api_gateway_integration" "contact" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.contact.id
  http_method             = aws_api_gateway_method.contact.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api.invoke_arn
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.hello.id,
      aws_api_gateway_resource.contact.id,
      aws_api_gateway_method.hello.id,
      aws_api_gateway_method.contact.id,
      aws_api_gateway_integration.hello.id,
      aws_api_gateway_integration.contact.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_integration.hello,
    aws_api_gateway_integration.contact
  ]
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "dev"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lambda_permission" "allow_apigw_hello" {
  statement_id  = "AllowExecutionFromAPIGatewayHello"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/hello"
}

resource "aws_lambda_permission" "allow_apigw_contact" {
  statement_id  = "AllowExecutionFromAPIGatewayContact"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/contact"
}
