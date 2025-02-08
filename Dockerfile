FROM docker:dind

# Instalar git y bash (docker:dind se basa en Alpine)
RUN apk update && apk add git bash

WORKDIR /benchmark

# Copiar el script de ejecución
COPY run_benchmark.sh /benchmark/run_benchmark.sh
RUN chmod +x /benchmark/run_benchmark.sh

CMD ["/benchmark/run_benchmark.sh"]
