{$, $$, View} = require 'atom'
EmpEditView = require '../../view/emp-edit-view'
emp = require '../../exports/emp'
param_item_view = require './cha_params_item_view'

module.exports =
class ChaParamsPanel extends View
  item_array:null
  cha_obj:null

  @content: ->
    @div =>
      @label class: 'param-label', '频道参数:'
      @button class: 'off_ul_btn btn btn-info inline-block-tight', click:'add_params',' add new params...'

      @div outlet:'item_list', class: 'params_con_body', =>
        @div class:'p_param_div', =>
          @ul class:'off_ul', =>
            @li class:'off_li', =>
              @span "http请求类型(Key):"
              @subview "method_k", new EmpEditView(attributes: {id: 'method_k', type: 'string'},  placeholderText:'method')
            @li class:'off_li', =>
              @span "请求类型(Value):"
              @subview "method_v", new EmpEditView(attributes: {id: 'method_v', type: 'string'},  placeholderText:'post')
        @div class:'p_param_div', =>
          @ul class:'off_ul', =>
            @li class:'off_li', =>
              @span "加密标示:"
              @subview "encrypt_k", new EmpEditView(attributes: {id: 'encrypt_k', type: 'string'},  placeholderText:'encrypt')
            @li class:'off_li', =>
              @span "参数值:(1加密，0不加密)"
              @subview "encrypt_v", new EmpEditView(attributes: {id: 'encrypt_v', type: 'integer'},  placeholderText:'0')



  initialize: (@cha_obj)->
    # console.log "params"
    @item_array = []
    @method_k.getEditor().setText('method')
    # @method_k.disable()
    @method_v.getEditor().setText('post')
    # @method_v.disable()
    @encrypt_k.getEditor().setText('encrypt')
    @encrypt_v.getEditor().setText('0')

  add_params: ->
    tmp_view = new param_item_view()
    @item_array.push(tmp_view)
    @item_list.append(tmp_view)
    tmp_view.focus()

  submit_detail: ->
    # console.log @item_array.length
    # console.log "param submit_detail"
    @cha_obj.initial_param()
    tmp_mk = @method_k.getEditor().getText('method').trim()
    tmp_mv = @method_v.getEditor().getText('post').trim()
    tmp_ek = @encrypt_k.getEditor().getText('encrypt').trim()
    tmp_ev = @encrypt_v.getEditor().getText('0').trim()
    @cha_obj.store_param({key:tmp_mk, value:tmp_mv})
    @cha_obj.store_param({key:tmp_ek, value:tmp_ev})

    for i_view in @item_array
      if i_view.ex_state
        # console.log 'exist-----'
        tmp_param = i_view.submit_detail()
        @cha_obj.store_param(tmp_param)
