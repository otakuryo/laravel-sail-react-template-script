#!/bin/bash

# Script para crear un proyecto Laravel 12 con Docker y Sail
# Autor: Script generado para desarrollo Laravel
# Uso: ./create-proyect-laravel.sh <nombre-del-proyecto>

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

info_continue() {
    echo "Continuando..."
    # read -p "¿Deseas continuar? (y/n): " continue
    # if [ "$continue" != "y" ]; then
    #     log_error "Proceso cancelado"
    #     exit 1
    # fi
}

# Verificar que se proporcionó el nombre del proyecto
if [ -z "$1" ]; then
    log_error "Debes proporcionar el nombre del proyecto"
    echo "Uso: $0 <nombre-del-proyecto>"
    exit 1
fi

PROJECT_NAME=$1

# Verificar que Docker está instalado
if ! command -v docker &> /dev/null; then
    log_error "Docker no está instalado. Por favor, instala Docker primero."
    exit 1
fi

# Verificar que Docker Compose está instalado
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    log_error "Docker Compose no está instalado. Por favor, instala Docker Compose primero."
    exit 1
fi

# Verificar que el directorio no existe
if [ -d "$PROJECT_NAME" ]; then
    log_error "El directorio '$PROJECT_NAME' ya existe."
    exit 1
fi

log_info "Creando proyecto Laravel 12: $PROJECT_NAME"

# Paso 1: Instalar Laravel Installer globalmente en contenedor
log_info "Paso 1/9: Preparando Laravel Installer..."
docker run --rm \
    -v "$(pwd):/app" \
    -u "$(id -u):$(id -g)" \
    composer:latest \
    global require laravel/installer

# Paso 2: Crear el proyecto Laravel con el starter kit de React
log_info "Paso 2/9: Creando proyecto Laravel 12 con React 19, TypeScript y shadcn/ui..."
log_info "Este proceso puede tardar varios minutos..."

# Crear el proyecto base primero
docker run --rm \
    -v "$(pwd):/app" \
    -u "$(id -u):$(id -g)" \
    composer:latest \
    create-project laravel/laravel "$PROJECT_NAME" --prefer-dist

# Verificar que el proyecto se creó correctamente
if [ ! -d "$PROJECT_NAME" ]; then
    log_error "Error al crear el proyecto Laravel"
    exit 1
fi

cd "$PROJECT_NAME"

log_info "Proyecto Laravel base creado exitosamente"

info_continue

# Paso 3: Instalar Laravel Sail
log_info "Paso 3/9: Instalando Laravel Sail..."
docker run --rm \
    -v "$(pwd):/app" \
    -w /app \
    -u "$(id -u):$(id -g)" \
    composer:latest \
    require laravel/sail --dev

info_continue

# Preguntar qué servicios instalar
log_info "Servicios disponibles para Sail: mysql, pgsql, mariadb, redis, memcached, meilisearch, typesense, minio, mailpit, selenium"
log_warning "Por defecto se instalarán: mysql, redis"
read -p "¿Deseas agregar servicios adicionales? (deja vacío para usar los predeterminados): " additional_services

if [ -z "$additional_services" ]; then
    SERVICES="mysql,redis"
else
    SERVICES="mysql,redis,$additional_services"
fi

info_continue

# Paso 4: Publicar configuración de Sail
log_info "Paso 4/9: Publicando configuración de Sail con servicios: $SERVICES..."
docker run --rm \
    -v "$(pwd):/app" \
    -w /app \
    -u "$(id -u):$(id -g)" \
    laravelsail/php84-composer:latest \
    php artisan sail:install --with=$SERVICES

info_continue

# Paso 5: Configurar permisos y levantar Sail
log_info "Paso 5/9: Configurando permisos de Sail..."
chmod +x ./vendor/bin/sail

log_info "Levantando contenedores de Sail..."
log_info "Este proceso puede tardar unos minutos mientras se descargan las imágenes Docker..."

./vendor/bin/sail up -d

log_info "Esperando a que los contenedores estén listos..."
sleep 15

log_info "Revisa si los contenedores están levantados con el comando: docker ps"
docker ps

