EmpDebuggerView = require './emp-debugger-view'
# EmpDebuggerErrView = require './emp-debugger-err-view'
ttt = require './ttt'
{EditorView} = require 'atom'
ds = require './debugger/debug_socket'
n_state = null


module.exports =
  empDebuggerView: null
  empDebuggerErrView: null

  activate:(state) ->
    n_state = state
    console.log "active"
    # ttt.test()
    atom.workspaceView.command "emp-debugger:convert", => @convert()
    atom.workspaceView.command "emp-debugger:init", => @init()
    atom.workspaceView.command "emp-debugger:debug", => @debug()
    atom.workspaceView.command "emp-debugger:close", => @close()
    # @empDebuggerView = new EmpDebuggerView(state.empDebuggerViewState)
    @empDebuggerView = new EmpDebuggerView(n_state.empDebuggerViewState)
    # @empDebuggerErrView = new EmpDebuggerErrView(n_state.empDebuggerErrViewState)

  convert: ->
    console.log "conver"
    # @empDebuggerView = new EmpDebuggerView(n_state.empDebuggerViewState)
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
    @empDebuggerView.destroy()

  serialize: ->
    console.log '--- serialize'
    empDebuggerViewState: @empDebuggerView.serialize()

  init: ->
    console.log '--- init'
    ds.init('localhost', 7003)

  debug: ->
    editor = atom.workspace.activePaneItem
    if editor
      # console.log "editor:#{editor}"
      debug_text = editor.getText()
      # console.log "debug_text: #{debug_text}"
      ds.debug(debug_text)
    else
      atom.confirm
        message:"Error"
        detailedMessage:"There's no editors~"

  close: ->
    ds.close()


      # @empDebuggerErrView = new EmpDebuggerErrView(n_state.empDebuggerErrViewState)
