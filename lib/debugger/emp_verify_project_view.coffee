{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
emp = require '../exports/emp'
fs_plus = require 'fs-plus'
path = require 'path'
_ = require 'underscore-plus'

module.exports =
class VerifyProjectView extends View

  @content: ()->

    @div outlet:'verify_detail_div', class:'verify-pro-view  overlay from-top', =>
      @div class:'verify_detail_panel panel', =>
        @h1 "Edit KeyMaps' Detail", class: 'panel-heading'
        @div class:'bar_div', =>
          @button class: 'btn-warning btn  inline-block-tight btn_right', click: 'do_cancel', 'Cancel'

      @div class: 'pack_detail_info', =>
        @div class:'div_box_r', =>
          @h4 class:'lab text-highlight', "注意:"
        @div class:'div_box_r', =>
          @label outlet:"pack_name", class:'lab text-highlight', "请确认你的工程路径是否为工程根路径,
          以保证创建文件相关链接的准确性."

        @div class: 'pack_detail_info',  =>
          @div class: 'div_box_r', =>
            @h4 class:'lab text-highlight',"工程路径:"
          @div =>
            @subview "project_path", new TextEditorView(mini: true,attributes: {id: 'project_path', type: 'string'},  placeholderText: ' Insert Key Map')

        @div class: 'pack_detail_info',  =>
          @div class: 'div_box_r', =>
            @button "Chose Path", class: "btn btn-primary", click: 'do_chose_path'

      @div class:'verify_detail_foot', =>
        @button "Done", class: "createSnippetButton btn btn-primary", click:'do_input'
        @button "Cancel", class: "createSnippetButton btn-warning btn btn-primary", click:'do_cancel'
        # @button "test", class: "createSnippetButton btn-warning btn btn-primary", click:'do_test'

  initialize: () ->
    @cbb_management = atom.project.cbb_management

  handle_event: ->
    @validate_fields()
    @on 'keydown', (e) =>
      if e.which is emp.ESCAPEKEY
        @detach()

  toggle: (@pro_path, @callback)->
    if @isVisible()
      @detach()
    else
      @show_view(@pro_path, @callback)

  show_view: (@pro_path, @callback)->
    # console.log " show this "
    # console.log pack
    if @hasParent()
      @show()
    else
      atom.workspace.addTopPanel(item: this)
    @refresh_show_view()

  refresh_show_view: ()->
    @project_path.setText @pro_path

  hide_view: ()->
    @hide()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  do_cancel: ->
    @destroy()

  do_input: ->
    if project_path = @project_path.getText()?.trim()
      # console.log project_path
      # console.log fs_plus.isDirectorySync project_path
      unless !fs_plus.isDirectorySync project_path
        @callback(project_path)
        @destroy()
        return
      emp.show_error "工程路径不存在(或者为非法路径)!"
    else
      emp.show_error "工程路径不能为空!"



  do_chose_path: ->
    # console.log "------"
    emp.chose_path ["openDirectory"], @pro_path , (cho_path) =>
      @project_path.setText cho_path


  show_alert: (msg) ->
    atom.confirm
      message: '警告'
      detailedMessage:msg
      buttons:
        '取消': -> return 3
        '替换': -> return 2
        '合并': -> return 1
