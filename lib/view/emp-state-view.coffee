{$, $$, View} = require 'atom'

module.exports =
class ServerStateView extends View
  emp_socket_server: null

  @content: ->
    # console.log 'constructor'
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
    # console.log 'server state view initial'
    atom.workspaceView.command "emp-debugger:debug-server", => @close()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  close: ->
    if @emp_socket_server.get_server() isnt null
      if @hasParent()
        @detach()
      else
        atom.workspaceView.append(this)
        # console.log "state view~"
        @label_server_st["context"].innerHTML="On"
        @label_cl_no["context"].innerHTML=@emp_socket_server.get_client_map().get_active_len()

  process_cancel: (event, element) ->
    # console.log "Cancel State Preparing #{element.name} for launch!"
    @detach()

  process_stop: (event, element) ->
    # console.log element
    @emp_socket_server.close()
    @detach()
