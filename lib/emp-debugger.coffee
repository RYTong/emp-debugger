{EditorView} = require 'atom'
EmpEnableView = require './view/emp-enable-view'
EmpEnableLuaView = require './view/emp-enable-lua-view'
EmpDebuggerLogView = require './view/emp-log-view.coffee'
EmpDebuggerSettingView = require './view/emp-debugger-setting-view.coffee'
EmpSocketServer = require './debugger/emp_socket'
EmpViewManage = require './view/emp-views-entrance'
conf_parser = require './emp_app/conf_parser'
ErtUiGuide = require './guide/emp-debugger-ui-guide'
EMPOpenLink = require './link/emp-open-link'
LessCompileView = require './less_compile/less-compile-view'
EmpErlIndent = require './indent/emp-erl-indent'

emp = require './exports/emp'
n_state = null
path = require 'path'

module.exports =

  config:
    defLimitOfLogLine:
      type: 'array'
      default: [500, 1000, 2000, 5000, 10000]

    defLimitOfLogLineSelected:
      type: 'integer'
      default: 1000

    defErlangIndentTabLength:
      type: 'integer'
      default: 4

    defErlangIndentUseTab:
      type: 'boolean'
      default: false

    defLogFilterFlag:
      type: 'string'
      default:','

    defAPIData:
      type: 'string'
      default:'app=ebank&o=i'

  empDebuggerInitView: null
  empDebuggerStateView: null
  empDebuggerErrView: null
  empEnableView: null
  empEnableLuaView: null
  empDebuggerLogView: null
  emp_socket_server: null
  empDebuggerSettingView: null
  empLessAutocompile:null
  empErlIndent:null

  activate:(state) ->
    n_state = state
    # console.log "active"
    @empLessAutocompile = new LessCompileView(state.lessCompileViewState)
    @empDebuggerLogView = new EmpDebuggerLogView(n_state.empDebuggerLogViewState)
    @emp_socket_server = new EmpSocketServer(@empDebuggerLogView)
    @empEnableView = new EmpEnableView(n_state.empEnableViewState, @emp_socket_server)
    @empEnableLuaView = new EmpEnableLuaView(n_state.empEnableLuaViewState, @emp_socket_server)
    @empDebuggerSettingView = new EmpDebuggerSettingView(n_state.empDebuggerSettingViewState,
                                  @emp_socket_server, @empDebuggerLogView, this)
    # @ertUiGuide = new ErtUiGuide(n_state.ertUiGuideState, this)
    @emp_open_link = new EMPOpenLink()
    @empErlIndent = new EmpErlIndent()
    atom.commands.add "atom-workspace", {
      "emp-debugger:live-preview":(event) => @live_preview()
      "emp-debugger:erl_indent": (event) => @do_erl_indent()

    }

    EmpViewManage.activate(oLessCompile:@empLessAutocompile)
    conf_parser.initial_parser()
    # snippets = require atom.packages.getActivePackage('snippets').mainModulePath
    # snippets.loadAll()
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
    # @ertUiGuide.destroy()
    @emp_open_link.destroy()
    @empLessAutocompile.destroy()
    # @empTestPanel.destroy()
    @empErlIndent.destroy()

  serialize: ->
    # empDebuggerStateViewState: @empDebuggerStateView.serialize()
    empEnableViewState: @empEnableView.serialize()
    empEnableLuaViewState: @empEnableLuaView.serialize()
    # empDebuggerInitViewState: @empDebuggerInitView.serialize()
    empDebuggerLogViewState: @empDebuggerLogView.serialize()
    empDebuggerSettingViewState: @empDebuggerSettingView.serialize()
    # ertUiGuideState:@ertUiGuide.serialize()
    lessCompileViewState: @empLessAutocompile.serialize()

  live_preview: ->
    editor = atom.workspace.getActiveTextEditor()
    if editor

      preview_obj = editor["emp_live_view"]
      debug_text = editor.getText()
      # console.log preview_obj
      # 判断是否为新协议页面
      if preview_obj?.new_type_view
        # console.log "new protocol send"
        @emp_socket_server.live_preview_view_with_new(preview_obj, debug_text)
      else
        text_path = editor.getPath()
        text_ext  = undefined
        text_ext  = path.extname(text_path ).toLowerCase() unless !text_path
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

  do_erl_indent: ->
    @empErlIndent.once_indent()
