{$, $$, ScrollView} = require 'atom'

# ChannelItemPanel = require './channel-item-panel.coffee'
GeneralPanel = require './general-panel'
AddChaPanel = require './panel_view/add_channel_view'
AddColPanel = require './collection_view/add_collection_view'
# EmpEditView = require '../view/emp-edit-view'
EmpChaListView = require './emp-channel-list-view'
emp = require '../exports/emp'

module.exports =
class EmpChannelWizardView extends ScrollView
  active_panel:null
  active_panel_name: null
  emp_channel_list_view:null
  gen_info_view:null
  gen_add_cha:null
  gen_add_col:null
  panels_list: {}
  createPanel:{}
  all_objs:null

  @content: ->
    @div class: 'emp-channel-wizard pane-item', tabindex: -1, =>
      @div class: 'config-menu', outlet: 'sidebar', =>
        @div outlet:"emp_logo", class: 'atom-banner'
        @div outlet: "loadingElement", class: 'alert alert-info loading-area icon icon-hourglass', "Loading config"
        @ul class: 'panels-menu nav nav-pills nav-stacked', outlet: 'panelMenu', =>
          @div class: 'panel-menu-separator', outlet: 'menuSeparator'
        # @div class: 'panel-menu-separator', outlet: 'menuSeparator'
        @div class: 'button-area', =>
          @button class: 'btn btn-default icon icon-link-external', outlet: 'openDotAtom', 'Open ~/.channel'
      @div class: 'panels padded', outlet: 'panels'

  initialize: ({@uri}={}) ->
    super
    # console.log activePanelName
    # @panelToShow = activePanelName
    # process.nextTick =>
    @panels_list={}
    @createPanel = {}
    @initializePanels()
    @all_objs = null

    # @initializePanels()
    # atom.workspaceView.command "emp-channel-wizard:toggle", => @toggle()

  initializePanels: ()->
    # console.log @panels.size()
    return if @panels.size > 0
    # console.log @panels.size()
    @gen_info_view = new GeneralPanel(this)
    @panels_list[@gen_info_view.name] = @gen_info_view

    # @gen_add_cha = new AddChaPanel(this, @all_objs)
    # @panels_list[@gen_add_cha.name] = @gen_add_cha


    @store_panel emp.ADD_CHA_VIEW, (parmas) => new AddChaPanel(this, parmas)
    @store_panel emp.ADD_COL_VIEW, (parmas) => new AddColPanel(this, parmas)

    @emp_channel_list_view = new EmpChaListView(this)
    @emp_logo.after(@emp_channel_list_view)

    @active_panel = @gen_info_view
    @active_panel_name = @gen_info_view.name

    # @active_panel = @gen_add_cha
    # @active_panel_name = @gen_add_cha.name

    # @gen_add_col = new AddColPanel(this)
    # console.log @gen_add_col.name
    # @panels_list[@gen_add_col.name] = @gen_add_col
    #
    # @active_panel = @gen_add_col
    # @active_panel_name = @gen_add_col.name

    # if @emp_channel_list_view.fex_state
      # @emp_channel_list_view.refresh_channel_view() unless !@emp_channel_list_view
    @panels.append(@active_panel) unless $.contains(@panels[0], @active_panel[0])
    @active_panel.show()
    for editorElement, index in @active_panel.find(".editor")
      $(editorElement).view().redraw()
    @active_panel.focus()
    # @add_new_panel()


  store_panel: (name, callback)->
    @createPanel[name] = callback




  redrawEditors: ->
    $(element).view().redraw() for element in @find('.editor')

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    deserializer: emp.CHA_WIZARD_VIEW
    version: 1
    activePanelName: @activePanelName ? emp.CHA_WIZARD_VIEW
    uri: @uri

  # Tear down any state and detach
  destroy: ->
    @detach()

  # toggle: ->
  #   # console.log "EmpChannelWizardView was toggled!"
  #   if @hasParent()
  #     @detach()
  #   # else
  #     atom.workspaceView.append(this)
  #     @add_new_panel()
  #     # @parse_conf()
