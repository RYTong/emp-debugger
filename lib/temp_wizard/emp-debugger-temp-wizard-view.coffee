{$, $$, View} = require 'atom-space-pen-views'
EmpViewManage = require '../view/emp-views-entrance'
emp = require '../exports/emp'

module.exports =
class EmpDebugTempWizardView extends View

  @content: ->
    @div class: 'emp-setting-row-two', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "Create App Wizard"
      @div class: "emp-setting-con panel-body padded",  =>
        @div class: "emp-set-div-content", =>
          @label class: "emp-setting-label", "创建一个前端页面的工程结构, 该结构只包括前端页面调试所需要的内容. "

        @div class: "emp-set-div-content", =>
          @button class: 'btn btn-else btn-info inline-block-tight', click: 'call_temp_wizard', "Create A Template App"

  initialize: ->
    this

  call_temp_wizard: ->
    EmpViewManage.open_temp_wizard()
