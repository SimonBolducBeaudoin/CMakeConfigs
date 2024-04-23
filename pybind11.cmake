	      # Finding using python to automatically find pybind11 and its dependencies (python dlls)
string(FIND ${CMAKE_CXX_COMPILER} x86_64-w64-mingw32-g++ IS_MINGW) 

if(IS_MINGW) #Using anaconda's python for windows
	message(STATUS "Cross-compiling using MINGW")
	#################################################################################
	# This line is searching for the Python executable. It first looks in "C:/Anaconda3" and "C:/Anaconda2".
	# If Python is not found in these locations, find_program will proceed to search in the default system paths.
	message(STATUS "Looking for python installation ...")
	find_program(ANACONDA_PYTHON python HINTS "C:/Anaconda3" "C:/Anaconda2" "C:/tools/Anaconda3") 
	message(STATUS "Found python at : ${ANACONDA_PYTHON}")
	#################################################################################
	
	#################################################################################
	# Find python version number
	execute_process(COMMAND ${ANACONDA_PYTHON} -c "import sys; print('.'.join(map(str, sys.version_info[:2])))"
					OUTPUT_VARIABLE PYTHON_VERSION
					OUTPUT_STRIP_TRAILING_WHITESPACE)
	string(REPLACE "." "" PYTHON_VERSION_NO_DOTS ${PYTHON_VERSION})
	message(STATUS "Python version found : ${PYTHON_VERSION}")
	#################################################################################
	
	get_filename_component(CONDA_PY_DIR ${ANACONDA_PYTHON} DIRECTORY)
	
    set(CONDA_PY_EXE ${ANACONDA_PYTHON})
	set(CONDA_PY_LINKS "-L${CONDA_PY_DIR} -lpython${PYTHON_VERSION_NO_DOTS}")
    #set(CONDA_PY_LINKS "-L${CONDA_PY_DIR} -lpython27")
    # Deprecated ####################################################################
	# if(CYGWIN)
		# message(STATUS "Cygwin environnment detected.")
        # string(REGEX REPLACE "C\:" "/cygdrive/c" CONDA_PY_EXE ${CONDA_PY_EXE})
        # string(REGEX REPLACE "C\:" "/cygdrive/c" CONDA_PY_LINKS ${CONDA_PY_LINKS})
    # endif()
	#################################################################################
    set(Python_EXECUTABLE ${CONDA_PY_EXE})
    list(APPEND LINKS ${CONDA_PY_LINKS})
else() #unix
	message(STATUS "Compiling for a unix system.")
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
else () #unix
    set(SHARED_LIB_PREFIX "lib")
    set(SHARED_LIB_SUFFIX ".so")
endif()
