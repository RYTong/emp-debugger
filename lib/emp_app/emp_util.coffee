path = require 'path'
fs = require 'fs'
c_process = require 'child_process'
os = require 'os'

OS_DARWIN = 'darwin'
OS_PATH = 'PATH'

bash_path_key = 'emp-debugger.path'
pid = null

initial_path = ->
  os_platform = os.platform().toLowerCase()
  console.log os_platform
  unless os_platform isnt OS_DARWIN

    bash_path = atom.config.get(bash_path_key)
    # console.log bash_path
    # console.log process.env[OS_PATH]
    if bash_path is undefined
      exportsCommand = process.env.SHELL + " -lc export"
      # console.log exportsCommand
      # Run the command and update the local process environment:
      c_process.exec exportsCommand, (error, stdout, stderr) ->
        for definition in stdout.trim().split('\n')
          [key, value] = definition.split('=', 2)
          key = key.trim().split(" ").pop()
          # console.log "key:#{key}, value:#{value}"
          unless key isnt OS_PATH
            process.env[key] = value
            atom.config.set(bash_path_key, value)
    else
      process.env[OS_PATH] = bash_path

compile_paser = ->
  # check the erl environmenr
  c_process.exec "which erlc", (error, stdout, stderr) ->
    try
      if (error instanceof Error)
        console.warn error.message
        throw "No erl environment~"

      erl_dir = path.join(__dirname, rel_erl_dir)
      # erl_beam = path.join(__dirname, '../util/parse_json.beam')
      ebin_dir = path.join(__dirname, rel_ebin_dir)
      erlc_str = 'erlc -o '+ebin_dir+' '+erl_dir+' -noshell -s erlang halt'
  #
      c_process.exec erlc_str, (error, stdout, stderr) ->
        if (error instanceof Error)
          # throw error
          console.warn error.message
          show_error("Compile erl error ~")
        # console.log "compile:#{error}"
        # console.log "compile:#{stdout}"
        # console.log "compile:#{stderr}"
        # console.log "compile erl"
    catch err
      show_error(err)

do_test = ->
  pid = c_process.spawn 'erl', ['-setcookie',' ewpcool', ' -sname', ' test1']
  pid.stdout.on 'data', (data) ->
    console.log "stdout: #{data}"

  pid.stderr.on 'data', (data) ->
    console.log "stderr: #{data}"

  pid.on 'close', (code) ->
    console.log "close: #{code}"
    pid.stdin.end()

  console.log pid


do_else = ->
  console.log "do_else"
  # pid.stdin.write("io:format(\"test ~n\",[]).\r\n")
  pid.stdin.write('io:format("test ~n",[]). \r\n')
  # pid.stdin.write("1.")
  # pid.stdin.write("q().")



show_error = (err_msg) ->
  atom.confirm
    message:"Error"
    detailedMessage:err_msg


module.exports.initial_path = initial_path
module.exports.do_test = do_test
module.exports.do_else = do_else
