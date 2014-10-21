
EmpChannelWizardView = require '../channel_view/emp-channel-wizard-view'
EmpCreateAppWizardView = require '../app_wizard/emp-app-wizard-view'

empChannelWizardView = null
empAppWizardView = null
emp = require '../exports/emp'

# -------------------use for app -------------------------
create_app_wizard_view = (params) ->
  empAppWizardView = new EmpCreateAppWizardView(params)

open_app_wizard_panel = ->
  atom.workspaceView.open(emp.EMP_APP_URI)
  # empAppWizardView.add_new_panel()

app_deserializer =
  name: emp.APP_WIZARD_VIEW
  version: 1
  deserialize: (state) ->
    console.log "emp deserialize"
    create_app_wizard_view(state) if state.constructor is Object

atom.deserializers.add(app_deserializer)

# -------------------use for channel -------------------------

create_cha_wizard_view =  (params)->
  # console.log "create view "
  # console.log "params:#{params}"
  empChannelWizardView = new EmpChannelWizardView(params)

open_cha_wizard_panel = ->
  atom.workspaceView.open(emp.EMP_CHANNEL_URI)
  empChannelWizardView.add_new_panel()

cha_deserializer =
  name: emp.CHA_WIZARD_VIEW
  version: 1
  deserialize: (state) ->
    # console.log "emp deserialize"
    create_cha_wizard_view(state) if state.constructor is Object

atom.deserializers.add(cha_deserializer)

module.exports =
  activate: (state)->
    # console.log "emp active~:#{state}"
    atom.workspace.registerOpener (uri) ->
      # console.log "emp registerOpener: #{uri}"
      # console.log atom.workspace.activePane
      # console.log atom.workspace.activePane.itemForUri(configUri)
      if uri is emp.EMP_CHANNEL_URI
        create_cha_wizard_view({uri})
      else if uri is emp.EMP_APP_URI
        create_app_wizard_view({uri})

    atom.workspaceView.command "emp-debugger:show-channel", ->
      # console.log "open emp view"
      open_cha_wizard_panel()
    atom.workspaceView.command "emp-debugger:show-app", ->
      # console.log "open emp view"
      open_app_wizard_panel()

module.exports.open_cha_wizard = open_cha_wizard_panel
module.exports.open_app_wizard = open_app_wizard_panel
