FROM mysql:8-oracle

RUN echo 'sql-mode="STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"' >> /etc/mysql/conf.d/docker.cnf
RUN echo 'information_schema_stats_expiry=0' >> /etc/mysql/conf.d/docker.cnf
