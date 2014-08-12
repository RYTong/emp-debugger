{$, $$, View} = require 'atom'
event = (require 'events').EventEmitter
EmpEditView = require './emp-edit-view'

module.exports =
class EmpDebuggerView extends View
  emp_server_host: 'localhost'
  emp_server_port: 7003
  emp_socket_server: null

  @content: ->
    # console.log "constructor"
    @div class: "emp-debugger overlay bordered", =>
      @div outlet:'fa_div', class: "panel-heading", 'Service Config Dialog'
      @div class: "panel-body padded", =>
        @label class: "emp-conf-label", "Host "
        @label class: "emp-label-conment", "如果使用的是模拟器，建议使用localhost，如果使用真机等，请使用ip"
        @div class: 'controls', =>
          @div class: 'editor-container', =>
            @subview "emp_sub_host", new EmpEditView(attributes: {id: 'emp_host', type: 'string'},  placeholderText: 'Editor Server 监听的地址') #from editor view class
        @label class: "emp-conf-label", "Port "
        @div class: 'controls', =>
          @div class: 'editor-container', =>
            @subview "emp_sub_port".replace(/\./g, ''), new EmpEditView(attributes: {id: 'emp_port', type: 'number'}, placeholderText: '同Client交互的端口')
      @div class: 'emp-btn-div', =>
        @button class: 'btn inline-block emp-btn-cancel', click: 'process_cancel', "Cancel"
        @button class: 'btn inline-block emp-btn-ok', click: 'process_start', "Ok"


  initialize: (serializeState, @emp_socket_server) ->
    # console.log "server init view initial"

    atom.workspaceView.command "emp-debugger:debug-server", => @init()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  init: ->
    # console.log "EmpDebuggerView was toggled!"
    # if @emp_socket_server.get_server() is null
    if !@emp_socket_server.get_server_sate()
      if @hasParent()
        @detach()
      else
        atom.workspaceView.append(this) # unless @emp_socket_server.server isnt null
        @emp_sub_host.focus()
        @emp_sub_host.on 'enter', =>
          console.log 'enter input~'
        @on 'enter', =>
          console.log 'enter input~2'

  process_cancel: (event, element) ->
    # console.log element
    # console.log "Cancel Preparing #{element.name} for launch!"
    @detach()

  process_start: (event, element) ->
    # console.log element
    # console.log "port:#{@emp_server_port}"
    # console.log "host:#{@emp_server_host}"
    new_server_host = @emp_sub_host.getText().trim()
    new_server_port = @emp_sub_port.getText().trim()
    # console.log new_server_host
    # console.log new_server_port
    @emp_server_host = new_server_host unless new_server_host is ''
    @emp_server_port = new_server_port unless new_server_port is ''

    # for editorView in @find('.editor[id]').views()
    #   do (editorView) =>
    #     name = editorView.attr('id')
    #     type = editorView.attr('type')
    #     console.log name
    #     show_val = editorView.getText().trim()
    #     emp_server_host = show_val unless name is 'emp_host'
    #     emp_server_port = show_val unless name is 'emp_port'
        # show_val = @parseValue(show_val) unless name is 'emp_ip'
        #
        # console.log show_val
        # console.log show_val.length
    # console.log @emp_server_port
    @emp_server_port = @parseValue('number', @emp_server_port)
    console.log "local server start with option parameters: host: #{@emp_server_host}, port: #{@emp_server_port}"
    @emp_socket_server.init(@emp_server_host, @emp_server_port) unless @emp_socket_server.get_server() isnt null
    @detach()

  # start_listen: (f_view)->
  #   console.log "start listen"
  #   @find('ol').append('<li>Star Destroyer</li>')
  #   @on 'click', 'li', ->
  #     console.log $(this).text()
  #     try
  #       alert "They clicked on #{$(this).text()}"
  #     catch
  #       console.log "error happen"


    # button_listener = () ->
    #   console.log $(this).text()
    #   if $(this).text() is 'Cancel'
    #     console.log "cancel~"
    #     f_view.detach()
    #   else
    #     console.log this
    #     console.log 'ok'

    # this.on 'click', 'button', @button_listener('click', 'button', f_view)
    # this.removeListener 'click', 'button', @button_listener('click', 'button', f_view)


  warn_dialog:(msg) ->
    console.log "this a waring dialog"
    @div class: 'overlay from-top select-list', =>
      @div class: 'editor editor-colors mini', "I searched for this: #{msg}"
      @div class: 'error-message', 'Nothing has been found!'

  valueToString: (value) ->
    if _.isArray(value)
      value.join(", ")
    else
      value?.toString()

  parseValue: (type, value) ->
    if value == ''
      value = undefined
    else if type == 'number'
      floatValue = parseFloat(value)
      value = floatValue unless isNaN(floatValue)
    else if type == 'array'
      arrayValue = (value or '').split(',')
      value = (val.trim() for val in arrayValue when val)
    value
