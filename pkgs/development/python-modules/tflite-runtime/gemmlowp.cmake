get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

####################################################################################

set (GEMMLOWP_FOUND 1)
#set (GEMMLOWP_USE_FILE    "${CMAKE_CURRENT_LIST_DIR}/UseEigen3.cmake")

set (GEMMLOWP_DEFINITIONS  "")
set (GEMMLOWP_INCLUDE_DIR  "${PACKAGE_PREFIX_DIR}/include")
set (GEMMLOWP_INCLUDE_DIRS "${PACKAGE_PREFIX_DIR}/include")
set (GEMMLOWP_ROOT_DIR     "${PACKAGE_PREFIX_DIR}")

add_library(gemmlowp INTERFACE IMPORTED)

set_target_properties(gemmlowp PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${GEMMLOWP_INCLUDE_DIR}"
)
