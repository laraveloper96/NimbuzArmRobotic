import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:nimbuz_arm_robotic/app/config/env.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/mqtt.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/options.dart';
import 'package:nimbuz_arm_robotic/core/mqtt/robot.dart';
import 'package:nimbuz_arm_robotic/core/robot_arm/models/robot_event.dart';

part 'principal_event.dart';
part 'principal_state.dart';

typedef PrincipalEmitter = Emitter<PrincipalState>;

class PrincipalBloc extends Bloc<PrincipalEvent, PrincipalState> {
  PrincipalBloc({
    required Mqtt mqtt,
  })  : _mqtt = mqtt,
        super(const Initial([])) {
    on<InitEv>(_onInit);
    on<AddRobotEv>(_onAddRobotEv);
    on<EnableRobotEv>(_onEnableRobotEv);
    on<SendCommandEv>(_onSendCommandEv);
  }

  final Mqtt _mqtt;
  Robot robotALL = Robot.all();
  // IAEvent? iaEvent;
  Timer? timer;

  Future<void> _onInit(InitEv ev, PrincipalEmitter emit) async {
    await _mqtt.connect(
      Options(
        host: Env.instance.ws,
        port: Env.instance.port,
        clientId: 'FlutterConf-Arequipa',
      ),
    );
    await _mqtt.subscribeTopic(Topic.human);
    _mqtt.onMessages().listen((robot) {
      add(AddRobotEv(robot));
    });
  }

  Future<void> _onAddRobotEv(AddRobotEv ev, PrincipalEmitter emit) async {
    final newlist = List<Robot>.from(state.robots);
    final search =
        newlist.indexWhere((el) => el.mac == ev.robot.mac && el.enable == true);
    print('😀 search:$search');
    if (search >= 0) {
      newlist.removeAt(search);
      newlist.add(ev.robot.copyWith(enable: true));
      return;
    }

    if (search == -1) {
      newlist.add(ev.robot);
    }

    robotALL = robotALL.copyWith(status: newlist.isNotEmpty);
    emit(NewRobot(newlist));
  }

  Future<void> _onEnableRobotEv(EnableRobotEv ev, PrincipalEmitter emit) async {
    // print(
    //     'entorl${ev.robot.clientID == robotALL.clientID} status:${ev.robot.status}');
    // if (ev.robot.clientID == robotALL.clientID && ev.robot.status) {
    //   final newList = List<Robot>.from(state.robots);
    //   for (var i = 0; i < newList.length; i++) {
    //     newList[i] = newList[i].copyWith(enable: false);
    //   }
    //   robotALL = robotALL.copyWith(enable: !ev.robot.enable);
    //   print('entorl');
    //   emit(NewRobot(newList));

    //   return;
    // }

    if (ev.robot.clientID != robotALL.clientID && ev.robot.status) {
      robotALL = robotALL.copyWith(enable: false);
      final index = state.robots.indexWhere((el) => el.mac == ev.robot.mac);
      if (index >= 0) {
        final newList = List<Robot>.from(state.robots);
        final status = !ev.robot.enable;
        newList[index] = newList.elementAt(index).copyWith(
              enable: status,
            );
        final robot = newList[index];
        emit(ChangedStatusRobot(newList,
            message:
                '[Robot] ${robot.name} ${status ? "Actived" : "Disabled"}'));
      }
    }
  }

  Future<void> _onSendCommandEv(SendCommandEv ev, PrincipalEmitter emit) async {
    if (ev.robotEvent.command == Command.none) return;

    // if (_mqtt.isConnect && robotALL.enable) {
    //   print('[MQTT] Message was sended');
    //   await _mqtt.sendMessage(
    //     topic: Topic.move,
    //     clientId: robotALL.clientID,
    //     command: ev.robotEvent.command.name,
    //     value: ev.robotEvent.value,
    //   );
    // }

    if (_mqtt.isConnect) {
      final robotsActive = state.robots.where((e) => e.enable);
      print('[MQTT] Found ${robotsActive.length} Robots Actived');
      for (final robot in robotsActive) {
        print('[MQTT] Message was sended');
        await _mqtt.sendMessage(
          topic: Topic.move,
          clientId: robot.clientID,
          command: ev.robotEvent.command.val,
          value: ev.robotEvent.value,
        );
      }
    }
  }
}
