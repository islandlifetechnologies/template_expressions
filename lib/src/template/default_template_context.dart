import 'package:template_expressions/template_expressions.dart';

/// Holds the default context that is used by all templates.  Adding or removing
/// items to this will affect all templates at evaluation / processing time.
abstract final class DefaultTemplateContext {
  DefaultTemplateContext._();

  /// The default context to use for all template when they evaluate or process
  /// the template.
  static final Map<String, dynamic> context = {
    ...CodexFunctions.members,
    ...CryptoFunctions.functions,
    ...DateTimeFunctions.functions,
    ...DurationFunctions.functions,
    ...EncryptFunctions.functions,
    ...FileSystemFunctions.functions,
    ...FutureFunctions.functions,
    ...JsonPathFunctions.functions,
    ...NumberFunctions.functions,
    ...PlatformFunctions.functions,
    ...RandomFunctions.functions,
  };
}