echo ""
read -p "¿Los contenedores de Sail se levantaron correctamente? (y/n): " sail_ready
if [ "$sail_ready" != "y" ]; then
    log_error "Los contenedores no se levantaron correctamente. Revisa los logs con: ./vendor/bin/sail logs"
    exit 1
fi

log_info "✅ Sail levantado correctamente. Continuando con las instalaciones usando Sail..."

info_continue

# Paso 6: Instalar Laravel Breeze con React
log_info "Paso 6/9: Instalando Laravel Breeze con stack de React..."
./vendor/bin/sail composer require laravel/breeze --dev

info_continue

# Instalar Breeze con React stack (incluye React 19, TypeScript, Tailwind, shadcn/ui)
log_info "Configurando React 19, TypeScript, Tailwind, shadcn/ui y ESLint..."
./vendor/bin/sail artisan breeze:install react --typescript --dark --eslint

# Ajustando node typing para compatibilidad con Vite 7
log_info "Ajustando @types/node para compatibilidad con Vite 7..."
./vendor/bin/sail npm i -D @types/node@22.12.0

# Instalando dependencias de Node
log_info "Instalando dependencias de Node.js..."
./vendor/bin/sail npm install

log_info "✅ Starter kit de React instalado: React 19 + TypeScript + Tailwind + shadcn/ui + ESLint"

info_continue

# Paso 7: Instalar Laravel Passport para API
log_info "Paso 7/9: Instalando Laravel Passport para soporte de API..."
./vendor/bin/sail composer require laravel/passport

info_continue

# Ejecutar comando install:api con Passport
log_info "Configurando Passport (migraciones y keys)..."
./vendor/bin/sail artisan install:api --passport

log_warning "⚠️  IMPORTANTE: install:api --passport ya ejecutó las migraciones de OAuth"
log_warning "Si más tarde ejecutas 'migrate' y obtienes error de tablas duplicadas,"
log_warning "necesitarás limpiar la base de datos manualmente (ver instrucciones al final)"

log_info "✅ Laravel Passport instalado y configurado"

info_continue

# Paso 8: Instalar SASS
log_info "Paso 8/9: Instalando SASS para estilos avanzados..."
./vendor/bin/sail npm install --save-dev sass@latest

log_info "✅ SASS instalado y listo para usar"

info_continue

# Paso 9: Detener Sail y crear alias
log_info "Paso 9/9: Deteniendo contenedores de Sail..."
./vendor/bin/sail down

log_info "Creando script alias para Sail..."
# Crear alias en el script
cat > sail.sh << 'EOF'
#!/bin/bash
./vendor/bin/sail "$@"
EOF

chmod +x sail.sh

log_info "✅ Alias de Sail creado: ./sail.sh"

