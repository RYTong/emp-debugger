{$, $$, View, TextEditorView} = require 'atom'
# EmpEditView = require '../../view/emp-edit-view'
emp = require '../../exports/emp'
item_obj = require '../emp_item/channel_adapter_param'

module.exports =
class AdapterArgPanel extends View
  cha_obj:null
  ex_state:true

  @content: ->
    @div class:'off_pdiv' ,=>
      @ul class:'off_pul', =>
        @li class:'off_pli', =>
          @span "取值参数名:"
          @subview "arg_key", new TextEditorView(mini: true, attributes: {id: 'arg_key', type: 'string'},  placeholderText: 'Param Key')
        @li class:'off_pli', =>
          @span "请求参数名:"
          @subview "ra_key", new TextEditorView(mini: true, attributes: {id: 'ra_key', type: 'string'},  placeholderText: 'Rquest Param Key')
        @li class:'off_pli', =>
          @span "取值方式:"
          @select outlet: "off_param", class: "form-control", =>
            @option value: emp.ADAPTER_ARG_M_P, selected:"selected", "param"
            @option value: emp.ADAPTER_ARG_M_A, "arg"
            @option value: emp.ADAPTER_ARG_M_S, "session"
        @button class: 'off_pbtn btn btn-info inline-block-tight', click:'destroy',' Delete '

  initialize: (@cha_obj)->
    # console.log "item arg view"
    @ex_state = true

  focus: ->
    @arg_key.focus()

  destroy: ->
    @ex_state = false
    @detach()

  submit_detail: ->
    tmp_key = @arg_key.getEditor().getText().trim()
    tmp_rkey = @ra_key.getEditor().getText().trim()
    tmp_type = @off_param.val()
    new item_obj(tmp_key, tmp_rkey, tmp_type)
