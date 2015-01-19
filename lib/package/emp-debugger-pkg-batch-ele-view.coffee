{$, $$, View} = require 'atom'
ZipWriter = require("moxie-zip").ZipWriter
path = require 'path'
emp = require '../exports/emp'

module.exports =
class EmpPkgBatchEleView extends View

  checked_state:true

  @content: (fa_view, tmp_obj)->
    @tr =>
      @td "#{tmp_obj.id}"
      @td "#{tmp_obj.name}"
      @td =>
        @input outlet:"sel_state", type: 'checkbox', checked:'true', click:'do_click'



  initialize: (@fa_view, @cha_obj)->
    # console.log "initialize"
    # console.log @file_arr

    this


  destroy: ->
    @detach()

  do_package:(e, element) ->

  # select_state: ->
  #
  #   # @emp_default_color.attr('selected')
  #   @checked_state

  do_click: ->
    console.log "do click"
    # console.log @sel_state.prop('checked')
    # console.log @sel_state
    @checked_state=@sel_state.prop('checked')
    console.log @checked_state

  do_checked: ->
    unless @checked_state
      @checked_state=true
      @sel_state.prop('checked', @checked_state)

  do_unchecked: ->
    console.log @checked_state
    @checked_state = !@checked_state
    @sel_state.prop('checked', @checked_state)
