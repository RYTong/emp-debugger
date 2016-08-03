{Disposable, CompositeDisposable} = require 'atom'
{$, $$, View, TextEditorView} = require 'atom-space-pen-views'
EMPLog = require '../emp_log/emp_log'
EMPLogMaps = require '../emp_log/emp_log_map'

_ = require 'underscore-plus'
default_client_id = 'All'
emp = require '../exports/emp'
default_history_length=30
default_lv = "1"

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

lv_map = [{key:"Only Lua",val:"1"},
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

sDefFlag = ","

module.exports =
class EmpDebuggerLogView extends View
  emp_conf_view: null
  line_height: null
  line_number: null
  default_ln: null
  # state: true      #
  first_show: true #是否为第一次显示
  show_state: false # 当前 log pane 是否为显示状态
  stop_state: false
  selected_client: default_client_id
  reFilterReg:new RegExp("#[^#]*#", "i")
  aFilterList:[]
  aFlagsList:["#", "#"]

  @content: ->
    @div class: 'emp-log-pane tool-panel pannel panel-bottom padding', =>
      # @div class: 'log-console-resize-handle', mousedown: 'resizeStarted', dblclick: 'resizeToMin'
      @div outlet:'emp_head', class: 'emp_bar panel-heading padded', mousedown: 'resizeStarted', dblclick: 'resizeToMin',=>
        @span 'Log From The Script Of Views: '


        @div class:'bar_div', =>
          @button outlet:'showFindBtn', class: 'btn btn_right2 inline-block-tight', click: 'show_find', 'Find'
          @button outlet:'showFilterBtn', class: 'btn btn_right2', click: 'show_filter', 'Show Filter'
          @select outlet: "lv_control", class: "select_bar"
          @select outlet: "line_control", class: "select_bar"
          @button class: 'btn btn_right2', click: 'clear_log', 'Clear'
          @button class: 'btn-warning btn  inline-block-tight btn_right', click: 'hide_log_view', 'Hide'

      @div class: 'emp_footer panel-heading padded',outlet:'filter_div',style:"display:none;", =>
        @ul class:'foot_ul', =>
          @li class:'foot_li', =>
            @subview 'log_filter', new TextEditorView(mini: true, attributes: {id: 'log_filter', type: 'string'},  placeholderText: 'Input Log Filter Flag')

      @div class: 'emp_footer panel-heading padded',outlet:'find_div',style:"display:none;", =>
        @ul class:'foot_ul', =>
          @li class:'foot_li', =>
            @subview 'log_find', new TextEditorView(mini: true, attributes: {id: 'log_find', type: 'string'},  placeholderText: 'Find in Logs')
          @li class:'foot_rf_li', =>
            @button outlet:'doFindBtn', class: 'btn btn_top inline-block-tight', click: 'do_find', 'Find'
          @li class:'foot_rf_li', =>
            @button outlet:'doFindPreBtn', class: 'btn btn_top inline-block-tight', click: 'do_find_pre', 'Previous'
            # @button outlet:'doFilterBtn1', class: 'btn btn_top inline-block-tight', click: 'do_find1', 'Find1'
          # @li class:'foot_rf_li', =>
          #   @div class:'btn-group', =>
          #     @button outlet:'doFilterBtn', class: 'btn btn_top', click: 'do_filter', 'DoFilter'
          #     @button outlet:'unFilterBtn', class: 'btn btn_top', click: 'un_filter', 'UnFilter'


      # @ul class: 'log-console list-group', outlet:'listView'
      @div outlet:"emp_log_panel", class:'emp-log-panel',  =>
        @div outlet:"emp_log_view", id:'emp_log_view', class:'emp-log-view', =>
          @div outlet: 'emp_lineNumber', class: 'line-numbers'
          @div outlet: 'log_detail', id:'emp_log_row', class: 'emp-log-row native-key-bindings',tabindex: -1

      @div class: 'emp_footer panel-heading padded', =>
        @ul class:'foot_ul', =>
          @li class:'foot_lf_li', =>
        # @div class:'foot_div', =>
            @select outlet:"client_select", id: "client", class: '', =>
              @option value: 'test', "test"
          @li class:'foot_li', =>
            @subview 'lua_console', new TextEditorView(mini: true, attributes: {id: 'lua_console', type: 'string'},  placeholderText: 'Lua Console')
          @li class:'foot_lf_li', =>
            @button class: 'btn ', click: 'do_test', 'Test'


  initialize: ()->
    @oLogMaps = new EMPLogMaps()
    @line_number = 1
    @history = new Array()
    @history_index = 0
    @current_input = ""
    @aFilterList=[]
    @disposable = new CompositeDisposable
    @log_line_limit = atom.config.get(emp.EMP_LOG_LINE_LIMIT)
    @def_line_limit_sel = atom.config.get(emp.EMP_LOG_LINE_LIMIT_SELECTED)
    if !@def_line_limit_sel
      @def_line_limit_sel = emp.EMP_DEF_LINE_LIMIT_SELECTED
      atom.config.set(emp.EMP_LOG_LINE_LIMIT_SELECTED, emp.EMP_DEF_LINE_LIMIT_SELECTED)

    @sDefFilterFlag = atom.config.get(emp.EMP_FILTER_FLAG)
    unless @sDefFilterFlag
      @sDefFilterFlag = sDefFlag

    if !@log_line_limit
      @log_line_limit = emp.EMP_DEF_LOG_LINE_LIMIT

    # 设置默认日志类型
    for tmp_lv in lv_map
      lv_key = tmp_lv.key
      lv_val = tmp_lv.val
      if lv_val is default_lv
        @lv_selected = lv_val
        @lv_map_val = lv_unmap[@lv_selected]
        @lv_control.append @new_select_option lv_key,lv_val
      else
        @lv_control.append @new_option lv_key,lv_val

    # 记住日志类型
    @disposable.add @lv_control.change =>

      @lv_selected = @lv_control.val()
      @lv_map_val = lv_unmap[@lv_selected]
      # console.log @lv_selected
      # console.log @lv_map_val

    # 设置默认行数
    for log_line in @log_line_limit
      if log_line is @def_line_limit_sel
        @line_control.append @new_select_option log_line, log_line
      else
        @line_control.append @new_option log_line, log_line


    # 记住用户的行数选择
    @disposable.add @line_control.change =>
      def_line_selected = @line_control.val()
      atom.config.set(emp.EMP_LOG_LINE_LIMIT_SELECTED, def_line_selected)


    @disposable.add atom.commands.add "atom-workspace","emp-debugger:view-log", => @toggle()

    # console 发送 lua 日志
    @disposable.add atom.commands.add @lua_console.element, 'core:confirm', =>
      @do_send_lua()

    @disposable.add atom.commands.add @lua_console.element, 'core:move-up', =>
      # console.log "move-up"
      # console.log @history_index
      his_len = @history.length

      if !@history_index
        @current_input = @lua_console.getText()
        @history_index = his_len
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

    @disposable.add @client_select.change =>
      @selected_client = @client_select.val()


    @log_filter.getModel().onDidStopChanging =>
      sFilterStr = @log_filter.getText().trim()
      if sFilterStr
        @aFilterList = sFilterStr.split @sDefFilterFlag
        @aFilterList = @aFilterList.filter (tmpFilter) => tmpFilter isnt ''
        @aFilterList = @aFilterList.map (tmpFilter) => @aFlagsList.join tmpFilter
      else
        @aFilterList = []
      console.log @aFilterList

        # if @trancode_detail
        #   @view_detail = @cha_obj.id + '_' + @trancode_detail
        #   @view_name.setText(@view_detail)

    @disposable.add atom.commands.add @log_find.element, 'core:confirm', =>
      @do_find()

    # @test()
  dispose: ->
    @disposable?.dispose()

  serialize: ->
    attached: @hasParent()

  destroy: ->
    @detach()

  detach: ->
    @disposable?.dispose()

  set_conf_view: (@emp_conf_view)->

  show_find: ()=>
    console.log "show log filter"
    if @find_div.isVisible()
      @find_div.hide()
      @showFindBtn.removeClass("selected")
    else
      @find_div.show()
      @showFindBtn.addClass("selected")

  do_find:() =>
    sFindText = @log_find.getText().trim()
    aFindedLog = @oLogMaps.scan_in_buffer(sFindText)
    unless !aFindedLog
      @emp_log_view.scrollTop(aFindedLog[0].offsetTop)

  do_find_pre:()=>
    sFindText = @log_find.getText().trim()
    aFindedLog = @oLogMaps.scan_in_buffer_pre(sFindText)

    unless !aFindedLog
      @emp_log_view.scrollTop(aFindedLog[0].offsetTop)


  show_filter: ()->
    console.log "show log filter"
    if @filter_div.isVisible()
      @filter_div.hide()
      @showFilterBtn.removeClass("selected")
    else
      @filter_div.show()
      @showFilterBtn.addClass("selected")

  do_filter: ()->
    console.log "show filter"
    # console.log @dofilter_btn
    # console.log  @unfilter_btn
    @doFilterBtn.addClass("selected")
    @unFilterBtn.removeClass("selected")

    sFilterStr = @log_filter.getText().trim()
    if sFilterStr
      # console.log "filter true"
      @aFilterList = sFilterStr.split @sDefFilterFlag
      # console.log @aFilterList
      @aFilterList = @aFilterList.filter (tmpFilter) => tmpFilter isnt ''
      # console.log @aFilterList
      @aFilterList = @aFilterList.map (tmpFilter) => @aFlagsList.join tmpFilter
    else
      # console.log "filter false"
      @aFilterList = []
    console.log @aFilterList
    # @aFilterList = []

  un_filter: ()->
    console.log "un filter"
    @unFilterBtn.addClass("selected")
    @doFilterBtn.removeClass("selected")
    @log_filter.setText ""
    @aFilterList=[]


  update_ln: ->
    html = ''
    # console.log @log_detail.css('height')
    # console.log @get_int(@log_detail.css('height'))
    # console.log @get_line_number_count()
    @line_number = @get_line_number_count()
    @line_number = @default_ln unless @line_number+1 >@default_ln

    for row in [1..@line_number+1]
      rowValue = " "+ row
      classes = "line-number line-number-#{row}"
      # classes = "line-number line-number-#{row}"
      # <div class="icon-right"></div>
      html += """<div class="#{classes}" > #{rowValue}</div>"""

    # html += @update_else_ln() unless @line_number+1 >@default_ln
    # console.log @emp_lineNumber
    @emp_lineNumber[0].innerHTML = html



  update: ->
    aAllLogMaps = @oLogMaps.get_all_log()
    for sID, oLog of aAllLogMaps
      @log_detail.append $$ ->
        sLogCol = oLog.get_color()
        @pre class: "emp-log-con text-highlight", style:"color:#{sLogCol}; padding:0px;", "########################## CLIENT:#{oLog.get_id()} ##########################"
        # @p class: "emp-log-con", style:"color:#{tmp_color};padding:0px;", "########################## CLIENT:#{view_logs.get_id()} ##########################"

        for sLogStr in oLog.get_log()
          for sLog in sLogStr.split("\n")
            if sLog isnt "" and sLog isnt " "
              @pre class: "emp-log-con text-highlight",style:"color:#{sLogCol};padding:0px;", "#{sLog}"
    @emp_log_view.scrollToBottom()
    # $('#emp_log_view').stop().animate({scrollTop:@log_detail.context.scrollHeight}, 1000)

    # $("#log_content").stop().animate({
    #   scrollTop: document.getElementById("log_content").scrollHeight
    # }, 1000);

  show_live_log: (sClientID, log_lv, sLogMsg) ->
    # console.log "show live log "
    @do_show_live_log(sClientID, log_lv, sLogMsg) unless @first_show

  do_show_live_log: (sClientID, log_lv, sLogMsg)->
    # console.log "do_show_live_log"
    oLog = @oLogMaps.get_log(sClientID)
    # oLogView = {}
    # console.log oLog
    sShowColor = oLog.get_color()
    limit_line = @line_control.val()
    start_color_ln = @get_line_number_count()

    # 超过设定行数 清除日志
    if start_color_ln > limit_line
      @clear_log()

    # TODO: 判断日志类型,根据筛选规则输出
    # console.log @lv_selected
    log_con_color = lv_color[log_lv]
    log_con_color ?= lv_color.def

    if lv_list.indexOf(log_lv) >=0
      # lv_map_val = lv_unmap[@lv_selected]
      # console.log log_lv, @lv_map_val, @lv_selected
      if @lv_map_val?.indexOf(log_lv) >=0
        # if @lv_selected is lv_val_l
        # oLogView = @oLogMaps.format_log_msg(sClientID, sLogMsg, sShowColor, log_con_color)
        @update_log(sClientID, sLogMsg, sShowColor, log_con_color)
        @update_gutter(sShowColor, start_color_ln, sClientID)

        # @oLogMaps.store_find_log(sClientID, sLogMsg, oLogView)
        # @store_find_log(oLog, sLogMsg, oLogView)
    else
      # oLogView = @oLogMaps.format_log_msg(sClientID, sLogMsg, sShowColor, log_con_color)
      @update_log(sClientID, sLogMsg, sShowColor, log_con_color)
      @update_gutter(sShowColor, start_color_ln, sClientID)
      # @oLogMaps.store_find_log(sClientID, sLogMsg, oLogView)
      # @store_find_log(oLog, sLogMsg, oLogView)

  update_gutter: (sShowColor, start_color_ln, sClientID)->
    # console.log @log_detail.css('height')
    # console.log @get_int(@log_detail.css('height'))
    # console.log @get_line_number_count()
    end_ln = @get_line_number_count()
    # console.log end_ln
    start_ln = @line_number+1
    # console.log "update_gutter: s: #{start_ln} ,e: #{end_ln}"
    # console.log "ln: #{@line_number}, s: #{start_color_ln}"
    # 现在不改变行数的背景色
    # @do_update_gutter_css(start_color_ln, sShowColor) unless @line_number < start_color_ln
    @do_update_gutter(start_ln, end_ln, sShowColor, sClientID) unless start_ln > end_ln


  do_update_gutter: (start, end, sShowColor)->
    # console.log "do_update_gutter:s: #{start} ,e: #{end}"
    @line_number = end
    html = ''
    for row in [start+1..end+1]
      rowValue = " "+ row
      classes = "line-number line-number-#{row}"
      # style="background-color:#{sShowColor};"
      # <div class="icon-right"></div>
      html += """<div class="#{classes}" > #{rowValue}</div>"""
    @emp_lineNumber.append(html)

  do_update_gutter_css: (start_color_ln, sShowColor) ->
    # console.log "do_update_gutter_css"
    # console.log @emp_lineNumber
    chile_nodes = @emp_lineNumber.context.children
    for row in [start_color_ln..@line_number]
      chile_nodes[row].style.backgroundColor=sShowColor


  update_log: (sClientID, sLogMsg, sShowColor, sLogConColor)->
    # console.log "update log "

    for sTmpLog in sLogMsg.split("\n")
      # console.log "|#{log}|"
      if sTmpLog isnt "" and sTmpLog isnt " "
        oTmpView =  $$ ->
          @pre id:"log_#{sClientID}",class: "emp-log-con "+sLogConColor,style:"color:#{sShowColor};padding:0px;", "#{sTmpLog}"
        @oLogMaps.store_buffer(sTmpLog, oTmpView)
          # oTmpView
        @log_detail.append oTmpView
        @emp_log_view.scrollToBottom()
    # oLovView



    # oLogView =  $$ ->
    #   # @pre id:"log_#{client_id}", class: "emp-log-con", style:"color:#{sShowColor};padding:0px;", "######################### CLIENT:#{client_id} ##########################"
    #   for sTmpLog in sLogMsg.split("\n")
    #     # console.log "|#{log}|"
    #     if sTmpLog isnt "" and sTmpLog isnt " "
    #
    #       @pre id:"log_#{sClientID}",class: "emp-log-con "+sLogConColor,style:"color:#{sShowColor};padding:0px;", "#{sTmpLog}"
    #       # oLogMaps.store_buffer(sTmpLog, oTmpView)
    #       # oTmpView
    # @log_detail.append oLogView
    # @emp_log_view.scrollToBottom()
    # oLovView

  store_log: (client_id, log, log_lv=emp.EMP_DEF_LOG_TYPE) ->
    # console.log client_id, log, log_lv
    if !@oLogMaps.has_log(client_id)
      oTmpLog = @oLogMaps.new_log(client_id)
      @refresh_conf_view(client_id, oTmpLog.get_color())
      # @show_live_log(client_id, log, tmp_color)

    # console.log !@stop_state, !@first_show, @show_state
    if !@stop_state and !@first_show and @show_state
      # @log_map[client_id].put_log(log)
      if aLogMatch = log.match @reFilterReg
        if aLogMatch.index isnt 0
          # console.log "log filter:no match"
          @show_live_log(client_id, log_lv, log)
        else
          # console.log "log filter:match true #{@aFilterList}"
          sNewLog = log.replace @reFilterReg, ""

          if  @aFilterList.length > 0
            # console.log "log filter:match true do filter"
            sTmpFlag = aLogMatch[0]
            unless (@aFilterList.indexOf(sTmpFlag) < 0)
              @show_live_log(client_id, log_lv, sNewLog)
          else
            # console.log "log filter:match true len no filter"
            @show_live_log(client_id, log_lv, sNewLog)
      else
        @show_live_log(client_id, log_lv, log)
    # else
      # console.log "store_log"

  store_new_log: (client_id, log_obj)->
    # console.log log_obj
    log_lv = log_obj.level.toLowerCase()
    log_msg = emp.base64_decode log_obj.message
    @store_log(client_id, log_msg, log_lv)

  store_find_log: (oLog, sLogMsg, oLogView)->


  refresh_conf_view: (client_id, color)->
    # unless !emp_conf_view
    # console.log @emp_conf_view
    # @add_clients(client_id)
    @emp_conf_view.refresh_log_view(@oLogMaps, client_id, color) unless !@emp_conf_view

  remove_client_log: (client_id)->
    @refresh_clients()
    @oLogMaps.remove_log(client_id)

    # @emp_conf_view.remove_log_view(client_id) unless !@emp_conf_view

  get_line_number_count: ->
    pane_height = @get_int(@log_detail.css('height'))
    # console.log "pane height:"+pane_height
    # console.log "pane height: #{pane_height} ,lh: #{@line_height}"
    Math.floor(pane_height/ @line_height)

  initial_height: ->
    @get_line_height() unless @line_height
    @get_default_ln() unless @default_ln

  get_line_height: ->
    iTmpHeight = undefined
    oChildNode = @emp_lineNumber.context.children
    # console.log oChildNode
    if oChildNode?.length > 0
      iTmpHeight = oChildNode[0].clientHeight

    # console.log iTmpHeight
    if iTmpHeight isnt undefined
      # @get_int(sTmpHeight)
      @line_height = iTmpHeight
    else
      # @line_height = 18
      @line_height = 17

  get_default_ln: ->
    tmp_height = @emp_log_panel.css('height')
    # console.log tmp_height
    if tmp_height isnt undefined
      @default_ln = Math.floor(@get_int(tmp_height) / @line_height)
    else
      @default_ln = 1

  get_int: (css) ->
    parseInt(css.split("px")[0])

  # use for state view

  hide_view: ->
    if @hasParent()
      if @show_state
        this.hide()
        @show_state = false
      else
        this.show()
        @show_state = true


  clear_store_log: ->
    @oLogMaps.clear_store_log()

  #-------------------------------------------------------------------------
  get_log_store: ->
    @oLogMaps

  # -------------------------------------------------------------------------
  # call by command
  # initial log pane
  toggle: ->
    # console.log @first_show
    if @first_show
      @first_show = false
      if @hasParent()
        @detach()
        @show_state = false
        @stop_state = false
      else
        @refresh_clients()
        @attach()
        @stop_state = false
        @show_state = true
    else
      # console.log @show_state
      if @show_state
        this.hide()
        @show_state = false
      else
        @refresh_clients()
        this.show()
        @show_state = true

  attach: ->
    # atom.workspaceView.prependToBottom(this)
    @panel = atom.workspace.addBottomPanel(item:this,visible:true)
    @disposable.add new Disposable =>
      @panel.destroy()
      @panel = null
    @initial_height()
    @update()
    @update_ln()
    # 刷新 line-height
    @get_line_height()
    # @initial_height()

  # -------------------------------------------------------------------------
  # call by config vieww
  # show log pane
  show_log: ->
    # console.log "show_log"
    @refresh_clients()
    if @first_show
      @first_show = false
      @attach()
      @show_state = true
    else
      # console.log @show_state
      this.show()
      @show_state = true

  hide_log_view: ->
    if @hasParent()
      if @show_state
        this.hide()
        @show_state = false

  show_log_state: ->
    @show_state

  # -------------------------------------------------------------------------
  # clear log content in the log pane
  clear_log: ->
    # console.log 'clear_log'
    if @hasParent()
      @log_detail.context.innerHTML = ''
      @update_ln()

    @clear_store_log()

  # -------------------------------------------------------------------------
  # pause the log poutput
  stop_log: ->
    # console.log "stop_log"
    @stop_state = true

  continue_log: ->
    @stop_state = false

  get_pause_state: ->
    @stop_state

  # -------------------------------------------------------------------------
  #close and clear the log pane
  close_log_view: ->
    # console.log "close1"
    if @hasParent()
      @log_detail.context.innerHTML = ''
      @detach()
      @show_state = false
      @first_show = true
      @stop_state = false
    @clear_store_log()

  get_log_pane_state: ->
    if @first_show
      "Close"
    else
      if @show_state
        if @stop_state
          "Pause"
        else
          "Show"
      else
        "Hide"

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
    # console.log e
    return @resizeStopped() unless which is 1
    height = $(document.body).height()-pageY

    return if height < 70
    # console.log height
    @height(height)
    @emp_log_panel.css("max-height", height)

  resizeToMin: ->
    height = 70
    @height(height)
    @emp_log_panel.css("max-height", height)
    @emp_log_view.scrollToBottom()

  # -------------------------------------------------------------------------
  # -------------------------------------------------------------------------
  ## @doc  Lua console
  do_send_lua: ->
    # console.log @snippet_obj
    lua_code = @lua_console.getText()?.trim()
    # console.log lua_code
    @do_show_in_console(lua_code)
    # console.log @selected_client
    # lua_code = @format_code(lua_code)
    @emp_socket_server.send_lua_console(lua_code, @selected_client)
    if @history.length >= default_history_length
      @history.shift()
    @history.push lua_code
    @history_index = 0
    @current_input = ""
    @lua_console.setText("")


  do_show_in_console: (lua_code) ->

    #  优先使用全局配色, 如果没有,则使用默认色
    unless sShowColor = atom.config.get(emp.EMP_LOG_GLOBAL_COLOR)
      sShowColor = emp.get_color()
    console.log sShowColor
    # a="#{@text-color}"
    start_color_ln = @get_line_number_count()
    @update_console_log(lua_code, sShowColor)
    @update_gutter(sShowColor, start_color_ln)

  update_console_log: (sLogMsg, sShowColor)->
    @log_detail.append $$ ->
      for log in sLogMsg.split("\n")
        # console.log "|#{log}|"
        # Console Input:
        if log isnt "" and log isnt " "
          log = "> "+log
          # color:#{sShowColor};
          @pre class: "emp-log-con text-highlight",style:"color:#{sShowColor};font-weight:bold;font-style:italic;padding:0px;", "#{log}"
    @emp_log_view.scrollToBottom()

  refresh_clients: ->
    client_ids = @emp_socket_server.get_all_id()
    @client_select.empty()
    # client_ids.push default_client_id
    selectd_flag = false
    if client_ids.indexOf(@selected_client) < 0
      @selected_client = default_client_id

    client_ids.push default_client_id
    for tmp_id in client_ids
      if tmp_id is @selected_client
        tmp_view = @new_select_option tmp_id, tmp_id
        @client_select.append tmp_view
        selectd_flag = true
      else
        tmp_view = @new_option tmp_id, tmp_id
        @client_select.append tmp_view

  # set_clients_map: (@emp_clients)->

  set_socket_server: (@emp_socket_server) ->

  add_clients: (client_id)->
    @client_select.append @new_option(client_id, client_id)
    console.log '------------------'
    sShowInput = "########################## New Client:#{client_id} ##########################"
    @store_log(client_id, sShowInput)

  new_option: (name, value=name)->
    $$ ->
      @option value: value, name

  new_select_option: (name, value=name) ->
    $$ ->
      @option selected:'select', value: value, name

  # -------------------------------------------------------------------------

  do_test: ->
    @test()

  test: ->
    @store_log("test", "\nasdasd `    asda;")
    @store_log("test", "------\nasdasd\n\n test functione longlonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglong---")
    @store_log("test", "------\nasdasd\n\n test longlonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglonglong msg")
    @store_log("test", "------\nasdasd\n\n test functione")
    @store_log("test", "------\nasdasd\n\n test functione")
    @store_log("test", "------\nasdasd\n\n test functione")
