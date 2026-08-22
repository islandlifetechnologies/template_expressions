import 'platform_functions_stub.dart'
    if (dart.library.io) 'platform_functions_io.dart';

class PlatformFunctions {
  const PlatformFunctions._();

  static final functions = {
    'env': env,
    'Platform': {'environment': env},
  };
}
