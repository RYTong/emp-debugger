emp = require '../exports/emp'
module.exports =
class EMPLog
  id: null
  glo_color:null
  color: null
  log_arr: null

  constructor: (@id, @color)->
    @log_arr = []
    @glo_color = atom.config.get(emp.EMP_LOG_GLOBAL_COLOR)
    @sLineSelected = atom.config.get(emp.EMP_LOG_LINE_LIMIT_SELECTED)
    @sLineSelected ?= 1000


  store_log: (sLogLv, sLvColor, sLogDetail)->
    if @log_arr.length > @sLineSelected
      @log_arr = []
    oNewBuf = {lv:sLogLv, log:sLogDetail, color:sLvColor}
    @log_arr.push(oNewBuf)


  get_log: ->
    @log_arr

  get_and_clear:() ->
    aTmpA = @log_arr
    @log_arr = []
    return aTmpA

  clear_log: ->
    @log_arr = []





  get_color: ->
    if @glo_color
      @glo_color
    else
      @color

  set_color: (@color)->
    @glo_color = null

  set_glo_color: (@glo_color)->

  get_id: ->
    @id

  store_oView:(@oOption) ->

  get_oView:() ->
    return @oOption

  remove_oView:() ->
    @oOption.remove()
    return
