import 'package:file/file.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'fs/default_file_system.dart'
    if (dart.library.io) 'fs/io_file_system.dart';

class FileSystemFunctions {
  const FileSystemFunctions._();

  @visibleForTesting
  static FileSystem? fileSystemOverride;

  /// Returns the file system utilized by the Template engine for parsing
  /// expressions.  Callers can read this value to ensure that they are
  /// referencing the same file system the templates are.
  static FileSystem get fileSystem => fileSystemOverride ?? getFileSystem();

  static final functions = {
    'Directory': (path) => fileSystem.directory(path),
    'File': (path) => fileSystem.file(path),
    'FileSystem': () => fileSystem,
    'path': {
      'basename': p.basename,
      'basenameWithoutExtension': p.basenameWithoutExtension,
      'extension': p.extension,
      'dirname': p.dirname,
      'fromUri': p.fromUri,
      'join': p.join,
      'joinAll': (Iterable arr) => p.joinAll(arr.map((a) => a.toString())),
      'relative': (String path, [String? from]) => p.relative(path, from: from),
    },
  };
}
