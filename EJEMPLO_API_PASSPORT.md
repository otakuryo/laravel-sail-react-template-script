# Ejemplos de API con Laravel Passport

Guía práctica para usar Laravel Passport en tu proyecto.

## Configuración Inicial

### 1. Actualizar el modelo User

```php
// app/Models/User.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Passport\HasApiTokens;
use Laravel\Passport\Contracts\OAuthenticatable;

class User extends Authenticatable implements OAuthenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }
}
```

### 2. Crear Cliente OAuth2

```bash
# Cliente para password grant
./vendor/bin/sail artisan passport:client --password

# Cliente para personal access
./vendor/bin/sail artisan passport:client --personal

# Cliente para authorization code
./vendor/bin/sail artisan passport:client
```

## Rutas de API

### Estructura básica en routes/api.php

```php
// routes/api.php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\{
    AuthController,
    UserController,
    ProductController
};

// Rutas públicas
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Rutas protegidas con Passport
Route::middleware('auth:api')->group(function () {
    // Usuario autenticado
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Recursos protegidos
    Route::apiResource('products', ProductController::class);
    Route::get('/profile', [UserController::class, 'profile']);
    Route::put('/profile', [UserController::class, 'updateProfile']);
});

// Rutas con scopes específicos
Route::middleware(['auth:api', 'scope:admin'])->group(function () {
    Route::get('/admin/users', [UserController::class, 'index']);
    Route::delete('/admin/users/{user}', [UserController::class, 'destroy']);
});
```

## Controladores de API

### AuthController

```php
// app/Http/Controllers/Api/AuthController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Registro de usuario
     */
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);

        $token = $user->createToken('auth_token')->accessToken;

        return response()->json([
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ], 201);
    }

    /**
     * Login de usuario
     */
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Las credenciales proporcionadas son incorrectas.'],
            ]);
        }

        $token = $user->createToken('auth_token')->accessToken;

        return response()->json([
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }

    /**
     * Obtener usuario autenticado
     */
    public function user(Request $request)
    {
        return response()->json($request->user());
    }

    /**
     * Logout
     */
    public function logout(Request $request)
    {
        $request->user()->token()->revoke();

        return response()->json([
            'message' => 'Sesión cerrada exitosamente'
        ]);
    }
}
```

### ProductController (CRUD Completo)

```php
// app/Http/Controllers/Api/ProductController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    /**
     * Listar todos los productos
     */
    public function index()
    {
        $products = Product::paginate(15);
        
        return response()->json($products);
    }

    /**
     * Crear producto
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
        ]);

        $product = Product::create($validated);

        return response()->json($product, 201);
    }

    /**
     * Mostrar un producto
     */
    public function show(Product $product)
    {
        return response()->json($product);
    }

    /**
     * Actualizar producto
     */
    public function update(Request $request, Product $product)
    {
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'price' => 'sometimes|required|numeric|min:0',
            'stock' => 'sometimes|required|integer|min:0',
        ]);

        $product->update($validated);

        return response()->json($product);
    }

    /**
     * Eliminar producto
     */
    public function destroy(Product $product)
    {
        $product->delete();

        return response()->json([
            'message' => 'Producto eliminado exitosamente'
        ]);
    }
}
```

## Uso de Scopes

### Definir Scopes

```php
// app/Providers/AppServiceProvider.php
use Laravel\Passport\Passport;

public function boot(): void
{
    Passport::tokensCan([
        'admin' => 'Acceso administrativo completo',
        'user' => 'Acceso de usuario estándar',
        'products:read' => 'Ver productos',
        'products:create' => 'Crear productos',
        'products:update' => 'Actualizar productos',
        'products:delete' => 'Eliminar productos',
    ]);

    Passport::setDefaultScope([
        'user',
    ]);
}
```

### Verificar Scopes en Controladores

```php
public function index(Request $request)
{
    if ($request->user()->tokenCan('products:read')) {
        return Product::all();
    }

    return response()->json(['error' => 'No autorizado'], 403);
}
```

### Middleware de Scopes

