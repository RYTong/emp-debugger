emp = require '../exports/emp'
module.exports =
class emp_view_log
  id: null
  glo_color:null
  color: null
  log_arr: null

  constructor: (@id, @color)->
    @log_arr = []
    @glo_color = atom.config.get(emp.EMP_LOG_GLOBAL_COLOR)


  put_log: (log)->
    if @log_arr.length > 2000
      @log_arr = []
    @log_arr.push(log)


  get_log: ->
    @log_arr

  reset_log: ->
    @log_arr = []

  get_color: ->
    if @glo_color
      @glo_color
    else
      @color

  set_color: (@color)->

  set_glo_color: (@glo_color)->

  get_id: ->
    @id
