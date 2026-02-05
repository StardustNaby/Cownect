# Guía de Construcción para Producción

## Versión
- **Versión actual**: `1.0.0+1` (definida en `pubspec.yaml`)

## Comando para construir APK firmado

```bash
flutter build apk --release --split-per-abi
```

### Opciones del comando:
- `--release`: Construye en modo release (optimizado, sin debug)
- `--split-per-abi`: Genera APKs separados por arquitectura (más pequeños)

### Alternativa (APK universal):
```bash
flutter build apk --release
```
Genera un solo APK que incluye todas las arquitecturas (más grande).

## Ubicación de los APKs generados

Después de una construcción exitosa, encontrarás los archivos en:

```
build/app/outputs/flutter-apk/
```

### Con `--split-per-abi`:
- `app-armeabi-v7a-release.apk` - Para dispositivos ARM 32-bit
- `app-arm64-v8a-release.apk` - Para dispositivos ARM 64-bit (más común)
- `app-x86_64-release.apk` - Para dispositivos x86 64-bit

### Sin `--split-per-abi`:
- `app-release.apk` - APK universal (incluye todas las arquitecturas)

## Configuración de firma

**Estado actual**: La aplicación está configurada para usar debug keys temporalmente.

### Para producción real, necesitas:

1. **Crear un keystore**:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Crear `android/key.properties`**:
```properties
storePassword=<password del keystore>
keyPassword=<password de la clave>
keyAlias=upload
storeFile=<ruta al keystore>
```

3. **Actualizar `android/app/build.gradle.kts`** para usar el keystore de producción.

## Nota sobre el problema actual

Actualmente hay un problema de compatibilidad con `isar_flutter_libs` que impide la construcción. Se requiere:
- Actualizar `compileSdk` a 36 (ya configurado)
- Resolver el conflicto con `android:attr/lStar` en isar_flutter_libs

## Verificación del APK

Para verificar que el APK está correctamente firmado:
```bash
jarsigner -verify -verbose -certs app-release.apk
```

Para ver información del APK:
```bash
aapt dump badging app-release.apk
```

