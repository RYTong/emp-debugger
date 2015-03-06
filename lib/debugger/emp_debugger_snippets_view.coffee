{$, $$, View} = require 'atom-space-pen-views'
fs = require 'fs'
path = require 'path'
# c_process = require 'child_process'
emp = require '../exports/emp'

module.exports =
class EmpSnippetsView extends View

  @content: ->
    @div class: 'emp-setting-row', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "添加调试文件关联"

      @div outlet:"emp_log_pane", class: "emp-setting-con panel-body padded", =>
        @div class: "emp-set-div-content", =>
          @label class: "emp-setting-label", "如果当前 lua 或者 xhtml 文件并非由 Atom 创建,同时您想使用文件关联保存功能, 请点击这里添加文件关联语句. "
        @div class: "emp-set-div-content", =>
          @button class: 'btn btn-else btn-info inline-block-tight', click: 'add_snippet', "Add Snippet"

  initialize: ->
    this

  add_snippet: ->
    console.log "add_snippet"
    editor = atom.workspace.getActiveEditor()
    project_path = atom.project.getPath()
    if editor
      text_path = editor.getPath()
      text_ext  = path.extname(text_path?='').toLowerCase()
      relative_path = path.relative project_path, text_path
      # console.log project_path

      replace_con = ''
      # 判断文件类型,目前基本只支持 xhtml 和 lua
      if text_ext is emp.DEFAULT_EXT_XHTML
        replace_con = emp.DEFAULT_TEMP_HEADER
        do_add(replace_con, relative_path, editor)
      else if text_ext is emp.DEFAULT_EXT_LUA
        replace_con = emp.DEFAULT_LUATEMP_HEADER
        do_add(replace_con, relative_path, editor)
      else
        replace_con = emp.DEFAULT_HEADER
        @show_alert(replace_con, relative_path, editor)


  # 如果为非 lua 或者 xhtml ,提示是否强制添加
  show_alert: (replace_con, relative_path, editor) ->
    atom.confirm
      message: '文件类型警告!'
      detailedMessage: '判断当前文件类型不是 xhtml 或者 Lua, 该文件关联并不支持该文件类型.是否继续添加?'
      buttons:
        '是': -> do_add(replace_con, relative_path, editor)
        '否': -> return

# 插入代码段到第二行
do_add = (replace_con, relative_path, editor)->
    last_cursor = editor.getLastCursor()
    # cursor_point = last_cursor.getBufferRow()
    # cursor_screeen_point = last_cursor.getScreenRow()
    # editor.moveUp(cursor_screeen_point)
    last_cursor.setBufferPosition([1,0], autoscroll:true)
    last_cursor.setVisible()
    file_header = replace_con.replace(/\$\{atom_related_info\}/ig, relative_path)
    console.log "insert: #{file_header}"
    editor.insertText file_header, autoIndentNewline:true,select:true
