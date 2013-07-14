do ($) =>
  GroupRoots = {}

  class ColorHolder
    constructor: (@_color) ->

    updateColor: (new_color) ->
      if new_color.equals(@_color)
        return
      @_color = new_color
      $(this).trigger('change', new_color)

  class Color
    constructor: (r=0, g=0, b=0, a=1.0) ->
      @r = to_byte_value(r)
      @g = to_byte_value(g)
      @b = to_byte_value(b)
      @a = to_unit_value(a)

    @fromCSS: (color_string) ->
      color_string = color_string.trim()
      color_string = @simple_colors()[color_string] ? color_string

      # array of color definition objects
      color_defs = [
        re: /^rgb\((\d{1,3}),\s*(\d{1,3}),\s*(\d{1,3})\)/i
        process: (m) =>
          new Color(
            parseInt(m[1]),
            parseInt(m[2]),
            parseInt(m[3])
          )
      ,
        re: /^#([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i
        process: (m) =>
          new Color(
            parseInt(m[1], 16),
            parseInt(m[2], 16),
            parseInt(m[3], 16)
          )
      ,
        re: /^#([0-9a-f])([0-9a-f])([0-9a-f])$/i
        process: (m) =>
          new Color(
            parseInt(m[1] + m[1], 16),
            parseInt(m[2] + m[2], 16),
            parseInt(m[3] + m[3], 16)
          )
      ]

      for d in color_defs
        if m = color_string.match(d.re)
          return d.process(m)
      return null

    # 文字列変換関数
    toString: ->
      @hex()

    hex: ->
      r = @r.toString(16)
      g = @g.toString(16)
      b = @b.toString(16)
      r = "0" + r  if r.length is 1
      g = "0" + g  if g.length is 1
      b = "0" + b  if b.length is 1
      ("#" + r + g + b).toLowerCase()

    hex3: ->
      if not [@r, @g, @b].every((x) -> Math.floor(x / 16) == x % 16)
        return null
      r = (@r % 16).toString(16)
      g = (@g % 16).toString(16)
      b = (@b % 16).toString(16)
      ("#" + r + g + b).toLowerCase()

    rgb: ->
      "rgb(#{@r}, #{@g}, #{@b})"

    name: ->
      hex = @hex()
      for name, hex_str of this.simple_colors()
        if hex_str == hex
          return name
      null

    @simple_colors = =>
      SimpleColors

    simple_colors: @simple_colors

    # 合成処理関連
    get: (element_name) ->
      e = element_name.toLowerCase()
      switch e
        when 'red'   then @r
        when 'green' then @g
        when 'blue'  then @b
        when 'alpha' then @a
        when 'hue', 'saturation', 'value'
          [h, s, v] = rgb_to_hsv(@r, @g, @b)
          switch e
            when 'hue'        then h
            when 'saturation' then s
            when 'value'      then v

    replace: (element_name, value) ->
      e = element_name.toLowerCase()
      color = Object.clone(this)
      switch e
        when 'red'
          color.r = value
        when 'blue'
          color.b = value
        when 'green'
          color.g = value
        when 'alpha'
          color.a = value
        when 'hue', 'saturation', 'value'
          [h, s, v] = rgb_to_hsv(@r, @g, @b)
          switch e
            when 'hue'
              h = value
            when 'saturation'
              s = value
            when 'value'
              v = value
          [color.r, color.g, color.b] = hsv_to_rgb(h, s, v)
      color

    equals: (other) ->
      Object.equals(this, other)

  in_range = (x, min, max) =>
    return min if x < min
    return max if x > max
    return x

  to_byte_value = (v) =>
    v = parseInt(v)
    v = 0 if isNaN(v)
    in_range(v, 0, 255)

  to_unit_value = (v) =>
    v = parseFloat(v)
    v = 0 if isNaN(v)
    in_range(v, 0, 1)

  rgb_to_hsv = (r, g, b) =>
    [r, g, b] = [r / 255, g / 255, b / 255]
    maxc = Math.max(r, g, b)
    minc = Math.min(r, g, b)
    v = maxc
    if minc == maxc
      return [0.0, 0.0, v]
    s = (maxc - minc) / maxc
    rc = (maxc - r) / (maxc - minc)
    gc = (maxc - g) / (maxc - minc)
    bc = (maxc - b) / (maxc - minc)
    if r == maxc
        h = bc - gc
    else if g == maxc
        h = 2.0 + rc - bc
    else
        h = 4.0 + gc - rc
    h = (h / 6.0) % 1.0
    return [h, s, v]

  hsv_to_rgb = (h, s, v) =>
    v *= 255
    if s == 0.0
      [v, v, v]
    i = parseInt(h * 6.0)
    f = (h * 6.0) - i
    p = v * (1.0 - s)
    q = v * (1.0 - s * f)
    t = v * (1.0 - s * (1.0-f))
    switch i % 6
      when 0 then [v, t, p]
      when 1 then [q, v, p]
      when 2 then [p, v, t]
      when 3 then [p, q, v]
      when 4 then [t, p, v]
      else [v, p, q]

  SimpleColors = {
    aliceblue: "#f0f8ff"
    antiquewhite: "#faebd7"
    aqua: "#00ffff"
    aquamarine: "#7fffd4"
    azure: "#f0ffff"
    beige: "#f5f5dc"
    bisque: "#ffe4c4"
    black: "#000000"
    blanchedalmond: "#ffebcd"
    blue: "#0000ff"
    blueviolet: "#8a2be2"
    brown: "#a52a2a"
    burlywood: "#deb887"
    cadetblue: "#5f9ea0"
    chartreuse: "#7fff00"
    chocolate: "#d2691e"
    coral: "#ff7f50"
    cornflowerblue: "#6495ed"
    cornsilk: "#fff8dc"
    crimson: "#dc143c"
    cyan: "#00ffff"
    darkblue: "#00008b"
    darkcyan: "#008b8b"
    darkgoldenrod: "#b8860b"
    darkgray: "#a9a9a9"
    darkgreen: "#006400"
    darkkhaki: "#bdb76b"
    darkmagenta: "#8b008b"
    darkolivegreen: "#556b2f"
    darkorange: "#ff8c00"
    darkorchid: "#9932cc"
    darkred: "#8b0000"
    darksalmon: "#e9967a"
    darkseagreen: "#8fbc8f"
    darkslateblue: "#483d8b"
    darkslategray: "#2f4f4f"
    darkturquoise: "#00ced1"
    darkviolet: "#9400d3"
    deeppink: "#ff1493"
    deepskyblue: "#00bfff"
    dimgray: "#696969"
    dodgerblue: "#1e90ff"
    feldspar: "#d19275"
    firebrick: "#b22222"
    floralwhite: "#fffaf0"
    forestgreen: "#228b22"
    fuchsia: "#ff00ff"
    gainsboro: "#dcdcdc"
    ghostwhite: "#f8f8ff"
    gold: "#ffd700"
    goldenrod: "#daa520"
    gray: "#808080"
    green: "#008000"
    greenyellow: "#adff2f"
    honeydew: "#f0fff0"
    hotpink: "#ff69b4"
    indianred: "#cd5c5c"
    indigo: "#4b0082"
    ivory: "#fffff0"
    khaki: "#f0e68c"
    lavender: "#e6e6fa"
    lavenderblush: "#fff0f5"
    lawngreen: "#7cfc00"
    lemonchiffon: "#fffacd"
    lightblue: "#add8e6"
    lightcoral: "#f08080"
    lightcyan: "#e0ffff"
    lightgoldenrodyellow: "#fafad2"
    lightgrey: "#d3d3d3"
    lightgreen: "#90ee90"
    lightpink: "#ffb6c1"
    lightsalmon: "#ffa07a"
    lightseagreen: "#20b2aa"
    lightskyblue: "#87cefa"
    lightslateblue: "#8470ff"
    lightslategray: "#778899"
    lightsteelblue: "#b0c4de"
    lightyellow: "#ffffe0"
    lime: "#00ff00"
    limegreen: "#32cd32"
    linen: "#faf0e6"
    magenta: "#ff00ff"
    maroon: "#800000"
    mediumaquamarine: "#66cdaa"
    mediumblue: "#0000cd"
    mediumorchid: "#ba55d3"
    mediumpurple: "#9370d8"
    mediumseagreen: "#3cb371"
    mediumslateblue: "#7b68ee"
    mediumspringgreen: "#00fa9a"
    mediumturquoise: "#48d1cc"
    mediumvioletred: "#c71585"
    midnightblue: "#191970"
    mintcream: "#f5fffa"
    mistyrose: "#ffe4e1"
    moccasin: "#ffe4b5"
    navajowhite: "#ffdead"
    navy: "#000080"
    oldlace: "#fdf5e6"
    olive: "#808000"
    olivedrab: "#6b8e23"
    orange: "#ffa500"
    orangered: "#ff4500"
    orchid: "#da70d6"
    palegoldenrod: "#eee8aa"
    palegreen: "#98fb98"
    paleturquoise: "#afeeee"
    palevioletred: "#d87093"
    papayawhip: "#ffefd5"
    peachpuff: "#ffdab9"
    peru: "#cd853f"
    pink: "#ffc0cb"
    plum: "#dda0dd"
    powderblue: "#b0e0e6"
    purple: "#800080"
    red: "#ff0000"
    rosybrown: "#bc8f8f"
    royalblue: "#4169e1"
    saddlebrown: "#8b4513"
    salmon: "#fa8072"
    sandybrown: "#f4a460"
    seagreen: "#2e8b57"
    seashell: "#fff5ee"
    sienna: "#a0522d"
    silver: "#c0c0c0"
    skyblue: "#87ceeb"
    slateblue: "#6a5acd"
    slategray: "#708090"
    snow: "#fffafa"
    springgreen: "#00ff7f"
    steelblue: "#4682b4"
    tan: "#d2b48c"
    teal: "#008080"
    thistle: "#d8bfd8"
    tomato: "#ff6347"
    turquoise: "#40e0d0"
    violet: "#ee82ee"
    violetred: "#d02090"
    wheat: "#f5deb3"
    white: "#ffffff"
    whitesmoke: "#f5f5f5"
    yellow: "#ffff00"
    yellowgreen: "#9acd32"
  }

  $.widget 'ui.colorwidget',
    _create: ->
      @options = $.extend({
        color: @element.data('colorinput-color') ? new Color
        group: @element.data('colorinput-group')
      }, @options)

      @_trigger 'updateelement', null, @option('color')

      $(@_getRoot()).on 'change', (event, color) =>
        @option 'color', color

    _getRoot: () ->
      root = GroupRoots[@options.group] ?= new ColorHolder(@options.color)
      return root

    _setOption: (key, value) ->
      if key != 'color'
        return @_super 'option', key, value

      if $.type(value) == 'string'
        new_color = Color.fromCSS(value)
      else
        new_color = value

      old_color = @option('color')
      if new_color.equals(old_color)
        return

      @options.color = new_color
      @_trigger 'updateelement', null, new_color
      @_getRoot().updateColor(new_color)
      @_trigger 'colorwidgetchange', null, new_color

  $.widget 'ui._abstractcolorinput', $.ui.colorwidget,
    _create: ->
      if not @element.is('input[type=text]')
        return

      @options = $.extend({
        type: @element.data('colorinput-type') ? 'css'
        css_format: @element.data('colorinput-css-format')
      }, @options)

      if @options.css_format == undefined
        @options.css_format = []
      else if $.type(@options.css_format) == 'string'
        @options.css_format = @options.css_format.split(/\s+/)

      @_impl = @_getColorInputImpl(@options.type)

      @options.updateelement = (event, color) =>
        c = @_impl.colorFromElement()
        if c? and c.equals(color)
          return
        @_impl.updateElement(color)

      @_super()

      @element.on 'change', =>
        new_color = @_impl.colorFromElement()
        if not new_color?
          return
        color = @option 'color'
        if new_color.equals color
          return
        @_setOption 'color', new_color

  $.widget 'ui.colorinput', $.ui._abstractcolorinput,
    _getColorInputImpl: (type) ->
      type = type.toLowerCase()

      attr_types = '''
        red green blue
        redhex greenhex bluehex
        alpha
        hue saturation value
      '''.split(/\s+/)
      if type == 'css'
        new CssColorInputImpl(this)
      else if type in attr_types
        new AttrColorInputImpl(this)
      else
        throw new ValueError


  class AbstractColorInputImpl
    constructor: (@_this) ->
    type: -> @_this.option('type')
    element: -> @_this.element
    color: -> @_this.option('color')


  class CssColorInputImpl extends AbstractColorInputImpl
    updateElement: (color) ->
      name = (color.name() if 'name' in @css_format())
      hex3 = (color.hex3() if 'hex3' in @css_format())
      rgb  = (color.rgb() if 'rgb' in @css_format())
      @element().val(name ? hex3 ? rgb ? color.hex())

    colorFromElement: ->
      Color.fromCSS(@element().val())

    css_format: -> @_this.option('css_format')


  class AttrColorInputImpl extends AbstractColorInputImpl
    updateElement: (color) ->
      v = color.get(@type())
      text = switch @type()
        when 'red', 'green', 'blue'
          v.toString()
        when 'redhex', 'greenhex', 'bluehex'
          ('00' + v.toString(16)).slice(-2)
        else
          v.toString()
      @element().val(text)

    colorFromElement: ->
      val = $.trim(@element().val())

      v = switch @type()
        when 'red', 'green', 'blue'
          parseInt val
        when 'redhex', 'greenhex', 'bluehex'
          parseInt val, 16
        else
          parseFloat val
      if isNaN(v)
        return null
      @color().replace(@type(), v)

