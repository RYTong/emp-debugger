fs = require 'fs'
path = require 'path'
_ = require 'underscore-plus'
{Minimatch} = require 'minimatch'

asyncCallsInProgress = 0
pathsChunkSize = 100
paths = []
repo = null
unignoredNames = null
traverseSymlinkDirectories = false
callback = null

isUnIgnored = (loadedPath) ->
  if repo?.isPathIgnored(loadedPath)
    true
  else
    for unignoredName in unignoredNames
      return true if unignoredName.match(loadedPath)

asyncCallStarting = ->
  asyncCallsInProgress++

asyncCallDone = ->
  if --asyncCallsInProgress is 0
    repo?.destroy()
    emit('load-paths:paths-found', paths)
    callback()

pathLoaded = (path) ->
  paths.push(path) unless !isUnIgnored(path)
  if paths.length is pathsChunkSize
    emit('load-paths:paths-found', paths)
    paths = []

loadPath = (path) ->
  asyncCallStarting()
  fs.lstat path, (error, stats) ->
    unless error?
      if stats.isSymbolicLink()
        asyncCallStarting()
        fs.stat path, (error, stats) ->
          unless error?
            if stats.isFile()
              pathLoaded(path)
            else if stats.isDirectory() and traverseSymlinkDirectories
              loadFolder(path) #unless !isUnIgnored(path)
          asyncCallDone()
      else if stats.isDirectory()
        loadFolder(path) #unless !isUnIgnored(path)
      else if stats.isFile()
        pathLoaded(path)
    asyncCallDone()

loadFolder = (folderPath) ->
  asyncCallStarting()
  fs.readdir folderPath, (error, children=[]) ->
    loadPath(path.join(folderPath, childName)) for childName in children
    asyncCallDone()

module.exports = (rootPath, traverseIntoSymlinkDirectories, ignoreVcsIgnores, sAtomVersion, unignores=[]) ->
  traverseSymlinkDirectories = traverseIntoSymlinkDirectories
  unignoredNames = []
  for unignore in unignores when unignore
    try
      unignoredNames.push(new Minimatch(unignore, matchBase: true, dot: true))
    catch error
      console.warn "Error parsing unignore pattern (#{unignore}): #{error.message}"
  callback = @async()
  if sAtomVersion > "1.1.0"
    {GitRepository} = require 'atom'
    repo = GitRepository.open(rootPath, refreshOnWindowFocus: false) if ignoreVcsIgnores
  else
    {Git} = require 'atom'
    repo = Git.open(rootPath, refreshOnWindowFocus: false) if ignoreVcsIgnores

  loadFolder(rootPath)
