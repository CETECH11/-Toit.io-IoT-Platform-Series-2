# Copyright (C) 2021 Toitware ApS.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; version
# 2.1 only.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# The license can be found in the file `LICENSE` in the top level
# directory of this repository.

file(GLOB TOITP_TESTS "*_toitp_test.toit")

set(TOITP_TEST_DIR ${CMAKE_BINARY_DIR}/toitp_test)

include(fail.cmake)
include("${TOIT_SDK_SOURCE_DIR}/tools/toit.cmake")

set(TOITP_SOURCE "${TOIT_SDK_SOURCE_DIR}/tools/toitp.toit")
set(TOITP_EXE "${CMAKE_CURRENT_BINARY_DIR}/toitp${CMAKE_EXECUTABLE_SUFFIX}")
set(TOITP_DEP "${CMAKE_CURRENT_BINARY_DIR}/toitp.dep")

# For simplicity build the toitp executable for this test.
# We could try to use the one that is build in the tools directory but this approach is easier.
ADD_TOIT_EXE(
  ${TOITP_SOURCE}
  ${TOITP_EXE}
  ${TOITP_DEP}
  "")

add_custom_target(build_test_toitp_exe DEPENDS ${TOITP_EXE})
add_dependencies(check build_test_toitp_exe)
add_dependencies(check_slow build_test_toitp_exe)

foreach(file ${TOITP_TESTS})
  get_filename_component(base ${file} NAME_WE)
  string(REGEX REPLACE "_toitp_test$" "" test_name ${base})
  set(input ${CMAKE_CURRENT_SOURCE_DIR}/${test_name}_input.toit)
  set(toitp_test ${CMAKE_CURRENT_SOURCE_DIR}/${test_name}_toitp_test.toit)
  set(snap_test ${CMAKE_CURRENT_SOURCE_DIR}/${test_name}_snap_test.toit)

  set(snap ${TOITP_TEST_DIR}/${test_name}_input.snap)
  set(dep ${TOITP_TEST_DIR}/${test_name}_input.dep)

  ADD_TOIT_SNAPSHOT(
    ${input}
    ${snap}
    ${dep}
    "")


  set(build_snap tests-toitp-build_${test_name}_input)
  add_custom_target(${build_snap} DEPENDS ${snap})

  # Make sure the test input is built before we run the tests.
  add_dependencies(check ${build_snap})
  add_dependencies(check_slow ${build_snap})

  file(RELATIVE_PATH toitp_test_name ${TOIT_SDK_SOURCE_DIR} ${toitp_test})
  if (NOT "${toitp_test_name}" IN_LIST TOIT_SKIP_TESTS)
    add_test(
      NAME ${toitp_test_name}
      COMMAND $<TARGET_FILE:toit.run> ${toitp_test} ${snap} $<TARGET_FILE:toit.run> ${TOITP_EXE}
      DEPENDS ${TOITP_EXE}
      )
    set_tests_properties(${toitp_test_name} PROPERTIES TIMEOUT 40)
    if ("${toitp_test_name}" IN_LIST TOIT_FAILING_TESTS)
      set_tests_properties(${toitp_test_name} PROPERTIES WILL_FAIL TRUE)
    endif()
  endif()

  file(RELATIVE_PATH snap_test_name ${TOIT_SDK_SOURCE_DIR} ${snap_test})
  if (NOT "${snap_test_name}" IN_LIST TOIT_SKIP_TESTS)
    add_test(
      NAME ${snap_test_name}
      COMMAND $<TARGET_FILE:toit.run> ${snap_test} ${snap}
      )
    set_tests_properties(${snap_test_name} PROPERTIES TIMEOUT 40)
    if ("${snap_test_name}" IN_LIST TOIT_FAILING_TESTS)
      set_tests_properties(${snap_test_name} PROPERTIES WILL_FAIL TRUE)
    endif()
  endif()
endforeach()
