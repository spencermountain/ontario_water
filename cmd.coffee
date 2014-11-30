#a pretty way to run a shell command without thinking
shell = require("shelljs")

run_sync = (cmd) ->
  result = shell.exec(cmd, {silent: true, async: false} )
  if result.code
    console.log "error:" + result.code
    console.log JSON.stringify(result, null, 2)
  else
    result.output


module.exports= run_sync