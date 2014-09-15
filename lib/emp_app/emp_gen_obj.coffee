
module.exports =
class GenObj
  len:null
  ulen:null
  obj_list:null
  unused:null

  constructor: (obj_list)->
    @len = 0
    @obj_list = {}
    @unused = {}

    for obj in obj_list
      @obj_list[obj.id] = obj
      @unused[obj.id] = obj
      @len += 1

    @ulen = @len


  put: (obj)->
    @obj_list[obj.id] = obj

  get: (id) ->
    @obj_list[id]

  use: (id) ->
    re = @obj_list[id]

    unless !re
      @set_used(id)
    re

  set_used: (id) ->
    unless !@unused[id]
      delete @unused[id]
      @ulen -= 1


  get_all: ->
    @obj_list

  get_unused: () ->
    @unused
