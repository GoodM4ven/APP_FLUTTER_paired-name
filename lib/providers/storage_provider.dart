import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final storageProvider = StateNotifierProvider<StorageNotifier, bool>((ref) {
  return StorageNotifier();
});

class StorageNotifier extends StateNotifier<bool> {
  Box? encryptedStorage;

  StorageNotifier() : super(false) {
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    const secureStorage = FlutterSecureStorage();

    final encryptionKeyString = await secureStorage.read(key: 'key');
    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(key: 'key', value: base64UrlEncode(key));
    }

    final key = await secureStorage.read(key: 'key');
    final encryptionKeyUint8List = base64Url.decode(key!);

    encryptedStorage = await Hive.openBox(
      'secureStorage',
      encryptionCipher: HiveAesCipher(encryptionKeyUint8List),
    );

    state = true;
  }

  Future<void> setData(String key, dynamic value) async {
    await encryptedStorage!.put(key, value);
  }

  dynamic getData(String key) {
    return encryptedStorage!.get(key);
  }

  Future<void> deleteData(String key) async {
    await encryptedStorage!.delete(key);
  }
}
