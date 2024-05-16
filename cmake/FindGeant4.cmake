# $Id$
#
# ------------------------------------------------------------------------------
# The configuration file for CMake build for Virtual Geometry Model
# Copyright (C) 2012, Ivana Hrivnacova
# All rights reserved.
# 
# For the licensing terms see vgm/LICENSE.
# Contact: ivana@ipno.in2p3.fr
# ------------------------------------------------------------------------------

# The CMake build for Virtual Geometry Model is a result of a merge 
# of the CMake configuration files kindly provided 
# by Florian Uhlig, GSI and Pere Mato, CERN.

# - Try to find Geant4 installation
# This module sets up Geant4 information: 
# - either from Geant4 CMake configuration file (Geant4Config.cmake), if available
# - or it defines:
# Geant4_FOUND          If Geant4 is found
# Geant4_INCLUDE_DIRS   include directories for Geant4
# Geant4_LIBRARIES      Geant4 libraries to link against
# GEANT4_LIBRARY_DIR    PATH to the library directory (used to find CLHEP in old Geant4 installation)

message(STATUS "Starting Geant4 search...")

# Alternative paths which can be defined by user
set(Geant4_DIR "" CACHE PATH "Directory where Geant4 is installed")
set(GEANT4_INC_DIR "" CACHE PATH "Alternative directory for Geant4 includes")
set(GEANT4_LIB_DIR "" CACHE PATH "Alternative directory for Geant4 libraries")
set(GEANT4_SYSTEM "" CACHE PATH "Geant4 platform specification")

message(STATUS "Geant4_DIR is set to: ${Geant4_DIR}")
message(STATUS "GEANT4_INC_DIR is set to: ${GEANT4_INC_DIR}")
message(STATUS "GEANT4_LIB_DIR is set to: ${GEANT4_LIB_DIR}")
message(STATUS "GEANT4_SYSTEM is set to: ${GEANT4_SYSTEM}")

# First search for Geant4Config.cmake on the path defined via user setting 
# Geant4_DIR

if(EXISTS ${Geant4_DIR}/Geant4Config.cmake)
  message(STATUS "Found Geant4Config.cmake in ${Geant4_DIR}")
  include(${Geant4_DIR}/Geant4Config.cmake)
  message(STATUS "Included Geant4Config.cmake from ${Geant4_DIR}")
  # Geant4_INCLUDE_DIRS, Geant4_LIBRARIES are defined in Geant4Config
  set(Geant4_FOUND TRUE)
  return()
else()
  message(STATUS "Geant4Config.cmake not found in ${Geant4_DIR}")
endif()

# If Geant4Config.cmake was not found in Geant4_DIR
# search for geant4-config executable on system path to get Geant4 installation directory 

find_program(GEANT4_CONFIG_EXECUTABLE geant4-config PATHS
  ${Geant4_DIR}/bin
)
message(STATUS "GEANT4_CONFIG_EXECUTABLE is set to: ${GEANT4_CONFIG_EXECUTABLE}")

