{$, $$, View, SelectListView, EditorView} = require 'atom-space-pen-views'
path_fliter = require '../util/path-loader'
fs = require 'fs'
path = require 'path'
path_loader = require '../util/path-loader'
project_path = ''

module.exports =
class EnableRView extends SelectListView

  initialize: (@item_obj) ->
    # console.log 'enable view process initial'
    super
    project_path = atom.project.getPaths()[0]
    @addClass('overlay from-top')
    # @setMaxItems(20)
    @autoDetect = index: 'Auto Detect'

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @cancel()

  enable_view: (@item_obj,  @callback)->
    # console.log "enable_view"
    if @panel?
      @cancel()
    else
      # console.log @item_obj
      @setItems(@get_view_items())
      @storeFocusedElement()
      @panel = atom.workspace.addModalPanel(item:this)
      @focusFilterEditor()


  get_view_items: ->
    re_map = new Array()
    index = 0
    # console.log @item_obj
    tmp_map = @item_obj.detail_map
    # console.log tmp_map

    len = tmp_map.length
    loop
      break if len is 0
      len -= 1
      re_map[index] = tmp_map[len]
      index += 1
    # console.log re_map
    re_map


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
  # viewForItem: (item) ->
  #   console.log item
  #   new_file_dir = item.dir.replace project_path, ""
  #   "<li class=\"two-lines\">
  #        <div class=\"primary-line icon icon-file-text\">#{item.name}</div>
  #        <div class=\"secondary-line no-icon\">Path: #{new_file_dir}</div>"

  viewForItem: (item) ->
    # console.log "view item"
    # console.log item
    icon_class = "status-added icon-diff-added"
    icon_class =  "status-ignored icon-diff-ignored" unless !item.readed
    label_name = ''
    label_path = ''
    if item.show_name
      label_name = item.show_name
      label_path = "<div class=\"secondary-line no-icon\">Path: #{item.dir}</div>"
    else
      label_name = item.index
      label_path = ""

    "<li class=\"two-lines\">
         <div class=\"status icon #{icon_class}\"></div>
         <div class=\"primary-line icon icon-file-text\">#{label_name}</div>
         <div class=\"secondary-line no-icon\">File Type: ##{item.file_type}</div>" +label_path

  # Public: Callback function for when an item is selected.
  #
  # This method must be overridden by subclasses.
  #
  # item - The selected model item. This will always be one of the items
  #        previously passed to {::setItems}.
  #
  # Returns a DOM element, jQuery object, or {View}.
  confirmed: (item) ->
    # item.set_view_readed()
    # console.log item
    @initial_new_pane(item)
    @cancel()

  cancelled: ->
    @panel?.destroy()
    @panel = null

  # initial a new editor pane
  initial_new_pane: (item)->
    tmp_editor = null
    # console.log item
    # atom.open({pathsToOpen: [pathToOpen], newWindow: true})
    if dest_file_path = item.dir
      project_path = atom.project.getPaths()[0]
      tmp_file_path = path.join project_path, dest_file_path
      # console.log "--------------------------------------------"
      # console.log tmp_file_path
      if fs.existsSync tmp_file_path
        @create_editor tmp_file_path, item
      else
        tmp_name = item.name
        atom.workspace.open('').then (tmp_editor) =>
          @store_info(tmp_editor, item)
    else
      # tmp_editor = atom.workspace.openSync()
      atom.workspace.open('').then (tmp_editor) =>
        @store_info(tmp_editor, item)

  # set the opened editor grammar, default is HTML
  getGrammars: (grammar_name)->
    grammars = atom.grammars.getGrammars().filter (grammar) ->
      (grammar isnt atom.grammars.nullGrammar) and
      grammar.name is 'Emp View'
    grammars


  create_editor:(tmp_file_path, item) ->
    changeFocus = true
    # console.log item
    atom.workspace.open(tmp_file_path).then (tmp_editor) =>
    # tmp_editor = atom.open({pathsToOpen: [tmp_file_path], newWindow: true})
      tmp_editor["emp_live_view"] = item
      tmp_editor.setText(item.view)
      gramers = @getGrammars()
      tmp_editor.setGrammar(gramers[0]) unless gramers[0] is undefined

  store_info: (tmp_editor, item)->
    tmp_editor["emp_live_view"] = item
    tmp_editor.setText(item.view)
    gramers = @getGrammars()
    tmp_editor.setGrammar(gramers[0]) unless gramers[0] is undefined

  # set the opened editor grammar, default is HTML
  # getGrammars: ->
  #   console.log "3333333333333"
  #   console.log atom.syntax.getGrammars()
  #   grammars = atom.syntax.getGrammars().filter (grammar) ->
  #     (grammar isnt atom.syntax.nullGrammar) and
  #     grammar.name is 'HTML'
  #   grammars

  getGrammars: (grammar_name)->
    grammars = atom.grammars.getGrammars().filter (grammar) ->
      (grammar isnt atom.grammars.nullGrammar) and
      grammar.name is 'Emp View'
    grammars
