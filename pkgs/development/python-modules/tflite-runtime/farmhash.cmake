get_filename_component(PACKAGE_PREFIX_DIR "${CMAKE_CURRENT_LIST_DIR}/../../../" ABSOLUTE)

####################################################################################

set (FARMHASH_FOUND 1)

set (FARMHASH_DEFINITIONS  "")
set (FARMHASH_INCLUDE_DIR  "${PACKAGE_PREFIX_DIR}/include")
set (FARMHASH_INCLUDE_DIRS "${PACKAGE_PREFIX_DIR}/include")
set (FARMHASH_LIBRARIES    "${PACKAGE_PREFIX_DIR}/lib/libfarmhash${CMAKE_STATIC_LIBRARY_SUFFIX}")
set (FARMHASH_ROOT_DIR     "${PACKAGE_PREFIX_DIR}")

add_library(farmhash STATIC IMPORTED)

set_target_properties(farmhash PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES "${FARMHASH_INCLUDE_DIR}"
  IMPORTED_LOCATION "${FARMHASH_LIBRARIES}"
)
