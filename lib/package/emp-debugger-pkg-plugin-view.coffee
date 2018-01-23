{Disposable, CompositeDisposable} = require 'atom'
{$, $$, View} = require 'atom-space-pen-views'
{ dialog } = require('electron').remote

path = require 'path'
fs = require 'fs'
crypto = require 'crypto'
emp = require '../exports/emp'
EmpPkgExtraEle = require './emp-debugger-pkg-extra-element-view'
ZipWriter = require("moxie-zip").ZipWriter
Cert = require '../util/cert'

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
    project_path = atom.project.getPaths()[0]
    @eft_parser = new Cert()
    @disposable = new CompositeDisposable()
    # super()
    # console.log "server init view initial"

    # atom.workspaceView.command "emp-debugger:debug-server", => @init()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  show_view: (@cha_id, @cha_obj)->
    # console.log "EmpDebuggerView was toggled!"
    # if @emp_socket_server.get_server() is null
    if @hasParent()
      @destroy()
    else
      @initial_channel_panel(@cha_id, @cha_obj)
      # @panel = atom.workspace.addTopPanel(item:this) # unless @emp_socket_server.server isnt null
      @panel = atom.workspace.addTopPanel(item:this, visible:true)
      # @panel = atom.workspaceView.appendToRight(this)
          # atom.workspaceView.prependToRight(this)

      @disposable.add new Disposable =>
        @panel.destroy()
        @panel = null
      # @attach()
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
    # console.log "do nothing now"
    # console.log @package_show_entry
    # console.log @package_extra_entry
    project_path = atom.project.getPaths()[0]
    zip_file_name = emp.PACKAGE_NORMAL_CHANNEL+".zip"
    zip_file_name = path.join(project_path,"tmp",zip_file_name)
    # console.log "zip_name: #{zip_file_name}"
    zip = new ZipWriter()

    spec_file = @format_spec_file()
    checksum_file = @format_sign_file(spec_file)
    zip.addData emp.PACKAGE_CHECKSUM, "{checksum, \"#{checksum_file}\"}"
    zip.addData emp.PACKAGE_SPEC, spec_file

    for key, tmp_file of @package_show_entry
      # console.log tmp_file
      zip.addFile(tmp_file.show_path, tmp_file.rel_path)

    for key, tmp_file of @package_extra_entry
      # console.log tmp_file
      zip.addFile(tmp_file.show_path, tmp_file.rel_path)
    zip.saveAs(zip_file_name, () ->
      emp.show_info emp.EMP_PACKAGE_PKG_SUCCESS+"包路径:"+path.basename(project_path)+"/tmp"
      # console.log "zip written."
      )
    # @fa_view.destroy()
    @detach()

  format_spec_file:()->
    # console.log @cha_obj
    all_files = new Array()
    for key, tmp_file of @package_show_entry
      all_files.push "\"#{tmp_file.show_path}\""

    for key, tmp_file of @package_extra_entry
      all_files.push "\"#{tmp_file.show_path}\""

    all_files = all_files.join ","
    re_str = "{spec,[{channel,#{@cha_obj.atom_p}},\n\r{files,[#{all_files}]}]}."
    # console.log re_str
    re_str

  format_sign_file: (spec_file) ->
    file_arr = new Array()
    for key, tmp_file of @package_show_entry
      # console.log tmp_file
      # all_files.push "\"#{tmp_file.show_path}\""
      file_arr.push @format_content(tmp_file)

    for key, tmp_file of @package_extra_entry
      # console.log tmp_file
      file_arr.push @format_content(tmp_file)

    file_arr.push @eft_parser.tuple("SPEC",@eft_parser.binary spec_file)
    re = @eft_parser.encode file_arr
    # fs.writeFileSync project_path+'/tmp/t.txt', re
    # console.log file_arr
    shasum = crypto.createHash 'sha1'
    shasum.update re
    shasum.digest 'hex'


  format_content:(file_obj) ->
    try
      re_con = fs.readFileSync file_obj.rel_path
      @eft_parser.tuple file_obj.show_path,@eft_parser.binary re_con
    catch e
      console.log e




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

  get_path_entry:(relative_path, file_type='default', show_path=relative_path) ->
    {show_path:show_path, rel_path:path.join(project_path,relative_path), type:file_type}

  get_abs_path_entry:(relative_path, file_type='default', show_path=relative_path) ->
    {show_path:show_path, rel_path:relative_path, type:file_type}
