{$, $$, View, TextEditorView} = require 'atom'
# EmpEditView = require '../../view/emp-edit-view'
emp = require '../../exports/emp'
arg_view = require './adapter_item_arg_view'
adapter_obj = require '../emp_item/channel_adapter'

module.exports =
class AdapterItemPanel extends View
  cha_obj:null
  trancode_detail:null
  view_detail:null
  arg_list:[]
  ex_state:null

  @content: ->
    @div class:'off_param_item_div', =>
      @ul outlet:'item_detail', class:'off_ul', =>
        @li class:'off_li', =>
          @span "Trancode:"
          @subview "trancode", new TextEditorView(mini: true, attributes: {id: 'trancode', type: 'string'},  placeholderText: 'Trancode')
        @li class:'off_li', =>
          @span "Adapter:"
          @subview "adapter", new TextEditorView(mini: true, attributes: {id: 'adapter', type: 'string'},  placeholderText: 'Adapter')
        @li class:'off_li', =>
          @span "Procedure:"
          @subview "procedure", new TextEditorView(mini: true, attributes: {id: 'procedure', type: 'string'},  placeholderText: 'Procedure')
        @li class:'off_li', =>
          @span "View:"
          @subview "view_name", new TextEditorView(mini: true, attributes: {id: 'view_name', type: 'string'},  placeholderText: 'View Name')
        @button class: 'off_ul_btn btn btn-info inline-block-tight', click:'add_arg',' Add Arg'
        @button class: 'off_ul_btn btn btn-info inline-block-tight', click:'destroy',' Delete '


  initialize: (@cha_obj, key, val)->
    # console.log "new adapter item"
    @arg_list = []
    @trancode_detail = null
    @view_detail = null
    @ex_state = true
    initial_flag = false
    if typeof(val) is 'string'
      initial_flag = true
      @trancode.getEditor().setText(key)
      @view_name.getEditor().setText(val)
    else if typeof(val) is 'object'
      initial_flag = true
      @trancode.getEditor().setText(key)
      @adapter.getEditor().setText(val.adapter)
      @procedure.getEditor().setText(val.procedure)
      @view_name.getEditor().setText(val.view)

    @trancode.getEditor().on 'contents-modified', =>
      if initial_flag
        initial_flag = false
      else
        @trancode_detail = @trancode.getEditor().getText().trim()
        if @trancode_detail
          @view_detail = @cha_obj.id + '_' + @trancode_detail
          @view_name.getEditor().setText(@view_detail)

  focus: ->
    @trancode.focus()

  add_arg: ->
    tmp_arg_view = new arg_view(@cha_obj)
    @item_detail.after(tmp_arg_view)
    @arg_list.push(tmp_arg_view)
    tmp_arg_view.focus()

  destroy: ->
    @ex_state = false
    @detach()

  submit_detail: ->
    # console.log "adapter submit_detail"
    tmp_tran = @trancode.getEditor().getText().trim()
    tmp_ada = @adapter.getEditor().getText().trim()
    tmp_pro = @procedure.getEditor().getText().trim()
    tmp_view = @view_name.getEditor().getText().trim()
    ada_obj = new adapter_obj(tmp_tran, tmp_ada, tmp_pro, tmp_view, @cha_obj.id)
    @get_params(ada_obj)
    ada_obj


  get_params: (ada_obj)->
    # console.log @arg_list.length
    for c_view in @arg_list
      if c_view.ex_state
        # console.log 'exist-----'
        tmp_param = c_view.submit_detail()
        ada_obj.store_param(tmp_param)
