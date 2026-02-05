import 'dart:ui' as ui;
import 'package:athan_app_v2/services/migration_service.dart';
import 'package:athan_app_v2/theme.dart';
import 'package:flutter/cupertino.dart';

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  final MigrationService _migrationService = MigrationService();
  final TextEditingController _jsonController = TextEditingController();
  bool _isLoading = false;
  MigrationResult? _result;
  List<String> _backups = [];

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    final backups = await _migrationService.getBackups();
    setState(() {
      _backups = backups;
    });
  }

  Future<void> _handleImport() async {
    if (_jsonController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    final result = await _migrationService.importFromJson(_jsonController.text);
    await _loadBackups(); // Refresh backups list after import (which creates a backup)

    setState(() {
      _isLoading = false;
      _result = result;
    });

    if (result.success && result.errors.isEmpty) {
      _showSuccessDialog(result.importedCount);
    }
  }

  Future<void> _handleRestore(String backupKey) async {
    final success = await _migrationService.restoreBackup(backupKey);
    if (success) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Restore Successful'),
            content: const Text('Data has been restored from backup.'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      }
    }
  }

  void _showSuccessDialog(int count) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Migration Successful'),
        content: Text('Successfully imported $count tasks.'),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Data Migration'),
          backgroundColor: colors.surface,
        ),
        backgroundColor: colors.background,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              Text(
                'Import Data',
                style: AppTextStyles.headlineSmall(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Paste the JSON content exported from the web app below:',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Use CupertinoTextField for consistency
              CupertinoTextField(
                controller: _jsonController,
                maxLines: 10,
                placeholder: '[{"id": "...", "title": "..."}]',
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CupertinoColors.white,
                  border: Border.all(color: CupertinoColors.systemGrey4),
                  borderRadius: BorderRadius.circular(8),
                ),
                style: const TextStyle(color: CupertinoColors.black),
              ),
              const SizedBox(height: AppSpacing.md),
              CupertinoButton.filled(
                onPressed: _isLoading ? null : _handleImport,
                child: _isLoading
                    ? const CupertinoActivityIndicator()
                    : const Text('Import Data'),
              ),

              if (_result != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _buildResultSection(colors),
              ],

              const SizedBox(height: AppSpacing.xl),
              Text(
                'Backups',
                style: AppTextStyles.headlineSmall(context),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_backups.isEmpty)
                Text(
                  'No backups found.',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: colors.textSecondary,
                  ),
                )
              else
                ..._backups.map((key) => _buildBackupItem(key, colors)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(AppColors colors) {
    if (_result!.success && _result!.errors.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: CupertinoColors.systemGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: CupertinoColors.systemGreen),
        ),
        child: Text(
          'Success! Imported ${_result!.importedCount} items.',
          style: const TextStyle(color: CupertinoColors.systemGreen),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: CupertinoColors.systemRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: CupertinoColors.systemRed),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import Completed with Errors (${_result!.importedCount} imported)',
            style: const TextStyle(
                color: CupertinoColors.systemRed, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          ..._result!.errors.take(5).map((e) => Text('• $e',
              style: const TextStyle(color: CupertinoColors.systemRed))),
          if (_result!.errors.length > 5)
            Text('...and ${_result!.errors.length - 5} more errors.',
                style: const TextStyle(color: CupertinoColors.systemRed)),
        ],
      ),
    );
  }

  Widget _buildBackupItem(String key, AppColors colors) {
    // Extract timestamp from key
    final timestampStr = key.replaceFirst('tasks_backup_', '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(CupertinoIcons.doc_text),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              timestampStr,
              style: AppTextStyles.bodyMedium(context),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Text('Restore'),
            onPressed: () => _handleRestore(key),
          ),
        ],
      ),
    );
  }
}
