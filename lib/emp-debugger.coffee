EmpDebuggerInitView = require './view/emp-debugger-view'
EmpDebuggerStateView = require './view/emp-state-view'
EmpEnableView = require './view/emp-enable-view'
# EmpDebuggerErrView = require './emp-debugger-err-view'
ttt = require './ttt'
{EditorView} = require 'atom'
ds = require './debugger/debug_socket'
EmpSocketServer = require './debugger/emp_socket'
n_state = null


module.exports =
  empDebuggerInitView: null
  empDebuggerStateView: null
  empDebuggerErrView: null
  empEnableView: null
  emp_socket_server: null

  activate:(state) ->
    n_state = state
    console.log "active"
    # ttt.test()
    atom.workspaceView.command "emp-debugger:convert", => @convert()
    atom.workspaceView.command "emp-debugger:init", => @init()
    atom.workspaceView.command "emp-debugger:live_preview", => @live_preview()
    atom.workspaceView.command "emp-debugger:close", => @close()
    atom.workspaceView.command "emp-debugger:enable_view", => @enable_view()
    # @empDebuggerInitView = new empDebuggerInitView(state.empDebuggerInitViewState)
    @emp_socket_server = new EmpSocketServer()
    @empDebuggerInitView = new EmpDebuggerInitView(n_state.empDebuggerInitViewState, @emp_socket_server)
    @empDebuggerStateView = new EmpDebuggerStateView(n_state.empDebuggerStateViewState, @emp_socket_server)
    @empEnableView = new EmpEnableView(n_state.empEnableViewState, @emp_socket_server)
    # @empDebuggerErrView = new EmpDebuggerErrView(n_state.empDebuggerErrViewState)

  convert: ->
    console.log "conver"
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
    console.log '--- deactivate'
    @empDebuggerInitView.destroy()
    @empDebuggerStateView.destroy()

  serialize: ->
    console.log '--- serialize'
    empDebuggerStateViewState: @empDebuggerStateView.serialize()
    empEnableViewState: @empEnableView.serialize()
    empDebuggerInitViewState: @empDebuggerInitView.serialize()


  init: ->
    console.log '--- init'
    @emp_socket_server.init('localhost', 7003)

  live_preview: ->
    editor = atom.workspace.activePaneItem
    if editor
      # console.log "editor:#{editor}"
      debug_text = editor.getText()
      # console.log "debug_text: #{debug_text}"
      @emp_socket_server.debug(debug_text)
    else
      atom.confirm
        message:"Error"
        detailedMessage:"There's no editors~"

  enable_view: ->
    console.log "show enable view~"

    if @emp_socket_server.get_server() isnt null
      console.log @emp_socket_server.get_enable_view_list()



  close: ->
    @emp_socket_server.close()


      # @empDebuggerErrView = new EmpDebuggerErrView(n_state.empDebuggerErrViewState)
