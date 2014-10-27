{$, $$, View} = require 'atom'
path = require 'path'
fs = require 'fs'
EmpEditView = require '../../view/emp-edit-view'
emp = require '../../exports/emp'
AdapterView = require './cha_adapter_view'
ParamView = require './cha_params_view'
channel = require '../emp_item/channel'

module.exports =
class AddGenPanel extends View
  name:emp.ADD_CHA_VIEW
  cha_obj:null
  adapter_view :null
  params_view:null
  active_view:null
  is_edit:false

  @content: ()->

    @div class: 'general-panel section', =>
      @div outlet: "loadingElement", class: 'alert alert-info loading-area icon icon-hourglass', "Loading settings"
      @div class: 'add-channel-panel', =>
        # @section class: 'config-section', =>
        @div class: 'block section-heading icon icon-gear', "Create A Channel..."
        @div class: 'div-body', =>
          @div class:'div-con ', =>
            @div class:'cha_detail_div', =>
              @div class: 'info-div', =>
                @label outlet:"cha_id_title",class: 'info-label', '频道ID*: '
                @subview "cha_id", new EmpEditView(attributes: {id: 'cha_id', type: 'string'},  placeholderText: 'Channel ID') #from editor view class
              @div class: 'info-div', =>
                @label class: 'info-label', '频道名称*'
                @subview "cha_name", new EmpEditView(attributes: {id: 'cha_name', type: 'string'},  placeholderText: 'Channel Name') #from editor view class
              @div class: 'info-div', =>
                @label class: 'info-label', '所属App'
                @subview "cha_app", new EmpEditView(attributes: {id: 'cha_app', type: 'string'},  placeholderText: 'App') #from editor view class
            @div class: 'info-div', =>
              @label class: 'info-label', '频道配型'
              @select outlet: "channel_entry", class: "form-control", =>
                @option value: emp.CHANNEL_ADAPTER, selected:"selected", "适配"
                @option value: emp.CHANNEL_NEW_CALLBACK, "新回调"
            @div outlet:'cha_state_info', class: 'info-div info-font', =>
              @label class: 'info-label', '频道状态:'
              # @div class: 'checkbox', =>
              @input outlet:'cha_state', type: 'checkbox', checked:'true'
              @text "开启"
            # @div outlet:'entry_params', class:'entry_div'
            @div outlet:'cha_params', class:'cha_parma_div'

        @div class: 'item_div', =>
          @div class: 'item_cbtn_div', =>
            @button class: 'item_btn btn btn-info inline-block-tight', click:'do_cancel','  Cancel  '
            @button class: 'item_btn btn btn-info inline-block-tight', click:'do_submit',' Ok '

  initialize: (@fa_view, extra_param)->
    @cha_obj = new channel()
    if extra_param
      # console.log "edit channel"
      # console.log extra_param
      @cha_obj.set_id(extra_param.id)
      @is_edit = true
      @cha_id.hide()
      @cha_id_title.after(@new_id_label(extra_param.id))
      @cha_name.getEditor().setText(extra_param.name)
      @cha_app.getEditor().setText(extra_param.app)
      # @cha_name.getEditor().setText(extra_param.name)
      if extra_param.entry is emp.CHANNEL_NEW_CALLBACK
        @channel_entry.val(emp.CHANNEL_NEW_CALLBACK)
      else
        @channel_entry.val(emp.CHANNEL_ADAPTER)
      if !extra_param.state
        @cha_state.prop('checked', false)
    else
      @cha_id.getEditor().on 'contents-modified', =>
        @cha_obj.id = @cha_id.getEditor().getText().trim()


      if tmp_app_name = atom.config.get(emp.EMP_TMPORARY_APP_NAME)
        @cha_app.getEditor().setText(tmp_app_name)

    @adapter_view = new AdapterView(@cha_obj, extra_param)
    @params_view = new ParamView(@cha_obj, extra_param)
    @cha_state_info.after(@adapter_view)
    @cha_params.append(@params_view)
    @loadingElement.remove()
    @active_view = @adapter_view

  new_id_label: (tmp_id)->
    $$ ->
      @label class: 'info-label', "#{tmp_id}"

  # Tear down any state and detach
  destroy: ->
    @detach()

  focus: ->
    @cha_id.focus()

  do_cancel:  ->
    @fa_view.show_panel(emp.GEN_VIEW)
    @destroy()


  do_submit: ->
    try
      if !@is_edit
        unless tmp_id = @cha_id.getEditor().getText().trim()
          throw("频道Id不能为空！")
        @cha_obj.id = tmp_id
      unless tmp_name = @cha_name.getEditor().getText().trim()
        throw("频道Name不能为空！")
      unless tmp_app = @cha_app.getEditor().getText().trim()
        throw("频道所属App不能为空！")
      tmp_entry = @channel_entry.val()
      tmp_state = @cha_state.prop('checked')
      atom.config.set(emp.EMP_TMPORARY_APP_NAME, tmp_app)

      @cha_obj.app = tmp_app
      @cha_obj.name = tmp_name
      @cha_obj.set_entry(tmp_entry)
      @cha_obj.set_state(tmp_state)

      @active_view.submit_detail()
      @params_view.submit_detail()

      if !@is_edit
        @do_add()
        @fa_view.after_add_channel(@cha_obj)
        @check_if_the_first_page()
      else
        @do_edit()
        @fa_view.after_edit_channel(@cha_obj)

      @destroy()

    catch e
      console.log e
      emp.show_error(e)

  do_add: ->
    # console.log "do add"
    cha_objs = @fa_view.all_objs.cha.obj_list
    tmp_id = @cha_obj.id
    if cha_objs[tmp_id]
      throw("该channel 已经存在~")

    @cha_obj.create_channel(@fa_view.all_objs.cha.len)
    # emp.show_info("添加 channel 完成~")

  do_edit: ->
    @cha_obj.edit_channel(@fa_view.all_objs.cha.len)
    # emp.show_info("修改 channel 完成~")

  check_if_the_first_page: ->
    tmp_cha_obj = @cha_obj
    if !atom.project.emp_first_cha_flag
      project_path = atom.project.getPath()
      entrance_page = path.join project_path, emp.ATOM_EMP_APGE_ENTRANCE
      fs.exists entrance_page, (exist_state) ->
        if exist_state
          tmp_tran = null
          for key,obj of tmp_cha_obj.adapters
            tmp_tran = key
          if tmp_tran
            entrance_con = fs.readFileSync entrance_page, 'utf8'
            entrance_con = entrance_con.replace(emp.EMP_ENTRANCE_FIRST_ID, tmp_cha_obj.id)
            entrance_con = entrance_con.replace(emp.EMP_ENTRANCE_FIRST_TRANCODE, tmp_tran)
            fs.writeFileSync entrance_page, entrance_con, 'utf8'
            atom.project.emp_first_cha_flag = true
