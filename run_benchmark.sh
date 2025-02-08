#!/bin/bash
set -e

# Esperar a que el daemon Docker esté listo
echo "Esperando a que el daemon Docker esté listo..."
until docker info > /dev/null 2>&1; do
    sleep 1
done
echo "Docker daemon listo."

# Directorio donde se guardarán los resultados (se mapea desde el host)
OUTPUT_DIR="/benchmark_output"
CSV_FILE="${OUTPUT_DIR}/results.csv"

# URL del repositorio de soluciones (reemplaza con la URL real)
REPO_URL="https://github.com/flaviofuego/benchmark-solutions.git"
LOCAL_REPO_DIR="/benchmark/benchmark-solutions"

# Crear el directorio de salida
mkdir -p ${OUTPUT_DIR}

# Clonar el repositorio (si aún no existe)
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
    
    # Construir la imagen Docker para el lenguaje
    docker build -t ${IMAGE_NAME} ${LANG_DIR}
    
    # Ejecutar el contenedor montando el directorio de salida
    # Se captura la salida que contiene el tiempo de ejecución (en ms)
    TIME_OUTPUT=$(docker run --rm -v ${OUTPUT_DIR}:/output ${IMAGE_NAME})
    
    # Registrar el resultado en el archivo CSV
    echo "${lang},${TIME_OUTPUT}" >> ${CSV_FILE}
    
    echo "Resultado ${lang}: ${TIME_OUTPUT} ms"
done

echo "Benchmark completado. Resultados en ${CSV_FILE}"
