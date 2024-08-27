part of 'principal_bloc.dart';

sealed class PrincipalEvent extends Equatable {
  const PrincipalEvent();

  @override
  List<Object> get props => [];
}

final class InitEv extends PrincipalEvent {}
