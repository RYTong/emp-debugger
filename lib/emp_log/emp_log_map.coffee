EMPLog = require './emp_log'
emp = require '../exports/emp'
{$, $$, View, TextEditorView} = require 'atom-space-pen-views'

module.exports =
class EMPLogMaps
  oLogMap: {}

  constructor: ()->
    @oLogMap = {}

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


  store_log_buffer:(sClientId, sLogLv, sLogColor, sLogDetail) ->
    # @oLogBuffer
    if oLog = @oLogMap[sClientId]
      oLog.store_log(sLogLv, sLogColor, sLogDetail)

  clear_log_buffer:() ->
    for sID, oLog of @oLogMap
      oLog.clear_log()

  get_log_buf:(sClientId) ->
    unless oLog = @oLogMap[sClientId]
      return []
    oRe = oLog.get_and_clear()
    # console.log "get log buf -----:", oRe
    return oRe

  get_all_buf:() ->
    oRe = {}
    for sClientID , oLog of @oLogMap
      tmpLogBuf = oLog.get_and_clear()
      oRe[sClientID] = tmpLogBuf
    oRe

  clear_store_log:() ->
    for sID, oView of @oLogMap
      oView.clear_log()
