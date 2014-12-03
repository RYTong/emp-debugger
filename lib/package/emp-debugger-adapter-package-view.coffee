{$, $$, View} = require 'atom'
ZipWriter = require("moxie-zip").ZipWriter
# os = require 'os'
path = require 'path'
fs = require 'fs'
# c_process = require 'child_process'
emp = require '../exports/emp'

PackageBarView = require './emp-debugger-package-bar-view'
PackageAdpView = require './emp-debugger-pkg-adp-view'
tmp_offline_path = null

module.exports =
class EmpDebugAdpPackageView extends View

  @content: ->
    @div outlet: 'cha_detail', class: 'emp-setting-row', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "Adapter Package"
      @div outlet:"emp_cha_btns", class: "emp-setting-con panel-body padded",  =>
        @button class: 'btn btn-else btn-info inline-block-tight', click: 'do_package', "Package Adapters Resource"
        @button class: 'btn btn-else btn-info inline-block-tight', click: 'do_union_package', "Package An Union Package"
        @button class: 'btn btn-else btn-info inline-block-tight', click: 'show_detail', "test"
        @button class: 'btn btn-else btn-info inline-block-tight', click: 'show_detail2', "test2"

  initialize: ->
    unless tmp_offline_path = atom.config.get(emp.EMP_OFFLINE_RELATE_DIR)
      tmp_offline_path = emp.EMP_OFFLINE_RELATE_PATH_V

    @emp_debugger_bar = new PackageBarView()
    @emp_debugger_adp_pkg = new PackageAdpView()
    this

  # 打普通资源包
  do_package: ->
    project_path = atom.project.getPath()
    offline_path = path.join project_path, tmp_offline_path
    gather_common_files(offline_path)

  #  打普通资源整合包，即把普通资源报再压缩为一个压缩包
  do_union_package: ->
    project_path = atom.project.getPath()
    offline_path = path.join project_path, tmp_offline_path
    package_union_package(offline_path)

  show_detail: ->
    console.log "show_detail"
    @emp_debugger_bar.show_view("test")

  show_detail2: ->
    console.log "show_detail2"
    @emp_debugger_adp_pkg.show_view("test")

union_package_index = 0
union_package_pkgs = []
package_union_package = (adapter_dir)->
  try
    #  全局变量初始化
    # 通过判断 union_package_index，来判断生成 综合包的时机
    union_package_pkgs = []
    union_package_index = 0

    re_dir = check_dir(adapter_dir)
    union_package_index = re_dir.length
    delete re_dir.length


    for key, value of re_dir
      if value.length isnt 0
        create_adapter_zip(key, value, emp.ADAPTER_UNION_PACKAGE_CHEAD, true)
      else
        union_package_index -= 1
  catch e
      console.error e
      emp.show_error(e)

gather_common_files = (adapter_dir)->
  try
    union_package_index = 0
    re_dir = check_dir(adapter_dir)
    union_package_index = re_dir.length
    delete re_dir.length

    for key, value of re_dir
      if value.length isnt 0
        create_adapter_zip(key, value)
      else
        union_package_index -= 1
  catch e
      console.error e
      emp.show_error(e)

# @doc check the root and base dir for adapter channel
check_dir = (adapter_dir) ->
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
          check_root_dirs(adapter_dir, tmp_dir, re_dir)
    # console.log re_dir
    re_dir
  else
    throw emp.EMP_PACKAGE_UNION_PKG_DIR_ENOENT

check_root_dirs = (adapter_dir, root_path, re_dir) ->
  if root_path is emp.ADAPTER_PLT_D
    tmp_all_dir = path.join(adapter_dir, root_path)
    re_dir.length+=1
    re_dir[root_path] = check_base_file(tmp_all_dir)
    # path.join(RootPath, root_path)
  else
    dir_children = fs.readdirSync path.join(adapter_dir, root_path)
    for tmp_dir in dir_children
      if !tmp_dir.match(/^\..*/ig)
        tmp_type = path.join root_path, tmp_dir
        tmp_all_dir = path.join(adapter_dir, tmp_type)
        tmp_state = fs.statSync(tmp_all_dir)
        if tmp_state?.isDirectory()
          re_dir.length+=1
          re_dir[tmp_type] = check_base_file(tmp_all_dir)
    # console.log re_dir

