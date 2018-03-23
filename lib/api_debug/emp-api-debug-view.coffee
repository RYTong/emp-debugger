{$, $$, ScrollView, TextEditorView} = require 'atom-space-pen-views'
remote = require 'remote'
dialog = remote.Dialog
fs = require 'fs'
fs_plus = require 'fs-plus'
path = require 'path'
http = require 'http'
querystring = require 'querystring'
# EmpEditView = require '../channel_view/item-editor-view'
emp = require '../exports/emp'

module.exports =
class EMPAPIDebuggView extends ScrollView

  app_version:'5.3'
  sAPIName:''
  app_dir:''
  ewp_dir:''
  default_api_host:'localhost'
  default_api_method:'POST'

  sDefaultPort:'4002'
  default_app_aport:'4000'
  sDefaultPack:"default"
  aDefaultMethods:["POST", "GET", "DELETE", "PUT"]


  @content: ->
    @div class: 'emp-app-wizard pane-item', tabindex: -1, =>
      @div class:'wizard-panels', =>
      #   @div outlet:"emp_logo", class: 'atom-banner'
        @div class: 'wizard-logo', outlet: 'wizard_logo', =>
          @div outlet:"emp_logo", class: 'atom-banner'
        @div class: 'detail-panels', =>
          @div class:'detail-ch-panels', =>
            @div class: 'block panels-heading icon icon-gear', "Api Debug..."

            @div class:'detail-body', =>
              @div class:'detail-con', =>
                @div class:'info-div', =>
                  @label class: 'info-label', 'API Pack*:'
                  @select outlet:"exist_pack", id: "exist_pack", class: 'form-control'

                @div class:'info-div div_border', =>
                  @label class: 'info-label', 'API Pack*:'
                  @select outlet:"exist_api", id: "exist_api", class: 'form-control'

                @div class:'info-div', =>
                  @label class: 'info-label', 'API Package Name*:'
                  @subview "pack_name_editor", new TextEditorView(mini: true,attributes: {id: 'pack_name', type: 'string'},  placeholderText: 'Pack Name')

                @div class:'info-div', =>
                  @label class: 'info-label', 'API Name*:'
                  @subview "api_name_editor", new TextEditorView(mini: true,attributes: {id: 'api_name', type: 'string'},  placeholderText: 'API Name')

                @div class:'info-div', =>
                  @label class: 'info-label', 'API Request Method: '

                  @select outlet:"api_method", id: "api_method", class: 'form-control'


                @div class:'info-div', =>
                  @label class: 'info-label', 'API Host*:'
                  @subview "api_host", new TextEditorView(mini: true,attributes: {id: 'api_host', type: 'string'},  placeholderText: 'API Host')

                @div class:'info-div', =>
                  @label class: 'info-label', 'API Port*:'
                  @label class: 'detail-label', 'Http Request 端口.'
                  @subview "api_port", new TextEditorView(mini: true,attributes: {id: 'api_port', type: 'string'},  placeholderText: 'API Request Port')

                @div class:'info-div', =>
                  @label class: 'info-label', 'API Path*:'
                  @subview "api_path", new TextEditorView(mini: true,attributes: {id: 'api_path', type: 'string'},  placeholderText: 'API Path')

                @div class:'info-div', =>
                  @label class: 'info-label', 'Default Data*:'
                  @label class: 'detail-label', 'Default Data.(默认请求接口带的参数)'
                  @subview "def_api_data", new TextEditorView(mini: true,attributes: {id: 'def_api_data', type: 'string'},  placeholderText: 'Default API Data')

                @div class:'info-div', =>
                  @label class: 'info-label', 'API Data*:'
                  @label class: 'detail-label', 'API Data.(请求接口的 data)'
                  @subview "api_data", new TextEditorView(mini: true,attributes: {id: 'api_data', type: 'string'},  placeholderText: 'API Data')

                @div class:'info-div', =>
                  @label class: 'info-label', 'Request Result:'
                  # @label class: 'detail-label', 'API Data.'
                  @textarea "", class: "snippet_area native-key-bindings editor-colors", rows: 8, outlet: "api_result", placeholder: ""

            @div class: 'footer-div', =>
              @div class: 'footer-detail', =>
                @button class: 'footer-btn btn btn-info inline-block-tight', click:'do_cancel','  Cancel  '
                @button class: 'footer-btn btn btn-info inline-block-tight', click:'do_save',' Save '
                @button class: 'footer-btn btn btn-info inline-block-tight', click:'do_save_result',' Save Result'
                @button class: 'footer-btn btn btn-info inline-block-tight', click:'do_test','Do Request '

  initialize: ({@uri}={}) ->
    super
    sDefAPIData = atom.config.get(emp.EMP_DEF_API_DATA)
    @sAPIJsonPath = path.join __dirname, '../../', emp.STATIC_API_DIR
    console.log @sAPIJsonPath
    if fs.existsSync @sAPIJsonPath
      json_data = fs.readFileSync @sAPIJsonPath
      @oAPIObject = JSON.parse json_data
      # @initial_()
    else
      @oAPIObject = {packs:[@sDefaultPack]}

      @oAPIObject[@sDefaultPack]={name:@sDefaultPack, apis:[]}

    @exist_pack.change (event) =>
      sTmpPack = @exist_pack.val()
      console.log @exist_pack.val()
      # console.log @oAPIObject[sTmpPack]
      #
      # aCopyMethods = @aDefaultMethods.slice()
      # sFirstMethod = aCopyMethods.shift()
      # @api_method.append @new_selected_option(sFirstMethod)
      # for sTmpAPIMethod in aCopyMethods
      #   @api_method.append @new_option(sTmpAPIMethod)

    @exist_api.change (event) =>
      sTmpPack = @exist_pack.val()
      sTmpAPI = @exist_api.val()
      oAPI = @oAPIObject[sTmpPack][sTmpAPI]
      # console.log oAPI
      # console.log @exist_api.val()

      @pack_name_editor.setText oAPI.pack
      @api_name_editor.setText oAPI.name
      @api_host.setText oAPI.host
      @change_method_select(oAPI.method)
      # @api_method.val(oTmpPack.method)
      unless !oAPI.path
        @api_path.setText oAPI.path
      unless !oAPI.port
        @api_port.setText oAPI.port
      unless !oAPI.data
        @api_data.setText oAPI.data

      unless !oAPI.def_data
        @def_api_data.setText oAPI.def_data

      unless !oAPI.result
        @api_result.val oAPI.result

    # console.log @api_method

    # initial request method
    # aDefaultMethods

    aCopyMethods = @aDefaultMethods.slice()
    sFirstMethod = aCopyMethods.shift()
    @api_method.append @new_selected_option(sFirstMethod)
    for sTmpAPIMethod in aCopyMethods
      @api_method.append @new_option(sTmpAPIMethod)

    # if @oAPIObject[@sDefaultPack]?
    if @oAPIObject.packs
      aTmpPacks = @oAPIObject.packs.slice()
      sFirstPack = aTmpPacks.shift()
      @exist_pack.append @new_selected_option(sFirstPack)
      oTmpPacks = @oAPIObject[sFirstPack]
      if oTmpPacks?.apis
        aTmpAPIs = oTmpPacks?.apis.slice()
        sFirstAPI = aTmpAPIs.shift()
        @exist_api.append @new_selected_option(sFirstAPI)
        oTmpPack = oTmpPacks[sFirstAPI]

        for sTmpAPI in aTmpAPIs
          sTmpAPIOption = @new_option sTmpAPI
          @exist_api.append sTmpAPIOption

        @pack_name_editor.setText oTmpPack.pack
        @api_name_editor.setText oTmpPack.name
        @api_host.setText oTmpPack.host
        @change_method_select(oTmpPack.method)
        # @api_method.val(oTmpPack.method)
        unless !oTmpPack.path
          @api_path.setText oTmpPack.path
        unless !oTmpPack.port
          @api_port.setText oTmpPack.port
        unless !oTmpPack.data
          @api_data.setText oTmpPack.data

        unless !oTmpPack.def_data
          @def_api_data.setText oTmpPack.def_data

        unless !oTmpPack.result
          @api_result.val oTmpPack.result
      else
        # console.log @oAPIObject
        @pack_name_editor.setText sFirstPack
        @change_method_select(@default_api_method)
        # @api_method.val(default_api_method)
        @api_port.setText "4002"
        @api_data.setText "data"
        @def_api_data.setText sDefAPIData

      for sTmpPack in aTmpPacks
        sTmpPackOption = @new_option sTmpPack
        @exist_pack.append sTmpPackOption
        if aTmpAPIs = @oAPIObject[sTmpPack]?.apis
          for sTmpAPI in aTmpAPIs
            sTmpAPIOption = @new_option sTmpAPI
            @exist_api.append sTmpAPIOption
    else
      # console.log @oAPIObject
      @pack_name_editor.setText @sDefaultPack
      @change_method_select(@default_api_method)
      # @api_method.val(default_api_method)
      @api_port.setText "4002"
      @api_data.setText "data"
      @def_api_data.setText sDefAPIData
    # console.log "app wizard view"
    # if @default_api_host = atom.config.get(emp.EMP_APP_WIZARD_APP_P)
    #   # console.log "exist"
    #   @api_host.setText(@default_api_host)
    # if tmp_ewp_path = atom.config.get(emp.EMP_APP_WIZARD_EWP_P)
    #   # console.log "exist ewp"
    #   @default_api_method = tmp_ewp_path
    #   @api_method.setText(@default_api_method)
    # else
    #   @api_method.setText(@default_api_method)
    # # @focus()
    #
    # if !tmp_app_port = atom.config.get emp.EMP_TEMP_WIZARD_PORT
    #   tmp_app_port = @default_app_port
    # @app_port.setText tmp_app_port
    #
    # if !tmp_app_aport = atom.config.get emp.EMP_TEMP_WIZARD_APORT
    #   tmp_app_aport = @default_app_aport
    # @app_aport.setText tmp_app_aport

  change_method_select:(sTag)->
    sTag = sTag.toUpperCase()
    iOptIndex = @api_method.context?.childElementCount
    # console.log @api_method.context?.childElementCount
    # console.log @api_method.context.selectedIndex
    # console.log @api_method.context.selectedOptions
    for iTmpIndex in [0..iOptIndex-1]
      unless (@api_method.context[iTmpIndex].innerText isnt sTag)
        # console.log @api_method.context[iTmpIndex]
        # console.log $(@api_method.context[iTmpIndex])
        $(@api_method.context[iTmpIndex]).attr('selected', true)


  select_epath: (e, element)->
    tmp_path = @api_method.val()
    @promptForPath(@api_method, tmp_path)

  promptForPath: (fa_view, def_path) ->
    if def_path
      dialog.showOpenDialog title: 'Select', defaultPath:def_path, properties: ['openDirectory', 'createDirectory'], (pathsToOpen) =>
        @refresh_path( pathsToOpen, fa_view)
    else
      dialog.showOpenDialog title: 'Select', properties: ['openDirectory', 'createDirectory'], (pathsToOpen) =>
        @refresh_path( pathsToOpen, fa_view)

  refresh_path: (new_path, fa_view)->
    if new_path
      # console.log new_path
      fa_view.setText(new_path[0])


  show_dialog: ->
    dialog.showMessageBox title:'test', message:"asdasda"

  redrawEditors: ->
    $(element).view().redraw() for element in @find('.editor')

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    deserializer: emp.APP_WIZARD_VIEW
    version: 1
    activePanelName: @activePanelName ? emp.APP_WIZARD_VIEW
    uri: @uri

  # Tear down any state and detach
  # destroy: ->
  #   @detach()

  # toggle: ->
  #   # console.log "EmpChannelWizardView was toggled!"
  #   if @hasParent()
  #     @detach()
  #   # else
  #     atom.workspaceView.append(this)
  #     # @add_new_panel()
  #     # @parse_conf()
  focus: ->
    # super
    @api_name_editor.focus()

  getUri: ->
    @uri

  getTitle: ->
    "EMP API Debug"

  isEqual: (other) ->
    other instanceof EmpChannelWizardView

  refresh_view:(@all_objs) ->
    @remove_loading()

  remove_loading: ->
    @loadingElement.remove()

  do_cancel: ->
    # console.log "do_submit "
    # atom.workspaceView.trigger 'core:close'
    atom.workspace.getActivePane().destroyActiveItem()

  do_save: ->
    # console.log "do do_save"
    try
      unless @sPackName = @pack_name_editor.getText().trim()
        throw("Pack名称不能为空！")
      unless @sAPIName = @api_name_editor.getText().trim()
        throw("API名称不能为空！")
      unless @sAPIHost = @api_host.getText().trim()
        throw("API Host不能为空！")
      unless @sAPIMethod = @api_method.val()
        @sAPIMethod = "get"

      unless @sAPIPath = @api_path.getText().trim()
        throw("API Path不能为空！")
      console.log  @sAPIName

      unless @sAPIPort = @api_port.getText().trim()
        @sAPIPort = @sDefaultPort
      unless @sAPIData = @api_data.getText().trim()
        @sAPIData = ""

      unless @sDefAPIData = @def_api_data.getText().trim()
        @sDefAPIData = ""

      # atom.workspace.destroyActivePaneItem()
      oNewApi = @new_api_to_store()
      console.log @oAPIObject
      console.log @sPackName
      oPackApis = @oAPIObject[@sPackName]

      # delete @sAPIJsonPath @sAPIJsonPath[@sPackName]
      console.log oPackApis
      oNewApi.result = oPackApis[@sAPIName].result
      delete oPackApis[@sAPIName]
      # oPackApis.packs = oPackApis.packs.filter (tmp_api_name) -> tmp_api_name isnt oNewApi.name
      unless (oPackApis.apis.indexOf(@sAPIName) >= 0)
        oPackApis.apis.push @sAPIName
      oPackApis[@sAPIName] = oNewApi
      @store_api(oPackApis)
      emp.show_info "API 保存成功"


    catch e
      console.error e
      emp.show_error("保存 API 参数失败, 请查看日志!")

  do_save_result:()=>
    try
      unless @sPackName = @pack_name_editor.getText().trim()
        throw("Pack名称为空,无法保存！")
      unless @sAPIName = @api_name_editor.getText().trim()
        throw("API名称为空, 无法保存！")


      unless @sAPIResult = @api_result.val().trim()
        @sAPIResult = ""

      # atom.workspace.destroyActivePaneItem()
      console.log @oAPIObject
      console.log @sPackName
      oPackApis = @oAPIObject[@sPackName]
      # delete @sAPIJsonPath @sAPIJsonPath[@sPackName]
      console.log oPackApis
      oThisAPI = oPackApis[@sAPIName]

      oPackApis[@sAPIName].result = @sAPIResult
      @store_api(oPackApis)
      emp.show_info "API Result 保存成功"
    catch e
      console.error e
      emp.show_error("保存 API Result失败, 请查看日志!")

  do_test: ()=>
    try
      unless @sAPIName = @api_name_editor.getText().trim()
        throw("API名称不能为空！")
      unless @sAPIHost = @api_host.getText().trim()
        throw("API Host不能为空！")

      unless @sAPIMethod = @api_method.val()
        @sAPIMethod = "get"

      unless @sAPIPath = @api_path.getText().trim()
        throw("API Path不能为空！")

      unless @sAPIPort = @api_port.getText().trim()
        @sAPIPort = @sDefaultPort


      unless @sAPIData = @api_data.getText().trim()
        # atom.config.set emp.EMP_TEMP_WIZARD_APORT, @app_aport_text
        # else
        @sAPIData = ""

      unless @sDefAPIData = @def_api_data.getText().trim()
        @sDefAPIData = ""

      sNewPath = @sAPIPath
      if !(@sAPIPath.indexOf "?" >= 0)
        sNewPath = sNewPath+'&'+@sDefAPIData
      else
        sNewPath = sNewPath+'?'+@sDefAPIData

      oTmpOption = @new_http_option(sNewPath)
      console.log  @sAPIName
      console.log oTmpOption

      req = http.request oTmpOption,(res) =>
        console.log('STATUS: ' + res.statusCode)
        console.log('HEADERS: ' + JSON.stringify(res.headers))
        res.setEncoding('utf8')
        res.on 'data',(chunk) =>
          console.log('BODY: ' + chunk);
          @api_result.context.value = chunk


      req.on 'error', (e)=>
        console.log('problem with request: ' + e.message)

      # // write data to request body
      console.log @sAPIData
      req.write(@sAPIData+'\n')
      req.end()

        # console.log res
        # console.log  res.resume()
        # res.resume()
      # @new_api_to_store()
    catch e
      console.error e
      emp.show_error("保存 API 参数失败!")

  new_http_option:(sNewPath) =>
    return {host:@sAPIHost,port:@sAPIPort,path:sNewPath, method:@sAPIMethod,headers: {'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8','Content-Length': @sAPIData.length}}


  new_api_to_store:() =>
    return {name:@sAPIName, method:@sAPIMethod,host:@sAPIHost,  port:@sAPIPort, path:@sAPIPath, def_data:@sDefAPIData, data:@sAPIData,pack:@sPackName, result:""}

  store_api:(oNewApi) =>
    sApiName = oNewApi.name
    delete @oAPIObject[sApiName]
    @oAPIObject.packs = @oAPIObject.packs.filter (tmp_pack_name) -> tmp_pack_name isnt sApiName
    @oAPIObject.packs.push sApiName
    @oAPIObject[sApiName] = oNewApi
    console.log @oAPIObject
    @refreh_api_json()

  refreh_api_json: ()=>
    temp_str = JSON.stringify @oAPIObject, null, '\t'
    # console.log template_json
    # console.log temp_str
    fs.writeFileSync @sAPIJsonPath, temp_str



  string_replace: (str) ->
    map = [{'k':/\$\{app\}/ig,'v':@sAPIName}, {'k':/\$\{ecl_ewp\}/ig,'v':@ewp_dir},
          {'k':/\$\{server_port\}/ig,'v':@app_port_text},{'k':/\$\{console_port\}/ig,'v':@app_aport_text}]
    for o in map
      str = str.replace(o.k, o.v)
    str





  new_option: (name)->
    $$ ->
      @option value: name, name

  new_selected_option: (name) ->
    $$ ->
      @option selected:'select', value: name, name
