#!/bin/bash
#set -x  # Keep debug on

TEMPLATE="template.cfg"
CSV="mac_mapping.csv"
OUTPUT_DIR="/var/www/html/provisioning"
PBX_IP=""IP""
SIP_PORT="5160"

mkdir -p "$OUTPUT_DIR"

# NEW: Use process substitution to ensure clean reading
while IFS=, read -r EXT MAC || [[ -n "$EXT" ]]; do
    echo "DEBUG: Read EXT='$EXT' MAC='$MAC'"
    [[ "$EXT" == "extension" || -z "$EXT" ]] && continue
    
    SECRET=$(mysql -u root -D asterisk -Bse "SELECT data FROM sip WHERE id = '$EXT' AND keyword = 'secret'")
    [ -z "$SECRET" ] && continue
    
    sed -e "s/{{EXTENSION}}/$EXT/g" \
        -e "s/{{SECRET}}/$SECRET/g" \
        -e "s/{{PBX_IP}}/$PBX_IP/g" \
        -e "s/{{SIP_PORT}}/$SIP_PORT/g" \
        "$TEMPLATE" > "$OUTPUT_DIR/${MAC}.cfg"
    
    echo "✅ Generated: $OUTPUT_DIR/${MAC}.cfg"
done < <(grep -v '^$' "$CSV")  # NEW: Skips empty lines