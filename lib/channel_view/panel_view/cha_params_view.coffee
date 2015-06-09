{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
# EmpEditView = require '../../view/emp-edit-view'
emp = require '../../exports/emp'
param_item_view = require './cha_params_item_view'

module.exports =
class ChaParamsPanel extends View
  item_array:null
  cha_obj:null

  @content: ->
    @div =>
      @label class: 'param-label', '频道参数(Channel Parameters):'
      @button class: 'off_ul_btn btn btn-info inline-block-tight', click:'add_params_btn',' add new params...'

      @div outlet:'item_list', class: 'params_con_body'
        # @div class:'p_param_div', =>
        #   @ul class:'off_ul', =>
        #     @li class:'off_li', =>
        #       @span "http请求类型(Key):"
        #       @subview "method_k", new EmpEditView(attributes: {id: 'method_k', type: 'string'},  placeholderText:'method')
        #     @li class:'off_li', =>
        #       @span "请求类型(Value):"
        #       @subview "method_v", new EmpEditView(attributes: {id: 'method_v', type: 'string'},  placeholderText:'post')
        # @div class:'p_param_div', =>
        #   @ul outlet:"param_items", class:'off_ul'

  initialize: (@cha_obj, extra_param)->
    # console.log "params"
    @item_array = []
    if extra_param
      # console.log extra_param
      tmp_params = null
      if extra_param.props
        tmp_params = extra_param.props
      else
        tmp_params = extra_param.get_param()
      if typeof(tmp_params) is 'object'
        for key,val of tmp_params
          @add_params(key, val)
    else
      # console.log @cha_obj.params
      for key,val of @cha_obj.get_param()
        @add_params(key, val)

  add_params: (key, val)->
    tmp_view = new param_item_view(key, val)
    @item_array.push(tmp_view)
    @item_list.append(tmp_view)

  add_params_btn: ->
    tmp_view = new param_item_view()
    @item_array.push(tmp_view)
    @item_list.append(tmp_view)
    tmp_view.focus()

  submit_detail: ->
    # console.log @item_array.length
    # console.log "param submit_detail"
    @cha_obj.initial_param()
    # tmp_mk = @method_k.getEditor().getText('method').trim()
    # tmp_mv = @method_v.getEditor().getText('post').trim()
    # tmp_ek = @encrypt_k.getEditor().getText('encrypt').trim()
    # tmp_ev = @encrypt_v.getEditor().getText('0').trim()
    # @cha_obj.store_param({key:tmp_mk, value:tmp_mv})
    # @cha_obj.store_param({key:tmp_ek, value:tmp_ev})

    for i_view in @item_array
      if i_view.ex_state
        # console.log 'exist-----'
        tmp_param = i_view.submit_detail()
        @cha_obj.store_param(tmp_param)
