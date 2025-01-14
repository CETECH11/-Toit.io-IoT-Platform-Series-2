/*  */// Copyright (C) 2022 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/LICENSE file.

/**
Tests gpio pins.

Setup:
Connect pin 16 to pin 26, optionally with a 330 Ohm resistor to avoid short circuits.
*/

import gpio
import expect show *

PIN1 ::= 16
PIN2 ::= 26

main:
  pin1 := gpio.Pin PIN1
  pin2 := gpio.Pin PIN2

  // Test that we can close a pin and open it again.
  pin1.close
  pin2.close

  pin1 = gpio.Pin PIN1
  pin2 = gpio.Pin PIN2

  // Test pin configurations.

  pin1.configure --output
  pin2.configure --input

  expect_equals 0 pin2.get
  pin1.set 1
  expect_equals 1 pin2.get

  pin1.configure --input --pull_down
  expect_equals 0 pin1.get
  expect_equals 0 pin2.get

  pin1.configure --input --pull_up
  expect_equals 1 pin1.get
  expect_equals 1 pin2.get

  // Try the pull-down/pull-up again to ensure that we weren't just lucky.
  pin1.configure --input --pull_down
  expect_equals 0 pin1.get
  expect_equals 0 pin2.get

  pin1.configure --input --pull_up
  expect_equals 1 pin1.get
  expect_equals 1 pin2.get

  pin1.close

  // --- Test the same configurations through the constructor.

  pin1 = gpio.Pin PIN1 --input --pull_down
  expect_equals 0 pin1.get
  expect_equals 0 pin2.get
  pin1.close

  pin1 = gpio.Pin PIN1 --input --pull_up
  expect_equals 1 pin1.get
  expect_equals 1 pin2.get
  pin1.close

  // Try again.
  pin1 = gpio.Pin PIN1 --input --pull_down
  expect_equals 0 pin1.get
  expect_equals 0 pin2.get
  pin1.close

  pin1 = gpio.Pin PIN1 --input --pull_up
  expect_equals 1 pin1.get
  expect_equals 1 pin2.get
  pin1.close

  pin1 = gpio.Pin PIN1
  expect_throw "INVALID_ARGUMENT": pin1.configure --input --pull_up --pull_down
  expect_throw "INVALID_ARGUMENT": pin1.configure --output --pull_up --pull_down
  pin1.close

  expect_throw "INVALID_ARGUMENT": pin1 = gpio.Pin PIN1 --input --pull_up --pull_down
  expect_throw "INVALID_ARGUMENT": pin1 = gpio.Pin PIN1 --output --pull_up --pull_down


  pin1 = gpio.Pin PIN1

  pin1.configure --input --pull_up
  pin2.configure --output
  // Override the pull up of pin1
  pin2.set 0
  expect_equals 0 pin1.get
  pin2.set 1
  expect_equals 1 pin1.get

  pin1.configure --input --pull_down
  pin2.configure --output
  pin2.set 0
  expect_equals 0 pin1.get
  // Override the pull down of pin1
  pin2.set 1
  expect_equals 1 pin1.get

  pin1.configure --input --pull_up
  pin2.configure --input --output --open_drain

  expect_equals 1 pin1.get
  expect_equals 1 pin2.get

  pin2.set 0
  expect_equals 0 pin1.get
  expect_equals 0 pin2.get

  pin1.configure --input --output --open_drain --pull_up

  pin1.set 0
  pin2.set 0
  expect_equals 0 pin1.get
  expect_equals 0 pin2.get

  pin1.set 1
  pin2.set 0
  expect_equals 0 pin1.get
  expect_equals 0 pin2.get

  pin1.set 0
  pin2.set 1
  expect_equals 0 pin1.get
  expect_equals 0 pin2.get

  pin1.set 1
  pin2.set 1
  expect_equals 1 pin1.get
  expect_equals 1 pin2.get

  pin1.close
  pin2.close

  print "done"
