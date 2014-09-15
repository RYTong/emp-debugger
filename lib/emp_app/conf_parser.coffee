path = require 'path'
fs = require 'fs'
c_process = require 'child_process'
os = require 'os'

OS_DARWIN = 'darwin'
OS_PATH = 'PATH'

bash_path_key = 'emp-channel-wizard.path'

rel_erl_dir = '../../erl_util/parse_json.erl'
rel_ebin_dir = '../../erl_util/'

com_state = 0

initial_parser = ->
  console.log "init"
  console.log "state:#{com_state}"
  if com_state is 0
    initial_path()
    compile_paser()
  else if com_state is 1
    compile_paser()

  return com_state

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
            set_path_state()
    else
      process.env[OS_PATH] = bash_path
      set_path_state()




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
        set_compile_state()
        # console.log "compile:#{error}"
        # console.log "compile:#{stdout}"
        # console.log "compile:#{stderr}"
        # console.log "compile erl"
    catch err
      show_error(err)


show_error = (err_msg) ->
  atom.confirm
    message:"Error"
    detailedMessage:err_msg

set_path_state = ->
  com_state = 1

set_compile_state = ->
  unless com_state isnt 1
    com_state = 2


module.exports.initial_parser = initial_parser
module.exports.initial_path = initial_path
