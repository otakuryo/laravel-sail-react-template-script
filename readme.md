# Proyecto para levantar un proyecto de Laravel 12 con Docker

Este proyecto es una plantilla automatizada para crear y levantar un proyecto de Laravel 12 con Docker usando Laravel Sail y el stack moderno de React.

## Características

- ✅ Crea un proyecto Laravel 12 completamente funcional
- ✅ Usa la imagen oficial de Composer para la instalación
- ✅ **React 19** con TypeScript como frontend
- ✅ **Inertia.js 2** para SPA sin API
- ✅ **Tailwind CSS 4** para estilos modernos
- ✅ **SASS** preinstalado para estilos avanzados
- ✅ **shadcn/ui** para componentes de UI de alta calidad
- ✅ **Laravel Breeze** con autenticación web completa
- ✅ **Laravel Passport** para API OAuth2
- ✅ Instala y configura Laravel Sail automáticamente
- ✅ Configuración flexible de servicios Docker
- ✅ El proyecto se crea en el directorio actual con el nombre especificado

## Requisitos

- Docker
- Docker Compose

## Instalación

1. Clonar el repositorio:
```bash
git clone <url-del-repositorio>
cd laravel
```

2. Dar permisos de ejecución al script:
```bash
chmod +x create-proyect-laravel.sh
```

3. Ejecutar el script con el nombre de tu proyecto:
```bash
./create-proyect-laravel.sh mi-proyecto-laravel
```

4. (Opcional) Revisa los archivos de ejemplos:
   - `EJEMPLO_COMPONENTE.md` - Ejemplos de código React con shadcn/ui
   - `EJEMPLO_API_PASSPORT.md` - Ejemplos de API REST con Laravel Passport

## Uso

Una vez creado el proyecto, sigue estos pasos:

> **Nota:** El script ya instaló automáticamente las dependencias de Node.js, SASS y actualizó los paquetes necesarios durante la creación del proyecto.

1. **Navegar al directorio del proyecto:**
```bash
cd mi-proyecto-laravel
```

2. **Iniciar los contenedores de Sail:**
```bash
./vendor/bin/sail up -d
# o usando el alias
./sail.sh up -d
```

3. **Compilar assets del frontend:**
```bash
./vendor/bin/sail npm run dev
```

4. **Ejecutar migraciones de base de datos:**
```bash
./vendor/bin/sail artisan migrate
```

5. **Acceder a la aplicación:**
   - Aplicación: http://localhost
   - Mailpit (email testing): http://localhost:8025
   - Meilisearch: http://localhost:7700 (si fue instalado)

## Stack Tecnológico

El proyecto se crea con el siguiente stack moderno:

### Frontend
- **React 19** - Framework de UI más reciente
- **TypeScript** - Tipado estático para JavaScript
- **Inertia.js 2** - Para crear SPAs sin necesidad de API
- **Tailwind CSS 4** - Framework CSS utility-first
- **SASS/SCSS** - Preprocesador CSS para estilos avanzados
- **shadcn/ui** - Biblioteca de componentes accesibles y modernos
- **Vite** - Build tool ultra rápido

### Backend
- **Laravel 12** - Framework PHP más moderno
- **Laravel Breeze** - Starter kit con autenticación web completa
- **Laravel Passport** - OAuth2 server para APIs
- **Laravel Sail** - Entorno Docker configurado

### Servicios Docker

Por defecto se instalan:
- **MySQL 8.0** - Base de datos
- **Redis** - Cache y sesiones

Servicios opcionales disponibles:
- **PostgreSQL** - Base de datos alternativa
- **MariaDB** - Base de datos alternativa
- **Memcached** - Cache alternativo
- **Meilisearch** - Motor de búsqueda
- **Typesense** - Motor de búsqueda alternativo
- **MinIO** - Almacenamiento de objetos S3-compatible
- **Mailpit** - Testing de emails
- **Selenium** - Testing de navegador

## Autenticación

### Autenticación Web con Laravel Breeze

El proyecto incluye autenticación completa lista para usar:

- ✅ Login con email y contraseña
- ✅ Registro de nuevos usuarios
- ✅ Recuperación de contraseña
- ✅ Verificación de email (opcional)
- ✅ Autenticación de dos factores (2FA) disponible
- ✅ Gestión de perfil de usuario
- ✅ Interfaz moderna con React y shadcn/ui

### API OAuth2 con Laravel Passport

El proyecto incluye Laravel Passport preconfigurado para APIs:

- 🔐 OAuth2 server completo
- 🔐 Personal access tokens
- 🔐 Password grant tokens
- 🔐 Client credentials grant
- 🔐 Authorization code grant con PKCE

#### Configurar Passport en el modelo User

