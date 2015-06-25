{$, View} = require 'atom-space-pen-views'

parent_view = null
module.exports =
class TabBarView extends View
  @content: (@parent_view)->
    @div class: 'emp-setting-bar', =>
      @ul class:'eul' ,=>
        @li outlet:"emp_debug_bar", class:'eli curr',click: 'btn_debug', "Debugger"
        @li outlet:"emp_app_bar", class:'eli', click: 'btn_app', "EMP App"

  initialize: (@parent_view) ->
    # console.log pane
    # parent_view = pane

  # show the emp app management pane
  btn_app: ->
    @emp_app_bar.addClass('curr')
    @emp_debug_bar.removeClass('curr')
    # console.log parent_view
    @parent_view.show_app()

  # show the debugger pane
  btn_debug: ->
    @emp_app_bar.removeClass('curr')
    @emp_debug_bar.addClass('curr')
    @parent_view.show_debug()
