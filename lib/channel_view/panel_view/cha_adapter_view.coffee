{$, $$, View} = require 'atom'
# EmpEditView = require '../item-editor-view'
# EmpSelView = require '../item-selector-view'
emp = require '../../exports/emp'

ItemView = require './adapter_item_view'

module.exports =
class AdapterPanel extends View
  ocode_flag:null
  ocs_flag:null
  ofile_flag:null

  cha_obj:null
  item_list:[]

  @content: ->
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

      @div outlet:'off_info', class: 'off_info_div',  =>
      # @div class: 'info-div', =>
        @label class: 'info-label', '平台'
        @select outlet: "off_plat", class: "form-control", =>

          @option value: emp.ADAPTER_PLT_D, selected:"selected", "Default"

          # @option value: emp.ADAPTER_PLT_I, "Iphone"
          # @option value: emp.ADAPTER_PLT_A, "Android"
          # @option value: emp.ADAPTER_PLT_W, "Wphone"
      # @div class: 'info-div', =>
        @label outlet:'testt', class: 'info-label', '分辨率'
        # @select outlet: "off_rel", class: "form-control", =>
        # @subview "off_rel", class:'form-control', new EmpSelView([{name:'1', value:'1'},{name:'2', value:'2'},{name:'3', value:'3'}])
        # @div class: 'form-control select-list popover-list', =>
        #   @subview "off_rel", new EmpEditView(attributes: {id: 'off_rel', type: 'string'},  placeholderText: 'App')
        #   @ol class: 'list-group', =>
        #     @li class: 'selected', 'one'
        #     @li 'two'
        #     @li 'three'
        @select outlet: "off_rel", class: "form-control", =>
          @option value: emp.ADAPTER_PLT_R,selected:"selected", "Default"
          # @option value: emp.ADAPTER_PLT_R1, emp.ADAPTER_PLT_R1
          # @option value: emp.ADAPTER_PLT_R2, emp.ADAPTER_PLT_R2
          # @option value: emp.ADAPTER_PLT_R3, emp.ADAPTER_PLT_R3
        @div class: 'off_type_div', =>
          @div class: 'checkbox_column', =>
            @input outlet:'off_img', type: 'checkbox', checked:'true'
            @text "images"
          @div class: 'checkbox_column', =>
            @input outlet:'off_css', type: 'checkbox', checked:'true'
            @text "css"
          @div class: 'checkbox_column', =>
            @input outlet:'off_lua', type: 'checkbox', checked:'true'
            @text "lua"
          @div class: 'checkbox_column', =>
            @input outlet:'off_xhtml', type: 'checkbox', checked:'true'
            @text "xhtml"
          @div class: 'checkbox_column', =>
            @input outlet:'off_json', type: 'checkbox', checked:'true'
            @text "json"
      @div outlet:'off_params', class: 'off_params_div',  =>
        @div class:'off_pb_div', =>
          @button outlet:'addAda', class: 'off_btn_w btn btn-info inline-block-tight', click:'add_adpter_item_btn',' Add a step... '
        @div outlet:'adapter_item', class:'off_param_div'


  initialize: (@cha_obj, edit_obj)->
    # console.log "adapter view initial"
    # @disable_off_detail()
    # tmp_view = new EmpSelView([{name:'1', value:'1'},{name:'2', value:'2'},{name:'3', value:'3'}])
    # @testt.after(tmp_view)
    @item_list = []
    @ocode_flag=true
    @ocs_flag=true
    @ofile_flag=true

    # @doc 初始化 平台选项
    def_plat_list = [emp.ADAPTER_PLT_I, emp.ADAPTER_PLT_A, emp.ADAPTER_PLT_W]
    unless tmp_plat_list = atom.config.get(emp.EMP_CHANNEL_ADAPTER_PLAT)
      tmp_plat_list = def_plat_list
      atom.config.set(emp.EMP_CHANNEL_ADAPTER_PLAT, tmp_plat_list)
    for tmp_plat in tmp_plat_list
      @off_plat.append(@select_option(tmp_plat))

    # @doc 初始化分辨率选项
    def_res_list = [emp.ADAPTER_PLT_R1, emp.ADAPTER_PLT_R2, emp.ADAPTER_PLT_R3,
      emp.ADAPTER_PLT_R4,emp.ADAPTER_PLT_R5,emp.ADAPTER_PLT_R6, emp.ADAPTER_PLT_R7]
    unless tmp_res_list = atom.config.get(emp.EMP_CHANNEL_ADAPTER_RES)
      tmp_res_list = def_res_list
      atom.config.set(emp.EMP_CHANNEL_ADAPTER_RES, def_res_list)
    tmp_res_list = tmp_res_list.sort()
    for tmp_res in tmp_res_list
      @off_rel.append(@select_option(tmp_res))

    # console.log edit_obj
    if edit_obj
      if typeof(edit_obj.views) is 'object'
        for tmp_key,tmp_val of edit_obj.views
          @add_adpter_item(tmp_key, tmp_val)
      else
        for tmp_key,tmp_obj of edit_obj.adapters
          @add_adpter_item(tmp_key, tmp_obj)

    @off_use_cs.on 'click', (e) =>
      @refresh_ocs_type()

    @off_use_code.on  'click', (e, el)=>
      @refresh_ocode_type()

    @off_use_off.on  'click', (e, el)=>
      @refresh_off_type(e, el)
    this

  select_option: (tmp_val)->
    $$ ->
      @option value: tmp_val, "#{tmp_val}"


  refresh_off_type: (e, el)->
    @ofile_flag = @off_use_off.prop('checked')
    # code_flag = @off_use_code.prop('checked')
    @refresh_adapter_btn_type()
    if @ofile_flag
      @enable_off_detail()
    else
      @disable_off_detail()


  enable_off_detail: ->
    @off_plat.enable()
    @off_rel.enable()
    @off_img.enable()
    @off_css.enable()
    @off_lua.enable()
    @off_xhtml.enable()
    @off_json.enable()


  disable_off_detail: ->
    @off_plat.disable()
    @off_rel.disable()
    @off_img.disable()
    @off_css.disable()
    @off_lua.disable()
    @off_xhtml.disable()
    @off_json.disable()

  refresh_ocode_type: ->
    @ocode_flag = @off_use_code.prop('checked')
    @refresh_adapter_btn_type()

  refresh_ocs_type: ->
    @ocs_flag = @off_use_cs.prop('checked')
    @refresh_adapter_btn_type()


  refresh_adapter_btn_type: ->
    if @ofile_flag or @ocode_flag or @ocs_flag
      @addAda.enable()
    else
      @addAda.disable()

  add_adpter_item: (key, val)->
    # console.log 'add_step'
    tmp_item = new ItemView(@cha_obj, key, val)
    @adapter_item.append(tmp_item)
    @item_list.push(tmp_item)

  add_adpter_item_btn: ->
    # console.log 'add_step'
    tmp_item = new ItemView(@cha_obj)
    @adapter_item.append(tmp_item)
    @item_list.push(tmp_item)
    tmp_item.focus()

  submit_detail: ->
    @cha_obj.use_code = @ocode_flag
    @cha_obj.use_cs = @ocs_flag
    @cha_obj.use_off = @ofile_flag
    @set_off_detail()
    @store_adapter()

  set_off_detail: ->
    unless !@ofile_flag
      off_plat = @off_plat.val()
      off_rel = @off_rel.val()

      oimg_flag = @off_img.prop('checked')
      ocss_flag = @off_css.prop('checked')
      olua_flag = @off_lua.prop('checked')
      oxhtml_flag = @off_xhtml.prop('checked')
      ojson_flag = @off_json.prop('checked')
      @cha_obj.set_off_detail(off_plat, off_rel)
      @cha_obj.set_off_detailf(oimg_flag, ocss_flag, olua_flag, oxhtml_flag, ojson_flag)

  store_adapter: ->
    # console.log @item_list.length
    # console.log @item_list
    @cha_obj.initial_adapter()
    if @ofile_flag or @ocode_flag or @ocs_flag
      for a_view in @item_list
        if a_view.ex_state
          tmp_obj = a_view.submit_detail()
          @cha_obj.store_adapter(tmp_obj)