check_base_file = (dest_path) ->
  # console.log "check base file :#{dest_path}"
  re_acc = new Array()
  dir_acc = new Array()
  dir_children = fs.readdirSync dest_path
  for tmp_dir in dir_children
    dir_acc.push [tmp_dir, dest_path]
  # console.log dir_acc
  result = check_file(dir_acc, re_acc)
  # console.log "result :#{result}"
  result

check_file  = (dir_acc, re_acc) ->
  # dir_children = fs.readdirSync dest_path
  # for tmp_dir in dir_children
  # console.log dir_acc
  # console.log re_acc
  if dir_acc.length isnt 0
    [dir_name, fa_path] = dir_acc.pop()
    # console.log "dir_name:#{dir_name}, fa_path:#{fa_path}"
    if dir_name is emp.OFF_DEFAULT_BASE
      check_file(dir_acc, re_acc)
    else if dir_name.match(/^\..*/ig)
      check_file(dir_acc, re_acc)
    else
      dest_path = path.join fa_path, dir_name
      tmp_state = fs.statSync(dest_path)
      # console.log  dest_path
      if tmp_state?.isDirectory()
        dir_children = fs.readdirSync dest_path
        tmp_acc = new Array()
        for tmp_dir in dir_children
          dir_acc.push [tmp_dir, dest_path]
        check_file(dir_acc.concat(tmp_acc), re_acc)
      else
        re_acc.push(dest_path)
        check_file(dir_acc, re_acc)
  else
    re_acc



create_adapter_zip = (package_type, file_list, extra_header="", sync_flag=false) ->
  # console.log "create adapter zip :#{package_type}"
  project_path = atom.project.getPath()

  tmp_path = path.join project_path, "tmp"
  emp.mkdir_sync tmp_path
  package_type.split("/").join(".")

  f_name = extra_header+([emp.ADAPTER_PACKAGE_HEAD].concat package_type.split("/")).join(".")
  fe_name = f_name + ".zip"
  re_pa = path.join tmp_path, fe_name
  zip = new ZipWriter()
  for tmp_file in file_list
    tmp_file_name = path.basename tmp_file
    tmp_file_name = path.join f_name, path.basename(path.dirname tmp_file), tmp_file_name
    console.log tmp_file_name
    zip.addFile(tmp_file_name, tmp_file)
  if sync_flag
    union_package_pkgs.push(re_pa)
    zip.saveAs(re_pa, () ->
      union_package_index-=1
      #  console.log union_package_index
      if union_package_index is 0
        common_zip(union_package_pkgs, emp.ADAPTER_UNION_PACKAGE_NAME)
      console.log "zip written."
      )
  else
    zip.saveAs(re_pa, () ->
      union_package_index-=1
      if union_package_index is 0
        emp.show_info emp.EMP_PACKAGE_PKG_SUCCESS
      console.log "zip written."
      )
  re_pa


common_zip = (file_list, zip_name = emp.DEFAULT_ZIP_FULE_NAME) ->
  project_path = atom.project.getPath()
  tmp_path = path.join project_path, "tmp"
  re_pa = path.join tmp_path, zip_name

  zip = new ZipWriter()
  for tmp_file in file_list
    tmp_file_name = path.basename tmp_file
    # tmp_dir_name = path.dirname tmp_file
    # tmp_file_name = path.join path.basename(path.dirname tmp_file), tmp_file_name
    zip.addFile(tmp_file_name, tmp_file)
  zip.toBuffer((buf) ->
    )

  zip.saveAs(re_pa, () ->
     console.log "zip written."
    )
  emp.show_info emp.EMP_PACKAGE_UNION_PKG_SUCCESS
