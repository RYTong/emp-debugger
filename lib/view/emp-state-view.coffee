{$, $$, View} = require 'atom'

module.exports =
class ServerStateView extends View
  emp_socket_server: null

  @content: ->
    console.log 'constructor'
    @div class: "emp-debugger bordered", =>
      @div outlet:'fa_div', class: "panel-heading", 'Service Config Dialog'
      @div class: "emp-div-content", =>
        @label class: "emp-conf-label", "Server State   :"
        @label outlet:"label_server_st", class: "emp-label-content", "------"
      @div class: "emp-div-content", =>
        @label class: "emp-conf-label", "Client Number:"
        @label outlet:"label_cl_no", class: "emp-label-content", ""

      @div class: 'emp-btn-div', =>
        @button class: 'btn inline-block emp-btn-cancel', click: 'process_cancel', "Cancel"
        @button class: 'btn inline-block emp-btn-ok', click: 'process_stop', "Stop"

  initialize: (serializeState, @emp_socket_server) ->
    console.log 'server state view initial'
    atom.workspaceView.command "emp-debugger:convert", => @convert()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  convert: ->
    console.log "this is state"

    if @emp_socket_server.get_server() isnt null
      if @hasParent()
        @detach()
      else
        atom.workspaceView.append(this)
        console.log "state view~"
        console.log @label_server_st
        console.log @label_cl_no

        @label_server_st["context"].innerHTML="On"
        # @label_server_st.setDocument("test")
        @label_cl_no["context"].innerHTML=@emp_socket_server.get_socket_length()


  process_cancel: (event, element) ->
    # console.log element
    console.log "Cancel State Preparing #{element.name} for launch!"
    @detach()

  process_stop: (event, element) ->
    console.log element
    @emp_socket_server.close()
    @detach()
