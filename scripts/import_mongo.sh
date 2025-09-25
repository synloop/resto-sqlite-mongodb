#!/usr/bin/env bash
set -euo pipefail

DB="resto"
DIR="json_mongo"

echo "[Mongo] Import JSON vers db '$DB'…"
for f in "$DIR"/*.json; do
  coll=$(basename "$f" .json)
  echo "  -> $coll"
  mongoimport --db "$DB" --collection "$coll" --file "$f" --jsonArray
done
echo "OK."
