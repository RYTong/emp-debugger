{$, $$, View, SelectListView, EditorView} = require 'atom'
path = require 'path'
emp = require '../exports/emp'
relate_view = require './emp-relate-view'
path_fliter = require '../util/path-loader'

relate_all_views = null
tmp_offline_path = null

module.exports =
class EnableView extends SelectListView
  emp_socket_server: null


  initialize: (serializeState, @emp_socket_server) ->
    # console.log 'enable view process initial'
    super
    @addClass('overlay from-top')
    @setMaxItems(20)

    unless tmp_offline_path = atom.config.get(emp.EMP_OFFLINE_RELATE_DIR)
      tmp_offline_path = emp.EMP_OFFLINE_RELATE_PATH_V
      atom.config.set(emp.EMP_OFFLINE_RELATE_DIR, tmp_offline_path)
    # console.log tmp_offline_path
    path_fliter.load_all_path tmp_offline_path, emp.EMP_VIEW_FILTER_IGNORE, (paths) ->
      # console.log result
      relate_all_views = paths

    @subscribe atom.project, 'path-changed', =>
      console.log "path changed -----------"
      console.log data

    atom.workspaceView.command "emp-debugger:enable-view", => @enable_view()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @cancel()
    @remove()

  enable_view: ->
    # console.log "enable_view"
    if @hasParent()
      @cancel()
    else
      @setItems(@get_view_items())
      @storeFocusedElement()
      atom.workspaceView.append(this)
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
    'index'

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
    # console.log item.readed
    item.set_view_readed()
    @cancel()
    @initial_new_pane(item)

  confirmSelection: ->
    # console.log "selections~"
    item = @getSelectedItem()
    if item?
      @confirmed(item)
    else
      @cancel()

  cancelled: ->
    @filterEditorView.getEditor().setText('')
    @filterEditorView.updateDisplay()


  # initial a new editor pane
  initial_new_pane: (item)->
    tmp_editor = null
    # atom.open({pathsToOpen: [pathToOpen], newWindow: true})
    if dest_file_path = item.dir
      tmp_name = item.name
      index = 0
      # console.log relate_all_views
      re_path_arr = path_fliter.filter_path(relate_all_views, tmp_name)
      # console.log re_path_arr
      for tmp_item in re_path_arr
        if tmp_item.name is  tmp_name
          index += 1
      if index is 1
        project_path = atom.project.getPath()
        tmp_file_path = path.join project_path, dest_file_path
        # test_path = path.join project_path, 'test.xhtml'
        @create_editor tmp_file_path, item
      else
        @path_view = new relate_view(re_path_arr, item, tmp_offline_path, emp.EMP_VIEW_FILTER_IGNORE, this.create_editor)
    else
      tmp_editor = atom.workspace.openSync()
      @store_info(tmp_editor, item)

  create_editor:(tmp_file_path, item) ->
    changeFocus = true
    tmp_editor = atom.workspaceView.openSync(tmp_file_path, { changeFocus })
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
  getGrammars: ->
    grammars = atom.syntax.getGrammars().filter (grammar) ->
      (grammar isnt atom.syntax.nullGrammar) and
      grammar.name is 'HTML'

    # grammars.sort (grammarA, grammarB) ->
    #   if grammarA.scopeName is 'text.plain'
    #     -1
    #   else if grammarB.scopeName is 'text.plain'
    #     1
    #   else
    #     grammarA.name?.localeCompare?(grammarB.name) ? grammarA.scopeName?.localeCompare?(grammarB.name) ? 1

    grammars
