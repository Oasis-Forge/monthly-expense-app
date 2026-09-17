# Report fonts

The PDF report embeds its own fonts, because it is built on the device with no
network connection (PDF-4) and has to cover the app's languages (PDF-5).
Flutter's own text rendering does not use these; only `lib/services/pdf_*`
does.

| Font | Covers | Licence |
| --- | --- | --- |
| `Roboto-Regular.ttf`, `Roboto-Bold.ttf` | Latin, Greek, and Cyrillic: English, Dutch, French, German, Greek, Indonesian, Italian, Polish, Portuguese, Russian, Spanish, Turkish, and Vietnamese | Apache License 2.0 — see `LICENSE-Roboto.txt` |
| `NotoSansArabic-Regular.ttf`, `NotoSansArabic-Bold.ttf` | Arabic and Urdu | SIL Open Font License 1.1 — see `OFL.txt` |
| `NotoSansDevanagari-Regular.ttf`, `NotoSansDevanagari-Bold.ttf` | Hindi | SIL Open Font License 1.1 — see `OFL.txt` |
| `NotoSansBengali-Regular.ttf`, `NotoSansBengali-Bold.ttf` | Bengali | SIL Open Font License 1.1 — see `OFL.txt` |
| `NotoSansThai-Regular.ttf`, `NotoSansThai-Bold.ttf` | Thai | SIL Open Font License 1.1 — see `OFL.txt` |

Roboto is the copy that ships with the Flutter SDK
(`bin/cache/artifacts/material_fonts`). The Noto files come from
[notofonts](https://github.com/notofonts/notofonts.github.io)
(`fonts/<family>/hinted/ttf`).

Chinese, Japanese, and Korean have no face here. The smallest usable ones are
9.6–17.8 MB each and no single file covers all three, which would more than
double what a user downloads — for a report, in three of twenty-one
languages. `ReportFonts.unsupportedLanguages` names them, and the report says
so rather than printing empty boxes (PDF-7).

Static instances on purpose: the `pdf` package reads a TrueType file directly
and does not apply variable-font axes, so a variable `NotoSans…[wght].ttf`
would render every weight the same.
