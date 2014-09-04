{$, View} = require 'atom'
ChannelView = require './channel-view'

COL_KEY = "collections"
CHA_KEY = "channels"
COL_ROOT_TYPE = 1
COL_CH_TYPE = 0
ITEM_CHA_TYPE = 1
ITEM_COL_TYPE = 0

module.exports =
class CollectionView extends View
  @content: ->
    @li class: 'list-nested-item', =>
      @div outlet: 'header', class: 'header list-item', =>
        @span class: 'text-info icon icon-file-directory', 'data-name':"*.json", outlet: 'colName'

      @ol class: 'entries list-tree', outlet: 'entries'

  initialize: (obj, new_all_obj)->
    console.log "---------collection view~-----------"
    console.log obj

    name = obj.name
    name ?= obj.id
    @colName.text(name)
    # rest_struct = null
    unless !obj.items
      console.log obj.items.length
      col_type = obj.type
      all_col = new_all_obj.child
      all_cha = new_all_obj.cha

      for c_obj in obj.items
        console.log c_obj
        tmp_obj_type = c_obj.item_type

        if tmp_obj_type is ITEM_COL_TYPE and col_type is COL_ROOT_TYPE
          console.log "col item"

          tmp_col_obj = all_col[c_obj.item_id]

          if tmp_col_obj
            new_item_view = new CollectionView(tmp_col_obj, new_all_obj)
            @entries.append(new_item_view)
          # else
          #   @err_col_item_view(c_obj.item_id)
        else
          console.log "cha item"

          tmp_cha_obj = all_cha[c_obj.item_id]
          new_item_view = new ChannelView(tmp_cha_obj, new_all_obj)
          @entries.append(new_item_view)
          # tmp_cha_obj = channel_obj[c_obj.item_id]
          # if tmp_cha_obj
          #   @channel_item_view(tmp_cha_obj)
          # else
          #   @err_channel_item_view(tmp_cha_obj.item_id)
