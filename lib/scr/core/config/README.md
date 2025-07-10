# Configuración de API Centralizada

Este archivo centraliza la configuración de URLs de la API para facilitar el desarrollo en diferentes entornos.

## Cómo usar

### Para desarrollo local (tu máquina)
```dart
// En lib/scr/core/config/api_config.dart
static const String baseUrl = 'http://localhost:8080';
```

### Para otros desarrolladores
```dart
// En lib/scr/core/config/api_config.dart
static const String baseUrl = 'http://10.0.1.x:8080'; // donde x es tu IP
```

## Ventajas

1. **Un solo lugar para cambiar**: Solo necesitas modificar la línea `baseUrl` en `api_config.dart`
2. **Consistencia**: Todos los servicios usan la misma configuración
3. **Fácil mantenimiento**: No hay que buscar y reemplazar en múltiples archivos

## Servicios actualizados

Los siguientes servicios ya están configurados para usar `ApiConfig`:

- ✅ AuthService
- ✅ PatientService  
- ✅ ProfileService
- ✅ DoctorSignUpService
- ✅ PatientSignUpService
- ✅ NotificationService
- ✅ MedicalRecordService
- ✅ PatientsListService

## Cómo agregar nuevos endpoints

Si necesitas agregar nuevos endpoints, simplemente agrégalos al archivo `api_config.dart`:

```dart
// Ejemplo
static const String newEndpoint = '$apiV1/nuevo-endpoint';
```

Y luego úsalo en tu servicio:

```dart
final response = await http.get(
  Uri.parse(ApiConfig.newEndpoint),
  headers: headers,
);
``` 