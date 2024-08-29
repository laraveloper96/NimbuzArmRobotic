part of 'principal_bloc.dart';

sealed class PrincipalState extends Equatable {
  const PrincipalState(this.robots);

  final List<Robot> robots;

  @override
  List<Object> get props => [robots];
}

final class Initial extends PrincipalState {
  const Initial(super.robots);

  @override
  List<Object> get props => [robots];
}

class NewRobot extends PrincipalState {
  const NewRobot(super.robots);

  @override
  List<Object> get props => [robots];
}

class ChangedStatusRobot extends PrincipalState {
  const ChangedStatusRobot(super.robots, {required this.message});

  final String message;
  @override
  List<Object> get props => [robots, message];
}
