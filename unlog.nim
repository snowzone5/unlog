#% nim c -d:chronicles_sinks=textblocks[stdout,file,syslog] -d:chronicles_indent=4 -d:chronicles_disable_thread_id  unlog.nim
#% remove syslog for color in log files (less -R to view)
#% nim c -d:chronicles_sinks=textblocks[stdout,file] -d:chronicles_indent=4 -d:chronicles_disable_thread_id  unlog.nim

import os
import parseopt
import chronicles
import std/logging
import morelogging
import strutils

var ver: string = "Unlog v0.05\n" 
var debug: bool =  true
var logfile: string = "unlog.log"
var loglevel: string = "INFO"
var lineNumber: string = "0"
var msg: string = ""
var paramCount = paramCount()
var extraArgs:  string = ""
var logStyle = "multiLine"
var usemaxsquishlogging: bool = false
var useJournaldLogging: bool = false
let slog = newStdoutLogger(fmtStr="$time ")

proc version =  echo ver

proc help = echo "help"

proc multiline =
      # TODO: use try/except for success var
      if extraArgs != "":  # -c is used one or more times for Chronicles
        var success = defaultChroniclesStream.output.open(logfile, fmAppend)

      case loglevel
      of "INFO":  info  "", lineNumber, msg, extraArgs
      of "NOTICE":  notice  "", lineNumber, msg, extraArgs
      of "DEBUG":  debug  "", lineNumber, msg, extraArgs
      of "WARN":  warn  "", lineNumber, msg, extraArgs
      of "ERROR":  error  "", lineNumber, msg, extraArgs
      of "FATAL":  fatal  "", lineNumber, msg, extraArgs

      quit(QuitSuccess)

proc stdoutlogging =
      case loglevel:
      of "INFO": slog.info(loglevel, ": ", msg," -> ",  extraArgs)
      of "NOTICE": slog.info(loglevel, ": ", msg," -> ",  extraArgs)
      of "DEBUG": slog.info(loglevel, ": ", msg," -> ",  extraArgs)
      of "WARN": slog.info(loglevel, ": ", msg," -> ",  extraArgs)
      of "ERROR": slog.info(loglevel, ": ", msg," -> ",  extraArgs)
      of "FATAL": slog.info(loglevel, ": ", msg," -> ",  extraArgs)

      echo ""

      quit(QuitSuccess)

proc usenimlogger =
        var consoleLog = newConsoleLogger(fmtStr="[$date $time] - $levelname: ")          
        var fileLog = newFileLogger(logfile, fmAppend,  fmtStr="[$date $time] - $levelname: ")

        addHandler(consoleLog)
        addHandler(fileLog)


proc checkargs =
        var argCounter : int
        var extraCounter: int = 0

        if paramCount == 0:
          echo "Usage: unlog --log=\"<filename.log>\" --loglevel=[info | debug | warn | error | fatal] [ -ln | --linenumber ] [ -n | -c |  -m ] [  [-v | --version ] --msg=\"Log message.\" [ -c=extraArgs ...]"  
          quit(QuitFailure)

        for p in 1 .. paramCount:
            #% echo "\nparam ", p, ": ", paramStr(p)
            #% echo ""

            for kind, key, value in getOpt():
                case kind
                of cmdArgument:
                    echo "Got arg ", argCounter, ": \"", key, "\""
                    argCounter.inc
              
                of cmdLongOption, cmdShortOption:
                    case key
                    of "log": logfile=value
                    of "loglevel": loglevel=value
                    of "ln": lineNumber=value
                    of "linenumber": lineNumber=value
                    of "msg": msg=value
                    of "h": help()
                    of "help": help()
                    of "v": version()
                    of "version": version()
                    of "x":
                          if extraCounter < ((paramCount-1)-extraCounter):
                              extraArgs.add(value & " ")
                              extraCounter.inc

                    of "mul": logStyle = "multiLine"
                    of "nl": logStyle = "nimlogger"
                    of "jl": 
                              useJournaldLogging = true
                    of "sl":  logStyle = "stdout" 
                    of "mxl": usemaxsquishlogging = true
                    of "z":
                      if (debug == true): 
                        echo "Got a \"", key, "\" option with value: \"", value, "\""
            
                    else:
                      echo "Unknown option: ", key
            
                of cmdEnd: # matches: of cmdLongOption, cmdShortOption:
                    discard


checkargs() 

case logStyle:
of "multiLine": multiline()
of "stdout": stdoutlogging()
of "nimlogger": 
              usenimlogger()
              case loglevel:
              of "INFO":  log(lvlInfo, "ln:",lineNumber, " - ", msg, " -> ", extraArgs )
              of "NOTICE":  log(lvlNotice, "ln:",lineNumber, " - ", msg, " -> ", extraArgs )
              of "DEBUG":  log(lvlDebug, "ln:",lineNumber, " - ", msg, " -> ", extraArgs )
              of "WARN":  log(lvlWarn, "ln:",lineNumber, " - ", msg, " -> ", extraArgs )
              of "ERROR":  log(lvlError, "ln:",lineNumber, "- ", msg, " -> ", extraArgs )
              of "FATAL":  log(lvlFatal, "ln:",lineNumber, " - ", msg," -> ",  extraArgs )
              echo ""
              quit(QuitSuccess)


# TODO: add nim-morelogging (journald)

# TODO: add max/squish logging :)
#CRITICAL = "! "
#        WARNING  = "? "
#        DEBUG    = "+ "
#        SESSION  = "$ "
#        INFO     = "- "

 # TODO: add simple (for quick) -s option  (defaults to unlog.log, debug, no ln, and just msg)
