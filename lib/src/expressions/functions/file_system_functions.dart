import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'fs/default_file_system.dart'
    if (dart.library.io) 'fs/io_file_system.dart';

class FileSystemFunctions {
  const FileSystemFunctions._();

  static FileSystem? fileSystemOverride;

  static final functions = {
    'Directory': (path) =>
        (fileSystemOverride ?? getFileSystem()).directory(path),
    'File': (path) => (fileSystemOverride ?? getFileSystem()).file(path),
    'FileSystem': () => fileSystemOverride ?? getFileSystem(),
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
