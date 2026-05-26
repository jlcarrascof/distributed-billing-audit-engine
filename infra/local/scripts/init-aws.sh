#!/bin/bash
# Desactivar variables de proxy para la comunicación directa entre contenedores
export HTTP_PROXY=""
export HTTPS_PROXY=""
export http_proxy=""
export https_proxy=""

# Configurar credenciales ficticias de AWS para desarrollo local
export AWS_ACCESS_KEY_ID=mock
export AWS_SECRET_ACCESS_KEY=mock
export AWS_DEFAULT_REGION=us-east-1
export AWS_EC2_METADATA_DISABLED=true

echo "Initializing AWS local resources..."

# 1. Crear colas de SQS
echo "Creating SQS queues..."
awslocal sqs create-queue --queue-name dbae-invoice-queue
awslocal sqs create-queue --queue-name dbae-invoice-dlq

# 2. Crear tabla de DynamoDB (Single-Table Design) en el contenedor de DynamoDB Local
echo "Creating DynamoDB table..."
aws --endpoint-url=http://dbae-dynamodb-local:8000 dynamodb create-table \
    --table-name dbae-billing-audit-table \
    --attribute-definitions \
        AttributeName=PK,AttributeType=S \
        AttributeName=SK,AttributeType=S \
    --key-schema \
        AttributeName=PK,KeyType=HASH \
        AttributeName=SK,KeyType=RANGE \
    --billing-mode PAY_PER_REQUEST \
    --region us-east-1

echo "AWS local resources initialization complete."
