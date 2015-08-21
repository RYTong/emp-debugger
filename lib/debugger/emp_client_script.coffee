path = require 'path'

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
  dir:null

  constructor: (@script_name, @script_con, @local_index, @fa_from, @fa_address, @fa_view)->
    @script_index = "#{@fa_from}:#{@script_name}"
    @name = @script_name

    if re = @script_con.match(/atom_emp_related_file_info.*atom_emp_related_file_info/ig)
      # console.log re
      new_re = re[0].replace(/\<*\/*atom_emp_related_file_info\>*/ig, "")
      new_name = path.basename(new_re)
      if @script_name is new_name
      # @dir = path.dirname(new_re)
        @dir = new_re

    # console.log "init script obj :#{@script_index}"

  set_readed: ->
    @readed = true

  set_con: (@script_con, @fa_view)->
