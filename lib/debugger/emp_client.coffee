emp_view = require './emp_client_view'
emp_script = require './emp_client_script'
emp = require '../exports/emp'
glo_obj_name = "name"
glo_obj_con = "content"

module.exports =
class emp_client
  id: null
  address: null
  socket: null
  state: false
  view_map: null
  view_len: 0

  script_map: {}
  css_map:{}
  script_len: 0
  css_len: 0
  new_type_protocal:false

  constructor: (@id, @socket)->
    # console.log "init socket~:#{socket}"
    @view_map = new Array()
    @state = true
    @address = @socket.remoteAddress
    @script_map = {}
    @css_map = {}
    @script_len = 0
    @css_len = 0
    @entrance_flag = 0
    @entranc_obj = {}

  close_socket: ->
    @socket.end('$close') unless @socket is null
    @socket = null
    @state = false

  remove_socket: ->
    @socket = null
    @state = false

  store_new_view: (data_obj, @index_flag) ->
    tmp_obj = {}
    # console.log data_obj
    origin_data = data_obj["originMessage"]
    view = origin_data?["staticContent"]
    unless !view
      view_str = emp.base64_decode(view)
      tmp_obj["view"] = view_str

    tmp_script_obj = {}
    script_arr = origin_data?["script"]
    unless !script_arr
      unless script_arr.length is 0
        for script_obj in script_arr
          script_name = script_obj[glo_obj_name]
          script_con = script_obj[glo_obj_con]
          script_con_str = emp.base64_decode(script_con)
          tmp_script_obj[script_name] = script_con_str
    tmp_obj["script"] = tmp_script_obj

    tmp_css_obj = {}
    css_arr = origin_data?["css"]
    unless !css_arr
      unless css_arr.length is 0
        for css_obj in css_arr
          css_name = css_obj[glo_obj_name]
          css_con = css_obj[glo_obj_con]
          css_con_str = emp.base64_decode(css_con)
          tmp_css_obj[css_name] = css_con_str
    tmp_obj["css"] = tmp_css_obj
    # console.log tmp_obj
    # tmp_obj = {"view": "", script:{"name.lua":"lua_con"}, "css":{"name.css":"css_con"} }
    @entrance_flag += 1
    @entranc_obj[@entrance_flag] = tmp_obj
    @put_new_view(tmp_obj)

  put_view: (view_con, index) ->
    @view_len += 1
    new_view = new emp_view(view_con, index, @view_len, @id, @address)
    @view_map.push(new_view)
    new_view

  # use for new protocal
  put_new_view: (view_con_obj) ->
    @view_len += 1
    new_view = new emp_view(view_con_obj["view"], @index_flag, @view_len, @id, @address)
    new_view.set_relate_obj(view_con_obj)
    @view_map.push(new_view)
    new_view

  get_view_map: ()->
    @view_map

  clear_all_views: () ->
    @view_map = new Array()
    @script_map = {}
    @css_map = {}
    @script_len = 0
    @css_len = 0
    @entrance_flag = 0
    @entranc_obj = {}


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
      view_obj   @view_map[@view_map.length-1]
    if tmp_obj
      tmp_obj.set_con(script_con, view_obj)
    else
      @script_len += 1
      tmp_obj = new emp_script(script_name, script_con, @script_len, @id, @address, view_obj)
      @script_map[script_name] = tmp_obj
    # console.log "put_script-----------"
    view_obj.set_script(tmp_obj)
    # console.log "put_script over-----------"
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

  set_protocal_type:(@new_type_protocal) ->
