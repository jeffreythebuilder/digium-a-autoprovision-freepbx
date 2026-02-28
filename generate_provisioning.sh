#!/bin/bash
#set -x  # Keep debug on

TEMPLATE="template.cfg"
CSV="mac_mapping.csv"
OUTPUT_DIR="/var/www/html/provisioning"
PBX_IP="192.168.22.2"
SIP_PORT="5060"

mkdir -p "$OUTPUT_DIR"

# NEW: Use process substitution to ensure clean reading
while IFS=, read -r EXT MAC || [[ -n "$EXT" ]]; do
    [[ "$EXT" == "extension" || -z "$EXT" ]] && continue

    # Clean and normalize MAC: lowercase, no spaces/colons/hyphens
    MAC_CLEAN=$(echo "$MAC" | tr -d '[:space:]:-' | tr '[:upper:]' '[:lower:]')

    # Validate MAC: must be exactly 12 lowercase hex characters
    if [[ ! "$MAC_CLEAN" =~ ^[0-9a-f]{12}$ ]]; then
        echo "⚠️  WARNING: Invalid MAC '$MAC' (cleaned: '$MAC_CLEAN') — skipped"
        continue
    fi

    SECRET=$(mysql -u root -D asterisk -Bse "SELECT data FROM sip WHERE id = '$EXT' AND keyword = 'secret'")

    if [ -z "$SECRET" ]; then
        echo "⚠️  WARNING: No secret found for extension $EXT — skipped"
        continue
    fi

    sed -e "s/{{EXTENSION}}/$EXT/g" \
        -e "s/{{SECRET}}/$SECRET/g" \
        -e "s/{{PBX_IP}}/$PBX_IP/g" \
        -e "s/{{SIP_PORT}}/$SIP_PORT/g" \
        "$TEMPLATE" > "$OUTPUT_DIR/${MAC_CLEAN}.cfg"

    echo "✅ Generated: $OUTPUT_DIR/${MAC_CLEAN}.cfg"
done < <(grep -v '^$' "$CSV")