Agrega los traits en `app/Models/User.php`:

```php
use Laravel\Passport\HasApiTokens;
use Laravel\Passport\Contracts\OAuthenticatable;

class User extends Authenticatable implements OAuthenticatable
{
    use HasApiTokens, HasFactory, Notifiable;
    // ...
}
```

#### Crear un cliente OAuth2

```bash
./vendor/bin/sail artisan passport:client
```

#### Proteger rutas API

En `routes/api.php`:

```php
Route::middleware('auth:api')->get('/user', function (Request $request) {
    return $request->user();
});
```

#### Endpoints de Passport disponibles

- `POST /oauth/token` - Obtener access token
- `GET /oauth/tokens` - Listar tokens del usuario autenticado
- `DELETE /oauth/tokens/{token-id}` - Revocar token específico
- `GET /oauth/clients` - Listar clientes OAuth2
- `POST /oauth/clients` - Crear nuevo cliente

#### Obtener un access token

```bash
curl -X POST http://localhost/oauth/token \
  -H "Content-Type: application/json" \
  -d '{
    "grant_type": "password",
    "client_id": "your-client-id",
    "client_secret": "your-client-secret",
    "username": "user@example.com",
    "password": "password",
    "scope": ""
  }'
```

## Estructura del Proyecto

El proyecto React con Inertia tiene la siguiente estructura:

```
resources/
├── js/
│   ├── components/    # Componentes React reutilizables
│   ├── layouts/       # Layouts de la aplicación
│   ├── pages/         # Páginas/Vistas de Inertia
│   ├── types/         # Definiciones de TypeScript
│   ├── lib/           # Utilidades y helpers
│   └── app.tsx        # Punto de entrada de React
├── css/
│   └── app.css        # Estilos con Tailwind
└── views/
    └── app.blade.php  # Template HTML base
```

## Comandos útiles de Sail

```bash
# Iniciar contenedores
./vendor/bin/sail up -d

# Detener contenedores
./vendor/bin/sail down

# Ver logs
./vendor/bin/sail logs

# Ejecutar comandos Artisan
./vendor/bin/sail artisan <comando>

# Ejecutar comandos Composer
./vendor/bin/sail composer <comando>

# Ejecutar comandos NPM
./vendor/bin/sail npm <comando>

# Compilar assets en modo desarrollo (con hot reload)
./vendor/bin/sail npm run dev

# Compilar assets para producción
./vendor/bin/sail npm run build

# Ejecutar TypeScript type checking
./vendor/bin/sail npm run type-check

# Acceder a la shell del contenedor
./vendor/bin/sail shell

# Ejecutar tests de PHP
./vendor/bin/sail test

# Ejecutar tests de frontend (si están configurados)
./vendor/bin/sail npm run test
```

## Trabajando con SASS/SCSS

El proyecto viene con SASS preinstalado. Puedes usar archivos `.scss` en lugar de `.css`:

### Usar SASS en tu proyecto

1. Renombra `resources/css/app.css` a `resources/css/app.scss`

2. Actualiza la importación en `resources/js/app.tsx`:

```typescript
import '../css/app.scss';
```

3. Crea archivos SASS modulares:

```scss
// resources/css/_variables.scss
$primary-color: #3490dc;
$secondary-color: #6574cd;
$font-stack: 'Inter', sans-serif;

// resources/css/_mixins.scss
@mixin flex-center {
    display: flex;
    justify-content: center;
    align-items: center;
}

// resources/css/app.scss
@import 'variables';
@import 'mixins';

.custom-container {
    @include flex-center;
    background-color: $primary-color;
}
```

4. SASS funciona perfectamente con Tailwind CSS - puedes usar ambos simultáneamente.

## Trabajando con React + Inertia

### Crear una nueva página

1. Crea un componente React en `resources/js/pages/`:

```typescript
// resources/js/pages/MiPagina.tsx
import { Head } from '@inertiajs/react';

export default function MiPagina({ datos }: { datos: string }) {
    return (
        <>
            <Head title="Mi Página" />
            <div>
                <h1>Mi Nueva Página</h1>
                <p>{datos}</p>
            </div>
        </>
    );
}
```

2. Crea una ruta en Laravel:

```php
// routes/web.php
use Inertia\Inertia;

Route::get('/mi-pagina', function () {
    return Inertia::render('MiPagina', [
        'datos' => 'Información del servidor'
    ]);
});
```

### Usar componentes de shadcn/ui

Los componentes de shadcn/ui están pre-instalados. Para agregar más:

```bash
# Ver componentes disponibles
./vendor/bin/sail npm run ui

# Agregar un componente (ej: button, card, dialog)
./vendor/bin/sail npx shadcn@latest add button
```

