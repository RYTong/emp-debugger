{$, $$, View, TextEditorView} = require 'atom'
remote = require 'remote'
dialog = remote.require 'dialog'

path = require 'path'
fs = require 'fs'
emp = require '../exports/emp'
EmpPkgExtraEle = require './emp-debugger-pkg-extra-element-view'
ZipWriter = require("moxie-zip").ZipWriter

project_path = ''

module.exports =
class EmpDebuggerPkgView extends View
  package_show_entry :{}
  package_extra_entry :{}

  @content: ->
    # console.log "constructor" overlay
    @div class: "emp-debugger panel bordered", =>
      @div outlet:'fa_div', class: "panel-heading", 'Common Channel Resource Package'
      @div class: "panel-body padded file_panel", =>
        # 'list-tree has-collapsable-children ', =>
        @ul outlet:'fa_list', class: 'list-tree', =>
          @li class: 'list-nested-item', =>
            @div class: 'list-item', =>
              @span class: 'icon icon-file-zip', 'Channel Zip Detail'
            @ul outlet:'pkg_file_list', class: 'list-tree has-flat-children'

        @ul outlet:'ex_fa_list', class: 'list-tree', style:"display:none;", =>
          @li class: 'list-nested-item', =>
            @div class: 'list-item', =>
              @span class: 'icon icon-file-directory', 'Channel Extra File'
              @button class: 'btn btn-error', click:'rm_all', 'R'
            @ul outlet:'ex_pkg_file_list', class: 'list-tree has-flat-children'
          # @li class: 'list-item', =>
          #   @span class: 'icon icon-file-text', 'With icon-file-text'
          # @li class: 'list-item', =>
          #   @span class: 'icon icon-file-media', 'With icon-file-media'
          # @li class: 'list-item', =>
          #   @span class: 'icon icon-book', 'With icon-book'
      @div class: "panel-body padded", =>
        @label class: "emp-conf-label", "添加其他文件: "
        @button class: 'btn inline-block emp-btn-ok', click: 'add_else', " +Add "

        # @label class: "emp-label-conment", "如果使用的是模拟器，建议使用localhost，如果使用真机等，请使用ip"
        # @div class: 'controls', =>
        #   @div class: 'editor-container', =>
        #     @subview "emp_sub_host", new TextEditorView(mini: true, attributes: {id: 'emp_host', type: 'string'},  placeholderText: 'Editor Server 监听的地址') #from editor view class
            # @subview "emp_sub_host", new EmpEditView(attributes: {id: 'emp_host', type: 'string'},  placeholderText: 'Editor Server 监听的地址') #from editor view class
      @div class: 'emp-btn-div', =>
        @button class: 'btn inline-block emp-btn-cancel', click: 'process_cancel', "Cancel"
        @button class: 'btn inline-block emp-btn-ok', click: 'process_pkg', "Package"


  initialize: () ->
    project_path = atom.project.getPath()
    # super()
    # console.log "server init view initial"

    # atom.workspaceView.command "emp-debugger:debug-server", => @init()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  show_view: (cha_id)->
    # console.log "EmpDebuggerView was toggled!"
    # if @emp_socket_server.get_server() is null
    if @hasParent()
      @detach()
    else
      @initial_channel_panel(cha_id)
      atom.workspaceView.append(this) # unless @emp_socket_server.server isnt null
      # @emp_sub_host.focus()
      # @emp_sub_host.on 'enter', =>
      #   console.log 'enter input~'
      # @on 'enter', =>
      #   console.log 'enter input~2'

  process_cancel: (event, element) ->
    # console.log element
    # console.log "Cancel Preparing #{element.name} for launch!"
    @detach()

  process_pkg: (event, element) ->
    console.log "start pkg"
    console.log "do nothing now"
    # zip = new ZipWriter()
    # zip.addFile(tmp_file_name, tmp_file)
    #
    # zip.saveAs(re_pa, () ->
    #   # union_package_index-=1
    #   # if union_package_index is 0
    #   #   emp.show_info emp.EMP_PACKAGE_PKG_SUCCESS
    #   console.log "zip written."
    #   )

    @detach()

  add_else:(e, ele) ->
    console.log "add_else"
    dialog.showOpenDialog title: 'Select',  defaultPath:project_path, properties: ['openFile', 'multiSelections'], (pathsToOpen) =>
      console.log pathsToOpen
      if pathsToOpen
        for tmp_path in pathsToOpen
          @new_extra_ele tmp_path

      console.log @package_extra_entry

  new_extra_ele: (add_file)->
    show_path = path.relative project_path,add_file
    unless @package_extra_entry[show_path]
      tmp_entry = @get_abs_path_entry(add_file, 'default', show_path)
      @package_extra_entry[show_path] = tmp_entry
      tmp_view_entry = new EmpPkgExtraEle(show_path, this.package_extra_entry)

      if @ex_fa_list.isHidden()
        @ex_fa_list.show()
      @ex_pkg_file_list.append tmp_view_entry

  remove_extra_entry: (extra_ele)->
    console.log extra_ele
    console.log @package_extra_entry
    delete @package_extra_entry[extra_ele]

  rm_all:(e, element) ->
    console.log "rm_all"
    @ex_pkg_file_list.empty()
    @package_extra_entry = {}



  new_show_ele: (show_entry)->
    tmp_class = "icon-file-text"
    tmp_class = switch show_entry.type
      when emp.PACKAGE_EXTENSION_BEAM_TYPE then "icon-file-submodule"
      when emp.OFF_EXTENSION_CS then "icon-file-text"
      else "icon-file-text"

    $$ ->
      @li class: 'list-item', =>
        @span class: "icon #{tmp_class}", show_entry.show_path

  initial_channel_panel: (cha_id, cha_obj) ->
    console.log "initial_channel_panel:#{cha_id}"
    # console.log @pkg_file_list
    # do initial
    @ex_fa_list.hide()
    @pkg_file_list.empty()
    @ex_pkg_file_list.empty()
    @package_show_entry = {}
    @package_extra_entry = {}
    #@notic channel erlang resource beam
    # beam_entry = @gather_resource_beam(cha_id)
    @gather_resource_beam(cha_id)
    # console.log beam_entry
    # @package_show_entry = @package_show_entry.concat beam_entry
    #@notic channel cs template
    # cs_entrys = @gather_cs_template(cha_id)
    @gather_cs_template(cha_id)
    # console.log cs_entrys
    # @package_show_entry = @package_show_entry.concat cs_entrys
    # console.log package_show_entry


    for key, tmp_entry of @package_show_entry
      tmp_view_element = @new_show_ele tmp_entry
      @pkg_file_list.append tmp_view_element

  gather_resource_beam: (cha_id) ->
    cha_beam_rel_path = path.join emp.PACKAGE_CHANNEL_EBIN_DIR, cha_id+emp.PACKAGE_EXTENSION_BEAM
    tmp_entry = @get_path_entry(cha_beam_rel_path, emp.PACKAGE_EXTENSION_BEAM_TYPE)
    if fs.existsSync tmp_entry.rel_path
      @package_show_entry[cha_beam_rel_path] = tmp_entry


  gather_cs_template: (cha_id)->
    relative_path = path.join emp.PACKAGE_CHANNEL_CS_DIR, cha_id
    cs_dir = path.join project_path, relative_path
    if fs.existsSync cs_dir
      # console.log "exist"
      cs_file_list = fs.readdirSync(cs_dir).filter((ele)-> ele.match(/.*\.cs$/ig))
      unless !cs_file_list
        for tmp_cs_file in cs_file_list
          tmp_relative_path = path.join relative_path, tmp_cs_file
          tmp_show_path = path.join "cs", cha_id, tmp_cs_file
          @package_show_entry[tmp_relative_path] = @get_path_entry(tmp_relative_path, emp.OFF_EXTENSION_CS, tmp_show_path)


  warn_dialog:(msg) ->
    # console.log "this a waring dialog"
    @div class: 'overlay from-top select-list', =>
      @div class: 'editor editor-colors mini', "I searched for this: #{msg}"
      @div class: 'error-message', 'Nothing has been found!'

  get_path_entry:(relative_path, file_type='default', show_path=relative_path) ->
    {show_path:show_path, rel_path:path.join(project_path,relative_path), type:file_type}

  get_abs_path_entry:(relative_path, file_type='default', show_path=relative_path) ->
    {show_path:show_path, rel_path:relative_path, type:file_type}
