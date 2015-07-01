emp = require '../../exports/emp'
path = require 'path'
fs = require 'fs'
fs_plus = require 'fs-plus'
conf_parser = require '../../emp_app/conf_parser'

module.exports =
class emp_collection
  id:null
  name:null
  app:null

  url:'undefined'
  uid:'undefined'
  type:emp.COL_CH_TYPE

  state:1
  item_param:[]
  items:[]
  use_front:true


  constructor: ->
    # console.log "this is a channel"
    # @item = {}

  set_url:(val) ->
    # console.log val
    # console.log typeof(val)
    if val
      # console.log "??????"
      @url = val.trim()
    else
      @url = 'undefined'

  set_uid:(val) ->
    # console.log typeof(val)
    if val
      @uid = val.trim()
    else
      @uid = 'undefined'

  set_state:(tmp_state) ->
    if tmp_state
      @state = 1
    else
      @state = 0

  add_item: (key, index, tmp_obj) ->
    tmp_temp = emp.DEFAULT_COL_ITEM
    item_type = tmp_obj.item_type
    tmp_item = tmp_temp.replace(/\$cha_id/ig, key)
    tmp_item = tmp_item.replace(/\$itype/ig,item_type)
    tmp_item = tmp_item.replace(/\$order/ig, index)
    @item_param.push(tmp_item)
    @items.push({item_id:key, item_type:item_type,menu_order:index})

  format_items: ->
    "["+@item_param.join(",")+ "]"


  create_collection: (col_objs)->
    if atom.project.emp_app_state
      @sync_create_collection()

    else if atom.project.emp_node_state
      @sync_create_collection('node')

    else
      @do_create_collection(col_objs)

    # @create_front_col()

  do_create_collection: (col_objs)->
    tmp_col = path.join __dirname, '../../../', emp.STATIC_TEMPLATE_DIR,'/collection.txt'
    f_con = fs.readFileSync(tmp_col, 'utf8')
    f_con = f_con.replace('${collection}', @id).replace('${name}', @name)
    f_con = f_con.replace('${app}', @app).replace('${type}', @type)
    f_con = f_con.replace('${url}', @url).replace('${uid}', @uid)
    f_con = f_con.replace('${state}', @state).replace('${items}', @format_items())
    # console.log f_con

    col_con = fs.readFileSync(atom.project.channel_conf, 'utf8')
    col_con = col_con.replace(/\{\W*collections\W*,[^\[]*\[/ig, f_con)

    if !emp.isEmpty(col_objs)
      col_con = col_con +',\n'
    # console.log col_con
    fs.writeFileSync(atom.project.channel_conf, col_con, 'utf8')

  sync_create_collection: (type)->
    tmp_conf = atom.project.channel_conf
    item_str = []
    for tmp_obj in @items
      item_str.push("[{item_id, \"#{tmp_obj.item_id}\"},{item_type, #{tmp_obj.item_type}}, {menu_order, #{tmp_obj.menu_order}}]")
    if item_str.length is 0
      item_str = "[]"
    else
      item_str = "[" + item_str.join(",") + "]"

    if type
      tmp_pid = atom.project.emp_node_pid
      tmp_node_name = atom.project.emp_node_name
      erl_str = "#{emp.parser_beam_file_mod}:node_fun_call(\'#{tmp_node_name}\', add_col, [\"#{tmp_conf}\",
                  \"#{@id}\", \"#{@name}\", \"#{@app}\", #{@type} , \"#{@url}\",
              \"#{@uid}\", #{@state}, #{item_str}]). "
      # console.log erl_str
      tmp_pid.stdin.write(erl_str+'\n')
    else
      tmp_pid = atom.project.emp_app_pid
      erl_str = "#{emp.parser_beam_file_mod}:add_col(\"#{tmp_conf}\",
                  \"#{@id}\", \"#{@name}\", \"#{@app}\", #{@type} , \"#{@url}\",
              \"#{@uid}\", #{@state}, #{item_str}). "
      # if erl_str = atom.config.get(emp.EMP_IMPORT_MENU_KEY)
      tmp_pid.stdin.write(erl_str+'\n')


  edit_collection: ()->
    if atom.project.emp_app_state
      @do_edit_collection_rt()
    else if atom.project.emp_node_state
      @do_edit_collection_rt('node')
    else
      @do_edit_collection()
    # @create_front_col()

  do_edit_collection: ()->
    # console.log col_objs
    # console.log "do edit"
    p_str = " -id #{@id} -app #{@app} -name #{@name} -type #{@type} "
    p_str = p_str + " -url #{@url} -uid #{@uid} -state #{@state}"
    # console.log p_str
    item_str = ""
    for tmp_obj in @items
      item_str = item_str + "|#{tmp_obj.item_id}|#{tmp_obj.item_type}|#{tmp_obj.menu_order}"

    p_str = p_str + " -items \"#{item_str}\" "
    # console.log p_str
    conf_parser.edit_col(p_str)

  do_edit_collection_rt: (type) ->
    # console.log " do "
    tmp_conf = atom.project.channel_conf
    item_str = []
    for tmp_obj in @items
      item_str.push("[{item_id, \"#{tmp_obj.item_id}\"},{item_type, #{tmp_obj.item_type}}, {menu_order, #{tmp_obj.menu_order}}]")
    if item_str.length is 0
      item_str = "[]"
    else
      item_str = "[" + item_str.join(",") + "]"

    if type
      tmp_pid = atom.project.emp_node_pid
      tmp_node_name = atom.project.emp_node_name
      erl_str = "#{emp.parser_beam_file_mod}:node_fun_call(\'#{tmp_node_name}\', edit_col, [\"#{tmp_conf}\",
                  \"#{@id}\", \"#{@name}\", \"#{@app}\", #{@type} , \"#{@url}\",
              \"#{@uid}\", #{@state}, #{item_str}]). "

      # console.log erl_str
      tmp_pid.stdin.write(erl_str+'\n')
    else
      erl_str = "#{emp.parser_beam_file_mod}:edit_col(\"#{tmp_conf}\",
                  \"#{@id}\", \"#{@name}\", \"#{@app}\", #{@type} , \"#{@url}\",
              \"#{@uid}\", #{@state}, #{item_str}). "
      # console.log erl_str
      tmp_pid = atom.project.emp_app_pid
      tmp_pid.stdin.write(erl_str+'\n')


  create_front_col:()->
    if @use_front
      project_path = atom.project.getPaths()[0]
      pub_dir = path.join project_path,emp.CHA_PUBLIC_DIR
      menu_dir = path.join pub_dir, "/menu"
      col_dir = path.join menu_dir, "#{@id}"

      emp.mkdir_sync(pub_dir)
      emp.mkdir_sync(menu_dir)

      if !fs.existsSync col_dir
        fs.mkdirSync col_dir

      @create_front_item(menu_dir, col_dir)


  # @doc 初始化前端路径
  initial_menu_dir:(project_path) ->

    pub_dir = path.join project_path,emp.CHA_PUBLIC_DIR
    menu_dir = path.join pub_dir, "/menu"
    col_dir = path.join menu_dir, "#{@id}"

    emp.mkdir_sync(pub_dir)
    emp.mkdir_sync(menu_dir)

    if !fs.existsSync col_dir
      fs.mkdirSync col_dir
    col_dir

  create_front_item:(menu_dir, col_dir) ->
    # console.log @items

# {item_id:key, item_type:item_type,menu_order:index}
    for tmp_item in @items
      # console.log  tmp_item
      tmp_id = tmp_item.item_id
      tmp_type = tmp_item.item_type

      if tmp_type is emp.ITEM_CHA_TYPE
        tmp_cha_dir = path.join menu_dir, emp.CHA_FRONT_VITUAL_COL, "$#{tmp_id}"
        tmp_dest_dir = path.join col_dir, "$#{tmp_id}"
        emp.mkdir_sync tmp_dest_dir

        if fs.existsSync tmp_cha_dir
          fs_plus.copySync  tmp_cha_dir, tmp_dest_dir

      else
        tmp_col_dir = path.join menu_dir, "#{tmp_id}"

        tmp_dest_dir = path.join col_dir, "#{tmp_id}"
        emp.mkdir_sync tmp_dest_dir

        if fs.existsSync tmp_col_dir
          fs_plus.copySync  tmp_col_dir, tmp_dest_dir
        else
          tmp_col_dir = path.join col_dir, "#{tmp_id}"
          emp.mkdir_sync tmp_col_dir
