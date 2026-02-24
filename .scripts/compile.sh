#!/bin/bash

# Set up the trap immediately to reset colors on exit
trap 'tput sgr0' EXIT

# --- Configuration ---
# Exit immediately if a command exits with a non-zero status.
set -e

# Check for texfot
if ! command -v texfot &> /dev/null; then
    echo "texfot could not be found. Please install texfot to proceed."
    exit 1
fi

# --- Argument Parsing ---
# Expected usage: bash compile.sh "main" "path/to/output.pdf" "aux_dir" "log_dir"

RAW_MAIN="$1"       # e.g., "main"
TARGET_PDF="$2"     # e.g., "release/monograph.pdf"
AUX_DIR="$3"        # e.g., "aux"
LOG_DIR="$4"        # e.g., ".log"

# Ensure the main file has the .tex extension for the compiler
if [[ "$RAW_MAIN" != *.tex ]]; then
    MAIN_FILE="${RAW_MAIN}.tex"
else
    MAIN_FILE="$RAW_MAIN"
fi

# Extract the basename (jobname) for intermediate files
# e.g., "main"
BASENAME=$(basename "$MAIN_FILE" .tex)

echo "------------------------------------------------"
echo "Target:      $MAIN_FILE"
echo "Output:      $TARGET_PDF"
echo "Working Dir: $AUX_DIR"
echo "------------------------------------------------"

# --- Compilation ---

# We use AUX_DIR as the -output-directory. 
# This keeps the root directory clean and keeps all .aux/.toc/.bbl files 
# in the persistent aux folder automatically.

echo "--- Pass 1: Initial Compile ---"
tput setaf 1
texfot pdflatex -draftmode \
                -interaction=nonstopmode \
                -output-directory="$AUX_DIR" \
                "$MAIN_FILE"
tput sgr0

# Check for citations in the generated aux file
if grep -q '\\citation' "$AUX_DIR/$BASENAME.aux"; then
    tput setaf 2
    echo "--- Running BibTeX ---"
    # Note: BibTeX needs to run on the file inside the aux directory
    bibtex "$AUX_DIR/$BASENAME"
    tput sgr0
fi

echo "--- Pass 2: Resolving References ---"
tput setaf 3
texfot pdflatex -draftmode \
                -interaction=nonstopmode \
                -output-directory="$AUX_DIR" \
                "$MAIN_FILE"
tput sgr0

echo "--- Pass 3: Final Output ---"
tput setaf 4
texfot pdflatex -interaction=nonstopmode \
                -output-directory="$AUX_DIR" \
                "$MAIN_FILE"
tput sgr0

# --- Post-Processing ---

echo "--- Finalizing ---"

# 1. Move the generated PDF to the specific target path
# We use 'cp' then 'rm' or 'mv'. 'mv' is atomic on same fs.
if [ -f "$AUX_DIR/$BASENAME.pdf" ]; then
    echo "Moving PDF to $TARGET_PDF"
    # Ensure target directory exists (safety check, even if guaranteed)
    mkdir -p "$(dirname "$TARGET_PDF")"
    mv "$AUX_DIR/$BASENAME.pdf" "$TARGET_PDF"
else
    echo "Error: PDF was not generated."
    exit 1
fi

# 2. Move logs to the LOG_DIR
echo "Moving logs to $LOG_DIR"
# We move the specific log files for this basename
mv "$AUX_DIR/$BASENAME.log" "$LOG_DIR/" 2>/dev/null || true
mv "$AUX_DIR/$BASENAME.out" "$LOG_DIR/" 2>/dev/null || true
mv "$AUX_DIR/$BASENAME.blg" "$LOG_DIR/" 2>/dev/null || true
# We intentionally leave .aux, .bbl, .toc in AUX_DIR to speed up future compilations

echo "Done."
