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
