part of 'home_full_bloc.dart';

/// Abstract class for all events that can be dispatched from the
/// HomeFull widget.
///
/// Events must be immutable and implement the [Equatable] interface.
class HomeFullEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Event that is dispatched when the HomeFull widget is first created.
class HomeFullInitialEvent extends HomeFullEvent {
  @override
  List<Object?> get props => [];
}

/// Event for updating the index in HomeFull.
class HomeFullUpdateIndexEvent extends HomeFullEvent {
  final int newIndex;

  HomeFullUpdateIndexEvent(this.newIndex);

  @override
  List<Object?> get props => [newIndex];
}

