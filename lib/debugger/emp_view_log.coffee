module.exports =
class emp_view_log
  id: null
  color: null
  log_arr: null

  constructor: (@id, @color)->
    @log_arr = new Array()


  put_log: (log)->
    @log_arr.push(log)

  get_log: ->
    @log_arr

  reset_log: ->
    @log_arr = new Array()

  get_color: ->
    @color

  get_id: ->
    @id
