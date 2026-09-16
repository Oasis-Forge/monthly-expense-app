import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/attachment_service.dart';

/// The photo and the voice note on the transaction form (ATT-1). The file
/// names belong to the form, which saves them with the transaction; this
/// takes the photo, records the note, and plays it back.
class AttachmentField extends StatefulWidget {
  const AttachmentField({
    super.key,
    this.photoFile,
    this.voiceFile,
    required this.onPhotoChanged,
    required this.onVoiceChanged,
  });

  final String? photoFile;
  final String? voiceFile;
  final ValueChanged<String?> onPhotoChanged;
  final ValueChanged<String?> onVoiceChanged;

  @override
  State<AttachmentField> createState() => _AttachmentFieldState();
}

class _AttachmentFieldState extends State<AttachmentField> {
  /// Files this form made. One of these that is dropped before the form is
  /// saved is deleted here; a file the transaction already had is left to the
  /// provider, which deletes it once the change is saved (ATT-5).
  final _mine = <String>{};

  Timer? _countdown;
  Duration _left = AttachmentService.voiceLimit;
  bool _recording = false;
  bool _playing = false;
  StreamSubscription<bool>? _playback;

  AttachmentService get _attachments => context.read<AttachmentService>();

  @override
  void initState() {
    super.initState();
    _playback = _attachments.playing.listen((playing) {
      if (mounted) setState(() => _playing = playing);
    });
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _playback?.cancel();
    super.dispose();
  }

  Future<void> _dropIfMine(String? name) async {
    if (name != null && _mine.remove(name)) await _attachments.delete(name);
  }

  Future<void> _addPhoto(PhotoSource source) async {
    final old = widget.photoFile;
    final name = await _attachments.addPhoto(source);
    if (name == null) return;
    _mine.add(name);
    await _dropIfMine(old);
    widget.onPhotoChanged(name);
  }

  Future<void> _choosePhoto() async {
    final l10n = AppLocalizations.of(context);
    final phone =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    // Only a phone has a camera to offer; elsewhere the picker is a file
    // dialog (ATT-2).
    if (!phone) return _addPhoto(PhotoSource.gallery);

    final source = await showModalBottomSheet<PhotoSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.photoTake),
              onTap: () => Navigator.of(context).pop(PhotoSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.photoChoose),
              onTap: () => Navigator.of(context).pop(PhotoSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) await _addPhoto(source);
  }

  Future<void> _removePhoto() async {
    final old = widget.photoFile;
    widget.onPhotoChanged(null);
    await _dropIfMine(old);
  }

  Future<void> _startRecording() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (!await _attachments.startRecording()) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.microphoneRefused)));
      return;
    }
    setState(() {
      _recording = true;
      _left = AttachmentService.voiceLimit;
    });
    // A voice note stops on its own at the cap (ATT-4).
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = _left - const Duration(seconds: 1);
      if (left <= Duration.zero) {
        _stopRecording();
      } else {
        setState(() => _left = left);
      }
    });
  }

  Future<void> _stopRecording() async {
    _countdown?.cancel();
    final old = widget.voiceFile;
    final name = await _attachments.stopRecording();
    if (!mounted) return;
    setState(() => _recording = false);
    if (name == null) return;
    _mine.add(name);
    await _dropIfMine(old);
    widget.onVoiceChanged(name);
  }

  Future<void> _removeVoice() async {
    final old = widget.voiceFile;
    if (_playing) await _attachments.pausePlaying();
    widget.onVoiceChanged(null);
    await _dropIfMine(old);
  }

  Future<void> _togglePlay(String name) =>
      _playing ? _attachments.pausePlaying() : _attachments.play(name);

  void _openPhoto(String path) => showDialog<void>(
    context: context,
    builder: (_) =>
        Dialog(child: InteractiveViewer(child: Image.file(File(path)))),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.attachmentsLabel,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        _photoRow(l10n),
        const SizedBox(height: 8),
        _voiceRow(l10n),
      ],
    );
  }

  Widget _photoRow(AppLocalizations l10n) {
    final name = widget.photoFile;
    if (name == null) {
      return OutlinedButton.icon(
        onPressed: _choosePhoto,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: Text(l10n.photoAdd),
      );
    }
    return FutureBuilder<String>(
      future: _attachments.path(name),
      builder: (context, snapshot) {
        final path = snapshot.data;
        if (path == null) return const SizedBox(height: 72);
        return Row(
          children: [
            InkWell(
              onTap: () => _openPhoto(path),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(path),
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  // The file can be gone after a restore (ATT-7).
                  errorBuilder: (context, _, _) => Text(l10n.photoMissing),
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: l10n.photoRemove,
              onPressed: _removePhoto,
              icon: const Icon(Icons.close),
            ),
          ],
        );
      },
    );
  }

  Widget _voiceRow(AppLocalizations l10n) {
    if (_recording) {
      return Row(
        children: [
          FilledButton.icon(
            onPressed: _stopRecording,
            icon: const Icon(Icons.stop),
            label: Text(l10n.voiceStop),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(l10n.voiceRecording(_left.inSeconds))),
        ],
      );
    }
    final name = widget.voiceFile;
    if (name == null) {
      return OutlinedButton.icon(
        onPressed: _startRecording,
        icon: const Icon(Icons.mic_none),
        label: Text(l10n.voiceRecord),
      );
    }
    return FutureBuilder<bool>(
      future: _attachments.exists(name),
      builder: (context, snapshot) {
        final missing = snapshot.data == false;
        return Row(
          children: [
            if (!missing)
              IconButton(
                tooltip: _playing ? l10n.voicePause : l10n.voicePlay,
                onPressed: () => _togglePlay(name),
                icon: Icon(_playing ? Icons.pause : Icons.play_arrow),
              ),
            Expanded(
              child: Text(missing ? l10n.voiceMissing : l10n.voiceNoteLabel),
            ),
            IconButton(
              tooltip: l10n.voiceRemove,
              onPressed: _removeVoice,
              icon: const Icon(Icons.close),
            ),
          ],
        );
      },
    );
  }
}
