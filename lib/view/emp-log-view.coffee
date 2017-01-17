{Disposable, CompositeDisposable, Emitter} = require 'atom'
{$, $$, View, TextEditorView} = require 'atom-space-pen-views'
EMPLog = require '../emp_log/emp_log'
EMPLogMaps = require '../emp_log/emp_log_map'

_ = require 'underscore-plus'
# default_client_id = 'All'
emp = require '../exports/emp'
default_history_length=30
iDefaultLv = "1"

lv_list = ["lua", "i", "w", "e"]
lv_lua = "lua"
lv_info = "i"
lv_warn = "w"
lv_error = "e"
lv_color = {lv_lua:"text-highlight",
lv_info:"text-info",
lv_warn:"text-warn",
lv_error:"text-error",
def:"text-highlight"
}
# - Lua：用“lua”表示。
# - 普通：用“i”表示。
# - 警告：用“w”表示。
# - 异常：用“e”表示。
lv_val_l = "1"
lv_val_cl = "2"
lv_val_lcl = "3"
lv_val_cli = "4"
lv_val_clw = "5"
lv_val_cle = "6"
lv_val_clie = "7"
lv_val_lcli = "8"
lv_val_lcle = "9"
lv_val_lclie = "10"

aGLogMap = [{key:"Only Lua",val:"1"},
          {key:"All Client",val: "2"},
          {key:"Lua & All Client",val:"3"},
          {key:"Client Info",val: "4"},
          {key:"Client Warning",val:"5"},
          {key:"Client Error",val: "6"},
          {key:"Client Info & Error",val:"7"},
          {key:"Lua & Info",val:"8"},
          {key:"Lua & Error",val:"9"},
          {key:"Lua & Info & Error",val:"10"}]

lv_unmap = {1:[lv_lua],
2:[lv_info, lv_warn, lv_error],
3:lv_list,
4:[lv_info],
5:[lv_warn],
6:[lv_error],
7:[lv_info, lv_error],
8:[lv_lua, lv_info],
9:[lv_lua, lv_error],
10:[lv_lua, lv_info, lv_error]
           }

# sDefFlag = ","

