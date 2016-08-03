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

  # sAllLogMsg:""
  aAllLogArr:[]
  sPreFinedLog:""
  aFindedLogArr:[]
  iLogLen:0
  # iPreFindedArrLen:0
  # oNowFindedView:null
  oFindedHeadInfo:{}
  bFindIFPre:false


  constructor: ()->
    # console.log "emp_clients constructor"
    @iIndex = 0
    @iLogLen = 0
    # @iPreFindedArrLen=0
    @views_map = new Array()
    @oLogMap = {}
    # @sAllLogMsg=""
    @reset_find_params()
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
    # @sAllLogMsg = ""
    @aAllLogArr = []
    @iLogLen = 0
    @reset_find_params()

  reset_find_params:(@sPreFinedLog="", oFView=null, iFLen=0) ->
    @iIndex = 0
    # @iPreFindedArrLen=0
    # @oNowFindedView=null
    @aFindedLogArr=[]
    @bFindIFPre=false
    @set_find_head_info(oFView, iFLen)

  set_find_head_info:(oView, iLen) ->
    @oFindedHeadInfo={view:oView, len:iLen}

  get_find_head_len:() ->
    return @oFindedHeadInfo.len

  get_find_head_view:() ->
    return @oFindedHeadInfo.view


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


  # for find log
  store_find_log: (sID, sLogMsg, oView) ->
    oTmpLog = @oLogMap[sID]

  new_log_msg:(sMsg, oView, iIndex) ->
    {msg:sMsg, view:oView, index:iIndex}

  scan_in_buffer_pre:(sFindText) ->
    @bFindIFPre=true
    @do_scan_in_buffer(sFindText)

  scan_in_buffer:(sFindText) ->
    @bFindIFPre=false
    @do_scan_in_buffer(sFindText)

  do_scan_in_buffer:(sFindText) ->
    # console.log "scan in buffer ------"

    if sFindText isnt ""
      if sFindText isnt @sPreFinedLog
        for oTmpView in @aFindedLogArr
          @remove_find_flag(oTmpView)

        @reset_find_params(sFindText, @aAllLogArr[0]?.view, @aAllLogArr.length)

        oNowFindedView = @do_find_process(sFindText, @aAllLogArr)
        return oNowFindedView
      else
        iFLen = @get_find_head_len()
        oFView = @get_find_head_view()
        oTmpView = @aAllLogArr[0]?.view
        iNLen = @aAllLogArr.length
        if oFView isnt oTmpView
          @reset_find_params(sFindText, @aAllLogArr[0]?.view, @aAllLogArr.length)
          oNowFindedView = @do_find_process(sFindText, @aAllLogArr)
          return oNowFindedView
        else if iFLen != iNLen
          aTmpArr = []
          aLoopArr = [iFLen-1..iNLen-1]
          for iTmpIndex in aLoopArr
            unless !@aAllLogArr[iTmpIndex]
              aTmpArr.push @aAllLogArr[iTmpIndex]
          # @reset_find_params(sFindText, oFView, iNLen)
          @set_find_head_info(oFView, iNLen)
          oNowFindedView = @do_find_process(sFindText, aTmpArr)
          # console.log oNowFindedView
          return oNowFindedView
        else
          # console.log "else"
          if @bFindIFPre
            @iIndex=@iIndex-2
            unless @iIndex >= 0
              @iIndex=@aFindedLogArr.length-1
            # if @iIndex >= @aFindedLogArr.length
              # @iIndex=0
            # console.log @iIndex
            oNowFindedView = @aFindedLogArr[@iIndex]
            @iIndex = @iIndex+1
            return oNowFindedView
          else
            if @iIndex >= @aFindedLogArr.length
              @iIndex=0
            # console.log @iIndex
            oNowFindedView = @aFindedLogArr[@iIndex]
            @iIndex = @iIndex+1
            return oNowFindedView
    else
      for oTmpView in @aFindedLogArr
        @remove_find_flag(oTmpView)
      @reset_find_params(sFindText)
    return null

  do_find_process:(sFindText, aDoFindArr) ->
    for oTmp in aDoFindArr
      sTmpMsg = oTmp.msg
      oFindReg = new RegExp sFindText, 'ig'
      if sTmpMsg.match oFindReg
        # sTmpMsg.replace
        sNewStr = sTmpMsg.replace oFindReg, "<span class=\"emp_log_selected\">$&</span>"
        oTmpView = oTmp.view

        # @oNowFindedView = oTmpView
        @aFindedLogArr.push oTmpView
        # console.log oTmpView
        sNewStr = "<div>#{sNewStr}</div>"
        oTmpView[0].innerHTML = sNewStr

        # oTmpView.addClass('emp_log_selected')
    oNowFindedView = @aFindedLogArr[@iIndex]

    @iIndex = @iIndex+1
    return oNowFindedView

  remove_find_flag:(oTmpView) ->
    oTmpView[0].innerHTML = oTmpView[0].innerText
