##  Структура проєкту
```text
Project/
│
├── main.tf                  # Головний файл для підключення модулів
├── backend.tf               # Налаштування бекенду для стейтів (S3 + DynamoDB
├── outputs.tf               # Загальні виводи ресурсів
│
├── modules/                 # Каталог з усіма модулями
│   ├── s3-backend/          # Модуль для S3 та DynamoDB
│   │   ├── s3.tf            # Створення S3-бакета
│   │   ├── dynamodb.tf      # Створення DynamoDB
│   │   ├── variables.tf     # Змінні для S3
│   │   └── outputs.tf       # Виведення інформації про S3 та DynamoDB
│   │
│   ├── vpc/                 # Модуль для VPC
│   │   ├── vpc.tf           # Створення VPC, підмереж, Internet Gateway
│   │   ├── routes.tf        # Налаштування маршрутизації
│   │   ├── variables.tf     # Змінні для VPC
│   │   └── outputs.tf  
│   ├── ecr/                 # Модуль для ECR
│   │   ├── ecr.tf           # Створення ECR репозиторію
│   │   ├── variables.tf     # Змінні для ECR
│   │   └── outputs.tf       # Виведення URL репозиторію
│   │
│   ├── eks/                      # Модуль для Kubernetes кластера
│   │   ├── eks.tf                # Створення кластера
│   │   ├── aws_ebs_csi_driver.tf # Встановлення плагіну csi drive
│   │   ├── variables.tf     # Змінні для EKS
│   │   └── outputs.tf       # Виведення інформації про кластер
│   │
│   ├── jenkins/             # Модуль для Helm-установки Jenkins
│   │   ├── jenkins.tf       # Helm release для Jenkins
│   │   ├── variables.tf     # Змінні (ресурси, креденшели, values)
│   │   ├── providers.tf     # Оголошення провайдерів
│   │   ├── values.yaml      # Конфігурація jenkins
│   │   └── outputs.tf       # Виводи (URL, пароль адміністратора)
│   │ 
│   └── argo_cd/             # Новий модуль для Helm-установки Argo CD
│       ├── jenkins.tf       # Helm release для Jenkins
│       ├── variables.tf     # Змінні (версія чарта, namespace, repo URL тощо)
│       ├── providers.tf     # Kubernetes+Helm.  переносимо з модуля jenkins
│       ├── values.yaml      # Кастомна конфігурація Argo CD
│       ├── outputs.tf       # Виводи (hostname, initial admin password)
│		    └──charts/                  # Helm-чарт для створення app'ів
│ 	 	    ├── Chart.yaml
│	  	    ├── values.yaml          # Список applications, repositories
│			    └── templates/
│		        ├── application.yaml
│		        └── repository.yaml
├── charts/
│   └── django-app/
│       ├── templates/
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   ├── configmap.yaml
│       │   └── hpa.yaml
│       ├── Chart.yaml
│       └── values.yaml     # ConfigMap зі змінними середовища


```
## Інструкція з розгортання та запуску команд
Ініціалізація проєкту, перевірка плану та створення всіх ресурсів в AWS (VPC, ECR, EKS):

```bash
terraform init
terraform plan
terraform apply -auto-approve
```
## Схема CI/CD процесу
1. **CI (Jenkins):**  Jenkins за допомогою Kubernetes-агента (Kaniko + Git) збирає Docker-образ, пушить його в ECR та оновлює тег у `values.yaml` Helm-чарта.
2. **CD (Argo CD):** Argo CD відстежує репозиторій. При оновленні файлу в Git, Argo CD автоматично підхоплює зміни та синхронізує стан кластера Kubernetes (GitOps).

## Як перевірити роботу Jenkins
1. Переконайтеся, що поди Jenkins працюють: `kubectl get pods -n jenkins`.
2. Виконайте `port-forward` для доступу до панелі:
   `kubectl port-forward svc/jenkins 8080:8080 -n jenkins`
3. У Jenkins Pipeline перевірте історію виконання для вашої гілки. Логи пайплайну покажуть процес збірки через Kaniko та оновлення Git.

## Як побачити результат в Argo CD
1. Виконайте прокидання порту:
   `kubectl port-forward svc/argo-cd-server -n argocd 8080:443`
2. Відкрийте в браузері `https://localhost:8080`.
3. У списку додатків оберіть `django-app`. Статус **Healthy** та **Synced** підтверджує успішну роботу GitOps-конвеєра.

<img width="1280" height="651" alt="photo_2026-07-12_19-14-51" src="https://github.com/user-attachments/assets/cdb728d6-96f1-4145-82df-805b4ebea8da" />

<img width="1183" height="569" alt="photo_2026-07-12_19-16-51" src="https://github.com/user-attachments/assets/4e8ca819-ddfb-4b97-a068-97d17159462a" />

