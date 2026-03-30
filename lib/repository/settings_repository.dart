import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_projects/model/settings_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(FirebaseFirestore.instance);
});

final settingsStreamProvider = StreamProvider<SettingsModel>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.getSettings();
});

class SettingsRepository {
  final FirebaseFirestore _firestore;

  SettingsRepository(this._firestore);

  Stream<SettingsModel> getSettings() {
    return _firestore.collection('settings').doc('prices').snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists && snapshot.data() != null) {
        return SettingsModel.fromJson(snapshot.data()!);
      } else {
        return SettingsModel.empty();
      }
    });
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await _firestore
        .collection('settings')
        .doc('prices')
        .set(settings.toJson(), SetOptions(merge: true));
  }
}
