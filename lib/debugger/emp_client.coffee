emp_view = require './emp_client_view'
emp_script = require './emp_client_script'

module.exports =
class emp_client
  id: null
  address: null
  socket: null
  state: false
  view_map: null
  view_len: 0

  script_map: {}
  script_len: 0

  constructor: (@id, @socket)->
    # console.log "init socket~:#{socket}"
    @view_map = new Array()
    @state = true
    @address = @socket.remoteAddress
    @script_map = {}

  close_socket: ->
    @socket.end('$close') unless @socket is null
    @socket = null
    @state = false

  remove_socket: ->
    @socket = null
    @state = false

  put_view: (view_con, index) ->
    @view_len += 1
    new_view = new emp_view(view_con, index, @view_len, @id, @address)
    @view_map.push(new_view)
    new_view

  get_view_map: ()->
    @view_map

  get_view: (index)->
    @view_map[index-1]

  get_view_socket: ->
    @socket

  set_view_readed: (index)->
    @view_map[index-1].readed = true

  get_readed: (index)->
    @view_map[index-1].readed



  put_script: (script_name, script_con, view_obj) ->
    tmp_obj = @script_map[script_name]
    if !view_obj
      view_obj = @view_map[@view_map.length-1]
    if tmp_obj
      tmp_obj.set_con(script_con, view_obj)
    else
      @script_len += 1
      tmp_obj = new emp_script(script_name, script_con, @script_len, @id, @address, view_obj)
      @script_map[script_name] = tmp_obj
    view_obj.set_script(tmp_obj)
    tmp_obj

  get_script_map: ->
    @script_map

  get_script: (script_name)->
    @script_map[script_name]

  get_script_socket: ->
    @socket

  set_script_readed: (script_name)->
    @script_map[script_name].readed = true

  get_script_readed: (script_name)->
    @script_map[script_name].readed
