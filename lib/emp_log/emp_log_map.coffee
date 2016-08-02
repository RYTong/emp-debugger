EMPLog = require './emp_log'
emp = require '../exports/emp'
{$, $$, View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class EMPLogMaps
  active_len: 0
  obj_len: 0

  views_map: null
  oLogMap: {}
  iIndex: 0

  log_storage: null

  sAllLogMsg:""
  aAllLogArr:[]
  sPreFinedLog:""
  aFindedLogArr:[]
  iLogLen:0


  constructor: ()->
    # console.log "emp_clients constructor"
    @iIndex = 0
    @iLogLen = 0
    @views_map = new Array()
    @oLogMap = {}
    @sAllLogMsg=""
    @sPreFinedLog=""
    @oFindReg = null
    @oNowFindedView=null
    @aFindedLogArr=[]
    # @log_storage.set_clients_map(this)
    # @css_map = {}

  get_all_log:() ->
    return @oLogMap

  new_log: (sLogID) ->

    oLog = new EMPLog(sLogID, emp.get_color())
    @oLogMap[sLogID] = oLog
    return oLog

  remove_log: (sLogID) ->
    delete @oLogMap[sLogID]
    return true

  get_log:(sLogID) ->
    return @oLogMap[sLogID]

  get_log_col:(sLogID) ->
    oTmpLog = @oLogMap[sLogID]
    unless oTmpLog
      return null
    return oTmpLog.get_color()

  set_log_col:(sLogID, sCol) ->
    oTmpLog = @oLogMap[sLogID]
    unless oTmpLog
      return null
    oTmpLog.set_color(sCol)
    return true

  set_log_gol_col:(sLogID, sGloCol) ->
    unless oTmpLog = @oLogMap[sLogID]
      return null
    oTmpLog.set_glo_color(sGloCol)
    return true

  has_log:(sLogID) ->
    unless @oLogMap[sLogID]
      return false
    return true


  clear_store_log:() ->
    for sID, oView of @oLogMap
      # console.log name
      oView.reset_log()
    @sAllLogMsg = ""
    @aAllLogArr = []
    @iLogLen = 0
    @iIndex = 0
    @oNowFindedView=null
    @aFindedLogArr=[]
    @sPreFinedLog=""

  format_log_msg: (sClientID, sLogMsg, sShowColor, sLogConColor) ->
    oLovView =  $$ =>
      for sStr in sLogMsg.split("\n")
        # console.log "|#{log}|"
        if sStr isnt "" and sStr isnt " "
          oTmpView = @pre id:"log_#{sClientID}",class: "emp-log-con "+sLogConColor,style:"color:#{sShowColor};padding:0px;", "#{sStr}"
          @aAllLogArr.push @new_log_msg(sStr, oTmpView)
          oTmpView

    return oLovView

  store_buffer:(sStr, oTmpView) ->
    # iIndex = iIndex+1
    @iLogLen = @iLogLen+1
    @aAllLogArr.push @new_log_msg(sStr, oTmpView, @iLogLen)


    # oLovView =  $$ ->
    #   # @pre id:"log_#{client_id}", class: "emp-log-con", style:"color:#{sShowColor};padding:0px;", "######################### CLIENT:#{client_id} ##########################"
    #   for log in log_ga.split("\n")
    #     # console.log "|#{log}|"
    #     if log isnt "" and log isnt " "
    #       @pre id:"log_#{client_id}",class: "emp-log-con "+sLogConColor,style:"color:#{sShowColor};padding:0px;", "#{log}"
    # @log_detail.append oLovView
    # @emp_log_view.scrollToBottom()
    # oLovView

  # for find log
  store_find_log: (sID, sLogMsg, oView) ->
    oTmpLog = @oLogMap[sID]

  new_log_msg:(sMsg, oView, iIndex) ->
    {msg:sMsg, view:oView, index:iIndex}

  scan_in_buffer:(sFindText) ->
    console.log "scan in buffer ------"
    # console.log sFindText
    # console.log @aAllLogArr

    if sFindText isnt ""
    # @oFindReg = new RegExp()
    # @emp_node_st.css('color', node_css_style)
    # iLen = @aAllLogArr.length
    # oTmp = @aAllLogArr[iLen-1]
    # console.log oTmp
    # oTmp.view.css('border','1px solid')
    # oTmp.view.css('color','#ee1717')
    # oTmp.view.addClass('emp_log_selected')
      if sFindText isnt @sPreFinedLog
        for oTmpView in @aFindedLogArr
          oTmpView.removeClass('emp_log_selected')

      @aFindedLogArr=[]

      for oTmp in @aAllLogArr
        sTmpMsg = oTmp.msg
        if sTmpMsg.match sFindText
          oTmpView = oTmp.view
          # unless oTmpView isnt @oNowFindedView
          @oNowFindedView = oTmpView
          @aFindedLogArr.push oTmpView
          oTmpView.addClass('emp_log_selected')

    else
      for oTmpView in @aFindedLogArr
        oTmpView.removeClass('emp_log_selected')
      @aFindedLogArr=[]
    return @aFindedLogArr
