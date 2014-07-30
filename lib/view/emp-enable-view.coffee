{$, $$, View, SelectListView, EditorView} = require 'atom'

module.exports =
class EnableView extends SelectListView
  emp_socket_server: null

  @content: ->
    console.log 'constructor'
    @div class: 'select-list', outlet: 'emp_enable_div', =>
      @subview 'filterEditorView', new EditorView(mini: true)
      @div class: 'error-message', outlet: 'error'
      @div class: 'loading', outlet: 'loadingArea', =>
        @span class: 'loading-message', outlet: 'loading'
        @span class: 'badge', outlet: 'loadingBadge'
      @ol class: 'list-group', outlet: 'list'

    # @div class: "emp-debugger bordered", =>
    #   @div outlet:'fa_div', class: "panel-heading", 'Service Config Dialog'
    #   @div class: "emp-div-content", =>
    #     @label class: "emp-conf-label", "Server State   :"
    #     @label outlet:"label_server_st", class: "emp-label-content", "------"
    #   @div class: "emp-div-content", =>
    #     @label class: "emp-conf-label", "Client Number:"
    #     @label outlet:"label_cl_no", class: "emp-label-content", ""
    #
    #   @div class: 'emp-btn-div', =>
    #     @button class: 'btn inline-block emp-btn-cancel', click: 'process_cancel', "Cancel"
    #     @button class: 'btn inline-block emp-btn-ok', click: 'process_stop', "Stop"


  # Public: Initialize the select list view.
  #
  # This method can be overridden by subclasses but `super` should always
  # be called.
  initialize: ->
    @filterEditorView.getEditor().getBuffer().on 'changed', =>
      @schedulePopulateList()

    @filterEditorView.on 'focus', =>
      console.log "focusout~~~~~~"

    @filterEditorView.hiddenInput.on 'focusout', =>
      console.log "focusout~~~~~~"

      @cancel() unless @cancelling

    # This prevents the focusout event from firing on the filter editor view
    # when the list is scrolled by clicking the scrollbar and dragging.

    @list.on 'mousedown', ({target}) =>
      console.log "mousedown"
      false if target is @list[0]

    @on 'core:move-up', =>
      console.log "up"
      @selectPreviousItemView()
    @on 'core:move-down', =>
      console.log "down"
      @selectNextItemView()
    @on 'core:move-to-top', =>
      @selectItemView(@list.find('li:first'))
      @list.scrollToTop()
      false
    @on 'core:move-to-bottom', =>
      @selectItemView(@list.find('li:last'))
      @list.scrollToBottom()
      false

    @on 'core:confirm', => @confirmSelection()
    @on 'core:cancel', => @cancel()

    @list.on 'focus', =>
      console.log "focus[[[]]]"

    @list.on 'mousedown', 'li', (e) =>
      console.log "mousedown li"
      @selectItemView($(e.target).closest('li'))
      e.preventDefault()

    @list.on 'mouseup', 'li', (e) =>
      console.log "mouseup li"
      @confirmSelection() if $(e.target).closest('li').hasClass('selected')
      e.preventDefault()

    @emp_enable_div.on 'focus', =>
      console.log "focus focus focus focus"

    @addClass('emp-debugger from-top')
    @setMaxItems(10)

    atom.workspaceView.command "emp-debugger:enable_view", => @enable_view()
    @focusFilterEditor()
    @subscribe $(this), 'focusout', =>
      console.log "======focusout~~"

  # initialize: (serializeState, @emp_socket_server) ->
  #   console.log 'enable view process initial'
  #   super
  #   @addClass('emp-debugger from-top')
  #   @setMaxItems(10)
  #
  #   atom.workspaceView.command "emp-debugger:enable_view", => @enable_view()
  #   @focusFilterEditor()
  #   @subscribe $(window), 'focus', =>
  #     console.log "focus~~"


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  # destroy: ->
  #   @detach()
  destroy: ->
    @cancel()
    @remove()

  enable_view: ->
    console.log "this is state"

    if @hasParent()
      @detach()
    else
      @setItems(["t1", "t2"])
      @storeFocusedElement
      atom.workspaceView.append(this)
      # @emp_enable_div.on 'focus', =>
      #   console.log "div f2"
      @on 'focus', 'div', ->
        console.log "div ffffffff;;;;"
        # console.log "state view~"
        # console.log @label_server_st
        # console.log @label_cl_no
        #
        # @label_server_st["context"].innerHTML="On"
        # # @label_server_st.setDocument("test")
        # @label_cl_no["context"].innerHTML=@emp_socket_server.get_socket_length()


  process_cancel: (event, element) ->
    # console.log element
    console.log "Cancel State Preparing #{element.name} for launch!"
    @detach()

  process_stop: (event, element) ->
    console.log element
    @emp_socket_server.close()
    @detach()

  viewForItem: (item) ->
    "<li>#{item}</li>"

  confirmed: (item) ->
    console.log("#{item} was selected")

  confirmSelection: ->
    console.log "selections~"
    item = @getSelectedItem()
    if item?
      @confirmed(item)
    else
      @cancel()

  cancelled: ->
    @filterEditorView.getEditor().setText('')
    @filterEditorView.updateDisplay()
