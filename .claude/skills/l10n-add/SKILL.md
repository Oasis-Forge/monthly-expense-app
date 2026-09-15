---
name: l10n-add
description: Add, change, or remove app messages in all six languages at once (LANG-6) with one JSON file, without reading or editing the ARB files by hand. Use whenever a screen needs new or changed text.
---

The ARB files are 19–26 KB each and the generated `app_localizations*.dart` are larger: don't read them. To see an existing message, Grep its key with `path: lib/l10n`.

1. Write the messages to a JSON file in the scratchpad. Each key needs `en`, `tr`, `ar`, `fr`, `es`, and `de`; `description` and `placeholders` are optional and go into `app_en.arb` only; `after` puts a new key next to a related one. `null` removes a key.
   ```json
   {
     "importDone": {
       "en": "{count, plural, =1{Imported 1 row.} other{Imported {count} rows.}}",
       "tr": "...", "ar": "...", "fr": "...", "es": "...", "de": "...",
       "placeholders": {"count": {"type": "int"}},
       "after": "importButton"
     },
     "oldMessage": null
   }
   ```
2. `dart tool/add_messages.dart <file>`. It checks every key has all six languages and uses each declared placeholder, and writes nothing if anything is wrong.
3. `flutter gen-l10n`, then `flutter test test/l10n_test.dart`.

Writing the translations:
- Machine translations are fine; keep them as short as the English, since `test/languages_test.dart` fails on overflow at 1.3× text.
- Plurals: Arabic uses `=0`, `=1`, `=2`, `few`, `many`, `other`; the other languages `=1` (or `one`) and `other`. Add `=0{...}` in every language when English has it.
- Placeholder names stay in English in every language: `{count}`, never a translated name.
