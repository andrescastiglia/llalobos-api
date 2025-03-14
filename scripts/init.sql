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

CREATE TABLE test.news (
    ID SERIAL NOT NULL PRIMARY KEY,
    DATE TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    TITLE VARCHAR(255) NOT NULL,
    CONTENT TEXT NOT NULL,
    MEDIA BYTEA NULL,
    TRANSCRIPTION TEXT NULL
);

CREATE INDEX idx_news_date ON test.news (date);

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
    WHERE direction(trim(transaction_type)) > 0 AND transaction_amount > 0
    GROUP BY trim(payer_name)
    ORDER BY amount DESC;

CREATE OR REPLACE VIEW test.goal AS
    SELECT sum(tx.transaction_amount * direction(trim(tx.transaction_type))) as balance, 
        (select max(tg.target_amount) from test.target as tg) as target
    FROM test.transactions tx;

COPY test.transactions (SOURCE_ID, TRANSACTION_TYPE, TRANSACTION_AMOUNT, TRANSACTION_DATE, PAYER_NAME) FROM '/DIRECTORY/settlement-report-USER_ID-2025-03-01-065004.csv' DELIMITER ',' CSV HEADER;

INSERT INTO test.news (title, content, media, transcription)
VALUES (
    'Lanzamiento de nuevo producto',
    'Hoy se anunció el lanzamiento de un nuevo producto innovador...',
    pg_read_binary_file('/DIRECTORY/file.mpeg'),
    'Transcripción de la grabación de audio o video.'
);

