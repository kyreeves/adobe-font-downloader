#!/bin/bash

# Obtenir le nom d'utilisateur
username=$(whoami)

# Chemins
xml_folder="/Users/$username/Library/Application Support/Adobe/CoreSync/plugins/livetype/.c"
xml_file="$xml_folder/entitlements.xml"
source_folder="/Users/$username/Library/Application Support/Adobe/CoreSync/plugins/livetype/.w"
install_folder="/Users/$username/Library/Fonts"

# Fonction pour vérifier si une police est installée
is_font_installed() {
    local font_name="$1"
    find "$install_folder" -name "$font_name.otf" 2>/dev/null | grep -q .
}

# Fonction pour extraire les informations du XML
extract_font_info() {
    local xml_content=$(cat "$xml_file")
    echo "$xml_content" | awk -F'[<>]' '
        /<font>/ {
            in_font=1
            font_id=""
            family_name=""
            full_name=""
            style=""
        }
        in_font && /<id>/ {font_id=$3}
        in_font && /<familyName>/ {family_name=$3}
        in_font && /<fullName>/ {full_name=$3}
        in_font && /<name>/ && !full_name {full_name=$3}
        in_font && /<style>/ {style=$3}
        in_font && /<\/font>/ {
            if (font_id != "") {
                # Préférence: fullName > familyName+style > familyName
                if (full_name != "")
                    print font_id ":" full_name
                else if (family_name != "" && style != "")
                    print font_id ":" family_name "-" style
                else if (family_name != "")
                    print font_id ":" family_name
            }
            in_font=0
        }
    '
}

# Extraire les informations des polices
echo "Extraction des informations du XML..."
font_info=$(extract_font_info)

if [ -z "$font_info" ]; then
    echo "ERREUR: Impossible d'extraire les informations du XML"
    echo "Structure du XML:"
    head -50 "$xml_file"
    exit 1
fi

# Compteur
copied=0
skipped=0

# Traiter chaque fichier de police
for file in "$source_folder"/.*.otf; do
    [ -e "$file" ] || continue
    
    filename=$(basename "$file")
    font_id=${filename#.}
    font_id=${font_id%.otf}
    
    # Chercher le nom correspondant à l'ID
    font_name=$(echo "$font_info" | grep "^$font_id:" | cut -d: -f2-)
    
    if [ -n "$font_name" ]; then
        # Nettoyer les caractères problématiques du nom
        safe_name=$(echo "$font_name" | tr '/' '-' | tr ' ' '_')
        
        if ! is_font_installed "$safe_name"; then
            cp "$file" "$install_folder/$safe_name.otf"
            echo "✓ Copié: $safe_name.otf"
            ((copied++))
        else
            echo "○ Déjà installé: $safe_name.otf"
            ((skipped++))
        fi
    else
        echo "✗ Nom non trouvé pour ID: $font_id"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Opération terminée:"
echo "  • $copied polices copiées"
echo "  • $skipped polices déjà installées"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"