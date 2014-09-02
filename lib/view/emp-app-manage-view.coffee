{$, $$, View} = require 'atom'
EmpEditView = require './emp-edit-view'
EmpAppMan = require '../emp_app/emp_app_manage'
os = require 'os'
OS_DARWIN = 'darwin'

module.exports =
class EmpAppManaView extends View
  emp_app_manage: null
  app_state_show: "#66FF33"
  app_state_close: "#FF1919"
  app_state_dis: "#FF6600"

  @content: ->
    # console.log 'constructor'
    @div outlet:"emp_app_view", class:'emp-setting-server', =>
      # @div outlet: 'emp_lineNumber', class: 'line-numbers'

      # ------------------------ server state pane ------------------------
      @div outlet: 'app_detail', class: 'emp-setting-row', =>
        @div class: "emp-setting-con panel-body padded", =>
          @div class: "block conf-heading icon icon-gear", "App Management"

        @div class: "emp-setting-con panel-body padded", =>
          @label class: "emp-setting-label", "App State   : "
          @label outlet:"emp_app_st", class: "emp-label-content", style: "color:#FF1919;", "Close"
          @span outlet:"emp_app_load", class: 'loading loading-spinner-small inline-block',style:"display:none;"
        @div outlet:"emp_conmiunication_pane", class: "emp-setting-con panel-body padded", =>

          @label class: "emp-setting-label", "Erl "
          @div class: 'controls', =>
            @div class: 'setting-editor-container', =>
              @subview "emp_app_erl", new EmpEditView(attributes: {id: 'emp_erl', type: 'string'},  placeholderText: 'Erlang') #fr
          @button outlet:"btn_r", class: 'btn btn-default ', click: 'run_erl', "Run Erl"


        @div outlet:"emp_app_btns", class: "emp-setting-con panel-body padded",  =>
          @button class: 'btn btn-default ', click: 'run_app', "Run App"
          @button class: 'btn btn-default ', click: 'stop_app', "Stop App"
          @button class: 'btn btn-default ', click: 'conf_app', "Config App"
          @button class: 'btn btn-default ', click: 'make_app', "Make App"

  initialize: ->
    # unless os.platform().toLowerCase() isnt OS_DARWIN
    @emp_app_manage = new EmpAppMan(this)
    this

  focus: ->
    @emp_app_erl.focus()

  check_os: ->
    # add linux type
    unless os.platform().toLowerCase() is OS_DARWIN
      unless @emp_app_erl.isDisabled()
        # console.log "1--------"
        @emp_app_erl.disable()
      unless @emp_app_btns.isDisabled()
        @emp_app_btns.disable()
      unless @btn_r.isDisabled()
        @btn_r.disable()
        for btn in @emp_app_btns.children()
          child = $(btn)
          child.disable()
        @show_disable()

  # -------------------------------------------------------------------------
  # btn callback for app setting

  run_erl: ->
    erl_str = @emp_app_erl.getEditor().getText()

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

  refresh_app_st: (app_st)->
    # console.log "refresh_app_st -- "
    # console.log @emp_app_manage.get_app_state()
    app_st ?= @emp_app_manage.get_app_state()
    # console.log "refresh_app_st --#{app_st}"
    app_st_str = null
    app_css = null
    if app_st
      app_st_str =  "Running"
      app_css_style = @app_state_show
    else
      app_st_str =  "Closed"
      app_css_style = @app_state_close
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
