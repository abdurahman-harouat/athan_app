# Migration Guide: Roznama (Web) to Athan App (Flutter)

This guide details the process of migrating calendar event data from the legacy Roznama web application (Prisma/PostgreSQL) to the new Athan App (Flutter/SharedPreferences).

## 1. Architecture

The migration follows an **Export-Transform-Load (ETL)** pattern:

1.  **Export**: Extract data from the web application database into a portable JSON format.
2.  **Transform**: Map web data fields (`Event`) to mobile data models (`Task`), handling type conversions and logic adaptation (e.g., color to category).
3.  **Load**: Import the transformed data into the Flutter application's local storage.

### Data Mapping
See `MIGRATION_MAPPING.md` for detailed field-to-field mapping.

## 2. Prerequisites

- **Web App**: Node.js environment with access to the PostgreSQL database.
- **Mobile App**: Flutter development environment.
- **Data**: A valid JSON export file from the web app.

## 3. Step-by-Step Execution

### Phase 1: Export Data (Web)

**Option A: From Live Database**
1.  Navigate to the `roznama` directory.
2.  Install dependencies:
    ```bash
    npm install
    npx prisma generate
    ```
3.  Run the export script:
    ```bash
    npx ts-node scripts/export-events.ts
    ```
    *Output*: `migration_data.json` containing all calendar events.

**Option B: From SQL Dump (Backup)**
If you have a PostgreSQL dump file (e.g., `backup/calendar_db_dump.sql`):
1.  Navigate to the `roznama` directory.
2.  Run the parser script:
    ```bash
    npx ts-node scripts/parse-sql-dump.ts
    ```
3.  The script looks for `backup/calendar_db_dump.sql` and outputs to `../migration_data_from_dump.json`.

### Phase 2: Import Data (Mobile)
1.  Launch the Athan App.
2.  Go to **Settings** > **Data Management** > **Import Data from Web**.
3.  Copy the content of `migration_data.json` into the text field.
    *Note: For large datasets, consider transferring the file to the device and using a file picker (future enhancement).*
4.  Tap **Import**.
5.  Wait for the process to complete. A success dialog will show the number of imported tasks.

### Phase 3: Verification
1.  Check the "Success" dialog count against the record count in `migration_data.json`.
2.  Navigate to the Calendar/Home screen to visually verify the events appear on the correct dates.
3.  Verify task details (title, description, duration, category) for a sample of events.

## 4. Rollback & Recovery

The application automatically creates a backup of the existing local database *before* any import operation.

### To Restore a Backup:
1.  Go to **Settings** > **Data Management** > **Import Data from Web**.
2.  Scroll down to the **Backups** section.
3.  Tap on a backup item (identified by timestamp) to restore it.
4.  Confirm the action. The app will revert to the state at that timestamp.

## 5. Troubleshooting

| Issue | Cause | Resolution |
|-------|-------|------------|
| `Invalid JSON format` | The pasted text is not valid JSON. | Ensure the entire file content is copied without modification. |
| `End date is before start date` | Source data inconsistency. | The importer skips invalid records. Check the error log in the result dialog. |
| `Missing title/start/end` | Required fields are null. | The importer skips incomplete records. Fix data in the source DB or JSON file. |
| App crashes during import | Dataset too large for memory. | Split the JSON file into smaller chunks and import sequentially. |

## 6. Maintenance

- **Log Rotation**: Backups are currently stored indefinitely. Users should manually clear app data if storage usage becomes an issue, or a future update will implement auto-cleanup.
- **Schema Updates**: If the `Task` model changes, the `MigrationService.importFromJson` method must be updated to reflect the new structure.
