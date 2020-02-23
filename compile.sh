#!/bin/bash
set -ex
pdflatex drm.tex
nasm -f bin -o a.out tiny.asm
chmod +x a.out
cat a.out drm.pdf > new.pdf
