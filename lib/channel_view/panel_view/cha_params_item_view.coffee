{$, $$, View} = require 'atom'
EmpEditView = require '../../view/emp-edit-view'
emp = require '../../exports/emp'

module.exports =
class ParamsItemPanel extends View
  ex_state:true
  @content: ->
    @div class:'p_param_div', =>
      @ul class:'off_ul', =>
        @li class:'off_li', =>
          @span "参数名称:"
          @subview "ekey", new EmpEditView(attributes: {id: 'key', type: 'string'},  placeholderText: 'Key')
        @li class:'off_li', =>
          @span "参数值:"
          @subview "evalue", new EmpEditView(attributes: {id: 'value', type: 'string'},  placeholderText: 'Value')
        @button class: 'off_ul_btn btn btn-info inline-block-tight', click:'destroy',' Delete '

  initialize: ->
    # console.log "item arg view"
    @ex_state = true

  destroy: ->
    @ex_state = false
    @detach()

  focus: ->
    @ekey.focus()


  submit_detail: ->
    tmp_key = @ekey.getEditor().getText().trim()
    tmp_value = @evalue.getEditor().getText().trim()
    {key:tmp_key, value:tmp_value}
