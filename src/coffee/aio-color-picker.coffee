do (jQuery) =>
  EventName = 'ColorChange'
  DataName = 'color'
  $ = jQuery

  in_range = (x, min, max) =>
    return min if x < min
    return max if x > max
    return x

  $.fn.colorPicker  = (options) ->
    $elements = this
    options = $.extend({
      type: 'css',
    }, options)

    switch options.type
      when 'css'
        options = $.extend({
          format: ['hex']
        }, options)

        format = options.format
        if $.type(format) != 'array'
          format = [format]

        input_changed = (input) =>
          $(input).color(Color.fromCSS($(input).val()))

        # 設定情報の構築
        $elements.filter('input[type=text]').each ->
          $(this)
            .data(DataName, new Color)
            .data 'update_value', (color) ->
              if Color.fromCSS($(this).val())?.equals(color)
                return
              name = (color.name() if 'name' in format)
              hex3 = (color.hex3() if 'hex3' in format)
              rgb  =  (color.rgb() if 'rgb' in format)
              $(this).val(name ? hex3 ? rgb ? color.hex())
            .on 'change', ->
              input_changed(this)
            .on 'keypress', (e) ->
               if (e.which? and e.which == 13) or (e.keycode? and e.keycode == 13)
                input_changed(this)

  $.fn.color = (color) ->
    unless color?
      return this.data(DataName)

    if jQuery.type(color) == "string"
      color = Color.fromCSS(color)

    this.each ->
      old_color = $(this).color()
      return if color.equals(old_color)

      $(this).data(DataName, color)
      $(this).data('update_value').call(this, color)
      $(this).trigger(EventName, color)

    return this


  class Color
    constructor: (r=0, g=0, b=0, a=1.0) ->
      [@r, @g, @b] = (in_range(parseInt(x), 0, 255) for x in [r, g, b])
      @a = in_range(parseFloat(a), 0, 1)

    equals: (other) ->
      (   @r == other.r \
      and @g == other.g \
      and @b == other.b \
      and @a == other.a)

    @fromCSS: (color_string) ->
      color_string = color_string.trim()
      color_string = Color.simple_colors()[color_string] ? color_string

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
      for name, hex_str of Color.simple_colors()
        if hex_str == hex
          return name
      null

    @simple_colors = =>
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

