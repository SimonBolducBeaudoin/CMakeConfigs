# Finding using python to automatically find pybind11 and its dependencies (python dlls)
string(FIND ${CMAKE_CXX_COMPILER} x86_64-w64-mingw32-g++ IS_MINGW) 
if(NOT(IS_MINGW EQUAL -1)) 
    #Using anaconda's python for windows
    set(CONDA_PY_EXE "C:/Anaconda2/python")
    set(CONDA_PY_LINKS "-LC:/Anaconda2/ -lpython27")
    if(CYGWIN)
        string(REGEX REPLACE "C\:" "/cygdrive/c" CONDA_PY_EXE ${CONDA_PY_EXE})
        string(REGEX REPLACE "C\:" "/cygdrive/c" CONDA_PY_LINKS ${CONDA_PY_LINKS})
    endif()
    set(Python_EXECUTABLE ${CONDA_PY_EXE})
    list(APPEND LINKS ${CONDA_PY_LINKS})
elseif(MSVC)
    find_package(Python COMPONENTS Interpreter REQUIRED)
    set(Python_EXECUTABLE "C:/Anaconda2/python")
    find_library(PYLIB NAMES python27 HINTS "C:/Anaconda2/libs")
    list(APPEND LINKS ${PYLIB})
else() #unix 
    find_package(Python COMPONENTS Interpreter REQUIRED)
endif()

# inluding pybind11
execute_process(COMMAND ${Python_EXECUTABLE} -m pybind11 --includes OUTPUT_VARIABLE PY_INCL)
string(REGEX REPLACE "-I" "" PY_INCL ${PY_INCL}) #removes -I
string(REGEX REPLACE "\n" "" PY_INCL ${PY_INCL}) #removes \n
if(CYGWIN)
    string(REGEX REPLACE "C\:" "/cygdrive/c" PY_INCL ${PY_INCL})
endif()
separate_arguments(PY_INCL)                 

# shared labrary convention
if ( IS_MINGW ) # genrate libbrary named "name.pyd" else it's named "libname.so"
    set(SHARED_LIB_PREFIX "")
    set(SHARED_LIB_SUFFIX ".pyd")
elseif(MSVC)
    set(SHARED_LIB_PREFIX "")
    set(SHARED_LIB_SUFFIX ".pyd")
else () #unix
    set(SHARED_LIB_PREFIX "lib")
    set(SHARED_LIB_SUFFIX ".so")
endif()
