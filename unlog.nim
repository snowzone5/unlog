import os
import parseopt
 
var  logfile: string = "unlog.log"
var loglevel: string = "info"
# initial code found at: http://rosettacode.org/wiki/Parse_command-line_arguments#Nim

#[
  --log: log filename
  --loglevel [info | debug | warn |  fatal]
   -n: standard Nim logging
   -c: chronicles textblock logging
   -m: morelogging style
   --msg: "log msg"

   Usage: unlog --log="test.log" --loglevel=[info | debug | warn |  fatal] [ -n | -c |  -m | -v ] --msg="this is a test"
   
]#
 

proc main =
  #  app name
 # echo "app name: ", getAppFilename().extractFilename()
 # Get parameter count
  echo "# parameters: ", paramCount()
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
      of  "n", "c", "m", "v","msg":

        echo "Got a \"", key, "\" option with value: \"", value, "\""
      else:
        echo "Unknown option: ", key
 
    of cmdEnd:
      discard
 
echo logfile," ", loglevel
main()
echo logfile," ", loglevel