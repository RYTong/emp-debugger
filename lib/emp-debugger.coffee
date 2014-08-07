EmpDebuggerInitView = require './view/emp-debugger-view'
EmpDebuggerStateView = require './view/emp-state-view'
EmpEnableView = require './view/emp-enable-view'
EmpDebuggerLogView = require './view/emp-log-view.coffee'
# EmpDebuggerErrView = require './emp-debugger-err-view'
{EditorView} = require 'atom'
EmpSocketServer = require './debugger/emp_socket'
n_state = null


module.exports =
  empDebuggerInitView: null
  empDebuggerStateView: null
  empDebuggerErrView: null
  empEnableView: null
  empDebuggerLogView: null
  emp_socket_server: null

  activate:(state) ->
    n_state = state
    # console.log "active"
    # atom.workspaceView.command "emp-debugger:convert", => @convert()
    # atom.workspaceView.command "emp-debugger:debug server", => @init()
    atom.workspaceView.command "emp-debugger:live-preview", => @live_preview()
    # atom.workspaceView.command "emp-debugger:close-server", => @close()
    # atom.workspaceView.command "emp-debugger:enable_view", => @enable_view()
    # @empDebuggerInitView = new empDebuggerInitView(state.empDebuggerInitViewState)
    @empDebuggerLogView = new EmpDebuggerLogView(n_state.empDebuggerLogViewState, @empDebuggerLogView)
    @emp_socket_server = new EmpSocketServer(@empDebuggerLogView)
    @empDebuggerInitView = new EmpDebuggerInitView(n_state.empDebuggerInitViewState, @emp_socket_server)
    @empDebuggerStateView = new EmpDebuggerStateView(n_state.empDebuggerStateViewState, @emp_socket_server, @empDebuggerLogView)
    @empEnableView = new EmpEnableView(n_state.empEnableViewState, @emp_socket_server)

    # @empDebuggerErrView = new EmpDebuggerErrView(n_state.empDebuggerErrViewState)

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
    @empDebuggerInitView.destroy()
    @empDebuggerStateView.destroy()

  serialize: ->
    console.log 'debugger serialize'
    empDebuggerStateViewState: @empDebuggerStateView.serialize()
    empEnableViewState: @empEnableView.serialize()
    empDebuggerInitViewState: @empDebuggerInitView.serialize()
    empDebuggerLogViewState: @empDebuggerLogView.serialize()

  # init: ->
    # console.log 'init emp server'
    # @emp_socket_server.init('localhost', 7003)

  live_preview: ->
    # console.log 'live preview'
    editor = atom.workspace.activePaneItem
    if editor
      debug_text = editor.getText()
      @emp_socket_server.debug(debug_text)
    else
      atom.confirm
        message:"Error"
        detailedMessage:"There's no editors~"

  # enable_view: ->
    # console.log "show enable view~"
    # if @emp_socket_server.get_server() isnt null
    #   console.log @emp_socket_server.get_enable_view_list()

  close: ->
    @emp_socket_server.close()
