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

### Calendar
Principal
```
curl -X GET "https://www.googleapis.com/calendar/v3/calendars/lalibertadavanzalobos.ar%40gmail.com/events?timeMin=2025-04-01T12:00:00Z&timeMax=2025-05-31T12:00:00Z&singleEvents=true&key=API_KEY"
```

Electoral
```
curl -X GET "https://www.googleapis.com/calendar/v3/calendars/6024b978a4778af358f1c977c503092b27474dcabcfe55e77397d97cd462c47c%40group.calendar.google.com/events?timeMin=2025-04-01T12:00:00Z&timeMax=2025-05-31T12:00:00Z&singleEvents=true&key=API_KEY"
```

### Test
```
curl 'http://localhost:4000/news?page=1&page_size=3'
curl 'http://localhost:4000/news?id=1'
curl 'http://localhost:4000/transactions?page=1&page_size=3'
curl 'http://localhost:4000/goal'
curl 'http://localhost:4000/funds'
curl 'http://localhost:4000/agenda?time_min=2025-04-01T12%3A00%3A00Z&time_max=2025-05-01T12%3A00%3A00Z'
```

### Scripts

[Scripts](scripts/README.md)


