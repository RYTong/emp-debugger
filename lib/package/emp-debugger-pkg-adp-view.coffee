{$, $$, View, TextEditorView} = require 'atom'
remote = require 'remote'
dialog = remote.require 'dialog'

event = (require 'events').EventEmitter

path = require 'path'
fs = require 'fs'
emp = require '../exports/emp'
EmpPkgExtraEle = require './emp-debugger-pkg-extra-element-view'

project_path = ''
tmp_offline_path = ''

module.exports =
class EmpPkgAdpView extends View
  package_show_entry :{}
  package_extra_entry :{}

  @content: ->
    # console.log "constructor" overlay
    @div class: "emp-debugger panel bordered", =>
      @div outlet:'fa_div', class: "panel-heading", 'Channel Adapter Resource Package'
      @div class: "panel-body padded file_panel", =>
        # 'list-tree has-collapsable-children ', =>
        @ul outlet:'fa_list', class: 'list-tree', =>
          @li class: 'list-nested-item', =>
            @div class: 'list-item', =>
              @span class: 'icon icon-file-zip', 'Channel Zip Detail'
            @ul outlet:'pkg_file_list', class: 'list-tree has-flat-children'

        # @ul outlet:'ex_fa_list', class: 'list-tree', style:"display:none;", =>
        #   @li class: 'list-nested-item', =>
        #     @div class: 'list-item', =>
        #       @span class: 'icon icon-file-directory', 'Channel Extra File'
        #       @button class: 'btn btn-error', click:'rm_all', 'R'
        #     @ul outlet:'ex_pkg_file_list', class: 'list-tree has-flat-children'

      # @div class: "panel-body padded", =>
      #   @label class: "emp-conf-label", "添加其他文件: "
      #   @button class: 'btn inline-block emp-btn-ok', click: 'add_else', " +Add "

        # @label class: "emp-label-conment", "如果使用的是模拟器，建议使用localhost，如果使用真机等，请使用ip"
        # @div class: 'controls', =>
        #   @div class: 'editor-container', =>
        #     @subview "emp_sub_host", new TextEditorView(mini: true, attributes: {id: 'emp_host', type: 'string'},  placeholderText: 'Editor Server 监听的地址') #from editor view class
            # @subview "emp_sub_host", new EmpEditView(attributes: {id: 'emp_host', type: 'string'},  placeholderText: 'Editor Server 监听的地址') #from editor view class
      @div class: 'emp-btn-div', =>
        @button class: 'btn inline-block emp-btn-cancel', click: 'process_cancel', "Cancel"
        @button class: 'btn inline-block emp-btn-ok', click: 'process_start', "Ok"


  initialize: () ->
    project_path = atom.project.getPath()
    unless tmp_offline_path = atom.config.get(emp.EMP_OFFLINE_RELATE_DIR)
      tmp_offline_path = emp.EMP_OFFLINE_RELATE_PATH_V
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

  process_start: (event, element) ->
    # console.log element
    # console.log "port:#{@emp_server_port}"
    # console.log "host:#{@emp_server_host}"
    # new_server_host = @emp_sub_host.getText().trim()
    # new_server_port = @emp_sub_port.getText().trim()
    # console.log new_server_host
    # console.log new_server_port
    # @emp_server_host = new_server_host unless new_server_host is ''
    # @emp_server_port = new_server_port unless new_server_port is ''

    # for editorView in @find('.editor[id]').views()
    #   do (editorView) =>
    #     name = editorView.attr('id')
    #     type = editorView.attr('type')
    #     console.log name
    #     show_val = editorView.getText().trim()
    #     emp_server_host = show_val unless name is 'emp_host'
    #     emp_server_port = show_val unless name is 'emp_port'
        # show_val = @parseValue(show_val) unless name is 'emp_ip'
        #
        # console.log show_val
        # console.log show_val.length
    # console.log @emp_server_port
    # @emp_server_port = @parseValue('number', @emp_server_port)
    # console.log "local server start with option parameters: host: #{@emp_server_host}, port: #{@emp_server_port}"
    # @emp_socket_server.init(@emp_server_host, @emp_server_port) unless @emp_socket_server.get_server() isnt null
    @detach()

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
    # @ex_fa_list.hide()
    @pkg_file_list.empty()
    # @ex_pkg_file_list.empty()
    @package_show_entry = {}
    @package_extra_entry = {}
    #@notic channel erlang resource beam
    # beam_entry = @gather_resource_beam(cha_id)
    # emp.EMP_OFFLINE_RELATE_PATH_V
    # @gather_resource_beam(cha_id)
    # console.log beam_entry
    # @gather_cs_template(cha_id)
    result = check_dir(path.join(project_path,tmp_offline_path), cha_id)
    console.log result

    # for key, value of result
    #   if value.length isnt 0


    #
    # for key, tmp_entry of @package_show_entry
    #   tmp_view_element = @new_show_ele tmp_entry
    #   @pkg_file_list.append tmp_view_element

