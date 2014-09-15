{View} = require 'atom'
ColItemPanel = require './collection-item-panel'
ChannelItemPanel = require './channel-item-panel.coffee'
emp = require '../exports/emp'

module.exports =
class GeneralPanel extends View
  name:emp.GEN_VIEW
  col_view:null
  cha_view:null
  @content: ->
    @div class: 'general-panel section', =>
      @div outlet: "loadingElement", class: 'alert alert-info loading-area icon icon-hourglass', "Loading settings"

  initialize: (fa_view)->
    @loadingElement.remove()

    # @append(new ItemPanel('core'))
    @col_view = new ColItemPanel(fa_view)
    @cha_view = new ChannelItemPanel(fa_view)
    @append(@col_view)
    @append(@cha_view)

  refresh_list: (objs) ->
    console.log "refresh list"
    @col_view.refresh_col_list(objs)
    @cha_view.refresh_cha_list(objs)
