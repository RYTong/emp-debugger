{$, $$, View} = require 'atom'
# os = require 'os'
EmpViewManage = require '../view/emp-views-entrance'
# emp = require '../exports/emp'

module.exports =
class EmpDebugAppWizardView extends View

  @content: ->
    @div outlet: 'cha_detail', class: 'emp-setting-row', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "Create App Wizard"
      @div outlet:"emp_cha_btns", class: "emp-setting-con panel-body padded",  =>
        @button class: 'btn btn-else btn-info inline-block-tight', click: 'call_app_wizard', "Create A Emp App"

  initialize: ->
    this

  call_app_wizard: ->
    # console.log "show app wizard"
    EmpViewManage.open_app_wizard()
