{$, $$, View} = require 'atom'
_ = require 'underscore-plus'
ItemEditorView = require './item-editor-view'
ColItemView = require './item_view/collection-item-view'
emp = require '../exports/emp'

module.exports =
class SettingsPanel extends View
  select_entry:null
  @content: ->
    @div class: 'col-list-panel', =>
      # @section class: 'config-section', =>
      @div class: 'block section-heading icon icon-gear', "Collections Management"
      @div class: 'div-body', =>
        @div class:'div-con ', =>
          @div class:'emp_item_list_div', =>
            @ol outlet:"gen_col_list", class: 'list-tree', =>
          @div class:'emp_item_btn_div', =>
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'add_col', ' Add... '
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'edi_col','  Edit  '
            @div class: 'item_cbtn_div', =>
              @button class: 'item_btn btn btn-info inline-block-tight', click:'del_col',' Delete '



  initialize: (all_objs) ->
    @on 'click', '.emp_col_item_tag', (e, element) =>
      @itemClicked(e, element)

    # @loadingElement.remove()
    # settings = atom.config.getSettings()
    # @appendSettings()

    # @bindFormFields()
    # @bindEditors()

  refresh_col_list:(new_all_obj) ->
    console.log new_all_obj
    root_col = new_all_obj.root
    child_col = new_all_obj.child.obj_list

    for n, obj of root_col
      tmp_item = new ColItemView(obj)
      @gen_col_list.append(tmp_item)

    for n, obj of child_col
      tmp_item = new ColItemView(obj)
      @gen_col_list.append(tmp_item)




  appendChildCol: (col_name, col_id, type) ->
    $$ ->
      @li class: 'list-item' , =>
        @div outlet: 'col_item', etype:type,id:col_id,  class: 'emp_col_item_tag list-item', =>
          @span class: 'text-info icon icon-diff-removed', 'data-name':"*.json", col_name

  appendRootCol: (col_name, col_id, type) ->
    $$ ->
      @li class: 'list-item' , =>
        @div outlet: 'col_item', id:col_id, etype:type,class: 'emp_col_item_tag list-item', =>
          @span class: 'text-info icon icon-diff-added', 'data-name':"*.json", col_name

  itemClicked:(e, element) ->
    console.log "item click"
    entry = $(e.currentTarget).view()
    if @select_entry isnt null
      @select_entry.deselect()
    entry.select()
    @select_entry = entry

  add_col: (e, element)->
    console.log 'add_col'

  edi_col: (e, element)->
    console.log 'edi_col'

  del_col: (e, element)->
    console.log 'del_col'


    # console.log entry.getAttribute('id')
    # console.log $(e.currentTarget).id


          # for name in _.keys(settings).sort()
          #   appendSetting.call(this, namespace, name, settings[name])

  bindFormFields: ->
    for input in @find('input[id]').toArray()
      do (input) =>
        input = $(input)
        name = input.attr('id')
        type = input.attr('type')

        @subscribe atom.config.observe name, (value) ->
          if type is 'checkbox'
            input.prop('checked', value)
          else
            input.val(value) if value

        input.on 'change', =>
          value = input.val()
          if type == 'checkbox'
            value = !!input.prop('checked')
          else
            value = @parseValue(type, value)

          atom.config.set(name, value)

  bindEditors: ->
    for editorView in @find('.editor[id]').views()
      do (editorView) =>
        name = editorView.attr('id')
        type = editorView.attr('type')

        if defaultValue = @valueToString(atom.config.getDefault(name))
          editorView.setPlaceholderText("Default: #{defaultValue}")

        @subscribe atom.config.observe name, (value) =>
          if atom.config.isDefault(name)
            stringValue = ''
          else
            stringValue = @valueToString(value) ? ''

          return if stringValue is editorView.getText()
          return if _.isEqual(value, @parseValue(type, editorView.getText()))

          editorView.setText(stringValue)

        editorView.getEditor().getBuffer().on 'contents-modified', =>
          atom.config.set(name, @parseValue(type, editorView.getText()))

  valueToString: (value) ->
    if _.isArray(value)
      value.join(", ")
    else
      value?.toString()

  parseValue: (type, value) ->
    if value == ''
      value = undefined
    else if type == 'number'
      floatValue = parseFloat(value)
      value = floatValue unless isNaN(floatValue)
    else if type == 'array'
      arrayValue = (value or '').split(',')
      value = (val.trim() for val in arrayValue when val)

    value

###
# Space Pen Helpers
###

isEditableArray = (array) ->
  for item in array
    return false unless _.isString(item)
  true

appendSetting = (namespace, name, value) ->
  if namespace is 'core'
    return if name is 'themes' # Handled in the Themes panel
    return if name is 'disabledPackages' # Handled in the Packages panel

  @div class: 'control-group', =>
    @div class: 'controls', =>
      if _.isBoolean(value)
        appendCheckbox.call(this, namespace, name, value)
      else if _.isArray(value)
        appendArray.call(this, namespace, name, value) if isEditableArray(value)
      else if _.isObject(value)
        appendObject.call(this, namespace, name, value)
      else
        appendEditor.call(this, namespace, name, value)

getSettingTitle = (name='') ->
  _.uncamelcase(name).split('.').map(_.capitalize).join(' ')

appendCheckbox = (namespace, name, value) ->
  keyPath = "#{namespace}.#{name}"
  @div class: 'checkbox', =>
    @label for: keyPath, =>
      @input id: keyPath, type: 'checkbox'
      @text getSettingTitle(name)

appendEditor = (namespace, name, value) ->
  keyPath = "#{namespace}.#{name}"
  if _.isNumber(value)
    type = 'number'
  else
    type = 'string'

  @label class: 'control-label', getSettingTitle(name)
  @div class: 'controls', =>
    @div class: 'editor-container', =>
      @subview keyPath.replace(/\./g, ''), new ItemEditorView(attributes: {id: keyPath, type: type})

appendArray = (namespace, name, value) ->
  keyPath = "#{namespace}.#{name}"
  @label class: 'control-label', getSettingTitle(name)
  @div class: 'controls', =>
    @div class: 'editor-container', =>
      @subview keyPath.replace(/\./g, ''), new ItemEditorView(attributes: {id: keyPath, type: 'array'})

appendObject = (namespace, name, value) ->
  for key in _.keys(value).sort()
    appendSetting.call(this, namespace, "#{name}.#{key}", value[key])
