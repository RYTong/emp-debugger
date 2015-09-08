emp = require '../../exports/emp'
module.exports =
class emp_adapter
  trancode:null
  adapter:null
  procedure:null
  view:null
  view_type:emp.EMP_ADD_CHA_VIEW_TYPE_EMP
  params:[]


  constructor: (@trancode, @adapter, @procedure, @view, @cha_id, @view_type)->
    # console.log "this is a channel"
    @params = []
    if !@view
      @view = @cha_id + '_' +@trancode


  store_param:(param) ->
    # console.log param
    if param.key
      @params.push(param)
