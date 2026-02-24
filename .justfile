# Define variables for directories and main file
export MAIN            :="main"
export RELEASE_NAME    :="monograph"
export RELEASE_DIR     :="release"
export AUX_DIR         :="aux" 
export LOG_DIR         :=".log"
export MONITOR_DIR     :=".monitor"


# Create the general directories for the project
@create_dirs:
    echo "Creating necessary directories..."
    mkdir -p "$AUX_DIR" "$LOG_DIR"

# Create the monitor directory for tracking changes
@create_monitor_dir: create_dirs
    mkdir -p "$MONITOR_DIR"

# Check and create the necessary directories for the release process
@create_release_dirs: create_dirs
    mkdir -p "$RELEASE_DIR"
    
# Compile the monograph into PDF for distribution
@release: create_release_dirs 
    echo "Compiling the monograph for release..."
    bash .scripts/compile.sh "$MAIN" "$PDF_DIR/$RELEASE_NAME.pdf" "$AUX_DIR" "$LOG_DIR"

@watch: create_monitor_dir
    # Compile the monograph for the first time to ensure the PDF is available for viewing
    bash .scripts/compile.sh "$MAIN" "$MONITOR_DIR/$MAIN.pdf" "$AUX_DIR" "$LOG_DIR"
    
    # Open the compiled PDF in Zathura for real-time monitoring
    zathura "$MONITOR_DIR/$MAIN.pdf" &

    # Start watching for changes in the source files and recompile when changes are detected
    bash .scripts/recompile_on_change.sh "$MAIN" "$MONITOR_DIR/$MAIN.pdf" "$AUX_DIR" "$LOG_DIR"

@clean:
    echo "Cleaning auxiliary files..."
    rm -rf "$AUX_DIR"/* "$LOG_DIR"/*

