{EditorView} = require 'atom'
# EmpDebuggerInitView = require './view/emp-debugger-view'
# EmpDebuggerStateView = require './view/emp-state-view'
EmpEnableView = require './view/emp-enable-view'
EmpEnableLuaView = require './view/emp-enable-lua-view'
EmpDebuggerLogView = require './view/emp-log-view.coffee'
EmpDebuggerSettingView = require './view/emp-debugger-setting-view.coffee'
EmpSocketServer = require './debugger/emp_socket'
# EmpChaWizard = require './channel_view/emp-channel-wizard'
EmpViewManage = require './view/emp-views-entrance'
conf_parser = require './emp_app/conf_parser'
emp = require './exports/emp'
n_state = null
path = require 'path'

module.exports =
  empDebuggerInitView: null
  empDebuggerStateView: null
  empDebuggerErrView: null
  empEnableView: null
  empEnableLuaView: null
  empDebuggerLogView: null
  emp_socket_server: null
  empDebuggerSettingView: null

  activate:(state) ->
    n_state = state
    # console.log "active"
    @empDebuggerLogView = new EmpDebuggerLogView(n_state.empDebuggerLogViewState)
    @emp_socket_server = new EmpSocketServer(@empDebuggerLogView)
    @empEnableView = new EmpEnableView(n_state.empEnableViewState, @emp_socket_server)
    @empEnableLuaView = new EmpEnableLuaView(n_state.empEnableLuaViewState, @emp_socket_server)
    @empDebuggerSettingView = new EmpDebuggerSettingView(n_state.empDebuggerSettingViewState,
                                  @emp_socket_server, @empDebuggerLogView, this)

    atom.commands.add "atom-workspace","emp-debugger:live-preview", => @live_preview()
    # atom.commands.add "atom-workspace","emp-debugger:setting-view", => @set_conf()

    EmpViewManage.activate()
    conf_parser.initial_parser()

  # convert: ->
    # @empDebuggerInitView.start_listen(@empDebuggerInitView)
    # @empDebuggerInitView = new empDebuggerInitView(n_state.empDebuggerInitViewState)
    # o = new Object("tetst");
    # atom.open(o)
    # miniEditorView = new EditorView(mini: true)
    # console.log(miniEditorView)
    # atom.workspaceView.appendToBottom(miniEditorView)
    # acc_pane =  atom.workspace.getActivePane()
    # acc_pane.addItem(miniEditorView, 0)
    # atom.menu.add [
    #   {
    #     label: 'Hello'
    #     submenu : [{label: 'World!', command: 'hello:world'}]
    #   }
    # ]
    # atom.menu.update()
    # craft = new Spacecraft()
    # craft.find('h1').text() # 'Spacecraft'
    # craft.appendTo(document.body)
    # editor = atom.workspace.activePaneItem
    # selection = editor.getSelectedText()
    # console.log(selection)
    # editor.insertText('Hello, World')


  deactivate: ->
    # @empDebuggerInitView.destroy()
    # @empDebuggerStateView.destroy()
    @empDebuggerErrView.destroy()
    @empEnableView.destroy()
    @empEnableLuaView.destroy()
    @empDebuggerLogView.destroy()
    @emp_socket_server.destroy()
    @empDebuggerSettingView.destroy()

  serialize: ->
    # empDebuggerStateViewState: @empDebuggerStateView.serialize()
    empEnableViewState: @empEnableView.serialize()
    empEnableLuaViewState: @empEnableLuaView.serialize()
    # empDebuggerInitViewState: @empDebuggerInitView.serialize()
    empDebuggerLogViewState: @empDebuggerLogView.serialize()
    empDebuggerSettingViewState: @empDebuggerSettingView.serialize()

  live_preview: ->
    editor = atom.workspace.getActiveEditor()
    if editor
      text_path = editor.getPath()
      text_ext  = undefined
      text_ext  = path.extname(text_path ).toLowerCase() unless !text_path
      debug_text = editor.getText()
      # live preview lus script with lua file
      if text_ext is emp.DEFAULT_EXT_LUA
        text_name = path.basename(text_path)
        @emp_socket_server.live_preview_lua(text_name, debug_text)
      else if text_ext is emp.DEFAULT_EXT_XHTML # live preview xhtml file
        @emp_socket_server.live_preview_view(debug_text)
      else if text_ext
        emp.self_info("Warnning", "Unrecognise file type, unable live preview~")
      else
        debug_view = editor["emp_live_view"]
        debug_script_name = editor["emp_live_script_name"]
        debug_script = editor["emp_live_script"]
        # if the debug script exist, then live preview the lua script
        if debug_script
          debug_script.script_con = debug_text
          @emp_socket_server.live_preview_view(debug_view, debug_text, debug_script_name)
        else if debug_view
          # if the script isn't exist , then live preview the view
          debug_view.view = debug_text
          @emp_socket_server.live_preview_view(debug_text)
        else
          emp.show_error("No Content to live preview~")
    else
      emp.show_error("There's no editors~")

  show_enable_view: ->
    @empEnableView.enable_view()

  show_enable_lua: ->
    @empEnableLuaView.enable_lua()
