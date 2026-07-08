import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Puente Flutter <-> BleGattServerManager.kt.
/// El teléfono es el SERVIDOR GATT; el reloj (goalify_watch) es el cliente.
class BleServerService {
  static const MethodChannel _channel = MethodChannel('com.goalify/ble_server');

  final _commandsController = StreamController<Map<String, dynamic>>.broadcast();

  /// Comandos que llegan del reloj: {'action': 'toggle_habit', 'id': '...'}
  Stream<Map<String, dynamic>> get commands => _commandsController.stream;

  BleServerService() {
    _channel.setMethodCallHandler(_onMethodCall);
  }

  Future<dynamic> _onMethodCall(MethodCall call) async {
    if (call.method == 'onCommand') {
      try {
        final Map<String, dynamic> data = jsonDecode(call.arguments as String);
        _commandsController.add(data);
      } catch (_) {
        // JSON corrupto/parcial: se ignora.
      }
    }
  }

  /// Pide los permisos de Bluetooth necesarios en Android 12+.
  /// Debe llamarse ANTES de start().
  Future<bool> requestPermissions() async {
    final statuses = await [
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
    ].request();
    return statuses.values.every((s) => s.isGranted);
  }

  Future<void> start() => _channel.invokeMethod('startServer');

  Future<void> stop() => _channel.invokeMethod('stopServer');

  Future<bool> isBluetoothReady() async {
    final ready = await _channel.invokeMethod<bool>('isBluetoothReady');
    return ready ?? false;
  }

  /// Empuja el estado completo al reloj (habits + goals + config).
  Future<void> pushState({
    required List<Map<String, dynamic>> habits,
    required List<Map<String, dynamic>> goals,
    required bool isDarkMode,
  }) {
    final json = jsonEncode({
      'habits': habits,
      'goals': goals,
      'config': {'isDarkMode': isDarkMode},
    });
    return _channel.invokeMethod('pushState', {'json': json});
  }

  void dispose() {
    _commandsController.close();
  }
}
