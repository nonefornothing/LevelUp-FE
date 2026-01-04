import 'package:hive/hive.dart';

import '../../core/constants/app_constants.dart';
import 'local_storage.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isCompleted();
  Future<void> setCompleted(bool completed);
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  Box<dynamic> get _prefsBox => Hive.box(HiveLocalStorage.prefsBoxName);

  @override
  Future<bool> isCompleted() async {
    final value = _prefsBox.get(AppConstants.storageKeyOnboardingCompleted);
    return value is bool ? value : false;
  }

  @override
  Future<void> setCompleted(bool completed) async {
    await _prefsBox.put(AppConstants.storageKeyOnboardingCompleted, completed);
  }
}


