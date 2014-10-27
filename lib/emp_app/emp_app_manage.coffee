path = require 'path'
fs = require 'fs'
c_process = require 'child_process'
os = require 'os'
emp = require '../exports/emp'

bash_path_key = 'emp-debugger.path'
pid = null

emp_app_view = null
app_state = false
emp_app_start_script='iewp'
emp_app_make_cmd='make'
emp_app_config_cmd='configure'
emp_app_config_arg= ['--with-debug', '--with-mysql']
emp_import_menu = '[{App_name, _}|_]=ewp_app_manager:all_apps(),ewp_channel_util:import_menu(App_name).'
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

    # unless atom.config.get(emp.EMP_IMPORT_MENU_KEY)
    atom.config.set(emp.EMP_IMPORT_MENU_KEY, emp_import_menu)

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
        show_error("Compile erl error ~")
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
    if f_state
      c_process.execFile conf_f_p, conf_ags, cwd:cwd, (error, stdout, stderr) ->
        if (error instanceof Error)
          # throw error
          console.warn error.message
          show_error("Compile erl error ~")
        format_stdout(stdout)
        format_stderr(stderr)
        emp_app_view.hide_loading()
    else
      show_error("Configure app error ~")



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
    if f_state
      pid = c_process.spawn script_exc, cwd:cwd
      app_state = true
      set_app_stat(true)
      pid.stdout.on 'data', (data) ->
        console.info data.binarySlice()

      pid.stderr.on 'data', (data) ->
        console.error data.binarySlice()

      # pid.on 'message', (msg) ->
      #   console.warn msg

      pid.on 'close', (code) ->
        app_state = false
        # set_app_stat(false)
        pid.stdin.end()
        emp_app_view.refresh_app_st(app_state)
        console.warn "close over:#{code}"
    else
      show_error("Run app error ~")

  stop_app: ->
    # console.log "stop"
    if app_state
      app_state = false
      set_app_stat(false)
      if pid
        pid.stdin.write('q().\r\n')
        pid.kill()
      else
        show_error("no Pid ~")
    else
      show_error("The app is not running ~")

  run_erl: (erl_str) ->
    # console.log "erl:#{erl_str}"
    if app_state
      if pid
        pid.stdin.write(erl_str+'\r\n')
      else
        show_error("no Pid ~")
    else
      show_error("The app is not running ~")


  import_menu: ->
    erl_str = atom.config.get(emp.EMP_IMPORT_MENU_KEY)
    console.log erl_str
    # app_name = @get_app_name()
    # app_name = atom.project.emp_app_name
    # if !app_name
    #   app_name = @get_app_name()
    #   atom.project.emp_app_name = app_name
    # console.log app_name
    if app_state
      if pid
        pid.stdin.write(erl_str+'\r\n')
      else
        show_error("no Pid ~")
    else
      show_error("The app is not running ~")

  get_app_name: ->
    # ewp_app_manager:all_apps().
    if app_state
      if pid
        pid.stdin.write(emp_get_app_name+'\r\n')
      else
        show_error("no Pid ~")
    else
      show_error("The app is not running ~")

  get_app_state: ->
    return app_state

  initial_path: ->
    os_platform = os.platform().toLowerCase()
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
    pid.stdin.write('io:format("test ~n",[]). \r\n')
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


show_error = (err_msg) ->
  atom.confirm
    message:"Error"
    detailedMessage:err_msg

set_app_stat = (state)->
  console.log "set stat :#{state}"
  if state
    atom.project.emp_app_pid = pid
  else
    atom.project.emp_app_pid = null

  atom.project.emp_app_state = state
