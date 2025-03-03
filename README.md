# Backend

## Docs

### Git Convention

https://www.conventionalcommits.org/en/v1.0.0/

### API
https://www.mercadopago.com.ar/developers/es/docs/checkout-pro/additional-content/reports/account-money/api

### Fields
https://www.mercadopago.com.ar/developers/es/docs/checkout-pro/additional-content/reports/account-money/report-fields

## Environment

### Sample .env

```
POSTGRES_URL="postgres://usuario:password@host.docker.internal:5432/mercadopago?options=-c%20search_path=test"
POSTGRES_MAX_CONNECTIONS="5"
LISTENER="0.0.0.0:4000"
```

### SQLx

```
DATABASE_URL="${POSTGRES_URL}" cargo sqlx prepare --check -- --bin llalobos-api
```

### Test
```
curl 'http://localhost:4000/transactions?page=1&page_size=3'
curl 'http://localhost:4000/goal
```

### Scripts

[Scripts](scripts/README.md)