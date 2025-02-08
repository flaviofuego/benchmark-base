# Benchmark de Soluciones en Contenedores

## Descripción

Este proyecto ejecuta un benchmark de soluciones implementadas en varios lenguajes para calcular el 12th tipos de parentizaciones generadas por los numeros de catalan. Cada solución se ejecuta en su contenedor y se mide el tiempo de ejecución (en milisegundos). Los resultados se registran en un archivo CSV.

## Requisitos

- Docker
- Docker Compose

## Uso

Para ejecutar el benchmark, sigue estos pasos:

1. Clona este repositorio:

    ```sh
    git clone https://github.com/flaviofuego/benchmark-base.git
    cd benchmark-base
    ```

2. Construye y ejecuta los contenedores usando Docker Compose:

    ```sh
    docker-compose up --build
    ```

3. Los resultados del benchmark se guardarán en el archivo `benchmark-base/results.csv`.

## Resultados

Los resultados del benchmark se registran en el archivo `results.csv` en el siguiente formato:

```txt
Lenguaje,Tiempo(ms)
python,123
java,456
cpp,789
javascript,101
go,112
```

## Licencia

Este proyecto está licenciado bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

Para ejecutar todo el proyecto, usa el siguiente comando en la raíz del proyecto:

```sh
docker-compose up --build
```
