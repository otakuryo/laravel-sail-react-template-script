# Ejemplo de Componente React con shadcn/ui

Este archivo contiene ejemplos de cómo crear componentes React usando el stack instalado por el script.

## Ejemplo 1: Página Simple con Inertia

```typescript
// resources/js/pages/Welcome.tsx
import { Head } from '@inertiajs/react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

interface WelcomeProps {
    message: string;
    user?: {
        name: string;
        email: string;
    };
}

export default function Welcome({ message, user }: WelcomeProps) {
    return (
        <>
            <Head title="Bienvenido" />
            
            <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 dark:from-gray-900 dark:to-gray-800">
                <div className="container mx-auto px-4 py-16">
                    <Card className="max-w-2xl mx-auto">
                        <CardHeader>
                            <CardTitle className="text-3xl">
                                {message}
                            </CardTitle>
                            {user && (
                                <CardDescription>
                                    Bienvenido, {user.name}!
                                </CardDescription>
                            )}
                        </CardHeader>
                        <CardContent>
                            <p className="text-gray-600 dark:text-gray-300 mb-4">
                                Tu aplicación Laravel con React está funcionando correctamente.
                            </p>
                            <Button asChild>
                                <a href="/dashboard">
                                    Ir al Dashboard
                                </a>
                            </Button>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </>
    );
}
```

**Ruta correspondiente en Laravel:**

```php
// routes/web.php
use Inertia\Inertia;

Route::get('/', function () {
    return Inertia::render('Welcome', [
        'message' => 'Hola desde Laravel 12',
        'user' => auth()->user()
    ]);
});
```

## Ejemplo 2: Formulario con Validación

```typescript
// resources/js/pages/ContactForm.tsx
import { Head, useForm } from '@inertiajs/react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Alert, AlertDescription } from '@/components/ui/alert';

export default function ContactForm() {
    const { data, setData, post, processing, errors } = useForm({
        name: '',
        email: '',
        message: ''
    });

    function handleSubmit(e: React.FormEvent) {
        e.preventDefault();
        post('/contact');
    }

    return (
        <>
            <Head title="Contacto" />
            
            <div className="container mx-auto px-4 py-16">
                <Card className="max-w-xl mx-auto">
                    <CardHeader>
                        <CardTitle>Formulario de Contacto</CardTitle>
                    </CardHeader>
                    <CardContent>
                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div>
                                <Label htmlFor="name">Nombre</Label>
                                <Input
                                    id="name"
                                    value={data.name}
                                    onChange={e => setData('name', e.target.value)}
                                    className={errors.name ? 'border-red-500' : ''}
                                />
                                {errors.name && (
                                    <p className="text-red-500 text-sm mt-1">
                                        {errors.name}
                                    </p>
                                )}
                            </div>

                            <div>
                                <Label htmlFor="email">Email</Label>
                                <Input
                                    id="email"
                                    type="email"
                                    value={data.email}
                                    onChange={e => setData('email', e.target.value)}
                                    className={errors.email ? 'border-red-500' : ''}
                                />
                                {errors.email && (
                                    <p className="text-red-500 text-sm mt-1">
                                        {errors.email}
                                    </p>
                                )}
                            </div>

                            <div>
                                <Label htmlFor="message">Mensaje</Label>
                                <Textarea
                                    id="message"
                                    value={data.message}
                                    onChange={e => setData('message', e.target.value)}
                                    className={errors.message ? 'border-red-500' : ''}
                                    rows={5}
                                />
                                {errors.message && (
                                    <p className="text-red-500 text-sm mt-1">
                                        {errors.message}
                                    </p>
                                )}
                            </div>

                            <Button 
                                type="submit" 
                                disabled={processing}
                                className="w-full"
                            >
                                {processing ? 'Enviando...' : 'Enviar Mensaje'}
                            </Button>
                        </form>
                    </CardContent>
                </Card>
            </div>
        </>
    );
}
```

**Controlador en Laravel:**

```php
// app/Http/Controllers/ContactController.php
namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ContactController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|min:3',
            'email' => 'required|email',
            'message' => 'required|min:10'
        ]);

        // Procesar el formulario (enviar email, guardar en BD, etc.)
        
        return back()->with('success', 'Mensaje enviado correctamente');
    }
}
```

**Ruta:**

```php
// routes/web.php
use App\Http\Controllers\ContactController;
use Inertia\Inertia;

Route::get('/contact', function () {
    return Inertia::render('ContactForm');
});

Route::post('/contact', [ContactController::class, 'store']);
```

