import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:file/file.dart';
import 'package:intl/intl.dart';
import 'package:json_path/json_path.dart';
import 'package:logging/logging.dart';
import 'package:template_expressions/template_expressions.dart';
import 'package:yaon/yaon.dart';

/// Associates member functions from common objects for use by the expression
/// evaluator.
dynamic lookupStandardMembers(dynamic target, String name) {
  dynamic result;

  if (target is Codex) {
    result = _processCodex(target, name);
  } else if (target is DateFormat) {
    result = _processDateFormat(target, name);
  } else if (target is DateTime) {
    result = _processDateTime(target, name);
  } else if (target is Duration) {
    result = _processDuration(target, name);
  } else if (target is FileSystem) {
    result = _processFileSystem(target, name);
  } else if (target is FileSystemEntity) {
    if (target is Directory) {
      result = _processDirectory(target, name);
    } else if (target is File) {
      result = _processFile(target, name);
    } else {
      result = _processFileSystemEntity(target, name);
    }
  } else if (target is Iterable) {
    result = _processIterable(target, name);
  } else if (target is JsonPath) {
    result = _processJsonPath(target, name);
  } else if (target is JsonPathMatch) {
    result = _processJsonPathMatch(target, name);
  } else if (target is Logger) {
    result = _processLogger(target, name);
  } else if (target is Map) {
    result = _processMap(target, name);
  } else if (target is MapEntry) {
    result = _processMapEntry(target, name);
  } else if (target is NumberFormat) {
    result = _processNumberFormat(target, name);
  } else if (target is double || target is int || target is num) {
    result = _processNum(target, name);
  } else if (target is String) {
    result = _processString(target, name);
  } else if (target is Aes) {
    result = _processAes(target, name);
  } else if (target is Rsa) {
    result = _processRsa(target, name);
  }

  if (target != null && result == null) {
    result = switch (name) {
      'hashCode' => target.hashCode,
      'runtimeType' => target.runtimeType,
      'toString' => target.toString,
      _ => null,
    };
  }

  return result;
}

dynamic _processAes(Aes target, String name) => switch (name) {
  'decrypt' => target.decrypt,
  'encrypt' => target.encrypt,
  'iv' => target.iv,
  'key' => target.key,
  'mode' => target.mode,
  'padding' => target.padding,
  _ => null,
};

dynamic _processCodex(Codex target, String name) => switch (name) {
  'decode' => target.decode,
  'encode' => target.encode,
  _ => null,
};

dynamic _processDateFormat(DateFormat target, String name) => switch (name) {
  'format' => target.format,
  'parse' => target.parse,
  'parseUtc' || 'parseUTC' => target.parseUtc,
  _ => null,
};

dynamic _processDateTime(DateTime target, String name) => switch (name) {
  'add' => (duration) => DateTime.fromMillisecondsSinceEpoch(
    target.millisecondsSinceEpoch +
        ((duration is Duration)
            ? duration.inMilliseconds
            : maybeParseInt(duration)!),
    isUtc: target.isUtc,
  ),
  'compareTo' => target.compareTo,
  'format' => (pattern) => DateFormat(pattern).format(target),
  'isAfter' => target.isAfter,
  'isBefore' => target.isBefore,
  'isUtc' => target.isUtc,
  'millisecondsSinceEpoch' => target.millisecondsSinceEpoch,
  'subtract' => (duration) => target.subtract(
    duration is Duration
        ? duration
        : Duration(milliseconds: maybeParseInt(duration)!),
  ),
  'toIso8601String' => target.toIso8601String,
  'toLocal' => target.toLocal,
  'toUtc' => target.toUtc,
  _ => null,
};

dynamic _processDirectory(Directory dir, String name) => switch (name) {
  'childDirectory' => dir.childDirectory,
  'childFile' => dir.childFile,
  'create' => dir.create,
  'createSync' => dir.createSync,
  'createTemp' => dir.createTemp,
  'createTempSync' => dir.createTempSync,
  'list' => dir.list,
  'listSync' => dir.listSync,
  _ => _processFileSystemEntity(dir, name),
};

