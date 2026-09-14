# Report fonts

The PDF report embeds its own fonts, because it is built on the device with no
network connection (PDF-4) and has to cover all six app languages (PDF-5).
Flutter's own text rendering does not use these; only `lib/services/pdf_*`
does.

| Font | Covers | Licence |
| --- | --- | --- |
| `Roboto-Regular.ttf`, `Roboto-Bold.ttf` | Latin, including Turkish, French, Spanish, and German | Apache License 2.0 — see `LICENSE-Roboto.txt` |
| `NotoSansArabic-Regular.ttf`, `NotoSansArabic-Bold.ttf` | Arabic | SIL Open Font License 1.1 — see `OFL.txt` |

Roboto is the copy that ships with the Flutter SDK
(`bin/cache/artifacts/material_fonts`). The Noto Sans Arabic files come from
[notofonts/noto-fonts](https://github.com/notofonts/noto-fonts)
(`hinted/ttf/NotoSansArabic`).

Static instances on purpose: the `pdf` package reads a TrueType file directly
and does not apply variable-font axes, so the variable `NotoSansArabic[wdth,wght].ttf`
would render every weight the same.
