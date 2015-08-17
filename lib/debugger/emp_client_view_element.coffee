path = require 'path'
emp = require '../exports/emp'

module.exports =
class emp_client_view
  fa_from: null
  fa_address: null
  view:null
  readed:false
  all_index: null
  local_index: null
  name:null
  dir:null
  show_name:null
  file_type:emp.OFF_EXTENSION_XHTML
  new_type_view:true

  # OFF_EXTENSION_XHTML:"xhtml"
  # OFF_EXTENSION_LUA:"lua"
  # OFF_EXTENSION_CSS: "css"

  constructor: (@fa_obj, @view, @input_name, @fa_from, @fa_address, @file_type, true_name)->
    # console.log @fa_from
    if !true_name
      @show_name = "#{@input_name}"
      if re = @view.match(/atom_emp_related_file_info.*atom_emp_related_file_info/ig)
        # console.log re
        new_re = re[0].replace(/\<*\/*atom_emp_related_file_info\>*/ig, "")
        @name = path.basename(new_re)
        @show_name = @name
        @dir = new_re
    else
      @show_name = true_name

  set_view_readed: ->
    @readed = true

  get_fa_obj: ->
    @fa_obj
