{$, View} = require 'atom'
ChannelView = require './channel-view'
emp = require '../../exports/emp'

module.exports =
class CollectionView extends View
  col_type:null
  obj_id: null
  isSelected: false
  isExpanded: true
  @content: ->
    @li class: 'list-nested-item' , =>
      @div outlet: 'header', class: 'header list-item', =>
        @span class: 'text-info icon icon-diff-removed', 'data-name':"*.json", outlet: 'colName'

      @ol class: 'entries list-tree', outlet: 'entries'

  initialize: (obj, new_all_obj, error)->
    # console.log "---------collection view~-----------: #{error}"
    # console.log obj  icon-file-directory
    if !error
      @create_collection(obj, new_all_obj)
    else
      @create_err_collection(obj)

  create_collection:(obj, new_all_obj) ->

    @set_col_text(obj)

    all_col = new_all_obj.child
    @set_col_state(obj, all_col)

    # if obj.items
    #   if obj.items.items > 0
    unless !obj.items
      # console.log obj.items.length
      all_cha = new_all_obj.cha
      for c_obj in obj.items
        # console.log c_obj
        tmp_obj_type = c_obj.item_type
        c_obj_id = c_obj.item_id
        if tmp_obj_type is emp.ITEM_COL_TYPE and @col_type is emp.COL_ROOT_TYPE
          # console.log "col item"
          tmp_col_obj = all_col.get(c_obj_id)
          if tmp_col_obj
            new_item_view = new CollectionView(tmp_col_obj, new_all_obj)
            @entries.append(new_item_view)
          else
            # there  is no collection entry
            error_item_view = new CollectionView(c_obj_id, null, true)
            @entries.append(error_item_view)
        else
          # console.log "cha item"
          tmp_cha_obj = all_cha.get(c_obj_id)
          if tmp_cha_obj
            @set_cha_state(c_obj_id, all_cha)
            new_item_view = new ChannelView(tmp_cha_obj, [])
            @entries.append(new_item_view)
          else
            error_item_view = new ChannelView(c_obj_id, [], true)
            @entries.append(error_item_view)
          # tmp_cha_obj = channel_obj[c_obj.item_id]
          # if tmp_cha_obj
          #   @channel_item_view(tmp_cha_obj)
          # else
          #   @err_channel_item_view(tmp_cha_obj.item_id)

  set_col_text: (obj)->
    @col_type = obj.type
    name = obj.name
    @obj_id = obj.id
    name ?= @obj_id
    @colName.text(name)

    unless @col_type isnt emp.COL_ROOT_TYPE
      @colName.removeClass('icon-diff-removed')
      # @colName.addClass('text-warning')
      @colName.addClass('icon-diff-added')


  create_err_collection: (col_id)->
    @colName.text(col_id)
    @colName.removeClass('text-info')
    @colName.addClass('text-error')

  set_col_state: (obj, all_obj) ->
    if obj.type is emp.COL_CH_TYPE
      if !obj.unsed_flag
        all_obj.set_used(@obj_id)

  set_cha_state: (id, all_obj) ->
    all_obj.set_used(id)

  toggleExpansion: (isRecursive)->
    # console.log isRecursive
    if !@isSelected
      @addClass('selected')
      # if @col_type isnt emp.COL_ROOT_TYPE
      @colName.removeClass('text-info').addClass('text-highlight')
      # else
        # @colName.removeClass('text-warning').addClass('text-highlight')
      @isSelected=true
    if @isExpanded then @collapse(isRecursive) else @expand(isRecursive)

  expand: ->
    @isExpanded = true
    @addClass('expanded').removeClass('collapsed')

  collapse: () ->
    # if isRecursive
    #   for child in @entries.children()
    #     childView = $(child).view()
    #     childView.collapse(true) if childView instanceof DirectoryView and childView.isExpanded
    @isExpanded = false
    @removeClass('expanded').addClass('collapsed')

  deselect: ->
    @removeClass('selected')
    # if @col_type isnt emp.COL_ROOT_TYPE
    @colName.removeClass('text-highlight').addClass('text-info')
    # else
    #   @colName.removeClass('text-highlight').addClass('text-warning')
    @isSelected=false

  destroy: ->
    @detach()
