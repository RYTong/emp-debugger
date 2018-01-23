{$, $$, ScrollView, TextEditorView} = require 'atom-space-pen-views'
{ dialog } = require('electron').remote
fs = require 'fs'
path = require 'path'
# EmpEditView = require '../channel_view/item-editor-view'
emp = require '../exports/emp'

module.exports =
class EmpAppWizardView extends ScrollView

  app_version:'basic'
  app_name:'ebank'
  app_dir:''
  ewp_dir:''
  default_app_path:''
  default_app_port:'4002'
  default_app_aport:'4000'
  default_ewp_path:'/usr/local/lib/ewp'


  @content: ->
    @div class: 'emp-app-wizard pane-item', tabindex: -1, =>
      @div class:'wizard-panels', =>
      #   @div outlet:"emp_logo", class: 'atom-banner'
        @div class: 'wizard-logo', outlet: 'wizard_logo', =>
          @div outlet:"emp_logo", class: 'atom-banner'
        @div class: 'detail-panels', =>
          @div class:'detail-ch-panels', =>
            @div class: 'block panels-heading icon icon-gear', "Create A Template Application..."

            @div class:'detail-body', =>
              @div class:'detail-con', =>
                @div class:'info-div', =>
                  @label class: 'info-label', 'Channel Id*:'
                @div class:'info-div', =>
                  @label class: 'detail-label', 'Channel Id.'
                  @subview "cha_id_editor", new TextEditorView(mini: true,attributes: {id: 'cha_id', type: 'string'},  placeholderText: 'Channel Id')

                @div class:'info-div', =>
                  @label class: 'info-label', 'Resource Path*:'
                  @label class: 'detail-label', '页面文件存放位置.'
                  @subview "src_path", new TextEditorView(mini: true,attributes: {id: 'src_path', type: 'string'},  placeholderText: 'Resource Path')
                  @button class: 'path-btn btn btn-info inline-block-tight', click:'select_apath',' Chose Path '


                @div class:'info-div', =>
                  @label class: 'info-label', 'App Port*:'
                  @label class: 'detail-label', 'App 服务端口.'
                  @subview "app_port", new TextEditorView(mini: true,attributes: {id: 'app_port', type: 'string'},  placeholderText: 'Application Port')

                @div class:'info-div', =>
                  @label class: 'info-label', 'App Console Port*:'
                  @label class: 'detail-label', '管理平台端口.'
                  @subview "app_aport", new TextEditorView(mini: true,attributes: {id: 'app_aport', type: 'string'},  placeholderText: 'Console Port')



            @div class: 'footer-div', =>
              @div class: 'footer-detail', =>
                @button class: 'footer-btn btn btn-info inline-block-tight', click:'do_cancel','  Cancel  '
                @button class: 'footer-btn btn btn-info inline-block-tight', click:'do_submit',' Ok '




  initialize: ({@uri}={}) ->
    super
    # console.log "app wizard view"
    if !tmp_name = atom.config.get emp.EMP_TEMP_WIZARD_NAME
      tmp_name = @app_name
      # console.log "exist"
    @app_name_editor.setText tmp_name

    if @default_app_path = atom.config.get(emp.EMP_TEMP_WIZARD_PATH)
      # console.log "exist"
      @app_path.setText @default_app_path

    if !tmp_app_port = atom.config.get emp.EMP_TEMP_WIZARD_PORT
      tmp_app_port = @default_app_port
    @app_port.setText tmp_app_port

    if !tmp_app_aport = atom.config.get emp.EMP_TEMP_WIZARD_APORT
      tmp_app_aport = @default_app_aport
    @app_aport.setText tmp_app_aport


  select_apath: (e, element)->
    tmp_path = @app_path.getText()
    @promptForPath(@app_path, tmp_path)


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
  destroy: ->
    @detach()

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
    @app_name_editor.focus()

  getUri: ->
    @uri

  getTitle: ->
    "Create An EMP Template App Wizard"

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

  do_submit: ->
    # console.log "do do_submit"
    try
      unless @app_name = @app_name_editor.getText().trim()
        throw("工程名称不能为空！")
      unless @app_dir = @app_path.getText().trim()
        throw("工程路径不能为空！")

      atom.config.set emp.EMP_TEMP_WIZARD_NAME, @app_name
      atom.config.set emp.EMP_TEMP_WIZARD_PATH, @app_dir
      if @app_port_text = @app_port.getText().trim()
        atom.config.set emp.EMP_TEMP_WIZARD_PORT, @app_port_text
      else
        @app_port_text = @default_app_port


      if @app_aport_text = @app_aport.getText().trim()
        atom.config.set emp.EMP_TEMP_WIZARD_APORT, @app_aport_text
      else
        @app_aport_text = @default_app_aport

      console.log  @app_name

      @mk_app_dir(@app_dir, @app_name)
      # console.log  "111111"
      emp.show_info("创建app 完成~")
      # console.log  "222222"
      atom.open options =
        pathsToOpen: [@app_dir]
        devMode: false

      # atom.workspaceView.trigger 'core:close'
      atom.workspace.destroyActivePaneItem()
    catch e
      console.error e
      emp.show_error(e)

  mk_app_dir:(app_path, app_name) ->
    base_name = path.basename(app_path)
    to_path = ''
    if base_name is app_name
      emp.mk_dirs_sync(app_path)
      to_path = app_path
      @app_dir = to_path
    else
      to_path = path.join(app_path, app_name)
      emp.mk_dirs_sync(to_path)
      @app_dir = to_path

    # console.log re
    basic_dir = path.join __dirname, '../../', emp.STATIC_APP_FRONT_TEMP, @app_version
    @copy_template(to_path, basic_dir)
    console.log to_path
    app_file = path.join to_path,emp.DEF_APP_FILE
    port_file = path.join to_path, emp.DEF_PORT_FILE
    aport_file = path.join to_path, emp.DEF_APORT_FILE
    fs.writeFileSync app_file, @app_name
    fs.writeFileSync port_file, @app_port_text
    fs.writeFileSync aport_file, @app_aport_text




  copy_template: (to_path, basic_dir)->
    # console.log "copy  template`````--------"
    # console.log to_path
    # console.log basic_dir
    files = fs.readdirSync(basic_dir)
    for template in files
      f_path = path.join basic_dir, template
      t_path = path.join to_path, template
      if fs.lstatSync(f_path).isDirectory()
        emp.mkdir_sync(t_path)
        @copy_template(t_path, f_path)
      else
        @copy_content(t_path, f_path)


  copy_content: (t_path, f_path)->
    f_name = path.basename f_path
    f_con = fs.readFileSync f_path
    fs.writeFileSync t_path, f_con
