#!/bin/bash
# A small script to recompile the LaTeX document whenever a change is made to any of the source files.
# Usage: bash ./recompile_on_change.sh <main.tex> <output_dir/output.pdf> <aux_dir> <log_dir>


# Check if inotifywait exists. If not, print error and exit.
if ! command -v inotifywait &> /dev/null; then
    echo "Error: 'inotifywait' is not installed."
    exit 1
fi

while true; do
    # Watch for changes in the current directory, excluding certain file types
    inotifywait -e modify,create,delete -r . --exclude '(\.log|\.aux|\.pdf|\.monitor|\.justfile)'
    
    # Clear the terminal
    clear

    # Compile the LaTeX document
    bash .scripts/compile.sh $1 $2 $3 $4

    # Make sure that we don't do too many compilations in a short time
    sleep 1
done
