CREATE TABLE test.transactions (
    TRANSACTION_DATE TIMESTAMP WITH TIME ZONE NOT NULL,
    SOURCE_ID VARCHAR(20) NOT NULL PRIMARY KEY,
    PAYER_NAME VARCHAR(80) NOT NULL,
    TRANSACTION_AMOUNT DECIMAL NOT NULL,
    TRANSACTION_TYPE VARCHAR(20) NOT NULL
);

CREATE INDEX idx_transaction_date ON test.transactions (TRANSACTION_DATE);
CREATE INDEX idx_payer_name ON test.transactions (PAYER_NAME);

CREATE TABLE test.target (
    TARGET_AMOUNT DECIMAL NOT NULL
);

CREATE OR REPLACE FUNCTION direction(TRANSACTION_TYPE TEXT)
RETURNS DECIMAL AS $$
BEGIN
  CASE TRIM(TRANSACTION_TYPE)
    WHEN 'SETTLEMENT' THEN
      RETURN 1; -- Cobro
    WHEN 'REFUND'
       , 'CHARGEBACK'
       , 'DISPUTE'
       , 'WITHDRAWAL'
       , 'PAYOUT' THEN
      RETURN -1; -- Pago
    WHEN 'WITHDRAWAL_CANCEL' THEN
      RETURN 1; -- Un retiro cancelado vuelve a tener el dinero disponible
    ELSE
      RAISE NOTICE 'Unknown transaction type: %', TRANSACTION_TYPE;
      RETURN 0;
  END CASE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW test.funds AS
    SELECT trim(payer_name) as payer_name, sum(transaction_amount * direction(trim(transaction_type))) as amount
    FROM test.transactions
    GROUP BY trim(payer_name)
    ORDER BY amount DESC;

CREATE OR REPLACE VIEW test.goal AS
    SELECT sum(tx.transaction_amount * direction(trim(tx.transaction_type))) as balance, 
        (select max(tg.target_amount) from test.target as tg) as target
    FROM test.transactions tx;

COPY test.transactions (SOURCE_ID, TRANSACTION_TYPE, TRANSACTION_AMOUNT, TRANSACTION_DATE, PAYER_NAME) FROM '/DIRECTORY/settlement-report-USER_ID-2025-03-01-065004.csv' DELIMITER ',' CSV HEADER;