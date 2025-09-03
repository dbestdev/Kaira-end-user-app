// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:end_user_app/core/di/core_module.dart' as _i554;
import 'package:end_user_app/core/services/storage_service.dart' as _i208;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final coreModule = _$CoreModule();
    gh.factory<_i558.FlutterSecureStorage>(
      () => coreModule.flutterSecureStorage,
    );
    gh.factory<_i208.StorageService>(
      () => _i208.StorageService(gh<_i558.FlutterSecureStorage>()),
    );
    return this;
  }
}

class _$CoreModule extends _i554.CoreModule {}
