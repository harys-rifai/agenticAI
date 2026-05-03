#!/bin/bash

set -e

echo "🚀 Setting up Agentic-Flow..."

# 1. Ensure dependencies are installed
npm install

# 2. Run migration
MIGRATION_FILE="packages/agentdb/src/db/migrations/003_composite_indexes.sql"
DB_PATH="agentdb.db"

echo "📦 Initializing database at $DB_PATH..."

# Create the DB file if it doesn't exist so migration can run
if [ ! -f "$DB_PATH" ]; then
  echo "   Database not found — creating fresh $DB_PATH..."
  node -e "
    import('better-sqlite3').then(({ default: Database }) => {
      const db = new Database('$DB_PATH');
      db.pragma('journal_mode = WAL');
      db.close();
      console.log('   ✅ Created $DB_PATH');
    }).catch(e => {
      console.error('   ❌ Could not create DB:', e.message);
      process.exit(1);
    });
  "
fi

# Apply the migration
if [ -f "$MIGRATION_FILE" ]; then
  echo "   Applying migration: $MIGRATION_FILE"
  npx tsx packages/agentdb/src/db/migrations/apply-migration.ts "$DB_PATH" "$MIGRATION_FILE"
else
  echo "⚠️  Migration file not found at $MIGRATION_FILE — skipping."
fi

# 3. Start the frontend dev server (uses Vite, no 'dev' script in root package.json)
echo "⚡ Starting development server on http://localhost:5173 ..."
npx vite
