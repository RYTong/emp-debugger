{$, $$, View} = require 'atom'
_ = require 'underscore-plus'
ItemEditorView = require './item-editor-view'
ColItemView = require './item_view/collection-item-view'
emp = require '../exports/emp'
conf_parser = require '../emp_app/conf_parser'
os = require 'os'

module.exports =
class SettingsPanel extends View
  select_entry:null
  @content: ->
    @div class: 'col-list-panel', =>
      # @section class: 'config-section', =>
      @div class: 'block section-heading icon icon-gear', "Collections Management"
      @div class: 'div-body', =>
        @div class:'div-con ', =>
          @div class:'emp_item_list_div', =>
            @ol outlet:"gen_col_list", class: 'list-tree', =>
          @div class:'emp_item_btn_div', =>
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'add_col', ' Add... '
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'edi_col','  Edit  '
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'del_col',' Delete '



  initialize: (@fa_view) ->
    @select_entry = []
    @on 'click', '.emp_col_item_tag', (e, element) =>
      @itemClicked(e, element)

  refresh_col_list:(new_all_obj) ->
    # console.log new_all_obj
    root_col = new_all_obj.root
    child_col = new_all_obj.child.obj_list

    for n, obj of root_col
      tmp_item = new ColItemView(obj)
      @gen_col_list.append(tmp_item)

    for n, obj of child_col
      tmp_item = new ColItemView(obj)
      @gen_col_list.append(tmp_item)

  refresh_col_panel: (tmp_col_obj, all_objs) ->
    if tmp_col_obj.type is emp.COL_CH_TYPE
      all_objs.child.put(tmp_col_obj)
    else
      all_objs.root[tmp_col_obj.id] = tmp_col_obj
    # console.log tmp_col_obj
    tmp_item = new ColItemView(tmp_col_obj)
    @gen_col_list.append(tmp_item)


  itemClicked:(e, element) ->
    # console.log "item click"
    entry = $(e.currentTarget).view()
    shift_key = e.shiftKey
    ctrl_key = e.ctrlKey
    # console.log entry

    os_platform = os.platform().toLowerCase()
    # console.log os_platform
    unless os_platform isnt emp.OS_DARWIN
      ctrl_key = e.metaKey
    if ctrl_key
      if entry.isSelected
        entry.deselect()
        delete @select_entry[entry.col_id]
      else
        entry.select()
        @select_entry[entry.col_id] = entry
    else
      for key, tmp_entry of @select_entry
        tmp_entry.deselect()
        delete @select_entry[key]
      entry.select()
      @select_entry[entry.col_id] = entry



  add_col: (e, element)->
    # console.log 'add_cha'
    @fa_view.show_panel(emp.ADD_COL_VIEW)
    # console.log 'add_col'

  edi_col: (e, element)->
    console.log 'edi_col'

  del_col: (e, element)->
    # console.log 'del_col'
    tmp_col_str = " col_list  "
    # console.log @select_entry
    if @select_entry
      tmp_id_list = []
      for key, tmp_obj of @select_entry
        tmp_id_list.push(key)
        tmp_col_str = tmp_col_str+' '+key
        # console.log "#{tmp_cha_str}, #{key}"
        tmp_obj.destroy()
      conf_parser.remove_col(tmp_col_str)
      @fa_view.after_del_col(tmp_id_list)
