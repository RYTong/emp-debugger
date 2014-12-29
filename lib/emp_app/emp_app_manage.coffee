{BufferedProcess,Emitter} = require 'atom'
path = require 'path'
fs = require 'fs'
c_process = require 'child_process'
emp = require '../exports/emp'

bash_path_key = 'emp-debugger.path'
pid = null
npid = null
node_name = null

emp_app_view = null
app_state = false
connect_state = false
emp_app_start_script='iewp'
emp_app_make_cmd='make'
emp_app_config_cmd='configure'
emp_app_config_arg= ['--with-debug', '--with-mysql']
emp_import_menu = '[{App_name, _}|_]=ewp_app_manager:all_apps(),ewp_channel_util:import_menu(App_name).'
emp_c_make = '[{App_name, _}|_]=ewp_app_manager:all_apps(), ewp:c_app(App_name).'
emp_get_app_name = '[{A, _}|_]=ewp_app_manager:all_apps(), A.'



# 定义编译文件到 atom conf 中
# emp_app_  ='iewp'

# EMP_MAKE_CMD_KEY = 'emp-debugger.emp-make'
# EMP_STAET_SCRIPT_KEY = 'emp-debugger.emp-start-script'
# EMP_CONFIG_KEY = 'emp-debugger.emp-config'
# EMP_CONFIG_ARG_KEY = 'emp-debugger.emp-config-arg'

