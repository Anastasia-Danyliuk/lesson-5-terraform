##  Структура проєкту
```text
lesson-5-terraform/
│
├── charts/                  # Helm-чарт застосунку
│   └── django-app/
│       ├── templates/       # Маніфести (deployment, service, hpa, configmap)
│       ├── Chart.yaml
│       └── values.yaml      # Конфігураційні змінні
│
├── modules/                 # Модулі інфраструктури
│   ├── argo_cd/             # Модуль для Argo CD
│   │   ├── jenkins.tf       # Terraform маніфести (Helm release)
│   │   ├── outputs.tf
│   │   ├── providers.tf
│   │   ├── values.yaml
│   │   └── variables.tf
│   ├── ecr/                 # Модуль для ECR
│   ├── eks/                 # Модуль для EKS кластера
│   ├── jenkins/             # Модуль для Jenkins
│   ├── s3-backend/          # Модуль для стану (S3 + DynamoDB)
│   └── vpc/                 # Модуль для мережі
│
├── .gitignore               # Виключення для системних файлів
├── .terraform.lock.hcl      # Файл блокування версій провайдерів
├── argo-application.yaml    # Маніфест Argo CD Application
├── backend.tf               # Налаштування бекенду
├── Dockerfile               # Інструкція збірки Docker-образу
├── Jenkinsfile              # Pipeline для CI/CD
├── kubectl                  # Конфігураційний файл/бінарний файл kubectl
├── main.tf                  # Головний файл проєкту
├── outputs.tf               # Виводи інфраструктури
├── README.md                # Документація проєкту
├── requirements.txt         # Залежності
├── terraform.tfstate        # Файл стану Terraform
└── terraform.tfstate.backup # Резервна копія стану


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

