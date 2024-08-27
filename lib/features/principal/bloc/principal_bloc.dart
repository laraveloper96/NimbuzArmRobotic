import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nimbuz_arm_robotic/app/config/env.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/mqtt.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/options.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/robot.dart';

part 'principal_event.dart';
part 'principal_state.dart';

typedef PrincipalEmitter = Emitter<PrincipalState>;

class PrincipalBloc extends Bloc<PrincipalEvent, PrincipalState> {
  PrincipalBloc({
    required Mqtt mqtt,
  })  : _mqtt = mqtt,
        super(const Initial([])) {
    on<InitEv>(_onInit);
  }

  final Mqtt _mqtt;
  Robot robotALL = Robot.all();
  // IAEvent? iaEvent;
  Timer? timer;

  Future<void> _onInit(InitEv ev, PrincipalEmitter emit) async {
    print('host: ${Env.instance.ws}'
        'port: ${Env.instance.port}');
    await _mqtt.connect(
      Options(
        host: Env.instance.ws,
        port: Env.instance.port,
        clientId: 'FlutterConf-Arequipa',
      ),
    );
    // await _mqtt.subscribeTopic(Topic.human);
    // _mqtt.onMessages().listen((robot) {
    //   // add(AddRobotEv(robot));
    // });
  }
}