# @doc check the root and base dir for adapter channel
check_dir = (adapter_dir, cha_id) ->
  # console.log adapter_dir
  if fs.existsSync adapter_dir
    # console.log "exist"
    dir_children = fs.readdirSync adapter_dir
    # console.log "all dirs :#{dir_children}"
    re_dir = {length:0}

    for tmp_dir in dir_children
      if !tmp_dir.match(/^\..*/ig)
        tmp_all_dir = path.join(adapter_dir, tmp_dir)
        tmp_state = fs.statSync(tmp_all_dir)
        if tmp_state?.isDirectory()
          # re_dir[tmp_dir] = new Array()
          check_root_dirs(adapter_dir, cha_id, tmp_dir, re_dir)
    # console.log re_dir
    re_dir
  else
    throw emp.EMP_PACKAGE_UNION_PKG_DIR_ENOENT

check_root_dirs = (adapter_dir, cha_id, root_path, re_dir) ->
  # ADAPTER_PLT_D is "common"
  # console.log cha_id
  if root_path is emp.ADAPTER_PLT_D
    tmp_all_dir = path.join(adapter_dir, root_path)
    re_dir.length+=1
    re_dir[root_path] = check_base_file(tmp_all_dir, cha_id)
    # path.join(RootPath, root_path)
  else
    dir_children = fs.readdirSync path.join(adapter_dir, root_path)
    for tmp_dir in dir_children
      if !tmp_dir.match(/^\..*/ig)
        tmp_type = path.join root_path, tmp_dir
        tmp_all_dir = path.join adapter_dir, tmp_type
        tmp_state = fs.statSync(tmp_all_dir)
        if tmp_state?.isDirectory()
          re_dir.length+=1
          if tmp_entry = check_base_file(tmp_all_dir, cha_id)
            re_dir[tmp_type] = tmp_entry
    # console.log re_dir

check_base_file = (dest_path, cha_id) ->
  # console.log "check base file :#{dest_path}"
  re_acc = new Array()
  dir_acc = new Array()

  cha_path = path.join dest_path,emp.OFF_DEFAULT_BASE, cha_id
  if fs.existsSync cha_path
    dir_children = fs.readdirSync cha_path
    for tmp_dir in dir_children
      dir_acc.push [tmp_dir, cha_path, cha_id]
    # console.log dir_acc
    result = check_file(dir_acc, re_acc)
    # console.log "result :#{result}"
    result
  else
    null

check_file  = (dir_acc, re_acc, type) ->
  # dir_children = fs.readdirSync dest_path
  # for tmp_dir in dir_children
  # console.log dir_acc
  # console.log re_acc
  if dir_acc.length isnt 0
    [dir_name, fa_path, show_path] = dir_acc.pop()
    # console.log "dir_name:#{dir_name}, fa_path:#{fa_path}"
    if dir_name.match(/^\..*/ig)
      check_file(dir_acc, re_acc)
    else
      dest_path = path.join fa_path, dir_name
      show_path = path.join show_path, dir_name
      tmp_state = fs.statSync(dest_path)
      # console.log  dest_path
      if tmp_state?.isDirectory()
        dir_children = fs.readdirSync dest_path
        tmp_acc = new Array()
        for tmp_dir in dir_children
          dir_acc.push [tmp_dir, dest_path, show_path]
        check_file(dir_acc.concat(tmp_acc), re_acc)
      else
        re_acc.push(resource_entry(dest_path, show_path))
        check_file(dir_acc, re_acc, type)
  else
    re_acc

resource_entry = (dest_path, show_path) ->
  {dest_path:dest_path, show_path:show_path}

package_entry =(file_com, f_type) ->
  {file_arr:file_com, type:f_type}
