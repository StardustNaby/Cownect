# 📱 CÓMO CONSTRUIR EL APK - INSTRUCCIONES PASO A PASO

## ⚠️ PROBLEMA ACTUAL
Hay un conflicto con `isar_flutter_libs` que impide la construcción. 

## ✅ SOLUCIÓN: Construir el APK

### Paso 1: Abrir la terminal en la carpeta del proyecto
```powershell
cd C:\Users\Victus\Desktop\GanApp
```

### Paso 2: Limpiar el proyecto
```powershell
flutter clean
```

### Paso 3: Obtener dependencias
```powershell
flutter pub get
```

### Paso 4: Construir el APK (INTENTAR ESTO PRIMERO)
```powershell
flutter build apk --release --split-per-abi
```

**Si falla**, intenta sin split:
```powershell
flutter build apk --release
```

## 📍 DÓNDE ENCONTRAR EL APK

Una vez que la construcción sea exitosa, el APK estará en:

```
C:\Users\Victus\Desktop\GanApp\build\app\outputs\flutter-apk\
```

### Archivos que encontrarás:

**Con `--split-per-abi`** (3 archivos, uno por arquitectura):
- `app-armeabi-v7a-release.apk` → Para dispositivos ARM 32-bit (antiguos)
- `app-arm64-v8a-release.apk` → Para dispositivos ARM 64-bit (MÁS COMÚN - USA ESTE)
- `app-x86_64-release.apk` → Para emuladores/dispositivos x86

**Sin `--split-per-abi`** (1 archivo universal):
- `app-release.apk` → Funciona en todos los dispositivos (más grande)

## 🔧 SI EL BUILD FALLA

El error actual es con `isar_flutter_libs`. Opciones:

### Opción A: Construir sin Isar (si no lo usas activamente)
Comentar temporalmente Isar en `pubspec.yaml` y construir.

### Opción B: Usar una versión anterior de compileSdk
Cambiar `compileSdk = 36` a `compileSdk = 34` en `android/app/build.gradle.kts`

### Opción C: Construir en modo debug (para pruebas)
```powershell
flutter build apk --debug
```
El APK estará en la misma ubicación pero será más grande y no optimizado.

## 📦 DESPUÉS DE CONSTRUIR

1. **Encuentra el APK** en la carpeta mencionada arriba
2. **Copia el APK** a tu dispositivo Android
3. **Instala** tocando el archivo (necesitas permitir "Instalar desde fuentes desconocidas")
4. **Prueba** la aplicación

## 🎯 RECOMENDACIÓN

Para la mayoría de dispositivos modernos, usa:
- `app-arm64-v8a-release.apk` (si usaste `--split-per-abi`)
- `app-release.apk` (si NO usaste `--split-per-abi`)

