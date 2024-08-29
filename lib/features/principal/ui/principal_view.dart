import 'package:flutter/material.dart';
import 'package:nimbuz_arm_robotic/features/principal/ui/widgets/left_panel_controls.dart';
import 'package:nimbuz_arm_robotic/features/principal/ui/widgets/right_panel_controls.dart';
import 'package:nimbuz_arm_robotic/features/principal/ui/widgets/slider_controls.dart';

class PrincipalView extends StatefulWidget {
  const PrincipalView({super.key});

  @override
  State<PrincipalView> createState() => _PrincipalViewState();
}

class _PrincipalViewState extends State<PrincipalView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Row(
            children: [
              LeftPanelCtrls(),
              SliderCtrls(),
              RightPanelCtrls(),
            ],
          ),
        ),
      ),
    );
  }
}
