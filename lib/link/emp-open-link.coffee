{Point, Range, Emitter, Disposable, CompositeDisposable} = require 'atom'
_ = require 'underscore-plus'
{EnableView} = require './emp-link-file'
resolve = require 'resolve'
path = require 'path'
fs = require 'fs'
emp = require '../exports/emp'
path_fliter = require '../util/path-loader'
head_parse = require('../head-parser/lib/parser').parse

parse_type_css = "link"
parse_type_css_link = "ref"
parse_type_lua = "script-src"
parse_type_lua_link = "src"

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

    @exists = fs.existsSync or fs.accessSync

  serialize: ->
    pathCache: @pathCache

  refresh: ->
    path_fliter.load_all_path_unignore "", (@path_list) =>
    emp.show_info "刷新 link 路径成功!"

  forward: ->
    editor = atom.workspace.getActiveTextEditor()
    @uri = editor.getSelectedText() or @get_text(editor)
    # console.log @uri
    return atom.workspace.open @uri unless !@check_http()
    # file_path = path.dirname editor.getPath()
    # ext = path.extname(editor.getPath()).toLowerCase()
    line =  editor.lineTextForBufferRow editor.getCursorBufferPosition().row
    # console.log ext

    # try
    if line.includes 'require'
      return @resolve_file(editor, ['.js', '.coffee'])

    if line.includes '<link'
      return @filter_file(editor, ['.css','.less'])

    if line.includes '<script'
      return @filter_file(editor, ['.js', '.lua'])


    # unless @uri.match
    # console.log "else----"
    [@uri, uri_type] = @get_text_re(editor)
    filter_file_list = @parse_head_file(editor, uri_type)
    @filter_file_content(editor, filter_file_list, uri_type)
    # console.log @uri

  parse_head_file: (editor, uri_type) ->
    html_con = editor.getText()
    # console.log html_con
    re_con = /<head>[\s\S]*?<\/head>/g.exec(html_con)
    # console.log re_con
    new_re_arr = []
    if re_con
      re_objs = head_parse(re_con[0])
      # console.log re_objs
      if uri_type is "css"
        for obj in re_objs
          if obj.type is parse_type_css
            props = obj.props
            store_link_dir = ""
            for tmp_obj in props
              if tmp_obj.key is parse_type_css_link
                store_link_dir = tmp_obj.value
                break
            if store_link_dir
              new_re_arr.unshift store_link_dir
      else
        for obj in re_objs
          if obj.type is parse_type_lua
            props = obj.props
            store_link_dir = ""
            for tmp_obj in props
              if tmp_obj.key is parse_type_lua_link
                store_link_dir = tmp_obj.value
                break
            if store_link_dir
              new_re_arr.unshift store_link_dir
    console.log new_re_arr
    new_re_arr

  filter_file_content:(editor, filter_file_list, uri_type) ->
    file_path = path.dirname editor.getPath()

    # # 缓存打开过的文件
    # if ofname = @pathCache[project_path]?[@uri]
    #   @do_open([ofname],editor)
    #   return

    # console.log file_path
    # 判断是否为 emp 文件结构下的文件
    # ---------- start ----------
    cha_path = path.resolve file_path, "../../"
    base_dir = path.basename(file_path).toLowerCase()
    com_path = path.resolve cha_path, ".."
    if base_dir is emp.OFF_EXTENSION_XHTML or base_dir is emp.OFF_EXTENSION_HTML
      for tmp_filter_path in filter_file_list


        if tmp_filter_path.split("/").length > 1
          # console.log "do in o spec"
          tmp_file_path = path.join cha_path, tmp_filter_path
          # console.log tmp_file_path
          if @exists tmp_file_path
            # TODO:
            # console.log "exist"
            tmp_con = fs.readFileSync tmp_file_path, "utf-8"
            # console.log tmp_con.match @uri
            if tmp_con.match @uri
              @do_open_re [tmp_file_path]
              return
            # break
            continue
        else
          # console.log "do in o com"
          tmp_file_path = path.join com_path, uri_type, tmp_filter_path
          # console.log tmp_file_path
          if @exists tmp_file_path
            # @do_open([tmp_file_path],editor)
            # TODO:
            # console.log "exist"
            tmp_con = fs.readFileSync tmp_file_path, "utf-8"
            # console.log tmp_con.match @uri
            if tmp_con.match @uri
              @do_open_re [tmp_file_path]
              return
            # break
            continue

  do_open_re: (url)->
    atom.workspace.open url[0]
      .then (tmp_editor)=>
        # console.log "----------------"
        # console.log @uri
        expression = _.escapeRegExp(@uri)
        regex = new RegExp(expression, 'ig')
        project_path = atom.project.getPaths()[0]
        newMarkers = []
        tmp_editor.scanInBufferRange regex, Range(Point.ZERO, Point.INFINITY), ({range}) =>
          # new_marker = @createMarker(range, tmp_editor)
          newMarkers.push(@createMarker(range, tmp_editor))
        # console.log newMarkers
        if newMarkers.length > 0
          new_marker = newMarkers[0]
          ranges = new_marker.getBufferRange()
          # console.log ranges
          tmp_editor.setCursorBufferPosition ranges.start
          # tmp_editor.setSelectedBufferRanges(ranges, flash: true)
          # # tmp_editor.scrollToBufferPosition(new_marker.getStartBufferPosition(), center: true)
          # console.log new_marker.getStartBufferPositio()
          #
          # tmp_editor.setCursorScreenPosition ranges.start
        # @pathCache[project_path] = @pathCache[project_path] or {}
        # @pathCache[project_path][@uri] = url[0]
        # @link_view["#{tmp_editor.getPath()}"] = [editor.getPath(),editor.getCursorScreenPosition()] unless back


  createMarker: (range, tmp_editor) ->
    marker = tmp_editor.markBufferRange(range,
      invalidate: 'inside'
      class: @constructor.markerClass
      persistent: false
      maintainHistory: false
    )
    # unless @useMarkerLayers
    #   @decorationsByMarkerId[marker.id] = @editor.decorateMarker(marker,
    #     type: 'highlight',
    #     class: @constructor.markerClass
    #   )
    marker

  check_http:() ->
    if @uri.indexOf('http:') is 0  or @uri.indexOf('https:') is 0 or @uri.indexOf('localhost:') is 0
      true
    else
      false

  filter_file: (editor, filter_ext)->
    # console.log "open_file -------"
    try
      editor_file = editor.getPath()
      file_path = path.dirname editor_file
      # ext = path.extname editor_file
      ext_name = path.extname(@uri)?.split "."
      ext_name = ext_name?[1] or ""
      project_path = atom.project.getPaths()[0]

      # 缓存打开过的文件
      if ofname = @pathCache[project_path]?[@uri]
        @do_open([ofname],editor)
        return

      # console.log file_path
      # 判断是否为 emp 文件结构下的文件
      # ---------- start ----------
      cha_path = path.resolve file_path, "../../"
      base_dir = path.basename(file_path).toLowerCase()
      if base_dir is emp.OFF_EXTENSION_XHTML or base_dir is emp.OFF_EXTENSION_HTML
        if @uri.split("/").length > 1
          # console.log "do in o spec"
          tmp_file_path = path.join cha_path, @uri
          # console.log tmp_file_path
          if @exists tmp_file_path
            @do_open([tmp_file_path],editor)
            return
        else
          # console.log "do in o com"
          cha_path = path.resolve cha_path, ".."
          tmp_file_path = path.join cha_path, ext_name.toLowerCase(),@uri
          # console.log tmp_file_path
          if @exists tmp_file_path
            @do_open([tmp_file_path],editor)
            return
      # ---------- end ----------

      # public_dir =  emp.LINK_PUBLICK_DIR
      file_src = []
      public_dir = @get_publick_dir(project_path)

      for i,dir of public_dir
        file_src.unshift path.join(dir, @uri)

      # console.log file_src
      for url in file_src
        if @exists url
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


  resolve_file: (editor, exts) ->
    file_path = path.dirname editor.getPath()
    filename = path.basename(@uri)
    console.log @uri
    console.log exts
    console.log file_path
    filepath = resolve.sync(@uri, basedir:file_path,extensions:exts)
    console.log filepath
    return @do_open([filepath],editor) if fs.statSync filepath

  do_open: (url,editor,back=false)->
    atom.workspace.open url[0]
      .then (tmp_editor)=>
        project_path = atom.project.getPaths()[0]
        console.log url
        tmp_editor.setCursorScreenPosition(url[1]) if url[1]
        @pathCache[project_path] = @pathCache[project_path] or {}
        @pathCache[project_path][@uri] = url[0]
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
    # console.log range
    # console.log editor.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    if range
      text = editor.getTextInBufferRange(range)[1..-2]
    else
      text = editor.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    # console.log text
    text = text[0..-2] if text.slice(-1) is ':'
    text.trim()

  get_text_re: (editor)->
    # editor.getSelectedText() or

    cursor = editor.getCursors()[0]
    range = editor.displayBuffer.bufferRangeForScopeAtPosition '.string.quoted',cursor.getBufferPosition()
    # console.log range
    tag_type = emp.OFF_EXTENSION_CSS
    # range = editor.displayBuffer.bufferRangeForScopeAtPosition( '.string.quoted',cursor.getBufferPosition())
    # console.log editor.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    if range
      text = editor.getTextInBufferRange(range)[1..-2]
      # if text.includes ","
      # console.log text
      tag_type = emp.OFF_EXTENSION_LUA unless !text.includes "("
      text = editor.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    else
      text = editor.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    # console.log text
    text = text[0..-2] if text.slice(-1) is ':'
    # @get_tag_type(editor, text)
    [text.trim(), tag_type]


  getPosition: ->
    activePane = atom.workspace.paneForItem atom.workspace.getActiveTextEditor()
    paneAxis = activePane.getParent()
    paneIndex = paneAxis.getPanes().indexOf(activePane)
    orientation = paneAxis.orientation ? 'horizontal'
    if orientation is 'horizontal'
      if  paneIndex is 0 then 'right' else 'left'
    else
      if  paneIndex is 0 then 'down' else 'top'
#
  # get_tag_type: (editor, tag_text)->
  #   line =  editor.lineTextForBufferRow editor.getCursorBufferPosition().row
  #
  # # ' class="poc_btn_title,poc_btn_right" type="button"
  # # id="more" value="确定" onclick="this.select(1)" />'
  #   process_line(line)
# key=0
# val =1
#
# process_line = (line) ->
#   line = line?.trim()
#
#   if line_head = line?.match /^\<\S*/ig
#     new_line = line
#     re_line = line.split line_head?[0]
#     new_line = re_line[1] unless new_line?.length < 2
#
#     re_obj = {}
#
#     do_process_line(new_line, re_obj, key)
#
# do_process_line = (line_text, re_obj) ->
#   console.log line_text
#   line_text = line_text.trim()
#   # for count, char of line_text
