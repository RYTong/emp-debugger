{$, $$, View} = require 'atom'
# os = require 'os'
# EmpChannelWizardView = require './emp-channel-wizard-view'
# empChaWizard = require './emp-channel-wizard'
EmpViewManage = require '../view/emp-views-entrance'

# empChannelWizardView = null
emp = require '../exports/emp'

module.exports =
class EmpChannelManaView extends View

  @content: ->
    # console.log 'constructor'
    @div outlet: 'cha_detail', class: 'emp-setting-row', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "Channel Management"
      @div outlet:"emp_cha_btns", class: "emp-setting-con panel-body padded",  =>
        @button class: 'btn btn-else btn-info inline-block-tight', click: 'show_channel', "Show Channel"

  initialize: ->
    # unless os.platform().toLowerCase() isnt OS_DARWIN
    # @emp_app_manage = new EmpAppMan(this)

    # atom.workspace.registerOpener (uri) ->
    #   # console.log "emp registerOpener: #{uri}"
    #   create_view({uri}) if uri is EMP_CHANNEL_URI
    # atom.deserializers.add(deserializer)
    this

  show_channel: ->
    console.log "show channel"
    EmpViewManage.open_cha_wizard()
