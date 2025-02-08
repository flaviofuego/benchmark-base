#!/bin/bash
set -e

# Desactivar DOCKER_HOST para que el daemon se comunique localmente
unset DOCKER_HOST

# Iniciar el daemon de Docker en segundo plano
echo "Iniciando Docker daemon..."
/usr/local/bin/dockerd-entrypoint.sh dockerd > /tmp/dockerd.log 2>&1 &

# Esperar a que el daemon Docker esté listo
echo "Esperando a que Docker daemon esté listo..."
while ! docker info > /dev/null 2>&1; do
    sleep 1
done
echo "Docker daemon listo."

# Directorio para guardar resultados (se mapea desde el host)
OUTPUT_DIR="/benchmark_output"
CSV_FILE="${OUTPUT_DIR}/results.csv"

# URL del repositorio de soluciones (reemplazar por la URL real)
REPO_URL="https://github.com/flaviofuego/benchmark-solutions.git"
LOCAL_REPO_DIR="/benchmark/benchmark-solutions"

# Crear el directorio de salida si no existe
mkdir -p ${OUTPUT_DIR}

# Clonar el repositorio de soluciones si aún no está clonado
if [ ! -d "${LOCAL_REPO_DIR}" ]; then
    echo "Clonando repositorio de soluciones..."
    git clone ${REPO_URL} ${LOCAL_REPO_DIR}
else
    echo "Repositorio ya clonado."
fi

# Inicializar el archivo CSV con encabezado
echo "Lenguaje,Tiempo(ms)" > ${CSV_FILE}

# Lista de lenguajes a procesar
languages=("python" "java" "cpp" "javascript" "go")

# Procesar cada carpeta de solución
for lang in "${languages[@]}"
do
    echo "Procesando ${lang}..."
    LANG_DIR="${LOCAL_REPO_DIR}/${lang}"
    IMAGE_NAME="solution-${lang}"
    
    # Construir la imagen Docker para la solución en el lenguaje correspondiente
    docker build -t ${IMAGE_NAME} ${LANG_DIR}
    
    # Ejecutar el contenedor montando el directorio de salida y capturar el tiempo de ejecución (ms)
    TIME_OUTPUT=$(docker run --rm -v ${OUTPUT_DIR}:/output ${IMAGE_NAME})
    
    # Registrar el resultado en el archivo CSV
    echo "${lang},${TIME_OUTPUT}" >> ${CSV_FILE}
    
    echo "Resultado ${lang}: ${TIME_OUTPUT} ms"
done

echo "Benchmark completado. Resultados en ${CSV_FILE}"