module.exports =
class EmpDebuggerLogView extends View
  emp_setting_view: null
  line_height: null
  line_number: null
  log_detail_height:null
  default_ln: null
  show_state: false # 当前 log pane 是否为显示状态
  stop_state: false
  sSelectClient: emp.EMP_DEF_CLIENT
  aFlagsList:["#", "#"]
  bLogRefrsh: false

  @content: ->
    @div class: 'emp-log-pane tool-panel pannel panel-bottom padding', =>
      @div outlet:'emp_head', class: 'emp_bar panel-heading padded', mousedown: 'resizeStarted', dblclick: 'resizeToMin',=>
        @span 'Lua Log: '

        @div class:'bar_div block', =>

          @button outlet:'showFindBtn', class: 'btn btn_right2  inline-block-tight ', click: 'show_find', 'Find in Log'
          @select outlet: "client_select",id: "client", class: "select_bar", style:"display:none;", =>
            @option value: 'All', "All"

          @span class: 'icon icon-gear icon-pointer span-else', title:"Log Setting", click: 'log_setting'
          @span class: 'icon icon-move-up icon-pointer span-else', title:"Move Up", click: 'move_up'
          @span class: 'icon icon-move-down icon-pointer span-else', title:"Move Down", click: 'move_down'
          # playback-pause
          # playback-play
          @span outlet:"btn_pause", class: 'icon icon-playback-pause icon-pointer span-else', title:"Pause Log", click: 'pause_log'
          @span class: 'icon icon-trashcan icon-pointer span-else', title:"Clear Log", click: 'clear_log'
          @span class: 'icon icon-x icon-pointer inline-block-tight span-right', title:"Hide Log Panel", click: 'hide_log_view'
      @div class: 'emp_footer panel-heading padded',outlet:'setting_div',style:"display:none;", =>
        @ul class:'foot_ul', =>
          # @li class:'foot_li', =>
          @li class:'foot_li_label', =>
            @label  "日志等级过滤:"
          @li class:'foot_li_sel', =>
            @select outlet: "lv_control", title:"Log Level", class: "select_bar"
        @ul class:'foot_ul', =>
          @li class:'foot_li_label', =>
            @label "日志行数限制:"
          @li class:'foot_li_sel', =>
            @select outlet: "line_control", title:"Log Line Limit", class: "select_bar"
        @ul class:'foot_ul', =>
          @li class:'foot_li_label', =>
            @label "有新日志时,显示最新:"
          # @li class:'foot_li_sel', =>
          #   @select outlet: "line_control", title:"Log Line Limit", class: "select_bar"
          @li class:'foot_li_find', =>
            @input outlet:'doScrollBottom', class:'input-checkbox', type:'checkbox', checked:'true', click:'do_scroll_bottom'
            @span class:"span_filter", "Scroll To Bottom"
      @div class: 'emp_footer panel-heading padded',outlet:'find_div',style:"display:none;", =>
        @ul class:'foot_ul', =>
          @li class:'foot_li_find_lf', =>
            @subview 'log_find', new TextEditorView(mini: true, attributes: {id: 'log_find', type: 'string'},  placeholderText: 'Find in Logs')
          @li class:'foot_rf_li', =>
            @button outlet:'doFindBtn', class: 'btn btn_top inline-block-tight', click: 'do_find', 'Find'
          @li class:'foot_rf_li', =>
            @button outlet:'doFindPreBtn', class: 'btn btn_top inline-block-tight', click: 'do_find_pre', 'Previous'
          @li class:'foot_li_find', =>
            @input outlet:'showFilterRe', class:'input-checkbox', type:'checkbox', checked:'true', click:'show_filter'
            @span class:"span_filter", "Only Result"
      @div outlet:"emp_log_panel", class:'emp-log-panel',  =>
        @div outlet:"emp_log_view", id:'emp_log_view', class:'emp-log-view', =>
          @div outlet: 'emp_lineNumber', class: 'line-numbers'
          @div outlet: 'log_detail', id:'emp_log_row', class: 'emp-log-row native-key-bindings',tabindex: -1

      @div class: 'emp_footer panel-heading padded', =>
        @ul class:'foot_ul', =>
          @li class:'foot_li', =>
            @subview 'lua_console', new TextEditorView(mini: true, attributes: {id: 'lua_console', type: 'string'},  placeholderText: 'Lua Console')
          # @li class:'foot_lf_li', =>
          #   @button class: 'btn ', click: 'do_test', 'Test'
          #   @button class: 'btn ', click: 'do_stop', 'Stop'


  initialize: ()=>
    # @emitter = new Emitter()
    @oLogMaps = new EMPLogMaps()
    @line_number = 1
    @log_detail_height = 0
    @history = new Array()
    @history_index = 0
    @current_input = ""
    @sShowFilter = atom.config.get(emp.EMP_LOG_SHOW_FIND_RESULT)

    unless @sShowFilter
      @sShowFilter = true
    @showFilterRe.prop('checked', @sShowFilter) # 设置 checkbox 的状态

    @bDoScrollBottom = atom.config.get(emp.EMP_LOG_SCROLL_TO_BOTTOM)
    unless @bDoScrollBottom
      @bDoScrollBottom = true
      atom.config.set(emp.EMP_LOG_SCROLL_TO_BOTTOM, @bDoScrollBottom)
    @doScrollBottom.prop('checked', @bDoScrollBottom) # 设置 checkbox 的状态

    @disposable = new CompositeDisposable

    # 设置日志限制数列表,及默认限制数
    unless @log_line_limit = atom.config.get(emp.EMP_LOG_LINE_LIMIT)
      @log_line_limit = emp.EMP_DEF_LOG_LINE_LIMIT
    unless @def_line_limit_sel = atom.config.get(emp.EMP_LOG_LINE_LIMIT_SELECTED)
      @def_line_limit_sel = emp.EMP_DEF_LINE_LIMIT_SELECTED
      atom.config.set(emp.EMP_LOG_LINE_LIMIT_SELECTED, emp.EMP_DEF_LINE_LIMIT_SELECTED)

    # 设置默认行数
    for log_line in @log_line_limit
      if log_line is @def_line_limit_sel

        @line_control.append @new_select_option log_line, log_line
      else
        @line_control.append @new_option log_line, log_line

    # 记住用户的行数选择
    @line_control.change =>
      @sLineSelected = @line_control.val()
      atom.config.set(emp.EMP_LOG_LINE_LIMIT_SELECTED, @sLineSelected)

    # 设置默认日志类型
    # emp.EMP_LOG_TYPE_SELECTED
    unless @iDefLogLv = atom.config.get(emp.EMP_LOG_LEVEL_SELECTED)
      @iDefLogLv = iDefaultLv
      atom.config.set(emp.EMP_LOG_LEVEL_SELECTED, emp.iDefaultLv)
    # console.log @iDefLogLv
    for tmp_lv in aGLogMap
      lv_key = tmp_lv.key
      lv_val = tmp_lv.val
      if lv_val is @iDefLogLv
        @lv_selected = lv_val
        @lv_map_val = lv_unmap[@lv_selected]
        # console.log "select:",lv_key,lv_val
        @lv_control.append @new_select_option lv_key,lv_val
      else
        @lv_control.append @new_option lv_key,lv_val

    # 记住日志类型
    @lv_control.change =>
      @lv_selected = @lv_control.val()
      @lv_map_val = lv_unmap[@lv_selected]
      console.log @lv_selected
      atom.config.set(emp.EMP_LOG_LEVEL_SELECTED, @lv_selected)



    @disposable.add atom.commands.add "atom-workspace","emp-debugger:view-log", => @toggle()

    # console 发送 lua 日志
    @disposable.add atom.commands.add @lua_console.element, 'core:confirm', =>
      @do_send_lua()

    @disposable.add atom.commands.add @lua_console.element, 'core:move-up', =>
      # console.log "move-up"
      # console.log @history_index
      iTmpLen = @history.length
      if !@history_index
        @current_input = @lua_console.getText()
        @history_index = iTmpLen
        history_input = @history.slice @history_index-1, @history_index
        if history_input?[0]
          @lua_console.setText history_input[0]
      else if @history_index > 1
        @history_index = @history_index-1
        history_input = @history.slice @history_index-1, @history_index
        if history_input?[0]
          @lua_console.setText history_input[0]
      else
        history_input = @history.slice @history_index-1, @history_index
        if history_input?[0]
          @lua_console.setText history_input[0]

    @disposable.add atom.commands.add @lua_console.element, 'core:move-down', =>
      # console.log "move-down"
      # console.log @history_index
      if @history_index
        history_input = @history.slice @history_index, @history_index+1
        if history_input?[0]
          @lua_console.setText history_input?[0]
          @history_index = @history_index+1
        else
          @history_index = @history.length+1
          @lua_console.setText @current_input

    # @disposable.add
    @client_select.change =>
      @sSelectClient = @client_select.val()
      # console.log "client change"

    # 为 find log 添加按键时间
    @disposable.add atom.commands.add @log_find.element,
    'core:confirm': @do_find
    'core:cancel': @hide_find

    unless iMillSec = atom.config.get(emp.EMP_LOG_TIMER)
      iMillSec
    @iTimer = setInterval @timeInterVal, iMillSec
    # @test()

  dispose: ->
    @disposable?.dispose()
    clearInterval @iTimer
    @iTimer = null
    @panel = null


  serialize: ->
    attached: @hasParent()

  destroy: ->
    @detach()

  detach: ->
    @disposable?.dispose()
    @panel = null

  set_conf_view: (@emp_setting_view)->

  # -------------------------------------------------------------------------
  # call by command
  # initial log pane
  toggle: ->
    # console.log @first_show
    # if !@panel
    #   @attach()
    # else
    if this.isVisible()
      @hide_log_view()
    else
      @show_log()


  # do attach ---------
  attach: ->
    # atom.workspaceView.prependToBottom(this)
    @panel = atom.workspace.addBottomPanel(item:this,visible:true)
    @disposable.add new Disposable =>
      @panel.destroy()
      @panel = null
    @initial_height()

    # 刷新 line-height
    @get_line_height()

  initial_height: ->
    @get_line_height() unless @line_height
    @get_default_ln() unless @default_ln

  get_line_height: ->
    iTmpHeight = undefined
    oChildNode = @emp_lineNumber.context.children
    if oChildNode?.length > 0
      iTmpHeight = oChildNode[0].clientHeight
    if iTmpHeight isnt undefined
      @line_height = iTmpHeight
    else
      # @line_height = 18
      @line_height = 17

  get_default_ln: ->
    tmp_height = @emp_log_panel.css('height')
    if tmp_height isnt undefined
      @default_ln = Math.floor(@get_int(tmp_height) / @line_height)
    else
      @default_ln = 1

  # -------------------------------------------------------------------------
  # call by config vieww
  # show log pane
  show_log: ->
    # console.log "show_log"
    # console.log this
    unless @panel
      @attach()
      @emp_setting_view.show_log_callback()
      return
    if !this.isVisible()
      this.show()
    @emp_setting_view.show_log_callback()


  hide_log_view: ->
    # console.log "hide log"
    if this.isVisible()
      this.hide()
      @setting_div.hide()
    @emp_setting_view.hide_log_callback()
      # @show_state = false

  show_log_state: ->
    this.isVisible()

  # callback of btn
  show_find: ()=>
    # console.log "show log filter"
    if @find_div.isVisible()
      @hide_find()
    else
      @find_div.show()
      @showFindBtn.addClass("selected")
      @log_find.focus()

  oLogMsgsFindedArr:[]
  sPreFindLog:""

  hide_find: () =>

    @remove_find_flag()
    aLogViewArr = @log_detail.children()
    for oView in aLogViewArr
      vView = $(oView)
      unless vView.isVisible()
        vView.show()
    @find_div.hide()
    @showFindBtn.removeClass("selected")


  set_refresh_state:(bState) ->
    @refresh_find_state = bState

  # DOC jcfind 日志查找

  do_find:() =>
    @do_find_sequence(@find_next)

  do_find_sequence:(callback) =>
    sFindText = @log_find.getText().trim()
    if sFindText isnt ""
      if sFindText isnt @sPreFindLog
        @remove_find_flag()
        @do_process_find(sFindText)
      else
        # console.log @refresh_find_state
        # 如果有新日志进入,则刷新查找结果
        if !@refresh_find_state
          callback()
        else
          @set_refresh_state(false)
          @remove_find_flag()
          @do_process_find(sFindText)
    else
      # @log_detail.empty()
      @remove_find_flag()
      aLogViewArr = @log_detail.children()
      for oView in aLogViewArr
        $(oView).show()
    @sPreFindLog = sFindText

  find_next:() =>
    iLen = @oLogMsgsFindedArr.length
    unless iLen <= 1
      vView = @oLogMsgsFindedArr.shift()
      @oLogMsgsFindedArr.push(vView)
      # console.log vView
      @emp_log_view.scrollTop(vView[0].offsetTop)

  # 回复日志的查找状态
  remove_find_flag:(oTmpView) ->
    for vView in @oLogMsgsFindedArr
      sNewStr = vView["context"]["orign_text_store"]
      # console.log sNewStr
      vView.html(sNewStr)
      vView["context"]["orign_text_store"] = undefined
      # vView.show()
    @oLogMsgsFindedArr = []

  do_process_find:(sFindText) ->
    # console.log "filter is :", @sShowFilter
    oFindReg = new RegExp sFindText, 'ig'
    # console.log @log_detail
    # console.log @log_detail.children()
    aLogViewArr = @log_detail.children()
    for oView in aLogViewArr
      # console.log oView
      vView = $(oView)
      sTmpLog = vView.html()
      # console.log sTmpLog
      if sTmpLog.match oFindReg
        @oLogMsgsFindedArr.push vView
        unless vView["context"]["orign_text_store"]
          vView["context"]["orign_text_store"] = sTmpLog
        sNewStr = sTmpLog.replace oFindReg, "<span class=\"emp_log_selected\">$&</span>"
        sNewStr = "<div>#{sNewStr}</div>"
        vView.html(sNewStr)
        vView.show()
      else
        # 如果不选择只显示结果, 则显示全部
        unless !@sShowFilter
          vView.hide()
    @find_next()

  # append_log_ex:(sClientID, aLogBuf)->
  #   return unless aLogBuf.length > 0
  #   sShowColor = @oLogMaps.get_log_col(sClientID)
  #   oTmpView =  $$ ->
  #     for oLog in aLogBuf
  #       sLogMsg = oLog.log
  #       sLogConColor = oLog.color
  #       for sTmpLog in sLogMsg.split("\n")
  #         if sTmpLog isnt "" and sTmpLog isnt " "
  #           @pre id:"log_#{sClientID}",class: "emp-log-con #{sLogConColor}",style:"color:#{sShowColor};padding:0px;", "<#{sClientID}>: #{sTmpLog}"
  #   @log_detail.append oTmpView

  do_find_pre:()=>
    @do_find_sequence(@find_pre)

  find_pre:() =>
    iLen = @oLogMsgsFindedArr.length
    unless iLen <= 1
      vView = @oLogMsgsFindedArr.pop()
      @oLogMsgsFindedArr.unshift(vView)
      @emp_log_view.scrollTop(vView[0].offsetTop)
    # aFindedLog = @oLogMaps.scan_in_buffer_pre(sFindText)

    # unless !aFindedLog
      # @emp_log_view.scrollTop(aFindedLog[0].offsetTop)

  do_scroll_bottom:()=>
    @bDoScrollBottom = @doScrollBottom.prop('checked')
    atom.config.set(emp.EMP_LOG_SCROLL_TO_BOTTOM, @bDoScrollBottom)

  # 是否只显示日志
  show_filter:() =>
    # @sShowFilter = true
    @sShowFilter = @showFilterRe.prop('checked')
    atom.config.set(emp.EMP_LOG_SHOW_FIND_RESULT, @sShowFilter)
    # console.log "show filter:", @sShowFilter
    if !@sShowFilter
      aLogViewArr = @log_detail.children()
      for oView in aLogViewArr
        $(oView).show()
    else
      aLogViewArr = @log_detail.children()
      for oView in aLogViewArr
        vView = $(oView)
        if !vView["context"]["orign_text_store"]
          $(oView).hide()

  move_up:() ->
    @emp_log_view.scrollToTop()

  move_down: () ->
    @emp_log_view.scrollToBottom()

  log_setting:() ->
    console.log "show log setting view "
    if @setting_div.isVisible()
      @setting_div.hide()
    else
      @setting_div.show()
      # pane_height = @get_int(@emp_log_panel.css('height'))
      # console.log "pane height:", pane_height
          # console.log "pane height: #{pane_height} ,lh: #{@line_height}"
      # Math.floor(pane_height/ @line_height)
      # @resizeToSpec()


    # @setting_div

  # callback
  # -------------------------------------------------------------------------
  # pause the log poutput
  stop_log: ->
    # console.log "stop_log"
    @stop_state = true

  continue_log: ->
    @stop_state = false

  get_pause_state: ->
    @stop_state

  pause_log: ->
    # @btn_pause.
    # console.log "stop_state is :", @stop_state
    if @stop_state
      @btn_pause.removeClass("icon-playback-play")
      @btn_pause.addClass("icon-playback-pause")
      @btn_pause.removeClass("text-warning")
    else
      @btn_pause.removeClass("icon-playback-pause")
      @btn_pause.addClass("icon-playback-play")
      @btn_pause.addClass("text-warning")
    # @stop_state = !@stop_state
    # console.log "stop_state is :", @stop_state
    # callback 重置 log 状态
    @emp_setting_view.pause_log()

  # -------------------------------------------------------------------------
  # jcclear clear log content in the log pane
  clear_log: ->
    # console.log 'clear_log'
    if @panel
      @log_detail.empty()
      @emp_lineNumber.empty()
    @oLogMsgsFindedArr =[]
    @sPreFindLog=""
    @bLogRefrsh = false
    @clear_store_log()


  # -------------------------------------------------------------------------
  #close and clear the log pane
  close_log_view: ->
    # console.log "close1"
    if @panel()
      @clear_log()
      @detach()
      @show_state = false
      @stop_state = false

  get_log_pane_state: ->
    if !@panel
      "Close"
    else
      if this.isVisible()
        if @stop_state
          "Pause"
        else
          "Show"
      else
        "Hide"

  client_connect: (sClientID)->
    # console.log @client_select
    oLog = @oLogMaps.new_log(sClientID)
    if @client_select?.children()?.length > 1
      vOPView = @new_option(sClientID, sClientID)
    else
      vOPView = @new_select_option(sClientID, sClientID)
      @sSelectClient = sClientID
    oLog.store_oView(vOPView)
    unless @client_select.isVisible()
      @client_select.show()
    @client_select.append vOPView

    # console.log '------------------'
    sShowInput = "########################## New Client:#{sClientID} ##########################"
    @store_log(sClientID, sShowInput)
    # console.log @client_select



  client_disconnect: (sClientID)->
    if @sSelectClient is sClientID
      @sSelectClient = emp.EMP_DEF_CLIENT
      @client_select.find("option[value=#{@sSelectClient}]").attr('selected', true)
    oLog = @oLogMaps.get_log(sClientID)
    oLog.remove_oView()
    @oLogMaps.remove_log(sClientID)


  new_option: (name, value=name)->
    $$ ->
      @option value: value, name

  new_select_option: (name, value=name) ->
    $$ ->
      @option selected:'select', value: value, name


  # set time interval
  refresh_find_state:false
  timeInterVal:() =>
    console.log "now is interval"

    # console.log @oLogBuffer
    # TODO 判断是否为暂停,等状态, 并清空缓存
    unless !@bLogRefrsh
      unless @panel
        @oLogBuffer = {}
        @oLogMaps.clear_log_buffer()
        return

      # unless this.isVisible()
      #   return

      unless !@stop_state
        return

      iStartLn = @get_line_number_count()
      # console.log "start line: #{iStartLn}, line:#{@line_number}"

      # 超过设定行数 清除日志
      if iStartLn > @sLineSelected
        @clear_log()

      if @sSelectClient isnt emp.EMP_DEF_CLIENT
        tmpLogBuf = @oLogMaps.get_log_buf(@sSelectClient)
        @bLogRefrsh = false
        if tmpLogBuf.length > 0
          @set_refresh_state(true)
          @append_log(@sSelectClient, tmpLogBuf)
          @append_ln()
          unless !@bDoScrollBottom
            @emp_log_view.scrollToBottom()
      else
        oLogMap = @oLogMaps.get_all_buf()
        @bLogRefrsh = false
        # console.log oLogMap
        bTmpFlag = true
        for sClientID , aLogBuf of oLogMap
          if aLogBuf.length > 0
            bTmpFlag = false
            @set_refresh_state(true)
            @append_log(sClientID, aLogBuf)
        unless bTmpFlag
          @append_ln()
          unless !@bDoScrollBottom
            @emp_log_view.scrollToBottom()
        # @oLogMaps.clear_log_buffer_by_limit(@sLineSelected)


    # @emp_log_view.scrollToBottom()
    # @update_log(sClientID, sLogMsg, sShowColor, log_con_color)
    # @update_gutter(sShowColor, start_color_ln, sClientID)

  append_log:(sClientID, aLogBuf)->
    # return unless aLogBuf.length > 0
    sShowColor = @oLogMaps.get_log_col(sClientID)
    oTmpView =  $$ ->
      @pre id:"log_#{sClientID}",class: "emp-log-con #{sLogConColor}",style:"color:#{sShowColor};padding:0px;", "<#{sClientID}>: ----------------------"
      for oLog in aLogBuf
        sLogMsg = oLog.log
        sLogConColor = oLog.color
        for sTmpLog in sLogMsg.split("\n")
          if sTmpLog isnt "" and sTmpLog isnt " "
              @pre id:"log_#{sClientID}",class: "emp-log-con #{sLogConColor}",style:"color:#{sShowColor};padding:0px;", "#{sTmpLog}"
    @log_detail.append oTmpView

  append_ln:()->
    # log_detail_height
    iStartLn = @get_line_number_start()
    iEndLn = @get_line_number_count()
    # console.log "end line: #{iStartLn}:#{iEndLn}"
    # iNowStartLn = @line_number+1

    if iEndLn >= iStartLn
      oGutterView = $$ ->
        for row in [iStartLn+1..iEndLn+1]
          @div class:"line-number line-number-#{row}", " #{row}"
      @emp_lineNumber.append(oGutterView)


  store_log: (sClientID, sLogMsg, sLogLv=emp.EMP_DEF_LOG_TYPE) ->
    # console.log client_id, log, log_lv
    @bLogRefrsh = true
    if !@stop_state
      # @store_log_buf(sClientID, sLogLv, sLogMsg)
      if (@sSelectClient is emp.EMP_DEF_CLIENT) or (@sSelectClient is sClientID)

        # TODO: 判断日志类型,根据筛选规则输出
        if lv_list.indexOf(sLogLv) >=0
          if @lv_map_val?.indexOf(sLogLv) < 0
            return
        sLvColor = lv_color[sLogLv]
        sLvColor ?= lv_color.def
        # oNewBuf = {lv:log_lv, log:log, color:sLogColor}
        @oLogMaps.store_log_buffer(sClientID, sLogLv, sLvColor, sLogMsg)


  store_new_log: (sClientID, oLog)->
    # console.log log_obj
    iLogLv = oLog.level.toLowerCase()
    sLog = emp.base64_decode oLog.message
    @store_log(sClientID, sLog, iLogLv)


  refresh_conf_view: (client_id, color)->
    # unless !emp_setting_view
    # console.log @emp_setting_view
    # @add_clients(client_id)
    @emp_setting_view.refresh_log_view(@oLogMaps, client_id, color) unless !@emp_setting_view


  get_line_number_count: ->
    pane_height = @get_int(@log_detail.css('height'))
    # console.log "pane height:"+pane_height
    # console.log "pane height: #{pane_height} ,lh: #{@line_height}"
    Math.floor(pane_height/ @line_height)

  get_line_number_start: ->
    pane_height = @get_int(@emp_lineNumber.css('height'))
    Math.floor(pane_height/ @line_height)

  get_int: (css) ->
    parseInt(css.split("px")[0])


  clear_store_log: ->
    @oLogMaps.clear_store_log()

  #-------------------------------------------------------------------------
  get_log_store: ->
    @oLogMaps


  # -------------------------------------------------------------------------
  #日志界面高度计算处理
  resizeStarted: ->
    $(document).on('mousemove', @resizeTreeView)
    $(document).on('mouseup', @resizeStopped)

  resizeStopped: ->
    $(document).off('mousemove', @resizeTreeView)
    $(document).off('mouseup', @resizeStopped)

  resizeTreeView: (e) =>
    {pageY, which} = e
    return @resizeStopped() unless which is 1
    height = $(document.body).height()-pageY

    return if height < 70
    @height(height)
    @emp_log_panel.css("max-height", height)

  resizeToMin: ->
    height = 70
    @height(height)
    @emp_log_panel.css("max-height", height)
    @emp_log_view.scrollToBottom()

  resizeToSpec: (iHeight)->
    iOrgHeight = 70
    iHeight = iHeight+iOrgHeight
    @height(iHeight)
    @emp_log_panel.css("max-height", iHeight)
    @emp_log_view.scrollToBottom()

  # -------------------------------------------------------------------------
  # -------------------------------------------------------------------------
  ## @doc  Lua console
  do_send_lua: ->
    sLuaCode = @lua_console.getText()?.trim()
    @do_show_in_console(sLuaCode)
    # lua_code = @format_code(lua_code)
    if @sSelectClient isnt emp.EMP_DEF_CLIENT
      @emp_socket_server.send_lua_console(sLuaCode, @sSelectClient)
    else
      @emp_socket_server.send_lua_console(sLuaCode)
    if @history.length >= default_history_length
      @history.shift()
    @history.push sLuaCode
    @history_index = 0
    @current_input = ""
    @lua_console.setText("")


  do_show_in_console: (sLuaCode) ->

    #  优先使用全局配色, 如果没有,则使用默认色
    unless sShowColor = atom.config.get(emp.EMP_LOG_GLOBAL_COLOR)
      sShowColor = emp.get_color()
    # console.log sShowColor
    # a="#{@text-color}"
    start_color_ln = @get_line_number_count()
    @log_detail.append $$ ->
      for sLog in sLuaCode.split("\n")
        # Console Input:
        if sLog isnt "" and sLog isnt " "
          @pre class: "emp-log-con text-highlight",style:"color:#{sShowColor};font-weight:bold;font-style:italic;padding:0px;", "> #{sLog}"
    @emp_log_view.scrollToBottom()

  set_socket_server: (@emp_socket_server) ->
  # -------------------------------------------------------------------------

  do_stop:() ->
    @client_disconnect("test")

  do_test: ->
    for i in [0..30]
      @do_test_pre("test")
    # @do_test_pre("asd11111")

  do_test_pre:(sClientID = "test") ->
    unless @oLogMaps.has_log(sClientID)
      @client_connect(sClientID)
    @test(sClientID)

  test: (sClientID="test")->
    @store_log(sClientID, "#ert#\nasdasd `    asda;")
    @store_log(sClientID, "#ert#------\nasdasd\n\n test functione longlonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglong---")
    @store_log(sClientID, "#ert1#------\nasdasd\n\n test longlonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglong msg")
    @store_log(sClientID, "#ert1#------\nasdasd\n\n test functione")
    @store_log(sClientID, "-\t-----\nasdasd\n\n test functione")
    @store_log(sClientID, "111111111111111------\nasdasd\n\n test functione")
    @store_log(sClientID, "2222222222222222#ert1#------\nasdasd\n\n test functione")
    @store_log(sClientID, "3333333333333333-\t-----\nasdasd\n\n test functione")
    @store_log(sClientID, "4444444444444444------\nasdasd\n\n test functione")
