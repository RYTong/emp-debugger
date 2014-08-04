module.exports =
class emp_client_view
  fa_from: null
  fa_address: null
  view:null
  readed:false
  all_index: null
  local_index: null

  constructor: (@view, @index, @local_index, @fa_from, @fa_address)->

  set_readed: ->
    @readed = true
