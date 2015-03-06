path = require 'path'
module.exports =
class emp_client_view
  fa_from: null
  fa_address: null
  view:null
  readed:false
  all_index: null
  local_index: null
  script_map:{}
  name:null
  dir:null
  show_name:null

  constructor: (@view, @index, @local_index, @fa_from, @fa_address)->
    @show_name = "#{@index}"

    if re = @view.match(/atom_emp_related_file_info.*atom_emp_related_file_info/ig)
      # console.log re
      new_re = re[0].replace(/\<*\/*atom_emp_related_file_info\>*/ig, "")
      @name = path.basename(new_re)
      @show_name = @name
      # @dir = path.dirname(new_re)
      @dir = new_re

  set_view_readed: ->
    @readed = true

  set_script: (script_obj)->
    @script_map[script_obj.script_name] = script_obj
