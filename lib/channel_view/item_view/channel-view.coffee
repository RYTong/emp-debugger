{View} = require 'atom'

module.exports =
class ChannelView extends View
  @content: ->
    @li class: 'file entry list-item', =>
      @span class: 'text-success icon  icon-diff-modified', outlet: 'channelName'

  initialize: (obj, new_all_obj, error)->
    # console.log "---------channel view~-----------:#{error}"
    # console.log obj
    if !error
      @create_channel_enrey(obj)
    else
      @create_error_entry(obj)

  destroy: ->
    @detach()


  create_channel_enrey: (obj) ->
    name = obj.name
    name ?= obj.id
    @channelName.text(name)

  create_error_entry:(cha_id) ->
    @channelName.text(cha_id)
    @channelName.removeClass('text-success')
    @channelName.addClass('text-error')
