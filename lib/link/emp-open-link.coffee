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
    @path_list = []
    @erl_path_list = []
    @deps_erl_path = []
    if atom.project.getPaths().length isnt 0
      path_fliter.load_all_path_unignore "", (@path_list) =>
        # console.log @path_list
      path_fliter.load_file_path_unignore "./", ["*.erl", "*.hrl"], (@erl_path_list) =>
        # console.log @erl_path_list
      @refresh_dependences_path()

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
      # console.log @path_list
    path_fliter.load_file_path_unignore "./", ["*.erl", "*.hrl"], (@erl_path_list) =>
      # console.log @erl_path_list
    @refresh_dependences_path()
    emp.show_info "刷新 link 路径成功!"

  forward: ->
    editor = atom.workspace.getActiveTextEditor()
    @uri = editor.getSelectedText() or @get_text(editor)
    # console.log @uri
    return atom.workspace.open @uri unless !@check_http()

    text_ext = @get_ext(editor)
    # console.log text_ext
    if text_ext is "erl" or text_ext is "hrl"
      # console.log "do forward erl"
      @do_forward_erl(editor)

    else
      @do_forward(editor)



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


  do_forward: (editor)->
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

  filter_file: (editor)->
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
    # console.log @uri
    # console.log exts
    # console.log file_path
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

  get_text_erl:(editor)->
    # editor.getSelectedText() or
    erl_mod = undefined
    cursor = editor.getCursors()[0]
    range = editor.displayBuffer.bufferRangeForScopeAtPosition '.string.quoted',cursor.getBufferPosition()
    # console.log range
    if range
      text = editor.getTextInBufferRange(range)[1..-2]
      # if text.includes ","
      # console.log text
      # tag_type = emp.OFF_EXTENSION_LUA unless !text.includes "export"
      text = editor.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
    else
      # console.log "------------------------"
      text = editor.getWordUnderCursor wordRegex:/[\/A-Z\.\-\d\\-_:]+(:\d+)?/i
      if text.match /\//ig
        text = text.split(/\//ig)?[0]
      else
        if text.match /:/ig
          result = text.split ":"
          erl_mod = result?[0]
          text = result?[1]

    #   console.log "------------------------"
    # console.log text
    # text = text[0..-2] if text.slice(-1) is ':'
    # @get_tag_type(editor, text)
    [text.trim(), erl_mod]

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

  get_ext: (tmp_editor)->
    editor_file = tmp_editor.getPath()
    file_path = path.basename editor_file
    # ext = path.extname editor_file
    # console.log file_path
    ext_name = path.extname(file_path)?.split "."
    ext_name = ext_name?[1] or ""
    return ext_name

# --------------------------- for erl ----------------------------

  do_forward_erl: (tmp_editor) ->
    # console.log "do_forward_erl"
    line =  tmp_editor.lineTextForBufferRow tmp_editor.getCursorBufferPosition().row
    # 跳转到 include 的头文件
    if line.includes 'include'
      return @filter_all_file(tmp_editor, ['.hrl'])

    [@uri, erl_mod] = @get_text_erl(tmp_editor)
    # 判断 erlang 函数是 mod:fun 还是 fun

    if erl_mod
      @open_erl_mod(tmp_editor, erl_mod)
    else
      expression = "\n[^%]*"+ _.escapeRegExp(@uri)+"[^\.]*\-\>"
      regex = new RegExp(expression, 'ig')
      # console.log regex
      project_path = atom.project.getPaths()[0]
      newMarkers = []
      tmp_editor.scanInBufferRange regex, Range(Point.ZERO, Point.INFINITY), ({range}) =>
        range.start.row = range.start.row+1
        newMarkers.push(@createMarker(range, tmp_editor))
      if newMarkers.length > 0
        new_marker = newMarkers[0]
        ranges = new_marker.getBufferRange()
        tmp_editor.setCursorBufferPosition ranges.start

  filter_all_file: (editor)->
    # try
    editor_file = editor.getPath()
    file_path = path.dirname editor_file
    ext_name = path.extname(@uri)?.split "."
    ext_name = ext_name?[1] or ""
    project_path = atom.project.getPaths()[0]

    # 缓存打开过的文件
    if ofname = @pathCache[project_path]?[@uri]
      @do_open([ofname],editor)
      return

    file_src = []
    file_name = path.basename(@uri)
    console.log file_name
    console.log @erl_path_list
    if !@erl_path_list? or @erl_path_list?.length < 1
      @refresh_erl_path(file_name, project_path, true)
    else
      # console.log @erl_path_list
      filter_result = path_fliter.filter_path(@erl_path_list, file_name)
      if filter_result.length is 1
        @do_open([filter_result[0].dir],editor)
      else
        new EnableView filter_result, (sel_file) =>
          @do_open([sel_file],editor)
      # console.log 'erls -----------'

  open_erl_mod: (editor, erl_mod)->
    # console.log "open erl mod -------"
    project_path = atom.project.getPaths()[0]
    erl_mod_file = erl_mod+".erl"
    # 缓存打开过的文件
    if ofname = @pathCache[project_path]?[erl_mod_file]
      @do_open_erl(ofname, project_path)
      return

    file_src = []
    # file_name = path.basename(erl_mod)
    # @complex = true
    # console.log @erl_path_list
    if !@erl_path_list? or @erl_path_list?.length < 1
      @refresh_erl_path(erl_mod_file, project_path)
    else
      # console.log @erl_path_list
      filter_result = path_fliter.filter_path(@erl_path_list, erl_mod_file)
      if filter_result.length is 1
        @do_open_erl(filter_result[0].dir, project_path)
      else if filter_result.length > 0
        new EnableView filter_result, (sel_file) =>
          @do_open_erl(sel_file, project_path)
      else
        console.log "dep --------"
        # console.log @deps_erl_path
        if !@deps_erl_path or @deps_erl_path?.length < 1
          @refresh_dependences_path()
        dep_filter_result = path_fliter.filter_path(@deps_erl_path, erl_mod_file)
        if dep_filter_result.length is 1

          @do_open_erl(dep_filter_result[0].dir, project_path)
        else
          new EnableView dep_filter_result, (sel_file) =>
            @do_open_erl(sel_file, project_path)

  do_open_erl: (erl_mod_file, project_path, is_inclue)->
    # console.log "--------do_open_erl--------"
    # console.log erl_mod_file
    atom.workspace.open erl_mod_file
      .then (tmp_editor)=>
        # console.log @uri
        @pathCache[project_path] = @pathCache[project_path] or {}
        @pathCache[project_path][@uri] = erl_mod_file
        if !is_inclue
          expression = "\n[^%]*"+_.escapeRegExp(@uri)+"[^\.]*\-\>"
          regex = new RegExp(expression, 'ig')
          project_path = atom.project.getPaths()[0]
          newMarkers = []
          tmp_editor.scanInBufferRange regex, Range(Point.ZERO, Point.INFINITY), ({range}) =>
            range.start.row = range.start.row+1
            newMarkers.push(@createMarker(range, tmp_editor))
          if newMarkers.length > 0
            new_marker = newMarkers[0]
            ranges = new_marker.getBufferRange()
            tmp_editor.setCursorBufferPosition ranges.start

  # 如果没有查询路径, 则刷新当前路径,并查找
  refresh_erl_path: (file_name, project_path, flag)->
    path_fliter.load_file_path_unignore project_path, ["*.erl", "*.hrl"], (@erl_path_list) =>
      filter_result = path_fliter.filter_path(@erl_path_list, file_name)
      if filter_result.length is 1
        @do_open_erl(filter_result[0].dir, project_path, flag)
      else
        new EnableView filter_result, (sel_file) =>
          @do_open_erl(sel_file, project_path, flag)

  # 若当前路径没有,则刷新 erl, ewp, yaws 的路径
  refresh_dependences_path: ->
    @deps_erl_path = []
    if filter_erl_path = atom.config.get(emp.EMP_ERL_SOURCE_PATH)
      # console.log filter_erl_path+"------------------"
      path_fliter.load_file_path_unignore filter_erl_path, ["*.erl", "*.hrl"], (dep_erl_path) =>
        # console.log dep_erl_path
        @deps_erl_path = @deps_erl_path.concat dep_erl_path

    if filter_ewp_path = atom.config.get(emp.EMP_EWP_SOURE_PATH)
      # console.log filter_ewp_path+"------------------"
      path_fliter.load_file_path_unignore filter_ewp_path, ["*.erl", "*.hrl"], (dep_ewp_path) =>
        # console.log dep_ewp_path
        @deps_erl_path = @deps_erl_path.concat dep_ewp_path

    if filter_yaws_path = atom.config.get(emp.EMP_YAWS_SOURCE_PATH)
      # console.log filter_yaws_path+"------------------"
      path_fliter.load_file_path_unignore filter_yaws_path, ["*.erl", "*.hrl"], (dep_yaws_path) =>
        # console.log dep_yaws_path
        @deps_erl_path = @deps_erl_path.concat dep_yaws_path


      # atom.workspace.open erl_mod
      #   .then (tmp_editor)=>
      #     # console.log "----------------"
      #     # console.log @uri
      #     expression = _.escapeRegExp(@uri)+"[^\.]*\-\>"
      #     regex = new RegExp(expression, 'ig')
      #     project_path = atom.project.getPaths()[0]
      #     newMarkers = []
      #     tmp_editor.scanInBufferRange regex, Range(Point.ZERO, Point.INFINITY), ({range}) =>
      #       # new_marker = @createMarker(range, tmp_editor)
      #       newMarkers.push(@createMarker(range, tmp_editor))
      #     # console.log newMarkers
      #     if newMarkers.length > 0
      #       console.log newMarkers
      #       new_marker = newMarkers[0]
      #       ranges = new_marker.getBufferRange()
      #       # console.log ranges
      #       tmp_editor.setCursorBufferPosition ranges.start

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
