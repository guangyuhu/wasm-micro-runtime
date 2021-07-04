# Copyright (C) 2019 Intel Corporation.  All rights reserved.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

string(TOUPPER ${WAMR_BUILD_TARGET} WAMR_BUILD_TARGET)


# Add definitions for the build target
if (WAMR_BUILD_TARGET STREQUAL "X86_64")
  add_definitions(-DBUILD_TARGET_X86_64)
elseif (WAMR_BUILD_TARGET STREQUAL "AMD_64")
  add_definitions(-DBUILD_TARGET_AMD_64)
elseif (WAMR_BUILD_TARGET STREQUAL "X86_32")
  add_definitions(-DBUILD_TARGET_X86_32)
elseif (WAMR_BUILD_TARGET MATCHES "ARM.*")
  if (WAMR_BUILD_TARGET MATCHES "(ARM.*)_VFP")
    add_definitions(-DBUILD_TARGET_ARM_VFP)
    add_definitions(-DBUILD_TARGET="${CMAKE_MATCH_1}")
  else ()
    add_definitions(-DBUILD_TARGET_ARM)
    add_definitions(-DBUILD_TARGET="${WAMR_BUILD_TARGET}")
  endif ()
elseif (WAMR_BUILD_TARGET MATCHES "THUMB.*")
  if (WAMR_BUILD_TARGET MATCHES "(THUMB.*)_VFP")
    add_definitions(-DBUILD_TARGET_THUMB_VFP)
    add_definitions(-DBUILD_TARGET="${CMAKE_MATCH_1}")
  else ()
    add_definitions(-DBUILD_TARGET_THUMB)
    add_definitions(-DBUILD_TARGET="${WAMR_BUILD_TARGET}")
  endif ()
elseif (WAMR_BUILD_TARGET MATCHES "AARCH64.*")
  add_definitions(-DBUILD_TARGET_AARCH64)
  add_definitions(-DBUILD_TARGET="${WAMR_BUILD_TARGET}")
elseif (WAMR_BUILD_TARGET STREQUAL "MIPS")
  add_definitions(-DBUILD_TARGET_MIPS)
elseif (WAMR_BUILD_TARGET STREQUAL "XTENSA")
  add_definitions(-DBUILD_TARGET_XTENSA)
elseif (WAMR_BUILD_TARGET STREQUAL "RISCV64" OR WAMR_BUILD_TARGET STREQUAL "RISCV64_LP64D")
  add_definitions(-DBUILD_TARGET_RISCV64_LP64D)
elseif (WAMR_BUILD_TARGET STREQUAL "RISCV64_LP64")
  add_definitions(-DBUILD_TARGET_RISCV64_LP64)
elseif (WAMR_BUILD_TARGET STREQUAL "RISCV32" OR WAMR_BUILD_TARGET STREQUAL "RISCV32_ILP32D")
  add_definitions(-DBUILD_TARGET_RISCV32_ILP32D)
elseif (WAMR_BUILD_TARGET STREQUAL "RISCV32_ILP32")
  add_definitions(-DBUILD_TARGET_RISCV32_ILP32)
else ()
  message (FATAL_ERROR "-- WAMR build target isn't set")
endif ()

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
  add_definitions(-DBH_DEBUG=1)
endif ()

