{$, $$, View, SelectListView} = require 'atom-space-pen-views'
path = require 'path'
emp = require '../exports/emp'
relate_view = require './emp-relate-view'
path_fliter = require '../util/path-loader'
fs = require 'fs'

relate_all_views = null
tmp_offline_path = null

module.exports =
class EnableView extends SelectListView
  emp_socket_server: null


  initialize: (serializeState, @emp_socket_server) ->
    # console.log 'enable view process initial'
    super
    @addClass('overlay from-top')
    # @setMaxItems(20)
    @autoDetect = index: 'Auto Detect'

    unless tmp_offline_path = atom.config.get(emp.EMP_OFFLINE_RELATE_DIR)
      tmp_offline_path = emp.EMP_OFFLINE_RELATE_PATH_V
      atom.config.set(emp.EMP_OFFLINE_RELATE_DIR, tmp_offline_path)
    # console.log tmp_offline_path
    # @subscribe atom.project, 'path-changed', =>
    #   console.log "path changed -----------"

    atom.commands.add "atom-workspace","emp-debugger:enable-view", => @enable_view()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @cancel()
    # @remove()

  enable_view: ->
    # console.log "enable_view"
    if @panel?
      @cancel()
    else
      path_fliter.load_all_path tmp_offline_path, emp.EMP_VIEW_FILTER_IGNORE, (paths) ->
        # console.log result
        relate_all_views = paths

      @setItems(@get_view_items())
      @storeFocusedElement()
      @panel = atom.workspace.addModalPanel(item:this)
      @focusFilterEditor()

  get_view_items: ->
    # console.log @emp_socket_server.get_client_map()
    # console.log @emp_socket_server.get_client_map().get_all_views()
    tmp_map = @emp_socket_server.get_client_map().get_all_views()
    re_map = new Array()
    index = 0
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
    'show_name'

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
    # console.log "view item"
    # console.log item
    icon_class = "status-added icon-diff-added"
    icon_class =  "status-ignored icon-diff-ignored" unless !item.readed
    label_name = ''
    label_path = ''
    if item.name
      label_name = item.name
      label_path = "<div class=\"secondary-line no-icon\">Path: #{item.dir}</div>"
    else
      label_name = item.index
      label_path = ""

    "<li class=\"two-lines\">
         <div class=\"status icon #{icon_class}\"></div>
         <div class=\"primary-line icon icon-file-text\">#{label_name}</div>
         <div class=\"secondary-line no-icon\">From client: ##{item.fa_address}:#{item.fa_from}</div>" +label_path

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
    # console.log item
    item.set_view_readed()
    @initial_new_pane(item)
    @cancel()


  cancelled: ->
    @panel?.destroy()
    @panel = null

  # initial a new editor pane
  initial_new_pane: (item)->
    tmp_editor = null
    # atom.open({pathsToOpen: [pathToOpen], newWindow: true})
    if dest_file_path = item.dir
      project_path = atom.project.getPaths()[0]
      tmp_file_path = path.join project_path, dest_file_path
      if fs.existsSync tmp_file_path
        @create_editor tmp_file_path, item
      else
        tmp_name = item.name
        com_filter_arr = []
        # console.log relate_all_views
        # console.log tmp_name
        re_path_arr = path_fliter.filter_path(relate_all_views, tmp_name)
        # console.log re_path_arr
        for tmp_item in re_path_arr
          if tmp_item.name is  tmp_name
            com_filter_arr.push(tmp_item)
        if com_filter_arr.length < 1
          # tmp_editor = atom.workspace.openSync()
          atom.workspace.open('').then (tmp_editor) =>
            @store_info(tmp_editor, item)
        else if com_filter_arr.length is 1
          @create_editor tmp_item.dir, item
        else
          unless @path_view?
            @path_view = new relate_view(tmp_offline_path, emp.EMP_VIEW_FILTER_IGNORE)
          @path_view.enable_view(com_filter_arr, item, this.create_editor)
    else
      # tmp_editor = atom.workspace.openSync()
      atom.workspace.open('').then (tmp_editor) =>
        @store_info(tmp_editor, item)

  create_editor:(tmp_file_path, item) ->
    changeFocus = true
    atom.workspace.open(tmp_file_path).then (tmp_editor) =>
    # tmp_editor = atom.open({pathsToOpen: [tmp_file_path], newWindow: true})
      tmp_editor["emp_live_view"] = item
      tmp_editor["emp_live_script_name"] = null
      tmp_editor["emp_live_script"] = null
      tmp_editor.setText(item.view)
      gramers = @getGrammars()
      tmp_editor.setGrammar(gramers[0]) unless gramers[0] is undefined

  store_info: (tmp_editor, item)->
    tmp_editor["emp_live_view"] = item
    tmp_editor["emp_live_script_name"] = null
    tmp_editor["emp_live_script"] = null
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
