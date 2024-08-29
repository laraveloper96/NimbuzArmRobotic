import 'package:equatable/equatable.dart';

enum Command {
  none,
  shoulder,
  elbow,
  wrist,
  gripper,
  stop,
  save,
  play,
  reset,
  speed;

  static Command getCommand(String part) => switch (part) {
        ('gripper') => Command.gripper,
        ('wrist') => Command.wrist,
        ('elbow') => Command.elbow,
        ('shoulder') => Command.shoulder,
        ('play') => Command.play,
        ('save') => Command.save,
        ('stop') => Command.stop,
        ('reset') => Command.reset,
        ('speed') => Command.speed,
        (_) => Command.none,
      };
}

// enum Command {
//   none(0),
//   go(1),
//   stop(2),
//   left(3),
//   rigth(4),
//   sit(6),
//   greet(7),
//   tragedy(5);

//   const Command(this.value);
//   final int value;

// static Command getCommand(String gesture, PartOfArm part) {
//   // Open_Palm
//   // Pointing_Up
//   // Thumb_Up
//   // Thumb_Down
//   // Victory
//   // Closed_Fist
//   // ILoveYou

//   // print(hand);
//   switch (gesture) {
//     case 'Pointing_Up':
//       return Command.go;
//     case 'Open_Palm':
//       return Command.stop;
//     case 'Thumb_Up':
//       if (hand == Hand.left) {
//         return Command.left;
//       }
//       if (hand == Hand.rigth) {
//         return Command.rigth;
//       }
//       break;
//     case 'Thumb_Down':
//       return Command.none;
//     case 'Victory':
//       return Command.greet;
//     case 'Closed_Fist':
//       return Command.sit;
//     case 'ILoveYou':
//       return Command.tragedy;
//     default:
//       return Command.none;
//   }
//   return Command.none;
// }
// }

class RobotEvent extends Equatable {
  const RobotEvent(
    this.command,
    this.value,
  );

  final Command command;
  final int value;

  @override
  List<Object> get props => [
        command,
        value,
      ];
}
