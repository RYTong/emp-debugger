{$, $$, View} = require 'atom-space-pen-views'
emp = require '../exports/emp'
fs = require 'fs'
fs_plus = require 'fs-plus'
path = require 'path'

module.exports =
class EmpUIRefreshWizardView extends View

  @content: ->
    @div class: 'emp-setting-row-two', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "Refresh"
      @div class: "emp-setting-con panel-body padded",  =>
        @div class: "emp-set-div-content", =>
          @label class: "emp-setting-label", "用于刷新 EMP App 的公共样式,请在使用 UI_lib 的 EMP App 下使用.同时请不要修改添加的样式和 Lua文件,刷新时,会被覆盖."

        @div class: "emp-set-div-content", =>
          @button class: 'btn btn-else btn-info inline-block-tight', click: 'refresh_ui', "Refresh UI Lib"

  initialize: ->
    this

  refresh_ui: ->
    project_path = emp.get_project_path()

    @copy_css_ui(project_path)
    @copy_lua_ui(project_path)
    emp.show_info "刷新 UI Lib 成功!"

  # 从 emp template management 中指定的 ui snippet 中复制 eui.css
  copy_css_ui: (to_path) ->
    # dest_path = path.join to_path, emp.STATIC_UI_CSS_TEMPLATE_DEST_PATH
    dest_dir = path.join to_path, emp.STATIC_UI_CSS_TEMPLATE_DEST_DIR
    # basic_dir = path.join __dirname, '../../', emp.STATIC_UI_CSS_TEMPLATE
    # css_con = fs.readFileSync basic_dir, 'utf8'
    # src_dir = emp.get_temp_path()
    # tmp_dest_path = path.dirname dest_path
    if !fs.existsSync dest_dir
      emp.mkdir_sync_safe dest_dir
    tmp_emp = require emp.get_temp_emp_path()
    temp_ui_path = atom.config.get(tmp_emp.EMP_APP_STORE_UI_PATH)
    temp_ui_css_path = path.join temp_ui_path, emp.OFF_EXTENSION_CSS
    if fs.existsSync temp_ui_css_path
      fs_plus.copySync  temp_ui_css_path, dest_dir

  copy_lua_ui: (to_path) ->
    basic_dir = path.join __dirname, '../../', emp.STATIC_UI_LUA_TEMPLATE
    dest_path = path.join to_path, emp.STATIC_UI_LUA_TEMPLATE_DEST_PATH
    lua_con = fs.readFileSync basic_dir, 'utf8'
    tmp_dest_path = path.dirname dest_path
    if !fs.existsSync tmp_dest_path
      emp.mkdir_sync_safe tmp_dest_path
    fs.writeFileSync(dest_path, lua_con, 'utf8')