dynamic _processDuration(Duration target, String name) => switch (name) {
  'add' =>
    (duration) =>
        target.inMilliseconds +
        (duration is Duration
            ? duration.inMilliseconds
            : maybeParseInt(duration)!),
  'compareTo' => target.compareTo,
  'inDays' => target.inDays,
  'inHours' => target.inHours,
  'inMilliseconds' => target.inMilliseconds,
  'inMinutes' => target.inMinutes,
  'inSeconds' => target.inSeconds,
  'subtract' => (duration) => Duration(
    milliseconds:
        target.inMilliseconds -
        (duration is Duration
            ? duration.inMilliseconds
            : maybeParseInt(duration)!),
  ),
  _ => null,
};

dynamic _processFile(File file, String name) => switch (name) {
  'copy' => file.copy,
  'copySync' => file.copySync,
  'create' => file.create,
  'createSync' => file.createSync,
  'lastAccessed' => file.lastAccessed,
  'lastAccessedSync' => file.lastAccessedSync,
  'lastModified' => file.lastModified,
  'lastModifiedSync' => file.lastModifiedSync,
  'readAsBytes' => file.readAsBytes,
  'readAsBytesSync' => file.readAsBytesSync,
  'readAsLines' => file.readAsLines,
  'readAsLinesSync' => file.readAsLinesSync,
  'readAsString' => file.readAsString,
  'readAsStringSync' => file.readAsStringSync,
  'writeAsBytes' => file.writeAsBytes,
  'writeAsBytesSync' => file.writeAsBytesSync,
  _ => _processFileSystemEntity(file, name),
};

dynamic _processFileSystem(FileSystem fs, String name) => switch (name) {
  'currentDirectory' => fs.currentDirectory,
  'directory' => fs.directory,
  'file' => fs.file,
  'identical' => fs.identical,
  'identicalSync' => fs.identicalSync,
  'isDirectory' => fs.isDirectory,
  'isDirectorySync' => fs.isDirectorySync,
  'isFile' => fs.isFile,
  'isFileSync' => fs.isFileSync,
  'path' => fs.path,
  'systemTempDirectory' => fs.systemTempDirectory,
  'type' => fs.type,
  'typeSync' => fs.typeSync,
  _ => null,
};

dynamic _processFileSystemEntity(FileSystemEntity entity, String name) =>
    switch (name) {
      'absolute' => entity.absolute,
      'basename' => entity.basename,
      'delete' => entity.delete,
      'deleteSync' => entity.deleteSync,
      'exists' => entity.exists,
      'existsSync' => entity.existsSync,
      'dirname' => entity.dirname,
      'isAbsolute' => entity.isAbsolute,
      'path' => entity.path,
      'parent' => entity.parent,
      'rename' => entity.rename,
      'renameSync' => entity.renameSync,
      _ => null,
    };

dynamic _processIntList(List<int> bytes, String name) => switch (name) {
  'toBase64' => () => base64.encode(bytes),
  'toBase64Url' => () => const Base64Codec.urlSafe().encode(bytes),
  'toHex' => () => hex.encode(bytes),
  'toString' => () => utf8.decode(bytes),
  _ => null,
};

dynamic _processIterable(Iterable target, String name) {
  dynamic result = switch (name) {
    'contains' => target.contains,
    'elementAt' => target.elementAt,
    'first' => target.first,
    'isEmpty' => target.isEmpty,
    'isNotEmpty' => target.isNotEmpty,
    'last' => target.last,
    'length' => target.length,
    'join' => target.join,
    'single' => target.single,
    'skip' => target.skip,
    'take' => target.take,
    'toList' => target.toList,
    'toSet' => target.toSet,
    _ => null,
  };

  if (target is List && result == null) {
    result = _processList(target, name);
  }

  return result;
}

dynamic _processJsonPath(JsonPath target, String name) => switch (name) {
  'read' => target.read,
  'readValues' => target.readValues,
  _ => null,
};

dynamic _processJsonPathMatch(JsonPathMatch target, String name) =>
    switch (name) {
      'path' => target.path,
      'value' => target.value,
      _ => null,
    };

dynamic _processList(List target, String name) {
  dynamic result = switch (name) {
    'asMap' => target.asMap,
    'reversed' => target.reversed,
    'path' => (path) => JsonPath(path).readValues(target).first,
    'sort' => () {
      target.sort((a, b) {
        var result = 0;

        if (a is Comparable && b is Comparable) {
          result = a.compareTo(b);
        } else if (a is num && b is num) {
          result = a < b ? -1 : (a == b ? 0 : 1);
        }

        return result;
      });

      return target;
    },

    'toJson' => ([padding]) {
      final indent = maybeParseInt(padding) ?? 0;

      return indent == 0
          ? json.encode(target)
          : JsonEncoder.withIndent(''.padLeft(indent, ' ')).convert(target);
    },
    _ => null,
  };

  if (result == null) {
    if (target is List<int>) {
      result = _processIntList(target, name);
    } else if (target is Uint8List) {
      result = _processIntList(target.toList(), name);
    }
  }

  return result;
}

