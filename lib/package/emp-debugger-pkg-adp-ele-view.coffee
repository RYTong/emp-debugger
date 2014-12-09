{$, $$, View, TextEditorView} = require 'atom'
ZipWriter = require("moxie-zip").ZipWriter
path = require 'path'
emp = require '../exports/emp'

module.exports =
class EmpPkgAdpEleView extends View
  @content: (fa_view, cha_id, adp_type, file_arr)->
    zip_file_name = get_pkg_name("", cha_id, adp_type)

    @ul outlet:'fa_list', class: 'list-tree', =>
      @li class: 'list-nested-item', =>
        @div class: 'list-item', =>
          @span class: 'icon icon-file-zip', zip_file_name
          @button class: 'btn btn-success pull-right', click:'do_package', 'Zip'
        @ul outlet:'pkg_file_list', class: 'list-tree has-flat-children'


  initialize: (@fa_view, @cha_id, @adp_type, @file_arr)->
    # console.log "initialize"
    # console.log @file_arr
    for tmp_obj in @file_arr
      new_tmp_view = @new_show_ele(tmp_obj)
      @pkg_file_list.append new_tmp_view
    this


  destroy: ->
    @detach()

  do_package:(e, element) ->
    # console.log "do_package"
    # console.log @adp_type
    # console.log @file_arr
    project_path = atom.project.getPath()
    zip_file_name = get_pkg_name(".zip", @cha_id, @adp_type)
    # console.log zip_file_name
    zip_file_name = path.join(project_path,"tmp",zip_file_name)
    # console.log "zip_name: #{zip_name}"
    zip = new ZipWriter()
    for tmp_file in @file_arr
      zip.addFile(tmp_file.show_path, tmp_file.dest_path)
    zip.saveAs(zip_file_name, () ->
      emp.show_info emp.EMP_PACKAGE_PKG_SUCCESS
      # console.log "zip written."
      )
    @fa_view.destroy()

  new_show_ele: (show_entry)->
    # console.log show_entry
    $$ ->
      @li class: 'list-item', =>
        @span class: "icon icon-file-text", show_entry.show_path

get_pkg_name = (ext, cha_id, adp_type) ->
  # console.log "get_pkg_name"
  name_type = adp_type.split "/"
  if name_type.length > 1
    zip_file_name = [cha_id ,name_type[0],name_type[1].split("*").join("-")].join(".")+ext
  else
    zip_file_name = cha_id+name_type[0]+ext
  zip_file_name
