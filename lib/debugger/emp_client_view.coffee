path = require 'path'
ele_view = require './emp_client_view_element'
emp = require '../exports/emp'

module.exports =
class emp_client_view
  fa_from: null
  fa_address: null
  view:null
  readed:false
  all_index: null
  local_index: null
  script_map:{}
  css_map:{}
  detail_map:[]
  name:null
  dir:null
  show_name:null
  new_type_view:false

  constructor: (@view, @index, @local_index, @fa_from, @fa_address)->
    @show_name = "#{@index}"


    if re = @view.match(/atom_emp_related_file_info.*atom_emp_related_file_info/ig)
      # console.log re
      new_re = re[0].replace(/\<*\/*atom_emp_related_file_info\>*/ig, "")
      @name = path.basename(new_re)
      @show_name = @name
      # @dir = path.dirname(new_re)
      @dir = new_re

  set_relate_obj: (@view_content_obj) ->
    @new_type_view = true
    # OFF_EXTENSION_XHTML:"xhtml"
    # OFF_EXTENSION_LUA:"lua"
    # OFF_EXTENSION_CSS: "css"
    @detail_map =[]
    # console.log @view_content_obj
    # tmp_obj = {"view": "", script:{"name.lua":"lua_con"}, "css":{"name.css":"css_con"} }

    tmp_view_obj = new ele_view(@view_content_obj, @view_content_obj["view"], @show_name, @fa_from, @fa_address, emp.OFF_EXTENSION_XHTML)
    @detail_map.push(tmp_view_obj)

    for tmp_name, tmp_con of @view_content_obj["script"]
      tmp_script_obj = new ele_view(@view_content_obj, tmp_con, tmp_name, @fa_from, @fa_address, emp.OFF_EXTENSION_LUA)
      @detail_map.push(tmp_script_obj)

    for tmp_name, tmp_con of @view_content_obj["css"]
      tmp_css_obj = new ele_view(@view_content_obj, tmp_con, tmp_name, @fa_from, @fa_address, emp.OFF_EXTENSION_CSS)
      @detail_map.push(tmp_css_obj)

  set_view_readed: ->
    @readed = true



  set_script: (script_obj)->
    @script_map[script_obj.script_name] = script_obj

  set_css: (css_obj)->
    @css_map[css_obj.css_name] = css_obj
