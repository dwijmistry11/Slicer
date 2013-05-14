
# Make sure this file is included only once
get_filename_component(CMAKE_CURRENT_LIST_FILENAME ${CMAKE_CURRENT_LIST_FILE} NAME_WE)
if(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED)
  return()
endif()
set(${CMAKE_CURRENT_LIST_FILENAME}_FILE_INCLUDED 1)

# Set dependency list
set(teem_DEPENDENCIES zlib VTK)

# Include dependent projects if any
SlicerMacroCheckExternalProjectDependency(teem)
set(proj teem)

set(EXTERNAL_PROJECT_OPTIONAL_ARGS)

# Set CMake OSX variable to pass down the external project
if(APPLE)
  list(APPEND EXTERNAL_PROJECT_OPTIONAL_ARGS
    -DCMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
    -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET})
endif()

set(CMAKE_PROJECT_INCLUDE_EXTERNAL_PROJECT_ARG)
if(CTEST_USE_LAUNCHERS)
  set(CMAKE_PROJECT_INCLUDE_EXTERNAL_PROJECT_ARG
    "-DCMAKE_PROJECT_Teem_INCLUDE:FILEPATH=${CMAKE_ROOT}/Modules/CTestUseLaunchers.cmake")
endif()

#message(STATUS "${__indent}Adding project ${proj}")

if(WIN32)
  set(teem_PNG_LIBRARY ${VTK_DIR}/bin/${CMAKE_CFG_INTDIR}/vtkpng.lib)
elseif(APPLE)
  set(teem_PNG_LIBRARY ${VTK_DIR}/bin/libvtkpng.dylib)
else()
  set(teem_PNG_LIBRARY ${VTK_DIR}/bin/libvtkpng.so)
endif()

set(teem_URL http://svn.slicer.org/Slicer3-lib-mirrors/trunk/teem-1.10.0-src.tar.gz)
set(teem_MD5 efe219575adc89f6470994154d86c05b)

ExternalProject_Add(${proj}
  URL ${teem_URL}
  URL_MD5 ${teem_MD5}
  DOWNLOAD_DIR ${CMAKE_CURRENT_BINARY_DIR}
  SOURCE_DIR teem
  BINARY_DIR teem-build
  "${${PROJECT_NAME}_EP_UPDATE_IF_GREATER_288}"
  CMAKE_GENERATOR ${gen}
  CMAKE_ARGS
      -DCMAKE_CXX_COMPILER:FILEPATH=${CMAKE_CXX_COMPILER}
  # Not needed -DCMAKE_CXX_FLAGS:STRING=${ep_common_cxx_flags}
      -DCMAKE_C_COMPILER:FILEPATH=${CMAKE_C_COMPILER}
      -DCMAKE_C_FLAGS:STRING=${ep_common_c_flags}
      ${CMAKE_OSX_EXTERNAL_PROJECT_ARGS}
      -DCMAKE_BUILD_TYPE:STRING=${CMAKE_BUILD_TYPE}
      -DBUILD_TESTING:BOOL=OFF
      -DBUILD_SHARED_LIBS:BOOL=ON
    ${CMAKE_PROJECT_INCLUDE_EXTERNAL_PROJECT_ARG}
    -DTeem_USE_LIB_INSTALL_SUBDIR:BOOL=ON
    -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
    -DTeem_PTHREAD:BOOL=OFF
    -DTeem_BZIP2:BOOL=OFF
    -DTeem_ZLIB:BOOL=ON
    -DTeem_PNG:BOOL=ON
    -DTeem_VTK_TOOLKITS_IPATH:FILEPATH=${VTK_DIR}
    -DZLIB_ROOT:PATH=${SLICER_ZLIB_ROOT}
    -DZLIB_INCLUDE_DIR:PATH=${SLICER_ZLIB_INCLUDE_DIR}
    -DZLIB_LIBRARY:FILEPATH=${SLICER_ZLIB_LIBRARY}
    -DTeem_VTK_MANGLE:BOOL=OFF ## NOT NEEDED FOR EXTERNAL ZLIB outside of vtk
    #-DTeem_VTK_ZLIB_MANGLE_IPATH:PATH=${VTK_SOURCE_DIR}/Utilities/vtkzlib
    #-DTeem_ZLIB_DLLCONF_IPATH:PATH=${VTK_DIR}/Utilities
    -DPNG_PNG_INCLUDE_DIR:PATH=${VTK_SOURCE_DIR}/Utilities/vtkpng
    -DTeem_PNG_DLLCONF_IPATH:PATH=${VTK_DIR}/Utilities
    -DPNG_LIBRARY:FILEPATH=${teem_PNG_LIBRARY}
    ${EXTERNAL_PROJECT_OPTIONAL_ARGS}
  INSTALL_COMMAND ""
  DEPENDS
    ${teem_DEPENDENCIES}
  )

set(Teem_DIR ${CMAKE_BINARY_DIR}/teem-build)

