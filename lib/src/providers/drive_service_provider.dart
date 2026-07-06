import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_budget/src/data/services/drive_service.dart';

final driveServiceProvider = Provider<DriveService>((ref) {
  return DriveService();
});
