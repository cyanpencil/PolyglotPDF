# PolyglotPDF
A PDF that is also an ELF. A crack-me challenge developed for BjornCTF 2020

---

This PDF contains an encrypted flag that can be decrypted by *executing* the pdf and providing the correct password as an argument.

The pdf is created from `drm.tex`. The ELF is created from `tiny.asm`. Run `compile.sh` to compile both and generate the polyglot.
