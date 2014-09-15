{View} = require 'atom'
EmpEditView = require '../../view/emp-edit-view'
emp = require '../../exports/emp'

module.exports =
class AddGenPanel extends View
  name:emp.ADD_CHA_VIEW

  @content: ->
    @div class: 'general-panel section', =>
      @div outlet: "loadingElement", class: 'alert alert-info loading-area icon icon-hourglass', "Loading settings"
      @div class: 'add-channel-panel', =>
        # @section class: 'config-section', =>
        @div class: 'block section-heading icon icon-gear', "Create A Channel..."
        @div class: 'div-body', =>
          @div class:'div-con ', =>
            @div class:'off_type_div', =>
              @div class: 'info-div', =>
                @label class: 'info-label', '频道ID*'
                @subview "cha_id", new EmpEditView(attributes: {id: 'cha_id', type: 'string'},  placeholderText: 'Channel ID') #from editor view class
              @div class: 'info-div', =>
                @label class: 'info-label', '频道名称*'
                @subview "cha_name", new EmpEditView(attributes: {id: 'cha_name', type: 'string'},  placeholderText: 'Channel Name') #from editor view class
              @div class: 'info-div', =>
                @label class: 'info-label', '所属App'
              @subview "cha_app", new EmpEditView(attributes: {id: 'cha_app', type: 'string'},  placeholderText: 'App') #from editor view class
            @div class: 'info-div', =>
              @label class: 'info-label', '频道配型'
              @select outlet: "channel_entry", class: "form-control", =>
                @option value: emp.CHANNEL_ADAPTER, selected:"selected", "适配"
                @option value: emp.CHANNEL_NEW_CALLBACK, "新回调"
                @option value: emp.CHANNEL_CALLBACK, "回调"
            @div class: 'info-div info-font', =>
              @label class: 'info-label', '频道状态:'
              # @div class: 'checkbox', =>
              @input outlet:'cha_state', type: 'checkbox'
              @text "开启"

            @div class:'entry_div', =>
              @div class: 'off_use_div',  =>
                @div class: 'checkbox_ucolumn', =>
                  @input outlet:'off_use_code', type: 'checkbox', checked:'true'
                  @text "生成辅助代码"
                @div class: 'checkbox_ucolumn', =>
                  @input outlet:'off_use_cs', type: 'checkbox', checked:'true'
                  @text "生成CS模板"
                @div class: 'checkbox_ucolumn', =>
                  @input outlet:'off_use_off', type: 'checkbox', checked:'true'
                  @text "生成离线资源文件"
                # disapled:'disabled',
              @div outlet:'off_info', class: 'off_info_div',  =>
              # @div class: 'info-div', =>
                @label class: 'info-label', '平台'
                @select outlet: "off_plat", class: "form-control", =>
                  @option value: emp.CHANNEL_ADAPTER, selected:"selected", "适配"
                  @option value: emp.CHANNEL_NEW_CALLBACK, "新回调"
                  @option value: emp.CHANNEL_CALLBACK, "回调"
              # @div class: 'info-div', =>
                @label class: 'info-label', '分辨率'
                @select outlet: "off_rel", class: "form-control", =>
                  @option value: emp.CHANNEL_ADAPTER, selected:"selected", "适配"
                  @option value: emp.CHANNEL_NEW_CALLBACK, "新回调"
                  @option value: emp.CHANNEL_CALLBACK, "回调"
                @div class: 'off_type_div', =>
                  @div class: 'checkbox_column', =>
                    @input outlet:'off_f1', type: 'checkbox', checked:'true'
                    @text "images"
                  @div class: 'checkbox_column', =>
                    @input outlet:'off_f2', type: 'checkbox', checked:'true'
                    @text "css"
                  @div class: 'checkbox_column', =>
                    @input outlet:'off_f3', type: 'checkbox', checked:'true'
                    @text "lua"
                  @div class: 'checkbox_column', =>
                    @input outlet:'off_f4', type: 'checkbox', checked:'true'
                    @text "xhtml"
                  @div class: 'checkbox_column', =>
                    @input outlet:'off_f5', type: 'checkbox', checked:'true'
                    @text "json"
              @div outlet:'off_params', class: 'off_info_div',  =>





        @div class: 'item_div', =>
          @div class: 'item_cbtn_div', =>
            @button class: 'item_btn btn btn-info inline-block-tight', click:'do_cancel','  Cancel  '
            @button class: 'item_btn btn btn-info inline-block-tight', click:'do_ok',' Ok '



  initialize: (@fa_view, objs)->
    @loadingElement.remove()
    @disable_off_detail()


  disable_off_detail: ->
    @disable_off_file()
    @disable_off_plat()

  disable_off_plat: ->
    @off_plat.disable()
    @off_rel.disable()


  disable_off_file: ->
    @off_f1.disable()
    @off_f2.disable()
    @off_f3.disable()
    @off_f4.disable()
    @off_f5.disable()

    # @append(new ItemPanel('core'))
    # @append(@col_view)
    # @append(@cha_view)
  do_cancel:  ->
    @fa_view.show_panel(emp.GEN_VIEW)
