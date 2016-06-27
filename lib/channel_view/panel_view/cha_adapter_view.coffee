{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
# EmpEditView = require '../item-editor-view'
# EmpSelView = require '../item-selector-view'
_ = require 'underscore-plus'
path = require 'path'
emp = require '../../exports/emp'

ItemView = require './adapter_item_view'
AddLessOption = require './adapter_item_less_view'
# HtmlItemPanel = require './adapter_html_view'

module.exports =
class AdapterPanel extends View
  ocode_flag:null
  ocs_flag:null
  ofile_flag:null

  cha_obj:null
  item_list:[]
  lLessImportList:[]

  @content: ->
    @div class:'entry_div', =>
      @div class: 'off_use_div',  =>
        @div class: 'checkbox_ucolumn', =>
          @input outlet:'off_use_code', type: 'checkbox', checked:'true'
          @text "生成辅助代码(Create Erlang Code)"
        @div class: 'checkbox_ucolumn', =>
          @input outlet:'off_use_cs', type: 'checkbox', checked:'true'
          @text "生成CS模板(Create Cs Templates)"
        @div class: 'checkbox_ucolumn', =>
          @input outlet:'off_use_off', type: 'checkbox', checked:'true'
          @text "生成离线资源文件(Create Offline Resouce)"

        # @div class: 'checkbox_ucolumn', =>
        #   @input outlet:'off_use_off', type: 'checkbox', checked:'true'
        #   @text "(Create Offline Resouce)"
        # @div class: 'checkbox_ucolumn', =>
        #   @input outlet:'off_use_front', type: 'checkbox', checked:'true'
        #   @text "生成前端资源配置(Create Front Template Config)"


      @div outlet:'off_info', class: 'off_info_div',  =>
      # @div class: 'info-div', =>
        @label class: 'info-label', '平台(Platform)'
        @select outlet: "off_plat", class: "form-control", =>

          @option value: emp.ADAPTER_PLT_D, selected:"selected", "Default"

          # @option value: emp.ADAPTER_PLT_I, "Iphone"
          # @option value: emp.ADAPTER_PLT_A, "Android"
          # @option value: emp.ADAPTER_PLT_W, "Wphone"
      # @div class: 'info-div', =>
        @label outlet:'testt', class: 'info-label', '分辨率(Resolution)'
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
          @div class: 'checkbox_column', =>
            @input outlet:'off_js', type: 'checkbox', checked:'true'
            @text "js"
          @div class: 'checkbox_column', =>
            @input outlet:'off_less', type: 'checkbox', checked:'true'
            @text "less"
        @div class: 'off_params_div',  =>
          @div class:'off_pb_div', =>
            @button outlet:'add_less', class: 'off_btn_w btn btn-info inline-block-tight', click:'add_less_import',' Add a Less Import... '
          @ul class:'off_ul', =>
            @li class:'off_li',=>
              @text "注意:"
            @li class:'off_li',=>
              @text "1. 可以选择 Less 文件或者 Css 文件"
            @li class:'off_li',=>
              @text "2. 选择 Css 文件时,默认为 Inline 引入方式(如果不是请到对应文件内修改)."
            @li class:'off_li',=>
              @text "3. 如果为公用工程, 请选择当前工程下的文件引入,否则,代码同步之后可能会发生引入文件无法找到的问题."
          @div outlet:'less_list', class:'off_param_div'


      @div outlet:'off_params', class: 'off_params_div',  =>
        @div class:'off_pb_div', =>
          @button outlet:'addAda', class: 'off_btn_w btn btn-info inline-block-tight', click:'add_adpter_item_btn',' Add an EMP step... '
        @div outlet:'adapter_item', class:'off_param_div'

      # @div class: 'off_params_div',  =>
      #   @div class:'off_pb_div', =>
      #     @button outlet:'add_html', class: 'off_btn_w btn btn-info inline-block-tight', click:'add_html_step',' Add a Html step... '
      #   @div outlet:'html_adapter_item', class:'off_param_div'

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

    # @off_use_front.on  'click', (e, el)=>
    #   @refresh_front_type(e, el)
    # @doc 初始化 less 引入文件
    @initial_less_import()
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
    @off_js.enable()
    @off_less.enable()


  disable_off_detail: ->
    @off_plat.disable()
    @off_rel.disable()
    @off_img.disable()
    @off_css.disable()
    @off_lua.disable()
    @off_xhtml.disable()
    @off_json.disable()
    @off_js.disable()
    @off_less.disable()

  refresh_ocode_type: ->
    @ocode_flag = @off_use_code.prop('checked')
    @refresh_adapter_btn_type()

  refresh_ocs_type: ->
    @ocs_flag = @off_use_cs.prop('checked')
    @refresh_adapter_btn_type()

  # refresh_front_type: ->
  #   @ofront_flag = @off_use_front.prop('checked')
  #   @refresh_adapter_btn_type()


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

  # 创建页面主题为 EMP 页面的步骤
  add_adpter_item_btn: ->
    # console.log 'add_step'
    tmp_item = new ItemView(@cha_obj)
    @adapter_item.append(tmp_item)
    @item_list.push(tmp_item)
    tmp_item.focus()

  initial_less_import: ->
    @lLessImportList = []
    @less_list.empty()


    if lLessImportFiles = atom.config.get emp.EMP_LESS_IMPORT_FILES
      for sLessImportFile in lLessImportFiles
        oLessOption = new AddLessOption(sLessImportFile)
        @less_list.append(oLessOption)
        @lLessImportList.push(oLessOption)

    @sDefaultImportFile = path.join @cha_obj.project_path, emp.DESTINATION_CHANNEL_DEFAULT_STYLE
    oLessOption = new AddLessOption(@sDefaultImportFile, false)
    @less_list.append(oLessOption)
    @lLessImportList.push(oLessOption)

  add_less_import: ->
    # TODO: 记录添加的文件列表,方便下次使用
    oLessOption = new AddLessOption()
    @less_list.append(oLessOption)
    @lLessImportList.push(oLessOption)
    oLessOption.focus()
  #
  # # 创建 页面主题为 html 的步骤
  # add_html_step: ->
  #   tmp_item = new HtmlItemPanel(@cha_obj)
  #   @html_adapter_item.append(tmp_item)
  #   @html_item_list.push(tmp_item)
  #   tmp_item.focus()

  submit_detail: ->
    @cha_obj.use_code = @ocode_flag
    @cha_obj.use_cs = @ocs_flag
    @cha_obj.use_off = @ofile_flag
    # @cha_obj.use_front = @off_use_front
    if @check_less_import()
      @set_off_detail()
      @store_adapter()
      return 1
    else
      return 0

  set_off_detail: ->
    unless !@ofile_flag
      sOffPlat = @off_plat.val()
      sOffRel = @off_rel.val()

      bImgFlag = @off_img.prop('checked')
      bCssFlag = @off_css.prop('checked')
      bLuaFlag = @off_lua.prop('checked')
      bXhtmlFlag = @off_xhtml.prop('checked')
      bJsonFlag = @off_json.prop('checked')
      bJsFlag = @off_js.prop('checked')
      bLessFlag = @off_less.prop('checked')

      @cha_obj.set_off_detail(sOffPlat, sOffRel)
      @cha_obj.set_off_detailf(bImgFlag, bCssFlag, bLuaFlag, bXhtmlFlag, bJsonFlag, bLessFlag, bJsFlag)

  store_adapter: ->
    # console.log @item_list.length
    # console.log @item_list
    @cha_obj.initial_adapter()
    if @ofile_flag or @ocode_flag or @ocs_flag
      for a_view in @item_list
        if a_view.ex_state
          tmp_obj = a_view.submit_detail()
          @cha_obj.store_adapter(tmp_obj)

    # lLessImportFiles = []
    # for vLessOpView in @lLessImportList
    #   if vLessOpView.bValidateType
    #     sLessImportPath = vLessOpView.submit_detail()
    #     if lLessImportFiles.indexOf(sLessImportPath) < 0
    #       lLessImportFiles.push sLessImportPath
    #       @cha_obj.store_less_import(sLessImportPath)
    #   else
    #     bInvalidateFLag = true
    #
    # atom.config.set(emp.EMP_LESS_IMPORT_FILES, lLessImportFiles)

  # @doc 判断引入的 less 是否为当前工程内的文件
  check_less_import: ->
    console.log "check_less_import-------"
    lLessImportFiles = []
    lErrorImportFiles = []
    for vLessOpView in @lLessImportList
      console.log vLessOpView.bStatue

      sLessImportPath = vLessOpView.submit_detail()
      console.log sLessImportPath
      if vLessOpView.check_statue()
        if !vLessOpView.check_validate()
          lErrorImportFiles.push sLessImportPath
        if lLessImportFiles.indexOf(sLessImportPath) < 0
          lLessImportFiles.push sLessImportPath
          # @cha_obj.store_less_import(sLessImportPath)

        # break
    # console.log lErrorImportFiles
    if lErrorImportFiles.length >0
      if @show_alert(lErrorImportFiles)
        # do_some
        # _.each lLessImportFiles, (sFile) =>
        #   @cha_obj.store_less_import(sFile)
        lStoreImportFiles = _.filter lLessImportFiles, (sFile) =>
          @cha_obj.store_less_import(sFile)
          return sFile isnt @sDefaultImportFile

        atom.config.set(emp.EMP_LESS_IMPORT_FILES, lStoreImportFiles)
        return 1
      else
        return 0
    else
      lStoreImportFiles = _.filter lLessImportFiles, (sFile) =>
        @cha_obj.store_less_import(sFile)
        return sFile isnt @sDefaultImportFile
      # _.each lLessImportFiles, (sFile) =>
      #   @cha_obj.store_less_import(sFile)
      atom.config.set(emp.EMP_LESS_IMPORT_FILES, lStoreImportFiles)
      return 1



  #
  # # 如果为非 lua 或者 xhtml ,提示是否强制添加
  show_alert: (lErrorImportFiles) ->
    sShowCon = ''
    _.each lErrorImportFiles, (sFile) =>
      sShowCon += "#{sFile} \n"
    atom.confirm
      message: '文件类型警告!'
      detailedMessage: '当前引入的文件中含有不是 Less 或者 Css 的文件类型, 请删除之后继续添加!\n' + sShowCon
      buttons:
        '删除,并添加': -> return 1
        '否': -> return 0
