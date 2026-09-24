#!/usr/bin/env bash
set -euo pipefail

BOOTSTRAP="${KAFKA_BOOTSTRAP_SERVER:-broker1:9092}"
CLIENT_CONFIG="/tmp/client-ssl.properties"

# SSL-конфиг для kafka-topics/kafka-acls
cat > "${CLIENT_CONFIG}" <<EOF
security.protocol=SSL
ssl.truststore.location=/etc/kafka/secrets/broker1.truststore.jks
ssl.truststore.password=changeit
ssl.keystore.location=/etc/kafka/secrets/broker1.keystore.jks
ssl.keystore.password=changeit
ssl.key.password=changeit
EOF

sleep 15

# Создаём топики
kafka-topics --bootstrap-server "${BOOTSTRAP}" --create --topic topic-1 --partitions "${PARTITIONS}" --replication-factor "${REPLICATION_FACTOR}" --command-config "${CLIENT_CONFIG}" || true
kafka-topics --bootstrap-server "${BOOTSTRAP}" --create --topic topic-2 --partitions "${PARTITIONS}" --replication-factor "${REPLICATION_FACTOR}" --command-config "${CLIENT_CONFIG}" || true

# ACL для topic-1: Read + Write для User:app
kafka-acls --bootstrap-server "${BOOTSTRAP}" --add \
  --allow-principal User:app \
  --operation Read --operation Write \
  --topic topic-1 \
  --command-config "${CLIENT_CONFIG}"

# ACL для topic-2: только Write для User:app
kafka-acls --bootstrap-server "${BOOTSTRAP}" --add \
  --allow-principal User:app \
  --operation Write \
  --topic topic-2 \
  --command-config "${CLIENT_CONFIG}"

echo "Topics and ACLs configured successfully."