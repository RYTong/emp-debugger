emp_view = require './emp_client_view'

module.exports =
class emp_client
  id: null
  address: null
  socket: null
  state: false
  view_map: null
  view_len: 0

  constructor: (@id, @socket)->
    # console.log "init socket~:#{socket}"
    @view_map = new Array()
    @state = true
    @address = @socket.remoteAddress


  put_view: (view_con, index) ->
    @view_len += 1
    new_view = new emp_view(view_con, index, @view_len, @id, @address)
    @view_map.push(new_view)

    new_view

  close_socket: ->
    @socket.end('$close') unless @socket is null
    @socket = null
    @state = false

  remove_socket: ->
    @socket = null
    @state = false

  get_view_map: ()->
    @view_map

  get_view: (index)->
    @view_map[index-1]

  get_view_socket: ->
    @socket

  set_readed: (index)->
    @view_map[index-1].readed = true

  get_readed: (index)->
    @view_map[index-1].readed
