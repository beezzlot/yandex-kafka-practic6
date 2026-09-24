# Безопасность Apache Kafka

Настройка защищённого SSL-кластера Apache Kafka (KRaft, 3 брокера) в Docker, создание топиков и ACL, тестирование зашифрованных сообщений.

## Цель

Цель задания: настроить защищённое SSL-соединение для кластера Apache Kafka из трёх брокеров с использованием Docker Compose, создать новый топик и протестировать отправку и получение зашифрованных сообщений.

## Быстрый старт

### 1. Создать external network

```bash
docker network create kafka-internal
```

### 2. Запустить Kafka-кластер

```bash
docker compose -f docker-compose-kafka.yml up -d
```

Проверка:

```bash
docker compose -f docker-compose-kafka.yml ps
```

### 3. Создать топики и ACL

Контейнер `init-topics` (образ `confluentinc/cp-kafka`) автоматически запустит `scripts/setup-acls.sh` после старта Docker-Compose.

### 4. Запустить консьюмеров

```bash
docker compose -f docker-compose-app.yml up -d
```

Логи:

```bash
docker logs -f consumer-topic1
docker logs -f consumer-topic2-denied
```

Ожидаемое поведение:
- `consumer-topic1` — получает сообщения из `topic-1`;
- `consumer-topic2-denied` — получает ошибки авторизации (ACL запрещает `Read` на `topic-2`).


## Проверка SSL-соединения

```bash
openssl s_client -connect localhost:9094 -tls1_3 -showcerts </dev/null 2>/dev/null | openssl x509 -noout -subject
```

Должен отображаться сертификат брокера.

## Остановка и очистка

```bash
# Остановить консьюмеров
docker compose -f docker-compose-app.yml down -v

# Остановить кластер Kafka
docker compose -f docker-compose-kafka.yml down -v

# Удалить network (если не нужен)
docker network rm kafka-internal
```
