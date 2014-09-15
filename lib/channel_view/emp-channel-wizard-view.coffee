{$, $$, ScrollView} = require 'atom'

# ChannelItemPanel = require './channel-item-panel.coffee'
GeneralPanel = require './general-panel'
AddChaPanel = require './panel_view/add_channel_view'
EmpEditView = require '../view/emp-edit-view'
EmpChaListView = require './emp-channel-list-view'
s_name = 'EmpView'

module.exports =
class EmpChannelWizardView extends ScrollView
  active_panel:null
  active_panel_name: null
  emp_channel_list_view:null
  gen_info_view:null
  gen_add_cha:null
  gen_add_col:null
  panels_list: {}

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
    process.nextTick =>@initializePanels()
    # @initializePanels()
    # atom.workspaceView.command "emp-channel-wizard:toggle", => @toggle()

  initializePanels: ->
    # console.log @panels.size()
    return if @panels.size > 0
    # console.log @panels.size()
    @gen_info_view = new GeneralPanel(this)
    @gen_add_cha = new AddChaPanel(this)
    @panels_list[@gen_info_view.name] = @gen_info_view
    @panels_list[@gen_add_cha.name] = @gen_add_cha

    @emp_channel_list_view = new EmpChaListView(this)
    @emp_logo.after(@emp_channel_list_view)

    @active_panel = @gen_info_view
    @active_panel_name = @gen_info_view.name
    # @active_panel = @gen_add_cha
    # @active_panel_name = @gen_add_cha.name

    @emp_channel_list_view.refresh_channel_view() unless !@emp_channel_list_view
    @panels.append(@active_panel) unless $.contains(@panels[0], @active_panel[0])
    @active_panel.show()
    for editorElement, index in @active_panel.find(".editor")
      $(editorElement).view().redraw()
    @active_panel.focus()
    # @add_new_panel()



  redrawEditors: ->
    $(element).view().redraw() for element in @find('.editor')

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    deserializer: 'EmpView'
    version: 1
    activePanelName: @activePanelName ? s_name
    uri: @uri

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    # console.log "EmpChannelWizardView was toggled!"
    if @hasParent()
      @detach()
    # else
      atom.workspaceView.append(this)
      @add_new_panel()
      # @parse_conf()
#
  add_new_panel: ->
    # console.log "add_new_panel"
    @emp_channel_list_view.refresh_channel_view() unless !@emp_channel_list_view
    # if @active_panel
    #   @panels.append(@active_panel) unless $.contains(@panels[0], @active_panel[0])
    #   @active_panel.show()
    #   for editorElement, index in @active_panel.find(".editor")
    #     $(editorElement).view().redraw()
    #   @active_panel.focus()

  show_panel: (name) ->
    # console.log "show panels:#{name}"
    # console.log @active_panel_name
    if @active_panel_name isnt name
      tmp_pan = @panels_list[name]
      unless !tmp_pan
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

  refresh_view:(objs) ->
    @remove_loading()
    @refresh_gen_info_view(objs)

  refresh_gen_info_view: (objs) ->
    if @active_panel is @gen_info_view
      @gen_info_view.refresh_list(objs)

  remove_loading: ->
    @loadingElement.remove()