## Notas importantes

- ✅ Asegúrate de configurar el archivo `.env` con tus variables de entorno específicas
- ✅ El script usa los puertos por defecto de Sail (80, 3306, 6379, etc.)
- ✅ Si ya tienes servicios corriendo en esos puertos, deberás modificar el archivo `docker-compose.yml`
- ✅ Los permisos de archivos se configuran automáticamente con tu usuario actual
- ✅ **Importante**: Siempre ejecuta `npm run dev` antes de acceder a la aplicación para compilar los assets de React
- ✅ Los componentes de shadcn/ui usan Radix UI por debajo, garantizando accesibilidad
- ✅ Inertia.js elimina la necesidad de crear una API REST para tu SPA

## Ventajas de este Stack

### React 19 + Inertia
- ✨ SPA moderna sin necesidad de crear API REST
- ✨ Routing del lado del servidor con Laravel
- ✨ Tipado completo con TypeScript
- ✨ Hot Module Replacement (HMR) para desarrollo rápido
- ✨ SEO-friendly con renderizado del lado del servidor disponible

### shadcn/ui + Tailwind
- 🎨 Componentes modernos y accesibles
- 🎨 Completamente personalizables
- 🎨 No es una librería, copias el código a tu proyecto
- 🎨 Dark mode incluido por defecto
- 🎨 Diseño responsive automático

### Laravel Breeze + Passport
- 🔐 Autenticación web completa lista para producción
- 🔐 OAuth2 server para APIs con Passport
- 🔐 Personal access tokens, password grants, client credentials
- 🔐 Protección contra CSRF automática
- 🔐 Rate limiting configurado
- 🔐 Password hashing seguro con Bcrypt
- 🔐 Scopes para control de acceso granular

### SASS/SCSS
- 💅 Variables, mixins y funciones para estilos reutilizables
- 💅 Nesting de selectores para código más limpio
- 💅 Compatible con Tailwind CSS
- 💅 Compilación automática con Vite
- 💅 Partials para organizar estilos modulares

## Solución de problemas

### Error de permisos
```bash
chmod +x create-proyect-laravel.sh
chmod +x ./vendor/bin/sail
```

### Puerto 80 en uso
Edita `docker-compose.yml` y cambia el mapeo de puertos:
```yaml
ports:
    - '8000:80'
```

### Docker no está corriendo
```bash
# macOS/Linux
sudo systemctl start docker

# o inicia Docker Desktop
```

### Los cambios de React no se reflejan
Asegúrate de que Vite esté corriendo:
```bash
./vendor/bin/sail npm run dev
```

### Error: "Vite manifest not found"
Necesitas compilar los assets primero:
```bash
./vendor/bin/sail npm install
./vendor/bin/sail npm run build
```

### TypeScript arroja errores
Ejecuta el type checking:
```bash
./vendor/bin/sail npm run type-check
```

### Error de compilación de SASS
Asegúrate de que SASS esté instalado:
```bash
./vendor/bin/sail npm install sass --save-dev
```

### Error "Invalid grant" en Passport
Revisa que las credenciales del cliente OAuth2 sean correctas:
```bash
./vendor/bin/sail artisan passport:client --password
```

## Recursos Adicionales

### Documentación Oficial

- 📚 [Laravel 12](https://laravel.com/docs/12.x)
- 📚 [Laravel Breeze](https://laravel.com/docs/12.x/starter-kits)
- 📚 [Laravel Passport](https://laravel.com/docs/12.x/passport)
- 📚 [Laravel Sail](https://laravel.com/docs/12.x/sail)
- 📚 [React 19](https://react.dev/)
- 📚 [Inertia.js](https://inertiajs.com/)
- 📚 [TypeScript](https://www.typescriptlang.org/)
- 📚 [Tailwind CSS](https://tailwindcss.com/)
- 📚 [SASS](https://sass-lang.com/)
- 📚 [shadcn/ui](https://ui.shadcn.com/)

### Tutoriales y Guías

- 🎓 [Inertia.js + React Guide](https://inertiajs.com/client-side-setup)
- 🎓 [shadcn/ui Components](https://ui.shadcn.com/docs/components)
- 🎓 [Laravel Breeze Starter Kit](https://laravel.com/docs/12.x/starter-kits#breeze-and-inertia)

### Comunidad

- 💬 [Laravel Discord](https://discord.gg/laravel)
- 💬 [Laravel Forums](https://laracasts.com/discuss)
- 💬 [Inertia.js Discord](https://discord.gg/inertiajs)

## Contribuciones

Las contribuciones son bienvenidas. Por favor, abre un issue o pull request para cualquier mejora.

---

**⚡ Desarrollado con el stack más moderno de Laravel 12 + React 19**