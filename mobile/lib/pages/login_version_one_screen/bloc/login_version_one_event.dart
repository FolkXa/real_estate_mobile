part of 'login_version_one_bloc.dart';

/// Abstract class for all events that can be dispatched from the
/// LoginVersionOne widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class LoginVersionOneEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the LoginVersionOne widget is first created.
class LoginVersionOneInitialEvent extends LoginVersionOneEvent {
  @override
  List<Object?> get props => [1];
}

/// Event for changing password visibility
class ChangePasswordVisibilityEvent extends LoginVersionOneEvent {
  ChangePasswordVisibilityEvent({required this.value});

  final bool value;

  @override
  List<Object?> get props => [value];
}
