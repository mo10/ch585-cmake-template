cmake_minimum_required(VERSION 3.28)
include(riscv-none-embed.cmake)
project(ch585_cmake_template)

enable_language(CXX)
enable_language(ASM)

# Conditional flags
# DEBUG
set(CMAKE_C_FLAGS_DEBUG          "${CMAKE_C_FLAGS_DEBUG} -DDEBUG -g -O0")
set(CMAKE_CXX_FLAGS_DEBUG        "${CMAKE_CXX_FLAGS_DEBUG} -DDEBUG -g -O0")
set(CMAKE_EXE_LINKER_FLAGS_DEBUG "${CMAKE_EXE_LINKER_FLAGS_DEBUG}")

# RELEASE
set(CMAKE_C_FLAGS_RELEASE          "${CMAKE_C_FLAGS_RELEASE} -DNDEBUG -O3")
set(CMAKE_CXX_FLAGS_RELEASE        "${CMAKE_CXX_FLAGS_RELEASE} -DNDEBUG -O3")
set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")

# Final compiler flags
set(CMAKE_C_FLAGS          "${CMAKE_C_FLAGS} -fno-common -fno-builtin -ffreestanding -fdata-sections -ffunction-sections")
set(CMAKE_CXX_FLAGS        "${CMAKE_CXX_FLAGS} -fno-common -fno-builtin -ffreestanding -fdata-sections -ffunction-sections")
set(CMAKE_ASM_FLAGS        "${CMAKE_C_FLAGS} -x assembler-with-cpp")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--gc-sections")

# Add WCH SDK
add_subdirectory(SDK)

# Add project sources
add_executable(ch585_template src/main.c)
target_include_directories(ch585_template PUBLIC include)

target_link_libraries(ch585_template CH585SDK)

# Generate .bin and .hex
generate_binary_file(ch585_template)
generate_hex_file(ch585_template)