# unlog
Nim universal logging utility

TODO: clean up this README
## Cmd line arguments

-h, --help: print help

--log: log filename

--loglevel [info | debug | warn |  error | fatal]

-ln, --linenumber linenumber

-n: standard Nim logging

-c: chronicles textblock logging

-m: morelogging style

--msg: "log msg"


## From Nim docs

Debug - debugging information helpful only to developers

Info - anything associated with normal operation and 
without any particular importance

Notice - more important information that users should be 
notified about

Warn - impending problems that require some attention

Error - error conditions that the application can recover 
from

Fatal - fatal errors that prevent the application from continuing



Usage: unlog --log="test.log" --loglevel=[info | debug | warn |  fatal] [ -n | -c |  -m | -v ] --msg="this is a test"

Compile with: nim c -d:chronicles_sinks=textblocks[stdout,file] -d:chronicles_line_numbers -d:chronicles_indent=4 unlog.nim
## Example calls:

   ./unlog --log=test.log --loglevel=debug --msg="This is a test" -c=x=1 -c=y=2
