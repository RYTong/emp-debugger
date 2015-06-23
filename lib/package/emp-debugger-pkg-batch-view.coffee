{$, $$, View} = require 'atom-space-pen-views'
remote = require 'remote'
dialog = remote.require 'dialog'
ZipWriter = require("moxie-zip").ZipWriter
event = (require 'events').EventEmitter

path = require 'path'
fs = require 'fs'
emp = require '../exports/emp'
EmpPkgEle = require './emp-debugger-pkg-batch-ele-view'

project_path = ''
tmp_offline_path = ''

module.exports =
class EmpPkgAdpView extends View
  element_arr:new Array()
  @content: ->
    # console.log "constructor" overlay
    @div class: "emp-debugger panel bordered", =>
      @div class: "panel-heading", '批量下载', =>
        # @button class: 'btn inline-block emp-btn-cancel', click: 'process_cancel', "取消"
        # @button class: 'btn inline-block emp-btn-ok', click: 'process_start', "打包"
        @div class: 'emp-btn-div-ab', =>
          @button class: 'btn inline-block emp-btn-sel', click: 'checked_all', "全选"
          @button class: 'btn inline-block emp-btn-sel', click: 'unchecked_all', "反选"

      @div outlet:'fa_div', class: "panel-body padded file_panel", =>
        # @table class:"table_panel",border:"1",frame:"hsides",rules:"groups", =>
        @table outlet:'fa_div', class:"panel-body padded table_panel",border:"1",frame:"hsides", rules:"groups",=>
          # @caption 'My Ultimate Table'
          @colgroup span:"2"
          @colgroup span:"1"
          @thead =>
            @tr =>
              @td 'Id'
              @td 'Name'
              @td 'Sel'
          @tbody outlet:"detail_body", =>
      @div class: 'emp-btn-div', =>
        @button class: 'btn inline-block emp-btn-cancel', click: 'process_cancel', "取消"
        @button class: 'btn inline-block emp-btn-ok', click: 'process_start', "打包"


  initialize: () ->
    # console.log @cha_obj
    project_path = atom.project.getPaths()[0]
    unless tmp_offline_path = atom.config.get(emp.EMP_OFFLINE_RELATE_DIR)
      tmp_offline_path = emp.EMP_OFFLINE_RELATE_PATH_V

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  show_view: (@fa_view, @cha_obj)->
    # console.log "EmpDebuggerView was toggled!"
    # if @emp_socket_server.get_server() is null
    if @hasParent()
      @detach()
    else
      # @initial_channel_panel(cha_id, cha_obj)
      @detail_body.empty()
      for key, tmp_obj of @cha_obj
        emp_ele = new EmpPkgEle(this, tmp_obj)
        @element_arr.push emp_ele
        @detail_body.append emp_ele
      atom.workspaceView.append(this) # unless @emp_socket_server.server isnt null

  # @doc 全选所有选项
  checked_all: (event, element) ->
    console.log "checked all"
    # console.log @detail_body
    # console.log @detail_body.ch`ildren()
    for tmp_ele in @element_arr
      tmp_ele.do_checked()

  # @doc 反选所有选项
  unchecked_all: (event, element) ->
    console.log "unchecked all"
    # tmp_children = @detail_body.children()
    # unless !tmp_children.length
    for tmp_ele in @element_arr
      tmp_ele.do_unchecked()


  process_cancel: (event, element) ->
    # console.log element
    # console.log "Cancel Preparing #{element.name} for launch!"
    @detach()

  # @doc 打所有资源包
  process_start:(event, element) ->
    console.log "--package start--"
    re_arr = []
    for tmp_ele in @element_arr
      # console.log tmp_ele.checked_state
      unless !tmp_ele.checked_state
        re_arr.push tmp_ele.cha_obj.id
    console.log "package channels:#{re_arr}"
    @initial_channel(re_arr)

  # @doc 执行
  initial_channel: (cha_arr) ->
    try
      # console.log "initial_channel_panel:#{cha_id}"
      adapter_dir = path.join(project_path,tmp_offline_path)
      if fs.existsSync adapter_dir
        dir_children = fs.readdirSync adapter_dir
        new_dir_children = []
        for tmp_dir in dir_children
          if !tmp_dir.match(/^\..*/ig)
            tmp_all_dir = path.join(adapter_dir, tmp_dir)
            tmp_state = fs.statSync(tmp_all_dir)
            if tmp_state?.isDirectory()
              new_dir_children.push tmp_dir

        path_arr = []
        for tmp_dir in new_dir_children
          check_root_dirs(adapter_dir, tmp_dir, path_arr)

        result_arr = []
        # console.log cha_arr
        for cha_id in cha_arr
          tmp_entry = check_dir(cha_id, path_arr)
          result_arr = result_arr.concat(tmp_entry) unless !tmp_entry
        package_recurrence(result_arr)
      else
        throw emp.EMP_PACKAGE_UNION_PKG_DIR_ENOENT
    catch e
      console.log e
      throw e

