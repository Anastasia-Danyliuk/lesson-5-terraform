# Фінальний проєкт

Інфраструктура проекту AWS зібрано за допомогою Terraform і налаштовано простий CI/CD для Django-застосунку

## Що є у проєкті

- VPC з public і private subnet;
- EKS кластер;
- ECR для Docker-образів;
- PostgreSQL у RDS;
- Jenkins для збірки Docker-образу;
- Argo CD для автоматичного оновлення застосунку;
- Prometheus і Grafana для моніторингу;
- Helm chart для Django;
- HPA для автомасштабування Django pods;
- S3 і DynamoDB для Terraform state.

Було обрано PostgreSQL RDS, замість Aurora, тому він простіший і дешевший

## Як працює CI/CD

```text
Пушимо зміни в GitHub
          ↓
Jenkins запускає Jenkinsfile
          ↓
Kaniko збирає Docker-образ
          ↓
Образ завантажується в ECR
          ↓
Jenkins змінює image.tag у values.yaml
          ↓
Argo CD бачить зміну в GitHub
          ↓
Django оновлюється в EKS
```

## Основні папки

```text
modules/vpc          - мережа AWS
modules/eks          - Kubernetes кластер і EBS CSI driver
modules/ecr          - Docker registry
modules/rds          - PostgreSQL база даних
modules/jenkins      - Jenkins через Helm
modules/argo_cd      - Argo CD через Helm
modules/monitoring   - Prometheus і Grafana
charts/django-app    - Helm chart застосунку
bootstrap            - S3 і DynamoDB для Terraform state
config               - простий Django-застосунок
```

## Перед запуском

Потрібно встановити:

- AWS CLI;
- Terraform;
- kubectl;
- Helm;
- Git.

Також потрібно налаштувати AWS CLI:

```bash
aws configure
```

## Створення backend

S3 і DynamoDB створюються окремо:

```bash
terraform -chdir=bootstrap init
terraform -chdir=bootstrap apply
```

## Налаштування змінних

Створюємо локальний файл зі змінними:

```bash
cp terraform.tfvars.example terraform.tfvars
```

У `terraform.tfvars` потрібно замінити тестові значення на свої:

- GitHub token;
- AWS access key і secret key для Jenkins;
- пароль RDS;
- Django secret key;
- пароль Grafana.

## Перевірка і запуск Terraform

```bash
terraform init -reconfigure
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```
Після створення кластера :

```bash
aws eks update-kubeconfig --region us-east-1 --name final-project-eks-cluster
kubectl get nodes
```

## Перевірка всіх компонентів

```bash
kubectl get all -n jenkins
kubectl get all -n argocd
kubectl get all -n monitoring
kubectl get all -n django-app
```

## Перевірка Jenkins

Отримуємо пароль Jenkins:

```bash
kubectl get secret -n jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
```

Відкриваємо Jenkins через port-forward:

```bash
kubectl port-forward svc/jenkins 8080:8080 -n jenkins
```

Адреса: `http://localhost:8080`

У Jenkins потрібно створити Pipeline job:

- Pipeline script from SCM;
- SCM: Git;
- Repository URL: `https://github.com/Anastasia-Danyliuk/lesson-5-terraform.git`;
- Branch: `*/final-project`;
- Script Path: `Jenkinsfile`.

Після **Build Now** Jenkins повинен зібрати образ, відправити його в ECR і змінити тег у `charts/django-app/values.yaml`.

## Перевірка Argo CD

```bash
kubectl port-forward svc/argocd-server 8081:443 -n argocd
```

Адреса: `https://localhost:8081`

Логін: `admin`

Пароль:

```bash
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

Перевірка через kubectl:

```bash
kubectl get application django-app -n argocd
kubectl get pods -n django-app
kubectl get svc -n django-app
kubectl get hpa -n django-app
```

Endpoint `/health/` перевіряє Django, а `/ready/` також перевіряє підключення до RDS.

## Перевірка Grafana і Prometheus

Відкриваємо Grafana:

```bash
kubectl port-forward svc/grafana 3000:80 -n monitoring
```

Адреса: `http://localhost:3000`

Логін: `admin`. Пароль — значення `grafana_admin_password` із локального `terraform.tfvars`.

У Grafana можна відкрити готові Kubernetes dashboards і подивитися CPU, пам'ять, pods та nodes.

Перевірка Prometheus:

```bash
kubectl get pods -n monitoring
kubectl get prometheus -n monitoring
```

## Локальна перевірка Django і Helm

```bash
docker compose up --build
helm lint charts/django-app
helm template django-app charts/django-app
```



Локальний Django буде доступний за адресою `http://localhost:8000`.

## Видалення ресурсів

```bash
terraform destroy
```

<img width="1041" height="217" alt="screen1" src="https://github.com/user-attachments/assets/e61a3fc8-b497-4534-89ae-1f83c74c26c4" />

<img width="1280" height="175" alt="01" src="https://github.com/user-attachments/assets/1540541a-de23-4ade-b94b-5325446b2b06" />

<img width="1280" height="485" alt="02" src="https://github.com/user-attachments/assets/e5db77c6-f347-46b2-a0f1-baf14e398d5a" />

<img width="1280" height="642" alt="03" src="https://github.com/user-attachments/assets/6ca64d1d-9061-4c42-b2f5-09d58b225ff3" />

<img width="1280" height="326" alt="04" src="https://github.com/user-attachments/assets/e304c88a-54be-415a-8592-d4928a614432" />

<img width="1280" height="139" alt="05" src="https://github.com/user-attachments/assets/e5674876-374d-4308-b950-ba703998a9a5" />
