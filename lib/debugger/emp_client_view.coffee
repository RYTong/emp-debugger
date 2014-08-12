module.exports =
class emp_client_view
  fa_from: null
  fa_address: null
  view:null
  readed:false
  all_index: null
  local_index: null
  script_map:{}

  constructor: (@view, @index, @local_index, @fa_from, @fa_address)->

  set_view_readed: ->
    @readed = true

  set_script: (script_obj)->
    @script_map[script_obj.script_name] = script_obj
