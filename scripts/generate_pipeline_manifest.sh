#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to display usage information
usage() {
    echo "Usage: $0 <TEMPLATE_FILE> <OUTPUT_FILE> <PIPELINE_FILTER_CONFIG> <PIPELINE_INPUT_CONFIG> <PIPELINE_OUTPUT_CONFIG> <GH_COMMIT_SHA> <PIPELINE_TYPE>"
    exit 1
}

# Ensure all required arguments are provided
if [[ $# -ne 7 ]]; then
    usage
fi

# Assign command-line arguments to variables
TEMPLATE_FILE="$1"
OUTPUT_FILE="$2"
PIPELINE_FILTER_CONFIG="$3"
PIPELINE_INPUT_CONFIG="$4"
PIPELINE_OUTPUT_CONFIG="$5"
GH_COMMIT_SHA="$6"
PIPELINE_TYPE="$7"

# Ensure all required files exist
for file in "$TEMPLATE_FILE" "$PIPELINE_FILTER_CONFIG" "$PIPELINE_INPUT_CONFIG" "$PIPELINE_OUTPUT_CONFIG"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: File '$file' not found."
        exit 1
    fi
done

# Step 1: Replace placeholders in the template file
sed -e "s/COMMIT_SHA/\"${GH_COMMIT_SHA}\"/g" \
    -e "s/PIPELINE_TYPE/${PIPELINE_TYPE}/g" "$TEMPLATE_FILE" |

# Step 2: Insert combined pipeline config where PIPELINE_CONFIG is found
awk -v filter="$PIPELINE_FILTER_CONFIG" -v input="$PIPELINE_INPUT_CONFIG" -v output="$PIPELINE_OUTPUT_CONFIG" '
/PIPELINE_CONFIG/ {
    system("cat " input " " filter " " output " | sed \"s/^/        /\"");
    next
}
{ print }
' > "$OUTPUT_FILE"

# Print success message
echo "Pipeline file generated: $OUTPUT_FILE"
