#!/bin/bash

# --- compile-selection ---
# Universal script for macOS Quick Actions. Takes any number of file and/or
# folder paths as arguments and compiles their contents into a single text file.

# --- Configuration ---
OUTPUT_BASE_DIR="$HOME/Documents"
COMPILED_CODE_DIR="compiled-code"

# The introductory prompt to add at the top of the compiled file.
LLM_PROMPT="This is a single text file with many files compiled into it. Files are identified with their respective file path as follows: (i.e.)
✅ FILE: nhsj-employer-frontend/app/models/vacancy/vacancy-file-model.js
At the top of each file. This is not part of the code, its just to help you as the LLM to identify which file is which and navigate about
"

# List of directories to ignore.
PRUNE_DIRS=(
    "node_modules" "target" "dist" "build" "coverage" "__pycache__"
    ".gradle" ".mvn" ".github" ".husky" ".idea" ".vscode" ".cache"
    ".next" ".turbo" ".pnpm-store" ".yarn" ".terraform" "venv" ".venv"
    "acceptance-test" "reports" "logs" "cypress" "nhsbsa-jobs-ci-template"
)
# List of file extensions to ignore.
EXCLUDE_EXTENSIONS=(
    "png" "svg" "woff" "woff2" "ttf" "eot" "ico" "gif" "jpg" "jpeg"
    "pdf" "zip" "gz" "tar" "jar" "class" "exe" "dll" "so" "o" "a"
)
# List of file extensions to include.
INCLUDE_EXTENSIONS=(
    "js" "mjs" "cjs" "ts" "jsx" "tsx" "java" "kt" "scala" "groovy"
    "html" "css" "scss" "less" "json" "yml" "yaml" "xml" "properties"
    "sh" "bash" "zsh" "ps1" "md" "txt" "sql" "graphql" "gql" "tf" "py"
    "go" "rb" "php" "cs" "c" "cpp" "h" "hpp" "rs" "swift" "vue" "svelte"
    "Dockerfile" "toml" "ini" "cfg" "conf" "env"
)

# --- Script Logic ---
if [ "$#" -eq 0 ]; then exit 0; fi

FULL_OUTPUT_DIR="$OUTPUT_BASE_DIR/$COMPILED_CODE_DIR"
mkdir -p "$FULL_OUTPUT_DIR"

TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
OUTPUT_FILE="$FULL_OUTPUT_DIR/compiled-selection-${TIMESTAMP}.txt"

# Add the introductory prompt to the top of the file
echo "$LLM_PROMPT" > "$OUTPUT_FILE"
echo -e "\n\n" >> "$OUTPUT_FILE"

add_file_to_output() {
    local file_path="$1"
    echo "====================================================================" >> "$OUTPUT_FILE"
    echo "✅ FILE: $file_path" >> "$OUTPUT_FILE"
    echo "====================================================================" >> "$OUTPUT_FILE"
    cat "$file_path" >> "$OUTPUT_FILE"
    echo -e "\n\n" >> "$OUTPUT_FILE"
}

for item_path in "$@"; do
    if [ ! -e "$item_path" ]; then continue; fi

    if [ -d "$item_path" ]; then
        find_cmd_array=("find" "$item_path")
        find_cmd_array+=("-type" "f")
        find_cmd_array+=("(")
        first_ext=true
        for ext in "${INCLUDE_EXTENSIONS[@]}"; do
            if [ "$first_ext" = false ]; then find_cmd_array+=("-o"); fi
            find_cmd_array+=("-iname" "*.$ext")
            first_ext=false
        done
        find_cmd_array+=(")")
        for dir in "${PRUNE_DIRS[@]}"; do find_cmd_array+=("-not" "-path" "*/$dir/*"); done
        for ext in "${EXCLUDE_EXTENSIONS[@]}"; do find_cmd_array+=("-not" "-iname" "*.$ext"); done
        find_cmd_array+=("-print0")
        "${find_cmd_array[@]}" | while IFS= read -r -d '' file; do add_file_to_output "$file"; done
    elif [ -f "$item_path" ]; then
        add_file_to_output "$item_path"
    fi
done

if [ -s "$OUTPUT_FILE" ]; then
    file_count=$(grep -c "✅ FILE:" "$OUTPUT_FILE")
    if [ "$file_count" -gt 0 ]; then
        osascript -e "display notification \"Compiled $file_count item(s) successfully.\" with title \"Code Compilation Finished\""
    else
        # If only the prompt was added but no files, remove the file.
        rm "$OUTPUT_FILE"
    fi
else
    rm "$OUTPUT_FILE"
fi

exit 0