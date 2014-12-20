 # BERT-JS
 # Copyright (c) 2009 Rusty Klophaus (@rklophaus)
 # Contributions by Ben Browning (@bbrowning)
 # See MIT-LICENSE for licensing information.
 #
 #
 # BERT-JS is a Javascript implementation of Binary Erlang Term Serialization.
 # - http://github.com/rklophaus/BERT-JS
 #
 # References:
 # - http://www.erlang-factory.com/upload/presentations/36/tom_preston_werner_erlectricity.pdf
 # - http://www.erlang.org/doc/apps/erts/erl_ext_dist.html#8
 #
 #
 # - CLASSES -
# Buffer = require 'Buffer'

module.exports =
class BertClass
  BERT_START:String.fromCharCode(131)
  SMALL_ATOM:String.fromCharCode(115)
  ATOM:String.fromCharCode(100)
  BINARY:String.fromCharCode(109)
  SMALL_INTEGER:String.fromCharCode(97)
  INTEGER:String.fromCharCode(98)
  SMALL_BIG:String.fromCharCode(110)
  LARGE_BIG:String.fromCharCode(111)
  FLOAT:String.fromCharCode(99)
  STRING:String.fromCharCode(107)
  LIST:String.fromCharCode(108)
  SMALL_TUPLE:String.fromCharCode(104)
  LARGE_TUPLE:String.fromCharCode(105)
  NIL:String.fromCharCode(106)
  ZERO:String.fromCharCode(0)
  BERT_START_C:131
  SMALL_ATOM_C:115
  ATOM_C:100
  BINARY_C:109
  SMALL_INTEGER_C:97
  INTEGER_C:98
  SMALL_BIG_C:110
  LARGE_BIG_C:111
  FLOAT_C:99
  STRING_C:107
  LIST_C:108
  SMALL_TUPLE_C:104
  LARGE_TUPLE_C:105
  NIL_C:106
  ZERO_C:0

  constructor: ->
    # console.log "initial "
    this

  encode: (obj) ->
    re = @encode_inner(obj)
    # console.log re
    if Buffer.isBuffer re
      re_buf = new Buffer(re.length+1)
      re.copy re_buf,1
      re_buf[0] = @BERT_START_C
      # console.log re_buf
      re_buf
    else
      @BERT_START+re

  # decode: (obj) ->
  #   unless obj[0] is @BERT_START
  #     throw "invalid bert"
  #
  #   new_obj = @decode_inner obj.substring(1)
  #
  #   unless new_obj.rest is ""
  #     throw "invalid bert"
  #
  #   new_obj.value

  encode_inner: (obj) ->
    if obj
      func = 'encode_' + typeof(obj)
      # console.log func
      this[func](obj)
    else
      throw new Error("Cannot encode undefined values.")

  encode_string: (obj) ->
    buf = new Buffer(obj)
    re_buf = new Buffer(buf.length+3)
    len = @int_to_bytes(obj.length, 2)
    buf.copy re_buf,3
    for index in [0..len.length-1]
      re_buf[index+1]=len[index].charCodeAt 0
    re_buf[0]=@STRING_C
    re_buf

  encode_boolen: (obj) ->
    if obj
      @encode_inner @atom("true")
    else
      @encode_inner @atom("false")

  encode_number: (obj) ->
    s=isInteger= (obj%1 is 0)
    unless isInteger
      return @encode_float(obj)

    unless !(isInteger && obj >= 0 && obj < 256)
      re_buf = new Buffer(2)
      re_buf[0]=@SMALL_INTEGER_C
      re_buf[1]=@int_to_bytes(obj,1)[0].charCodeAt 0
      re_buf

    unless !(isInteger && obj >= -134217728 && obj <= 134217727)
      re_buf = new Buffer(5)
      re_buf[0]=@INTEGER_C
      len=@int_to_bytes obj,4
      for index in [0..len.length-1]
        re_buf[index+1]=len[index].charCodeAt 0
      re_buf
    s = @bignum_to_bytes(obj)
    buf = new Buffer(s)
    len = 0
    head = 0
    if s.length < 256
      # return @SMALL_BIG+@int_to_bytes(s.length - 1, 1) + s
      len = @int_to_bytes(s.length-1, 1)
      head=@SMALL_BIG_C
    else
      len = @int_to_bytes(s.length-1, 4)
      head=@LARGE_BIG_C
    start_index = 1+len.length
    re_buf = new Buffer(buf.length+start_index)
    buf.copy re_buf,start_index
    re_buf[0]=head
    for index in [0..len.length-1]
      re_buf[index+1]=len[index].charCodeAt 0
    re_buf
      # return @LARGE_BIG +@int_to_bytes(s.length - 1, 4) + s

  encode_float: (obj) ->
    tmp_val=obj.toExponential();
    while tmp_val.length <31
      tmp_val+=@ZERO
    # @FLOAT+s
    buf = new Buffer(tmp_val)
    re_buf = new Buffer(buf.length+1)
    buf.copy re_buf,1
    re_buf[0]=@FLOAT_C
    re_buf

  encode_object: (obj) ->
    # console.log obj
    unless obj
      return @encode_inner @atom("null")

    unless obj.type isnt "Atom"
      return @encode_atom obj

    unless obj.type isnt "Binary"
      return @encode_binary obj

    unless obj.type isnt "Tuple"
      return @encode_tuple obj

    unless obj.constructor.toString().indexOf("Array") is -1
      return @encode_array obj

    @encode_associative_array obj

  encode_atom: (obj) ->
    buf = new Buffer(obj.value)
    re_buf = new Buffer(obj.value.length+3)
    len = @int_to_bytes(obj.value.length, 2)
    buf.copy re_buf,3
    for index in [0..len.length-1]
      re_buf[index+1]=len[index].charCodeAt 0
    re_buf[0]=@ATOM_C
    re_buf

  encode_binary: (obj) ->
    # console.log "encode_binary"
    # console.log obj
    re_buf = new Buffer(obj.value.length+5)
    if Buffer.isBuffer obj.value
      obj.value.copy re_buf,5
    else
      buf = new Buffer obj.value
      buf.copy re_buf,5

    re_buf[0] = @BINARY_C
    len = @int_to_bytes(obj.value.length, 4)
    for index in [0..3]
      re_buf[index+1]=len[index].charCodeAt 0
    # console.log re_buf
    # @BINARY+@int_to_bytes(obj.value.length, 4)+obj.value
    re_buf


  encode_tuple: (obj) ->
    # console.log "encode_tuple"
    s=""
    re_arr=[]
    head=""
    len=""
    if obj.length < 256
      head = @SMALL_TUPLE_C
      len=@int_to_bytes obj.length, 1
      # s+=@SMALL_TUPLE+@int_to_bytes obj.length, 1
    else
      head = @LARGE_TUPLE_C
      len=@int_to_bytes obj.length, 4
      # s+=@LARGE_TUPLE+@int_to_bytes obj.length, 4
    for i in [0..obj.length-1]
      tmp_re = @encode_inner obj[i]
      # console.log tmp_re
      # re_arr.push @encode_inner obj[i]
      re_arr.push tmp_re

    all_len = 0
    for tmp_ele in re_arr
      # console.log tmp_ele
      all_len+=tmp_ele.length

    start_index = 1+len.length
    re_buf = new Buffer(all_len+start_index)
    for tmp_ele in re_arr
      all_len+=tmp_ele.length
      tmp_ele.copy re_buf,start_index
      start_index+=tmp_ele.length

    for index in [0..len.length-1]
      re_buf[index+1]=len[index].charCodeAt 0
    re_buf[0]=head
    # console.log "-----------"
    # console.log re_buf
    re_buf

    # re_buf = new Buffer(obj.value.length+5)

  encode_array: (obj) ->
    # console.log "encode array"
    unless obj.length isnt 0
      return new Buffer(@NIL)
    # s=@LIST+@int_to_bytes obj.length, 4
    len = @int_to_bytes obj.length, 4
    buf = new Buffer(5)
    buf[0]=@LIST_C
    for index in [0..len.length-1]
      buf[index+1]=len[index].charCodeAt 0

    re_arr = []
    re_arr.push buf
    for i in [0..obj.length-1]
      re_arr.push @encode_inner obj[i]
    # s+=@NIL
    all_len = 0
    for tmp_ele in re_arr
      all_len+=tmp_ele.length
    start_index = 0
    end_index = all_len
    re_buf = new Buffer(all_len+start_index+1) # all+nil
    for tmp_ele in re_arr
      all_len+=tmp_ele.length
      tmp_ele.copy re_buf,start_index
      start_index+=tmp_ele.length
    re_buf[end_index]=@NIL_C
    re_buf


  encode_associative_array: (obj) ->
    # console.log "encode_associative_array"
    # console.log obj
    arr = new Array()
    for key,value of obj
      unless !obj.hasOwnProperty key
        arr.push @tuple(@atom(key), value)
    @encode_array arr

  int_to_bytes: (int, length) ->
    isNegative=originalInt=i=rem=s=""
    isNegative = int <0
    int=-int-1 unless !isNegative
    originalInt=int
    for i in [0..length-1]
      rem=int % 256
      rem=255-rem unless !isNegative
      # console.log rem
      s=String.fromCharCode(rem) + s
      int = Math.floor int/256
      i+=1
    throw("Argument out of range: "+originalInt) unless int <=0
    s

  # Encode an integer into an Erlang bignum,
  # which is a byte of 1 or 0 representing
  # whether the number is negative or positive,
  # followed by little-endian bytes.
  bignum_to_bytes: (int) ->
    isNegative=rem=s= ""
    isNegative = int < 0
    if isNegative
      int *= -1
      s+=String.fromCharCode 1
    else
      s+=String.fromCharCode 0

    while int isnt 0
      rem = int % 256
      s+=String.fromCharCode rem
      int = Math.floor int/256
    s

  # @notic 基本类型
  atom: (obj)->
    {type:"Atom", value:obj, toString: -> obj}

  binary: (obj) ->
    {type:"Binary", value:obj, toString: ->
      if Buffer.isBuffer obj
        tmp_val = obj.toString()
        "<<\"#{tmp_val}\">>"
      else
        "<<\"#{obj}\">>"}

  tuple: (arr...) ->
    tmp_obj = {type:"Tuple", length:arr.length, value:arr}
    index = -1
    tmp_obj[index+=1]=tmp_ele for tmp_ele in arr
    tmp_obj.toString = ->
      i = 0
      s = ""
      for i in [0..this.length-1]
        unless s is ""
          s+=", "
        s+=this[i].toString();
      "{#{s}}"
    tmp_obj

  binary_to_list: (str) ->
    ret = new Array()
    for i in [0..str.length-1]
      ret.push str.fromCharCode i
    ret

  sign:(data) ->
    shasum = crypto.createHash 'sha1'
    shasum.update data
    shasum.digest 'hex'
