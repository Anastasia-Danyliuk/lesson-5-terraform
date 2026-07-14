Terraform створює інфраструктуру в AWS і встановлює Jenkins та Argo CD через Helm. Jenkins збирає Docker-образ, завантажує його в Amazon ECR та змінює тег образу у `values.yaml`. Після цього Argo CD бачить зміну в GitHub і оновлює застосунок у Kubernetes.

## Як працює

```text
Зміни в GitHub
      ↓
Jenkins запускає pipeline
      ↓
Kaniko збирає Docker-образ
      ↓
Образ завантажується в Amazon ECR
      ↓
Jenkins змінює image.tag у values.yaml
      ↓
Argo CD бачить зміну в GitHub
      ↓
Застосунок оновлюється в EKS
```

## Що є в проєкті

- простий Django-застосунок;
- Dockerfile;
- Terraform-модулі для VPC, ECR, EKS, Jenkins та Argo CD;
- Jenkinsfile з Kaniko та Git;
- Helm chart для Django-застосунку;
- Argo CD Application з автоматичною синхронізацією;
- окремий Terraform-каталог `bootstrap` для S3 і DynamoDB.

## Що потрібно встановити

Перед запуском потрібні:

- AWS CLI;
- Terraform;
- kubectl;
- Helm;
- Git.

Також потрібен AWS-акаунт і GitHub token із правом запису в репозиторій.

## 1. Створення S3 і DynamoDB для Terraform state

Спочатку потрібно створити backend для Terraform:

```bash
terraform -chdir=bootstrap init
terraform -chdir=bootstrap apply
```

S3 зберігає Terraform state, а DynamoDB використовується для блокування state.

## 2. Налаштування змінних

Потрібно зробити копію файлу `terraform.tfvars.example`:

```bash
cp terraform.tfvars.example terraform.tfvars
```

У файлі `terraform.tfvars` потрібно вказати свої дані:

- `github_token`;
- `jenkins_aws_access_key_id`;
- `jenkins_aws_secret_access_key`.

Цей файл доданий у `.gitignore`, тому секрети не повинні потрапити в GitHub.

## 3. Запуск Terraform

Для перевірки та створення інфраструктури я використовую такі команди:

```bash
terraform init -reconfigure
terraform fmt -check -recursive
terraform validate
terraform plan
terraform apply
```

Після створення EKS потрібно підключити kubectl до кластера:

```bash
aws eks update-kubeconfig --region us-east-1 --name django-eks-cluster
kubectl get nodes
```

Перевірка Jenkins та Argo CD:

```bash
kubectl get pods -n jenkins
kubectl get pods -n argocd
```

## 4. Як перевірити Jenkins

Щоб отримати пароль Jenkins:

```bash
kubectl get secret -n jenkins jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode
```

Щоб відкрити Jenkins локально:

```bash
kubectl port-forward -n jenkins svc/jenkins 8080:8080
```

Після цього Jenkins буде доступний за адресою:

```text
http://localhost:8080
```

У Jenkins потрібно створити Pipeline job і вибрати **Pipeline script from SCM**.

Налаштування job:

- SCM — Git;
- Repository URL — `https://github.com/Anastasia-Danyliuk/lesson-5-terraform.git`;
- Branch — `*/lesson-8-9`;
- Script Path — `Jenkinsfile`.

Після натискання **Build Now** pipeline повинен:

1. Перевірити потрібні файли.
2. Зібрати Docker-образ через Kaniko.
3. Завантажити образ в Amazon ECR.
4. Змінити тег образу в `charts/django-app/values.yaml`.
5. Запушити зміну в гілку `lesson-8-9`.

Перевірити образ в ECR можна командою:

```bash
aws ecr describe-images --region us-east-1 --repository-name lesson-5-ecr
```

## 5. Як перевірити Argo CD

Перевірити Application можна командами:

```bash
kubectl get applications -n argocd
kubectl get application django-app -n argocd
```

Щоб відкрити Argo CD локально:

```bash
kubectl port-forward -n argocd svc/argo-cd-server 8081:443
```

Argo CD буде доступний за адресою:

```text
https://localhost:8081
```

Логін — `admin`.

Пароль можна отримати так:

```bash
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 --decode
```

У вебінтерфейсі застосунок `django-app` повинен мати статуси **Synced** і **Healthy**.

Також результат можна перевірити через kubectl:

```bash
kubectl get pods -n django-app
kubectl get svc -n django-app
kubectl get hpa -n django-app
```

Для перевірки самого застосунку можна відкрити адресу LoadBalancer. Endpoint `/health/` повинен повернути:

```json
{"status": "healthy"}
```

## Локальна перевірка Helm chart

```bash
helm lint charts/django-app
helm template django-app charts/django-app
helm lint modules/argo_cd/charts
```

## Видалення ресурсів

AWS-ресурси можуть коштувати гроші, тому після перевірки їх потрібно видалити.

Спочатку видаляється основна інфраструктура:

```bash
terraform destroy
```

Після цього можна видалити S3 та DynamoDB:

```bash
terraform -chdir=bootstrap destroy
```

Backend потрібно видаляти останнім, тому що в ньому зберігається Terraform state.
