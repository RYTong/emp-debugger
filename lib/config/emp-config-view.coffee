{Disposable, CompositeDisposable} = require 'atom'
{$, $$, ScrollView, TextEditorView} = require 'atom-space-pen-views'
{ dialog } = require('electron').remote
fs = require 'fs'
fs_plus = require 'fs-plus'
path = require 'path'
# EmpEditView = require '../channel_view/item-editor-view'
emp = require '../exports/emp'

module.exports =
class EMPConfigView extends ScrollView

  @content: ->
    @div class: 'emp-app-wizard pane-item', tabindex: -1, =>
      @div class:'wizard-panels', =>
        @div class: 'wizard-logo', =>
          @div class: 'atom-banner'
        @div class: 'detail-panels', =>
          @div class:'detail-ch-panels', =>
            @div class: 'block panels-heading icon icon-gear', "EMP Config View"

            @div class:'detail-body', =>
              @div class:'detail-con', =>
                @div class:'info-div', =>
                  @label class: 'info-label', 'Erlang Source Path:'
                  @subview "erl_src_path", new TextEditorView(mini: true,attributes: {id: 'erl_src_path', type: 'string'},  placeholderText: 'Erlang Source Path')
                  @button class: 'path-btn btn btn-info inline-block-tight', click:'select_erl_path',' Chose Path '

                @div class:'info-div', =>
                  @label class: 'info-label', 'EWP Source Path:'
                  @subview "ewp_src_path", new TextEditorView(mini: true,attributes: {id: 'ewp_src_path', type: 'string'},  placeholderText: 'EWP Srouce Path')
                  @button class: 'path-btn btn btn-info inline-block-tight', click:'select_ewp_path',' Chose Path '

                @div class:'info-div', =>
                  @label class: 'info-label', 'Yaws Source Path:'
                  @subview "yaws_src_path", new TextEditorView(mini: true,attributes: {id: 'yaws_src_path', type: 'string'},  placeholderText: 'Yaws Source Path')
                  @button class: 'path-btn btn btn-info inline-block-tight', click:'select_yaws_path',' Chose Path '


  initialize: ({@uri}={}) ->
    super
    @disposable = new CompositeDisposable
    if set_erl_path = atom.config.get(emp.EMP_ERL_SOURCE_PATH)
      @erl_src_path.setText(set_erl_path)

    if set_ewp_path = atom.config.get(emp.EMP_EWP_SOURE_PATH)
      @ewp_src_path.setText(set_ewp_path)

    if set_yaws_path = atom.config.get(emp.EMP_YAWS_SOURCE_PATH)
      @yaws_src_path.setText(set_yaws_path)

    @erl_src_path.getModel().onDidStopChanging =>
      tmp_erl_path = @erl_src_path.getText()
      # console.log tmp_host
      atom.config.set(emp.EMP_ERL_SOURCE_PATH, tmp_erl_path)
    @ewp_src_path.getModel().onDidStopChanging =>
      tmp_ewp_path = @ewp_src_path.getText()
      atom.config.set(emp.EMP_EWP_SOURE_PATH, tmp_ewp_path)
    @yaws_src_path.getModel().onDidStopChanging =>
      tmp_yaws_path = @yaws_src_path.getText()
      atom.config.set(emp.EMP_YAWS_SOURCE_PATH, tmp_yaws_path)

    # console.log "app wizard view"
    # if @default_app_path = atom.config.get(emp.EMP_APP_WIZARD_APP_P)
    #   # console.log "exist"
    #   @app_path.setText(@default_app_path)
    # if tmp_ewp_path = atom.config.get(emp.EMP_APP_WIZARD_EWP_P)
    #   # console.log "exist ewp"
    #   @default_ewp_path = tmp_ewp_path
    #   @ewp_path.setText(@default_ewp_path)
    # else
    #   @ewp_path.setText(@default_ewp_path)
    # # @focus()
    #
    # if !tmp_app_port = atom.config.get emp.EMP_TEMP_WIZARD_PORT
    #   tmp_app_port = @default_app_port
    # @app_port.setText tmp_app_port
    #
    # if !tmp_app_aport = atom.config.get emp.EMP_TEMP_WIZARD_APORT
    #   tmp_app_aport = @default_app_aport
    # @app_aport.setText tmp_app_aport

  select_erl_path: (e, element)->
    tmp_path = @erl_src_path.getText()
    @promptForPath(@erl_src_path, tmp_path)

  select_ewp_path: (e, element)->
    tmp_path = @ewp_src_path.getText()
    @promptForPath(@ewp_src_path, tmp_path)

  select_yaws_path: (e, element)->
    tmp_path = @yaws_src_path.getText()
    @promptForPath(@yaws_src_path, tmp_path)

  promptForPath: (fa_view, def_path) ->
    if def_path
      dialog.showOpenDialog title: 'Select', defaultPath:def_path, properties: ['openDirectory', 'createDirectory'], (pathsToOpen) =>
        @refresh_path( pathsToOpen, fa_view)
    else
      dialog.showOpenDialog title: 'Select', properties: ['openDirectory', 'createDirectory'], (pathsToOpen) =>
        @refresh_path( pathsToOpen, fa_view)

  refresh_path: (new_path, fa_view)->
    if new_path
      # console.log new_path
      fa_view.setText(new_path[0])


  show_dialog: ->
    dialog.showMessageBox title:'test', message:"asdasda"

  redrawEditors: ->
    $(element).view().redraw() for element in @find('.editor')

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    deserializer: emp.EMP_SETTING_VIEW
    version: 1
    activePanelName: @activePanelName ? emp.EMP_SETTING_VIEW
    uri: @uri


  getUri: ->
    @uri

  getTitle: ->
    "EMP Config View"

  isEqual: (other) ->
    other instanceof EMPConfigView

  refresh_view:(@all_objs) ->
    @remove_loading()

  remove_loading: ->
    @loadingElement.remove()
