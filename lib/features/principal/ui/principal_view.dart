import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nimbuz_arm_robotic/core/utils/debouncer.dart';
import 'package:nimbuz_arm_robotic/features/principal/ui/widgets/left_panel_controls.dart';
import 'package:nimbuz_arm_robotic/features/principal/ui/widgets/right_panel_controls.dart';
import 'package:nimbuz_arm_robotic/features/principal/ui/widgets/slider_controls.dart';

class PrincipalView extends StatefulWidget {
  const PrincipalView({super.key});

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  late Debouncer _debouncer;
  @override
  void initState() {
    super.initState();
    _debouncer = context.read<Debouncer>();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const LeftPanelCtrls(),
              SliderCtrls(
                debouncer: _debouncer,
              ),
              const RightPanelCtrls(),
            ],
          ),
        ),
      ),
    );
  }
}