```php
// Usar en rutas
Route::middleware(['auth:api', 'scope:products:create'])
    ->post('/products', [ProductController::class, 'store']);

Route::middleware(['auth:api', 'scopes:products:read,products:update'])
    ->get('/products/advanced', [ProductController::class, 'advanced']);
```

## Resource Classes para Respuestas

```php
// app/Http/Resources/UserResource.php
<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'created_at' => $this->created_at->toDateTimeString(),
            'updated_at' => $this->updated_at->toDateTimeString(),
        ];
    }
}
```

Usar en controlador:

```php
use App\Http\Resources\UserResource;

public function user(Request $request)
{
    return new UserResource($request->user());
}
```

## Ejemplos de Peticiones con cURL

### Registro

```bash
curl -X POST http://localhost/api/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Juan Pérez",
    "email": "juan@example.com",
    "password": "password123",
    "password_confirmation": "password123"
  }'
```

### Login

```bash
curl -X POST http://localhost/api/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "juan@example.com",
    "password": "password123"
  }'
```

### Obtener Usuario Autenticado

```bash
curl -X GET http://localhost/api/user \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Crear Producto

```bash
curl -X POST http://localhost/api/products \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "name": "Laptop Dell",
    "description": "Laptop para desarrollo",
    "price": 999.99,
    "stock": 10
  }'
```

### Listar Productos

```bash
curl -X GET http://localhost/api/products \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Actualizar Producto

```bash
curl -X PUT http://localhost/api/products/1 \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "name": "Laptop Dell XPS",
    "price": 1299.99
  }'
```

### Eliminar Producto

```bash
curl -X DELETE http://localhost/api/products/1 \
  -H "Accept: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Consumir API desde React

```typescript
// resources/js/services/api.ts
import axios from 'axios';

const api = axios.create({
    baseURL: '/api',
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
    }
});

// Interceptor para agregar token
api.interceptors.request.use(config => {
    const token = localStorage.getItem('access_token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

// Funciones de API
export const authApi = {
    login: (email: string, password: string) => 
        api.post('/login', { email, password }),
    
    register: (name: string, email: string, password: string, password_confirmation: string) =>
        api.post('/register', { name, email, password, password_confirmation }),
    
    logout: () => 
        api.post('/logout'),
    
    getUser: () => 
        api.get('/user'),
};

export const productsApi = {
    getAll: (page = 1) => 
        api.get(`/products?page=${page}`),
    
    getOne: (id: number) => 
        api.get(`/products/${id}`),
    
    create: (data: any) => 
        api.post('/products', data),
    
    update: (id: number, data: any) => 
        api.put(`/products/${id}`, data),
    
    delete: (id: number) => 
        api.delete(`/products/${id}`),
};
```

## Rate Limiting

```php
// app/Http/Kernel.php o bootstrap/app.php
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Http\Request;

RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});
```

## Testing de API

```php
// tests/Feature/Api/ProductTest.php
<?php

namespace Tests\Feature\Api;

use App\Models\Product;
use App\Models\User;
use Laravel\Passport\Passport;
use Tests\TestCase;

class ProductTest extends TestCase
{
    public function test_user_can_list_products()
    {
        Passport::actingAs(User::factory()->create());

        Product::factory()->count(3)->create();

        $response = $this->getJson('/api/products');

        $response->assertStatus(200)
                 ->assertJsonStructure([
                     'data' => [
                         '*' => ['id', 'name', 'price', 'stock']
                     ]
                 ]);
    }

    public function test_user_can_create_product()
    {
        Passport::actingAs(User::factory()->create());

        $productData = [
            'name' => 'Test Product',
            'description' => 'Test Description',
            'price' => 99.99,
            'stock' => 10,
        ];

        $response = $this->postJson('/api/products', $productData);

        $response->assertStatus(201)
                 ->assertJsonFragment(['name' => 'Test Product']);

        $this->assertDatabaseHas('products', $productData);
    }
}
```

---

**Para más información consulta la [documentación oficial de Laravel Passport](https://laravel.com/docs/12.x/passport)**

