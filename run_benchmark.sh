#!/bin/bash
set -e

# Desactivar DOCKER_HOST para evitar conflictos
unset DOCKER_HOST

echo "Iniciando Docker daemon..."
/usr/local/bin/dockerd-entrypoint.sh dockerd > /tmp/dockerd.log 2>&1 &

echo "Esperando a que Docker daemon esté listo..."
while ! docker info > /dev/null 2>&1; do
    sleep 1
done
echo "Docker daemon listo."

# Directorio para guardar resultados (montado desde el host)
OUTPUT_DIR="/benchmark_output"
CSV_FILE="${OUTPUT_DIR}/results.csv"

# URL del repositorio de soluciones (reemplaza con la URL real)
REPO_URL="https://github.com/flaviofuego/benchmark-solutions.git"
LOCAL_REPO_DIR="/benchmark/benchmark-solutions"

mkdir -p ${OUTPUT_DIR}

if [ ! -d "${LOCAL_REPO_DIR}" ]; then
    echo "Clonando repositorio de soluciones..."
    git clone ${REPO_URL} ${LOCAL_REPO_DIR}
else
    echo "Repositorio ya clonado."
fi

# Inicializar el CSV con encabezado
echo "Lenguaje,Tiempo(ms)" > ${CSV_FILE}

languages=("python" "java" "cpp" "javascript" "go")

for lang in "${languages[@]}"
do
    echo "Procesando ${lang}..."
    LANG_DIR="${LOCAL_REPO_DIR}/${lang}"
    IMAGE_NAME="solution-${lang}"
    
    # Construir la imagen de la solución
    docker build -t ${IMAGE_NAME} ${LANG_DIR}
    
    # Ejecutar el contenedor y capturar el output
    TIME_OUTPUT=$(docker run --rm -v ${OUTPUT_DIR}:/output ${IMAGE_NAME})
    
    # Depurar: imprimir el output capturado
    echo "Output for ${lang}: '${TIME_OUTPUT}'"
    
    if [ -z "$TIME_OUTPUT" ]; then
        echo "Advertencia: No se recibió tiempo de ejecución para ${lang}"
    fi
    
    # Registrar en el CSV
    echo "${lang},${TIME_OUTPUT}" >> ${CSV_FILE}
    echo "Resultado ${lang}: ${TIME_OUTPUT} ms"
done

echo "Benchmark completado. Resultados en ${CSV_FILE}"
cat ${CSV_FILE}
