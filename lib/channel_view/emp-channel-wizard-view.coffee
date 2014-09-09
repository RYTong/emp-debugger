{$, $$, ScrollView} = require 'atom'

GeneralPanel = require './general-panel'
EmpEditView = require '../view/emp-edit-view'
EmpChaListView = require './emp-channel-list-view'
s_name = 'EmpView'

module.exports =
class EmpChannelWizardView extends ScrollView
  active_panel:null
  emp_channel_list_view:null

  @content: ->
    @div class: 'emp-channel-wizard pane-item', tabindex: -1, =>
      @div class: 'config-menu', outlet: 'sidebar', =>
        @div outlet:"emp_logo", class: 'atom-banner'
        @ul class: 'panels-menu nav nav-pills nav-stacked', outlet: 'panelMenu', =>
          @div class: 'panel-menu-separator', outlet: 'menuSeparator'
        # @div class: 'panel-menu-separator', outlet: 'menuSeparator'
        @div class: 'button-area', =>
          @button class: 'btn btn-default icon icon-link-external', outlet: 'openDotAtom', 'Open ~/.atom'
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
    @emp_channel_list_view = new EmpChaListView()
    @emp_logo.after(@emp_channel_list_view)
    @active_panel = new GeneralPanel()
    @add_new_panel()

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
    if @active_panel
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
