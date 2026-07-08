# app_wearable — cambios para BLE GATT Server

Este es tu proyecto `app_wearable` con lo necesario agregado para que exista
comunicación real por Bluetooth con `goalify_watch`: **el teléfono ahora es el
servidor GATT**, el reloj es el cliente que ya armamos antes.

## Qué se agregó / cambió

1. **`android/app/src/main/kotlin/com/example/app_wearable/BleGattServerManager.kt`** (nuevo)
   Arma el servicio GATT, lo anuncia (advertising) para que el reloj lo encuentre,
   notifica el estado a los relojes conectados y recibe sus comandos de escritura.

2. **`MainActivity.kt`** (modificado)
   Crea el `MethodChannel` `com.goalify/ble_server` y conecta `BleGattServerManager`
   con Flutter: `startServer`, `stopServer`, `pushState`, `isBluetoothReady`, y el
   callback `onCommand` hacia Dart.

3. **`lib/services/ble_server_service.dart`** (nuevo)
   Envoltorio Dart del `MethodChannel`. Pide permisos runtime, arranca/para el
   servidor, expone `pushState(...)` y un `Stream` de comandos entrantes.

4. **`lib/screens/dashboard.dart`** (modificado)
   - Se quitó `watch_connectivity`.
   - Cada hábito y meta ahora tiene un **`id` estable** (antes solo se identificaban
     por índice, lo cual se rompe apenas el reloj y el teléfono desincronizan listas).
   - `initState` pide permisos, arranca el servidor BLE y sincroniza el estado inicial.
   - Cada mutación (agregar/togglear hábito, agregar/avanzar meta, cambiar tema)
     llama a `_pushStateToWatch()`.
   - `_handleWatchCommand` procesa lo que el reloj pide: `toggle_habit` y `update_goal`.

5. **`lib/screens/configuracion.dart`** (modificado)
   El switch de modo oscuro ahora también dispara `onDarkModeChanged`, para que el
   teléfono le avise al reloj cuando cambia el tema.

6. **`AndroidManifest.xml`** — permisos `BLUETOOTH_ADVERTISE`, `BLUETOOTH_CONNECT`
   (Android 12+) y los legacy para versiones anteriores.

7. **`pubspec.yaml`** — se sacó `watch_connectivity`, se agregó `permission_handler`
   para pedir los permisos BLE en runtime.

## Contrato BLE (debe coincidir con `goalify_watch`)

**Service UUID:** `6e400001-b5a3-f393-e0a9-e50e24dcca9e`

| Characteristic | UUID | Propiedad | Contenido |
|---|---|---|---|
| State | `6e400002-...` | Notify + Read | `{"habits":[...],"goals":[...],"config":{"isDarkMode":bool}}` |
| Command | `6e400003-...` | Write | `{"action":"toggle_habit","id":"h2"}` o `{"action":"update_goal","id":"g0","progress":90}` |

## Pendiente / próximos pasos

- **Probar en hardware físico.** El servidor GATT (`BluetoothLeAdvertiser`) no funciona
  en emulador. Necesitás el teléfono real + el reloj real, como ya veníamos haciendo.
- **MTU:** el JSON de estado puede superar los 20 bytes del MTU por defecto. Android
  negocia esto automáticamente si el cliente (reloj) pide un MTU mayor tras conectar
  (`device.requestMtu(512)` del lado de `flutter_blue_plus`). Si el estado crece mucho
  (muchos hábitos/metas), convendría paginar o comprimir el JSON.
- **Permisos denegados:** ahora mismo si el usuario rechaza los permisos Bluetooth,
  `_initBleServer` simplemente no arranca el servidor sin avisar. Vale la pena agregar
  un diálogo explicando por qué se necesitan y un botón para reintentar.
- El bloque de Bluetooth encendido/apagado no se está escuchando en runtime
  (`isBluetoothReady()` existe pero no se usa todavía) — podrías mostrarlo en
  `configuracion.dart` como indicador de "reloj vinculado".
