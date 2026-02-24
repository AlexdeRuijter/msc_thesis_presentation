#!/bin/bash
# A small script to recompile the LaTeX document whenever a change is made to any of the source files.
# Usage: bash ./recompile_on_change.sh <main.tex> <output_dir/output.pdf> <aux_dir> <log_dir>


# Check if inotifywait exists. If not, print error and exit.
if ! command -v inotifywait &> /dev/null; then
    echo "Error: 'inotifywait' is not installed."
    exit 1
fi

echo "Watching for changes in the current directory. Press Ctrl+C to stop."

# Watch for changes in the current directory, excluding certain file types
inotifywait -m -e modify,create,delete -r . --exclude '(\.log|\.aux|\.pdf|\.monitor|\.justfile|\.git|\.scripts|\.*.sw?|\.gitignore)' \
| while read -r directory events filename; do
    # Clear the terminal
    clear

    # Print a message indicating that a change was detected
    echo "Change detected at $(date). Recompiling and continuing to watch for changes..."

    # Compile the LaTeX document
    bash .scripts/compile.sh $1 $2 $3 $4

    # Empty the pipe to prevent multiple compilations if multiple changes are detected in quick succession
    while read -t 0.1 -u 0 discard; do :; done
    echo "Watching for changes in the current directory. Press Ctrl+C to stop."

done
