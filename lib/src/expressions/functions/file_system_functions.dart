import 'package:file/chroot.dart';
import 'package:file/file.dart';
import 'package:path/path.dart' as p;

import 'fs/default_file_system.dart'
    if (dart.library.io) 'fs/io_file_system.dart';

class FileSystemFunctions({final FileSystem? fs, String? workingDirectory}) {
  this {
    var fileSystem = fs ?? getFileSystem();

    if (workingDirectory != null) {
      fileSystem = ChrootFileSystem(
        fileSystem,
        fileSystem.path.rootPrefix(fileSystem.currentDirectory.absolute.path),
      );
      fileSystem.currentDirectory = fileSystem.directory(workingDirectory);
    }

    functions = {
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
        'relative': (String path, [String? from]) =>
            p.relative(path, from: from),
      },
    };
  }

  late final Map<String, dynamic> functions;
}
