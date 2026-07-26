import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sync_service.dart';
import '../services/isar_service.dart';
import '../services/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) => ConnectivityService());

final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return SyncService(connectivity);
});

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  // يمكن إضافة تيار من syncService لمعرفة حالة المزامنة
  // هنا نضع قيمة مبدئية
  return Stream.value(SyncStatus.idle);
});

enum SyncStatus { idle, syncing, success, error }