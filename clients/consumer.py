import os
from confluent_kafka import Consumer

conf = {
    "bootstrap.servers": os.environ["BOOTSTRAP_SERVERS"],
    "security.protocol": "SSL",
    "ssl.ca.location": os.environ["SSL_CA_LOCATION"],
    "ssl.certificate.location": os.environ["SSL_CERT_LOCATION"],
    "ssl.key.location": os.environ["SSL_KEY_LOCATION"],
    "ssl.key.password": os.environ["SSL_KEY_PASSWORD"],
    "group.id": os.environ["GROUP_ID"],
    "auto.offset.reset": "earliest",
    "client.id": f"app-consumer-{os.environ['TOPIC']}",
}

consumer = Consumer(conf)

topic = os.environ["TOPIC"]
consumer.subscribe([topic])

print(f"Subscribed to {topic}, waiting for messages...")

try:
    while True:
        msg = consumer.poll(1.0)
        if msg is None:
            continue
        if msg.error():
            print(f"Error: {msg.error()}")
            continue
        print(f"Received: {msg.value().decode('utf-8')}")
except KeyboardInterrupt:
    pass
finally:
    consumer.close()