# Copyright (C) 2019 Intel Corporation.  All rights reserved.
# SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception

SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_PROCESSOR wasm32)
SET (CMAKE_SYSROOT                  ${CMAKE_CURRENT_LIST_DIR}/libc-builtin-sysroot)

if (NOT DEFINED WASI_SDK_DIR)
    SET (WASI_SDK_DIR               "/opt/wasi-sdk")
endif ()

SET (CMAKE_C_FLAGS                  "-nostdlib -z stack-size=4096"   CACHE INTERNAL "")
SET (CMAKE_C_COMPILER_TARGET        "wasm32")
SET (CMAKE_C_COMPILER               "${WASI_SDK_DIR}/bin/clang")

SET (CMAKE_CXX_FLAGS                "-nostdlib -z stack-size=4096"   CACHE INTERNAL "")
SET (CMAKE_CXX_COMPILER_TARGET      "wasm32")
SET (CMAKE_CXX_COMPILER             "${WASI_SDK_DIR}/bin/clang++")

SET (CMAKE_EXE_LINKER_FLAGS
    "-Wl,--initial-memory=65536,--no-entry,--strip-all" CACHE INTERNAL "")

SET (CMAKE_LINKER  "${WASI_SDK_DIR}/bin/wasm-ld"                     CACHE INTERNAL "")
SET (CMAKE_AR      "${WASI_SDK_DIR}/bin/llvm-ar"                     CACHE INTERNAL "")
SET (CMAKE_NM      "${WASI_SDK_DIR}/bin/llvm-nm"                     CACHE INTERNAL "")
SET (CMAKE_OBJDUMP "${WASI_SDK_DIR}/bin/llvm-dwarfdump"              CACHE INTERNAL "")
SET (CMAKE_RANLIB  "${WASI_SDK_DIR}/bin/llvm-ranlib"                 CACHE INTERNAL "")
SET (CMAKE_EXE_LINKER_FLAGS
    "${CMAKE_EXE_LINKER_FLAGS},--allow-undefined-file=${CMAKE_SYSROOT}/share/defined-symbols.txt" CACHE INTERNAL "")
