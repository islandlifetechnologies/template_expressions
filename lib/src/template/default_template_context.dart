import 'package:file/file.dart';
import 'package:template_expressions/template_expressions.dart';

/// Holds the default context that is used by all templates.  Adding or removing
/// items to this will affect all templates at evaluation / processing time.
class DefaultTemplateContext({
  final FileSystem? fs,
  final String? workingDirectory,
}) {
  Map<String, dynamic> get context => {
    ...CodexFunctions.members,
    ...CryptoFunctions.functions,
    ...DateTimeFunctions.functions,
    ...DurationFunctions.functions,
    ...EncryptFunctions.functions,
    ...FileSystemFunctions(
      fs: fs,
      workingDirectory: workingDirectory,
    ).functions,
    ...FutureFunctions.functions,
    ...JsonPathFunctions.functions,
    ...NumberFunctions.functions,
    ...PlatformFunctions.functions,
    ...RandomFunctions.functions,
  };
}
