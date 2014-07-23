{View} = require 'atom'

module.exports =
class EmpDebuggerView extends View
  @content: ->
    console.log "constructor"
    @div class: "emp-debugger overlay from-top panel", =>
    # @div class: "my-package tool-panel panel-bottom padded", =>
    #   @div class: "inset-panel", =>
    #     @div class: "panel-heading", 'An inset-panel heading'
    #     @div class: "panel-body padded", 'Some Content'
      @div class: "panel-heading", 'A .panel heading'
      @div class: "panel-body padded", 'Some Content goes here. I am padded!'
      @div class: 'editor mini editor-colors', 'Something you typed...'
      # @div class: 'block', =>
        # @label 'You might want to type something here.'
        # @div class: 'editor mini editor-colors', 'Something you typed...'
      @div class: 'block', =>
        @button class: 'btn', 'Do it'


  initialize: (serializeState) ->
    console.log "initial"
    atom.workspaceView.command "emp-debugger:convert", => @convert()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  convert: ->
    console.log "EmpDebuggerView was toggled!"
    if @hasParent()
      console.log "dddddd!"
      @detach()
    else
      atom.workspaceView.append(this)

  warn_dialog:(msg) ->
    console.log "this a waring dialog"
    @div class: 'overlay from-top select-list', =>
      @div class: 'editor editor-colors mini', "I searched for this: #{msg}"
      @div class: 'error-message', 'Nothing has been found!'
