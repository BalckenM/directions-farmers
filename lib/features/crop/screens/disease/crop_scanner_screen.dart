import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../providers/crop_providers.dart';

class CropScannerScreen extends ConsumerStatefulWidget {
  const CropScannerScreen({super.key});

  @override
  ConsumerState<CropScannerScreen> createState() => _CropScannerScreenState();
}

class _CropScannerScreenState extends ConsumerState<CropScannerScreen> {
  final _picker = ImagePicker();
  String? _imagePath;
  String? _selectedCropHint;
  bool _isAnalysing = false;

  static const _cropHints = [
    'maize',
    'soybean',
    'tomato',
    'potato',
    'wheat',
    'sorghum',
  ];

  Future<void> _pickImage(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (file == null) return;
    setState(() => _imagePath = file.path);
  }

  Future<void> _analyse() async {
    final path = _imagePath;
    if (path == null) return;

    setState(() => _isAnalysing = true);

    try {
      final result = await ref
          .read(diseaseRepositoryProvider)
          .detectDisease(imagePath: path, cropHint: _selectedCropHint);

      if (mounted) {
        context.push(AppRoutes.cropDiseaseResult, extra: result);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalysing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasImage = _imagePath != null;

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Crop Disease Scanner'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Info banner ──────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                borderRadius: AppRadius.card,
                border: Border.all(
                    color: AppColors.primary.withAlpha(50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.biotech_rounded,
                      color: AppColors.primary, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Leaf Analysis',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Take a clear photo of an affected leaf or plant. '
                          'The AI will identify diseases, pests, or deficiencies '
                          'and recommend treatments.',
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Image capture area ───────────────────────────────────────────
            GestureDetector(
              onTap: hasImage ? null : () => _showSourceSheet(),
              child: Container(
                height: 260,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: AppRadius.card,
                  border: Border.all(
                    color: hasImage
                        ? AppColors.primary.withAlpha(80)
                        : cs.outlineVariant,
                    width: hasImage ? 2 : 1,
                    style: hasImage ? BorderStyle.solid : BorderStyle.solid,
                  ),
                ),
                child: hasImage
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: AppRadius.card,
                            child: Image.network(
                              // Use network for cross-platform mock (file path)
                              // In real implementation this would be Image.file()
                              Uri.file(_imagePath!).toString(),
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _ImagePlaceholder(
                                label: 'Image captured',
                                icon: Icons.check_circle_rounded,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                          // Retake button overlay
                          Positioned(
                            top: AppSpacing.sm,
                            right: AppSpacing.sm,
                            child: GestureDetector(
                              onTap: _showSourceSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: AppSpacing.xs,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(160),
                                  borderRadius: AppRadius.chip,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.refresh_rounded,
                                        color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Retake',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : _ImagePlaceholder(
                        label: 'Tap to capture or upload a leaf photo',
                        icon: Icons.add_a_photo_rounded,
                        color: cs.onSurfaceVariant,
                      ),
              ),
            ),

            // ── Capture buttons ──────────────────────────────────────────────
            if (!hasImage) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Camera'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            // ── Crop type selector ───────────────────────────────────────────
            Text(
              'Crop Type (optional)',
              style: tt.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Selecting the crop type improves accuracy.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _CropChip(
                  label: 'Any crop',
                  selected: _selectedCropHint == null,
                  onTap: () => setState(() => _selectedCropHint = null),
                ),
                ..._cropHints.map(
                  (c) => _CropChip(
                    label: c[0].toUpperCase() + c.substring(1),
                    selected: _selectedCropHint == c,
                    onTap: () => setState(() => _selectedCropHint = c),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Tips ─────────────────────────────────────────────────────────
            _TipsCard(),

            const SizedBox(height: AppSpacing.xl),

            // ── Analyse button ───────────────────────────────────────────────
            FilledButton.icon(
              icon: _isAnalysing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search_rounded),
              label: Text(_isAnalysing ? 'Analysing...' : 'Analyse Plant'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cropGreen,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: hasImage && !_isAnalysing ? _analyse : null,
            ),

            const SizedBox(height: AppSpacing.md),

            Text(
              'Results are for guidance only. Consult a registered agricultural '
              'advisor for formal diagnosis and registered treatment recommendations.',
              style: tt.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 56, color: color.withAlpha(150)),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            label,
            style: tt.bodyMedium?.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _CropChip extends StatelessWidget {
  const _CropChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 2,
          vertical: AppSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.cropGreen.withAlpha(25)
              : Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: AppRadius.chip,
          border: Border.all(
            color: selected ? AppColors.cropGreen : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppColors.cropGreen
                : Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    const tips = [
      ('Good Lighting', 'Natural light or bright even lighting — avoid shadows'),
      ('Close-Up Leaf', 'Fill the frame with the affected leaf — 15–30 cm away'),
      ('Clear Focus', 'Ensure the photo is sharp — tap screen to focus'),
      ('Both Sides', 'Capture the underside of the leaf for best results'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tips_and_updates_outlined,
                  size: 16, color: AppColors.secondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Photo Tips for Best Results',
                style: tt.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...tips.map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.success),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface,
                        ),
                        children: [
                          TextSpan(
                            text: '${t.$1}: ',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: t.$2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
