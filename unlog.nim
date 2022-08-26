#% nim c -d:chronicles_sinks=textblocks[stdout,file,syslog] -d:chronicles_indent=4 -d:chronicles_disable_thread_id  unlog.nim
#% remove syslog for color in log files (less -R to view)
#% nim c -d:chronicles_sinks=textblocks[stdout,file] -d:chronicles_indent=4 -d:chronicles_disable_thread_id  unlog.nim

import os
import parseopt
import chronicles
import std/logging
import morelogging
import strutils
#import std/distros

var debug: bool = false
var ver: string = "Unlog v0.05\n" 
var logfile: string = "unlog.log"
var loglevel: string = "INFO"
var caller: string = "main"
var lineNumber: string = "0"
var msg: string = ""
var paramCount = paramCount()
var extraArgs:  string = ""
var logStyle = "multiLine"
var usemaxsquishlogging: bool = false
var useJournaldLogging: bool = false
let slog = newStdoutLogger(fmtStr="$time ")

proc version =  
      echo ver
      quit(QuitSuccess)

proc help =
      echo "Usage: unlog [-h | --help] [ -v | --version ] --logstyle= [ sl | mul | nl | jctl | mxl ] --log=\"<filename.log>\" --loglevel=[ INFO | DEBUG | WARN | ERROR | FATAL ] [ -c= | --caller=\"proc\" ] [ --ln=# | --linenumber=# ] --msg=\"Log message.\" [-x=var1 [-x=var2 ... ]"
      echo ""
      echo "-h or --help"
      echo "        Print this help."
      echo ""
      echo "-v or --version"
      echo "        Print version."
      echo ""
      echo "--logstyle"
      echo "        sl   - stdout, no log is written (--log is ignored), timestamp does not include date."
      echo "        mul  - multi-line, cleaner output for readability."
      echo "        nl   - nimlogger, uses nim's log handlers."
      echo "        jctl - (not implemented yet) Journald logging "
      echo "        mxl  - (not implemented yet) Maximus BBS/Squish tosser style logging. Clean, efficient logging"
      echo "        jvl  - (not implemented yet) Java (Log4J) style logging. Note: Log4J is not actually used."  
      echo ""
      echo "--log"
      echo "        Log path/filename. If you choose any logging style other than sl, and omit this, the default log will be called \"unlog.log\" "
      echo ""
      echo "--loglevel"
      echo "        INFO, DEBUG, WARN, ERROR, FATAL. If omitted, default is INFO."
      echo ""
      echo "-c or --caller"
      echo "        Calling function/proc/class/method. By itself string will default to \"main\" "
      echo ""
      echo "--ln or --linenumber"
      echo "        Line number of caller. Internally this is actually a string. This may change in the future."
      echo ""
      echo "--msg"
      echo "        The message you want to log"
      echo ""
      echo "-x"
      echo "        extra arguments, can be any alpha numeric, and as many as you want to add." 
      echo ""
      quit(QuitFailure)

proc multiline =
      # TODO: use try/except for success var
      if extraArgs != "":  # -c is used one or more times for Chronicles
        var success = defaultChroniclesStream.output.open(logfile, fmAppend)

      case loglevel
      of "INFO":   info  "", caller, lineNumber, msg, extraArgs
      of "NOTICE": notice  "", caller, lineNumber, msg, extraArgs
      of "DEBUG":  debug  "", caller, lineNumber, msg, extraArgs
      of "WARN":   warn  "", caller, lineNumber, msg, extraArgs
      of "ERROR":  error  "", caller, lineNumber, msg, extraArgs
      of "FATAL":  fatal  "", caller, lineNumber, msg, extraArgs

      quit(QuitSuccess)

proc stdoutlogging =
      case loglevel:
      of "INFO": slog.info(loglevel, ":", caller, ":", lineNumber, ": ", msg," -> ",  extraArgs)
      of "NOTICE": slog.info(loglevel, ": ", caller, ":", lineNumber, ": ", msg," -> ",  extraArgs)
      of "DEBUG": slog.info(loglevel, ": ", caller, ":", lineNumber, ": ",msg," -> ",  extraArgs)
      of "WARN": slog.info(loglevel, ": ", caller, ":", lineNumber, ": ",msg," -> ",  extraArgs)
      of "ERROR": slog.info(loglevel, ": ", caller, ":", lineNumber, ": ", msg," -> ",  extraArgs)
      of "FATAL": slog.info(loglevel, ": ", caller, ":", lineNumber, ": ", msg," -> ",  extraArgs)

      echo ""

      quit(QuitSuccess)

proc usenimlogger =
        var consoleLog = newConsoleLogger(fmtStr="[$date $time] - $levelname:")          
        var fileLog = newFileLogger(logfile, fmAppend,  fmtStr="[$date $time] - $levelname:")

        addHandler(consoleLog)
        addHandler(fileLog)

proc checkargs =
        var argCounter : int
        var extraCounter: int = 0

        if paramCount == 0:
            help()

        for p in 1 .. paramCount:
            if debug:
                echo "\nparam ", p, ": ", paramStr(p)
                echo ""

            for kind, key, value in getOpt():
                case kind
                of cmdArgument:
                    echo "Got arg ", argCounter, ": \"", key, "\""
                    argCounter.inc
              
                of cmdLongOption, cmdShortOption:
                    case key
                    of "d": debug=true
                    of "log": logfile=value
                    of "loglevel": loglevel=value
                    of "ln": lineNumber=value
                    of "linenumber": lineNumber=value
                    of "c": 
                          if value != "":
                              caller=value
                    of "caller": 
                               if value != "":
                                   caller=value
                    of "msg": msg=value
                    of "h": help()
                    of "help": help()
                    of "v": version()
                    of "version": version()
                    of "x":
                          if extraCounter < ((paramCount-2)-extraCounter):
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
                      help()
            
                of cmdEnd: # matches: of cmdLongOption, cmdShortOption:
                    discard

checkargs() 

case logStyle:
of "multiLine": multiline()
of "stdout": stdoutlogging()
of "nimlogger": 
              usenimlogger()
              case loglevel:
              of "INFO":  log(lvlInfo, caller, ":", lineNumber, " - ", msg, " -> ", extraArgs )
              of "NOTICE":  log(lvlNotice, caller, ":", lineNumber, " - ", msg, " -> ", extraArgs )
              of "DEBUG":  log(lvlDebug, caller, ":", lineNumber, " - ", msg, " -> ", extraArgs )
              of "WARN":  log(lvlWarn, caller, ":", lineNumber, " - ", msg, " -> ", extraArgs )
              of "ERROR":  log(lvlError, caller, ":", lineNumber, "- ", msg, " -> ", extraArgs )
              of "FATAL":  log(lvlFatal, caller, ":", lineNumber, " - ", msg," -> ",  extraArgs )
              echo ""
              quit(QuitSuccess)

# TODO: add nim-morelogging (journald)
# TODO: look into detecting os

# TODO: add max/squish logging :)
#CRITICAL = "! "
#        WARNING  = "? "
#        DEBUG    = "+ "
#        SESSION  = "$ "
#        INFO     = "- "

 # TODO: add simple (for quick) -s option  (defaults to unlog.log, debug, no ln, and just msg)
