#!/bin/bash
# Crontab to run this script everyday 1 am:
# 0 1 * * * /directory/process_mercadopago.sh >> /var/log/process_mercadopago.log 2>&1
# To edit crontab: crontab -e

SCRIPT_DIR=$(dirname "$0")
if [ ! -f "${SCRIPT_DIR}/.env" ]; then
  echo "$(date +"%Y-%m-%dT%H:%M:%S %Z"): File .env not found" >&2
  exit 1
fi

echo "$(date +"%Y-%m-%dT%H:%M:%S %Z"): Load file .env"
export $(grep -v '^#' "${SCRIPT_DIR}/.env" | xargs)

if [[ -z "$DIRECTORY" || -z "$DB_USER" || -z "$DB_NAME" || -z "$DB_HOST" || -z "$DB_PORT" ]]; then
  echo "$(date +"%Y-%m-%dT%H:%M:%S %Z"): Failed to load .env" >&2
  exit 1
fi

for file in "${DIRECTORY}"/{test,prod}-*.csv; do

  if [ ! -f "${file}" ]; then
    echo "$(date +"%Y-%m-%dT%H:%M:%S %Z"): File ${file} not found" >&2
    continue
  fi

  filename=$(basename "${file}")

  if [[ "${filename}" == test-* ]]; then
    table_prefix="test"
  elif [[ "${filename}" == prod-* ]]; then
    table_prefix="prod"
  else
    echo "$(date +"%Y-%m-%dT%H:%M:%S %Z"): Unknown prefix ${filename}" >&2
    continue
  fi

  psql -U ${DB_USER} -d ${DB_NAME} -h ${DB_HOST} -p ${DB_PORT} -c "COPY ${table_prefix}.transactions FROM '${DIRECTORY}/${filename}' DELIMITER ',' CSV HEADER;"

  if [ $? -ne 0 ]; then
    echo "$(date +"%Y-%m-%dT%H:%M:%S %Z"): Failed to process file ${filename}" >&2
    continue
  fi

  mv "${file}" "${file}.backup"
  if [ $? -ne 0 ]; then
    echo "$(date +"%Y-%m-%dT%H:%M:%S %Z"): Failed to backup file ${filename}" >&2
    continue
  fi

  echo "$(date +"%Y-%m-%dT%H:%M:%S %Z"): File ${filename} was processed"
done

echo "$(date +"%Y-%m-%dT%H:%M:%S %Z"): Completed"