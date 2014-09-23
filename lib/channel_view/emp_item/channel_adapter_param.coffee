module.exports =
class emp_adapter_param
  key:null
  rkey:null
  type:null

  constructor: (@key, r_key, @type)->
    if !r_key
      @rkey = @key
    else
      @rkey = r_key
    # console.log "this is a adapter item"
