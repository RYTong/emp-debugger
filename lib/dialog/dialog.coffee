{$, TextEditorView, View} = require 'atom-space-pen-views'
path = require 'path'
AddLessOption = require './import-less-item'

module.exports =
class Dialog extends View
  @content: ({prompt, promptOut, promptImport} = {}) ->
    @div class: 'tree-view-dialog',outlet:'tree_view_dialog', =>
      @label prompt, class: 'icon', outlet: 'promptText'
      @subview 'miniEditor', new TextEditorView(mini: true)
      @label promptOut, class: 'icon', outlet: 'outLabelText'
      @ul outlet:'import_options', class:'off_ul', =>
        @li class:'off_li', =>
          @subview 'outEditor', new TextEditorView(mini: true, placeholderText: 'Out File Path')
        @button class: 'off_ul_btn btn btn-info inline-block-tight', click:'do_choice',' Chose '
      @div outlet:'importLabelText', =>
        @label promptImport, class: 'icon', outlet: 'importLabelText'
      @div class:'off_param_div', outlet:'import_less_list'
      @button class: 'btn btn-else btn-info inline-block-tight', click: 'add_import', "Add an Less"

      @div class: 'error-message', outlet: 'errorMessage'
      @button class: 'btn btn-else btn-info inline-block-tight', click: 'close', "Cancel"
      @button class: 'btn btn-else btn-info inline-block-tight', click: 'do_ok', "Ok"

  initialize: ({initialPath, outPath, select, iconClass} = {}) ->
    @promptText.addClass(iconClass) if iconClass
    @outLabelText.addClass(iconClass) if iconClass


    @store_less_list = []
    atom.commands.add @element,
      'core:confirm': => @do_ok()
      'core:cancel': => @cancel()

    @bOEditorFocus = false
    @bMEditorFocus = false

    @miniEditor.getModel().onDidChange =>
      sLessName = @miniEditor.getModel().getText()
      sOutLessName = @outEditor.getModel().getText()
      if sLessExt = path.extname sLessName
        sLessBaseName = path.basename sLessName, sLessExt
        sOutExt = path.extname sOutLessName
        sOutBaseName = path.dirname sOutLessName
        sOutLessName = path.join sOutBaseName, sLessBaseName+sOutExt
        @outEditor.getModel().setText(sOutLessName)
      @showError()
    @miniEditor.getModel().setText(initialPath)
    @outEditor.getModel().setText(outPath)

    if select
      extension = path.extname(initialPath)
      baseName = path.basename(initialPath)
      if baseName is extension
        selectionEnd = initialPath.length
      else
        selectionEnd = initialPath.length - extension.length
      range = [[0, initialPath.length - baseName.length], [0, selectionEnd]]
      @miniEditor.getModel().setSelectedBufferRange(range)

  attach: ->
    @panel = atom.workspace.addModalPanel(item: this.element)
    @miniEditor.focus()
    @miniEditor.getModel().scrollToCursorPosition()

  close: ->
    panelToDestroy = @panel
    @panel = null
    panelToDestroy?.destroy()
    atom.workspace.getActivePane().activate()

  cancel: ->
    @close()
    $('.tree-view').focus()

  showError: (message='') ->
    @errorMessage.text(message)
    @flashError() if message

  add_import: =>
    oImportLess = new AddLessOption()
    @store_less_list.push oImportLess
    @import_less_list.append oImportLess


  do_ok: =>
    sLessName = @miniEditor.getText()
    sOutName = @outEditor.getText()

    lLessList = []
    for oImportLess in @store_less_list
      if oImportLess.check_statue()
        if sImportName = oImportLess.submit_detail()
          lLessList.push sImportName
    @onConfirm(sLessName, sOutName, lLessList)
