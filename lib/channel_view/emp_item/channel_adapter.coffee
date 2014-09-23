module.exports =
class emp_adapter
  trancode:null
  adapter:null
  procedure:null
  view:null
  params:[]


  constructor: (@trancode, @adapter, @procedure, @view, @cha_id)->
    # console.log "this is a channel"
    @params = []
    if !@view
      @view = @cha_id + '_' +@trancode


  store_param:(param) ->
    # console.log param
    if param.key
      @params.push(param)
