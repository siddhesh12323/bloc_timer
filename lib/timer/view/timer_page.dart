import 'package:bloc_timer/ticker.dart';
import 'package:bloc_timer/timer/bloc/timer_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/timer_state.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TimerBloc(ticker: Ticker()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Timer')),
      body: const Stack(
        children: [
          Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.symmetric(vertical: 100), child: Center(child: TimerText(),),),
              Actions(),
            ],
          )
        ],
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);
    final minutesStr = ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text('$minutesStr:$secondsStr', style: Theme.of(context).textTheme.displayLarge,);
  }
}

class Actions extends StatelessWidget {
  const Actions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: (prev, state) => prev.runtimeType != state.runtimeType,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ...switch (state) {
                TimerInitialState() => [
                  FloatingActionButton(
                    child: const Icon(Icons.play_arrow),
                    onPressed: () {
                      context.read<TimerBloc>().add(TimerStartedEvent(duration: state.duration));
                    },
                  )
                ],
                TimerRunInProgressState() => [
                  FloatingActionButton(
                    child: const Icon(Icons.pause),
                    onPressed: () => context.read<TimerBloc>().add(TimerPausedEvent()),
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.replay),
                    onPressed: () => context.read<TimerBloc>().add(TimerResetEvent()),
                  )
                ],
                TimerRunPauseState() => [
                  FloatingActionButton(
                    child: const Icon(Icons.play_arrow),
                    onPressed: () => context.read<TimerBloc>().add(TimerResumedEvent()),
                  ),
                  FloatingActionButton(
                    child: const Icon(Icons.replay),
                    onPressed: () => context.read<TimerBloc>().add(TimerResetEvent()),
                  )
                ],
                TimerRunCompleteState() => [
                  FloatingActionButton(
                    child: const Icon(Icons.replay),
                    onPressed: () => context.read<TimerBloc>().add(TimerResetEvent()),
                  )
                ]
            }
          ],
        );
      },
    );
  }
}

class Background extends StatelessWidget {
  const Background({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade500
          ]
        )
      ),
    );
  }
}