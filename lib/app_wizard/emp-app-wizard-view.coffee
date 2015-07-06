{$, $$, ScrollView, TextEditorView} = require 'atom-space-pen-views'
remote = require 'remote'
dialog = remote.require 'dialog'
fs = require 'fs'
path = require 'path'
# EmpEditView = require '../channel_view/item-editor-view'
emp = require '../exports/emp'

module.exports =
class EmpAppWizardView extends ScrollView

  app_version:'5.3'
  app_name:''
  app_dir:''
  ewp_dir:''
  default_app_path:''
  default_ewp_path:'/usr/local/lib/ewp'

  default_app_port:'4002'
  default_app_aport:'4000'


  @content: ->
    @div class: 'emp-app-wizard pane-item', tabindex: -1, =>
      @div class:'wizard-panels', =>
      #   @div outlet:"emp_logo", class: 'atom-banner'
        @div class: 'wizard-logo', outlet: 'wizard_logo', =>
          @div outlet:"emp_logo", class: 'atom-banner'
        @div class: 'detail-panels', =>
          @div class:'detail-ch-panels', =>
            @div class: 'block panels-heading icon icon-gear', "Create A Application..."

            @div class:'detail-body', =>
              @div class:'detail-con', =>
                @div class:'info-div', =>
                  @label class: 'info-label', 'App Name*:'
                  @subview "app_name_editor", new TextEditorView(mini: true,attributes: {id: 'app_name', type: 'string'},  placeholderText: 'Application Name')

                @div class:'info-div', =>
                  @label class: 'info-label', 'App Path*:'
                  @subview "app_path", new TextEditorView(mini: true,attributes: {id: 'app_path', type: 'string'},  placeholderText: 'Application Path')
                  @button class: 'path-btn btn btn-info inline-block-tight', click:'select_apath',' Chose Path '

                @div class:'info-div', =>
                  @label class: 'info-label', 'EWP Path: (建议不要为空否则需要手动修改configure,iewp,yaws.conf 文件)'
                  @subview "ewp_path", new TextEditorView(mini: true,attributes: {id: 'ewp_path', type: 'string'},  placeholderText: 'Ewp Path')
                  @button class: 'path-btn btn btn-info inline-block-tight', click:'select_epath',' Chose Path '

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
    if @default_app_path = atom.config.get(emp.EMP_APP_WIZARD_APP_P)
      # console.log "exist"
      @app_path.setText(@default_app_path)
    if tmp_ewp_path = atom.config.get(emp.EMP_APP_WIZARD_EWP_P)
      # console.log "exist ewp"
      @default_ewp_path = tmp_ewp_path
      @ewp_path.setText(@default_ewp_path)
    else
      @ewp_path.setText(@default_ewp_path)
    # @focus()

    if !tmp_app_port = atom.config.get emp.EMP_TEMP_WIZARD_PORT
      tmp_app_port = @default_app_port
    @app_port.setText tmp_app_port

    if !tmp_app_aport = atom.config.get emp.EMP_TEMP_WIZARD_APORT
      tmp_app_aport = @default_app_aport
    @app_aport.setText tmp_app_aport

  select_apath: (e, element)->
    tmp_path = @app_path.getText()
    @promptForPath(@app_path, tmp_path)

  select_epath: (e, element)->
    tmp_path = @ewp_path.getText()
    @promptForPath(@ewp_path, tmp_path)

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
    @app_name_editor.focus()

  getUri: ->
    @uri

  getTitle: ->
    "Create An EMP App Wizard"

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
      atom.config.set(emp.EMP_APP_WIZARD_APP_P, @app_dir)
      if @ewp_dir = @ewp_path.getText().trim()
        atom.config.set(emp.EMP_APP_WIZARD_EWP_P, @ewp_dir)
      else
        @ewp_dir = ""
      console.log  @app_name
      atom.config.set(emp.EMP_TMPORARY_APP_NAME, @app_name)

      if @app_port_text = @app_port.getText().trim()
        atom.config.set emp.EMP_TEMP_WIZARD_PORT, @app_port_text
      else
        @app_port_text = @default_app_port


      if @app_aport_text = @app_aport.getText().trim()
        atom.config.set emp.EMP_TEMP_WIZARD_APORT, @app_aport_text
      else
        @app_aport_text = @default_app_aport




      @mk_app_dir(@app_dir, @app_name)
      # console.log  "111111"
      emp.show_info("创建app 完成~")
      # console.log  "222222"
      atom.open options =
        pathsToOpen: [@app_dir]
        devMode: false

      # atom.workspace.trigger 'core:close'
      atom.workspace.destroyActivePaneItem()
    catch e
      console.error e
      emp.show_error("创建 App 失败!")

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
    basic_dir = path.join __dirname, '../../', emp.STATIC_APP_TEMPLATE, @app_version
    @copy_template(to_path, basic_dir)

    @copy_css_ui(to_path)

    front_path = path.join  to_path, '/public'
    if fs.existsSync front_path
      app_file = path.join front_path,emp.DEF_APP_FILE
      port_file = path.join front_path, emp.DEF_PORT_FILE
      aport_file = path.join front_path, emp.DEF_APORT_FILE
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
      t_path = path.join to_path, @string_replace(template)
      if fs.lstatSync(f_path).isDirectory()
        emp.mkdir_sync(t_path)
        @copy_template(t_path, f_path)
      else
        @copy_content(t_path, f_path)


  string_replace: (str) ->
    map = [{'k':/\$\{app\}/ig,'v':@app_name}, {'k':/\$\{ecl_ewp\}/ig,'v':@ewp_dir},
          {'k':/\$\{server_port\}/ig,'v':@app_port_text},{'k':/\$\{console_port\}/ig,'v':@app_aport_text}]
    for o in map
      str = str.replace(o.k, o.v)
    str

  copy_content: (t_path, f_path)->
    f_name = path.basename f_path
    f_con = fs.readFileSync f_path, 'utf8'
    nf_con = @string_replace(f_con)
    fs.writeFileSync(t_path, nf_con, 'utf8')
    if f_name is 'iewp' or f_name is 'configure' or f_name is 'simulator'
      tmp_os = emp.get_emp_os()
      if tmp_os is emp.OS_DARWIN or tmp_os is emp.OS_LINUX
        fs.chmodSync(t_path, 493);

  copy_css_ui: (to_path) ->
    # console.log "  ------ ----- "
    basic_dir = path.join __dirname, '../../', emp.STATIC_UI_CSS_TEMPLATE
    dest_path = path.join to_path, emp.STATIC_UI_CSS_TEMPLATE_DEST_PATH
    css_con = fs.readFileSync basic_dir, 'utf8'
    tmp_dest_path = path.dirname dest_path
    if !fs.existsSync tmp_dest_path
      emp.mkdir_sync_safe tmp_dest_path
    fs.writeFileSync(dest_path, css_con, 'utf8')
