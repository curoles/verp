# add a target to generate API documentation with RDoc
#message ("Looking for RDoc")
#find_package(rdoc)
#if(RDOC_FOUND)
#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile @ONLY)
#add_custom_target(doc
#${RDOC_EXECUTABLE} ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile
#WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
#COMMENT "Generating API documentation with RDoc" VERBATIM
#)
#endif(RDOC_FOUND)

set (RDOC_EXECUTABLE rdoc)

add_custom_target(doc #ALL
  ${RDOC_EXECUTABLE} --root=${CMAKE_CURRENT_SOURCE_DIR} --all --op=${CMAKE_CURRENT_BINARY_DIR}/rdoc --verbose
  #WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "Generating API documentation with RDoc ${CMAKE_CURRENT_SOURCE_DIR}" VERBATIM
)
