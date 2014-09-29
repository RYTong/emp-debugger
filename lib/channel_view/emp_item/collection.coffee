emp = require '../../exports/emp'
path = require 'path'
fs = require 'fs'

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
    @item = {}

  set_url:(val) ->
    if val
      @url = val
    else
      @url = 'undefined'

  set_uid:(val) ->
    if val
      @uid = val
    else
      @uid = 'undefined'

  set_state:(tmp_state) ->
    if tmp_state
      @state = 1
    else
      @state = 0

  add_item: (key, index) ->
    tmp_temp = emp.DEFAULT_COL_ITEM
    item_type = emp.ITEM_CHA_TYPE
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