## Ejemplo 3: Lista con Paginación

```typescript
// resources/js/pages/Users/Index.tsx
import { Head, Link } from '@inertiajs/react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table';

interface User {
    id: number;
    name: string;
    email: string;
    created_at: string;
}

interface PaginatedUsers {
    data: User[];
    links: {
        url: string | null;
        label: string;
        active: boolean;
    }[];
}

interface UsersIndexProps {
    users: PaginatedUsers;
}

export default function UsersIndex({ users }: UsersIndexProps) {
    return (
        <>
            <Head title="Usuarios" />
            
            <div className="container mx-auto px-4 py-8">
                <div className="flex justify-between items-center mb-6">
                    <h1 className="text-3xl font-bold">Usuarios</h1>
                    <Button asChild>
                        <Link href="/users/create">
                            Nuevo Usuario
                        </Link>
                    </Button>
                </div>

                <Card>
                    <CardContent className="p-0">
                        <Table>
                            <TableHeader>
                                <TableRow>
                                    <TableHead>ID</TableHead>
                                    <TableHead>Nombre</TableHead>
                                    <TableHead>Email</TableHead>
                                    <TableHead>Fecha de Registro</TableHead>
                                    <TableHead className="text-right">Acciones</TableHead>
                                </TableRow>
                            </TableHeader>
                            <TableBody>
                                {users.data.map((user) => (
                                    <TableRow key={user.id}>
                                        <TableCell>{user.id}</TableCell>
                                        <TableCell className="font-medium">
                                            {user.name}
                                        </TableCell>
                                        <TableCell>{user.email}</TableCell>
                                        <TableCell>
                                            {new Date(user.created_at).toLocaleDateString('es-ES')}
                                        </TableCell>
                                        <TableCell className="text-right">
                                            <Button 
                                                variant="outline" 
                                                size="sm"
                                                asChild
                                            >
                                                <Link href={`/users/${user.id}/edit`}>
                                                    Editar
                                                </Link>
                                            </Button>
                                        </TableCell>
                                    </TableRow>
                                ))}
                            </TableBody>
                        </Table>
                    </CardContent>
                </Card>

                {/* Paginación */}
                <div className="flex justify-center gap-2 mt-6">
                    {users.links.map((link, index) => (
                        <Button
                            key={index}
                            variant={link.active ? 'default' : 'outline'}
                            disabled={!link.url}
                            asChild={!!link.url}
                        >
                            {link.url ? (
                                <Link href={link.url}>
                                    <span dangerouslySetInnerHTML={{ __html: link.label }} />
                                </Link>
                            ) : (
                                <span dangerouslySetInnerHTML={{ __html: link.label }} />
                            )}
                        </Button>
                    ))}
                </div>
            </div>
        </>
    );
}
```

**Controlador:**

```php
// app/Http/Controllers/UserController.php
namespace App\Http\Controllers;

use App\Models\User;
use Inertia\Inertia;

class UserController extends Controller
{
    public function index()
    {
        return Inertia::render('Users/Index', [
            'users' => User::latest()->paginate(10)
        ]);
    }
}
```

## Componentes Disponibles en shadcn/ui

Para agregar más componentes de shadcn/ui:

```bash
# Listar componentes disponibles
./vendor/bin/sail npx shadcn@latest

# Agregar componentes específicos
./vendor/bin/sail npx shadcn@latest add dialog
./vendor/bin/sail npx shadcn@latest add dropdown-menu
./vendor/bin/sail npx shadcn@latest add select
./vendor/bin/sail npx shadcn@latest add toast
./vendor/bin/sail npx shadcn@latest add avatar
./vendor/bin/sail npx shadcn@latest add badge
```

## Tips de TypeScript con Inertia

Define los tipos de tus props globales en `resources/js/types/index.d.ts`:

```typescript
export interface User {
    id: number;
    name: string;
    email: string;
    email_verified_at?: string;
}

export type PageProps<T extends Record<string, unknown> = Record<string, unknown>> = T & {
    auth: {
        user: User;
    };
};
```

Luego usa en tus componentes:

```typescript
import { PageProps } from '@/types';

export default function Dashboard({ auth }: PageProps) {
    return (
        <div>
            <h1>Bienvenido, {auth.user.name}!</h1>
        </div>
    );
}
```

---

**Estos ejemplos te ayudarán a empezar rápidamente con tu aplicación Laravel + React 19 + shadcn/ui!**

