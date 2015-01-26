{$, $$, View} = require 'atom'
# os = require 'os'
# path = require 'path'
# c_process = require 'child_process'

EmpViewManage = require '../view/emp-views-entrance'
emp = require '../exports/emp'

module.exports =
class EmpDebugAppWizardView extends View

  @content: ->
    @div outlet: 'cha_detail', class: 'emp-setting-row', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "Template Management Wizard"
      @div outlet:"emp_cha_btns", class: "emp-setting-con panel-body padded",  =>
        @button class: 'btn btn-else btn-info inline-block-tight', click: 'call_tmp_management', "Template Management"
        # @button class: 'btn btn-else btn-info inline-block-tight', click: 'do_test', "test"

  initialize: ->
    this

  call_tmp_management: ->
    # console.log "show app wizard"
    EmpViewManage.open_temp_wizard()
