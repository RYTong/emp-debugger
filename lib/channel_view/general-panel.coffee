{View} = require 'atom'
ItemPanel = require './item-panel'

module.exports =
class GeneralPanel extends View
  @content: ->
    @form class: 'general-panel section', =>
      @div outlet: "loadingElement", class: 'alert alert-info loading-area icon icon-hourglass', "Loading settings"

  initialize: ->
    @loadingElement.remove()

    # @append(new ItemPanel('core'))
    @append(new ItemPanel('editor'))
