// @license
// Copyright (c) 2019 - 2022 Dr. Gabriel Gatzsche. All Rights Reserved.
//
// Use of this source code is governed by terms that can be
// found in the LICENSE file in the root of this package.

import 'package:fake_async/fake_async.dart';
import 'package:gg_periodic_timer/gg_periodic_timer.dart';
import 'package:test/test.dart';

void main() {
  late GgPeriodicTimer periodicTimer;
  int counter = 0;
  const frameDuration = Duration(milliseconds: 120);
  late FakeAsync fake;
  var expectedCounter = 0;

  void init(FakeAsync fk) {
    expectedCounter = 0;
    fake = fk;
    counter = 0;

    periodicTimer = GgAutoPeriodicTimer(
      interval: frameDuration,
    );
    periodicTimer.addListener(() => counter++);
    fake.flushMicrotasks();
  }

  void dispose(FakeAsync fake) {
    fake.flushMicrotasks();
  }

  void testFiringTenTimes() {
    counter = 0;
    fake.elapse(frameDuration * 10);
    expectedCounter = 10;
    expect(counter, expectedCounter);
  }

  void testNotFiringTenTimes() {
    counter = 0;
    fake.elapse(frameDuration * 10);
    expectedCounter = 0;
    expect(counter, expectedCounter);
  }

  group('GgAutoPeriodicTimer', () {
    // #########################################################################
    group('start, stop, dispose', () {
      test('should start, stop calling timeFired', () {
        fakeAsync((fake) {
          init(fake);
          expect(periodicTimer, isNotNull);

          // Initially timerFired is not called
          expect(counter, expectedCounter);

          // Timer is not yet started.
          // Timer will not be fired.
          fake.elapse(const Duration(seconds: 10));
          expect(counter, expectedCounter);

          // Start the timer
          periodicTimer.start();

          // Wait a half frame => timer has not yet fired
          fake.elapse(frameDuration * 0.5);
          expect(counter, expectedCounter);

          // Wait another half frame => timer has fired
          fake.elapse(frameDuration * 0.5);
          expectedCounter++;
          expect(counter, expectedCounter);

          // Wait another ten freams => timer has fired ten times
          testFiringTenTimes();

          // Stop the timer again
          periodicTimer.stop();

          // Timer should not fire anymore
          testNotFiringTenTimes();

          // Start timer again
          periodicTimer.start();

          // Wait another ten freams => timer has fired ten times
          testFiringTenTimes();

          // Dispose the timer
          periodicTimer.dispose();

          // Timer should not fire anymore
          testNotFiringTenTimes();

          dispose(fake);
        });
      });
    });
  });

  group('GgManualPeriodicTimer', () {
    test('should trigger only if "trigger" is called and timer is running', () {
      var counter = 0;
      var expectedCounter = 0;
      final timer = GgPeriodicTimer();
      timer.addListener(
        () => counter++,
      );

      // Call fire -> onTimerFired will not be called because timer is not
      // started.
      timer.fire();
      expect(counter, expectedCounter);

      // Start timer
      timer.start();
      timer.fire();
      expect(counter, ++expectedCounter);

      // Stop timer -> fire will not trigger onTimerFired
      timer.stop();
      timer.fire();
      expect(counter, expectedCounter);
    });
  });

  group('addListener, removeListener', () {
    test('should allow to listen and unlisten to fire events', () {
      fakeAsync((fake) {
        var count0 = 0;
        void listener0() => count0++;

        var count1 = 0;
        void listener1() => count1++;

        final timer = GgPeriodicTimer();
        timer.start();

        // Add listener0 to timer
        timer.addListener(listener0);

        // Let timer fire
        timer.fire();

        // listener0 has been called, listener1 not, because it is not added
        expect(count0, 1);
        expect(count1, 0);

        // Add listener 1 to timer
        timer.addListener(listener1);

        // Let timer fire
        timer.fire();

        // Both listeners where called
        expect(count0, 2);
        expect(count1, 1);

        // Remove lister 0
        timer.removeListener(listener0);

        // Let timer fire
        timer.fire();

        // Only listener1 is fired, because listener0 is removed
        expect(count0, 2);
        expect(count1, 2);
      });
    });
  });
}