INSERT INTO test.news (title, content, media, transcription)
VALUES (
'Acalorado Debate en el Concejo Deliberante por la Inseguridad y el Gasto Público en la Provincia de Buenos Aires',
$$En una sesión marcada por la tensión y las acusaciones, el Concejo Deliberante abordó el delicado tema de la inseguridad en la provincia de Buenos Aires y los recursos asignados por el gobierno provincial. Durante su intervención, un concejal expresó su preocupación por la falta de fondos destinados a la seguridad y cuestionó las prioridades del gobernador Axel Kicillof en el manejo del presupuesto.
El edil señaló la contradicción entre la necesidad de unidades de patrullaje, solicitadas hace tiempo, y el gasto en publicidad política y bienes considerados no esenciales. Según sus declaraciones, se destinaron 30.000 millones de pesos a campañas de promoción partidaria, lo que se traduce en 82 millones de pesos diarios o 3 millones por hora. Además, mencionó inversiones en kits escolares con logos oficiales y la compra de vehículos de alta gama a través del Instituto Provincial de Asociativismo y Cooperativismo (IPAC).
“¿Cómo se puede justificar esta falta de recursos para la seguridad cuando se gastan cifras exorbitantes en propaganda política y bienes suntuosos?”, se preguntó el concejal, destacando también la diferencia de precios en la compra de patrulleros, cuyo costo habría superado en más del doble el valor de mercado.
El debate se tornó aún más encendido cuando se mencionaron partidas asignadas a áreas como el Ministerio de Género y Diversidad, festivales artísticos y comunicación inclusiva, contrastándolas con la crisis de inseguridad que enfrenta la provincia. “La inseguridad es la principal preocupación del 39% de los bonaerenses, y aún así, las prioridades parecen estar lejos de resolver este problema”, agregó.
Finalmente, tras la exposición de estos argumentos, se decidió enviar el expediente correspondiente a la comisión para su tratamiento. La sesión dejó en evidencia las tensiones políticas y las diferentes visiones sobre el uso del presupuesto provincial, en un contexto donde la demanda por mayor seguridad sigue siendo una preocupación central para la ciudadanía.$$,
pg_read_binary_file('/home/mercadopago/files/porccheda001.mpeg'),
$$[00:00.000 --> 00:11.700]  Gracias, señora Presidente. Bueno, después de escuchar las palabras del Concejal Tea,
[00:11.820 --> 00:17.440]  la verdad que me genera un par de sentimientos con respecto a las declaraciones.
[00:18.180 --> 00:23.120]  Es verdad que quizás el Gobernador no tenga los fondos que necesita,
[00:24.260 --> 00:27.340]  y a la vez que contradictorio hace poco aprobamos, como dijo él,
[00:27.340 --> 00:32.080]  un proyecto solicitándole a los patrilleros, ahora pateamos la pelota para arriba,
[00:32.280 --> 00:39.140]  diciendo que no hay, o sea, pedimos las unidades que necesitamos de Lobos hace bastante tiempo,
[00:40.300 --> 00:46.320]  y son bastantes las sesiones que hemos tratado de este tema con respecto a la inseguridad,
[00:47.080 --> 00:49.920]  y no solo la de Lobos, sino de toda la provincia de Buenos Aires.
[00:49.920 --> 00:59.300]  Las declaraciones del Concejal Tea muestran como que hay una falta de fondos,
[00:59.760 --> 01:05.420]  como que el Presidente tiene la culpa respecto a la gestión que el Gobernador tiene que llevar adelante,
[01:06.140 --> 01:08.760]  sabiendo que la provincia de Buenos Aires es una de las provincias que más recauda.
[01:10.580 --> 01:13.140]  Y la verdad que faltaron algunos datos también,
[01:13.140 --> 01:18.740]  porque nosotros siempre mantenemos la misma postura, que es importante manejar datos.
[01:19.500 --> 01:23.980]  El Gobernador en este momento está pateándole la pelota con respecto a la inseguridad
[01:23.980 --> 01:27.560]  que está viviendo y atravesando el baño de sangre de la provincia que estamos viviendo.
[01:28.980 --> 01:33.220]  Tenemos alguna información oficial, que es pública.
[01:34.720 --> 01:37.660]  Últimamente el Gobernador se ha tomado ciertas atribuciones
[01:37.660 --> 01:44.460]  y ha decidido gastar dinero en un montón de cosas que quizás para algunos es prioridad,
[01:44.980 --> 01:50.760]  pero creemos que para la gran cantidad de los bonaerenses, de los lobenenses y de los argentinos no.
[01:52.380 --> 01:57.480]  Por ejemplo, 30.000 millones en publicidad partidaria.
[01:58.440 --> 02:03.520]  Cuenta DNI, cartelería, pauta, entre otras cosas,
[02:03.520 --> 02:06.080]  pauta de algunos medios de comunicación, 30.000 millones.
[02:07.660 --> 02:14.060]  O sea que eso significa que son 82 millones por día que se gasta en publicidad política,
[02:14.620 --> 02:16.360]  en promoción política.
[02:17.340 --> 02:20.260]  También significa que son 3 millones por hora.
[02:24.260 --> 02:25.440]  ¿Y no hay plata?
[02:27.260 --> 02:32.100]  Le reclama al presidente este tipo de cosas cuando está gastando
[02:32.100 --> 02:35.300]  semejante cantidad de dinero en publicidad política.
[02:35.520 --> 02:35.680]  Bien.
[02:35.680 --> 02:41.160]  Luego, 2.600 millones en quites escolares con el logo de su gobierno.
[02:41.360 --> 02:42.540]  Más publicidad política.
[02:44.140 --> 02:49.000]  Mientras los docentes están pidiendo que las paritarias comiencen
[02:49.000 --> 02:54.260]  gracias a este gobierno que ha estabilizado la economía y ha bajado la inflación,
[02:54.940 --> 03:01.180]  el Gobernador aún no consigue darle el resguardo que necesitan los docentes
[03:01.180 --> 03:04.600]  y la policía y la policía también con respecto a la paritaria y el poder adquisitivo
[03:04.600 --> 03:08.100]  que necesitan las personas más importantes de la Argentina.
[03:08.100 --> 03:13.920]  Sigue siendo campaña política también, ¿no?
[03:13.920 --> 03:19.860]  No, útiles escolares con el nombre del gobernador o de la provincia, del ministerio.
[03:20.860 --> 03:22.200]  No sé si es una prioridad también.
[03:22.200 --> 03:30.100]  Casi 100 millones de dólares, esto fue data de hace dos días,
[03:31.040 --> 03:36.700]  que se gastaron en dos vehículos de alta gama a través del IPAC,
[03:37.440 --> 03:42.460]  que es el Instituto Provincial de Asociativismo y Cooperativismo.
[03:42.460 --> 03:48.960]  Se aprobaron la compra de dos vehículos de alta gama por 100 millones de dólares,
[03:49.600 --> 03:52.980]  o sea, más de 99 millones de pesos,
[03:54.120 --> 03:59.780]  y aún así le sigue reclamando al presidente que no hay dinero para seguridad.
[04:01.360 --> 04:02.320]  Es una barbaridad.
[04:02.320 --> 04:09.900]  La verdad que me daría vergüenza como gobernador salir a reclamar algo
[04:09.900 --> 04:12.840]  cuando la despilfarran en lo que se me antoja.
[04:13.600 --> 04:17.540]  El gobernador está priorizando otro tipo de cosas y ni hablar.
[04:18.380 --> 04:20.820]  Bueno, todos sabemos quién trabaja en el IPAC.
[04:22.680 --> 04:27.560]  Una orden del Ministerio de Seguridad de la provincia, a fines de enero,
[04:27.560 --> 04:35.260]  aprueba en el día la compra de 40 autos Fiat Cronos 1.3,
[04:35.500 --> 04:38.220]  autos que generalmente se utilizan para patrulleros.
[04:39.280 --> 04:42.080]  Y el dato perturbador acá es que, bueno,
[04:42.360 --> 04:45.500]  hubo un gasto general de 2.256 millones
[04:45.500 --> 04:50.680]  y el precio de cada vehículo fue facturado por 56 millones.
[04:51.620 --> 04:52.880]  Cada uno de esos autos,
[04:52.880 --> 04:57.760]  si alguno de los concejales quiere entrar e investigar y consulta,
[04:59.000 --> 05:00.760]  sale alrededor de 25 millones.
[05:04.100 --> 05:07.580]  Un poco más del doble lo pagamos los bonaerenses.
[05:09.240 --> 05:13.140]  Me preocupa y me suena a corrupción también.
[05:13.140 --> 05:23.000]  Volviendo un poco para atrás, señora Presidente,
[05:23.060 --> 05:26.360]  la verdad que desde antes de asumir esta banca, siempre lo he dicho,
[05:27.160 --> 05:30.740]  hace tiempo que se viene tratando el tema de los patrulleros,
[05:31.340 --> 05:32.960]  hace tiempo que lo estamos esperando
[05:32.960 --> 05:34.600]  y aún seguimos a la espera.
[05:35.340 --> 05:38.500]  Hace cinco años que gobierna Kicillof en la provincia
[05:38.500 --> 05:42.980]  y hoy salimos con que la culpa tiene Milei.
[05:45.700 --> 05:47.100]  También, me lo pregunto, ¿no?
[05:47.100 --> 05:50.000]  Lo pregunto al bloque del kirchnerismo.
[05:51.460 --> 05:52.140]  El presidente,
[05:53.720 --> 05:56.600]  la verdad que no sé qué respuesta le podrá dar.
[05:57.640 --> 06:00.860]  Creo que gran parte de las respuestas se las estoy dando yo ahora.
[06:00.860 --> 06:04.620]  La provincia sigue siendo un baño de sangre,
[06:05.420 --> 06:07.220]  el gobernador patea la pelota,
[06:07.780 --> 06:08.680]  no se hace cargo,
[06:09.620 --> 06:11.960]  las prioridades parecieran no ser la seguridad.
[06:14.100 --> 06:15.460]  Y a mí, la verdad que me...
[06:15.460 --> 06:17.180]  Yo le hago la pregunta, señora Presidente,
[06:17.220 --> 06:18.440]  ¿no se le cae la cara de vergüenza?
[06:20.960 --> 06:22.700]  Pregunto, ¿no se le caen las caras de vergüenza?
[06:24.060 --> 06:25.700]  El kirchnerismo siempre puso
[06:25.700 --> 06:29.260]  a los delincuentes del lado de la víctima.
[06:29.260 --> 06:32.020]  Siempre, continuamente.
[06:32.980 --> 06:34.620]  ¿Hasta cuándo vamos a seguir aplicando
[06:34.620 --> 06:36.720]  estas políticas blandas contra los delincuentes?
[06:37.780 --> 06:38.440]  O mejor dicho,
[06:38.540 --> 06:40.640]  ni siquiera aplicando ningún tipo de política
[06:40.640 --> 06:44.020]  de seguridad fuerte en la provincia de Buenos Aires.
[06:46.100 --> 06:47.800]  Hoy una acuesta arrojó
[06:47.800 --> 06:49.840]  que el 39% de los bonaerenses
[06:49.840 --> 06:51.800]  está preocupado principalmente
[06:51.800 --> 06:54.020]  por la inseguridad de la provincia.
[06:55.640 --> 06:57.640]  No me quiero por ahí poner a detallar
[06:57.640 --> 06:59.280]  todos los casos de inseguridad que hay.
[06:59.460 --> 07:00.240]  Inclusive lo hubo,
[07:00.320 --> 07:02.780]  que si en un momento fue la ciudad más segura.
[07:03.600 --> 07:04.220]  Hoy ya no lo es.
[07:07.940 --> 07:09.620]  Políticas de seguridad, nada.
[07:10.740 --> 07:12.080]  La verdad que, vuelvo a remarcar,
[07:12.140 --> 07:13.320]  las prioridades del Gobernador,
[07:14.640 --> 07:16.180]  cosa que para los lobenes,
[07:16.280 --> 07:17.680]  para los bonaerenses y los argentinos,
[07:18.420 --> 07:20.160]  en seguridad, no lo son.
[07:20.160 --> 07:22.160]  Y voy cerrando, señora Presidente.
[07:23.800 --> 07:26.060]  Quiero leerle también algunos gastos
[07:26.060 --> 07:28.960]  que el Gobernador aplica como prioridad,
[07:29.160 --> 07:29.840]  como por ejemplo,
[07:31.000 --> 07:33.620]  partidas asignadas al Ministerio de Género y Diversidad
[07:33.620 --> 07:37.940]  por un monto de 16.471 millones.
[07:37.940 --> 07:43.400]  32.180 millones en partidas asignadas
[07:43.400 --> 07:45.400]  al Ministerio de Comunicación Pública.
[07:48.400 --> 07:51.880]  427 millones en producción de festivales musicales.
[07:53.760 --> 07:56.880]  348 millones en producción de festivales de cine.
[07:56.880 --> 08:02.220]  142 millones en asistencias artísticas a municipios.
[08:03.960 --> 08:10.800]  1.995 millones en territorialidad y transversalidad
[08:10.800 --> 08:12.880]  de la perspectiva de género.
[08:14.840 --> 08:15.340]  Prioridad.
[08:16.180 --> 08:20.900]  5.263 millones en producción de espectáculos
[08:20.900 --> 08:23.140]  en teatros y organismos artísticos.
[08:23.140 --> 08:27.720]  413 millones en comunicación inclusiva.
[08:30.720 --> 08:36.500]  177 millones en masculinidades para la igualdad.
[08:38.600 --> 08:40.340]  Nada más, señor Presidente.
[08:41.420 --> 08:42.980]  La verdad que para cerrar,
[08:44.800 --> 08:47.100]  lo único que hay que decir es que son unos caraduras.
[08:48.840 --> 08:49.620]  Daría vergüenza.
[08:50.560 --> 08:51.460]  Así que, señor Presidente,
[08:51.460 --> 08:53.720]  lo vamos a mandar a comisión para trabajarlo.
[08:54.480 --> 08:56.220]  Lo vamos a mandar a comisión para trabajarlo.
[08:57.300 --> 08:59.120]  Pero, nada, finalizo.
[08:59.500 --> 09:00.400]  Muchas gracias, señora Presidente.
[09:00.400 --> 09:04.080]  Queda aprobado por los días el paso del expediente del 20-25
[09:04.080 --> 09:05.420]  a la profesora de legislación.
[09:07.340 --> 09:09.060]  Solamente le consulto a los señores Concejales,
[09:09.240 --> 09:14.060]  si quieren hacer el expediente del 20-25
[09:14.060 --> 09:15.340]  o seguimos con el debate.
[09:15.700 --> 09:16.340]  Seguimos con el debate.$$);
