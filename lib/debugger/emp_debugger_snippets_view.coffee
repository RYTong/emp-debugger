{$, $$, View} = require 'atom-space-pen-views'
fs = require 'fs'
fs_plus = require 'fs-plus'
path = require 'path'
# c_process = require 'child_process'
emp = require '../exports/emp'

VerifyProjectView = require './emp_verify_project_view'

module.exports =
class EmpSnippetsView extends View

  @content: ->
    @div class: 'emp-setting-row-snip', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "添加调试文件关联"

      @div outlet:"emp_log_pane", class: "emp-setting-con panel-body padded", =>
        @div class: "emp-set-div-content", =>
          @label class: "emp-setting-label", "如果当前 lua 或者 xhtml 文件并非由 Atom 创建,同时您想使用文件关联保存功能, 请点击这里添加文件关联语句. "
          @label class: "emp-setting-label", "If the lua and xthml isn't created by emp-debugger.And you wants the down-debugger-file assosiate with the file entry, you can use this button."

        @div class: "emp-set-div-content", =>
          @button class: 'btn btn-else btn-info inline-block-tight', click: 'add_link', "Add Relate Link For File"
          @button class: 'btn btn-else btn-info inline-block-tight', click: 'add_link_for_all', "Add Relate Link For All Files"

  initialize: ->
    @verify_view = new VerifyProjectView()
    this

  add_link_for_all: ->
    console.log " add snippet for all"
    project_path = emp.get_project_path()
    @verify_view.toggle project_path, (@project_path) =>
      fs_plus.traverseTree @project_path, @on_file, @on_dir, @on_done

  on_file: (file_path)=>
    # console.log "file"
    # console.log file_path
    # console.log @project_path
    file_ext  = path.extname(file_path?='')?.toLowerCase()
    relative_path = path.relative @project_path, file_path
    # 判断文件类型,目前基本只支持 xhtml 和 lua

    if file_ext is emp.DEFAULT_EXT_XHTML
      replace_con = emp.DEFAULT_TEMP_HEADER
      do_check_file(file_path, relative_path, replace_con)
    else if file_ext is emp.DEFAULT_EXT_LUA
      replace_con = emp.DEFAULT_LUATEMP_HEADER
      do_check_file(file_path, relative_path, replace_con)
    else if file_ext is emp.DEFAULT_EXT_CSS
      replace_con = emp.DEFAULT_CSSTEMP_HEADER
      do_check_file(file_path, relative_path, replace_con)
    true

  on_dir: (param)->
    # console.log "dir"
    # console.log param
    true

  on_done: (param)->
    # console.log "done"
    # console.log param
    emp.show_info "全工程添加文件关联完成."
    true


  add_link: ->
    console.log "add_link"
    editor = atom.workspace.getActiveTextEditor()
    project_path = emp.get_project_path()

    if editor
      text_path = editor.getPath()
      text_ext  = path.extname(text_path?='').toLowerCase()
      relative_path = path.relative project_path, text_path
      # console.log project_path

      replace_con = ''

      editor_text = editor.getText()
      if editor_text.match /\<atom_emp_related_file_info\>[^\<]*\<\/atom_emp_related_file_info\>/ig
        replace_con = emp.DEFAULT_HEADER_CON
        replace_con = replace_con.replace(/\$\{atom_related_info\}/ig, relative_path)
        editor_text = editor_text.replace /\<atom_emp_related_file_info\>[^\<]*\<\/atom_emp_related_file_info\>/ig, replace_con
        editor.setText editor_text

      else
        # 判断文件类型,目前基本只支持 xhtml 和 lua
        if text_ext is emp.DEFAULT_EXT_XHTML
          replace_con = emp.DEFAULT_TEMP_HEADER

          do_add(replace_con, relative_path, editor)
        else if text_ext is emp.DEFAULT_EXT_LUA
          replace_con = emp.DEFAULT_LUATEMP_HEADER
          do_add(replace_con, relative_path, editor)
        else if text_ext is emp.DEFAULT_EXT_CSS
          replace_con = emp.DEFAULT_CSSTEMP_HEADER
          do_add(replace_con, relative_path, editor)
        else
          replace_con = emp.DEFAULT_HEADER
          @show_alert(replace_con, relative_path, editor)


  # 如果为非 lua 或者 xhtml ,提示是否强制添加
  show_alert: (replace_con, relative_path, editor) ->
    atom.confirm
      message: '文件类型警告!'
      detailedMessage: '判断当前文件类型不是 Xhtml, Lua或者 Css, 该文件关联并不支持该文件类型.是否继续添加?'
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

do_check_file = (file_path, relative_path, replace_con) ->
  # console.log "check file"
  temp_con = fs.readFileSync(file_path, 'utf-8')
  if temp_con.match /\<atom_emp_related_file_info\>[^\<]*\<\/atom_emp_related_file_info\>/ig
    replace_con = emp.DEFAULT_HEADER_CON
    replace_con = replace_con.replace(/\$\{atom_related_info\}/ig, relative_path)
    temp_con = temp_con.replace /\<atom_emp_related_file_info\>[^\<]*\<\/atom_emp_related_file_info\>/ig, replace_con
  else
    file_footer = replace_con.replace(/\$\{atom_related_info\}/ig, relative_path)
    temp_con = temp_con+file_footer
  fs.writeFileSync file_path, temp_con, 'utf-8'
