{$, $$, TextEditorView, View} = require 'atom-space-pen-views'
emp = require '../../exports/emp'

module.exports =
class ColItemView extends View
  col_obj:null
  col_type:null
  id: null
  col_name:null
  item_type:emp.ITEM_COL_TYPE

  isSelected:false
  use:false

  @content: (obj, type)->
    @col_obj = obj
    @col_name = obj.name
    @id = obj.id
    @col_type = obj.type
    @col_name ?= @id
    if @col_type is emp.COL_ROOT_TYPE
      @li class: 'list-item' , =>
        @div outlet: 'col_item', id:@id, etype:@col_type,class: 'emp_col_item_tag list-item', =>
          @span outlet: 'colName', class: 'text-info icon icon-diff-added', 'data-name':"*.json", @col_name
    else
      @li class: 'list-item' , =>
        @div outlet: 'col_item', etype:@col_type,id:@id,  class: 'emp_col_item_tag list-item', =>
          @span outlet: 'colName',class: 'text-info icon icon-diff-removed', 'data-name':"*.json", @col_name


  initialize: (obj)->
    @col_obj = obj
    @col_name = obj.name
    @id = obj.id
    @col_type = obj.type
    # console.log "---------collection view~-----------: #{error}"
    this

  destroy: ->
    @detach()

  select: ->
    if !@isSelected
      @addClass('selected')
      @colName.removeClass('text-info').addClass('text-highlight')
      @isSelected = true

  deselect: ->
    if @isSelected
      @removeClass('selected')
      @colName.removeClass('text-highlight').addClass('text-info')
      @isSelected=false

  refresh_edit: (new_obj)->
    # console.log @colName.text()
    # console.log new_obj.name
    @col_name = new_obj.name
    @colName.text(@col_name)
    @col_obj = new_obj


  set_used: ->
    @use = true

  set_unused: ->
    @use = false
