{Disposable, CompositeDisposable} = require 'atom'
{$, $$, View,TextEditorView} = require 'atom-space-pen-views'
emp = require '../exports/emp'
# EmpEditView = require './emp-edit-view'
EmpAppMan = require '../emp_app/emp_app_manage'
EmpBarView = require './emp-setting-bar'
EmpAppManaView = require './emp-app-manage-view'
EmpSnippetsView = require '../debugger/emp_debugger_snippets_view'
# EmpAnalyzeView = require '../analyze/emp-project-ana-view'

PANE_DENUG = 'debug'
PANE_APP = 'emp'
EMP_DEBUG_HOST_KEY = 'emp-debugger.Emp-debugger-host'
EMP_DEBUG_PORT_KEY = 'emp-debugger.Emp-debugger-port'


module.exports =
class EmpDebuggerSettingView extends View
  emp_socket_server: null
  empDebuggerLogView: null
  app_view:null

  default_host: 'default'
  default_port: '7003'
  server_host: null
  server_port: null
  first_show: true
  show_state: false
  activ_pane: 'debug'

  log_state_pause: "#FF6600"
  log_state_show: "#66FF33"
  log_state_hide: "#666699"
  log_state_close: "#FF1919"

  default_name: 'default'
  default_color_value: '#FFFFFF'

  @content: ->
    # console.log 'constructor'
    @div class: 'emp-setting tool-panel',=>
      @div outlet:"emp_setting_panel", class:'emp-setting-panel', =>
        @div outlet:"emp_setting_view", class:'emp-setting-server',  =>
          # ------------------------ server setting pane ------------------------
          @div outlet: 'conf_detail', class: 'emp-setting-row-server', =>
            @div class: "emp-setting-con panel-body padded", =>
              @div class: "block conf-heading icon icon-gear", "Server Setting"

            # ------------------------ server conf pane ------------------------
            @div outlet:"emp_conf_pane", class: "emp-setting-con panel-body padded", =>
              @label class: "emp-setting-label", "Host "
              @div class: 'controls', =>
                @div class: 'setting-editor-container', =>
                  @subview 'emp_set_host', new TextEditorView(mini: true, attributes: {id: 'emp_host', type: 'string'},  placeholderText: 'Editor Server 监听的地址') #from editor view class
              @label class: "emp-setting-label", "Port "
              @div class: 'controls', =>
                @div class: 'setting-editor-container', =>
                  @subview 'emp_set_port', new TextEditorView(mini: true, attributes: {id: 'emp_port', type: 'string'}, placeholderText: '同Client交互的端口')
              @button class: 'btn btn-else btn-success inline-block-tight ', click: 'start_server', "Start Server"

            # ------------------------ server state pane ------------------------
            @div outlet:"emp_state_pane", class: "emp-setting-con panel-body padded", style:"display:none;", =>
              @div class: "emp-set-div-content", =>
                @label class: "emp-setting-label", "Server State   : "
                @label outlet:"emp_server_st", class: "emp-label-content", "--"

              @div class: "emp-set-div-content", =>
                @label class: "emp-setting-label", "Client Number: "
                @label outlet:"emp_cl_no", class: "emp-label-content", ""
              @button class: 'btn btn-else btn-error inline-block-tight', click: 'stop_server', "Stop Server"
              @div class: "emp-btn-group" ,=>
                @button class: 'btn btn-else btn-info inline-block-tight', click: 'live_preview', "Live Preview"
                @button class: 'btn btn-else btn-info inline-block-tight', click: 'show_enable_views', "Enable Views"
                @button class: 'btn btn-else btn-info inline-block-tight', click: 'show_enable_lua', "Enable Lua"
                @button class: 'btn btn-else btn-info inline-block-tight', click: 'clear_input_view', "Clear View"

      #     # ------------------------ log config pane ------------------------
          @div outlet: 'log_detail', class: 'emp-setting-row', =>
            @div class: "emp-setting-con panel-body padded", =>
              @div class: "block conf-heading icon icon-gear", "Log Setting"

            @div outlet:"emp_log_pane", class: "emp-setting-con panel-body padded", =>
              @div class: "emp-set-div-content", =>
                @label class: "emp-setting-label", "Log State   : "
                @label outlet:"emp_log_st", class: "emp-label-content", style: "color:#FF1919;", "Close"
              @div class: "emp-set-div-content", =>
                # @div class: "btn-group", =>
                @button outlet: "emp_showlog", class: 'btn btn-else btn-info inline-block-tight icon icon-link-external', click: 'show_log', "Show  Log"
                @button outlet: "emp_clearlog", class: 'btn btn-else btn-info inline-block-tight icon icon-trashcan', click: 'clear_log', "Clear Log"
                @button outlet: "emp_pauselog", class: 'btn btn-else btn-info inline-block-tight icon icon-playback-pause', click: 'pause_log', "Pause Log"
                @button outlet: "emp_closelog", class: 'btn btn-else btn-info inline-block-tight icon icon-squirrel', click: 'close_log', "Close Log"
                # @button outlet: "emp_closelog", class: 'btn btn-else btn-info inline-block-tight icon icon-squirrel', click: 'test_log', "test Log"
              @div class: "emp-set-div-content", =>
                @label class: "emp-setting-label", "ClientID: "
                @select outlet: "emp_client_list", class: "form-control", =>
                  @option outlet:'emp_default_client', value: "default","default"
                @label class: "emp-setting-label", "LogColor: "
                @select outlet: "emp_log_color_list", class: "form-control", =>
                  @option outlet:'emp_default_color', value: "default", selected:"selected", "default"

      @div class: 'emp-setting-footor', =>
        # @ul class:'eul' ,=>
        # @button outlet:"emp_footor_btn", class:'btn btn-info inline-block-tight', click: 'hide_setting_view', "Hide"
        @ul class:'eul' ,=>
          @li outlet:"emp_footor_btn", class:'eli curr',click: 'hide_setting_view', "Hide"



  initialize: (serializeState, @emp_socket_server, @empDebuggerLogView, @fa_view) ->
    # console.log 'server state view initial'
    bar_view = new EmpBarView(this)
    @user_set_color = "#000033"
    @emp_setting_panel.before(bar_view)

    # analyze_view = new EmpAnalyzeView(this)
    # @log_detail.after analyze_view
    #
    snippet_view = new EmpSnippetsView(this)
    @log_detail.after snippet_view


    @disposable = new CompositeDisposable
    @disposable.add atom.commands.add "atom-workspace","emp-debugger:setting-view", => @set_conf()
    @server_host = atom.config.get(EMP_DEBUG_HOST_KEY)
    @server_port = atom.config.get(EMP_DEBUG_PORT_KEY)

    @empDebuggerLogView.set_conf_view(this)
    @emp_socket_server.set_conf_view(this)
    @defailt_host = @emp_socket_server.get_default_host()
    @default_port = @emp_socket_server.get_default_port()

  do_test: ->
    # @on 'click', '.entry', (e) =>
    #   # This prevents accidental collapsing when a .entries element is the event target
    #   # return if e.target.classList.contains('entries')
    #
    #   @entryClicked(e) unless e.shiftKey or e.metaKey or e.ctrlKey

    @on 'mousedown', '.entry', (e) =>
      @onMouseDown(e)

    @on 'mousedown', '.emp-setting-panel', (e) => @resizeStarted(e)

  entryClicked: (e) ->
    entry = e.currentTarget
    isRecursive = e.altKey or false
    switch e.originalEvent?.detail ? 1
      when 1
        @selectEntry(entry)
        @openSelectedEntry(false) if entry instanceof FileView
        entry.toggleExpansion(isRecursive) if entry instanceof DirectoryView
      when 2
        if entry instanceof FileView
          @unfocus()
        else if DirectoryView
          entry.toggleExpansion(isRecursive)

    false

  resizeStarted: =>
    $(document).on('mousemove', @resizeTreeView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: =>
    $(document).off('mousemove', @resizeTreeView)
    $(document).off('mouseup', @resizeStopped)

  resizeTreeView: ({pageX, which}) =>
    return @resizeStopped() unless which is 1

    # if atom.config.get('tree-view.showOnRightSide')
    #   width = $(document.body).width() - pageX
    # else
    width = pageX
    @width(width)


  show_app: ->
    # console.log "fa show ~~"
    # console.log @app_view
    unless @activ_pane is PANE_APP
      @create_new_panel()
      @emp_setting_view.hide()

      @app_view.show()

      @app_view.focus()
      @activ_pane = PANE_APP

  show_debug: ->
    unless @activ_pane is PANE_DENUG
      unless !@app_view
        @app_view.hide()
      @emp_setting_view.show()
      @emp_setting_view.focus()
      @activ_pane = PANE_DENUG

  create_new_panel: ->
    unless @app_view
      @app_view = new EmpAppManaView(this)
      @emp_setting_view.before(@app_view)
      @app_view.check_os()
    @app_view

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    # attached: @panel?.isVisible()

  # Tear down any state and detach
  destroy: ->
    @detach()

  detach: ->
    @disposable?.dispose()

  set_conf: ->
    # console.log "panel visible:"
    # console.log @panel?.isVisible()
    if @first_show
      @first_show = false
      if @hasParent()
        @detach()
        @first_show = false
        @show_state = false
      else
        @attach()
        @show_state = true
    else
      if @show_state
        # @panel.hide()
        this.hide()
        @show_state = false
      else
        # @panel.show()
        this.show()
        @show_state = true


  attach: ->

    @panel = atom.workspace.addRightPanel(item:this,visible:true)
    # @panel = atom.workspaceView.appendToRight(this)
        # atom.workspaceView.prependToRight(this)

    @disposable.add new Disposable =>
      @panel.destroy()
      @panel = null
    @init_server_conf_pane()
    @init_server_conf()

  init_server_conf_pane: ->
    if @emp_socket_server.get_server_sate()
      @hide_conf_pane()
    else
      @hide_state_pane()
      # @conf_detail.html $$ ->
      #   @div class: "emp-setting-con panel-body padded", =>
      #     @div class: "block conf-heading icon icon-gear", "Server Setting"
      #
      #   # ------------------------ server conf pane ------------------------
      #   @div outlet:"emp_conf_pane", class: "emp-setting-con panel-body padded", =>
      #     @label class: "emp-setting-label", "Host "
      #     @div class: 'controls', =>
      #       @div class: 'setting-editor-container', =>
      #         @subview "emp_set_host", new TextEditorView(mini: true, attributes: {id: 'emp_host', type: 'string'},  placeholderText: 'Editor Server 监听的地址') #from editor view class
      #     @label class: "emp-setting-label", "Port "
      #     @div class: 'controls', =>
      #       @div class: 'setting-editor-container', =>
      #         @subview "emp_set_port", new TextEditorView(mini: true, attributes: {id: 'emp_port', type: 'string'}, placeholderText: '同Client交互的端口')
      #     @button class: 'btn btn-else btn-success inline-block-tight ', click: 'start_server', "Start Server"

  init_server_conf: ->
    @init_default_value()
    @init_server_listen()
    @init_log_color_value()
    @init_log_conf_listen()
    # console.log @test_o
    # @test_o.context.style.backgroundColor="#006666"
    # @test_o.css('color', "#CC3300")

  init_default_value: ->
    # console.log atom.config.get('emp-debugger.s_host')
    if @server_host is undefined
      @server_host = @default_host
      atom.config.set(EMP_DEBUG_HOST_KEY, @server_host)

    if @server_port is undefined
      @server_port = @default_port
      atom.config.set(EMP_DEBUG_PORT_KEY, @server_port)
    @emp_set_port.setText(@server_port)
    @emp_set_host.setText(@server_host)


  init_server_listen: ->
    # console.log @emp_set_port.getModel()
    @emp_set_port.getModel().onDidStopChanging =>
      tmp_port = @emp_set_port.getText()
      # console.log tmp_port
      if @server_port isnt tmp_port
        @server_port = tmp_port
        atom.config.set(EMP_DEBUG_PORT_KEY, @server_port)

    @emp_set_host.getModel().onDidStopChanging =>
      tmp_host = @emp_set_host.getText()
      # console.log tmp_host
      if @server_host isnt tmp_host
        @server_host = tmp_host
        atom.config.set(EMP_DEBUG_HOST_KEY, @server_host)

    # atom.config.set('emp-debugger.s_host', 'value')
    # atom.config.observe 'my-package.key', ->
    # console.log 'My configuration changed:', atom.config.get('my-package.key')

  init_log_color_value: ->
    @oLogMaps = @empDebuggerLogView.get_log_store()
    aAllLogMaps = @oLogMaps.get_all_log()
    for name, view_logs of aAllLogMaps
      # console.log name
      tmp_color = view_logs.get_color()
      tmp_id = view_logs.get_id()
      @emp_client_list.append(@create_option("client:#{tmp_id}", tmp_id))
    # 设置 log color 为全局记忆的颜色
    aDefaultColor = @get_log_default_color()
    sGolColor = atom.config.get(emp.EMP_LOG_GLOBAL_COLOR)
    for oCol in aDefaultColor
      if oCol.value is sGolColor
        sOption = @new_select_option(oCol.name, oCol.value)
        @emp_log_color_list.css('background-color', oCol.value)
      else
        sOption = @new_option(oCol.name, oCol.value)

      @emp_log_color_list.append(sOption)

  init_log_conf_listen: ->
    client_id = null
    @oLogMaps = @empDebuggerLogView.get_log_store()
    @emp_client_list.change =>
      console.log "client channge"
      client_id = @emp_client_list.val()
      console.log client_id
      if client_id isnt @default_name
        # console.log oLogMaps[client_id]
        # console.log @emp_default_color
        # @emp_default_color.context.selected = true
        @emp_default_color.attr('selected', true)
        unless !sTmpCol = @oLogMaps.get_log_col(client_id)
          @emp_log_color_list.css('background-color', sTmpCol)
          @emp_default_color.val(sTmpCol)
      else

        if glo_color = atom.config.get(emp.EMP_LOG_GLOBAL_COLOR)
          # console.log "option[val=#{glo_color}]"
          @emp_log_color_list.find("option[value=#{glo_color}]").attr('selected', true)
        else
          @emp_default_color.attr('selected', true)
          @emp_log_color_list.css('background-color', '')
          @emp_default_color.val("#{@default_name}")

    @emp_log_color_list.change =>
      console.log "color channge"
      client_id = @emp_client_list.val()
      sSelCol = @emp_log_color_list.val()
      console.log sSelCol

      if client_id is @default_name
        console.log "default id"

        # console.log sSelCol
        aAllLogMaps = @oLogMaps.get_all_log()
        if sSelCol isnt @default_name
          atom.config.set(emp.EMP_LOG_GLOBAL_COLOR, sSelCol)
          @emp_log_color_list.css('background-color', sSelCol)
          # atom.project.glo_color = sSelCol
          for cli_id, cli_view of aAllLogMaps
            cli_view.set_glo_color sSelCol
        else
          atom.config.set(emp.EMP_LOG_GLOBAL_COLOR, null)
          @emp_default_color.val("#{@default_name}")
          @emp_log_color_list.css('background-color', '')
          # atom.project.glo_color = null
          for cli_id, cli_view of aAllLogMaps
            cli_view.set_glo_color null

      else
        # console.log sSelCol
        if sSelCol isnt @default_name
          @emp_log_color_list.css('background-color', sSelCol)
          client_id = @emp_client_list.val()
          @oLogMaps.set_log_col(client_id, sSelCol)
          # @log_map[client_id].set_glo_color null
        else
          @oLogMaps.set_log_gol_col client_id, null
          @emp_log_color_list.css('background-color', @oLogMaps.get_log_col(client_id))

  refresh_log_view: (@oLogMaps, client_id, sTmpColor)->
    @emp_client_list.append(@create_option("client:#{client_id}", client_id))
    @emp_log_color_list.append(@create_else_option(sTmpColor))

  remove_client: (client_id) ->
    # console.log "remove: #{client_id}"
    @refresh_state_pane_ln()
    @remove_log_view(client_id)

  remove_log_view: (client_id)->
    # console.log @emp_client_list
    @emp_client_list.find("option[id=#{client_id}]").remove()
    select_client = @emp_client_list.val()
    console.log select_client
    console.log (select_client is client_id)
    if select_client is client_id
      @emp_default_client.attr('selected', true)
      @emp_default_color.attr('selected', true)
      @emp_log_color_list.css('background-color', @default_color_value)

  create_option: (name, value)->
    $$ -> @option id:"#{value}", value: value, name

  create_else_option: (color)->
    $$ -> @option style:"background-color:#{color};", value: color


  # -------------------------------------------------------------------------
  # view maintain
  hide_conf_pane: ->
    # console.log "call:hide_conf_pane"
    @emp_conf_pane.hide()
    @refresh_state_pane()
    @emp_state_pane.show()

  hide_state_pane: ->
    @emp_conf_pane.show()
    @emp_state_pane.hide()

  refresh_state_pane: ->
    if @emp_socket_server.get_server_sate()
      @emp_server_st["context"].innerHTML = "On"
      @emp_cl_no["context"].innerHTML=@emp_socket_server.get_client_map().get_active_len()

  refresh_state_pane_ln: ->
    if @emp_socket_server.get_server_sate()
      @emp_cl_no["context"].innerHTML=@emp_socket_server.get_client_map().get_active_len()

  # -------------------------------------------------------------------------
  # util fun
  # btn callback
  start_server: (event, element) ->
    # console.log element
    # console.log "port:#{@emp_server_port}"
    # console.log "host:#{@emp_server_host}"
    new_server_host = @server_host.trim()
    new_server_port = @server_port.trim()
    # console.log new_server_host
    # console.log new_server_port

    new_server_host = @default_host unless new_server_host isnt ''
    new_server_port = @default_port unless new_server_port isnt ''
    # console.log @emp_server_port
    new_server_port = @parseValue('number', new_server_port)
    console.log "local server start with option parameters: host: #{new_server_host}, port: #{new_server_port}"
    @emp_socket_server.init(new_server_host, new_server_port) unless @emp_socket_server.get_server() isnt null

  # btn callback
  stop_server: (event, element) ->
    @emp_socket_server.close()
    @hide_state_pane()


  # -------------------------------------------------------------------------
  #  btn for hide the setting view
  hide_setting_view: () ->
      this.hide()
      @show_state = false

  # -------------------------------------------------------------------------
  live_preview: ->
    console.log "live preview"
    @fa_view.live_preview()

  show_enable_views: ->
    console.log "show enable preview"
    @fa_view.show_enable_view()

  show_enable_lua: ->
    console.log "show enbale lua"
    @fa_view.show_enable_lua()

  # 清除 enable view 和 enable lua 的内容
  clear_input_view: ->
    @emp_socket_server.get_client_map().clear_all_views()
    console.info "清除 View 完成."
    emp.show_info "清除 View 完成."


  # btn callback for log setting
  show_log: ->
    # console.log "show_log"
    show_state = @empDebuggerLogView.show_log_state()
    if show_state
      @empDebuggerLogView.hide_log_view()
      # @emp_showlog.context.innerHTML = "Show Log"
      # @refresh_log_st(@log_state_hide)
    else
      @empDebuggerLogView.show_log()
      # @emp_showlog.context.innerHTML = "Hide Log"
      # @refresh_log_st(@log_state_show)

  show_log_callback: ->
    @emp_showlog.context.innerHTML = "Hide Log"
    @refresh_log_st(@log_state_show)

  hide_log_callback: ->
    @emp_showlog.context.innerHTML = "Show Log"
    @refresh_log_st(@log_state_hide)

  clear_log: ->
    # console.log "clear_log"
    @empDebuggerLogView.clear_log()

  pause_log: ->
    # console.log "stop_log"
    pause_state = @empDebuggerLogView.get_pause_state()
    if pause_state
      @empDebuggerLogView.continue_log()
      @emp_pauselog.context.innerHTML = "Pause Log"
      @refresh_log_st(@log_state_show)
    else
      @empDebuggerLogView.stop_log()
      @emp_pauselog.context.innerHTML = "Continue Log"
      @refresh_log_st(@log_state_pause)

  close_log: ->
    # console.log "close_log"
    @empDebuggerLogView.close_log_view()
    @refresh_log_st(@log_state_close)

  refresh_log_st: (css_style)->
    log_st_str = @empDebuggerLogView.get_log_pane_state()
    @emp_log_st.context.innerHTML = log_st_str
    @emp_log_st.css('color', css_style)
  # -------------------------------------------------------------------------

  valueToString: (value) ->
    if _.isArray(value)
      value.join(", ")
    else
      value?.toString()

  parseValue: (type, value) ->
    if value == ''
      value = undefined
    else if type == 'number'
      floatValue = parseFloat(value)
      value = floatValue unless isNaN(floatValue)
    else if type == 'array'
      arrayValue = (value or '').split(',')
      value = (val.trim() for val in arrayValue when val)
    value


  new_option: (name, value=name)->
    $$ ->
      @option value: value, name

  new_select_option: (name, value=name) ->
    $$ ->
      @option selected:'select', value: value, name


  get_log_default_color: ->
    return [{value: "#000033", name: "黑"},
            {value: "#FFFFFF", name: "白"},
            {value: "#FF0000", name: "红"},
            {value: "#FFFF33", name: "黄"},
            {value: "#0000FF", name: "蓝"},
            {value: "#00FF00", name: "绿"},
            {value: "#00FFFF", name: "青"},
            {value: "#FF6600", name: "橙"},
            {value: "#990099", name: "紫"}]
