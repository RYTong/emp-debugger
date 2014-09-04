{View} = require 'atom'

module.exports =
class ChannelView extends View
  @content: ->
    @li class: 'file entry list-item', =>
      @span class: 'text-success icon  icon-file-media', outlet: 'channelName'

  initialize: (obj, new_all_obj)->
    console.log "---------channel view~-----------"
    console.log obj

    name = obj.name
    name ?= obj.id
    @channelName.text(name)
