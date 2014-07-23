{WorkspaceView} = require 'atom'
EmpDebugger = require '../lib/emp-debugger'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "EmpDebugger", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('emp-debugger')

  describe "when the emp-debugger:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.emp-debugger')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'emp-debugger:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.emp-debugger')).toExist()
        atom.workspaceView.trigger 'emp-debugger:toggle'
        expect(atom.workspaceView.find('.emp-debugger')).not.toExist()
