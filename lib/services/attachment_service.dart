import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

/// Where a photo comes from (ATT-2).
enum PhotoSource { camera, gallery }

/// The platform side of attachments: the photo picker, the recorder, and the
/// folder the files live in. [DeviceAttachmentFiles] is the real one; tests
/// pass their own.
abstract class AttachmentFiles {
  /// A photo from the camera or the photo library, downscaled on the way in
  /// (ATT-3). Null when the user backs out or refuses the permission.
  Future<String?> pickPhoto(PhotoSource source);

  /// Starts recording into [path]. False when the microphone is refused.
  Future<bool> startRecording(String path);

  /// Stops recording and returns the file written, or null if there is none.
  Future<String?> stopRecording();

  /// Throws the recording away.
  Future<void> cancelRecording();

  /// Plays the file at [path], or resumes it.
  Future<void> play(String path);

  Future<void> pausePlaying();

  /// True while a voice note is playing.
  Stream<bool> get playing;

  /// The folder attachments are kept in, created if it isn't there.
  Future<Directory> directory();
}

/// [AttachmentFiles] with the system photo picker, the device microphone, and
/// a folder inside the app's own storage.
class DeviceAttachmentFiles implements AttachmentFiles {
  // Made on first use: building one touches a platform channel, and the
  // provider holds a service even where nothing is ever attached.
  late final _picker = ImagePicker();
  late final _recorder = AudioRecorder();
  late final _player = AudioPlayer();

  @override
  Future<String?> pickPhoto(PhotoSource source) async {
    final photo = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: AttachmentService.photoMaxSide,
      maxHeight: AttachmentService.photoMaxSide,
      imageQuality: 85,
    );
    return photo?.path;
  }

  @override
  Future<bool> startRecording(String path) async {
    if (!await _recorder.hasPermission()) return false;
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        numChannels: 1,
      ),
      path: path,
    );
    return true;
  }

  @override
  Future<String?> stopRecording() => _recorder.stop();

  @override
  Future<void> cancelRecording() => _recorder.cancel();

  @override
  Future<void> play(String path) => _player.play(DeviceFileSource(path));

  @override
  Future<void> pausePlaying() => _player.pause();

  @override
  Stream<bool> get playing =>
      _player.onPlayerStateChanged.map((state) => state == PlayerState.playing);

  @override
  Future<Directory> directory() async {
    final support = await getApplicationSupportDirectory();
    return Directory(p.join(support.path, 'attachments'))
        .create(recursive: true);
  }
}

/// Photos and voice notes kept in the app's own storage (ATT-2). A record
/// stores only the file name; this turns that into a file.
class AttachmentService {
  AttachmentService({
    AttachmentFiles? files,
    String Function()? newName,
    bool? galleryGivesCopy,
  }) : _files = files ?? DeviceAttachmentFiles(),
       _newName = newName ?? const Uuid().v4,
       _galleryGivesCopy =
           galleryGivesCopy ?? (Platform.isAndroid || Platform.isIOS);

  final AttachmentFiles _files;
  final String Function() _newName;

  /// Whether a photo picked from the gallery arrives as the picker's own
  /// copy. On Android and iOS it does; on the desktop the picker hands back
  /// the user's file itself, which must never be deleted (ATT-3).
  final bool _galleryGivesCopy;

  /// The longest side a stored photo keeps (ATT-3).
  static const photoMaxSide = 1600.0;

  /// How long a voice note may run (ATT-4).
  static const voiceLimit = Duration(seconds: 60);

  String? _recording;

  /// Picks a photo, copies it in, and returns its file name. Null when the
  /// user backs out.
  Future<String?> addPhoto(PhotoSource source) async {
    final picked = await _files.pickPhoto(source);
    if (picked == null) return null;
    final name = '${_newName()}.jpg';
    final source0 = File(picked);
    await source0.copy(await path(name));
    if (source == PhotoSource.gallery && !_galleryGivesCopy) return name;
    try {
      await source0.delete();
    } on FileSystemException {
      // The picker's copy is in a cache the system clears anyway.
    }
    return name;
  }

  /// Starts a recording. False when the microphone is refused.
  Future<bool> startRecording() async {
    final name = '${_newName()}.m4a';
    final started = await _files.startRecording(await path(name));
    _recording = started ? name : null;
    return started;
  }

  /// Stops a recording and returns its file name, or null if nothing was
  /// recorded.
  Future<String?> stopRecording() async {
    final written = await _files.stopRecording();
    final name = _recording;
    _recording = null;
    return written == null ? null : name;
  }

  /// Throws away a recording in progress, file and all.
  Future<void> cancelRecording() async {
    await _files.cancelRecording();
    await delete(_recording);
    _recording = null;
  }

  /// Plays the voice note [name], or resumes it.
  Future<void> play(String name) async => _files.play(await path(name));

  Future<void> pausePlaying() => _files.pausePlaying();

  /// True while a voice note is playing.
  Stream<bool> get playing => _files.playing;

  /// The full path of [name] in the attachments folder. Throws if [name]
  /// would resolve outside it: every caller is expected to pass this app's
  /// own uuid.ext name (ATT-2), and a backup restore checks this before it
  /// ever reaches here (data-integrity#10), but this is the last line of
  /// defense against a name that slips through as a path.
  Future<String> path(String name) async {
    if (name.contains('/') ||
        name.contains(r'\') ||
        name == '.' ||
        name == '..') {
      throw ArgumentError.value(
        name,
        'name',
        'must be a bare file name, not a path',
      );
    }
    return p.join((await _files.directory()).path, name);
  }

  Future<bool> exists(String name) async => File(await path(name)).exists();

  Future<Uint8List> read(String name) async =>
      File(await path(name)).readAsBytes();

  Future<void> write(String name, List<int> bytes) async =>
      File(await path(name)).writeAsBytes(bytes, flush: true);

  /// Deletes [name] if it is there. Null and missing files are ignored, so a
  /// record whose file has gone still deletes cleanly (ATT-7).
  Future<void> delete(String? name) async {
    if (name == null) return;
    final file = File(await path(name));
    if (await file.exists()) await file.delete();
  }

  Future<void> deleteAll(Iterable<String?> names) async {
    for (final name in names) {
      await delete(name);
    }
  }

  /// What every attachment adds up to, for the size a backup will be (ATT-6).
  Future<int> totalBytes() async {
    var total = 0;
    await for (final entry in (await _files.directory()).list()) {
      if (entry is File) total += await entry.length();
    }
    return total;
  }
}
