{$, $$, View} = require 'atom'
path = require 'path'
fs = require 'fs'
os = require 'os'
c_process = require 'child_process'
CollectionView = require './collection-view'
ChannelView = require './channel-view'

conf_parser = require '../emp_app/conf_parser'
parser_beam_file = path.join(__dirname, '../../erl_util/parse_json.beam')
parser_beam_dir = path.join(__dirname, '../../erl_util/')
test_conf = path.join(__dirname, '../../erl_util/channel.conf')
test_conf2 = path.join(__dirname, '../../erl_util/channel0.conf')
OS_DARWIN = 'darwin'
OS_PATH = 'PATH'

COL_KEY = "collections"
CHA_KEY = "channels"
COL_ROOT_TYPE = 1
COL_CH_TYPE = 0
ITEM_CHA_TYPE = 1
ITEM_COL_TYPE = 0

module.exports =
class ChannelListView extends View
  com_state :0
  @content: ->
    # @ol class: 'tree-view full-menu list-tree has-collapsable-children focusable-panel', tabindex: -1, outlet: 'list', =>
    #   @li class: 'directory entry list-nested-item collapsed', =>
    #     @div outlet: 'header', class: 'header list-item', =>
    #       @span class: 'name icon', outlet: 'directoryName', 'Channel List'
    #     @ol class: 'entries list-tree', outlet: 'entries'
    @ul class: 'list-tree has-collapsable-children',outlet:"root_ull", =>
      @li class: 'list-nested-item', outlet:"root_dir",=>
        @div class: 'list-item',  =>
          @span class: 'text-highlight icon icon-file-directory', 'Channel List'
        @ol class: 'entries list-tree', outlet: 'entries'
    #
    #   @li class: 'list-item', =>
    #     @span class: 'icon icon-file-text', '.icon-file-text'
    #   @li class: 'list-item', =>
    #     @span class: 'icon icon-file-symlink-file', '.icon-file-symlink-file'


    # @ul class: 'list-tree', =>
    #   @li class: 'list-nested-item', =>
    #     @div class: 'list-item', =>
    #       @span class: 'icon icon-file-directory', 'A Directory'
    #     @ul class: 'list-tree', =>
    #       @li class: 'list-nested-item', =>
    #         @div class: 'list-item', =>
    #           @span class: 'icon icon-file-directory', 'Nested Directory'
    #         @ul class: 'list-tree', =>
    #           @li class: 'list-item', =>
    #             @span class: 'icon icon-file-text', 'File one'
    #       @li class: 'list-nested-item collapsed', =>
    #         @div class: 'list-item', =>
    #           @span class: 'icon icon-file-directory', 'Collpased Nested Directory'
    #         @ul class: 'list-tree', =>
    #           @li class: 'list-item', =>
    #             @span class: 'icon icon-file-text', 'File one'
    #       @li class: 'list-item', =>
    #         @span class: 'icon icon-file-text', 'File one'
    #       @li class: 'list-item selected', =>
    #         @span class: 'icon icon-file-text', 'File three .selected!'
    #   @li class: 'list-item', =>
    #     @span class: 'icon icon-file-text', '.icon-file-text'
    #   @li class: 'list-item', =>
    #     @span class: 'icon icon-file-symlink-file', '.icon-file-symlink-file'


  initialize: ->
    ex_state = fs.existsSync(parser_beam_file)
    # console.log ex_state
    if !ex_state
      @com_state = conf_parser.initial_parser()
    else
      conf_parser.initial_path()

  refresh_channel_view: ->
    console.log "refresh_channel_view"
    # console.log @root_ul
    parse_conf(this)

  refresh_view: (cha_json)->
    # console.log cha_json
    all_objs = JSON.parse(cha_json)
    # console.log all_objs
    # cha_obj = all_objs[CHA_KEY]
    # col_obj = all_objs[COL_KEY]
    # console.log cha_obj
    # console.log col_obj

    console.log "do refresh "
    # console.log @root_dir
    # console.log @root_ull
    new_all_obj = @parse_params(all_objs)
    # console.log new_all_obj
    root_col = new_all_obj.root
    if root_col isnt {}
      # console.log root_col
      for key, obj of root_col
        col_views = new CollectionView(obj, new_all_obj)
        @entries.append(col_views)

    # col_views = new Collec`tionView(all_objs)
    # @root_dir.append(@create_item()).append(@else_view)

  parse_params: (all_objs)->
    new_obj = {}
    cha_obj = parse_channel_obj(all_objs[CHA_KEY])
    col_obj = parse_channel_obj(all_objs[COL_KEY])
    col_root_obj = {}
    col_ch_obj = {}
    for key, obj of col_obj
      if obj.type is COL_ROOT_TYPE
        # console.log "root col"
        col_root_obj[key] = obj
      else
        col_ch_obj[key] = obj
    new_obj.all = all_objs
    new_obj.cha = cha_obj
    new_obj.col = col_obj
    new_obj.root = col_root_obj
    new_obj.child = col_ch_obj
    new_obj


parse_channel_obj = (obj_list) ->
  if obj_list
    result_obj_list = {}
    for obj in obj_list
      result_obj_list[obj.id] = obj
    result_obj_list
  else
    {}

parse_conf = (callback)->
  # console.log "compile state :#{@com_state}"
  # console.log __dirname
  # var appDir = path.dirname(path.dirname(require.main.filename));
  # parser_ebin_dir
  # console.log __dirname
  ex_state = fs.existsSync(parser_beam_file)
  # console.log ex_state
  # if !ex_state
  #   @com_state = conf_parser.initial_parser()

  channel_conf = test_conf
  t_erl = 'erl -pa '+parser_beam_dir+' -channel_conf '+channel_conf+' -sname testjs -run parse_json parse -noshell -s erlang halt'
  c_process.exec t_erl, (error, stdout, stderr) ->
    if (error instanceof Error)
      console.log error.message
    # tmp_file = path.join(dir, 'tmp_channel_json.json');
    # logger.debug('tmp_file:', tmp_file);
    console.log "compile:#{error}"
    console.log "compile:#{stdout}"
    console.log "compile:#{stderr}"
    console.log "compile erl"
    # console.log JSON.parse(stdout);
    callback.refresh_view(stdout)
