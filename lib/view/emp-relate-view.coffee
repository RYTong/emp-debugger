{$, $$, View, SelectListView, EditorView} = require 'atom-space-pen-views'
path = require 'path'
path_loader = require '../util/path-loader'
project_path = ''

module.exports =
class EnableRView extends SelectListView

  initialize: (@offline_path, @ignore_name) ->
    # console.log 'enable view process initial'
    super
    project_path = atom.project.getPaths()[0]
    @addClass('overlay from-top')
    # @setMaxItems(20)
    @autoDetect = index: 'Auto Detect'
    # atom.workspaceView.command "emp-debugger:enable-view", =>
    # @enable_view()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @cancel()

  enable_view: (@paths, @view_item,  @callback)->
    # console.log "enable_view"
    if @panel?
      @cancel()
    else
      @populate()
      @attach()

  attach: ->
    @storeFocusedElement()
    @panel = atom.workspace.addModalPanel(item:this)
    @focusFilterEditor()

  populate: ->
    # console.log @view_item
    if @paths
      @setItems(@paths)
    else
      @loadPathsTask?.terminate()
      @loadPathsTask = path_fliter.load_path @offline_path, @view_item?.name, @ignore_name, (@paths) ->
        @populate()

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
    # console.log("#{item.index} was selected")
    # console.log item.readed
    # item.set_view_readed()
    @initial_new_pane(item)
    @cancel()

  cancelled: ->
    @panel?.destroy()
    @panel = null


  # initial a new editor pane
  initial_new_pane: (item)->
    @callback(item.dir, @view_item)

  # set the opened editor grammar, default is HTML
  getGrammars: ->
    grammars = atom.syntax.getGrammars().filter (grammar) ->
      (grammar isnt atom.syntax.nullGrammar) and
      grammar.name is 'HTML'
    grammars
