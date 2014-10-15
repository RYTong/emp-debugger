emp = require '../../exports/emp'
path = require 'path'
fs = require 'fs'
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
    tmp_col = path.join __dirname, '../../../', emp.STATIC_COLLECTION_TEMPLATE,'/collection.txt'
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

  edit_collection: ()->
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
