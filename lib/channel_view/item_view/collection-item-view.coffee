{$, View} = require 'atom'
emp = require '../../exports/emp'

module.exports =
class ColItemView extends View
  col_obj:null
  col_type:null
  col_id: null
  col_name:null
  isSelected: false
  @content: (obj, type)->
    @col_obj = obj
    @col_name = obj.name
    @col_id = obj.id
    @col_type = obj.type
    @col_name ?= @col_id
    if @col_type is emp.COL_ROOT_TYPE
      @li class: 'list-item' , =>
        @div outlet: 'col_item', id:@col_id, etype:@col_type,class: 'emp_col_item_tag list-item', =>
          @span outlet: 'colName', class: 'text-info icon icon-diff-added', 'data-name':"*.json", @col_name
    else
      @li class: 'list-item' , =>
        @div outlet: 'col_item', etype:@col_type,id:@col_id,  class: 'emp_col_item_tag list-item', =>
          @span outlet: 'colName',class: 'text-info icon icon-diff-removed', 'data-name':"*.json", @col_name


  initialize: (obj)->
    @col_obj = obj
    @col_name = obj.name
    @col_id = obj.id
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
