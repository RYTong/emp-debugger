{$, $$, ScrollView} = require 'atom'
path = require 'path'
fs = require 'fs'
c_process = require 'child_process'
CollectionView = require './item_view/collection-view'
ChannelView = require './item_view/channel-view'
emp = require '../exports/emp'
conf_parser = require '../emp_app/conf_parser'
GenObj = require '../emp_app/emp_gen_obj'

parser_beam_file = path.join(__dirname, '../../erl_util/atom_pl_parse_json.beam')
parser_beam_file_ne = path.join(__dirname, '../../erl_util/atom_pl_parse_json')

parser_beam_dir = path.join(__dirname, '../../erl_util/')
test_conf = path.join(__dirname, '../../erl_util/channel.conf')
test_conf1 = path.join(__dirname, '../../erl_util/channel0.conf')
tmp_json_dir = 'tmp/'
tmp_json_file = 'atom_channel_json.json'
befor_select = null
cha_conf_dir = null

fa_view = null

module.exports =
class ChannelListView extends ScrollView

  unused_cha_map:{}
  unused_col_map:{}

  @content: ->

    @ul class: 'emp_cha_list panels-list list-tree has-collapsable-children', =>
      @li class: 'list-nested-item', outlet:"emp_root_dir", =>
        @div class: 'root_header list-item',click:'root_clicked', =>
          @span class: 'text-highlight icon icon-file-directory', 'Channel List'
        @ol class: 'entries list-tree', outlet: 'entries'
      @li class: 'list-nested-item', outlet:"un_col",style:"display:none;",=>
        @div class: 'root_header list-item',click:'root_clicked',  =>
          @span class: 'text-highlight icon icon-file-directory', 'Unused Collection (Child)'
        @ol class: 'entries list-tree', outlet: 'col_entries'
      @li class: 'list-nested-item', outlet:"unused_cha", style:"display:none;",=>
        @div class: 'root_header list-item',click:'root_clicked',  =>
          @span class: 'text-highlight icon icon-file-directory', 'Unused Channel'
        @ol class: 'entries list-tree', outlet: 'cha_entries'


  initialize: (initial_fa)->
    super
    @unused_cha_map = {}
    @unused_col_map = {}
    fa_view = initial_fa

    # cha_conf_dir = atom.config.get(ATOM_CONF_CHANNEL_DIR_KEY)

    unless atom.config.get(emp.ATOM_CONF_CHANNEL_DIR_KEY)
      atom.config.set(emp.ATOM_CONF_CHANNEL_DIR_KEY, emp.ATOM_CONF_CHANNEL_DIR_DEFAULT)
      # emp.ATOM_CONF_CHANNEL_DIR_DEFAULT
    # ATOM_CONF_CHANNEL_DIR_DEFAULT

    # @on 'click', '.root_header', (e) =>
    #   console.log "root   header ----"
    #   @rootentryClicked(e)

    @on 'click', '.header', (e) =>
      @entryClicked(e)
    # @root_dir.command 'emp-debugger:copy', => @copySelectedEntries()
    @fex_state = fs.existsSync(parser_beam_file)
    # console.log @fex_state
    if !@fex_state
      conf_parser.initial_parser(fa_view)
    else
      conf_parser.initial_path()

  refresh_edit_cha:(tmp_obj, all_objs) ->
    # console.log "refresh list"
    @refresh_view_obj(all_objs)

  refresh_edit_col:(tmp_obj, all_objs) ->
    # console.log "refresh list"
    @refresh_view_obj(all_objs)


  refresh_cha_panel_re: (tmp_id_list, new_all_objs) ->
    # for tmp_id in tmp_id_list
    #   tmp_view = @unused_cha_map[tmp_id]
    #   if tmp_view
    #     tmp_view.destroy()
    #     delete @unused_cha_map[tmp_id]
    @refresh_view_obj(new_all_objs)


  refresh_col_panel_re: (tmp_id_list, new_all_objs) ->
    # for tmp_id, tmp_type of tmp_id_list
    #   tmp_view = @unused_col_map[tmp_id]
    #   if tmp_view
    #     if tmp_view.col_type is tmp_type
    #       tmp_view.destroy()
    #       delete @unused_col_map[tmp_id]
    @refresh_view_obj(new_all_objs)

  refresh_add_col: (add_col_obj, tmp_all_objs)->
    # 不会被设为已用的标示
    add_col_obj.unsed_flag = true
    tmp_col_views = new CollectionView(add_col_obj, tmp_all_objs)
    # console.log @unused_cha.isVisible()
    if @un_col.isHidden()
      @un_col.show()
    @col_entries.append(tmp_col_views)
    @unused_col_map[add_col_obj.id] = tmp_col_views

  refresh_cha_panel: (add_cha_obj, tmp_all_objs)->
    tmp_cha_views = new ChannelView(add_cha_obj)
    # console.log @unused_cha.isVisible()
    if @unused_cha.isHidden()
      @unused_cha.show()
    @cha_entries.append(tmp_cha_views)
    @unused_cha_map[add_cha_obj.id] = tmp_cha_views


  copySelectedEntries: ->
    console.log "copySelectedEntries~~~~~~~~~~"

  refresh_channel_view: ->
    # console.log "refresh_channel_view"
    parse_conf(this)

  refresh_view: (cha_json)->
    # console.log cha_json
    all_objs = JSON.parse(cha_json)
    # console.log "do refresh "
    new_all_obj = @parse_params(all_objs)
    root_col = new_all_obj.root
    @entries.empty()
    if root_col isnt {}

      for key, obj of root_col
        col_views = new CollectionView(obj, new_all_obj)
        @entries.append(col_views)
      # console.log new_all_obj
      @add_unused_list(new_all_obj)

    fa_view.refresh_view(new_all_obj)

  refresh_view_obj: (new_all_obj)->
    # console.log "do refresh ----"
    root_col = new_all_obj.root
    @entries.empty()
    if root_col isnt {}
      for key, obj of root_col
        col_views = new CollectionView(obj, new_all_obj)
        @entries.append(col_views)
      @add_unused_list(new_all_obj)
    # fa_view.refresh_view(new_all_obj)

  add_unused_list: (all_obj)->
    @add_unused_col(all_obj)
    @add_unused_cha(all_obj)

  add_unused_col: (all_obj) ->
    # console.log "add unused collections"
    # console.log all_obj
    col_child = all_obj.child
    ulen = col_child.ulen
    @col_entries.empty()
    # console.log ulen
    # console.log col_child
    if ulen isnt 0
      ucol_child = col_child.get_unused()
      # console.log ucol_child
      @un_col.show()
      for key, obj of ucol_child
        obj.unsed_flag = true
        col_views = new CollectionView(obj, all_obj)
        @col_entries.append(col_views)
        @unused_col_map[obj.id] = col_views

  add_unused_cha: (all_obj) ->
    # console.log "add unused channel"
    cha = all_obj.cha
    ulen = cha.ulen
    @cha_entries.empty()
    if ulen isnt 0
      ucha = cha.get_unused()
      @unused_cha.show()
      for key, obj of ucha
        cha_views = new ChannelView(obj, all_obj)
        @cha_entries.append(cha_views)
        @unused_cha_map[obj.id] = cha_views

  parse_params: (all_objs)->
    new_obj = {}
    cha_obj = new GenObj(all_objs[emp.CHA_KEY])
    col_obj = parse_col_obj(all_objs[emp.COL_KEY])
    col_root_obj = {}
    col_ch_obj = []
    for key, obj of col_obj
      if obj.type is emp.COL_ROOT_TYPE
        # console.log "root col"
        col_root_obj[key] = obj
      else
        col_ch_obj.push(obj)
    # new_obj.all = all_obj
    new_obj.cha = cha_obj
    new_obj.col = col_obj
    new_obj.root = col_root_obj
    new_obj.child = new GenObj(col_ch_obj)
    new_obj

  # callback for root list element
  root_clicked: (e, element) ->
    # console.log "root click"
    ele_parement = element.parent()
    if ele_parement.hasClass('collapsed')
      ele_parement.removeClass('collapsed').addClass('expanded')
    else
      ele_parement.removeClass('expanded').addClass('collapsed')

  # callback for child list element
  entryClicked: (e) ->
    entry = $(e.currentTarget).view()
    # console.log entry
    isRecursive = e.altKey || false
    entry.toggleExpansion(isRecursive)
    unless befor_select is entry
      @deselect()
    befor_select = entry

  deselect: ->
    unless !befor_select
      befor_select.deselect()

