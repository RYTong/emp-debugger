{$, $$, View, TextEditorView} = require 'atom'
# EmpEditView = require './emp-edit-view'
EmpAppMan = require '../emp_app/emp_app_manage'
os = require 'os'
emp = require '../exports/emp'

module.exports =
class EmpAppNodeView extends View
  fa_view: null
  emp_app_manage:null
  node_state_show: "#66FF33"
  node_state_close: "#FF1919"
  app_state_dis: "#FF6600"

  @content: ->
    @div outlet:"app_node_view", class:"setting_local_view", style:"display:none;", =>
      # @div class: "emp-setting-con panel-body padded", =>
      #   @label class: "emp-setting-label", "App State   : "
      #   @label outlet:"emp_app_st", class: "emp-label-content", style: "color:#FF1919;", "Unconnected"
      #   @span outlet:"emp_app_load", class: 'loading loading-spinner-small inline-block',style:"display:none;"

      @div outlet:"emp_node_pane", class: "emp-setting-con panel-body padded", =>
        @label class: "emp-setting-label", "Ewp Node"
        @div class: 'controls', =>
          @div class: 'setting-editor-container', =>
            @subview "emp_node_name", new TextEditorView(mini: true, attributes: {id: 'emp_node', type: 'string'},  placeholderText: 'Ewp Node') #fr
        @div class: 'controls', =>
          @div class: 'setting-editor-container', =>
            @subview "emp_node_cookie", new TextEditorView(mini: true, attributes: {id: 'emp_cookie', type: 'string'},  placeholderText: 'Ewp Node Cookie') #fr
        @button outlet:"btn_con_node", class: 'btn btn-else btn-info inline-block-tight', click: 'connect_node', "Connect"

      @div outlet:"emp_erl_pane", class: "emp-setting-con panel-body padded", style:"display:none;", =>
        @div class: "emp-set-div-content", =>
          @label class: "emp-setting-label", "App State   : "
          @label outlet:"emp_node_st", class: "emp-label-content", style: "color:#FF1919;", "Unconnected"
          @span outlet:"emp_app_load", class: 'loading loading-spinner-small inline-block',style:"display:none;"
        @div class: "emp-set-div-content-wb", =>
          @button outlet:"btn_dis_con", class: 'btn btn-else btn-info inline-block-tight', click: 'discon_node', "DisConnect"
          @button outlet:"btn_c_make", class: 'btn btn-else btn-warning inline-block-tight', click: 'make_app_runtime', "C_App"
          @button outlet:"btn_import_app", class: 'btn btn-else btn-info inline-block-tight',click: 'import_menu', "Import Menu"

        @div class: "emp-set-div-content", =>
          @label class: "emp-setting-label", "Erl source"
          @div class: 'controls', =>
            @div class: 'setting-editor-container', =>
              @subview "emp_node_erl", new TextEditorView(mini: true, attributes: {id: 'emp_erl', type: 'string'},  placeholderText: 'Erlang Source') #fr
        @button outlet:"btn_run_elr", class: 'btn btn-else btn-info inline-block-tight', click: 'run_erl', "Run Erl Term"


      # @div outlet:"emp_app_btns", class: "emp-setting-btn-else ",  =>
      #   @button outlet:"btn_run_app", class: 'btn btn-else btn-success inline-block-tight', click: 'run_app', "Start App"
      #   @button outlet:"btn_stop_app", class: 'btn btn-else btn-error inline-block-tight', click: 'stop_app', "Stop App"
      #   @button outlet:"btn_conf_app", class: 'btn btn-else btn-warning inline-block-tight', click: 'conf_app', "Config App"
      #   @button outlet:"btn_make_app", class: 'btn btn-else btn-warning inline-block-tight', click: 'make_app', "Make App"
      #   @button outlet:"btn_c_make", class: 'btn btn-else btn-warning inline-block-tight', click: 'make_app_runtime', "C_App"
      #   @button outlet:"btn_import_app", class: 'btn btn-else btn-info inline-block-tight',click: 'import_menu', "Import Menu"


  initialize: (@fa_view, @emp_app_manage)->
    # unless os.platform().toLowerCase() isnt OS_DARWIN

    tmp_node_name = atom.config.get(emp.EMP_NODE_NAME)
    tmp_node_cookie = atom.config.get(emp.EMP_NODE_COOKIE)
    if tmp_node_name
      @emp_node_name.getEditor().setText(tmp_node_name)
    else
      @emp_node_name.getEditor().setText(emp.EMP_NODE_NAME)

    if tmp_node_cookie
      @emp_node_cookie.getEditor().setText(tmp_node_cookie)
    else
      @emp_node_cookie.getEditor().setText(emp.EMP_NODE_COOKIE)

    this



  # -------------------------------------------------------------------------
  # btn callback for app setting
  connect_node: ->
    console.log "connect_node"
    try
      unless tmp_node_name = @emp_node_name.getEditor().getText().trim()
        throw("节点名称不能为空！可以通过 node(). 查看其他erlang shell节点名~")
      tmp_node_cookie = ''
      unless tmp_node_cookie = @emp_node_cookie.getEditor().getText().trim()
        tmp_node_cookie = emp.EMP_NODE_COOKIE
      @emp_app_manage.connect_node(tmp_node_name, tmp_node_cookie, this)

      atom.config.set(emp.EMP_NODE_NAME, tmp_node_name)
      atom.config.set(emp.EMP_NODE_COOKIE, tmp_node_cookie)
      # @emp_node_pane.hide()
      # @emp_erl_pane.show()
      @refresh_node_st()

    catch e
      console.log e
      emp.show_error(e)



  discon_node: ->
    console.log "discon_node"
    @emp_app_manage.disconnect_node()

    @emp_node_pane.show()
    @emp_erl_pane.hide()

  run_erl: ->
    console.log "run erl"
    erl_str = @emp_node_erl.getEditor().getText().trim()
    if erl_str
      console.log erl_str
    else
      console.log "nothing"
    @emp_app_manage.run_nerl(erl_str)

  make_app_runtime: ->
    @emp_app_manage.make_app_runtime_node()

  import_menu: ->
    @emp_app_manage.import_menu_node()


  refresh_node_st: (node_st)->
    # console.log "refresh_app_st -- "
    # console.log @emp_app_manage.get_app_state()
    node_st ?= atom.project.emp_node_state
    # console.log atom.project.emp_app_state
    # console.log "refresh_app_st --#{app_st}"
    node_st_str = null
    app_css = null
    if node_st
      node_st_str =  "Connecting"
      node_css_style = @node_state_show
      # @btn_import_app.enable()
      # @btn_c_make.enable()
      # @btn_run.enable()
      @emp_node_pane.hide()
      @emp_erl_pane.show()
    else
      node_st_str =  "Unconnected"
      node_css_style = @node_state_close
      @emp_node_pane.show()
      @emp_erl_pane.hide()
      # @btn_import_app.disable()
      # @btn_c_make.disable()
      # @btn_run.disable()
    @emp_node_st.context.innerHTML = node_st_str
    @emp_node_st.css('color', node_css_style)


  show_loading: ->
    @emp_app_load.show()

  hide_loading: ->
    @emp_app_load.hide()
# -------------------------------------------------------------------------
