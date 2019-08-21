#%INFO: inspired by REF: https://beesbuzz.biz/code/4399-Embedding-binary-resources-with-CMake-and-C-11
#%
#%SUMMARY: creates linkable resource and its interface library wrapper
#%  * null-terminated resource is interpreted as .rodata of *.o
#%  * has three actual symbols *_start, *_end, *_size
#%  * provides convenient header file to include resource from *.i
#%  * creates interface library to use with target_link_libraries()
#%
#%USAGE:
#%  CMake:
#%    include(EmbeddedResources)
#%    make_resource(myrc data/note.txt)           # single resource with custom name
#%    make_resource_from_each(data/note.txt ...)  # multiple with default derived names
#%    target_link_libraries(${PROJECT_NAME} PRIVATE rc::note_txt)
#%  CXX:
#%    #include <note_txt.i>
#%    auto some = std::string(note_txt_start);
#%
set(EMBEDDED_RESOURCES_DIR "rc"
  CACHE PATH "Subdirectory to contain all compiled resources (project-global or component-local)")

set(EMBEDDED_RESOURCES_INTERFACE_PREFIX "rc"
  CACHE PATH "Prefix of all interface libraries (DFL: 'rc'::*  to refer in CMake)")

set(EMBEDDED_RESOURCES_SYMBOL_PREFIX ""
  CACHE PATH "Additional prefix of all global symbols (e.g. use '_rc_*' to prevent namespace clashing)")
if(EMBEDDED_RESOURCES_SYMBOL_PREFIX MATCHES "[^a-zA-Z0-9_]")
  message(FATAL_ERROR "Unsupported prefix '${nm}', use only allowed in 'C' identifiers")
endif()


# THINK:DEV? "add_resources_merge(myrc ...)" to create single named *.o and *.i from multiple resources
function(make_resource_from_each)
  set(keywords LOCAL GLOBAL)
  set(scope LOCAL)
  foreach(src IN LISTS ARGN)
    if(src IN_LIST keywords)
      set(scope ${src})
      continue()
    endif()
    get_filename_component(nm ${src} NAME)
    string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" nm ${nm})
    make_resource(${nm} ${src} ${scope})
  endforeach()
endfunction()


function(make_resource nm src)
  if(NOT nm OR nm MATCHES "[^a-zA-Z0-9_]")
    message(FATAL_ERROR "Unsupported resource name '${nm}', use only allowed in 'C' identifiers")
  endif()

  set(keywords LOCAL GLOBAL)
  set(scope LOCAL)
  foreach(src IN LISTS ARGN)
    if(NOT src IN_LIST keywords)
      message(FATAL_ERROR "Unsupported keyword '${src}', use one of {${keywords}}")
    endif()
    set(scope ${src})
  endforeach()

  # MAYBE? place *.i into subdir to be able to group inludes like "#include <rc/some.i>"
  if(scope STREQUAL GLOBAL)
    set(dir ${CMAKE_BINARY_DIR}/${EMBEDDED_RESOURCES_DIR})
  elseif(scope STREQUAL LOCAL)
    set(dir ${CMAKE_CURRENT_BINARY_DIR}/${EMBEDDED_RESOURCES_DIR})
  endif()
  set(rc ${dir}/${nm})

  set(sym ${EMBEDDED_RESOURCES_SYMBOL_PREFIX}${nm})
  set(tgt ${EMBEDDED_RESOURCES_INTERFACE_PREFIX}::${nm})

  # WARN: all resources symbols are global for ELF -- impossible to have same name for different resources
  #  => local resources like "USAGE_txt" are supported when they go into different ELFs
  #  => cmake generates ERR when trying to create another resource with same name (both global or local in same scope)
  #  => linker generates ERR when linking two ELFs with name collision in local resources
  #    CHECK! maybe instead of conflicting second .o will be simply ignored
  if(scope STREQUAL GLOBAL)
    add_library(${tgt} INTERFACE IMPORTED GLOBAL)
  elseif(scope STREQUAL LOCAL)
    add_library(${tgt} INTERFACE IMPORTED)
  endif()

  # ALT:(cmake<=3.7): set_property(TARGET ${tgt} PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${dir})
  target_include_directories(${tgt} INTERFACE ${dir})

  file(RELATIVE_PATH rc_rel ${dir} ${rc})
  get_filename_component(src ${src} ABSOLUTE)
  get_filename_component(rc_dir ${rc} DIRECTORY)
  file(MAKE_DIRECTORY ${rc_dir})

  # NOTE: when ${src} file updated -- whole resource will be recompiled automatically
  add_custom_command(OUTPUT ${rc}.o ${rc}.i
    COMMAND install -Dm644 ${src} ${rc}
    COMMAND truncate -s +1 ${rc}  # HACK: append NULL byte to make file into correct C string
    # COMMAND gzip ${rc}          # MAYBE?(opt): unpack large rodata memory in runtime
    COMMAND ${CMAKE_LINKER} --relocatable --output=${rc}.o --format=binary ${rc_rel}
    COMMAND ${CMAKE_OBJCOPY}
      --rename-section .data=.rodata,ALLOC,LOAD,READONLY,DATA,CONTENTS
      --redefine-sym _binary_${nm}_start=${sym}_start
      --redefine-sym _binary_${nm}_end=${sym}_end
      --redefine-sym _binary_${nm}_size=${sym}_size_symbol
      ${rc}.o
    COMMAND sh -c "printf '%s\\n' \"$@\" > \"$0\"" ${rc}.i
      "// ${tgt} = '${src}'"
      "#include <stddef.h>"
      "extern const char ${sym}_start[];"
      "extern const char ${sym}_end[];"
      "extern const char ${sym}_size_symbol[];"
      "size_t const ${sym}_size = (size_t)${sym}_size_symbol;"
    DEPENDS ${src}
    WORKING_DIRECTORY ${dir}
    COMMENT "Generating embedded resource '${nm}'"
    VERBATIM
  )

  # ALT:(cmake<=3.7): set_property(TARGET ${tgt} PROPERTY INTERFACE_SOURCES ${rc}.o ${rc}.i)
  target_sources(${tgt} INTERFACE ${rc}.o ${rc}.i)

endfunction()