#
  add_new_panel_f: ->
    @emp_channel_list_view.refresh_channel_view() unless !@emp_channel_list_view

  add_new_panel: ->
    if @emp_channel_list_view.fex_state
      @emp_channel_list_view.refresh_channel_view() #unless !@emp_channel_list_view
    # if @active_panel
    #   @panels.append(@active_panel) unless $.contains(@panels[0], @active_panel[0])
    #   @active_panel.show()
    #   for editorElement, index in @active_panel.find(".editor")
    #     $(editorElement).view().redraw()
    #   @active_panel.focus()

  show_panel: (name, extra_param) ->
    # console.log "show panels:#{name}"
    # console.log @active_panel_name
    if @active_panel_name isnt name
      tmp_pan = @panels_list[name]
      if !tmp_pan
          unless !call_back = @createPanel[name]
            # console.log "d call"
            tmp_pan = call_back(extra_param)
        @active_panel = tmp_pan
        @active_panel_name = tmp_pan.name
        @panels.children().hide()
        @panels.append(@active_panel) unless $.contains(@panels[0], @active_panel[0])
        @active_panel.show()
        for editorElement, index in @active_panel.find(".editor")
          $(editorElement).view().redraw()
        @active_panel.focus()

  focus: ->
    super
    # Pass focus to panel that is currently visible
    for panel in @panels.children()
      child = $(panel)
      if child.isVisible()
        if view = child.view()
          view.focus()
        else
          child.focus()
        return

  getUri: ->
    @uri

  getTitle: ->
    "Emp Wizard"

  isEqual: (other) ->
    other instanceof EmpChannelWizardView

  refresh_view:(@all_objs) ->
    @remove_loading()
    @refresh_gen_info_view()

  refresh_gen_info_view: () ->
    if @active_panel is @gen_info_view
      @gen_info_view.refresh_list(@all_objs)

  remove_loading: ->
    @loadingElement.remove()

  after_add_channel: (add_cha)->
    cha_state = @all_objs.cha.check_exist(add_cha)
    @show_panel(@gen_info_view.name)
    if !cha_state
      @emp_channel_list_view.refresh_cha_panel(add_cha, @all_objs)
      @gen_info_view.refresh_add_cha(add_cha)

  after_del_channel: (del_id_list)->
    # console.log @all_objs
    # console.log del_id_list
    for cha_id in del_id_list
      @all_objs.cha.delete(cha_id)
    @emp_channel_list_view.refresh_cha_panel_re(del_id_list, @all_objs)

  after_edit_channel: (tmp_cha_obj)->
    @all_objs.cha.refresh(tmp_cha_obj)
    @emp_channel_list_view.refresh_edit_cha(tmp_cha_obj, @all_objs)
    # console.log "info view"
    @gen_info_view.refresh_edit_cha(tmp_cha_obj, @all_objs)
    @show_panel(@gen_info_view.name)

  after_add_col: (tmp_col_obj) ->
    col_state = false
    all_col = @all_objs.col
    for key,obj of all_col
      if tmp_col_obj.id is key
        if tmp_col_obj.type is obj.type
          col_state = true

    if tmp_col_obj.type is emp.COL_CH_TYPE
      @all_objs.child.put(tmp_col_obj)
    else
      @all_objs.root[tmp_col_obj.id] = tmp_col_obj
    @all_objs.col[tmp_col_obj.id] = tmp_col_obj
    @show_panel(@gen_info_view.name)
    if !col_state
      # console.log "list view"
      @emp_channel_list_view.refresh_add_col(tmp_col_obj, @all_objs)
      # console.log "info view"
      @gen_info_view.refresh_add_col(tmp_col_obj, @all_objs)

  after_del_col: (del_id_list) ->
    for col_id,col_type of del_id_list
      if col_type is emp.COL_CH_TYPE
        @all_objs.child.delete(col_id)
      else
        delete @all_objs.root[col_id]
      delete @all_objs.col[col_id]
    @emp_channel_list_view.refresh_col_panel_re(del_id_list, @all_objs)

  after_edit_col:(tmp_col_obj) ->
    if tmp_col_obj.type is emp.COL_CH_TYPE
      @all_objs.child.refresh(tmp_col_obj)
    else
      @all_objs.root[tmp_col_obj.id] = tmp_col_obj
    @all_objs.col[tmp_col_obj.id] = tmp_col_obj
    @emp_channel_list_view.refresh_edit_col(tmp_col_obj, @all_objs)
    # console.log "info view"
    @gen_info_view.refresh_edit_col(tmp_col_obj, @all_objs)
    @show_panel(@gen_info_view.name)
