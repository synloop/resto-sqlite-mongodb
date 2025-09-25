#!/usr/bin/env bash
set -euo pipefail

DB="restaurant.db"

echo "[1/2] Création de la base SQLite…"
rm -f "$DB"
sqlite3 "$DB" < restaurant.sql

echo "[2/2] Sanity-check : tables & contenu"
sqlite3 "$DB" <<'SQL'
.tables
SELECT COUNT(*) AS nb_resto FROM RESTAURANT;
SELECT COUNT(*) AS nb_clients FROM CLIENT;
SELECT name, sql FROM sqlite_master WHERE type='trigger';
SQL

echo "OK."
