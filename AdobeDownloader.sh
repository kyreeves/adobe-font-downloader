#!/bin/bash

set -euo pipefail

# Get the current username
username=$(whoami)

# Paths
xml_folder="/Users/$username/Library/Application Support/Adobe/CoreSync/plugins/livetype/.c"
xml_file="$xml_folder/entitlements.xml"
source_folder="/Users/$username/Library/Application Support/Adobe/CoreSync/plugins/livetype/.w"
install_folder="/Users/$username/Library/Fonts"

# Validate that Adobe CoreSync has actually staged fonts on this machine
if [ ! -f "$xml_file" ]; then
    echo "ERROR: entitlements XML not found at:"
    echo "  $xml_file"
    echo "Make sure Adobe Creative Cloud is installed and you have activated at least one font family on the Adobe Fonts website."
    exit 1
fi

if [ ! -d "$source_folder" ]; then
    echo "ERROR: source font folder not found at:"
    echo "  $source_folder"
    echo "Make sure Adobe Creative Cloud is installed and you have activated at least one font family on the Adobe Fonts website."
    exit 1
fi

mkdir -p "$install_folder"

# Check whether a font is already installed
is_font_installed() {
    local font_name="$1"
    find "$install_folder" -name "$font_name.otf" 2>/dev/null | grep -q .
}

# Extract font metadata from the entitlements XML.
# Emits one "id:name" line per <font> entry.
# Name preference: fullName > familyName-style > familyName.
extract_font_info() {
    awk -F'[<>]' '
        /<font>/ {
            in_font = 1
            font_id = ""
            family_name = ""
            full_name = ""
            style = ""
        }
        in_font && /<id>/         { font_id = $3 }
        in_font && /<familyName>/ { family_name = $3 }
        in_font && /<fullName>/   { full_name = $3 }
        in_font && /<name>/ && !full_name { full_name = $3 }
        in_font && /<style>/      { style = $3 }
        in_font && /<\/font>/ {
            if (font_id != "") {
                if (full_name != "")
                    print font_id ":" full_name
                else if (family_name != "" && style != "")
                    print font_id ":" family_name "-" style
                else if (family_name != "")
                    print font_id ":" family_name
            }
            in_font = 0
        }
    ' "$xml_file"
}

echo "Extracting font metadata from XML..."
font_info=$(extract_font_info)

if [ -z "$font_info" ]; then
    echo "ERROR: Could not extract font metadata from XML"
    echo "First 50 lines of the XML:"
    head -50 "$xml_file"
    exit 1
fi

# Counters
copied=0
skipped=0

# Process each font file
for file in "$source_folder"/.*.otf; do
    [ -e "$file" ] || continue

    filename=$(basename "$file")
    font_id=${filename#.}
    font_id=${font_id%.otf}

    # Look up the human-readable name for this font ID
    font_name=$(printf '%s\n' "$font_info" | grep "^$font_id:" | cut -d: -f2- || true)

    if [ -n "$font_name" ]; then
        # Sanitize characters that are awkward in filenames
        safe_name=$(echo "$font_name" | tr '/' '-' | tr ' ' '_')

        if ! is_font_installed "$safe_name"; then
            cp "$file" "$install_folder/$safe_name.otf"
            echo "✓ Copied: $safe_name.otf"
            copied=$((copied + 1))
        else
            echo "○ Already installed: $safe_name.otf"
            skipped=$((skipped + 1))
        fi
    else
        echo "✗ No name found for ID: $font_id"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Done:"
echo "  • $copied fonts copied"
echo "  • $skipped fonts already installed"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
