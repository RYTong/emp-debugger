{$, $$, View, SelectListView, EditorView} = require 'atom'

module.exports =
class ItemSelectorView extends SelectListView

  initialize: (item) ->
    # console.log 'enable view process initial'
    super
    console.log item
    # @addClass('overlay from-top')
    @addClass('form-control')
    # @setMaxItems(5)
    @setItems(item)
    @storeFocusedElement()
    this


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @cancel()
    @remove()

  enable_item: (item)->
    console.log "enable_view"
    @setItems(item)
    @storeFocusedElement()
    # @focusFilterEditor()
    this

  # get_script_items: ->
  #   # console.log @emp_socket_server.get_client_map()
  #   # console.log @emp_socket_server.get_client_map().get_all_views()
  #   re_map = new Array()
  #   index = 0
  #   len = tmp_map.length
  #   # console.log tmp_map
  #   for name,scr_obj of tmp_map
  #     # console.log name
  #     re_map.push(scr_obj)
  #   # loop
  #   #   break if len is 0
  #   #   len -= 1
  #   #   re_map[index] = tmp_map[len]
  #   #   index += 1
  #   re_map

  # Public: Get the property name to use when filtering items.
  #
  # This method may be overridden by classes to allow fuzzy filtering based
  # on a specific property of the item objects.
  #
  # For example if the objects you pass to {::setItems} are of the type
  # `{"id": 3, "name": "Atom"}` then you would return `"name"` from this method
  # to fuzzy filter by that property when text is entered into this view's
  # editor.
  #
  # Returns the property name to fuzzy filter by.
  getFilterKey: ->
    # console.log "get key"
    'name'

  # Public: Create a view for the given model item.
  #
  # This method must be overridden by subclasses.
  #
  # This is called when the item is about to appended to the list view.
  #
  # item - The model item being rendered. This will always be one of the items
  #        previously passed to {::setItems}.
  #
  # Returns a String of HTML, DOM element, jQuery object, or View.
  viewForItem: (item) ->

    console.log item
    $$ ->
      @li =>
        @raw item.name



  # Public: Callback function for when an item is selected.
  #
  # This method must be overridden by subclasses.
  #
  # item - The selected model item. This will always be one of the items
  #        previously passed to {::setItems}.
  #
  # Returns a DOM element, jQuery object, or {View}.
  confirmed: (item) ->
    # console.log("#{item.index} was selected")
    # console.log item.readed
    # @cancel()
    console.log item

  confirmSelection: ->
    # console.log "selections~"
    item = @getSelectedItem()
    if item?
      @confirmed(item)
    else
      @cancel()

  cancelled: ->
    @filterEditorView.getEditor().setText('')
    # @filterEditorView.updateDisplay()

  cancel: ->
    @list.empty()
    # @cancelling = true
    filterEditorViewFocused = @filterEditorView.isFocused
    # @filterEditorView.getEditor().setText('')
    # @detach()
    @restoreFocus() if filterEditorViewFocused
    @cancelling = false
