{$, $$, View} = require 'atom'

module.exports =
class EmpPkgEtraEleView extends View

  @content: (element_id)->
    @li class: 'list-item', =>
      @div =>
        @span class: 'icon icon-book', element_id
        #  pull-right
        @button class: 'btn btn-error', click: 'rm_ele', 'R'

  initialize: (@element_id, @package_extra_entry)->
    console.log "initialize"


  destroy: ->
    @detach()

  rm_ele:(e, element) ->
    console.log "rm_ele"
    # @callback(@element_id)
    console.log @package_extra_entry
    delete @package_extra_entry[@element_id]

    @destroy()
