#!/bin/bash

ENV_FILE=""
JSON_FILE=""

usage() {
    echo "Usage: $0 [--test|--prod] [--retrieve|--create|--update|--activate|--deactivate|--first]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --test)
            ENV_FILE=".env.test"
            JSON_FILE="report.test.json"
            shift
            ;;
        --prod)
            ENV_FILE=".env.prod"
            JSON_FILE="report.prod.json"
            shift
            ;;
        --retrieve)
            ACTION="retrieve"
            shift
            ;;
        --create)
            ACTION="create"
            shift
            ;;
        --update)
            ACTION="update"
            shift
            ;;
        --activate)
            ACTION="activate"
            shift
            ;;
        --deactivate)
            ACTION="deactivate"
            shift
            ;;
        --first)
            ACTION="first"
            JSON_FILE="report.first.json"
            shift
            ;;
        *)
            usage
            ;;
    esac
done

if [[ -z "$ENV_FILE" ]] || [[ -z "$ACTION" ]]; then
    usage
fi

source "$ENV_FILE"

URL="https://api.mercadopago.com/v1/account/settlement_report"
AUTHORIZATION="Authorization: Bearer ${TOKEN}"
ACCEPT="accept: application/json"
CONTENT_TYPE="content-type: application/json"

case "$ACTION" in
    retrieve)
        curl -X GET -H "${ACCEPT}" -H "${CONTENT_TYPE}" -H "${AUTHORIZATION}" ${URL}/config
        ;;
    create)
        curl -X POST -H "${ACCEPT}" -H "${CONTENT_TYPE}" -H "${AUTHORIZATION}" ${URL}/config -d @"${JSON_FILE}"
        ;;
    update)
        curl -X PUT -H "${ACCEPT}" -H "${CONTENT_TYPE}" -H "${AUTHORIZATION}" ${URL}/config -d @"${JSON_FILE}"
        ;;
    activate)
        curl -X POST -H "${ACCEPT}" -H "${CONTENT_TYPE}" -H "${AUTHORIZATION}" ${URL}/schedule
        ;;
    deactivate)
        curl -X DELETE -H "${ACCEPT}" -H "${CONTENT_TYPE}" -H "${AUTHORIZATION}" ${URL}/schedule
        ;;
    first)
        curl -X POST -H "${ACCEPT}" -H "${CONTENT_TYPE}" -H "${AUTHORIZATION}" ${URL} -d @"${JSON_FILE}"
        ;;
    *)
        usage
        ;;
esac