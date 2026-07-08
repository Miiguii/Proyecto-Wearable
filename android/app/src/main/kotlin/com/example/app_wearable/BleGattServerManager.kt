package com.example.app_wearable

import android.bluetooth.*
import android.bluetooth.le.AdvertiseCallback
import android.bluetooth.le.AdvertiseData
import android.bluetooth.le.AdvertiseSettings
import android.bluetooth.le.BluetoothLeAdvertiser
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import java.util.UUID

/**
 * Servidor GATT del lado del TELÉFONO para GOALIFY.
 * El reloj (goalify_watch) es el cliente: escanea, se conecta, se suscribe
 * al characteristic de estado y escribe comandos.
 *
 * Contrato (debe coincidir EXACTO con GoalifyBleUuids en el reloj):
 *  - Service:   6e400001-b5a3-f393-e0a9-e50e24dcca9e
 *  - State:     6e400002-...  Notify + Read  -> JSON completo del estado
 *  - Command:   6e400003-...  Write          -> JSON de comandos del reloj
 */
class BleGattServerManager(
    private val context: Context,
    private val onCommandReceived: (String) -> Unit,
) {
    companion object {
        private const val TAG = "BleGattServerManager"
        val SERVICE_UUID: UUID = UUID.fromString("6e400001-b5a3-f393-e0a9-e50e24dcca9e")
        val STATE_CHAR_UUID: UUID = UUID.fromString("6e400002-b5a3-f393-e0a9-e50e24dcca9e")
        val COMMAND_CHAR_UUID: UUID = UUID.fromString("6e400003-b5a3-f393-e0a9-e50e24dcca9e")
        val CCCD_UUID: UUID = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb")
    }

    private val bluetoothManager =
        context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
    private var gattServer: BluetoothGattServer? = null
    private var advertiser: BluetoothLeAdvertiser? = null
    private var stateCharacteristic: BluetoothGattCharacteristic? = null
    private val connectedDevices = mutableSetOf<BluetoothDevice>()
    private var lastStateBytes: ByteArray = "{}".toByteArray(Charsets.UTF_8)
    private val mainHandler = Handler(Looper.getMainLooper())

    /** true si el adaptador está prendido y soporta advertising. */
    fun isBluetoothReady(): Boolean {
        val adapter = bluetoothManager.adapter
        return adapter != null && adapter.isEnabled &&
            adapter.bluetoothLeAdvertiser != null
    }

    fun start() {
        val adapter = bluetoothManager.adapter ?: run {
            Log.e(TAG, "No hay adaptador Bluetooth en este dispositivo")
            return
        }
        if (!adapter.isEnabled) {
            Log.e(TAG, "Bluetooth está apagado")
            return
        }

        gattServer = bluetoothManager.openGattServer(context, gattServerCallback)
        setupService()
        startAdvertising(adapter)
    }

    private fun setupService() {
        val service = BluetoothGattService(SERVICE_UUID, BluetoothGattService.SERVICE_TYPE_PRIMARY)

        val stateChar = BluetoothGattCharacteristic(
            STATE_CHAR_UUID,
            BluetoothGattCharacteristic.PROPERTY_READ or BluetoothGattCharacteristic.PROPERTY_NOTIFY,
            BluetoothGattCharacteristic.PERMISSION_READ,
        )
        // Descriptor requerido para que el cliente pueda habilitar notificaciones.
        val cccd = BluetoothGattDescriptor(
            CCCD_UUID,
            BluetoothGattDescriptor.PERMISSION_READ or BluetoothGattDescriptor.PERMISSION_WRITE,
        )
        stateChar.addDescriptor(cccd)
        stateChar.value = lastStateBytes
        stateCharacteristic = stateChar

        val commandChar = BluetoothGattCharacteristic(
            COMMAND_CHAR_UUID,
            BluetoothGattCharacteristic.PROPERTY_WRITE,
            BluetoothGattCharacteristic.PERMISSION_WRITE,
        )

        service.addCharacteristic(stateChar)
        service.addCharacteristic(commandChar)
        gattServer?.addService(service)
    }

    private fun startAdvertising(adapter: BluetoothAdapter) {
        advertiser = adapter.bluetoothLeAdvertiser
        val settings = AdvertiseSettings.Builder()
            .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
            .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
            .setConnectable(true)
            .build()

        // El UUID del servicio va en el paquete de advertising: es lo que el
        // reloj filtra al escanear (withServices en flutter_blue_plus).
        val data = AdvertiseData.Builder()
            .setIncludeDeviceName(true)
            .addServiceUuid(android.os.ParcelUuid(SERVICE_UUID))
            .build()

        advertiser?.startAdvertising(settings, data, advertiseCallback)
    }

    private val advertiseCallback = object : AdvertiseCallback() {
        override fun onStartSuccess(settingsInEffect: AdvertiseSettings?) {
            Log.d(TAG, "Advertising iniciado correctamente")
        }

        override fun onStartFailure(errorCode: Int) {
            Log.e(TAG, "Fallo al iniciar advertising, código: $errorCode")
        }
    }

    private val gattServerCallback = object : BluetoothGattServerCallback() {
        override fun onConnectionStateChange(device: BluetoothDevice, status: Int, newState: Int) {
            if (newState == BluetoothProfile.STATE_CONNECTED) {
                connectedDevices.add(device)
                Log.d(TAG, "Reloj conectado: ${device.address}")
            } else if (newState == BluetoothProfile.STATE_DISCONNECTED) {
                connectedDevices.remove(device)
                Log.d(TAG, "Reloj desconectado: ${device.address}")
            }
        }

        override fun onCharacteristicReadRequest(
            device: BluetoothDevice,
            requestId: Int,
            offset: Int,
            characteristic: BluetoothGattCharacteristic,
        ) {
            if (characteristic.uuid == STATE_CHAR_UUID) {
                gattServer?.sendResponse(
                    device, requestId, BluetoothGatt.GATT_SUCCESS, offset,
                    lastStateBytes.copyOfRange(offset.coerceAtMost(lastStateBytes.size), lastStateBytes.size),
                )
            } else {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_FAILURE, offset, null)
            }
        }

        override fun onCharacteristicWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            characteristic: BluetoothGattCharacteristic,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray,
        ) {
            if (characteristic.uuid == COMMAND_CHAR_UUID) {
                val json = String(value, Charsets.UTF_8)
                Log.d(TAG, "Comando recibido del reloj: $json")
                // El MethodChannel debe invocarse en el main thread.
                mainHandler.post { onCommandReceived(json) }
                if (responseNeeded) {
                    gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, null)
                }
            } else if (responseNeeded) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_FAILURE, offset, null)
            }
        }

        override fun onDescriptorWriteRequest(
            device: BluetoothDevice,
            requestId: Int,
            descriptor: BluetoothGattDescriptor,
            preparedWrite: Boolean,
            responseNeeded: Boolean,
            offset: Int,
            value: ByteArray,
        ) {
            // Boilerplate estándar: el cliente escribe el CCCD para activar notify.
            descriptor.value = value
            if (responseNeeded) {
                gattServer?.sendResponse(device, requestId, BluetoothGatt.GATT_SUCCESS, offset, null)
            }
        }

        override fun onMtuChanged(device: BluetoothDevice, mtu: Int) {
            Log.d(TAG, "MTU negociado con ${device.address}: $mtu bytes")
        }
    }

    /**
     * Empuja el estado completo (habits + goals + config) a todos los relojes
     * conectados. Se llama desde Flutter vía MethodChannel cada vez que cambia algo.
     */
    fun pushState(json: String) {
        lastStateBytes = json.toByteArray(Charsets.UTF_8)
        val char = stateCharacteristic ?: return
        char.value = lastStateBytes
        for (device in connectedDevices) {
            gattServer?.notifyCharacteristicChanged(device, char, false)
        }
    }

    fun stop() {
        advertiser?.stopAdvertising(advertiseCallback)
        gattServer?.close()
        connectedDevices.clear()
    }
}
