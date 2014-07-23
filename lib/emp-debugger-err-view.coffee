{View} = require 'atom'

module.exports =
class EmpDebuggerErrView extends View
  @content: ->
    @div class: "panel", =>
      @div class: "panel-heading", 'A .panel heading'
      @div class: "panel-body padded", 'Some Content goes here. I am padded!'

  initialize: (serializeState) ->
    console.log "init"
    atom.workspaceView.command "emp-debugger:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "EmpDebuggerErrView was debug!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)

  warn_dialog:(msg) ->
    console.log "this a waring dialog"
    @div class: 'overlay from-top select-list', =>
      @div class: 'editor editor-colors mini', "I searched for this: #{msg}"
      @div class: 'error-message', 'Nothing has been found!'
