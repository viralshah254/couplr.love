import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'data/partner_link_repository.dart';
import '../../theme/app_tokens.dart';

/// Partner linking: deep links, QR code, WhatsApp share, pending invites.
class PartnerLinkScreen extends ConsumerStatefulWidget {
  const PartnerLinkScreen({super.key});

  @override
  ConsumerState<PartnerLinkScreen> createState() => _PartnerLinkScreenState();
}

class _PartnerLinkScreenState extends ConsumerState<PartnerLinkScreen> {
  bool _isLoading = false;
  String? _error;
  bool _inviteSent = false;

  Future<void> _copyInviteLink() async {
    const link = 'https://couplr.app/join/abc123';
    await Clipboard.setData(ClipboardData(text: link));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite link copied')),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    const text = 'Join me on Couplr — our private relationship space. '
        'https://couplr.app/join/abc123';
    final uri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: '',
      queryParameters: {'text': text},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() => _inviteSent = true);
    } else {
      setState(() => _error = 'Could not open WhatsApp');
    }
  }

  Future<void> _markAsLinked() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = await ref.read(partnerLinkRepositoryProvider.future);
      await repo.setPartnerLinked(partnerId: 'partner-1', displayName: 'Partner');
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Invite your partner',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Share a link or QR code so they can join your Couplr space.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceVariantDark
                            : AppColors.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Text(
                          'QR code',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        QrImageView(
                          data: 'https://couplr.app/join/abc123',
                          version: QrVersions.auto,
                          size: 180,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Color(0xFF1C1C1C),
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Color(0xFF1C1C1C),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Partner scans to join',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: isDark
                                    ? AppColors.onSurfaceVariantDark
                                    : AppColors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton.icon(
                  onPressed: _copyInviteLink,
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Copy invite link'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _shareViaWhatsApp,
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Share via WhatsApp'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                ),
                if (_inviteSent)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Text(
                      'Invite sent. Waiting for partner to join…',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppColors.primaryDarkMode
                                : AppColors.primary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Already have a partner code?',
                  style: Theme.of(context).textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _isLoading ? null : _markAsLinked,
                  child: const Text('I\'ve linked with my partner — continue'),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