module.exports =
class emp_app
  project_path: null
  erl_project: true

  constructor: (tmp_emp_app_view)->
    @project_path = atom.project.getPath()
    emp_app_view = tmp_emp_app_view
    unless atom.config.get(emp.EMP_MAKE_CMD_KEY)
      atom.config.set(emp.EMP_MAKE_CMD_KEY, emp_app_make_cmd)
    # else
    #   emp_app_make_cmd = tmp_emp_make

    unless atom.config.get(emp.EMP_STAET_SCRIPT_KEY)
      atom.config.set(emp.EMP_STAET_SCRIPT_KEY, emp_app_start_script)
    # else
    #   emp_app_start_script = tmp_emp_start_sc

    unless atom.config.get(emp.EMP_CONFIG_KEY)
      atom.config.set(emp.EMP_CONFIG_KEY, emp_app_config_cmd)
    # else
    #   emp_app_config_cmd = tmp_emp_config_sc
    # app_state = false

    unless atom.config.get(emp.EMP_CONFIG_ARG_KEY)
      atom.config.set(emp.EMP_CONFIG_ARG_KEY, emp_app_config_arg)

    unless atom.config.get(emp.EMP_IMPORT_MENU_KEY)
      atom.config.set(emp.EMP_IMPORT_MENU_KEY, emp_import_menu)

    unless atom.config.get(emp.EMP_CMAKE_KEY)
      atom.config.set(emp.EMP_CMAKE_KEY, emp_c_make)
    # console.log "project_path:#{@project_path}"
    @initial_path()

  make_app: ->
    # console.log "make"
    make_str = atom.config.get(emp.EMP_MAKE_CMD_KEY)
    cwd = atom.project.getPath()

    # console.log cwd
    c_process.exec make_str, cwd:cwd, (error, stdout, stderr) ->
      if (error instanceof Error)
        # throw error
        console.warn error.message
        show_error("Make error ~")
      # console.log "compile:#{error}"
      # console.log "compile:#{stdout}"
      format_stdout(stdout)
      format_stderr(stderr)
      emp_app_view.hide_loading()

  config_app: ->
    # console.log "config"
    conf_file = atom.config.get(emp.EMP_CONFIG_KEY)
    conf_ags = atom.config.get(emp.EMP_CONFIG_ARG_KEY)
    # console.log conf_ags
    cwd = atom.project.getPath()
    conf_f_p = path.join cwd, conf_file
    # console.log conf_f_p
    f_state = fs.existsSync conf_f_p
    # console.log f_state
    # console.log cwd
    try
      if f_state
        conf_stat = fs.statSync(conf_f_p).mode & 0o0777
        if conf_stat < 457
          fs.chmodSync(conf_f_p, 493)

      script_file = atom.config.get(emp.EMP_STAET_SCRIPT_KEY)
      script_path = path.join cwd, script_file
      # console.log script_path
      if fs.existsSync script_path
        script_stat = fs.statSync(script_path).mode & 0o0777
        if script_stat < 457
          fs.chmodSync(conf_f_p, 493)
    catch e
      console.error e


    if f_state
      c_process.execFile conf_f_p, conf_ags, cwd:cwd, (error, stdout, stderr) ->
        if (error instanceof Error)
          # throw error
          console.warn error.message
          emp.show_error("Configure app error ~")
        format_stdout(stdout)
        format_stderr(stderr)
        emp_app_view.hide_loading()
    else
      emp.show_error("Configure app error ~")



  run_app: ->
    # console.log "run"
    script_file = atom.config.get(emp.EMP_STAET_SCRIPT_KEY)
    script_exc = './' +script_file
    cwd = atom.project.getPath()
    script_path = path.join cwd, script_file
    # console.log script_path
    f_state = fs.existsSync script_path

    # console.log f_state
    # console.log cwd
    # console.log script_exc
    # console.log cwd
    if f_state
      if pid
        tmp_pid = pid
        pid = null
        tmp_pid.kill()

      # stdout = (data) ->
      #   console.log data
      #   # console.info data.binarySlice()
      # stderr = (data) ->
      #   console.error data.binarySlice()
      # exit = (code) ->
      #   console.log "exit"
      #   app_state = false
      #   # pid.stdin.write('q().\r\n')
      #   # set_app_stat(false)
      #   pid.stdin.end()
      #   emp_app_view.refresh_app_st(app_state)
      #   console.warn "close over:#{code}"

      # pid = new BufferedProcess({command:script_exc, args:[], options:{cwd:cwd}, stdout:stdout, stderr:stderr, exit:exit})
      pid = c_process.spawn script_exc, [],  {cwd:cwd, env: process.env}
      app_state = true
      set_app_stat(true)
      pid.stdout.on 'data', (data) ->
        console.info data.binarySlice()
      # pid.stdout.pipe process.stdout

      pid.stderr.on 'data', (data) ->
        console.error data.binarySlice()

      pid.on 'SIGINT', (data) ->
        console.log "-------------------------"
        console.log data

      pid.on 'close', (code) ->
        app_state = false
        # pid.stdin.write('q().\r\n')
        # set_app_stat(false)
        pid.stdin.end()
        emp_app_view.refresh_app_st(app_state)
        console.warn "close over:#{code}"
    else
      emp.show_error("Run app error ~")

  # test: ({command, args, options, stdout, stderr, exit}={}) ->
  #   @emitter = new Emitter
  #   options ?= {}
  #   # Related to joyent/node#2318
  #   if process.platform is 'win32'
  #     # Quote all arguments and escapes inner quotes
  #     if args?
  #       cmdArgs = args.filter (arg) -> arg?
  #       cmdArgs = cmdArgs.map (arg) =>
  #         if @isExplorerCommand(command) and /^\/[a-zA-Z]+,.*$/.test(arg)
  #           # Don't wrap /root,C:\folder style arguments to explorer calls in
  #           # quotes since they will not be interpreted correctly if they are
  #           arg
  #         else
  #           "\"#{arg.toString().replace(/"/g, '\\"')}\""
  #     else
  #       cmdArgs = []
  #     if /\s/.test(command)
  #       cmdArgs.unshift("\"#{command}\"")
  #     else
  #       cmdArgs.unshift(command)
  #     cmdArgs = ['/s', '/c', "\"#{cmdArgs.join(' ')}\""]
  #     cmdOptions = _.clone(options)
  #     cmdOptions.windowsVerbatimArguments = true
  #     @process = ChildProcess.spawn(@getCmdPath(), cmdArgs, cmdOptions)
  #   else
  #     console.log command
  #     console.log args
  #     console.log options
  #     @process = c_process.spawn(command, args, options)
  #   @killed = false

  stop_app: ->
    # console.log "stop"
    if app_state
      app_state = false
      set_app_stat(false)
      if pid
        pid.kill()
      else
        emp.show_error("no Pid ~")
    else
      emp.show_error("The app is not running ~")

  run_erl: (erl_str) ->
    # console.log "erl:#{erl_str}"
    if app_state
      if pid
        # pid.stdin.resume()
        pid.stdin.write(erl_str+'\n')
        # pid.stdin.end()
      else
        emp.show_error("no Pid ~")
    else
      emp.show_error("The app is not running ~")

  connect_node: (tmp_node_name, node_cookie, fa_view)->
    node_name = tmp_node_name
    atom.project.emp_node_name = tmp_node_name
    console.log "node_name:#{node_name}, cookie:#{node_cookie}"
    # console.log "-------"
    unless node_cookie.match(/\-setcookie/ig)
      node_cookie = " -setcookie " +node_cookie
    # console.log "------zzz-:#{node_cookie}"
    check_flag = ''
    unless node_cookie.match(/\-sname|\-name/ig)
      # console.log emp.mk_node_name()
      tmp_obj = emp.mk_node_name(node_name)
      # console.log tmp_obj
      check_flag = tmp_obj.name
      node_cookie = node_cookie + tmp_obj.node_name
    t_erl = '-pa '+ atom.project.parse_beam_dir + node_cookie
    re_arg = ["-run", "#{emp.parser_beam_file_mod}", "connect_node", ""+node_name, ""+check_flag]
    re_arg = re_arg.concat(t_erl.replace(/\s+/ig, " ").split(" "))

    cwd = atom.project.getPath()
    # console.log t_erl
    # console.log re_arg
    if npid
      tmp_pid = npid
      npid = null
      tmp_pid.kill()

    npid = c_process.spawn "erl", re_arg,  {cwd:cwd}
    connect_state = true
    set_node_stat(true)
    npid.stdout.on 'data', (data) ->
      console.info data.binarySlice()

    npid.stderr.on 'data', (data) ->
      err_msg = data.binarySlice()
      if err_msg is "error_" + check_flag
        console.error "Connect remote error"
        connect_state = false
        set_node_stat(false)
        fa_view.refresh_node_st(connect_state)
      else
        console.error data.binarySlice()

    npid.on 'close', (code) ->
      connect_state = false
      console.log "close -------"
      # npid.stdin.write('q().\r\n')
      npid.stdin.end()
      # emp_app_view.refresh_app_st(app_state)
      console.warn "close over:#{code}"


  disconnect_node: ->
    if connect_state
      if npid
        npid.kill()

  run_nerl: (erl_str) ->

    if connect_state
      if npid
        if erl_str.match(/^[\w\d]*:[\w\d]*/ig)
          erl_str = "#{emp.parser_beam_file_mod}:run_in_remote(\'#{node_name}\', \"#{erl_str}\")."
        console.log "erl:#{erl_str}"
        npid.stdin.write(erl_str+'\n')
      else
        emp.show_error("no Pid ~")
    else
      emp.show_error("The app is not running ~")

  make_app_runtime_node: ->
    emp_c_make_node = "#{emp.parser_beam_file_mod}:node_fun_call(\'#{node_name}\', node_cmake)."
    @run_to_node(emp_c_make_node)

  import_menu_node: ->
    emp_c_make_node = "#{emp.parser_beam_file_mod}:node_fun_call(\'#{node_name}\', node_import)."
    @run_to_node(emp.EMP_IMPORT_MENU_KEY)


  make_app_runtime: ->
    @run_from_conf(emp.EMP_CMAKE_KEY)

  import_menu: ->
    @run_from_conf(emp.EMP_IMPORT_MENU_KEY)

  run_from_conf: (key)->
    erl_str = atom.config.get(key)
    # console.log erl_str
    if app_state
      if pid
        # pid.stdin.resume()
        pid.stdin.write(erl_str+'\n')

        # pid.stdin.end()
        # pid.stdin.write('\r\n')
      else
        emp.show_error("no Pid ~")
    else
      emp.show_error("The app is not running ~")

  run_to_node: (erl_str)->
    # ewp_app_manager:all_apps().
    if connect_state
      if npid
        npid.stdin.write(erl_str+'\n')
      else
        emp.show_error("no Pid ~")
    else
      emp.show_error("The app is not running ~")

  get_app_state: ->
    return app_state

  initial_path: ->
    os_platform = emp.get_emp_os()
    # console.log os_platform
    if os_platform is emp.OS_DARWIN or os_platform is emp.OS_LINUX

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
            unless key isnt emp.OS_PATH
              process.env[key] = value
              atom.config.set(bash_path_key, value)
      else
        process.env[emp.OS_PATH] = bash_path

  check_project: ->
    console.log "checking ~"

  do_test: ->
    pid = c_process.spawn 'erl', ['-setcookie',' ewpcool', ' -sname', ' test1']
    pid.stdout.on 'data', (data) ->
      console.log "stdout: #{data}"

    pid.stderr.on 'data', (data) ->
      console.log "stderr: #{data}"

    pid.on 'close', (code) ->
      console.log "close: #{code}"
      pid.stdin.end()

    console.log pid


  do_send: (str)->
    console.log "do_else"
    # pid.stdin.write("io:format(\"test ~n\",[]).\r\n")
    pid.stdin.write('io:format("test ~n",[]). \n')
    # pid.stdin.write("1.")
    # pid.stdin.write("q().")


format_stdout = (stdout)->
  unless !stdout
    for log in stdout.trim().split('\n')
      console.info log

format_stderr = (stdout)->
  unless !stdout
    for log in stdout.trim().split('\n')
      console.error log

set_app_stat = (state)->
  # console.log "set stat :#{state}"
  if state
    atom.project.emp_app_pid = pid
  else
    atom.project.emp_app_pid = null

  atom.project.emp_app_state = state

set_node_stat = (state) ->
  if state
    atom.project.emp_node_pid = npid
  else
    atom.project.emp_node_pid = null

  atom.project.emp_node_state = state
