{EditorView} = require 'atom'

module.exports =
class EmpEditView extends EditorView
  constructor: (options={}) ->
    # console.log options
    options.mini = true
    # console.log options
    super(options)

  setFontSize: (fontSize) ->
    fontSize = parseInt(fontSize) or 0
    fontSize = Math.min(32, fontSize)
    fontSize = Math.max(10, fontSize)
    super(fontSize)
