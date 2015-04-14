{$, $$, View} = require 'atom-space-pen-views'
# os = require 'os'
# path = require 'path'
# c_process = require 'child_process'

EmpViewManage = require '../view/emp-views-entrance'
emp = require '../exports/emp'

module.exports =
class EmpDebugAppWizardView extends View

  @content: ->
    @div outlet: 'cha_detail', class: 'emp-setting-row-one', =>
      @div class: "emp-setting-con panel-body padded", =>
        @div class: "block conf-heading icon icon-gear", "Create App Wizard"
      @div outlet:"emp_cha_btns", class: "emp-setting-con panel-body padded",  =>
        @button class: 'btn btn-else btn-info inline-block-tight', click: 'call_app_wizard', "Create A Emp App"
        # @button class: 'btn btn-else btn-info inline-block-tight', click: 'do_test', "test"

  initialize: ->
    this

  call_app_wizard: ->
    # console.log "show app wizard"
    EmpViewManage.open_app_wizard()

  # do_test: ->
  #   console.log os.platform().toLowerCase()
  #   console.log process.env[emp.OS_PATH]
  #
  #   rel_erl_dir = '../../erl_util/atom_pl_parse_json.erl'
  #   rel_ebin_dir = '../../erl_util/'
  #
  #   erl_dir = path.join(__dirname, rel_erl_dir)
  #   ebin_dir = path.join(__dirname, rel_ebin_dir)
  #   erlc_str = 'erlc -o '+ebin_dir+' '+erl_dir+' -noshell -s erlang halt'
  #   console.log erlc_str
  #   c_process.exec erlc_str, (error, stdout, stderr) ->
  #     if (error instanceof Error)
  #       console.warn error.message
  #       console.log stderr
  #       emp.show_error("Compile erl error ~")
  #     else
  #       if callback
  #         callback.add_new_panel_f()
  #   emp.show_info("asdasda")
