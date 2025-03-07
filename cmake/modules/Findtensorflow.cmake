
#    Copyright (c) 2021 Vivante Corporation
#
#    Permission is hereby granted, free of charge, to any person obtaining a
#    copy of this software and associated documentation files (the "Software"),
#    to deal in the Software without restriction, including without limitation
#    the rights to use, copy, modify, merge, publish, distribute, sublicense,
#    and/or sell copies of the Software, and to permit persons to whom the
#    Software is furnished to do so, subject to the following conditions:
#
#    The above copyright notice and this permission notice shall be included in
#    all copies or substantial portions of the Software.
#
#    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#    DEALINGS IN THE SOFTWARE
#
include(FetchContent)
FetchContent_Declare(
  tensorflow
  GIT_REPOSITORY https://github.com/tensorflow/tensorflow.git
  GIT_TAG v2.11.0
)
FetchContent_GetProperties(tensorflow)
if(NOT tensorflow_POPULATED)
  FetchContent_Populate(tensorflow)
endif()
add_subdirectory("${tensorflow_SOURCE_DIR}/tensorflow/lite"
                 "${tensorflow_BINARY_DIR}")
get_target_property(TFLITE_SOURCE_DIR tensorflow-lite SOURCE_DIR)

if(TFLITE_LIB_LOC)
  message(STATUS "Will use prebuild tensorflow lite library from ${TFLITE_LIB_LOC}")
  if(NOT EXISTS ${TFLITE_LIB_LOC})
    message(FATAL_ERROR "tensorflow-lite library not found: ${TFLITE_LIB_LOC}")
  endif()
  add_library(TensorFlow::tensorflow-lite UNKNOWN IMPORTED)
  set_target_properties(TensorFlow::tensorflow-lite PROPERTIES
    IMPORTED_LOCATION ${TFLITE_LIB_LOC}
    INTERFACE_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:tensorflow-lite,INTERFACE_INCLUDE_DIRECTORIES>
  )
  set_target_properties(tensorflow-lite PROPERTIES EXCLUDE_FROM_ALL TRUE)
else()
  add_library(TensorFlow::tensorflow-lite ALIAS tensorflow-lite)
endif()


list(APPEND VX_DELEGATE_DEPENDENCIES TensorFlow::tensorflow-lite)
list(APPEND VX_DELEGATES_SRCS ${TFLITE_SOURCE_DIR}/tools/command_line_flags.cc)
list(APPEND VX_CUSTOM_OP_SRCS ${TFLITE_SOURCE_DIR}/delegates/external/external_delegate.cc)

