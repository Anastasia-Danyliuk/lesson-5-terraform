# Terraform-модуль для бази даних

Це домашнє завдання з Terraform. Модуль `modules/rds` може створити звичайну RDS базу або Aurora.

## Як вибрати базу

- `use_aurora = false` — створюється одна звичайна RDS база.
- `use_aurora = true` — створюється Aurora cluster та його instance.

Приклад підключення модуля:

```hcl
module "rds" {
  source = "./modules/rds"

  name           = "lesson-db"
  use_aurora     = var.use_aurora
  engine         = var.db_engine
  instance_class = var.db_instance_class
  db_name        = var.db_name
  username       = var.db_username
  password       = var.db_password

  vpc_id             = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnets
  allowed_cidr_blocks = ["10.0.0.0/16"]
}
```

Модуль сам створює DB Subnet Group, Security Group і Parameter Group.

## Основні змінні

| Змінна | Для чого потрібна | Значення за замовчуванням |
|---|---|---|
| `use_aurora` | Вибір між RDS та Aurora | `false` |
| `engine` | Тип звичайної RDS: `postgres` або `mysql` | `postgres` |
| `engine_version` | Версія звичайної RDS | `14` |
| `aurora_engine` | Тип Aurora | `aurora-postgresql` |
| `aurora_engine_version` | Версія Aurora | `14` |
| `instance_class` | Клас instance | `db.t3.micro` |
| `allocated_storage` | Розмір диска звичайної RDS | `20` GB |
| `db_name` | Назва бази | `mydb` |
| `username` | Логін адміністратора | задається користувачем |
| `password` | Пароль адміністратора | задається у `terraform.tfvars` |
| `multi_az` | Резервна RDS в іншій зоні | `false` |
| `aurora_instance_count` | Кількість Aurora instance | `1` |
| `parameters` | Параметри Parameter Group | PostgreSQL-параметри з прикладу |
| `name` | Назва ресурсів бази | `lesson-db` |
| `subnet_ids` | Підмережі для DB Subnet Group | задаються користувачем |
| `vpc_id` | VPC для Security Group | задається користувачем |
| `allowed_cidr_blocks` | Мережі, яким дозволено доступ | `10.0.0.0/16` |
| `publicly_accessible` | Чи має RDS публічну адресу | `false` |
| `backup_retention_period` | Скільки днів зберігати backup | `7` |
| `rds_parameter_group_family` | Family для RDS Parameter Group | `postgres14` |
| `aurora_parameter_group_family` | Family для Aurora Parameter Group | `aurora-postgresql14` |
| `tags` | Додаткові теги AWS | порожня map |

## Як змінити налаштування

Скопіюйте `terraform.tfvars.example` у `terraform.tfvars` і замініть пароль. Файл `terraform.tfvars` не додається в Git.

Для Aurora змініть:

```hcl
use_aurora = true
```

Для MySQL змініть `engine`, версію, family Parameter Group і параметри на сумісні з MySQL.

## Перевірка

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform plan
```

Після перевірки створені ресурси потрібно видалити:

```bash
terraform destroy
```
