# nim c -d:chronicles_sinks=textblocks[stdout,file] -d:chronicles_indent=4 -d:chronicles_disable_thread_id unlog.nim
import os
import parseopt
import chronicles
import std/logging
import strutils

var ver: string = "Unlog v0.03" 
var debug: bool =  true
var  logfile: string = "unlog.log"
var loglevel: string = "INFO"
var lineNumber: string = "0"
var msg: string = ""
var paramCount = paramCount()
var extraArgs:  string = ""
var usenimlogger: bool = false
var usemorelogger: bool = false


proc version =  echo ver

proc help = echo "help"

# TODO: add file logging to nimlogger
# TODO: add file rotation option to nimlogger

proc nimlogger =
        var consoleLog = newConsoleLogger(fmtStr="[$date $time] - $levelname: ")          
        addHandler(consoleLog)

proc checkargs =
        var argCounter : int
        var missingp: string

        if paramCount == 0:
          echo "Usage: unlog --log=\"<filename.log>\" --loglevel=[info | debug | warn | error | fatal] [ -ln | --linenumber ] [ -n | -c |  -m ] [  [-v | --version ] --msg=\"Log message.\" [ -c=extraArgs ...]"  
          quit(QuitFailure)

        if debug == false:
          for p in 1 .. paramCount:
               echo "param ", p, ": ", paramStr(p)
               echo ""
 
        for kind, key, value in getOpt():
          case kind
          of cmdArgument:
            echo "Got arg ", argCounter, ": \"", key, "\""
            argCounter.inc
        
          of cmdLongOption, cmdShortOption:
            case key
            of  "log": logfile=value
            of  "loglevel": loglevel=value
            of "ln": lineNumber=value
            of "linenumber": lineNumber=value
            of  "msg": msg=value
            of "h", "help": help()
            of "v","version": version()
            of "c":  extraArgs.add(value & " ")
            of  "n": usenimlogger = true
            of   "m": usemorelogger = true

                #echo "Got a \"", key, "\" option with value: \"", value, "\""
            else:
              echo "Unknown option: ", key
        
          of cmdEnd:
            discard

        if msg == "":  
          loglevel = "WARN"
          msg = "No log message defined."
          warn  "", lineNumber, msg, extraArgs
          log(lvlWarn, "ln:",lineNumber, " - ", msg )
          quit(QuitFailure)

        if  usenimlogger == false and usemorelogger == false and (extraArgs == ""):
            echo "You must use of one -n, -m or -c to define a logger"

nimlogger()
checkargs() 

# TODO: use try/except for success var

if extraArgs != "":  # -c is used one  or more times for Chronicles
  var success = defaultChroniclesStream.output.open(logfile, fmAppend)

  case loglevel
  of "info":  info  "", lineNumber,  msg, extraArgs
  of "notice":  notice  "", lineNumber,  msg, extraArgs
  of "debug":  debug  "", lineNumber, msg, extraArgs
  of "warn":  warn  "", lineNumber, msg, extraArgs
  of "error":  error  "", lineNumber, msg, extraArgs
  of "fatal":  fatal  "", lineNumber, msg, extraArgs

# TODO: -n defaults rotate log = 1000 --nr to set rotate limit

if (usenimlogger == true):
  case loglevel:
  of "info":  log(lvlInfo, "ln:",lineNumber, " - ", msg )
  of "notice":  log(lvlNotice, "ln:",lineNumber, " - ", msg )
  of "debug":  log(lvlDebug, "ln:",lineNumber, " - ", msg )
  of "warn":  log(lvlWarn, "ln:",lineNumber, " - ", msg )
  of "error":  log(lvlError, "ln:",lineNumber, "- ", msg )
  of "fatal":  log(lvlFatal, "ln:",lineNumber, " - ", msg )

# TODO: add nim-morelogging
# TODO: add max/squish logging :)

 # TODO: add simple (for quick) -s option  (defaults to unlog.log, debug, no ln, and just msg)
