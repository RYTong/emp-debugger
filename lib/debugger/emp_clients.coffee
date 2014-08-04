emp_client = require './emp_client'
module.exports =
class emp_clients
  active_len: 0
  obj_len: 0
  clients_map:{}
  views_map: null
  index: 0

  constructor: ->
    # console.log "emp_clients constructor"
    @views_map = new Array()

  new_client: (id, obj) ->
    @clients_map[id] = new emp_client(id, obj)
    @obj_len += 1
    @active_len += 1

  remove_client: (id)->
    @active_len -= 1 unless @clients_map[id].state is false
    @clients_map[id] = null
    delete @clients_map[id]
    @obj_len -= 1

  remove_all_client: ->
    @clients_map = {}
    @active_len = 0
    @obj_len = 0


  remove_client_socket: (id) ->
    @clients_map[id].remove_socket()
    @active_len -= 1

  remove_all_client_socket: (id) ->
    v.remove_socket() for k,v of @clients_map

    @active_len = 0

  get_client: (id) ->
    @clients_map[id]

  get_client_socket: (id) ->
    @clients_map[id].get_view_socket()

  get_all_socket: ->
    result = new Array()
    for k,v of @clients_map
      result.push(v.socket) unless v.state is false
    result

  close_all_socket: ->
    v.close_socket() for k,v of @clients_map
    @active_len = 0

  put_spec_view: (id, view) ->
    console.log "New view item income~"
    @index += 1
    view_obj = @clients_map[id].put_view(view, @index)
    @views_map.push(view_obj)


  get_all_spec_view: ->
    tmp_arr = new Array()
    console.log @clients_map
    console.log tmp_arr
    for k,v of @clients_map
      console.log k,v
      tmp = {}
      tmp[k]=v.get_view_map()
      tmp_arr.push(tmp)
    console.log tmp_arr
    tmp_arr

  get_all_views: ->
    @views_map

  get_client_view: (id) ->
    ""

  get_active_len: ->
    @active_len
