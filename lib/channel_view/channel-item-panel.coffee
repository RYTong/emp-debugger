{$, $$, View} = require 'atom'
ChaItemView = require './item_view/channel-item-view'
emp =  require '../exports/emp'

module.exports =
class ChannelItemPanel extends View
  select_entry:null
  new_all_obj:null
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

  initialize: (@fa_view) ->
    # @loadingElement.remove()
    # settings = atom.config.getSettings()
    @on 'click', '.emp_cha_item_tag', (e, element) =>
      @itemClicked(e, element)

    # @bindFormFields()
    # @bindEditors()

  refresh_cha_list:(@new_all_obj) ->
    # console.log new_all_obj
    cha_obj = @new_all_obj.cha.obj_list

    for n, obj of cha_obj
      tmp_item = new ChaItemView(obj)
      @gen_cha_list.append(tmp_item)


  itemClicked:(e, element) ->
    console.log "item click"
    entry = $(e.currentTarget).view()
    if @select_entry isnt null
      @select_entry.deselect()
    entry.select()
    @select_entry = entry

  add_cha: (e, element)->
    # console.log 'add_cha'
    @fa_view.show_panel(emp.ADD_CHA_VIEW)

  edi_cha: (e, element)->
    console.log 'edi_cha'

  del_cha: (e, element)->
    console.log 'del_cha'