parse_col_obj = (obj_list) ->
  if obj_list
    result_obj_list = {}
    for obj in obj_list
      result_obj_list[obj.id] = obj
    result_obj_list
  else
    {}

parse_conf = (callback)->
  ex_state = fs.existsSync(parser_beam_file)
  # console.log parser_beam_file
  # console.log atom.project.emp_app_state
  # console.log atom.project.emp_app_pid
  # channel_conf = test_conf
  cha_conf_dir = atom.config.get(emp.ATOM_CONF_CHANNEL_DIR_KEY)
  project_path = atom.project.getPath()
  channel_conf = path.join project_path, cha_conf_dir
  atom.project.channel_conf = channel_conf
  atom.project.parse_beam_dir = parser_beam_dir

  if atom.project.emp_app_state
    result_json_dir = path.join project_path,tmp_json_dir
    emp.mkdir_sync(result_json_dir)
    result_json_file = path.join result_json_dir,tmp_json_file

    erl_str = "f(), Fun = fun(Mod, Conf) ->
                     case code:is_loaded(#{emp.parser_beam_file_mod}) of \n
                       false ->code:load_abs(Mod);
                       _ -> go_on
                     end,
                     #{emp.parser_beam_file_mod}:parse(Conf, \"#{result_json_file}\")
                     end,
                     Fun(\"#{parser_beam_file_ne}\", \"#{channel_conf}\")."

    re_flag = true
    tmp_fs_watcher = fs.watch result_json_dir, {persistent: true, interval: 5000}, (event, filename) ->
      # console.log('event is: ' + event)
      if (filename)
        if filename is tmp_json_file
          if fs.existsSync(result_json_file)
            channel_json = fs.readFileSync(result_json_file, 'utf8')
            callback.refresh_view(channel_json)
          else
            emp.show_error("解析channel.conf 失败，请查看日志")
          # console.log('filename provided: ' + filename)
          tmp_fs_watcher.close()
    tmp_pid = atom.project.emp_app_pid
    tmp_pid.stdin.write(erl_str+'\r\n')
  else if atom.project.emp_node_state
    result_json_dir = path.join project_path,tmp_json_dir
    emp.mkdir_sync(result_json_dir)
    result_json_file = path.join result_json_dir,tmp_json_file
    erl_str = "#{emp.parser_beam_file_mod}:parse(\"#{channel_conf}\", \"#{result_json_file}\")."
    re_flag = true
    tmp_fs_watcher = fs.watch result_json_dir, {persistent: true, interval: 5000}, (event, filename) ->
      # console.log('event is: ' + event)
      if (filename)
        if filename is tmp_json_file
          if fs.existsSync(result_json_file)
            channel_json = fs.readFileSync(result_json_file, 'utf8')
            callback.refresh_view(channel_json)
          else
            emp.show_error("解析channel.conf 失败，请查看日志")

          # console.log('filename provided: ' + filename)
          tmp_fs_watcher.close()
      #   console.log('filename not ·')
    tmp_pid = atom.project.emp_node_pid
    tmp_pid.stdin.write(erl_str+'\r\n')
  else
    t_erl = 'erl -pa '+parser_beam_dir+' -channel_conf '+channel_conf+' -sname testjs -run atom_pl_parse_json parse -noshell -s erlang halt'
    c_process.exec t_erl, (error, stdout, stderr) ->
      # console.log error
      if (error instanceof Error)
        console.error error.message
        emp.show_error(stderr)
      # console.log "compile:#{stdout}"
      else if stderr
        console.error "compile:#{stderr}"
        emp.show_error(stderr)
      else
        callback.refresh_view(stdout)
