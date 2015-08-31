{Emitter, Disposable, CompositeDisposable} = require 'atom'
{EnableView} = require './emp-link-file'
resolve = require 'resolve'
path = require 'path'
fs = require 'fs'
emp = require '../exports/emp'
path_fliter = require '../util/path-loader'

module.exports =
class emp_open_link
  path_list:[]

  constructor: ()->
    @subscriptions = new CompositeDisposable
    @pathCache =  {}
    @link_view = {}
    if atom.project.getPaths().length isnt 0
      path_fliter.load_all_path_unignore "", (@path_list) =>
      # console.log @path_list
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'emp-debugger:open_link': (event) =>
        # console.log "asdasdasd"
        @forward()
    @subscriptions.add atom.commands.add 'atom-text-editor',
      'emp-debugger:refresh_link': (event) =>
        # console.log "asdasdasd"
        @refresh()

  serialize: ->
    pathCache: @pathCache

  refresh: ->
    path_fliter.load_all_path_unignore "", (@path_list) =>

    emp.show_info "刷新 link 路径成功!"

  forward: ->
    editor = atom.workspace.getActiveTextEditor()
    @uri = editor.getSelectedText()
    console.log @uri
    line =  editor.lineTextForBufferRow editor.getCursorBufferPosition().row
    # line =  editor.lineTextForScreenRow editor.getCursorScreenPosition().row
    console.log line
    @uri = editor.getSelectedText() or @get_text(editor)
    console.log @uri
    # split = @getPosition()
    if @uri
      if @uri.indexOf('http:') is 0  or @uri.indexOf('https:') is 0 or @uri.indexOf('localhost:') is 0
        atom.workspace.open @uri #, split:split
      else
        @open_uri(editor, line)

  open_uri: (editor, line)->
    try
      file_path = path.dirname editor.getPath()
      ext = path.extname editor.getPath()

      exists = fs.existsSync or fs.accessSync
      filename = path.basename(@uri)
      # try
      if line.includes 'require'
        filepath = resolve.sync(@uri, basedir:file_path,extensions:['.js','.coffee'])
        return @do_open([filepath],editor) if fs.statSync filepath
      else

        console.log line
        console.log "asd"
      @open_file(editor, file_path)
    catch e
      console.log 'Error finding the filepath',e
      try
        module  = require 'module'
        return @do_open([filepath],editor) if fs.statSync filepath if filepath =  module._resolveFilename @uri
        @open_file(editor, file_path)
      catch e
        console.log 'Error finding the filepath with module',e
        @open_file(editor, file_path)

  open_file: (editor, file_path)->
    # console.log "open_file -------"
    try
      ext = path.extname editor.getPath()
      exists = fs.existsSync or fs.accessSync
      project_path = atom.project.getPaths()[0]
      if ofname = @pathCache[project_path]?[@uri]
        @do_open([ofname],editor)
        return

      # console.log file_path
      base_path = path.dirname path.dirname file_path
      base_dir = path.basename file_path
      # console.log base_dir
      if base_dir is emp.OFF_EXTENSION_XHTML
        if @uri.split("/").length > 1
          # console.log "do in o spec"
          tmp_file_path = path.join base_path, @uri
          # console.log tmp_file_path
          if exists tmp_file_path
            @do_open([tmp_file_path],editor)
            return
        else
          # console.log "do in o com"
          base_path = path.dirname base_path
          ext_name = path.extname(@uri)?.split "."
          ext_name = ext_name?[1]
          ext_name?=""
          tmp_file_path = path.join base_path, ext_name.toLowerCase(),@uri
          # console.log tmp_file_path
          if exists tmp_file_path
            @do_open([tmp_file_path],editor)
            return

      # public_dir =  emp.LINK_PUBLICK_DIR
      file_src = []
      if @uri[0] is '/' or @uri[0] is '\\'
        file_src.unshift file_path+@uri
        file_src.unshift file_path+@uri+ext unless path.extname @uri
      else
        file_src.unshift project_path+'/'+@uri
        file_src.unshift project_path+'/'+@uri+ext unless path.extname @uri
      public_dir = @get_publick_dir(project_path)

      for i,dir of public_dir
        if @uri[0] is '/' or @uri[0] is '\\'
          file_src.unshift dir+'/'+@uri
        else
          file_src.unshift dir+'/'+@uri

      # console.log file_src
      for url in file_src
        if exists url
          @do_open([url],editor)
          return

      file_name = path.basename(@uri)
      # @complex = true
      if @path_list.length is 0
        @refresh()
      filter_result = path_fliter.filter_path(@path_list, file_name)
      if filter_result.length is 1
        @do_open([filter_result[0].dir],editor)
      else
        new EnableView filter_result, (sel_file) =>
          @do_open([sel_file],editor)
      # console.log 'erls -----------'
    catch e
      console.log 'Error finding the filepath',e

  do_open: (url,editor,back=false)->
    atom.workspace.open url[0]
      .then (tmp_editor)=>
        project_path = atom.project.getPaths()[0]
        tmp_editor.setCursorScreenPosition(url[1]) if url[1]
        @link_view["#{tmp_editor.getPath()}"] = [editor.getPath(),editor.getCursorScreenPosition()] unless back

  get_publick_dir: (project_path)->
    default_dir = emp.OFF_LINE_LINK_DIR
    default_pub = path.join project_path,default_dir
    new_dir_chis = []
    if fs.existsSync default_pub
      dir_chis = fs.readdirSync default_pub
      new_dir_chis = []
      for tmp_dir in dir_chis
        if !tmp_dir.match(/^\..*/ig)
          if tmp_dir.toLowerCase() is emp.ADAPTER_PLT_D
            new_tmp_dir = path.join(default_pub,tmp_dir)
            # new_dir_chis.push new_tmp_dir
            new_dir_chis = new_dir_chis.concat @get_dirs(new_tmp_dir, 0)
          else
            new_tmp_dir = path.join(default_pub,tmp_dir)
            # new_dir_chis.push new_tmp_dir
            new_dir_chis = new_dir_chis.concat @get_dirs(new_tmp_dir, 1)
    return new_dir_chis

  get_dirs: (root_dir, deepth)->
    new_dir_chis = []
    if fs.existsSync root_dir
      dir_chis = fs.readdirSync root_dir
      new_dir_chis = []
      for tmp_dir in dir_chis
        if !tmp_dir.match(/^\..*/ig)
          dir_next_depth = []
          new_tmp_dir = path.join(root_dir,tmp_dir)
          if deepth > 0
            dir_next_depth = @get_dirs(new_tmp_dir, deepth-1)
          else
            new_dir_chis.push new_tmp_dir
          new_dir_chis = new_dir_chis.concat dir_next_depth
    return new_dir_chis

  get_text: (editor)->
    cursor = editor.getCursors()[0]
    range = editor.displayBuffer.bufferRangeForScopeAtPosition '.string.quoted',cursor.getBufferPosition()
    console.log range
    # console.log editor.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    if range
      text = editor.getTextInBufferRange(range)[1..-2]
      # if text.includes ","
      #   text = editor.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    else
      text = editor.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    console.log text
    text = text[0..-2] if text.slice(-1) is ':'
    text.trim()

  getPosition: ->
    activePane = atom.workspace.paneForItem atom.workspace.getActiveTextEditor()
    paneAxis = activePane.getParent()
    paneIndex = paneAxis.getPanes().indexOf(activePane)
    orientation = paneAxis.orientation ? 'horizontal'
    if orientation is 'horizontal'
      if  paneIndex is 0 then 'right' else 'left'
    else
      if  paneIndex is 0 then 'down' else 'top'
