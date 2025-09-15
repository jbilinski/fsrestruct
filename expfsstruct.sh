#!/bin/bash

# Target directory to analyze
# Set SOURCE_DIR from the first argument, or print usage and exit if not provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <source_directory>"
    exit 1
fi
RECREATE_FILES=false
for arg in "$@"; do
    if [[ "$arg" == "--with-files" ]]; then
        RECREATE_FILES=true
        break
    fi
done
# Remove trailing slash from SOURCE_DIR if present
SOURCE_DIR="${1%/}"

# Output script file
OUTPUT_SCRIPT="recreate_fs.sh"


# Find all directories and create mkdir commands
find "$SOURCE_DIR" -type d -print0 | while IFS= read -r -d $'\0' dir; do
    relative_dir="${dir#"$SOURCE_DIR"}"
    if [[ -n "$relative_dir" ]]; then
        echo "mkdir -p \".${relative_dir}\"" >> "$OUTPUT_SCRIPT"
        
        # Get ownership and permissions for directories
        owner=$(stat -c "%U" "$dir")
        group=$(stat -c "%G" "$dir")
        permissions=$(stat -c "%a" "$dir")
        echo "chown ${owner}:${group} \".${relative_dir}\"" >> "$OUTPUT_SCRIPT"
        echo "chmod ${permissions} \".${relative_dir}\"" >> "$OUTPUT_SCRIPT"
    fi
done
# Only recreate files if --with-files flag is provided
if $RECREATE_FILES; then
    find "$SOURCE_DIR" -type f -print0 | while IFS= read -r -d $'\0' file; do
        relative_file="${file#"$SOURCE_DIR"}"
        # Remove leading slash if present
        relative_file="${relative_file#/}"
        if [[ -n "$relative_file" ]]; then
            # Create touch command to ensure file exists for ownership/permissions
            echo "touch \".${relative_file}\"" >> "$OUTPUT_SCRIPT"
            # Get ownership and permissions for files
            owner=$(stat -c "%U" "$file")
            group=$(stat -c "%G" "$file")
            permissions=$(stat -c "%a" "$file")
            echo "chown ${owner}:${group} \".${relative_file}\"" >> "$OUTPUT_SCRIPT"
            echo "chmod ${permissions} \".${relative_file}\"" >> "$OUTPUT_SCRIPT"
        fi
    done
fi
# Find all symlinks and create ln -s commands
find "$SOURCE_DIR" -type l -print0 | while IFS= read -r -d $'\0' link; do
    relative_link="${link#"$SOURCE_DIR"}"
    # Remove leading slash if present
    relative_link="${relative_link#/}"
    if [[ -n "$relative_link" ]]; then
        target=$(readlink "$link")
        # Write ln -s command to recreate the symlink
        echo "ln -sf \"${target}\" \".${relative_link}\"" >> "$OUTPUT_SCRIPT"
    fi
done

echo "Script '$OUTPUT_SCRIPT' created successfully." >&2
