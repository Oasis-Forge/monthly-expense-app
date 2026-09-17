---
name: l10n-add
description: Add, change, or remove app messages in all 21 languages at once (LANG-6) with one JSON file, without reading or editing the ARB files by hand. Use whenever a screen needs new or changed text.
---

There are 21 ARB files, 19–31 KB each, and the generated `app_localizations*.dart` are larger still: don't read them. To see an existing message, Grep its key with `path: lib/l10n`.

1. Write the messages to a JSON file in the scratchpad. Each key needs all 21 codes (`en ar bn zh nl fr de el hi id it ja ko pl pt ru es th tr ur vi`); `description` and `placeholders` are optional and go into `app_en.arb` only; `after` puts a new key next to a related one. `null` removes a key.
   ```json
   {
     "importDone": {
       "en": "{count, plural, =1{Imported 1 row.} other{Imported {count} rows.}}",
       "ar": "...", "bn": "...", "zh": "...", "nl": "...", "fr": "...",
       "de": "...", "el": "...", "hi": "...", "id": "...", "it": "...",
       "ja": "...", "ko": "...", "pl": "...", "pt": "...", "ru": "...",
       "es": "...", "th": "...", "tr": "...", "ur": "...", "vi": "...",
       "placeholders": {"count": {"type": "int"}},
       "after": "importButton"
     },
     "oldMessage": null
   }
   ```
2. `dart tool/add_messages.dart <file>`. It checks every key has all 21 languages and uses each declared placeholder, and writes nothing if anything is wrong.
3. `flutter gen-l10n`, then `flutter test test/l10n_test.dart`.

Writing the translations:
- Machine translations are fine; keep them as short as the English, since `test/languages_test.dart` fails on overflow at 1.3× text.
- Plurals: Arabic uses `=0`, `=1`, `=2`, `few`, `many`, `other`; Polish and Russian add `few` and `many`; Chinese, Japanese, Korean, Thai, Vietnamese and Indonesian have one form, so their `=1` and `other` read the same. Every case English uses must be present in every language, including `=0{...}` when English has it.
- Urdu is right to left like Arabic (LANG-5), but it is a different language: don't copy the Arabic across.
- Placeholder names stay in English in every language: `{count}`, never a translated name.
