#!/bin/zsh

# Variables
MEMCACHED_HOST="127.0.0.1"
MEMCACHED_PORT="11211"
MONGO_URI="mongodb://127.0.0.1:27017"
DB_NAME="memcached_dump"
COLLECTION_NAME="cache_data"
touch /tmp/memcached_dump.json
TMP_FILE="/tmp/memcached_dump.json"

# Fetch all slabs from Memcached
echo "Fetching slabs from Memcached..."
SLABS=$(echo "stats items\nquit" | nc "$MEMCACHED_HOST" "$MEMCACHED_PORT" | grep "STAT items" | awk -F: '{ print $2 }' | awk '{ print $1 }' | sort -u)

# Initialize JSON file
echo "[" > "$TMP_FILE"

FIRST=true

# Iterate through slabs to dump keys and values
echo "$SLABS" | while read -r SLAB; do
    echo "Dumping slab $SLAB..."
    KEYS=$(echo "stats cachedump $SLAB 0\nquit" | nc "$MEMCACHED_HOST" "$MEMCACHED_PORT" | grep "ITEM" | awk '{print $2}')
    
    echo "$KEYS" | while read -r KEY; do
        VALUE=$(echo "get $KEY\nquit" | nc "$MEMCACHED_HOST" "$MEMCACHED_PORT" | sed -n '2p')
        
        #KEY_ESCAPED=$(echo "$KEY" | jq -R .)
        #VALUE_ESCAPED=$(echo "$VALUE" | jq -R .)
        
        # Append JSON data
        if $FIRST; then
            FIRST=false
        else
            echo "," >> "$TMP_FILE"
        fi

        jq -n --arg KEY $KEY --arg VAL $VALUE '{$KEY:$VAL}' >> "$TMP_FILE"
    done
done

# Close JSON array
echo "]" >> "$TMP_FILE"
# Import data into MongoDB
sed -i 's/\r//' /tmp/memcached_dump.json

echo "Importing data into MongoDB..."
mongoimport --uri="$MONGO_URI" --db="$DB_NAME" --collection="$COLLECTION_NAME" --file="$TMP_FILE" --jsonArray

# Clean up
rm "$TMP_FILE"

echo "Dump completed successfully."
