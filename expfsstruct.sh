#!/bin/bash

# Target directory to analyze
# Set SOURCE_DIR from the first argument, or print usage and exit if not provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <source_directory>"
    exit 1
fi
# Remove trailing slash from SOURCE_DIR if present
SOURCE_DIR="${1%/}"

# Output script file

# Function to escape special characters for sed
escape_sed() {
    echo "$1" | sed -e 's/[\/&]/\\&/g'
}

# Find all directories and create mkdir commands
find "$SOURCE_DIR" -type d -print0 | while IFS= read -r -d $'\0' dir; do
    relative_dir="${dir#$SOURCE_DIR}"
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

# Find all files and create chown and chmod commands
    relative_file="${file#$SOURCE_DIR}"
    # Remove leading slash if present
    relative_file="${relative_file#/}"
    if [[ -n "$relative_file" ]]; then
        # Create touch command to ensure file exists for ownership/permissions
        echo "touch \".${relative_file}\"" >> "$OUTPUT_SCRIPT"
        echo "touch \".${relative_file}\"" >> "$OUTPUT_SCRIPT"

        # Get ownership and permissions for files
        owner=$(stat -c "%U" "$file")
        group=$(stat -c "%G" "$file")
        permissions=$(stat -c "%a" "$file")
        echo "chown ${owner}:${group} \".${relative_file}\"" >> "$OUTPUT_SCRIPT"
        echo "chmod ${permissions} \".${relative_file}\"" >> "$OUTPUT_SCRIPT"
    fi
done

    relative_link="${link#$SOURCE_DIR}"
    if [[ -n "$relative_link" ]]; then
        target=$(readlink "$link")
        # Resolve the absolute path of the symlink target
        abs_target=$(realpath -m --relative-to="$(dirname "$link")" "$target")
        # Compute the relative path from the new symlink location to the target
        rel_target=$(realpath -m --relative-to="$(dirname ".$relative_link")" "$abs_target")
        echo "ln -s \"${rel_target}\" \".${relative_link}\"" >> "$OUTPUT_SCRIPT"
    fi
echo "Script '$OUTPUT_SCRIPT' created successfully." >&2}\"" >> "$OUTPUT_SCRIPT"
    fi
done

echo "Script '$OUTPUT_SCRIPT' created successfully."
