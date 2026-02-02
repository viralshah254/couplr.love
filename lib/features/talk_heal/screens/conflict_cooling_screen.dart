import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/conflict_repair_repository.dart';
import '../widgets/cooling_timer_widget.dart';

const _sessionId = 'repair-1';
const _coolingSeconds = 10;

/// Cooling period before joint session. On complete, loads joint steps and navigates to session.
class ConflictCoolingScreen extends ConsumerStatefulWidget {
  const ConflictCoolingScreen({super.key});

  @override
  ConsumerState<ConflictCoolingScreen> createState() =>
      _ConflictCoolingScreenState();
}

class _ConflictCoolingScreenState extends ConsumerState<ConflictCoolingScreen> {
  bool _loading = false;

  Future<void> _onComplete() async {
    if (_loading) return;
    setState(() => _loading = true);
    final repo = ref.read(conflictRepairRepositoryProvider);
    await repo.getJointSessionSteps(_sessionId);
    if (!mounted) return;
    ref.invalidate(conflictRepairSessionProvider(_sessionId));
    context.go('/talk/repair/session');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CoolingTimerWidget(
              totalSeconds: _coolingSeconds,
              onComplete: _onComplete,
            ),
    );
  }
}
