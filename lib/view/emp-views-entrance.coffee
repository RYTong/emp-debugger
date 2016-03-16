{Disposable, CompositeDisposable} = require 'atom'
{$, $$} = require 'atom-space-pen-views'
EmpChannelWizardView = require '../channel_view/emp-channel-wizard-view'
EmpCreateAppWizardView = require '../app_wizard/emp-app-wizard-view'
EmpCreateTempWizardView = require '../temp_wizard/emp-temp-wizard-view'
EmpCreateFrontPageWizardView = require '../temp_wizard/emp-front-page-wizard-view'
EmpCreateAppWizardView = require '../app_wizard/emp-app-wizard-view'
EMPConfigView = require '../config/emp-config-view'

empChannelWizardView = null
empAppWizardView = null
empTempWizardView = null
empConfigView = null

emp = require '../exports/emp'
AddLessMod = require '../dialog/add-less-file'

# -------------------use for front page -------------------------
create_front_page_wizard_view = (params) ->
  empTempWizardView = new EmpCreateFrontPageWizardView(params)

open_front_page_wizard_panel = ->
  atom.workspace.open(emp.EMP_FRONT_PAGE_URI)

front_page_deserializer =
  name: emp.FRONT_PAGE_WIZARD_VIEW
  version: 1
  deserialize: (state) ->
    # console.log "emp deserialize"
    create_front_page_wizard_view(state) if state.constructor is Object

atom.deserializers.add(front_page_deserializer)

# -------------------use for temp -------------------------
create_temp_wizard_view = (params) ->
  empTempWizardView = new EmpCreateTempWizardView(params)

open_temp_wizard_panel = ->
  atom.workspace.open(emp.EMP_TEMP_URI)

temp_deserializer =
  name: emp.TEMP_WIZARD_VIEW
  version: 1
  deserialize: (state) ->
    # console.log "emp deserialize"
    create_temp_wizard_view(state) if state.constructor is Object

atom.deserializers.add(temp_deserializer)

# -------------------use for app -------------------------
create_app_wizard_view = (params) ->
  empAppWizardView = new EmpCreateAppWizardView(params)

open_app_wizard_panel = ->
  # console.log "open_app_wizard_panel"
  atom.workspace.open(emp.EMP_APP_URI)
  # empAppWizardView.add_new_panel()

app_deserializer =
  name: emp.APP_WIZARD_VIEW
  version: 1
  deserialize: (state) ->
    # console.log "emp deserialize"
    create_app_wizard_view(state) if state.constructor is Object

atom.deserializers.add(app_deserializer)


# -------------------use for channel -------------------------

create_cha_wizard_view =  (params)->
  # console.log "create view "
  # console.log "params:#{params}"
  empChannelWizardView = new EmpChannelWizardView(params)

open_cha_wizard_panel = ->
  atom.workspace.open(emp.EMP_CHANNEL_URI).then ->
    empChannelWizardView.add_new_panel()

cha_deserializer =
  name: emp.CHA_WIZARD_VIEW
  version: 1
  deserialize: (state) ->
    # console.log "emp deserialize"
    create_cha_wizard_view(state) if state.constructor is Object

atom.deserializers.add(cha_deserializer)


# -------------------use for Setting View -------------------------
emp_config_view = (params) ->
  console.log "-------emp_config_view"
  empConfigView = new EMPConfigView(params)

open_config_view = ->
  # console.log "open_app_wizard_panel"
  atom.workspace.open(emp.EMP_CONFIG_URI)
  # empAppWizardView.add_new_panel()

# -------------------use for Setting View -------------------------
create_xhtml = ->
  console.log "create_xhtml "

create_html = ->
  console.log "create_html "

create_erl = ->
  console.log "create_erl "

create_cha = ->
  console.log "create_cha "

create_less = (tmp_event)->
  # console.log tmp_event
  # console.log "create_less"
  AddLessMod.new_less_file(tmp_event)

config_deserializer =
  name: emp.EMP_CONFIG_VIEW
  version: 1
  deserialize: (state) ->
    # console.log "emp deserialize"
    emp_config_view(state) if state.constructor is Object

atom.deserializers.add(config_deserializer)


module.exports =
  activate: (state)->
    # console.log '--------------------------'
    # console.log state
    @disposables = new CompositeDisposable
    # console.log "emp active~:#{state}"
    @disposables.add atom.workspace.addOpener (uri) ->
      # console.log "emp registerOpener: #{uri}"
      # console.log atom.workspace.activePane
      # console.log atom.workspace.activePane.itemForUri(configUri)
      if uri is emp.EMP_CHANNEL_URI
        create_cha_wizard_view({uri})
      else if uri is emp.EMP_APP_URI
        create_app_wizard_view({uri})
      else if uri is emp.EMP_TEMP_URI
        create_temp_wizard_view({uri})
      else if uri is emp.EMP_CONFIG_URI
        emp_config_view({uri})
    #
    # @on 'tree-view:directory-modified', =>
    #   if @hasFocus()
    #     @selectEntryForPath(@selectedPath) if @selectedPath
    #   else
    #     @selectActiveFile()

    @disposables.add atom.commands.add("atom-workspace", {
      "emp-debugger:show-channel": => open_cha_wizard_panel()
      "emp-debugger:create-app": => open_app_wizard_panel()
      "emp-debugger:create-temp": => open_temp_wizard_panel()
      "emp-debugger:create-front-page": => open_front_page_wizard_panel()
      "emp-debugger:create_erl": => create_erl()
      "emp-debugger:create_xhtml": => create_xhtml()
      "emp-debugger:create_html": => create_html()
      "emp-debugger:create_channel": => create_cha()
      "emp-debugger:open_config": => open_config_view()
      "emp-debugger:create_less": (event)=> create_less(event)
      "emp-debugger:compile_all_less": =>
        oLessCompile = state.oLessCompile
        oLessCompile.compileAllLess()
    })
      # "emp-debugger:temp-management", -> open_temp_wizard_panel()

# {'label': 'Add a Emp Erl', 'command': 'emp-debugger:create_erl'}
# {'label': 'Add a Emp Page', 'command': 'emp-debugger:create_xhtml'}
# {'label': 'Add a Emp Html Page', 'command': 'emp-debugger:create_html'}
# {'label': 'Add a Emp Channel', 'command': 'emp-debugger:create_channel'}




module.exports.open_cha_wizard = open_cha_wizard_panel
module.exports.open_app_wizard = open_app_wizard_panel
module.exports.open_temp_wizard = open_temp_wizard_panel
module.exports.open_front_page_wizard_panel = open_front_page_wizard_panel
module.exports.open_config_view = open_config_view
