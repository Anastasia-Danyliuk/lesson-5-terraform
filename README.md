##  Структура проєкту
```text
lesson-7/
│
├── main.tf                  # Головний файл для підключення модулів інфраструктури
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB)
├── outputs.tf               # Загальні виводи ресурсів
│
├── modules/                 # Каталог з інфраструктурними модулями Terraform
│   ├── s3-backend/          # Модуль для S3 бакета та DynamoDB (State Lock)
│   ├── vpc/                 # Модуль для мережі (VPC, підмережі, маршрутизація, NAT)
│   ├── ecr/                 # Модуль для Amazon Elastic Container Registry
│   └── eks/                 # Модуль для Amazon EKS (Kubernetes кластер)
│
└── charts/                  # Каталог для Helm-чартів
    └── django-app/          # Helm-чарт для нашого застосунку
        ├── templates/       # Маніфести Kubernetes
        │   ├── deployment.yaml
        │   ├── service.yaml
        │   ├── configmap.yaml
        │   └── hpa.yaml
        ├── Chart.yaml       # Метадані чарту
        └── values.yaml      # Конфігураційні параметри чарту
```
## Інструкція з розгортання та запуску команд
Ініціалізація проєкту, перевірка плану та створення всіх ресурсів в AWS (VPC, ECR, EKS):

```bash
terraform init
terraform plan
terraform apply -auto-approve
```
Авторизація в AWS ECR та робота з Docker
Отримання свіжого токена авторизації та логін у Docker-демон прямо через консоль:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 228266398439.dkr.ecr.us-east-1.amazonaws.com
```
Збірка локального Docker-образу (використано полегшений Nginx-сервер як вебзаглушку додатка):

```bash
docker build -t django-app .
```
Створення тегу для зв'язку локального образу з віддаленим репозиторієм в AWS:

```bash
docker tag django-app:latest [228266398439.dkr.ecr.us-east-1.amazonaws.com/lesson-5-ecr:latest](https://228266398439.dkr.ecr.us-east-1.amazonaws.com/lesson-5-ecr:latest)
```
Пуш образу в хмару AWS ECR:
```bash
docker push [228266398439.dkr.ecr.us-east-1.amazonaws.com/lesson-5-ecr:latest](https://228266398439.dkr.ecr.us-east-1.amazonaws.com/lesson-5-ecr:latest)
```

## Налаштування доступу до Kubernetes кластера
Оновлення локального конфігу kubeconfig для підключення утиліти kubectl до створеного в AWS кластера EKS:

```bash
aws eks update-kubeconfig --region us-east-1 --name django-eks-cluster
```
## Деплой застосунку в кластер
Застосування створених маніфестів (Deployment, Service, ConfigMap, HPA) у кластер:

```bash
helm install django-release ./charts/django-app
```
## Результати виконання та перевірка
Перевірка статусу сервісів та отримання публічної адреси додатка:

```bash
kubectl get svc
```
AWS LoadBalancer URL:
http://add2b9e551914467da4b0bab597e2e9e-2118668214.us-east-1.elb.amazonaws.com

<img width="1280" height="435" alt="screeen8" src="https://github.com/user-attachments/assets/44f2a103-92cf-4915-8724-35c8db66a24c" />
