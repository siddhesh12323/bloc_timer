import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:bloc_timer/ticker.dart';
import 'package:bloc_timer/timer/bloc/timer_state.dart';

part 'timer_event.dart';
//part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  static const int _duration = 60;

  StreamSubscription<int>?  _tickerSubscription;

  TimerBloc({required Ticker ticker}) : _ticker = ticker, super(TimerInitialState(_duration)) {
    on<TimerStartedEvent>(_onStarted);
    on<TimerTickedEvent>(_onTicked);
    on<TimerPausedEvent>(_onPaused);
    on<TimerResetEvent>(_onReset);
    on<TimerResumedEvent>(_onResumed);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  void _onStarted(TimerStartedEvent event, Emitter<TimerState> emit) {
    emit(TimerRunInProgressState(event.duration));
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker.tick(ticks: event.duration).listen((duration) => add(TimerTickedEvent(duration: duration)));
  }

  void _onTicked(TimerTickedEvent event, Emitter<TimerState> emit) {
    emit(event.duration > 0 ? TimerRunInProgressState(event.duration) : TimerRunCompleteState());
  }

  void _onPaused(TimerPausedEvent event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgressState) {
      _tickerSubscription?.pause();
      emit(TimerRunPauseState(state.duration));
    }
  }

  void _onResumed(TimerResumedEvent event, Emitter<TimerState> emit) {
    if (state is TimerRunPauseState) {
      _tickerSubscription?.resume();
      emit(TimerRunInProgressState(state.duration));
    }
  }

  void _onReset(TimerResetEvent event, Emitter<TimerState> emit) {
    _tickerSubscription?.cancel();
    emit(TimerInitialState(_duration));
  }
}