package_buf_arr = []
package_recurrence = (all_entry) ->
  package_buf_arr = []
  # console.log all_entry
  do_package_recurrence(all_entry)

do_package_recurrence = (all_entry) ->
  # console.log "package_recurrence"
  if all_entry.length > 0
    tmp_entry = all_entry.pop()
    ele_zip = new ZipWriter()
    for tmp_file in tmp_entry.v
      ele_zip.addFile(tmp_file.show_path, tmp_file.dest_path)
    ele_zip.toBuffer((tmp_buf) ->
        # console.log tmp_entry.k
        package_buf_arr.push({name:tmp_entry.k, buf:tmp_buf})
        do_package_recurrence(all_entry)
      )
  else
    package_result(package_buf_arr)

package_result= (file_list, zip_name = emp.DEFAULT_ZIP_FULE_NAME) ->
  tmp_path = path.join project_path, "tmp"
  re_pa = path.join tmp_path, zip_name
  zip = new ZipWriter()
  for tmp_obj in file_list
    zip.addData(tmp_obj.name, tmp_obj.buf)

  zip.saveAs(re_pa, () ->
     console.log "zip written."
    )
  emp.show_info emp.EMP_PACKAGE_UNION_PKG_SUCCESS


# @doc check the root and base dir for adapter channel
check_root_dirs = (adapter_dir, root_path, re_arr) ->
  # ADAPTER_PLT_D is "common"
  if root_path is emp.ADAPTER_PLT_D
    tmp_all_dir = path.join(adapter_dir, root_path)
    re_arr.push {k:root_path, v:tmp_all_dir}
  else
    dir_children = fs.readdirSync path.join(adapter_dir, root_path)
    for tmp_dir in dir_children
      if !tmp_dir.match(/^\..*/ig)
        tmp_type = path.join root_path, tmp_dir
        tmp_all_dir = path.join adapter_dir, tmp_type
        tmp_state = fs.statSync(tmp_all_dir)
        if tmp_state?.isDirectory()
          re_arr.push {k:tmp_type, v:tmp_all_dir}
  re_arr

check_dir = (cha_id, dir_arr) ->
  re_dir = {length:0}
  for tmp_obj in dir_arr
    tmp_entry = check_base_file(tmp_obj.v, cha_id)
    re_dir[tmp_obj.k]= tmp_entry
    re_dir.length+=1
  if re_dir.length > 0
    delete re_dir.length
    new_re_arr = []
    if tmp_common_arr = re_dir[emp.ADAPTER_PLT_D]
      zip_file_name = get_pkg_name(".zip", cha_id, emp.ADAPTER_PLT_D)
      new_re_arr.push {k:zip_file_name, v:re_dir[emp.ADAPTER_PLT_D]}
      delete re_dir[emp.ADAPTER_PLT_D]
      for key,tmp_value of re_dir
        # console.log key, tmp_value
        tmp_file_arr = new Array()
        for tmp_obj in tmp_value
          tmp_file_arr.push tmp_obj.name

        re_common_arr = tmp_common_arr.filter (ele) ->
          tmp_flag = tmp_file_arr.indexOf ele.name
          tmp_flag is -1

        zip_file_name = get_pkg_name(".zip", cha_id, key)
        if re_common_arr
          new_re_arr.push {k:zip_file_name, v:re_dir[key].concat re_common_arr}
        else
          new_re_arr.push {k:zip_file_name, v:re_dir[key]}
    else
      for key,tmp_value of re_dir
        zip_file_name = get_pkg_name(".zip", cha_id, key)
        new_re_arr.push {k:zip_file_name, v:re_dir[key]}

    new_re_arr
  else
    null


check_base_file = (dest_path, cha_id) ->
  # console.log "check base file :#{dest_path}"
  re_acc = new Array()
  dir_acc = new Array()

  cha_path = path.join dest_path,emp.OFF_DEFAULT_BASE, cha_id
  if fs.existsSync cha_path
    dir_children = fs.readdirSync cha_path
    for tmp_dir in dir_children
      dir_acc.push [tmp_dir, cha_path, cha_id]

    result = check_file(dir_acc, re_acc)
    result
  else
    []

check_file  = (dir_acc, re_acc, type) ->
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

get_pkg_name = (ext, cha_id, adp_type) ->
  name_type = adp_type.split "/"
  if name_type.length > 1
    zip_file_name = [cha_id ,name_type[0],name_type[1].split("*").join("-")].join(".")+ext
  else
    zip_file_name = cha_id+"."+name_type[0]+ext
  zip_file_name
