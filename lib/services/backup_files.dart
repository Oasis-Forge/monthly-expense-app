import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// File access for backups and exports. Files leave the device only through
/// a save dialog the user opens (BAK-6); automatic backups stay in the app's
/// own folder.
abstract class BackupFiles {
  /// Asks the user where to save [bytes]. False when they cancel.
  Future<bool> save(
    String fileName,
    Uint8List bytes, {
    required String mimeType,
  });

  /// Asks the user for a file and returns its bytes. Null when they cancel.
  Future<Uint8List?> open();

  /// Names of the automatic backups kept on the device.
  Future<List<String>> listKept();

  Future<String> readKept(String name);

  Future<void> writeKept(String name, String contents);

  Future<void> deleteKept(String name);
}

/// [BackupFiles] with the platform's file dialogs and the app support folder.
class DeviceBackupFiles implements BackupFiles {
  @override
  Future<bool> save(
    String fileName,
    Uint8List bytes, {
    required String mimeType,
  }) async {
    final saved = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: mimeType,
    );
    return saved != null;
  }

  @override
  Future<Uint8List?> open() async {
    final file = await FilePicker.pickFile();
    return file?.readAsBytes();
  }

  Future<Directory> _folder() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'backups')).create(recursive: true);
  }

  Future<File> _kept(String name) async =>
      File(p.join((await _folder()).path, name));

  @override
  Future<List<String>> listKept() async {
    final entries = await (await _folder()).list().toList();
    return [
      for (final entry in entries)
        if (entry is File) p.basename(entry.path),
    ];
  }

  @override
  Future<String> readKept(String name) async =>
      (await _kept(name)).readAsString();

  @override
  Future<void> writeKept(String name, String contents) async {
    await (await _kept(name)).writeAsString(contents, flush: true);
  }

  @override
  Future<void> deleteKept(String name) async {
    await (await _kept(name)).delete();
  }
}
