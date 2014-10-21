{$, $$, ScrollView} = require 'atom'
remote = require 'remote'
dialog = remote.require 'dialog'
fs = require 'fs'
path = require 'path'
EmpEditView = require '../channel_view/item-editor-view'
emp = require '../exports/emp'

module.exports =
class EmpAppWizardView extends ScrollView

  app_version:'5.3'
  app_name:''
  app_dir:''
  ewp_dir:''
  default_app_path:''
  default_ewp_path:'/usr/local/lib/ewp'


  @content: ->
    @div class: 'emp-app-wizard pane-item', tabindex: -1, =>
      @div class:'wizard-panels', =>
      #   @div outlet:"emp_logo", class: 'atom-banner'
        @div class: 'wizard-logo', outlet: 'wizard_logo', =>
          @div outlet:"emp_logo", class: 'atom-banner'
        @div class: 'detail-panels', =>
          @div class:'detail-ch-panels', =>
            @div class: 'block panels-heading icon icon-gear', "Create A Collection..."

            @div class:'detail-body', =>
              @div class:'detail-con', =>
                @div class:'info-div', =>
                  @label class: 'info-label', 'App名称*:'
                  @subview "app_name", new EmpEditView(attributes: {id: 'app_name', type: 'string'},  placeholderText: 'Application Name')

                @div class:'info-div', =>
                  @label class: 'info-label', 'App 路径*:'
                  @subview "app_path", new EmpEditView(attributes: {id: 'app_path', type: 'string'},  placeholderText: 'Application Path')
                  @button class: 'path-btn btn btn-info inline-block-tight', click:'select_apath',' Chose Path '

                @div class:'info-div', =>
                  @label class: 'info-label', 'EWP Path:'
                  @subview "ewp_path", new EmpEditView(attributes: {id: 'ewp_path', type: 'string'},  placeholderText: 'Ewp Path')
                  @button class: 'path-btn btn btn-info inline-block-tight', click:'select_epath',' Chose Path '

            @div class: 'footer-div', =>
              @div class: 'footer-detail', =>
                @button class: 'footer-btn btn btn-info inline-block-tight', click:'do_cancel','  Cancel  '
                @button class: 'footer-btn btn btn-info inline-block-tight', click:'do_submit',' Ok '


  initialize: ({@uri}={}) ->
    super
    # console.log "app wizard view"
    if @default_app_path = atom.config.get(emp.EMP_APP_WIZARD_APP_P)
      # console.log "exist"
      @app_path.getEditor().setText(@default_app_path)
    if tmp_ewp_path = atom.config.get(emp.EMP_APP_WIZARD_EWP_P)
      # console.log "exist ewp"
      @default_ewp_path = tmp_ewp_path
      @ewp_path.getEditor().setText(@default_ewp_path)
    else
      @ewp_path.getEditor().setText(@default_ewp_path)

  select_apath: (e, element)->
    tmp_path = @app_path.getEditor().getText()
    @promptForPath(@app_path, tmp_path)

  select_epath: (e, element)->
    tmp_path = @ewp_path.getEditor().getText()
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
      console.log new_path
      fa_view.getEditor().setText(new_path[0])


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

  toggle: ->
    # console.log "EmpChannelWizardView was toggled!"
    if @hasParent()
      @detach()
    # else
      atom.workspaceView.append(this)
      # @add_new_panel()
      # @parse_conf()
  focus: ->
    super
    @app_name.focus()

  getUri: ->
    @uri

  getTitle: ->
    "Create An Emp App Wizard"

  isEqual: (other) ->
    other instanceof EmpChannelWizardView

  refresh_view:(@all_objs) ->
    @remove_loading()

  remove_loading: ->
    @loadingElement.remove()

  do_cancel: ->
    # console.log "do_submit "
    atom.workspaceView.trigger 'core:close'

  do_submit: ->
    # console.log "do cancel"
    try
      unless @app_name = @app_name.getEditor().getText().trim()
        throw("工程名称不能为空！")
      unless @app_dir = @app_path.getEditor().getText().trim()
        throw("工程路径不能为空！")
      atom.config.set(emp.EMP_APP_WIZARD_APP_P, @app_dir)
      if @ewp_dir = @ewp_path.getEditor().getText().trim()
        atom.config.set(emp.EMP_APP_WIZARD_EWP_P, @ewp_dir)

      @mk_app_dir(@app_dir, @app_name)
      emp.show_info("创建app 完成~")
      atom.open options =
        pathsToOpen: [@app_dir]
        devMode: true

      atom.workspaceView.trigger 'core:close'
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
    basic_dir = path.join __dirname, '../../', emp.STATIC_APP_TEMPLATE, @app_version
    @copy_template(to_path, basic_dir)

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
    map = [{'k':/\$\{app\}/ig,'v':@app_name}, {'k':/\$\{ecl_ewp\}/ig,'v':@ewp_dir}]
    for o in map
      if o.v
        str = str.replace(o.k, o.v)
    str

  copy_content: (t_path, f_path)->
    f_name = path.basename f_path
    f_con = fs.readFileSync f_path, 'utf8'
    nf_con = @string_replace(f_con)
    fs.writeFileSync(t_path, nf_con, 'utf8')
    if f_name is 'iewp' or f_name is 'configure'
      fs.chmodSync(t_path, 493);
