![](https://storage.yandexcloud.net/webazon/github/deb45d333d0414ba3de42155789fdb4a.jpg)

------

# backup-vps-s3

[TOC]

------

## Полное резервное копирование VPS

##### Резервное копирование и восстановление через облачное хранилище **S3**

### Установка

**CENTOS 7**

```bash
sudo yum install epel-release
sudo yum install s3fs-fuse
```

------

### Настройка

```bash
$ echo <идентификатор ключа>:<секретный ключ> >  /root/.passwd-s3fs
$ chmod 600  /root/.passwd-s3fs
$ mkdir /mnt/s3disk
$ s3fs <имя контейнера> /mnt/s3disk -o passwd_file=/root/.passwd-s3fs -o url=http://storage.yandexcloud.net -o use_path_request_style
```

Автоматизируем запуск **s3fs**

Создаем файл ***rc.local***

```bash
$ sudo nano /etc/rc.local
```

Добавить в него строку:

```
s3fs <имя контейнера> /mnt/s3disk -o passwd_file=/root/.passwd-s3fs -o url=http://storage.yandexcloud.net -o use_path_request_style
```

Сделать файл исполняемым и добавить в автозагрузку

```bash
$ sudo chmod +x /etc/rc.local
$ sudo systemctl enable rc-local
```

Теперь папка ***/mnt/s3disk*** это и есть с Бакет S3 хранилища!!!

Создаём там (в облачном хранилище !!!) папки для хранения копий по дням, неделям и месяцам...

```bash
$ mkdir /mnt/s3disk/day
$ mkdir /mnt/s3disk/week
$ mkdir /mnt/s3disk/month
```

... а так же паку для хранения горячей резервной копии баз данных.

```bash
$ mkdir /mnt/s3disk/month
```



------

Извлекаем скрипты из ***/usr/local/bin*** в соответствующие директории и ставим их в **cron** не забыв установить права на запуск

```bash
$ chmod +x /usr/local/bin/backup-day.sh
$ chmod +x /usr/local/bin/backup-week.sh
$ chmod +x /usr/local/bin/backup-month.sh
$ chmod +x /usr/local/bin/recovery-mysql.sh
```

... и редактируем файл...

```bash
$ crontab -e
```

**

```txt
# ежедневно в 2:00
0 2 * * * bash /usr/local/bin/backup-day.sh
# еженедельно в 2:15 в понедельник
15 2 * * 1 bash /usr/local/bin/backup-week.sh
# ежемесячно в 2:30 1-го числа месяца
30 2 1 * *  bash /usr/local/bin/backup-month.sh

```



> Ура! Резервное копирование настроено! :)

------

### Восстановление

Для восстановления:

- заливаем наш архив ***backup.tar.gz*** в корень диска

- выполняем команду

  ```bash
  $ tar xvpfz /backup.tar.gz -C /
  ```

- создаем утерянный каталог ***/mnt/s3disk*** 

- удаляем залитый ранее файл ***backup.tar.gz*** из корня диска

- перезагружаем сервер



> Ура! Система восстановлена!

------

## Горячее резервное копирование баз данных MySQL (MariaDB)

**Требование:** Установлено ***MariaDB-backup***

```bash
sudo yum install MariaDB-backup
```

### Подготовка

Создаём пользователя *`backup`*

```bash
mysql -u root -p
```

```mysql
mysql> CREATE USER 'backup'@'localhost' IDENTIFIED BY 'password';
mysql> GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT, CREATE TABLESPACE, PROCESS, SUPER, CREATE, INSERT, SELECT ON *.* TO 'backup'@'localhost';
mysql> FLUSH PRIVILEGES;
mysql> SELECT @@datadir;
```

Создать файл конфигурации MySQL с параметрами резервного копирования Начните с создания минимального файла конфигурации MySQL, который будет использовать сценарий резервного копирования. Это будет содержать учетные данные MySQL для пользователя MySQL. Открыть файл ***/etc/my.cnf.d/mariabackup.cnf*** в текстовом редакторе:

```bash
sudo nano /etc/my.cnf.d/mariabackup.cnf
```

Внутри создать раздел **[mariabackup]** и установите пользователя резервного копирования MySQL и пользователя пароля, которые определили в MySQL:

```tex
[mariabackup]
user = backup
password = password
# databases = database_name # (Необязательно) Копирование только определенных баз данных.
```

### Копирование:

```bash
bash backup-mysql.sh
```

При успешном выполнении операции копия базы данных будет располагаться в ***/backups/mysql*** а архив отправлен в облачное хранилище **S3**.

------

### Восстановление

Для восстановления запустить скрипт:

```bash
bash recovery-mysql.sh
```