if(GEANT4_CONFIG_EXECUTABLE)
  execute_process(
    COMMAND ${GEANT4_CONFIG_EXECUTABLE} --prefix 
    OUTPUT_VARIABLE G4PREFIX 
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  message(STATUS "Geant4 prefix is: ${G4PREFIX}")

  execute_process(
    COMMAND ${GEANT4_CONFIG_EXECUTABLE} --version 
    OUTPUT_VARIABLE GEANT4_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  message(STATUS "Geant4 version is: ${GEANT4_VERSION}")

  if(EXISTS ${G4PREFIX}/lib/cmake/Geant4/Geant4Config.cmake)
    set(Geant4_DIR ${G4PREFIX}/lib/cmake/Geant4)
    include(${Geant4_DIR}/Geant4Config.cmake)
    # Geant4_INCLUDE_DIRS, Geant4_LIBRARIES are defined in Geant4Config
    set(Geant4_FOUND TRUE)
    message(STATUS "Found Geant4 CMake configuration in ${Geant4_DIR}")
    return()
  elseif(EXISTS ${G4PREFIX}/lib64/Geant4-${GEANT4_VERSION}/Geant4Config.cmake)
    set(Geant4_DIR ${G4PREFIX}/lib64/Geant4-${GEANT4_VERSION})
    include(${Geant4_DIR}/Geant4Config.cmake)
    # Geant4_INCLUDE_DIRS, Geant4_LIBRARIES are defined in Geant4Config
    set(Geant4_FOUND TRUE)
    message(STATUS "Found Geant4 CMake configuration in ${Geant4_DIR}")
    return()
  else()
    message(STATUS "Geant4Config.cmake not found in ${G4PREFIX}/lib/Geant4-${GEANT4_VERSION} or ${G4PREFIX}/lib64/Geant4-${GEANT4_VERSION}")
  endif()

else()
  message(STATUS "geant4-config executable not found")
endif()

# If search for Geant4Config.cmake via geant4-config failed try to use directly 
# user paths if set or environment variables 
#
if (NOT Geant4_FOUND)
  find_path(Geant4_INCLUDE_DIRS NAMES globals.hh PATHS
    ${GEANT4_INC_DIR}
    ${Geant4_DIR}/include
    $ENV{G4INSTALL}/include
    $ENV{G4INCLUDE}
  )
  message(STATUS "Geant4_INCLUDE_DIRS is set to: ${Geant4_INCLUDE_DIRS}")

  find_path(GEANT4_LIBRARY_DIR NAMES libname.map PATHS
    ${GEANT4_LIB_DIR}
    ${Geant4_DIR}/lib/${GEANT4_SYSTEM}
    $ENV{G4INSTALL}/lib/$ENV{G4SYSTEM}
    $ENV{G4LIB}
  )
  message(STATUS "GEANT4_LIBRARY_DIR is set to: ${GEANT4_LIBRARY_DIR}")

  if (Geant4_INCLUDE_DIRS AND GEANT4_LIBRARY_DIR)
    execute_process(
      COMMAND ${GEANT4_LIBRARY_DIR}/liblist -m ${GEANT4_LIBRARY_DIR}                  
      INPUT_FILE ${GEANT4_LIBRARY_DIR}/libname.map 
      OUTPUT_VARIABLE Geant4_LIBRARIES
      OUTPUT_STRIP_TRAILING_WHITESPACE
      TIMEOUT 2)
    message(STATUS "Geant4_LIBRARIES is set to: ${Geant4_LIBRARIES}")
  endif()

  #set(Geant4_LIBRARIES "-L${GEANT4_LIBRARY_DIR} ${Geant4_LIBRARIES} -lexpat -lz")
  set(Geant4_LIBRARIES "-L${GEANT4_LIBRARY_DIR} ${Geant4_LIBRARIES}")
endif()      

if (Geant4_INCLUDE_DIRS AND GEANT4_LIBRARY_DIR AND Geant4_LIBRARIES)
  set (Geant4_FOUND TRUE)
endif()  

if (Geant4_FOUND)
  if (NOT GEANT4_FIND_QUIETLY)
    if (G4PREFIX)
      message(STATUS "Found GEANT4 ${GEANT4_VERSION} in ${G4PREFIX}")
    else()  
      message(STATUS "Found GEANT4 includes in ${Geant4_INCLUDE_DIRS}")
      message(STATUS "Found GEANT4 libraries in ${GEANT4_LIBRARY_DIR}")
      #message(STATUS "Found GEANT4 libraries ${Geant4_LIBRARIES}")
    endif()  
  endif (NOT GEANT4_FIND_QUIETLY)  
else()
  if (Geant4_FIND_REQUIRED)
    message(FATAL_ERROR "Geant4 required, but not found")
  else()
    message(STATUS "Geant4 not found, but not required")
  endif (Geant4_FIND_REQUIRED)   
endif()

# Make variables changeable to the advanced user
mark_as_advanced(Geant4_INCLUDE_DIRS)
mark_as_advanced(Geant4_LIBRARIES)
mark_as_advanced(GEANT4_LIBRARY_DIR)
mark_as_advanced(GEANT4_CONFIG_EXECUTABLE)

