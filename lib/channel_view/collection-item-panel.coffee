{$, $$, View} = require 'atom'
# ItemEditorView = require './item-editor-view'
ColItemView = require './item_view/collection-item-view'
emp = require '../exports/emp'
conf_parser = require '../emp_app/conf_parser'
os = require 'os'

module.exports =
class SettingsPanel extends View
  select_entry:null
  edit_entry:null
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
              @button class: 'item_btn btn btn-info inline-block-tight', click:'edit_col','  Edit  '
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'del_col',' Delete '



  initialize: (@fa_view) ->
    @select_entry = {}
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

  refresh_add_col: (tmp_col_obj, all_objs) ->
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

  edit_col: (e, element)->
    # console.log 'edi_col'
    # console.log @select_entry
    last_id = null

    for key, tmp_entry of @select_entry
      last_id = key
      @edit_entry = tmp_entry
    if last_id
      tmp_obj = @fa_view.all_objs.col[last_id]
      @fa_view.show_panel(emp.ADD_COL_VIEW, tmp_obj)

  refresh_edit_col: (tmp_col_obj) ->
    # console.log "refresh --------"
    @edit_entry.refresh_edit(tmp_col_obj)

  del_col: (e, element)->
    # console.log 'del_col'
    tmp_col_str = " col_list  "
    # console.log @select_entry
    if @select_entry
      tmp_id_list = {}
      tmp_col_list = []
      for key, tmp_obj of @select_entry
        tmp_type = tmp_obj.col_type
        tmp_id_list[key] = tmp_type
        tmp_col_str = tmp_col_str+' '+key+' '+tmp_type
        tmp_col_list.push('{\"'+key+'\",'+tmp_type+'}')
        # console.log "#{tmp_col_str}, #{key}"
        tmp_obj.destroy()
      conf_parser.remove_col(tmp_col_str, tmp_col_list)
      @fa_view.after_del_col(tmp_id_list)
