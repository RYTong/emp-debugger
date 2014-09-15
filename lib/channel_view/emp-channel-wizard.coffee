
EmpChannelWizardView = require './emp-channel-wizard-view'

configUri = 'emp://wizard'
empChannelWizardView = null

create_view =  (params)->
  # console.log "params:#{params}"
  empChannelWizardView = new EmpChannelWizardView(params)

open_panel = ->
  atom.workspaceView.open(configUri)
  empChannelWizardView.add_new_panel()


deserializer =
  name: 'EmpView'
  version: 1
  deserialize: (state) ->
    # console.log "emp deserialize"
    create_view(state) if state.constructor is Object

atom.deserializers.add(deserializer)



module.exports =
  activate: (state)->
    # console.log "emp active~:#{state}"
    atom.workspace.registerOpener (uri) ->
      # console.log "emp registerOpener: #{uri}"
      # console.log atom.workspace.activePane
      # console.log atom.workspace.activePane.itemForUri(configUri)
      create_view({uri}) if uri is configUri

    atom.workspaceView.command "emp-debugger:show-channel", ->
      # console.log "open emp view"
      open_panel()

module.exports.open_panel = open_panel