dynamic _processLogger(Logger target, String name) => switch (name) {
  'finest' => target.finest,
  'finer' => target.finer,
  'fine' => target.fine,
  'config' => target.config,
  'info' => target.info,
  'warning' => target.warning,
  'severe' => target.severe,
  'shout' => target.shout,
  _ => null,
};

dynamic _processMap(Map target, String name) => switch (name) {
  'containsValue' => target.containsValue,
  'containsKey' => target.containsKey,
  'entries' => target.entries,
  'keys' => target.keys,
  'isEmpty' => target.isEmpty,
  'isNotEmpty' => target.isNotEmpty,
  'length' => target.length,
  'path' => (path) => JsonPath(path).readValues(target).first,
  'remove' => target.remove,
  'toJson' => ([padding]) {
    final indent = maybeParseInt(padding) ?? 0;

    return indent == 0
        ? json.encode(target)
        : JsonEncoder.withIndent(''.padLeft(indent, ' ')).convert(target);
  },
  'values' => target.values,
  _ => target[name],
};

dynamic _processMapEntry(MapEntry target, String name) => switch (name) {
  'key' => target.key,
  'value' => target.value,
  _ => null,
};

dynamic _processNum(num target, String name) => switch (name) {
  'abs' => target.abs,
  'ceil' => target.ceil,
  'ceilToDouble' => target.ceilToDouble,
  'clamp' => target.clamp,
  'compareTo' => target.compareTo,
  'floor' => target.floor,
  'floorToDouble' => target.floorToDouble,
  'format' => (format) => NumberFormat(format).format(target),
  'isFinite' => target.isFinite,
  'isInfinite' => target.isInfinite,
  'isNaN' => target.isNaN,
  'isNegative' => target.isNegative,
  'remainder' => target.remainder,
  'round' => target.round,
  'roundToDouble' => target.roundToDouble,
  'sign' => target.sign,
  'toDouble' => target.toDouble,
  'toInt' => target.toInt,
  'toStringAsExponential' => target.toStringAsExponential,
  'toStringAsFixed' => target.toStringAsFixed,
  'toStringAsPrecision' => target.toStringAsPrecision,
  'truncate' => target.truncate,
  'truncateToDouble' => target.truncateToDouble,
  _ => null,
};

dynamic _processNumberFormat(NumberFormat target, String name) =>
    switch (name) {
      'format' => target.format,
      'parse' => target.parse,
      _ => null,
    };

dynamic _processRsa(Rsa target, String name) => switch (name) {
  'aes' => target.aes,
  'decrypt' => target.decrypt,
  'encoding' => target.encoding,
  'encrypt' => target.encrypt,
  'privateKey' => target.privateKey,
  'publicKey' => target.publicKey,
  'sign' => target.sign,
  'verify' => target.verify,
  _ => null,
};

dynamic _processString(String target, String name) => switch (name) {
  'compareTo' => target.compareTo,
  'contains' => target.contains,
  'decode' => () => yaon.parse(target),
  'endsWith' => target.endsWith,
  'indexOf' => target.indexOf,
  'isEmpty' => target.isEmpty,
  'isNotEmpty' => target.isNotEmpty,
  'lastIndexOf' => target.lastIndexOf,
  'length' => target.length,
  'padLeft' => target.padLeft,
  'padRight' => target.padRight,
  'path' => (path) => JsonPath(path).readValues(yaon.parse(target)).first,
  'replaceAll' => target.replaceAll,
  'replaceFirst' => target.replaceFirst,
  'split' => target.split,
  'startsWith' => target.startsWith,
  'substring' => target.substring,
  'toBool' => target.toLowerCase() == 'true',
  'toLowerCase' => target.toLowerCase,
  'toDouble' => () => double.tryParse(target),
  'toInt' => () => double.tryParse(target)?.toInt(),
  'toUpperCase' => target.toUpperCase,
  'trim' => target.trim,
  'trimLeft' => target.trimLeft,
  'trimRight' => target.trimRight,
  _ => null,
};