if (CMAKE_SIZEOF_VOID_P EQUAL 8)
  if (WAMR_BUILD_TARGET STREQUAL "X86_64" OR WAMR_BUILD_TARGET STREQUAL "AMD_64" OR WAMR_BUILD_TARGET MATCHES "AARCH64.*" OR WAMR_BUILD_TARGET MATCHES "RISCV64.*")
    if (NOT WAMR_BUILD_PLATFORM STREQUAL "windows")
      # Add -fPIC flag if build as 64-bit
      set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC")
      set (CMAKE_SHARED_LIBRARY_LINK_C_FLAGS "${CMAKE_SHARED_LIBRARY_LINK_C_FLAGS} -fPIC")
    endif ()
  else ()
    add_definitions (-m32)
    set (CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -m32")
    set (CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -m32")
  endif ()
endif ()

if (WAMR_BUILD_TARGET MATCHES "ARM.*")
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -marm")
elseif (WAMR_BUILD_TARGET MATCHES "THUMB.*")
  set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -mthumb")
  set (CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -Wa,-mthumb")
endif ()

if (NOT WAMR_BUILD_INTERP EQUAL 1)
if (NOT WAMR_BUILD_AOT EQUAL 1)
  message (FATAL_ERROR "-- WAMR Interpreter and AOT must be enabled at least one")
endif ()
endif ()

if (WAMR_BUILD_JIT EQUAL 1)
  if (WAMR_BUILD_AOT EQUAL 1)
    add_definitions("-DWASM_ENABLE_JIT=1")
    if (NOT DEFINED LLVM_DIR)
      set (LLVM_SRC_ROOT "${WAMR_ROOT_DIR}/core/deps/llvm")
      set (LLVM_BUILD_ROOT "${LLVM_SRC_ROOT}/build")
      if (WAMR_BUILD_PLATFORM STREQUAL "windows")
        set (LLVM_BUILD_ROOT "${LLVM_SRC_ROOT}/win32build")
      endif ()
      if (NOT EXISTS "${LLVM_BUILD_ROOT}")
        message (FATAL_ERROR "Cannot find LLVM dir: ${LLVM_BUILD_ROOT}")
      endif ()
      set (CMAKE_PREFIX_PATH "${LLVM_BUILD_ROOT};${CMAKE_PREFIX_PATH}")
    endif ()
    find_package(LLVM REQUIRED CONFIG)
    include_directories(${LLVM_INCLUDE_DIRS})
    add_definitions(${LLVM_DEFINITIONS})
    message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
    message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")
  else ()
    set (WAMR_BUILD_JIT 0)
    message ("-- WAMR JIT disabled due to WAMR AOT is disabled")
 endif ()
else ()
  unset (LLVM_AVAILABLE_LIBS)
endif ()

message ("-- Build Configurations:")
message ("     Build as target ${WAMR_BUILD_TARGET}")
message ("     CMAKE_BUILD_TYPE " ${CMAKE_BUILD_TYPE})
if (WAMR_BUILD_INTERP EQUAL 1)
  message ("     WAMR Interpreter enabled")
else ()
  message ("     WAMR Interpreter disabled")
endif ()
if (WAMR_BUILD_AOT EQUAL 1)
  message ("     WAMR AOT enabled")
else ()
  message ("     WAMR AOT disabled")
endif ()
if (WAMR_BUILD_JIT EQUAL 1)
  message ("     WAMR JIT enabled")
else ()
  message ("     WAMR JIT disabled")
endif ()
if (WAMR_BUILD_LIBC_BUILTIN EQUAL 1)
  message ("     Libc builtin enabled")
else ()
  message ("     Libc builtin disabled")
endif ()
if (WAMR_BUILD_LIBC_UVWASI EQUAL 1)
  message ("     Libc WASI enabled with uvwasi implementation")
elseif (WAMR_BUILD_LIBC_WASI EQUAL 1)
  message ("     Libc WASI enabled")
else ()
  message ("     Libc WASI disabled")
endif ()
if (WAMR_BUILD_FAST_INTERP EQUAL 1)
  add_definitions (-DWASM_ENABLE_FAST_INTERP=1)
  message ("     Fast interpreter enabled")
else ()
  add_definitions (-DWASM_ENABLE_FAST_INTERP=0)
  message ("     Fast interpreter disabled")
endif ()
if (WAMR_BUILD_MULTI_MODULE EQUAL 1)
  add_definitions (-DWASM_ENABLE_MULTI_MODULE=1)
  message ("     Multiple modules enabled")
else ()
  add_definitions (-DWASM_ENABLE_MULTI_MODULE=0)
  message ("     Multiple modules disabled")
endif ()
if (WAMR_BUILD_SPEC_TEST EQUAL 1)
  add_definitions (-DWASM_ENABLE_SPEC_TEST=1)
  message ("     spec test compatible mode is on")
endif ()
if (WAMR_BUILD_BULK_MEMORY EQUAL 1)
  add_definitions (-DWASM_ENABLE_BULK_MEMORY=1)
  message ("     Bulk memory feature enabled")
else ()
  add_definitions (-DWASM_ENABLE_BULK_MEMORY=0)
endif ()
if (WAMR_BUILD_SHARED_MEMORY EQUAL 1)
  add_definitions (-DWASM_ENABLE_SHARED_MEMORY=1)
  message ("     Shared memory enabled")
else ()
  add_definitions (-DWASM_ENABLE_SHARED_MEMORY=0)
endif ()
if (WAMR_BUILD_THREAD_MGR EQUAL 1)
  message ("     Thread manager enabled")
endif ()
if (WAMR_BUILD_LIB_PTHREAD EQUAL 1)
  message ("     Lib pthread enabled")
endif ()
if (WAMR_BUILD_LIBC_EMCC EQUAL 1)
  message ("     Libc emcc enabled")
endif ()
if (WAMR_BUILD_MINI_LOADER EQUAL 1)
  add_definitions (-DWASM_ENABLE_MINI_LOADER=1)
  message ("     WASM mini loader enabled")
else ()
  add_definitions (-DWASM_ENABLE_MINI_LOADER=0)
endif ()
if (WAMR_DISABLE_HW_BOUND_CHECK EQUAL 1)
  add_definitions (-DWASM_DISABLE_HW_BOUND_CHECK=1)
  message ("     Hardware boundary check disabled")
else ()
  add_definitions (-DWASM_DISABLE_HW_BOUND_CHECK=0)
endif ()
if (WAMR_BUILD_SIMD EQUAL 1)
  add_definitions (-DWASM_ENABLE_SIMD=1)
  message ("     SIMD enabled")
endif ()
if (WAMR_BUILD_MEMORY_PROFILING EQUAL 1)
  add_definitions (-DWASM_ENABLE_MEMORY_PROFILING=1)
  message ("     Memory profiling enabled")
endif ()
if (WAMR_BUILD_PERF_PROFILING EQUAL 1)
  add_definitions (-DWASM_ENABLE_PERF_PROFILING=1)
  message ("     Performance profiling enabled")
endif ()
if (DEFINED WAMR_APP_THREAD_STACK_SIZE_MAX)
  add_definitions (-DAPP_THREAD_STACK_SIZE_MAX=${WAMR_APP_THREAD_STACK_SIZE_MAX})
endif ()
if (WAMR_BUILD_CUSTOM_NAME_SECTION EQUAL 1)
  add_definitions (-DWASM_ENABLE_CUSTOM_NAME_SECTION=1)
  message ("     Custom name section enabled")
endif ()
if (WAMR_BUILD_DUMP_CALL_STACK EQUAL 1)
  add_definitions (-DWASM_ENABLE_DUMP_CALL_STACK=1)
  message ("     Dump call stack enabled")
endif ()
if (WAMR_BUILD_TAIL_CALL EQUAL 1)
  add_definitions (-DWASM_ENABLE_TAIL_CALL=1)
  message ("     Tail call enabled")
endif ()
if (WAMR_BUILD_REF_TYPES EQUAL 1)
  add_definitions (-DWASM_ENABLE_REF_TYPES=1)
  message ("     Reference types enabled")
else ()
  message ("     Reference types disabled")
endif ()
if (DEFINED WAMR_BH_VPRINTF)
  add_definitions (-DBH_VPRINTF=${WAMR_BH_VPRINTF})
endif ()
if (WAMR_DISABLE_APP_ENTRY EQUAL 1)
  message ("     WAMR application entry functions excluded")
endif ()
