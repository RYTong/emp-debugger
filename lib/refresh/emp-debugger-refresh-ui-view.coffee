{$, $$, View} = require 'atom-space-pen-views'
emp = require '../exports/emp'
fs = require 'fs'
path = require 'path'

module.exports =
class EmpUIRefreshWizardView extends View

  @content: ->
    @div class: 'emp-setting-row-two', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "Refresh"
      @div class: "emp-setting-con panel-body padded",  =>
        @div class: "emp-set-div-content", =>
          @label class: "emp-setting-label", "用于刷新 EMP App 的公共样式,请在使用 UI_lib 的 EMP App 下使用.同时请不要修改添加的样式文件,刷新时,会被覆盖."

        @div class: "emp-set-div-content", =>
          @button class: 'btn btn-else btn-info inline-block-tight', click: 'refresh_ui', "Refresh UI Lib"

  initialize: ->
    this

  refresh_ui: ->
    project_path = atom.project.getPaths()[0]
    dest_path = path.join project_path, emp.STATIC_UI_CSS_TEMPLATE_DEST_PATH
    basic_dir = path.join __dirname, '../../', emp.STATIC_UI_CSS_TEMPLATE
    css_con = fs.readFileSync basic_dir, 'utf8'

    tmp_dest_path = path.dirname dest_path
    if !fs.existsSync tmp_dest_path
      emp.mkdir_sync_safe tmp_dest_path

    fs.writeFileSync(dest_path, css_con, 'utf8')
