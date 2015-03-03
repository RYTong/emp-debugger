{$, $$, View} = require 'atom'
# EmpEditView = require '../item-editor-view'
# EmpSelView = require '../item-selector-view'
ChaItemView = require '../item_view/channel-item-view'
ColItemView = require '../item_view/collection-item-view'
emp = require '../../exports/emp'
os = require 'os'

# ItemView = require './adapter_item_view'

module.exports =
class ItemsPanel extends View
  item_list:[]
  unused_item:{}
  used_item:{}
  select_entry:{}    # 使用的item
  select_unentry:{}  #未使用的 item

  @content: ->
    @div class:'col_item_div', =>
      @div class:'label_div', =>
        @label class: 'info-ulabel', 'Items:'
        @label class: 'info-unlabel', '未使用 Items:'

      @div class: 'detail_div', =>
        @div class: 'item_use_div',  =>
          @ol outlet:"use_cha_list", class: 'list-tree', =>
            # @li class: 'list-item' , =>
            #   @div outlet: 'cha_item', id:"asd", class: ' list-item', =>
            #     @span outlet: 'chaName', class: 'text-success icon  icon-diff-modified', 'data-name':"*.json", "asdasd"

        @div class: 'item_btn_div', =>
          @div class: 'item_cbtn_div', =>
            @button class: 'item_btn btn btn-info inline-block-tight', click:'add_item', ' <- Add '

          @div class: 'item_cbtn_div', =>
            @button class: 'item_btn btn btn-info inline-block-tight', click:'add_all', ' <- Add All'
          @div class: 'item_cbtn_div', =>
            @button class: 'item_btn btn btn-info inline-block-tight', click:'remove_item', 'Remove-> '
          @div class: 'item_cbtn_div', =>
            @button class: 'item_btn btn btn-info inline-block-tight', click:'remove_all', ' Remove All ->'
          @div class: 'item_cbtn_div', =>
            @button class: 'item_btn btn btn-info inline-block-tight', click:'swap_items', '<- Swap ->'

        @div class: 'item_unuse_div',  =>
          @ol outlet:"unuse_cha_list", class: 'list-tree', =>
          # @li class: 'list-item' , =>
          #   @div outlet: 'cha_item', id:"asd", class: ' list-item', =>
          #     @span outlet: 'chaName', class: 'text-success icon  icon-diff-modified', 'data-name':"*.json", "asdasd"


  initialize: (all_objs, @col_obj)->
    # console.log all_objs
    @unused_item = {}
    @used_item = {}
    @select_entry ={}
    @select_unentry = {}
    @cha_objs = all_objs?.cha?.obj_list
    @col_objs = all_objs?.col

    if @col_obj.items.length > 0
      for obj in @col_obj.items
        tmp_type = obj.item_type
        tmp_id = obj.item_id
        tmp_item = null
        if tmp_type is emp.ITEM_CHA_TYPE
          # console.log "cha type"
          tmp_cha_obj = @cha_objs[tmp_id]
          tmp_item = new ChaItemView(tmp_cha_obj)
        else
          # console.log "col type"
          tmp_col_obj = @col_objs[tmp_id]
          tmp_item = new ColItemView(tmp_col_obj)
        tmp_item.set_used()
        @use_cha_list.append(tmp_item)
        @used_item[tmp_id] = tmp_item

    for key, obj of @cha_objs
      tmp_use_item = @used_item[key]
      if tmp_use_item
        if tmp_use_item.item_type isnt emp.ITEM_CHA_TYPE
          tmp_item = new ChaItemView(obj)
          # @cha_view_list[obj.id] = tmp_item
          @unuse_cha_list.append(tmp_item)
          @unused_item[obj.id] = tmp_item
      else
        tmp_item = new ChaItemView(obj)
        @unuse_cha_list.append(tmp_item)
        @unused_item[obj.id] = tmp_item

    # for n, obj of @cha_objs
    #   tmp_item = new ChaItemView(obj)
    #   tmp_item.set_used()
    #   # @cha_view_list[obj.id] = tmp_item
    #   @use_cha_list.append(tmp_item)
    #   @used_item[obj.id] = tmp_item
    # console.log "adapter view initial"
    # @disable_off_detail()
    # tmp_view = new EmpSelView([{name:'1', value:'1'},{name:'2', value:'2'},{name:'3', value:'3'}])
    # @testt.after(tmp_view)

    @on 'click', '.emp_cha_item_tag', (e, element) =>
      @itemClicked(e, element)
    # @cha_view_list = {}

  itemClicked:(e, element) ->
    # console.log "item click"
    entry = $(e.currentTarget).view()
    shift_key = e.shiftKey
    ctrl_key = e.ctrlKey

    os_platform = emp.get_emp_os()
    # console.log os_platform
    unless os_platform isnt emp.OS_DARWIN
      ctrl_key = e.metaKey

    # console.log entry
    # console.log entry.cha_id
    # console.log entry.use

    if ctrl_key
      if entry.isSelected
        entry.deselect()
        tmp_entry = @get_map(entry.use)
        delete tmp_entry[entry.cha_id]
      else
        entry.select()
        tmp_entry = @get_map(entry.use)
        tmp_entry[entry.cha_id] = entry
    else
      tmp_entrys = @get_map(entry.use)
      # console.log tmp_entrys
      for key, tmp_entry of tmp_entrys
        tmp_entry.deselect()
        delete tmp_entrys[key]
      entry.select()

      tmp_entrys[entry.cha_id] = entry

  get_map: (flag)->
    if flag
      @select_entry
    else
      @select_unentry

  add_item:->
    # console.log "add item"
    # console.log @select_unentry
    for key,old_item of @select_unentry
      tmp_obj = old_item.cha_obj
      # console.log tmp_obj
      tmp_item = new ChaItemView(tmp_obj)
      tmp_item.set_used()
      # @cha_view_list[obj.id] = tmp_item
      @use_cha_list.append(tmp_item)
      @used_item[tmp_obj.id] = tmp_item
      old_item.destroy()
      delete @select_unentry[key]
      delete @unused_item[key]

  add_all:->
    # console.log "add all"
    for key,old_item of @unused_item
      tmp_obj = old_item.cha_obj
      # console.log tmp_obj
      tmp_item = new ChaItemView(tmp_obj)
      tmp_item.set_used()
      # @cha_view_list[obj.id] = tmp_item
      @use_cha_list.append(tmp_item)
      @used_item[tmp_obj.id] = tmp_item
      old_item.destroy()
      delete @unused_item[key]
    @select_unentry = {}

  remove_item:->
    # console.log "remove item"
    for key,old_item of @select_entry
      tmp_obj = old_item.cha_obj
      tmp_item = new ChaItemView(tmp_obj)
      @unuse_cha_list.append(tmp_item)
      @unused_item[tmp_obj.id] = tmp_item
      old_item.destroy()
      delete @select_entry[key]
      delete @used_item[key]

  remove_all:->
    # console.log "remove all"
    for key,old_item of @used_item
      tmp_obj = old_item.cha_obj
      tmp_item = new ChaItemView(tmp_obj)
      @unuse_cha_list.append(tmp_item)
      @unused_item[tmp_obj.id] = tmp_item
      old_item.destroy()
      delete @used_item[key]
    @select_entry={}


  swap_items:->
    # console.log "swap items"
    tmp_umap = {}
    tmp_unmap = @unused_item
    for key,val of @unused_item
      tmp_unmap[key] = val
    @unused_item ={}
    @unuse_cha_list.empty()
    @use_cha_list.empty()

    for key,old_item of @used_item
      tmp_obj = old_item.cha_obj
      tmp_item = new ChaItemView(tmp_obj)
      @unuse_cha_list.append(tmp_item)
      @unused_item[tmp_obj.id] = tmp_item
      old_item.destroy()
    @used_item = {}
    for key,old_item of tmp_unmap
      tmp_obj = old_item.cha_obj
      tmp_item = new ChaItemView(tmp_obj)
      tmp_item.set_used()
      @use_cha_list.append(tmp_item)
      @used_item[tmp_obj.id] = tmp_item
      old_item.destroy()
    @select_entry={}
    @select_unentry = {}

  submit_detail: ->
    # console.log "submit detail"
    # console.log @used_item
    index = 1
    # tmp_list = []
    @col_obj.items = []
    for key,tmp_obj of @used_item
      @col_obj.add_item(key, index, tmp_obj)
      index += 1
