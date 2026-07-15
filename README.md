# Terraform-модуль для бази даних

Модуль `modules/rds` створює звичайну RDS базу або Aurora.

## Приклад використання модуля

Для підключення модуля додайте в `main.tf`:

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

Модуль автоматично створить DB Subnet Group, Security Group і Parameter Group.

## Змінні модуля

| Змінна | Опис | Значення за замовчуванням |
|---|---|---|
| `use_aurora` | Вибирає Aurora або звичайну RDS | `false` |
| `engine` | Вказує engine звичайної RDS | `postgres` |
| `engine_version` | Вказує версію engine для RDS | `14` |
| `instance_class` | Вказує клас інстансу | `db.t3.micro` |
| `db_name` | Вказує назву бази даних | `mydb` |
| `username` | Вказує логін адміністратора | потрібно передати |
| `password` | Вказує пароль адміністратора | потрібно передати |
| `subnet_ids` | Передає список підмереж для бази | потрібно передати |
| `vpc_id` | Передає ID мережі VPC | потрібно передати |
| `name` | Вказує назву ресурсів бази | `lesson-db` |
| `allocated_storage` | Вказує розмір диска RDS у GB | `20` |
| `multi_az` | Вмикає RDS у декількох зонах | `false` |
| `publicly_accessible` | Вмикає публічний доступ до RDS | `false` |
| `backup_retention_period` | Вказує кількість днів зберігання backup | `7` |
| `aurora_engine` | Вказує engine для Aurora | `aurora-postgresql` |
| `aurora_engine_version` | Вказує версію engine для Aurora | `14` |
| `aurora_instance_count` | Вказує кількість інстансів Aurora | `1` |
| `rds_parameter_group_family` | Вказує family для RDS Parameter Group | `postgres14` |
| `aurora_parameter_group_family` | Вказує family для Aurora Parameter Group | `aurora-postgresql14` |
| `parameters` | Передає параметри для Parameter Group | PostgreSQL-параметри |
| `allowed_cidr_blocks` | Вказує мережі, яким дозволено доступ | `10.0.0.0/16` |
| `tags` | Додає теги до ресурсів | порожня map |

## Як змінити налаштування

Для створення звичайної RDS вкажіть:

```hcl
use_aurora = false
```

Для створення Aurora вкажіть:

```hcl
use_aurora = true
```

Для зміни типу звичайної бази змініть `engine`, наприклад:

```hcl
engine = "mysql"
```

Для зміни Aurora змініть `aurora_engine`, наприклад:

```hcl
aurora_engine = "aurora-mysql"
```

Для зміни версії бази вкажіть потрібне значення в `engine_version` або `aurora_engine_version`.

Для зміни класу інстансу змініть:

```hcl
instance_class = "db.t3.small"
```

Для зміни PostgreSQL на MySQL також змініть відповідну Parameter Group family та значення в `parameters`.

Пароль вкажіть у файлі `terraform.tfvars`:

```hcl
db_password = "CHANGE_ME"
```

Файл `terraform.tfvars` не потрібно додавати в Git.
