#%SUMMARY: add unit tests targets
#%  REQUIRED:(input):
#%    * target "${PROJECT_NAME}"
#%  PRODUCED:(output):
#%    * augmented "${PROJECT_NAME}"
#%
#%USAGE:
#%    project(testrunner)
#%    add_executable(${PROJECT_NAME})
#%    include(project-tests-main)
#%
get_property(_objs GLOBAL PROPERTY test_objects)
target_sources(${PROJECT_NAME} PRIVATE ${_objs})
