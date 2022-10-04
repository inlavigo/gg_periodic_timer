import 'package:gg_periodic_timer/gg_periodic_timer.dart';

void main() async {
  //.............................................................
  /// Create a periodic timer that needs to be triggered manually.
  var timer = GgPeriodicTimer();

  /// Add a listener to the timer
  timer.addListener(() => print('Timer fired.'));

  /// Start the timer. Otherwise listeners are not triggered.
  timer.start();

  /// Call fire, to trigger listeners.
  timer.fire(); // Output: Timer fired.

  /// Stop the timer.
  timer.stop();

  /// Listeners will not be informed
  timer.fire(); // Output: Nothing

  /// Start timer again
  timer.start();

  /// Listeners will be triggered again.
  timer.fire(); // Output: Timer fired.

  //.............................................................
  /// Create a periodic timer is called automatically
  const oneFrame = Duration(milliseconds: 100);
  final autoTimer = GgAutoPeriodicTimer(interval: oneFrame);
  autoTimer.addListener(
    () => print('Auto timer fired.'),
  );

  /// Start the timer
  autoTimer.start();

  /// Wait five frames
  await Future.delayed(oneFrame * 5);

  /// Output:
  ///   Auto timer fired.
  ///   Auto timer fired.
  ///   Auto timer fired.
  ///   Auto timer fired.
  ///   Auto timer fired.
  ///
  autoTimer.stop();
}
