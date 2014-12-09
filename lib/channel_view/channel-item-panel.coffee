{$, $$, View} = require 'atom'
os = require 'os'
ChaItemView = require './item_view/channel-item-view'
PackageBarView = require '../package/emp-debugger-package-bar-view'
PackageAdpView = require '../package/emp-debugger-pkg-adp-view'
emp =  require '../exports/emp'
conf_parser = require '../emp_app/conf_parser'

module.exports =
class ChannelItemPanel extends View
  select_entry:{}
  new_all_obj:null
  edit_entry:null

  @content: ->
    @div class: 'cha-list-panel', =>
      # @section class: 'config-section', =>
      @div class: 'block section-heading icon icon-gear', "Channel Management"
      @div class: 'div-body', =>
        @div class:'div-con ', =>
          @div class:'emp_item_list_div', =>
            @ol outlet:"gen_cha_list", class: 'list-tree', =>
          @div class:'emp_item_btn_div', =>
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'add_cha',' Add... '
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'edi_cha','  Edit  '
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'del_cha',' Delete '
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'dl_cha',' Plugin '
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'dl_adapter',' Package'

  initialize: (@fa_view) ->
    @on 'click', '.emp_cha_item_tag', (e, element) =>
      @itemClicked(e, element)
    @emp_package_common_view = new PackageBarView()
    @emp_package_adapter_view = new PackageAdpView()
    @select_entry = {}

  refresh_cha_list:(@new_all_obj) ->
    # console.log new_all_obj
    cha_obj = @new_all_obj.cha.obj_list
    for n, obj of cha_obj
      tmp_item = new ChaItemView(obj)
      # @cha_view_list[obj.id] = tmp_item
      @gen_cha_list.append(tmp_item)


  itemClicked:(e, element) ->
    # console.log "item click"
    entry = $(e.currentTarget).view()
    shift_key = e.shiftKey
    ctrl_key = e.ctrlKey

    os_platform = emp.get_emp_os()
    # console.log os_platform
    unless os_platform isnt emp.OS_DARWIN
      ctrl_key = e.metaKey
    # console.log @select_entry
    if ctrl_key
      if entry.isSelected
        entry.deselect()
        delete @select_entry[entry.cha_id]
      else
        entry.select()
        @select_entry[entry.cha_id] = entry
    else
      for key, tmp_entry of @select_entry
        tmp_entry.deselect()
        delete @select_entry[key]
      entry.select()
      @select_entry[entry.cha_id] = entry

  add_cha: (e, element)->
    # console.log 'add_cha'
    @fa_view.show_panel(emp.ADD_CHA_VIEW)

  edi_cha: (e, element)->
    # console.log 'edi_cha'
    last_id = null
    for key, tmp_entry of @select_entry
      last_id = key
      @edit_entry = tmp_entry
    # console.log last_id
    if last_id
      tmp_obj = @fa_view.all_objs.cha.obj_list[last_id]
      @fa_view.show_panel(emp.ADD_CHA_VIEW, tmp_obj)

  del_cha: (e, element)->
    # console.log 'del_cha'
    tmp_cha_str = " cha_list  "
    if @select_entry
      tmp_id_list = []
      for key, tmp_obj of @select_entry
        tmp_id_list.push(key)
        tmp_cha_str = tmp_cha_str+' '+key
        tmp_obj.destroy()
      conf_parser.remove_cha(tmp_cha_str, tmp_id_list)
      @fa_view.after_del_channel(tmp_id_list)

  dl_cha: (e, element) ->
    console.log " download channel"
    last_id = null
    for key, tmp_entry of @select_entry
      last_id = key
    # console.log last_id
    if last_id
      tmp_obj = @fa_view.all_objs.cha.obj_list[last_id]
      console.log tmp_obj
      console.log last_id
      @emp_package_common_view.show_view(last_id, tmp_obj)
    else
      emp.show_warnning("请选择对应channel~")

  dl_adapter:(e, element) ->
    # console.log " download channel"
    last_id = null
    for key, tmp_entry of @select_entry
      last_id = key
    # console.log last_id
    if last_id
      tmp_obj = @fa_view.all_objs.cha.obj_list[last_id]
      # console.log tmp_obj
      # console.log last_id
      @emp_package_adapter_view.show_view(last_id, tmp_obj)
    else
      emp.show_warnning("请选择对应channel~")

  refresh_add_cha: (cha_obj)->
    tmp_item = new ChaItemView(cha_obj)
    @gen_cha_list.append(tmp_item)

  refresh_edit_cha:(cha_obj) ->
    @edit_entry.refresh_edit(cha_obj)