log_info "============================================"
log_info "¡Proyecto Laravel 12 creado exitosamente!"
log_info "============================================"
echo ""
log_info "Stack tecnológico instalado:"
echo "  ✅ Laravel 12"
echo "  ✅ React 19 con TypeScript"
echo "  ✅ Inertia.js 2"
echo "  ✅ Tailwind CSS 4"
echo "  ✅ SASS (para estilos avanzados)"
echo "  ✅ shadcn/ui (componentes modernos)"
echo "  ✅ Laravel Breeze (autenticación web)"
echo "  ✅ Laravel Passport (OAuth2 API)"
echo "  ✅ Laravel Sail (Docker)"
echo ""
log_info "Servicios Docker configurados:"
echo "  🐳 $SERVICES"
echo ""
log_info "Próximos pasos:"
echo ""
echo "1. Navega al directorio del proyecto:"
echo "   cd $PROJECT_NAME"
echo ""
echo "2. Inicia los contenedores de Sail:"
echo "   ./vendor/bin/sail up -d"
echo "   o usa el alias: ./sail.sh up -d"
echo ""
echo "3. Compila los assets del frontend (desarrollo):"
echo "   ./vendor/bin/sail npm run dev"
echo "   Para producción: ./vendor/bin/sail npm run build"
echo ""
echo "4. Ejecuta las migraciones (si es necesario):"
echo "   ⚠️  NOTA: Las migraciones de OAuth ya fueron ejecutadas por install:api"
echo "   ./vendor/bin/sail artisan migrate:status  (verifica el estado)"
echo "   ./vendor/bin/sail artisan migrate  (solo si hay pendientes)"
echo ""
echo "5. (Opcional) Compila los assets y ejecuta migraciones en un paso:"
echo "   ./vendor/bin/sail npm run build && ./vendor/bin/sail artisan migrate"
echo ""
echo "6. Accede a tu aplicación en:"
echo "   http://localhost"
echo ""
log_warning "Nota: Asegúrate de configurar el archivo .env con tus variables de entorno"
log_info "🎉 Tu aplicación Laravel con React está lista para empezar a desarrollar"
echo ""
log_info "✅ Las dependencias de Node.js ya están instaladas"
log_info "✅ SASS está configurado y listo para usar"
log_info "✅ @types/node actualizado para compatibilidad con Vite 7"
echo ""
log_info "Rutas de autenticación web disponibles:"
echo "  • /login - Iniciar sesión"
echo "  • /register - Registro de usuarios"
echo "  • /forgot-password - Recuperar contraseña"
echo "  • /dashboard - Panel de usuario (requiere autenticación)"
echo ""
log_info "📡 Configuración de API con Passport:"
echo ""
echo "1. Agrega los traits a tu modelo User (app/Models/User.php):"
echo "   use Laravel\Passport\HasApiTokens;"
echo "   use Laravel\Passport\Contracts\OAuthenticatable;"
echo "   class User extends Authenticatable implements OAuthenticatable"
echo ""
echo "2. Las rutas API están en routes/api.php"
echo "   Protege rutas con middleware: Route::middleware('auth:api')"
echo ""
echo "3. Crear cliente OAuth2:"
echo "   ./vendor/bin/sail artisan passport:client"
echo ""
echo "4. Endpoints de Passport disponibles en:"
echo "   POST /oauth/token - Obtener access token"
echo "   GET  /oauth/tokens - Listar tokens del usuario"
echo "   DELETE /oauth/tokens/{token-id} - Revocar token"
echo ""
log_warning "🔧 SOLUCIÓN A ERRORES DE MIGRACIÓN DUPLICADA:"
echo ""
echo "Si obtienes error 'Base table or view already exists' al ejecutar migrate:"
echo ""
echo "OPCIÓN 1 - Limpiar y recrear toda la base de datos (⚠️ ELIMINA TODOS LOS DATOS):"
echo "   ./vendor/bin/sail artisan migrate:fresh"
echo ""
echo "OPCIÓN 2 - Limpiar solo las tablas OAuth manualmente:"
echo "   ./vendor/bin/sail artisan tinker"
echo "   Luego ejecuta en tinker:"
echo "   Schema::dropIfExists('oauth_auth_codes');"
echo "   Schema::dropIfExists('oauth_access_tokens');"
echo "   Schema::dropIfExists('oauth_refresh_tokens');"
echo "   Schema::dropIfExists('oauth_clients');"
echo "   Schema::dropIfExists('oauth_device_codes');"
echo "   exit"
echo "   ./vendor/bin/sail artisan migrate"
echo ""
echo "OPCIÓN 3 - Si usas MySQL (Docker), reiniciar completamente la base de datos:"
echo "   ./vendor/bin/sail down -v  (elimina volúmenes de Docker)"
echo "   ./vendor/bin/sail up -d"
echo "   ./vendor/bin/sail artisan migrate:fresh"
echo ""
echo "OPCIÓN 4 - Si usas SQLite, eliminar el archivo de base de datos:"
echo "   rm database/database.sqlite"
echo "   touch database/database.sqlite"
echo "   ./vendor/bin/sail artisan migrate"
echo ""
log_info "💡 CAUSA: El comando 'install:api --passport' ejecuta automáticamente"
log_info "   las migraciones de OAuth. Si intentas ejecutar 'migrate' después,"
log_info "   Laravel intentará crear las tablas de nuevo y fallará."
echo ""

