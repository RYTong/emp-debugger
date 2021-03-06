emp_client = require './emp_client'
glo_obj_name = "name"
glo_obj_con = "content"

module.exports =
class emp_clients
  active_len: 0
  obj_len: 0
  clients_map:{}
  views_map: null
  script_map: {}
  index: 0
  script_index: 0
  log_storage: null

  constructor: (@log_storage)->
    # console.log "emp_clients constructor"
    @index = 0
    @views_map = new Array()
    @script_map = {}
    # @log_storage.set_clients_map(this)
    # @css_map = {}

  new_client: (id, obj) ->
    new_client = new emp_client(id, obj)
    @clients_map[id] = new_client
    @obj_len += 1
    @active_len += 1

    new_client

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
    @clients_map[id] = null
    delete @clients_map[id]
    @obj_len -= 1
    @active_len -= 1 unless @active_len <=0
    # @log_storage.remove_client_log(id)


  remove_all_client_socket: (id) ->
    v.remove_socket() for k,v of @clients_map
    @active_len = 0

  get_client: (id) ->
    @clients_map[id]

  get_client_socket: (id) ->
    @clients_map[id]?.get_view_socket()

  get_all_id: ->
    id_lists = new Array()
    for id, client of @clients_map
      id_lists.push id
    id_lists


  get_all_socket: ->
    # result = new Array()
    result = {new_p:[], old_p:[]}
    for k,v of @clients_map
      if v.state isnt false
        if v.new_type_protocal
          result.new_p.push(v.socket)
        else
          result.old_p.push(v.socket)
    result

  get_new_socket: ->
    result = new Array()
    for k,v of @clients_map
      if v.state isnt false
        unless !v.new_type_protocal
          result.push(v.socket)
    result

  close_all_socket: ->
    v.close_socket() for k,v of @clients_map
    @active_len = 0

  store_view: (client_id, message) ->
    argsContent = message.split "#EditorContent#"
    view = argsContent[1]
    # @put_spec_view(client_id, content) unless content is undefined
    view_obj = null
    unless view is undefined
      @index += 1
      view_obj = @clients_map[client_id].put_view(view, @index)
      # console.log view_obj
      @views_map.push(view_obj)

    script_arr = message.split "#EditorScript#"
    script_len =  parseInt(script_arr.length / 3)
    unless script_len is 0
      for i in [0..script_len]
        tmp_script = script_arr[1+3*i]
        if tmp_script isnt undefined
          script_arg = tmp_script.split("#fileName#")
          script_name = script_arg[0]
          script_con = script_arg[1]
          # console.log script_name
          map_index = "#{client_id}:#{script_name}"
          # console.log "inde:#{map_index}"
          # console.log @clients_map
          script_obj = @clients_map[client_id].put_script(script_name, script_con, view_obj)
          if !@script_map[map_index]
            @script_map[map_index] = script_obj

  # 保存新协议的内容
  store_new_view: (client_id, data_obj) ->
    # argsContent = message.split "#EditorContent#"
    # console.log "+++++++++++++++++++++++ obj +++++++++++++++++++++++"
    # console.log  data_obj
    @index += 1
    view_obj = @clients_map[client_id].store_new_view(data_obj, @index)
    @views_map.push(view_obj)

  put_spec_view: (id, view) ->
    console.log "New view item income~"
    @index += 1
    view_obj = @clients_map[id].put_view(view, @index)
    @views_map.push(view_obj)

  get_all_spec_view: ->
    tmp_arr = new Array()
    for k,v of @clients_map
      tmp = {}
      tmp[k]=v.get_view_map()
      tmp_arr.push(tmp)
    tmp_arr

  get_all_views: ->
    @views_map

  clear_all_views: ->
    @index = 0
    @views_map = new Array()
    @script_map = {}
    for tmp_id, tmp_obj of @clients_map
      tmp_obj.clear_all_views()

  get_lastest_view: ->
    @views_map[@views_map.length-1]

  get_all_script: ->
    @script_map

  get_active_len: ->
    @active_len
