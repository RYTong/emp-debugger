{$, $$, View, SelectListView} = require 'atom-space-pen-views'
emp = require '../exports/emp'
relate_view = require './emp-relate-view'
path_fliter = require '../util/path-loader'
tmp_offline_path = ''
relate_all_views = ''

module.exports =
class EnableLuaView extends SelectListView
  emp_socket_server: null

  initialize: (serializeState, @emp_socket_server) ->
    # console.log 'enable view process initial'
    super
    @addClass('overlay from-top')
    # @setMaxItems(20)
    @autoDetect = index: 'Auto Detect'
    unless tmp_offline_path = atom.config.get(emp.EMP_OFFLINE_RELATE_DIR)
      tmp_offline_path = emp.EMP_OFFLINE_RELATE_PATH_V

    atom.commands.add "atom-workspace","emp-debugger:enable-lua", => @enable_lua()


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @cancel()
    # @remove()

  enable_lua: ->
    # console.log "enable_view"
    if @panel?
      @cancel()
    else
      path_fliter.load_all_path tmp_offline_path, emp.EMP_SCRIPT_FILTER_IGNORE, (paths) ->
        # console.log result
        relate_all_views = paths

      @setItems(@get_script_items())
      @storeFocusedElement()
      @panel = atom.workspace.addModalPanel(item:this)
      @focusFilterEditor()

  get_script_items: ->
    # console.log @emp_socket_server.get_client_map()
    # console.log @emp_socket_server.get_client_map().get_all_views()
    tmp_map = @emp_socket_server.get_client_map().get_all_script()
    re_map = new Array()
    index = 0
    len = tmp_map.length

    for name,scr_obj of tmp_map
      re_map.push(scr_obj)
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
    'script_index'

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
    icon_class = "status-added icon-diff-added"
    icon_class =  "status-ignored icon-diff-ignored" unless !item.readed

    "<li class=\"two-lines\">
         <div class=\"status icon #{icon_class}\"></div>
         <div class=\"primary-line icon icon-file-text\">#{item.script_index}</div>
         <div class=\"secondary-line no-icon\">From client: ##{item.fa_address}:#{item.fa_from}</div>"

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
    item.set_readed()
    @initial_new_pane(item)
    @cancel()

  cancelled: ->
    @panel?.destroy()
    @panel = null


  # initial a new editor pane
  initial_new_pane: (item)->
    tmp_name = item.script_name
    if dest_file_path = item.dir
      project_path = atom.project.getPath()
      tmp_file_path = path.join project_path, dest_file_path
      if fs.existsSync tmp_file_path
        @create_editor tmp_file_path, item
    else
      com_filter_arr = []
      # console.log relate_all_views
      # console.log tmp_name
      re_path_arr = path_fliter.filter_path(relate_all_views, tmp_name)
      # console.log re_path_arr
      for tmp_item in re_path_arr
        if tmp_item.name is  tmp_name
          com_filter_arr.push(tmp_item)

      if com_filter_arr.length is 0
        tmp_editor = atom.workspace.openSync()
        @store_info(tmp_editor, item)
      else if com_filter_arr.length is 1
        tmp_item = com_filter_arr.pop()
        @create_editor tmp_item.dir, item
      else
        unless @path_view?
          @path_view = new relate_view(tmp_offline_path, emp.EMP_SCRIPT_FILTER_IGNORE)
        @path_view.enable_view(com_filter_arr, item, this.create_editor)



  create_editor:(tmp_file_path, item) ->
    changeFocus = true
    tmp_editor = atom.workspace.openSync(tmp_file_path, { changeFocus })

    tmp_editor["emp_live_view"] = item.fa_view.view
    tmp_editor["emp_live_script_name"] = item.script_name
    tmp_editor["emp_live_script"] = item
    # console.log tmp_editor
    tmp_editor.setText(item.script_con)
    gramers = @getGrammars()
    tmp_editor.setGrammar(gramers[0]) unless gramers[0] is undefined

  store_info: (tmp_editor, item)->
    tmp_editor["emp_live_view"] = item.fa_view.view
    tmp_editor["emp_live_script_name"] = item.script_name
    tmp_editor["emp_live_script"] = item
    # console.log tmp_editor
    tmp_editor.setText(item.script_con)
    gramers = @getGrammars()
    tmp_editor.setGrammar(gramers[0]) unless gramers[0] is undefined

  # set the opened editor grammar, default is HTML
  getGrammars: ->
    grammars = atom.syntax.getGrammars().filter (grammar) ->
      (grammar isnt atom.syntax.nullGrammar) and
      grammar.name is 'Lua'

    if !grammars
      grammars = atom.syntax.getGrammars().filter (grammar) ->
        (grammar isnt atom.syntax.nullGrammar) and
        grammar.name is 'HTML'
    grammars
