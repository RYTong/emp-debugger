{$, $$, View} = require 'atom'
# EmpEditView = require './emp-edit-view'
os = require 'os'

EmpChannelWizardView = require './emp-channel-wizard-view'
empChaWizard = require './emp-channel-wizard'

EMP_CHANNEL_URI = 'emp://wizard'
empChannelWizardView = null
OS_DARWIN = 'darwin'

module.exports =
class EmpChannelManaView extends View

  @content: ->
    # console.log 'constructor'
    # ------------------------ server state pane ------------------------
    @div outlet: 'cha_detail', class: 'emp-setting-row', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "Channel Management"

      # @div class: "emp-setting-con panel-body padded", =>
        # @label class: "emp-setting-label", "App State   : "
        # @label outlet:"emp_app_st", class: "emp-label-content", style: "color:#FF1919;", "Close"
        # @span outlet:"emp_app_load", class: 'loading loading-spinner-small inline-block',style:"display:none;"
      # @div outlet:"emp_conmiunication_pane", class: "emp-setting-con panel-body padded", =>
      #
      #   @label class: "emp-setting-label", "Erl source"
      #   @div class: 'controls', =>
      #     @div class: 'setting-editor-container', =>
      #       @subview "emp_app_erl", new EmpEditView(attributes: {id: 'emp_erl', type: 'string'},  placeholderText: 'Erlang Source') #fr
      #   @button outlet:"btn_r", class: 'btn btn-default ', click: 'run_erl', "Run Erl"

      @div outlet:"emp_cha_btns", class: "emp-setting-con panel-body padded",  =>
        @button class: 'btn btn-default ', click: 'show_channel', "Show Channel"

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
    empChaWizard.open_panel()