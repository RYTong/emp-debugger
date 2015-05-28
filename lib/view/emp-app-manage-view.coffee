{$, $$, View} = require 'atom'
{TextEditorView} = require 'atom-space-pen-views'
# EmpEditView = require './emp-edit-view'
EmpAppNodeView = require '../app_wizard/emp-debugger-app-node-view'
EmpChaManaView = require '../channel_view/emp-channel-manage-view'
EmpAppMan = require '../emp_app/emp_app_manage'
EmpAppWizardView = require '../app_wizard/emp-debugger-app-wizard-view'
EmpAdpPackageView = require '../package/emp-debugger-adapter-package-view'
EmpTempWizardView = require '../temp_wizard/emp-debugger-temp-wizard-view'

os = require 'os'
emp = require '../exports/emp'

# path = require 'path'
# path_fliter = require '../util/path-loader'
# relate_view = require './emp-relate-view'
# tmp_result = ''

module.exports =
class EmpAppManaView extends View
  emp_app_stat_view:null
  emp_app_manage: null
  emp_app_wizard: null
  emp_node_view: null
  app_state_show: "#66FF33"
  app_state_close: "#FF1919"
  app_state_dis: "#FF6600"

  @content: ->
    # console.log 'constructor'
    @div outlet:"emp_app_view", class:'emp-setting-server', =>
      @div outlet: 'app_detail', class: 'emp-setting-row-app', =>
        @div class: "emp-setting-con panel-body padded", =>
          @div class: "block conf-heading icon icon-gear", "App Management"

        @div outlet:"emp_node_type", class: "emp-setting-btn-head ",  =>
          @div class: "btn-group ", =>
            @button outlet:"btn_show_local", class: 'btn selected', click: 'show_local', "Start Local App"
            @button outlet:"btn_show_node", class: 'btn', click: 'show_node', "Connect Remote Node"

        @div outlet:"app_local_view", class:"setting_local_view", =>
          @div class: "emp-setting-con panel-body padded", =>
            @label class: "emp-setting-label", "App State   : "
            @label outlet:"emp_app_st", class: "emp-label-content", style: "color:#FF1919;", "Close"
            @span outlet:"emp_app_load", class: 'loading loading-spinner-small inline-block',style:"display:none;"

          @div outlet:"emp_conmiunication_pane", class: "emp-setting-con panel-body padded", =>
            @label class: "emp-setting-label", "Erl source"
            @div class: 'controls', =>
              @div class: 'setting-editor-container', =>
                @subview "emp_app_erl", new TextEditorView(mini: true, attributes: {id: 'emp_erl', type: 'string'},  placeholderText: 'Erlang Source') #fr
            @button outlet:"btn_run", class: 'btn btn-else btn-info inline-block-tight', click: 'run_erl', "Run Erl Term"

          @div outlet:"emp_app_btns", class: "emp-setting-btn-else ",  =>
            @button outlet:"btn_run_app", class: 'btn btn-else btn-success inline-block-tight', click: 'run_app', "Start App"
            @button outlet:"btn_stop_app", class: 'btn btn-else btn-error inline-block-tight', click: 'stop_app', "Stop App"
            @button outlet:"btn_conf_app", class: 'btn btn-else btn-warning inline-block-tight', click: 'conf_app', "Config App"
            @button outlet:"btn_make_app", class: 'btn btn-else btn-warning inline-block-tight', click: 'make_app', "Make App"
            @button outlet:"btn_c_make", class: 'btn btn-else btn-warning inline-block-tight', click: 'make_app_runtime', "C_App"
            @button outlet:"btn_import_app", class: 'btn btn-else btn-info inline-block-tight',click: 'import_menu', "Import Menu"
            # @button outlet:"btn_do_test", class: 'btn btn-else btn-info inline-block-tight',click: 'do_test1', "Do test"

  initialize: ->
    # unless os.platform().toLowerCase() isnt OS_DARWIN
    @emp_app_manage = new EmpAppMan(this)
    @emp_node_view = new EmpAppNodeView(this, @emp_app_manage)
    @emp_cha_manage = new EmpChaManaView(this)
    @emp_app_wizard = new EmpAppWizardView(this)
    @emp_temp_wizard = new EmpTempWizardView(this)
    @emp_adp_package = new EmpAdpPackageView(this)

    @app_local_view.after(@emp_node_view)
    @app_detail.after(@emp_adp_package)
    @app_detail.after(@emp_cha_manage)
    @app_detail.after @emp_temp_wizard
    @app_detail.after(@emp_app_wizard)


    # path_fliter.load_path "public/www/resource_dev", "m1.xhtml", null, (result) ->
    #   # console.log result
    #   tmp_result = result

    this

  focus: ->
    @emp_app_erl.focus()

  check_os: ->
    # add linux type
    tmp_os = emp.get_emp_os()
    # tmp_os = "win32"  #comment this
    # console.log tmp_os
    if tmp_os isnt emp.OS_DARWIN and tmp_os isnt emp.OS_LINUX
      # @btn_show_local.disable()
      # @btn_show_node.disable()
      @emp_node_type.hide()
      @show_node()

      # unless @emp_app_erl.isDisabled()
      #   # console.log "1--------"
      #   @emp_app_erl.disable()
      # unless @emp_app_btns.isDisabled()
      #   @emp_app_btns.disable()
      # unless @btn_run.isDisabled()
      #   @btn_run.disable()
      #   for btn in @emp_app_btns.children()
      #     child = $(btn)
      #     child.disable()
      #   @show_disable()
      # unless @btn_run_app.isDisabled()
      #   @btn_run_app.disable()
      # unless @btn_stop_app.isDisabled()
      #   @btn_stop_app.disable()
      # unless @btn_conf_app.isDisabled()
      #   @btn_conf_app.disable()
      # unless @btn_make_app.isDisabled()
      #   @btn_make_app.disable()
    else
      @btn_import_app.disable()
      @btn_run.disable()
      @btn_c_make.disable()

  # do_test1: ->
  #   console.log "this is a test1"
  #   # console.log atom.project.getDirectories()
  #   # console.log atom.project.resolve("lib/test")
  #   # root_dir = atom.project.getDirectories()[0]
  #   dir = "public/www/resource_dev"
  #   # console.log root_dir.isDirectory(dir)
  #   # console.log root_dir.getSubdirectory(dir)
  #   # entries = root_dir.getSubdirectory(dir).getEntriesSync()
  #
  #   @path_view = new relate_view("", "", "", [], tmp_result)

  do_test: ->
    #
    console.log "this is a test"
    tmp_path = atom.project.getPath()
    console.log tmp_path
    path = require 'path'
    tmp_dile_path = path.join tmp_path, "test.xhtml"
    console.log tmp_dile_path
    fs = require 'fs'
    re = fs.readFileSync tmp_dile_path,'utf8'
    console.log re
    # atom.open({pathsToOpen: [tmp_dile_path], newWindow: false})
    changeFocus = true
    atom.workspaceView.open(tmp_dile_path, { changeFocus })


  # -------------------------------------------------------------------------
  # btn callback for app setting
  show_local: ->
    console.log "show_local"
    @btn_show_node.removeClass("selected")
    @btn_show_local.addClass("selected")
    @emp_node_view.hide()
    @app_local_view.show()



  show_node: ->
    console.log "show_node"
    @btn_show_node.addClass("selected")
    @btn_show_local.removeClass("selected")
    @app_local_view.hide()
    @emp_node_view.show()

  run_erl: ->
    erl_str = @emp_app_erl.getText()
    @emp_app_manage.run_erl(erl_str)


  run_app: ->
    # @show_loading()
    @emp_app_manage.run_app()
    @refresh_app_st()
    # @hide_loading()

  stop_app: ->
    @show_loading()
    @emp_app_manage.stop_app()
    @refresh_app_st()
    @hide_loading()

  conf_app: ->
    @show_loading()
    @emp_app_manage.config_app()
    # @hide_loading()

  make_app: ->
    @show_loading()
    @emp_app_manage.make_app()
    # @hide_loading()

  make_app_runtime: ->
    @emp_app_manage.make_app_runtime()

  import_menu: ->
    @emp_app_manage.import_menu()


  refresh_app_st: (app_st)->
    # console.log "refresh_app_st -- "
    # console.log @emp_app_manage.get_app_state()
    app_st ?= atom.project.emp_app_state
    # console.log atom.project.emp_app_state
    # console.log "refresh_app_st --#{app_st}"
    app_st_str = null
    app_css = null
    if app_st
      app_st_str =  "Running"
      app_css_style = @app_state_show
      @btn_import_app.enable()
      @btn_c_make.enable()
      @btn_run.enable()
    else
      app_st_str =  "Closed"
      app_css_style = @app_state_close
      @btn_import_app.disable()
      @btn_c_make.disable()
      @btn_run.disable()
    @emp_app_st.context.innerHTML = app_st_str
    @emp_app_st.css('color', app_css_style)

  show_disable: ->
    @emp_app_st.context.innerHTML = "Disable"
    @emp_app_st.css('color', @app_state_dis)

  show_loading: ->
    @emp_app_load.show()

  hide_loading: ->
    @emp_app_load.hide()
# -------------------------------------------------------------------------
