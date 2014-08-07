{$, $$, View} = require 'atom'

module.exports =
class ServerStateView extends View
  emp_socket_server: null
  emp_log_view: null

  @content: ->
    # console.log 'constructor'
    @div class: "emp-debugger overlay bordered", =>
      @div outlet:'fa_div', class: "panel-heading", 'Service Config Dialog'
      @div class: "emp-div-content", =>
        @label class: "emp-conf-label", "Server State   :"
        @label outlet:"label_server_st", class: "emp-label-content", "--"
      @div class: "emp-div-content", =>
        @label class: "emp-conf-label", "Client Number:"
        @label outlet:"label_cl_no", class: "emp-label-content", ""
      @div class: "emp-div-content", =>
        @label class: "emp-conf-label", "Client Number:"
        # @button class: 'btn-warning inline-block-tight', click: 'process_cancel', "清除日志"
        @div class: 'btn-group', =>
          @button class: 'btn-warning inline-block-tight', click:'process_log_hide', '隐藏日志'
          @button class: 'btn-warning inline-block-tight', click:'process_log_clear', '清除当前日志'
          @button class: 'btn-warning inline-block-tight', click:'process_log_close', '关闭日志(清除)'

      @div class: 'emp-btn-div', =>
        @button class: 'btn inline-block emp-btn-cancel', click: 'process_cancel', "Cancel"
        @button class: 'btn inline-block selected emp-btn-ok', click: 'process_stop', "Stop"

  initialize: (serializeState, @emp_socket_server, @emp_log_view) ->
    # console.log 'server state view initial'
    atom.workspaceView.command "emp-debugger:debug-server", => @close()
    atom.workspaceView.command "emp-debugger:close-server", => @close_server()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  close: ->
    # if @emp_socket_server.get_server() isnt null
    if @emp_socket_server.get_server_sate()
      if @hasParent()
        @detach()
      else
        atom.workspaceView.append(this)
        # console.log "state view~"
        @label_server_st["context"].innerHTML="On"
        @label_cl_no["context"].innerHTML=@emp_socket_server.get_client_map().get_active_len()

  # this function is the same as @close function~
  close_server: ->
    if @emp_socket_server.get_server()
      if @hasParent()
        @detach()
      else
        atom.workspaceView.append(this)
        # console.log "state view~"
        @label_server_st["context"].innerHTML="On"
        @label_cl_no["context"].innerHTML=@emp_socket_server.get_client_map().get_active_len()
    else
        atom.confirm
          message:"Error"
          detailedMessage:"There's no socket server~"

  process_cancel: (event, element) ->
    # console.log "Cancel State Preparing #{element.name} for launch!"
    @detach()

  process_stop: (event, element) ->
    # console.log element
    @emp_socket_server.close()
    @detach()

  process_log_hide: (event, element) ->
    @emp_log_view.hide_view()
    @detach()

  process_log_clear: (event, element) ->
    @emp_log_view.clear_log()
    @detach()

  process_log_close: (event, element) ->
    @emp_log_view.close_view()
    @detach()
