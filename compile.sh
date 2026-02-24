#!/bin/bash
LATEXCMD="/usr/bin/lualatex"

$LATEXCMD --interaction=batchmode --output-directory="./output" "./main.tex" 
# bibtex "./output/main"
$LATEXCMD --interaction=batchmode --output-directory="./output" "./main.tex" 
$LATEXCMD --interaction=batchmode --output-directory="./output" "./main.tex" 
