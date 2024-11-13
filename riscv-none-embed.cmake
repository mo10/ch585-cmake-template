set(CMAKE_SYSTEM_NAME Generic)


if(NOT TOOLCHAIN_PATH)
    if(DEFINED ENV{TOOLCHAIN_PATH})
        message(STATUS "Detected toolchain path TOOLCHAIN_PATH in environmental variables: ")
        message(STATUS "$ENV{TOOLCHAIN_PATH}")
        set(TOOLCHAIN_PATH $ENV{TOOLCHAIN_PATH})
    else()
        if(NOT CMAKE_C_COMPILER)
            set(TOOLCHAIN_PATH "/usr")
            message(STATUS "No TOOLCHAIN_PATH specified, using default: " ${TOOLCHAIN_PATH})
        else()
            # keep only directory of compiler
            get_filename_component(TOOLCHAIN_PATH ${CMAKE_C_COMPILER} DIRECTORY)
            # remove the last /bin directory
            get_filename_component(TOOLCHAIN_PATH ${TOOLCHAIN_PATH} DIRECTORY)
        endif()
    endif()
    file(TO_CMAKE_PATH "${TOOLCHAIN_PATH}" TOOLCHAIN_PATH)
endif()

if(NOT TARGET_TRIPLET)
    set(TARGET_TRIPLET "riscv-none-embed")
    message(STATUS "No TARGET_TRIPLET specified, using default: " ${TARGET_TRIPLET})
endif()


set(TOOLCHAIN_SYSROOT  "${TOOLCHAIN_PATH}/${TARGET_TRIPLET}")
set(TOOLCHAIN_BIN_PATH "${TOOLCHAIN_PATH}/bin")
set(TOOLCHAIN_INC_PATH "${TOOLCHAIN_PATH}/${TARGET_TRIPLET}/include")
set(TOOLCHAIN_LIB_PATH "${TOOLCHAIN_PATH}/${TARGET_TRIPLET}/lib")

set(CMAKE_C_FLAGS_INIT   "-march=rv32imac -mabi=ilp32 -Wall")
set(CMAKE_CXX_FLAGS_INIT "-march=rv32imac -mabi=ilp32 -Wall")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-specs=nano.specs -specs=nosys.specs -nostartfiles -Wl,--print-memory-usage")

# Make CMake happy about those compilers
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

find_program(CMAKE_OBJCOPY NAMES ${TARGET_TRIPLET}-objcopy HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_OBJDUMP NAMES ${TARGET_TRIPLET}-objdump HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_SIZE NAMES ${TARGET_TRIPLET}-size HINTS ${TOOLCHAIN_BIN_PATH})

function(print_size_of_target TARGET)
    add_custom_target(${TARGET}_always_display_size
            ALL COMMAND ${CMAKE_SIZE} "$<TARGET_FILE:${TARGET}>"
            COMMENT "Target Sizes: "
            DEPENDS ${TARGET}
    )
endfunction()

function(_generate_file TARGET OUTPUT_EXTENSION OBJCOPY_BFD_OUTPUT)
    get_target_property(TARGET_OUTPUT_NAME ${TARGET} OUTPUT_NAME)
    if (TARGET_OUTPUT_NAME)
        set(OUTPUT_FILE_NAME "${TARGET_OUTPUT_NAME}.${OUTPUT_EXTENSION}")
    else()
        set(OUTPUT_FILE_NAME "${TARGET}.${OUTPUT_EXTENSION}")
    endif()

    get_target_property(RUNTIME_OUTPUT_DIRECTORY ${TARGET} RUNTIME_OUTPUT_DIRECTORY)
    if(RUNTIME_OUTPUT_DIRECTORY)
        set(OUTPUT_FILE_PATH "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_FILE_NAME}")
    else()
        set(OUTPUT_FILE_PATH "${OUTPUT_FILE_NAME}")
    endif()

    add_custom_command(
            TARGET ${TARGET}
            POST_BUILD
            COMMAND ${CMAKE_OBJCOPY} -O ${OBJCOPY_BFD_OUTPUT} "$<TARGET_FILE:${TARGET}>" ${OUTPUT_FILE_PATH}
            BYPRODUCTS ${OUTPUT_FILE_PATH}
            COMMENT "Generating ${OBJCOPY_BFD_OUTPUT} file ${OUTPUT_FILE_NAME}"
    )
endfunction()

function(generate_binary_file TARGET)
    _generate_file(${TARGET} "bin" "binary")
endfunction()

function(generate_hex_file TARGET)
    _generate_file(${TARGET} "hex" "ihex")
endfunction()
