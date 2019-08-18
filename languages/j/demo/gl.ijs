#!/usr/lib/j8/bin/jconsole
NB.SUMMARY: OpenGL demo

errhandle=: 9!:27
errexit=: 9!:29]1

onfail=:3 :0
  smoutput ARGV   NB. print actual cmdline (in boxes)
  stderr]dberm''  NB. print error message and line number
  exit>:dberr''   NB. exit with immex error code
)
errhandle 'onfail 1'
errexit
https://code.jsoftware.com/mediawiki/index.php?search=opengl
https://code.jsoftware.com/wiki/J6/OpenGL
NB. https://code.jsoftware.com/wiki/J6/OpenGL/API

require 'pacman'
'update' jpkg ''
'install' jpkg 'api/gles graphics/bmp graphics/gl2 graphics/plot graphics/viewmat'
smoutput 'All Qt demo addons installed.'

exit 0
