{View} = require 'atom'
path = require 'path'
EmpEditView = require '../../view/emp-edit-view'
emp = require '../../exports/emp'
ItemsPanel = require './collection_child_item_panel'
# ParamView = require './cha_params_view'
collection = require '../emp_item/collection'

module.exports =
class AddGenPanel extends View
  name:emp.ADD_COL_VIEW
  col_obj:null
  items_panel :null

  @content: ->

    @div class: 'general-panel section', =>
      @div outlet: "loadingElement", class: 'alert alert-info loading-area icon icon-hourglass', "Loading settings"
      @div class: 'add-channel-panel', =>
        # @section class: 'config-section', =>
        @div class: 'block section-heading icon icon-gear', "Create A Collection..."
        @div class: 'div-body', =>
          @div class:'div-con ', =>
            @div class:'cha_detail_div', =>
              @div class: 'info-div', =>
                @label class: 'info-label', '集合ID*'
                @subview "col_id", new EmpEditView(attributes: {id: 'col_id', type: 'string'},  placeholderText: 'Collection ID') #from editor view class
              @div class: 'info-div', =>
                @label class: 'info-label', '集合名称*'
                @subview "col_name", new EmpEditView(attributes: {id: 'col_name', type: 'string'},  placeholderText: 'Collection Name') #from editor view class
              @div class: 'info-div', =>
                @label class: 'info-label', '所属App*'
                @subview "col_app", new EmpEditView(attributes: {id: 'col_app', type: 'string'},  placeholderText: 'App') #from editor view class
              @div class: 'info-div', =>
                @label class: 'info-label', 'Url'
                @subview "col_url", new EmpEditView(attributes: {id: 'col_url', type: 'string'},  placeholderText: 'Url') #from editor view class
              @div class: 'info-div', =>
                @label class: 'info-label', 'User Id*'
                @subview "col_uid", new EmpEditView(attributes: {id: 'col_uid', type: 'string'},  placeholderText: 'User Id') #from editor view class

            @div class: 'info-div', =>
              @label class: 'info-label', '集合类型'
              @select outlet: "collecion_type", class: "form-control", =>
                @option value: emp.COL_CH_TYPE, selected:"selected", "Collection"
                @option value: emp.COL_ROOT_TYPE, "Collection 根节点"
            @div outlet:'col_state_info', class: 'info-div info-font', =>
              @label class: 'info-label', '集合状态:'
              # @div class: 'checkbox', =>
              @input outlet:'col_state', type: 'checkbox', checked:'true'
              @text "开启"

            # @div outlet:'entry_params', class:'entry_div'

            @div outlet:'col_params', class:'cha_parma_div'

        @div class: 'item_div', =>
          @div class: 'item_cbtn_div', =>
            @button class: 'item_btn btn btn-info inline-block-tight', click:'do_cancel','  Cancel  '
            @button class: 'item_btn btn btn-info inline-block-tight', click:'do_submit',' Ok '

  initialize: (@fa_view)->

    @col_obj = new collection()
    @items_panel = new ItemsPanel(@fa_view.all_objs, @col_obj)
    # @params_view = new ParamView(@cha_obj)
    @col_state_info.after(@items_panel)
    # @cha_params.append(@params_view)
    @loadingElement.remove()
    # @active_view = @adapter_view
    # @cha_id.getEditor().on 'contents-modified', =>
    #   @cha_obj.id = @cha_id.getEditor().getText().trim()

  # Tear down any state and detach
  destroy: ->
    @detach()

  focus: ->
    @col_id.focus()

  do_cancel:  ->
    @fa_view.show_panel(emp.GEN_VIEW)
    @destroy()


  do_submit: ->
    tmp_id = @col_id.getEditor().getText().trim()
    tmp_name = @col_name.getEditor().getText().trim()
    tmp_app = @col_app.getEditor().getText().trim()
    # console.log "id:#{tmp_id}, name:#{tmp_name}, app:#{tmp_app}"
    # console.log "s:#{tmp_state}, e:#{tmp_entry}"

    try
      unless tmp_id
        throw("集合Id不能为空！")
      unless tmp_name
        throw("集合Name不能为空！")
      unless tmp_app
        throw("集合所属App不能为空！")

      @col_obj.id = tmp_id
      @col_obj.app = tmp_app
      @col_obj.name = tmp_name
      @col_obj.type = @collecion_type.val()
      @col_obj.url = @col_obj.set_url(@col_url.getEditor().getText().trim())
      @col_obj.uid = @col_obj.set_uid(@col_uid.getEditor().getText().trim())
      @col_obj.set_state(@col_state.prop('checked'))

      @items_panel.submit_detail()

      @do_add()
      @fa_view.after_add_col(@col_obj)
      @destroy()

    catch e
      console.log e
      emp.show_error(e)

  do_add: ->
    console.log "do add"
    col_objs = @fa_view.all_objs.col
    tmp_id = @col_obj.id
    if col_objs[tmp_id]
      if col_objs[tmp_id].type is @col_obj.type
        throw("Collection 已经存在~")

    @col_obj.create_collection(col_objs)
    emp.show_info("添加 Collection 完成~")
    # console.log __dirname
    # path.join __dirname,
    # console.log @all_objs
    # console.log @fa_view.all_objs
    # console.log @cha_obj
