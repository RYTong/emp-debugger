{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
emp = require '../../exports/emp'

module.exports =
class ChaItemView extends View
  cha_obj:null
  cha_name:null
  id:null
  isSelected:false
  use:false
  item_type: emp.ITEM_CHA_TYPE

  @content: (@cha_obj)->
    @cha_name = @cha_obj.name
    @id = @cha_obj.id

    @li class: 'list-item' , =>
      @div outlet: 'cha_item', id:@id, class: 'emp_cha_item_tag list-item', =>
        @span outlet: 'chaName', class: 'text-success icon  icon-diff-modified', 'data-name':"*.json", @cha_name

  initialize: (@cha_obj)->
    this
    @id = @cha_obj.id

  select: ->
    if !@isSelected
      @addClass('selected')
      @chaName.removeClass('text-success').addClass('text-highlight')
      @isSelected = true

  deselect: ->
    if @isSelected
      @removeClass('selected')
      @chaName.removeClass('text-highlight').addClass('text-success')
      @isSelected=false

  refresh_edit: (tmp_obj)->
    @cha_obj = tmp_obj
    @cha_name = @cha_obj.name
    @chaName.text(@cha_name)

  destroy: ->
    @detach()

  set_used: ->
    @use = true

  set_unused: ->
    @use = false
