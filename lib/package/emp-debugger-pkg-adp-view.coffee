{Disposable, CompositeDisposable} = require 'atom'
{$, $$, View} = require 'atom-space-pen-views'
{ dialog } = require('electron').remote

event = (require 'events').EventEmitter

path = require 'path'
fs = require 'fs'
emp = require '../exports/emp'
EmpPkgAdpEle = require './emp-debugger-pkg-adp-ele-view'

project_path = ''
tmp_offline_path = ''

module.exports =
class EmpPkgAdpView extends View

  @content: ->
    # console.log "constructor" overlay
    @div class: "emp-debugger panel bordered", =>
      @div class: "panel-heading", 'Channel Adapter Resource Package'
      @div outlet:'fa_div', class: "panel-body padded file_panel"

      @div class: 'emp-btn-div', =>
        @button class: 'btn inline-block emp-btn-right', click: 'process_cancel', "Cancel"
        # @button class: 'btn inline-block emp-btn-ok', click: 'process_start', "Ok"


  initialize: () ->
    project_path = atom.project.getPaths()[0]
    @disposable = new CompositeDisposable()
    unless tmp_offline_path = atom.config.get(emp.EMP_OFFLINE_RELATE_DIR)
      tmp_offline_path = emp.EMP_OFFLINE_RELATE_PATH_V

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  show_view: (cha_id, cha_obj)->
    # console.log "EmpDebuggerView was toggled!"
    # if @emp_socket_server.get_server() is null
    if @hasParent()
      @detach()
    else
      @initial_channel_panel(cha_id, cha_obj)
      @panel = atom.workspace.addTopPanel(item:this, visible:true)# unless @emp_socket_server.server isnt null

      @disposable.add new Disposable =>
        @panel.destroy()
        @panel = null

  process_cancel: (event, element) ->
    # console.log element
    # console.log "Cancel Preparing #{element.name} for launch!"
    @detach()

  initial_channel_panel: (cha_id, cha_obj) ->
    # console.log "initial_channel_panel:#{cha_id}"
    # console.log @pkg_file_list
    @fa_div.empty()
    result = check_dir(path.join(project_path,tmp_offline_path), cha_id)
    # console.log result
    re_len = result.length
    delete result.length

    for key, value of result
      if value.length isnt 0
        tmp_ele_view = new EmpPkgAdpEle(this, cha_id, key, value)
        @fa_div.append tmp_ele_view

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
    if re_dir.length > 1
      if tmp_common_arr = re_dir[emp.ADAPTER_PLT_D]
        delete re_dir[emp.ADAPTER_PLT_D]
        tmp_lenth = re_dir.length - 1
        delete re_dir.length
        for key,tmp_value of re_dir
          # console.log key, tmp_value
          tmp_file_arr = new Array()
          for tmp_obj in tmp_value
            tmp_file_arr.push tmp_obj.name
          # console.log tmp_file_arr
          re_common_arr = tmp_common_arr.filter (ele) ->
            # console.log ele.name
            tmp_flag = tmp_file_arr.indexOf ele.name
            tmp_flag is -1
          # console.log tmp_common_arr
          # console.log re_common_arr
          # console.log key,re_dir[key]
          if re_common_arr
            re_dir[key] = re_dir[key].concat re_common_arr
        if tmp_common_arr
          re_dir[emp.ADAPTER_PLT_D] = tmp_common_arr
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
          tmp_entry = check_base_file(tmp_all_dir, cha_id)
          if tmp_entry.length > 0
            re_dir.length+=1
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
    []

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
        re_acc.push(resource_entry(dest_path, show_path, dir_name))
        check_file(dir_acc, re_acc, type)
  else
    re_acc

resource_entry = (dest_path, show_path, file_name) ->
  {dest_path:dest_path, show_path:show_path, name:file_name}

package_entry = (file_com, f_type) ->
  {file_arr:file_com, type:f_type}
