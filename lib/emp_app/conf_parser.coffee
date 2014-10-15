path = require 'path'
fs = require 'fs'
c_process = require 'child_process'
os = require 'os'

OS_DARWIN = 'darwin'
OS_PATH = 'PATH'

bash_path_key = 'emp-channel-wizard.path'

rel_erl_dir = '../../erl_util/atom_pl_parse_json.erl'
rel_ebin_dir = '../../erl_util/'
emp = require '../exports/emp'

# @doc 编译状态标示 编译步骤，最多2步，
# 0标示未开始，1标示初始化path，2标示编译开始
com_state = 0

initial_parser = (callback)->
  # console.log "init"
  # console.log "state:#{com_state}"
  if com_state is 0
    initial_path()
    compile_paser(callback)
  else if com_state is 1
    compile_paser(callback)
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


compile_paser = (callback)->
  # check the erl environmenr
  c_process.exec "which erlc", (error, stdout, stderr) ->
    try
      if (error instanceof Error)
        console.warn error.message
        throw "No erl environment~"

      erl_dir = path.join(__dirname, rel_erl_dir)
      ebin_dir = path.join(__dirname, rel_ebin_dir)
      erlc_str = 'erlc -o '+ebin_dir+' '+erl_dir+' -noshell -s erlang halt'
  #
      c_process.exec erlc_str, (error, stdout, stderr) ->
        if (error instanceof Error)
          console.warn error.message
          console.log stderr
          emp.show_error("Compile erl error ~")
        else

          set_compile_state()
          callback.add_new_panel_f()
    catch err
      emp.show_error(err)

module.exports.remove_cha = (cha_str) ->
  # console.log "~~---------------remove cha ~~:#{cha_str}"
  channel_conf = atom.project.channel_conf
  parse_beam_dir = atom.project.parse_beam_dir
  t_erl = 'erl -pa '+parse_beam_dir+' -channel_conf '+channel_conf
  t_erl = t_erl+' -cha_id'+cha_str+' -sname testjs -run atom_pl_parse_json remove_channel -noshell -s erlang halt'
  c_process.exec t_erl, (error, stdout, stderr) ->
    if (error instanceof Error)
      console.log error.message
      emp.show_error(error.message)
    if stderr
      console.error "compile:#{stderr}"


module.exports.remove_col = (col_str) ->
  # console.log "~~---------------remove col ~~:#{col_str}"
  channel_conf = atom.project.channel_conf
  parse_beam_dir = atom.project.parse_beam_dir
  t_erl = 'erl -pa '+parse_beam_dir+' -channel_conf '+channel_conf
  t_erl = t_erl+' -col_id'+col_str+' -sname testjs -run atom_pl_parse_json remove_col -noshell -s erlang halt'
  c_process.exec t_erl, (error, stdout, stderr) ->
    # console.log "compile:#{stdout}"
    if (error instanceof Error)
      console.log error.message
      emp.show_error(error.message)
    if stderr
      console.error "compile:#{stderr}"

module.exports.edit_col = (col_str) ->
  # console.log "~~---------------remove col ~~:#{col_str}"
  channel_conf = atom.project.channel_conf
  parse_beam_dir = atom.project.parse_beam_dir
  t_erl = 'erl -pa '+parse_beam_dir+' -channel_conf '+channel_conf
  t_erl = t_erl+col_str+' -sname testjs -run atom_pl_parse_json edit_col -noshell -s erlang halt'
  # console.log t_erl
  c_process.exec t_erl, (error, stdout, stderr) ->
    # console.log "compile:#{stdout}"
    if (error instanceof Error)
      console.log error.message
      emp.show_error(error.message)
    if stderr
      console.error "compile:#{stderr}"

module.exports.edit_cha = (cha_str) ->
  channel_conf = atom.project.channel_conf
  parse_beam_dir = atom.project.parse_beam_dir
  t_erl = 'erl -pa '+parse_beam_dir+' -channel_conf '+channel_conf
  t_erl = t_erl+cha_str+' -sname testjs -run atom_pl_parse_json edit_cha -noshell -s erlang halt'
  # console.log t_erl
  c_process.exec t_erl, (error, stdout, stderr) ->
    # console.log "compile:#{stdout}"
    if (error instanceof Error)
      console.log error.message
      emp.show_error(error.message)
    if stderr
      console.error "compile:#{stderr}"

set_path_state = ->
  com_state = 1

set_compile_state = ->
  unless com_state isnt 1
    com_state = 2


module.exports.initial_parser = initial_parser
module.exports.initial_path = initial_path
