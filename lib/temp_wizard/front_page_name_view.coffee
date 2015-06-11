{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
{TextEditorView} = require 'atom-space-pen-views'
# EmpEditView = require '../../view/emp-edit-view'
emp = require '../../exports/emp'

module.exports =
class ParamsItemPanel extends View
  ex_state:true
  @content: ->
    @div class:'p_param_div', =>
      @ul outlet:"item_ul", class:'off_ul', =>
        @li class:'off_li', =>
          @span "Page Name(New Page Name):"
          @subview "ekey", new TextEditorView(mini: true, attributes: {id: 'key', type: 'string'},  placeholderText: 'Key')
        @li class:'off_li', =>
          @span "参数值(Parameter Value):"
          @subview "evalue", new TextEditorView(mini: true, attributes: {id: 'value', type: 'string'},  placeholderText: 'Value')
        @button class: 'off_ul_btn btn btn-info inline-block-tight', click:'destroy',' Delete '

  initialize: (key, val)->
    @ex_state = true
    if key
      @ekey.setText(key)
      @evalue.setText(""+val)
    this


  destroy: ->
    @ex_state = false
    @detach()

  focus: ->
    @ekey.focus()


  submit_detail: ->
    tmp_key = @ekey.getText().trim()
    tmp_value = @evalue.getText().trim()
    {key:tmp_key, value:tmp_value}
