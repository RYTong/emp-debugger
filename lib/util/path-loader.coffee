{$, $$, Task} = require 'atom'
emp = require '../exports/emp'
path = require 'path'
taskPath = require.resolve('./load-paths-handler')
fuzzyFilter = require('fuzzaldrin').filter


module.exports.load_path = (dir, tmp_file, tmp_ignore_name, callback) ->
  tmp_file ?= "m1.xhtml"
  dir ?= "public/www/resource_dev"
  tmp_ignore_name ?= ["*.json", "*.lua", "*.png", "*.jpg", "*.css"]
  console.log "this is load_path"

  # atom.project.scan new RegExp(tmp_file), {paths:[dir]}, (result) ->
  #   console.log result

  projectPaths = []
  ignoredNames = atom.config.get('fuzzy-finder.ignoredNames') ? []
  ignoredNames = ignoredNames.concat(atom.config.get('core.ignoredNames') ? [])
  ignoredNames = ignoredNames.concat(tmp_ignore_name)
  pro_dir = atom.project.getPaths()[0]

  fuzzyFilter = require('fuzzaldrin').filter
  task = Task.once taskPath, path.join(pro_dir, dir), false, true, ignoredNames, ->
    # callback(projectPaths)
    new_path = []
    for tmp_pa in projectPaths
      tmp_pa_name = path.basename(tmp_pa)
      new_path.push({name:tmp_pa_name, dir:tmp_pa})

    # console.log new_path
    callback(fuzzyFilter(new_path, tmp_file, key:'name'))

  task.on 'load-paths:paths-found', (paths) ->
    projectPaths.push(paths...)

  task


module.exports.load_all_path = (dir, tmp_ignore_name, callback) ->
  # console.log "this is load all path"
  dir ?= "public/www/resource_dev"
  tmp_ignore_name ?= ["*.json", "*.lua", "*.png", "*.jpg", "*.css"]

  projectPaths = []
  ignoredNames = atom.config.get('fuzzy-finder.ignoredNames') ? []
  ignoredNames = ignoredNames.concat(atom.config.get('core.ignoredNames') ? [])
  ignoredNames = ignoredNames.concat(tmp_ignore_name)
  pro_dir = atom.project.getPaths()[0]

  task = Task.once taskPath, path.join(pro_dir, dir), false, true, ignoredNames, ->
    new_path = []
    for tmp_pa in projectPaths
      tmp_pa_name = path.basename(tmp_pa)
      new_path.push({name:tmp_pa_name, dir:tmp_pa})
    callback(new_path)

  task.on 'load-paths:paths-found', (paths) ->
    projectPaths.push(paths...)
  task

module.exports.filter_path = (path_arr, file_name) ->
  fuzzyFilter(path_arr, file_name, key:'name')
