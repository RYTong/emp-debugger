module.exports =
class emp_client_script
  fa_from: null
  fa_address: null
  script_name: null
  name:null
  script_con:null
  readed:false
  all_index: null
  local_index: null
  script_index: null
  fa_view:null

  constructor: (@script_name, @script_con, @local_index, @fa_from, @fa_address, @view_obj)->
    @script_index = "#{@fa_from}:#{@script_name}"
    @name = @script_name
    # console.log "init script obj :#{@script_index}"

  set_readed: ->
    @readed = true

  set_con: (@script_con, @fa_view)->
