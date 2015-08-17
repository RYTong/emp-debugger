{$, $$, View, SelectListView, EditorView} = require 'atom-space-pen-views'
path = require 'path'
# path_loader = require '../util/path-loader'
project_path = ''

class LoadingView
  constructor: (serializeState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('emp_link')
    loading = document.createElement('span')
    loading.classList.add('loading')
    loading.classList.add('loading-spinner-large')
    loading.classList.add('inline-block')
    @element.appendChild(loading)
  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element


class EnableView extends SelectListView

  initialize: (@items, @callback) ->
    # console.log 'enable view process initial'
    super
    project_path = atom.project.getPaths()[0]
    @addClass('overlay from-top')
    @autoDetect = index: 'Auto Detect'
    @setItems(@items)
    @attach()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @cancel()

  enable_view: (@items)->
    if @panel?
      @cancel()
    else
      # @populate()
      @setItems(@items)
      @attach()

  attach: ->
    @storeFocusedElement()
    @panel = atom.workspace.addModalPanel(item:this)
    @focusFilterEditor()

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
    new_file_dir = item.dir.replace project_path, ""
    "<li class=\"two-lines\">
         <div class=\"primary-line icon icon-file-text\">#{item.name}</div>
         <div class=\"secondary-line no-icon\">Path: #{new_file_dir}</div>"

  # Public: Callback function for when an item is selected.
  #
  # This method must be overridden by subclasses.
  #
  # item - The selected model item. This will always be one of the items
  #        previously passed to {::setItems}.
  #
  # Returns a DOM element, jQuery object, or {View}.
  confirmed: (item) ->
    @initial_new_pane(item)
    @cancel()

  cancelled: ->
    @panel?.destroy()
    @panel = null


  # initial a new editor pane
  initial_new_pane: (item)->
    # @callback(item.dir, @view_item)
    # console.log item
    @callback(item.dir)

  # set the opened editor grammar, default is HTML
  getGrammars: (grammar_name)->
    grammars = atom.grammars.getGrammars().filter (grammar) ->
      (grammar isnt atom.grammars.nullGrammar) and
      grammar.name is 'Emp View'
    grammars

module.exports = {LoadingView, EnableView}
