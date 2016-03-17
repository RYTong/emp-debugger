{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
emp = require '../exports/emp'
path = require 'path'
# arg_view = require './adapter_item_arg_view'
# adapter_obj = require '../emp_item/channel_adapter'

module.exports =
class AddLessOption extends View

  @content: ->
    @div class:'off_param_item_div', =>
      @ul outlet:'import_options', class:'off_ul', =>

        @li class:'off_li', =>
          @subview "import_option", new TextEditorView(mini: true, attributes: {id: 'import_option', type: 'string'},  placeholderText: 'Import File...')
        @button class: 'off_le_btn btn btn-info inline-block-tight', click:'add_one',' Add '
        @button class: 'off_le_btn btn btn-primary inline-block-tight', click:'destroy',' Delete '


  initialize: (@sDefaultText, @bStoreFlag=true)->
    # console.log "new import ...."
    @bStatue = true
    @bValidateType=true
    @import_option.getModel().onDidStopChanging =>
      @validate_fields(@import_option)

    @import_option.setText @sDefaultText unless !@sDefaultText
    project_path_list = atom.project.getPaths()
    @project_path = project_path_list?[0]

  focus: ->
    @import_option.focus()

  add_one: ->
    # @project_path
    emp.chose_path_f '', (sOptionPath) =>
      @import_option.setText(sOptionPath)
      # @validate_fields(@import_option)

  validate_fields: (vValiView)->
      sOptionPath = vValiView.getText()
      validate = (input, el) =>
        sExtName = path.extname(input).toLocaleLowerCase()
        # console.log sExtName
        if sExtName is '.less' or sExtName is '.css'
          # console.log "validate------"
          @bValidateType = true
          el.addClass "valid"
          el.removeClass "invalid"
        else
          # console.log "invalid------"
          @bValidateType = false
          # console.log @bValidateType
          el.addClass "invalid"
          el.removeClass "valid"
      validate sOptionPath, vValiView


  destroy: ->
    @bStatue = false
    @detach()

  check_validate: ->
    @bValidateType

  check_statue: ->
    @bStatue

  check_store: ->
    @bStoreFlag

  submit_detail: ->
    # console.log @bValidateType
    sOptionPath = @import_option.getText()
    sOptionPath
