FROM mysql:8.0

# Set default credentials
ENV MYSQL_ROOT_PASSWORD=kvkart_root
ENV MYSQL_DATABASE=kvkart
ENV MYSQL_USER=diya
ENV MYSQL_PASSWORD=diya_password

# Copy schema first, then seed files in order
# MySQL runs files in /docker-entrypoint-initdb.d/ alphabetically on FIRST run only
# These are IGNORED if the data volume already has an initialized DB
COPY 01_schema.sql               /docker-entrypoint-initdb.d/01_schema.sql
COPY 02_seed_users.sql           /docker-entrypoint-initdb.d/02_seed_users.sql
COPY 03_seed_catalog.sql         /docker-entrypoint-initdb.d/03_seed_catalog.sql
COPY 04_seed_orders.sql          /docker-entrypoint-initdb.d/04_seed_orders.sql
COPY 05_seed_logistics.sql       /docker-entrypoint-initdb.d/05_seed_logistics.sql
COPY 06_seed_returns_refunds.sql /docker-entrypoint-initdb.d/06_seed_returns_refunds.sql
COPY 07_seed_payments.sql        /docker-entrypoint-initdb.d/07_seed_payments.sql
COPY 08_seed_promotions.sql      /docker-entrypoint-initdb.d/08_seed_promotions.sql
COPY 09_seed_policies.sql        /docker-entrypoint-initdb.d/09_seed_policies.sql
COPY 10_seed_support.sql         /docker-entrypoint-initdb.d/10_seed_support.sql
COPY 11_seed_engagement.sql      /docker-entrypoint-initdb.d/11_seed_engagement.sql

# Grant diya user full access to kvkart DB
COPY 99_grant_permissions.sql    /docker-entrypoint-initdb.d/99_grant_permissions.sql
