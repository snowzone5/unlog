import os
import parseopt
 
var  logfile: string = "unlog.log"
var loglevel: string = "INFO"
var msg: string = ""
var paramCount = paramCount()
# initial code found at: http://rosettacode.org/wiki/Parse_command-line_arguments#Nim

#[
  -h, --help: print help
  --log: log filename
  --loglevel [info | debug | warn |  fatal]
   -n: standard Nim logging
   -c: chronicles textblock logging
   -m: morelogging style
   --msg: "log msg"

   Usage: unlog --log="test.log" --loglevel=[info | debug | warn |  fatal] [ -n | -c |  -m | -v ] --msg="this is a test"
   
]#
proc checkargs =
        if paramCount == 0:
          echo "Usage: unlog --log=\"<filename.log>\" --loglevel=[info | debug | warn | fatal] [ -n | -c |  -m ] [  [-v | --version ] --msg=\"Log message.\""  

        if msg == "":  
          loglevel = "WARN"
          msg = "Log msg unassigned"
  
proc version =  echo "v0.01"
proc help = echo "help"

proc init =
  #  app name
 # echo "app name: ", getAppFilename().extractFilename()
 # Get parameter count
#  echo "# parameters: ", paramCount()
  for ii in 1 .. paramCount():    # 1st param is at index 1
    echo "param ", ii, ": ", paramStr(ii)
 
  echo ""
 
  # Using parseopt module to extract short and long options and argumecd nts
  var argCtr : int
 
  for kind, key, value in getOpt():
    case kind
    of cmdArgument:
      echo "Got arg ", argCtr, ": \"", key, "\""
      argCtr.inc
 
    of cmdLongOption, cmdShortOption:
      case key
      of  "log": logfile=value
      of  "loglevel": loglevel=value
      of  "msg": msg=value
      of "h", "help": help()
      of "v","version": version()
      of  "n", "c", "m":

        echo "Got a \"", key, "\" option with value: \"", value, "\""
      else:
        echo "Unknown option: ", key
 
    of cmdEnd:
      discard
 
echo "\nBefore: ", logfile," ", loglevel, " ", msg, " \n"

init()
checkargs()

echo "\nAfter: ",logfile," ", loglevel, " ", msg, "\n"