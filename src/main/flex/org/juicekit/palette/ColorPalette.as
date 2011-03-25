/*
* Copyright 2007-2010 Juice, Inc.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

package org.juicekit.palette {
  
  /**
   * Palette for color values, including utility methods for generating
   * both categorical and ordinal color palettes.
   *
   * <p>A large number of predefined color palettes are
   * accessible through <code>getPaletteByName</code> and similar functions.
   * These predefined ColorPalettes are derived from Cynthia
   * Brewer&#8217;s Apache-licensed colorbrewer2.org. </p>
   *
   * <p>ColorPalettes are bindable through <code>colorsAC</code> and
   * <code>getColorByIndexFromAC</code>. ColorPalettes dispatch the
   * ColorPalette.COLORS_CHANGED event when colors in the palette
   * change.</p>
   *
   * <p>ColorPalettes can be manipulated using all of the
   * manipulation functions in <code>org.juicekit.flare.util.Colors</code>
   * utility class.</p>
   *
   * <p>@see org.juicekit.flare.util.Colors</p>
   *
   * <p>ColorPalettes can be generated from a base color using a
   * variety of rules. </p>
   *
   * <p>Derived from the Flare ColorPalette class extended with
   * elements of the NodeBox colors module
   * (http://nodebox.net/code/index.php/Colors).</p>
   *
   * <h2 id="predefined_color_palettes">Predefined color palettes</h2>
   *
   * <h3 id="sequential_highest_intensity_at_the_top">Sequential (highest intensity at the top)</h3>
   *
   * <ul>
   * <li>copper single strong</li>
   * <li>gray single strong</li>
   * <li>bone single strong</li>
   * <li>hot single strong</li>
   * <li>winter single</li>
   * <li>pink single strong</li>
   * <li>gray single</li>
   * <li>gist_gray single</li>
   * <li>gist_heat single</li>
   * <li>gist_earth single</li>
   * <li>autumn single weak</li>
   * <li>summer single weak</li>
   * </ul>
   *
   * <h3 id="sequential_reversed_highest_intensity_at_the_bottom">Sequential reversed (highest intensity at the bottom)</h3>
   *
   * <ul>
   * <li>binary single reversed b&amp;w</li>
   * <li>Blues single reversed</li>
   * <li>BuGn single reversed</li>
   * <li>BuPu single reversed</li>
   * <li>GnBu single reversed</li>
   * <li>Greens single reversed</li>
   * <li>Greys single reversed</li>
   * <li>Oranges single reversed</li>
   * <li>OrRd single reversed</li>
   * <li>PuBu single reversed</li>
   * <li>PuBuGn single reversed</li>
   * <li>PuRd single reversed</li>
   * <li>Purples single reversed</li>
   * <li>RdPu single reversed</li>
   * <li>Reds single reversed</li>
   * <li>YlGn single reversed</li>
   * <li>YlGnBu single reversed</li>
   * <li>YlOrBr single reversed</li>
   * <li>YlOrRd single reversed</li>
   * <li>gist_yarg single reversed</li>
   * </ul>
   *
   * <h3 id="diverging">Diverging</h3>
   *
   * <ul>
   * <li>spring double?</li>
   * <li>cool double?</li>
   * <li>jet double?</li>
   * <li>PiYG double</li>
   * <li>PRGn double</li>
   * <li>PuOr double</li>
   * <li>RdBu double</li>
   * <li>RdGy double</li>
   * <li>RdYlBu double</li>
   * <li>RdYlGn double</li>
   * <li>Spectral double</li>
   * <li>BrBG double</li>
   * </ul>
   *
   * <h3 id="categorical">Categorical</h3>
   *
   * <ul>
   * <li>spectral categorical</li>
   * <li>hsv categorical</li>
   * <li>prism categorical weird</li>
   * <li>Accent categorical</li>
   * <li>Dark2 categorical</li>
   * <li>Paired categorical in groups</li>
   * <li>Pastel1 categorical low contrast</li>
   * <li>Pastel2 categorical low contrast</li>
   * <li>Set1 categorical</li>
   * <li>Set2 categorical low contrast</li>
   * <li>Set3 categorical low contrast</li>
   * <li>gist_ncar categorical?</li>
   * <li>gist_rainbow categorical</li>
   * <li>gist_stern categorical</li>
   * <li>google categorical fixed length (6)</li>
   * </ul>
   *
   * @author Chris Gemignani
   */
  
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IEventDispatcher;
  
  import mx.binding.utils.ChangeWatcher;
  import mx.collections.ArrayCollection;
  import mx.styles.StyleManager;
  
  import org.juicekit.util.Colors;
  import org.juicekit.util.Maths;
  
  
  [Bindable]
  public class ColorPalette extends Palette implements IPalette {
    /**
     * An object containing arrays
     */
    public var nameCache:Object = {};
    
    private const COLORS_CHANGED:String = 'colorsChanged';
    
    
    /** Default size of generated color palettes. */
    public static const DEFAULT_SIZE:int = 64;
    
    /** A set of 10 colors for encoding category values. */
    public static const CATEGORY_COLORS_10:/*uint*/Array = [
      0xFF1F77B4, 0xFFFF7F0E, 0xFF2CA02C, 0xFFD62728, 0xFF9467BD,
      0xFF8C564B, 0xFFE377C2, 0xFF7F7F7F, 0xFFBCBD22, 0xFF17BECF
    ];
    
    /** A set of 20 colors for encoding category values. Includes
     *  the colors of <code>CATEGORY_COLORS_10</code> plus lighter
     *  shades of each. */
    public static const CATEGORY_COLORS_20:/*uint*/Array = [
      0xFF1F77B4, 0xFFAEC7E8, 0xFFFF7F0E, 0xFFFFBB78, 0xFF2CA02C,
      0xFF98DF8A, 0xFFD62728, 0xFFFF9896, 0xFF9467BD, 0xFFC5B0D5,
      0xFF8C564B, 0xFFC49C94, 0xFFE377C2, 0xFFF7B6D2, 0xFF7F7F7F,
      0xFFC7C7C7, 0xFFBCBD22, 0xFFDBDB8D, 0xFF17BECF, 0xFF9EDAE5
    ];
    
    /** An alternative set of 19 colors for encoding category values. */
    public static const CATEGORY_COLORS_ALT_19:/*uint*/Array = [
      0xff9C9EDE, 0xff7375B5, 0xff4A5584, 0xffCEDB9C, 0xffB5CF6B,
      0xff8CA252, 0xff637939, 0xffE7CB94, 0xffE7BA52, 0xffBD9E39,
      0xff8C6D31, 0xffE7969C, 0xffD6616B, 0xffAD494A, 0xff843C39,
      0xffDE9ED6, 0xffCE6DBD, 0xffA55194, 0xff7B4173
    ];
    
    /**
     * An optional name for the palette
     * This will be used to attempt to lookup the palette
     * if the palette length is changed
     */
    public var paletteName:String = 'undefined';
    
    public var reversed:Boolean = false;
    
    private var _keyframes:Array;
    
    /** Keyframes at which color values change in the palette. Useful
     *  for configuring gradient paint fills. */
    public function get keyframes():Array {
      return _keyframes;
    }
    
    /** Array of palette values. */
    override public function get values():Array {
      return _values;
    }
    
    override public function set values(a:Array):void {
      _values = a;
    }
    

    override public function set length(v:int):void {
      var p:ColorPalette = getPaletteByName(paletteName, v);
      if (this.reversed) {
        p = p.reverse();
      }
      values = p.values.slice();
      dispatchEvent(new Event(COLORS_CHANGED));
    }
    
    
    /**
     * Creates a new ColorPalette.
     * @param colors an array of colors defining the palette
     * @param keyframes array of keyframes of color interpolations
     * @param paletteName an optional name for the palette
     */
    public function ColorPalette(colors:Array, keyframes:Array = null, paletteName:String = 'undefined') {
      ChangeWatcher.watch(this, "values", colorsChangedListener);
      values = colors;
      _keyframes = keyframes;
      colorsAC.source = values;
      this.paletteName = paletteName;
    }
    
    
    private function colorsChangedListener(e:Event):void {
      colorsAC.source = values;
      dispatchEvent(new Event(COLORS_CHANGED));
    }
    
    
    /**
     * Generates a categorical color palette
     * @param size the number of colors to include
     * @param colors an array of category colors to use. If null, a
     *  default category color palette will be used.
     * @param alpha the alpha value for this palette's colors
     * @return the categorical color palette
     */
    public static function category(size:int = 20, colors:Array = null,
                                    alpha:Number = 1.0):ColorPalette
    {
      if (colors == null)
        colors = size <= 10 ? CATEGORY_COLORS_10 : CATEGORY_COLORS_20;
      var a:uint = uint(255 * alpha) % 256;
      var cm:Array = new Array(size);
      for (var i:uint = 0; i < size; ++i) {
        cm[i] = Colors.setAlpha(colors[i % colors.length], a);
      }
      return new ColorPalette(cm);
    }
    
    
    public var colorsAC:ArrayCollection = new ArrayCollection();
    
    
    /**
     * Generates a color palette that "ramps" from one color to another.
     * @param min the color corresponding to the minimum scale value
     * @param max the color corresponding to the maximum scale value
     * @param size the size of the color palette
     * @return the color palette
     */
    public static function ramp(min:uint = 0xfff1eef6, max:uint = 0xff045a8d,
                                size:int = DEFAULT_SIZE):ColorPalette
    {
      var cm:Array = new Array(size);
      for (var i:uint = 0; i < size; ++i) {
        cm[i] = Colors.interpolate(min, max, i / (size - 1));
      }
      return new ColorPalette(cm, [0,1]);
    }
    
    /**
     * Generates a color palette of color ramps diverging from a central
     * value.
     * @param min the color corresponding to the minimum scale value
     * @param mid the color corresponding to the central scale value
     * @param max the color corresponding to the maximum scale value
     * @param f an interpolation fraction specifying the position of the
     *  central value
     * @param size the size of the color palette
     * @return the color palette
     */
    public static function diverging(min:uint = 0xffd73027,
                                     mid:uint = 0xffffffbf, max:uint = 0xff1a9850,
                                     f:Number = 0.5, size:int = DEFAULT_SIZE):ColorPalette
    {
      var cm:Array = new Array(size);
      var mp:int = int(f * size), i:uint, j:uint;
      for (i = 0; i < mp; ++i) {
        cm[i] = Colors.interpolate(min, mid, i / mp);
      }
      mp = size - mp - 1;
      for (j = 0; i < size; ++i,++j) {
        cm[i] = Colors.interpolate(mid, max, j / mp);
      }
      return new ColorPalette(cm, [0,f,1]);
    }
    
    
    /**
     * Retrieves the color corresponding to input interpolation fraction.
     * @param v an interpolation fraction
     * @return the color corresponding to the input fraction
     */
    public function getColor(v:Number):uint
    {
      if (_values == null || _values.length == 0)
        return 0;
      return _values[uint(Math.round(v * (_values.length - 1)))];
    }
    
    /**
     * Retrieves the color corresponding to the input array index.
     * @param idx an integer index. The actual index value used is
     *  the modulo of the input index by the length of the palette.
     * @return the color in the palette at the given index
     */
    public function getColorByIndex(idx:int):uint
    {
      if (_values == null || _values.length == 0 || idx < 0)
        return 0;
      else
        return _values[idx % _values.length];
    }
    
    /**
     * Retrieves the color corresponding to the input array index.
     * This function result is bindable.
     * @param idx an integer index. The actual index value used
     * is the modulo of the input index by the length of the palette.
     * @return the color in the palette at the given index.
     */
    [Bindable(event="colorsChanged")]
    public function getColorByIndexFromAC(idx:int):uint
    {
      if (_values == null || _values.length == 0 || idx < 0) {
        return 0;
      } else {
        return colorsAC.getItemAt(idx % _values.length) as uint;
      }
    }
    
    
    /**
     * <p>Retrieve a color palette by name.</p>
     *
     * <p>If the name is preceeded by a "-", the color palette
     * will be reversed. The default palette is 'spectral'</p>
     *
     */
    public static function getPaletteByName(name:String = '', size:int = 64):ColorPalette {
      const lookup:Object = {
        'autumn': autumn,
        'summer': summer,
        'spring': spring,
        'winter': winter,
        'hsv': hsv,
        'copper': copper,
        'gray': gray,
        'bone': bone,
        'hot': hot,
        'cool': cool,
        'spectral': spectral,
        'prism': prism,
        'pink': pink,
        'jet': jet,
        'binary': binary,
        'Accent': Accent,
        'Blues': Blues,
        'BrBG': BrBG,
        'BuGn': BuGn,
        'BuPu': BuPu,
        'Dark2': Dark2,
        'GnBu': GnBu,
        'Greens': Greens,
        'Greys': Greys,
        'Oranges': Oranges,
        'OrRd': OrRd,
        'Paired': Paired,
        'Pastel1': Pastel1,
        'Pastel2': Pastel2,
        'PiYG': PiYG,
        'PRGn': PRGn,
        'PuBu': PuBu,
        'PuBuGn': PuBuGn,
        'PuOr': PuOr,
        'PuRd': PuRd,
        'Purples': Purples,
        'RdBu': RdBu,
        'RdGy': RdGy,
        'RdPu': RdPu,
        'RdYlBu': RdYlBu,
        'RdYlGn': RdYlGn,
        'Reds': Reds,
        'Set1': Set1,
        'Set2': Set2,
        'Set3': Set3,
        'Spectral': Spectral,
        'YlGn': YlGn,
        'YlGnBu': YlGnBu,
        'YlOrBr': YlOrBr,
        'YlOrRd': YlOrRd,
        'gist_earth': gist_earth,
        'gist_gray': gist_gray,
        'gist_heat': gist_heat,
        'gist_ncar': gist_ncar,
        'gist_rainbow': gist_rainbow,
        'gist_stern': gist_stern,
        'gist_yarg': gist_yarg,
        'google': googleColors
      };
      var reverse:Boolean = false;
      if (name.charAt(0) == '-') {
        reverse = true;
        name = name.substr(1);
      }
      name = lookup.hasOwnProperty(name) ? name : 'spectral';
      if (reverse) {
        return lookup[name](size).reverse();
      } else {
        return lookup[name](size);
      }
    }
    
    /**
     * Sequential palettes go from a low intensity to a high intensity
     */
    public static function getSequentialPaletteByName(name:String = 'hot', size:int = 64):ColorPalette {
      const lookup:Object = {
        'copper': copper,
        'gray': gray,
        'bone': bone,
        'hot': hot,
        'winter': winter,
        'pink': pink,
        'gist_gray': gist_gray,
        'gist_heat': gist_heat,
        'gist_earth': gist_earth,
        'autumn': autumn,
        'summer': summer
      };
      name = lookup.hasOwnProperty(name) ? name : 'hot';
      return lookup[name](size);
    }
    
    
    /**
     * Sequential reversed palettes go from a high intensity to a low intensity
     */
    public static function getSequentialReversedPaletteByName(name:String = 'binary', size:int = 64):ColorPalette {
      const lookup:Object = {
        'binary': binary,
        'Blues': Blues,
        'BuGn': BuGn,
        'BuPu': BuPu,
        'GnBu': GnBu,
        'Greens': Greens,
        'Greys': Greys,
        'Oranges': Oranges,
        'OrRd': OrRd,
        'PuBu': PuBu,
        'PuBuGn': PuBuGn,
        'PuRd': PuRd,
        'Purples': Purples,
        'RdPu': RdPu,
        'Reds': Reds,
        'YlGn': YlGn,
        'YlGnBu': YlGnBu,
        'YlOrBr': YlOrBr,
        'YlOrRd': YlOrRd,
        'gist_yarg': gist_yarg
      };
      name = lookup.hasOwnProperty(name) ? name : 'binary';
      return lookup[name](size);
    }
    
    /**
     * Diverging palettes go from an negative high intensity through a lower intensit
     * critical midpoint to a positive high intensity
     */
    public static function getDivergingPaletteByName(name:String = 'RdGy', size:int = 64):ColorPalette {
      const lookup:Object = {
        'spring': spring,
        'cool': cool,
        'jet': jet,
        'PiYG': PiYG,
        'PRGn': PRGn,
        'PuOr': PuOr,
        'RdBu': RdBu,
        'RdGy': RdGy,
        'RdYlBu': RdYlBu,
        'RdYlGn': RdYlGn,
        'Spectral': Spectral,
        'BrBG': BrBG
      };
      name = lookup.hasOwnProperty(name) ? name : 'RdGy';
      return lookup[name](size);
    }
    
    /**
     * Categorical palettes shows categories
     * Size in a categorical palette needs to always match the number of categories.
     */
    public static function getCategoricalPaletteByName(name:String = 'spectral'):ColorPalette {
      const lookup:Object = {
        'spectral': [spectral,21],
        'Dark2': [Dark2,8],
        'Paired': [Paired,12],
        'Pastel1': [Pastel1,9],
        'Pastel2': [Pastel2,9],
        'Set1': [Set1,9],
        'Set2': [Set2,9],
        'Set3': [Set3,12],
        'gist_ncar': [gist_ncar,40],
        'gist_rainbow': [gist_rainbow,40],
        'gist_stern': [gist_stern,40],
        'google': googleColors
      };
      if (!lookup.hasOwnProperty(name)) throw Error('Invalid categorical palette name: ' + name);
      if (lookup[name] is Function) return lookup[name]();
      
      return lookup[name][0](lookup[name][1]);
    }
    
    
    //--------------------------
    // ColorBrewer color palettes
    // these must be accessed by name
    //--------------------------
    
    private static function autumn(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 1.0000],
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [0.0000, 0.0000],
        [0.0000, 1.0000],
        'autumn',
        size);
    }
    
    
    private static function bone(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 0.6528, 1.0000],
        [0.0000, 0.7460, 1.0000],
        [0.0000, 0.3194, 0.7778, 1.0000],
        [0.0000, 0.3651, 0.7460, 1.0000],
        [0.0000, 0.4444, 1.0000],
        [0.0000, 0.3651, 1.0000],
        'bone',
        size);
    }
    
    
    private static function binary(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.0000],
        [0.0000, 1.0000],
        [1.0000, 0.0000],
        [0.0000, 1.0000],
        [1.0000, 0.0000],
        [0.0000, 1.0000],
        'binary',
        size);
    }
    
    
    private static function cool(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [1.0000, 0.0000],
        [0.0000, 1.0000],
        [1.0000, 1.0000],
        [0.0000, 1.0000],
        'cool',
        size);
    }
    
    
    private static function copper(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 1.0000, 1.0000],
        [0.0000, 0.8095, 1.0000],
        [0.0000, 0.7812],
        [0.0000, 1.0000],
        [0.0000, 0.4975],
        [0.0000, 1.0000],
        'copper',
        size);
    }
    
    
    private static function gray(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        'gray',
        size);
    }
    
    
    private static function hot(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0416, 1.0000, 1.0000],
        [0.0000, 0.3651, 1.0000],
        [0.0000, 0.0000, 1.0000, 1.0000],
        [0.0000, 0.3651, 0.7460, 1.0000],
        [0.0000, 0.0000, 1.0000],
        [0.0000, 0.7460, 1.0000],
        'hot',
        size);
    }
    
    
    private static function hsv(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 1.0000, 0.9688, 0.0312, 0.0000, 0.0000, 0.0312, 0.9688, 1.0000, 1.0000],
        [0.0000, 0.1587, 0.1746, 0.3333, 0.3492, 0.6667, 0.6825, 0.8413, 0.8571, 1.0000],
        [0.0000, 0.9375, 1.0000, 1.0000, 0.0625, 0.0000, 0.0000], // % of color
        [0.0000, 0.1587, 0.1746, 0.5079, 0.6667, 0.6825, 1.0000], // real value
        [0.0000, 0.0000, 0.0625, 1.0000, 1.0000, 0.9375, 0.0938],
        [0.0000, 0.3333, 0.3492, 0.5079, 0.8413, 0.8571, 1.0000],
        'hsv',
        size);
    }
    
    
    private static function jet(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 0.0000, 1.0000, 1.0000, 0.5000],
        [0.0000, 0.3500, 0.6600, 0.8900, 1.0000],
        [0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000],
        [0.0000, 0.1250, 0.3750, 0.6400, 0.9100, 1.0000],
        [0.5000, 1.0000, 1.0000, 0.0000, 0.0000],
        [0.0000, 0.1100, 0.3400, 0.6500, 1.0000],
        'jet',
        size);
    }
    
    
    private static function pink(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.1178, 0.1959, 0.2507, 0.2955, 0.3343, 0.3691, 0.4009, 0.4303, 0.4579, 0.4839, 0.5085, 0.5320, 0.5546, 0.5762, 0.5971, 0.6172, 0.6367, 0.6557, 0.6741, 0.6920, 0.7094, 0.7265, 0.7431, 0.7594, 0.7664, 0.7732, 0.7800, 0.7868, 0.7935, 0.8001, 0.8067, 0.8133, 0.8197, 0.8262, 0.8325, 0.8389, 0.8452, 0.8514, 0.8576, 0.8637, 0.8698, 0.8759, 0.8819, 0.8879, 0.8938, 0.8997, 0.9056, 0.9114, 0.9172, 0.9230, 0.9287, 0.9344, 0.9400, 0.9456, 0.9512, 0.9567, 0.9623, 0.9677, 0.9732, 0.9786, 0.9840, 0.9894, 0.9947, 1.0000],
        [0.0000, 0.0159, 0.0317, 0.0476, 0.0635, 0.0794, 0.0952, 0.1111, 0.1270, 0.1429, 0.1587, 0.1746, 0.1905, 0.2063, 0.2222, 0.2381, 0.2540, 0.2698, 0.2857, 0.3016, 0.3175, 0.3333, 0.3492, 0.3651, 0.3810, 0.3968, 0.4127, 0.4286, 0.4444, 0.4603, 0.4762, 0.4921, 0.5079, 0.5238, 0.5397, 0.5556, 0.5714, 0.5873, 0.6032, 0.6190, 0.6349, 0.6508, 0.6667, 0.6825, 0.6984, 0.7143, 0.7302, 0.7460, 0.7619, 0.7778, 0.7937, 0.8095, 0.8254, 0.8413, 0.8571, 0.8730, 0.8889, 0.9048, 0.9206, 0.9365, 0.9524, 0.9683, 0.9841, 1.0000],
        [0.0000, 0.1029, 0.1455, 0.1782, 0.2057, 0.2300, 0.2520, 0.2722, 0.2910, 0.3086, 0.3253, 0.3412, 0.3563, 0.3709, 0.3849, 0.3984, 0.4115, 0.4241, 0.4364, 0.4484, 0.4600, 0.4714, 0.4825, 0.4933, 0.5175, 0.5407, 0.5628, 0.5842, 0.6048, 0.6247, 0.6440, 0.6627, 0.6809, 0.6986, 0.7159, 0.7328, 0.7493, 0.7655, 0.7813, 0.7968, 0.8120, 0.8270, 0.8416, 0.8560, 0.8702, 0.8842, 0.8979, 0.9114, 0.9172, 0.9230, 0.9287, 0.9344, 0.9400, 0.9456, 0.9512, 0.9567, 0.9623, 0.9677, 0.9732, 0.9786, 0.9840, 0.9894, 0.9947, 1.0000],
        [0.0000, 0.0159, 0.0317, 0.0476, 0.0635, 0.0794, 0.0952, 0.1111, 0.1270, 0.1429, 0.1587, 0.1746, 0.1905, 0.2063, 0.2222, 0.2381, 0.2540, 0.2698, 0.2857, 0.3016, 0.3175, 0.3333, 0.3492, 0.3651, 0.3810, 0.3968, 0.4127, 0.4286, 0.4444, 0.4603, 0.4762, 0.4921, 0.5079, 0.5238, 0.5397, 0.5556, 0.5714, 0.5873, 0.6032, 0.6190, 0.6349, 0.6508, 0.6667, 0.6825, 0.6984, 0.7143, 0.7302, 0.7460, 0.7619, 0.7778, 0.7937, 0.8095, 0.8254, 0.8413, 0.8571, 0.8730, 0.8889, 0.9048, 0.9206, 0.9365, 0.9524, 0.9683, 0.9841, 1.0000],
        [0.0000, 0.1029, 0.1455, 0.1782, 0.2057, 0.2300, 0.2520, 0.2722, 0.2910, 0.3086, 0.3253, 0.3412, 0.3563, 0.3709, 0.3849, 0.3984, 0.4115, 0.4241, 0.4364, 0.4484, 0.4600, 0.4714, 0.4825, 0.4933, 0.5040, 0.5143, 0.5245, 0.5345, 0.5443, 0.5540, 0.5634, 0.5727, 0.5819, 0.5909, 0.5998, 0.6086, 0.6172, 0.6257, 0.6341, 0.6424, 0.6506, 0.6587, 0.6667, 0.6746, 0.6824, 0.6901, 0.6977, 0.7052, 0.7272, 0.7485, 0.7692, 0.7893, 0.8090, 0.8282, 0.8469, 0.8653, 0.8832, 0.9008, 0.9181, 0.9351, 0.9517, 0.9681, 0.9842, 1.0000],
        [0.0000, 0.0159, 0.0317, 0.0476, 0.0635, 0.0794, 0.0952, 0.1111, 0.1270, 0.1429, 0.1587, 0.1746, 0.1905, 0.2063, 0.2222, 0.2381, 0.2540, 0.2698, 0.2857, 0.3016, 0.3175, 0.3333, 0.3492, 0.3651, 0.3810, 0.3968, 0.4127, 0.4286, 0.4444, 0.4603, 0.4762, 0.4921, 0.5079, 0.5238, 0.5397, 0.5556, 0.5714, 0.5873, 0.6032, 0.6190, 0.6349, 0.6508, 0.6667, 0.6825, 0.6984, 0.7143, 0.7302, 0.7460, 0.7619, 0.7778, 0.7937, 0.8095, 0.8254, 0.8413, 0.8571, 0.8730, 0.8889, 0.9048, 0.9206, 0.9365, 0.9524, 0.9683, 0.9841, 1.0000],
        'pink',
        size);
    }
    
    
    private static function prism(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 1.0000, 0.0000, 0.0000, 0.6667, 1.0000, 1.0000, 0.0000, 0.0000, 0.6667, 1.0000, 1.0000, 0.0000, 0.0000, 0.6667, 1.0000, 1.0000, 0.0000, 0.0000, 0.6667, 1.0000, 1.0000, 0.0000, 0.0000, 0.6667, 1.0000, 1.0000, 0.0000, 0.0000, 0.6667, 1.0000, 1.0000, 0.0000, 0.0000, 0.6667, 1.0000, 1.0000, 0.0000, 0.0000, 0.6667, 1.0000, 1.0000, 0.0000, 0.0000, 0.6667, 1.0000, 1.0000, 0.0000, 0.0000, 0.6667, 1.0000, 1.0000, 0.0000],
        [0.0000, 0.0317, 0.0476, 0.0635, 0.0794, 0.0952, 0.1270, 0.1429, 0.1587, 0.1746, 0.1905, 0.2222, 0.2381, 0.2540, 0.2698, 0.2857, 0.3175, 0.3333, 0.3492, 0.3651, 0.3810, 0.4127, 0.4286, 0.4444, 0.4603, 0.4762, 0.5079, 0.5238, 0.5397, 0.5556, 0.5714, 0.6032, 0.6190, 0.6349, 0.6508, 0.6667, 0.6984, 0.7143, 0.7302, 0.7460, 0.7619, 0.7937, 0.8095, 0.8254, 0.8413, 0.8571, 0.8889, 0.9048, 0.9206, 0.9365, 0.9524, 0.9841, 1.0000],
        [0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000],
        [0.0000, 0.0317, 0.0476, 0.0635, 0.0952, 0.1270, 0.1429, 0.1587, 0.1905, 0.2222, 0.2381, 0.2540, 0.2857, 0.3175, 0.3333, 0.3492, 0.3810, 0.4127, 0.4286, 0.4444, 0.4762, 0.5079, 0.5238, 0.5397, 0.5714, 0.6032, 0.6190, 0.6349, 0.6667, 0.6984, 0.7143, 0.7302, 0.7619, 0.7937, 0.8095, 0.8254, 0.8571, 0.8889, 0.9048, 0.9206, 0.9524, 0.9841, 1.0000],
        [0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000, 1.0000, 1.0000, 0.0000, 0.0000],
        [0.0000, 0.0476, 0.0635, 0.0794, 0.0952, 0.1429, 0.1587, 0.1746, 0.1905, 0.2381, 0.2540, 0.2698, 0.2857, 0.3333, 0.3492, 0.3651, 0.3810, 0.4286, 0.4444, 0.4603, 0.4762, 0.5238, 0.5397, 0.5556, 0.5714, 0.6190, 0.6349, 0.6508, 0.6667, 0.7143, 0.7302, 0.7460, 0.7619, 0.8095, 0.8254, 0.8413, 0.8571, 0.9048, 0.9206, 0.9365, 0.9524, 1.0000],
        'prism',
        size);
    }
    
    
    private static function spring(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 1.0000],
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [1.0000, 0.0000],
        [0.0000, 1.0000],
        'spring',
        size);
    }
    
    
    private static function summer(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [0.5000, 1.0000],
        [0.0000, 1.0000],
        [0.4000, 0.4000],
        [0.0000, 1.0000],
        'summer',
        size);
    }
    
    
    private static function winter(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 0.0000],
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [0.0000, 1.0000],
        [1.0000, 0.5000],
        [0.0000, 1.0000],
        'winter',
        size);
    }
    
    
    private static function spectral(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 0.4667, 0.5333, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.7333, 0.9333, 1.0000, 1.0000, 1.0000, 0.8667, 0.8000, 0.8000],
        [0.0000, 0.0500, 0.1000, 0.1500, 0.2000, 0.2500, 0.3000, 0.3500, 0.4000, 0.4500, 0.5000, 0.5500, 0.6000, 0.6500, 0.7000, 0.7500, 0.8000, 0.8500, 0.9000, 0.9500, 1.0000],
        [0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.4667, 0.6000, 0.6667, 0.6667, 0.6000, 0.7333, 0.8667, 1.0000, 1.0000, 0.9333, 0.8000, 0.6000, 0.0000, 0.0000, 0.0000, 0.8000],
        [0.0000, 0.0500, 0.1000, 0.1500, 0.2000, 0.2500, 0.3000, 0.3500, 0.4000, 0.4500, 0.5000, 0.5500, 0.6000, 0.6500, 0.7000, 0.7500, 0.8000, 0.8500, 0.9000, 0.9500, 1.0000],
        [0.0000, 0.5333, 0.6000, 0.6667, 0.8667, 0.8667, 0.8667, 0.6667, 0.5333, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.8000],
        [0.0000, 0.0500, 0.1000, 0.1500, 0.2000, 0.2500, 0.3000, 0.3500, 0.4000, 0.4500, 0.5000, 0.5500, 0.6000, 0.6500, 0.7000, 0.7500, 0.8000, 0.8500, 0.9000, 0.9500, 1.0000],
        'spectral',
        size);
    }
    
    //----------------------------------
    // The following 34 colormaps based on color specifications and designs
    // developed by Cynthia Brewer (http://colorbrewer.org).
    // The ColorBrewer palettes have been included under the terms
    // of an Apache-stype license (for details, see the file
    // LICENSE_COLORBREWER in the license directory of the matplotlib
    // source distribution).
    //----------------------------------
    
    private static function Accent(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.4980, 0.7451, 0.9922, 1.0000, 0.2196, 0.9412, 0.7490, 0.4000],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        [0.7882, 0.6824, 0.7529, 1.0000, 0.4235, 0.0078, 0.3569, 0.4000],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        [0.4980, 0.8314, 0.5255, 0.6000, 0.6902, 0.4980, 0.0902, 0.4000],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        'Accent',
        size);
    }
    
    
    private static function Blues(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.9686, 0.8706, 0.7765, 0.6196, 0.4196, 0.2588, 0.1294, 0.0314, 0.0314],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9843, 0.9216, 0.8588, 0.7922, 0.6824, 0.5725, 0.4431, 0.3176, 0.1882],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [1.0000, 0.9686, 0.9373, 0.8824, 0.8392, 0.7765, 0.7098, 0.6118, 0.4196],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'Blues',
        size);
    }
    
    
    private static function BrBG(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.3294, 0.5490, 0.7490, 0.8745, 0.9647, 0.9608, 0.7804, 0.5020, 0.2078, 0.0039, 0.0000],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.1882, 0.3176, 0.5059, 0.7608, 0.9098, 0.9608, 0.9176, 0.8039, 0.5922, 0.4000, 0.2353],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.0196, 0.0392, 0.1765, 0.4902, 0.7647, 0.9608, 0.8980, 0.7569, 0.5608, 0.3686, 0.1882],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        'BrBG',
        size);
    }
    
    
    private static function BuGn(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.9686, 0.8980, 0.8000, 0.6000, 0.4000, 0.2549, 0.1373, 0.0000, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9882, 0.9608, 0.9255, 0.8471, 0.7608, 0.6824, 0.5451, 0.4275, 0.2667],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9922, 0.9765, 0.9020, 0.7882, 0.6431, 0.4627, 0.2706, 0.1725, 0.1059],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'BuGn',
        size);
    }
    
    
    private static function BuPu(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.9686, 0.8784, 0.7490, 0.6196, 0.5490, 0.5490, 0.5333, 0.5059, 0.3020],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9882, 0.9255, 0.8275, 0.7373, 0.5882, 0.4196, 0.2549, 0.0588, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9922, 0.9569, 0.9020, 0.8549, 0.7765, 0.6941, 0.6157, 0.4863, 0.2941],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'BuPu',
        size);
    }
    
    
    private static function Dark2(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.1059, 0.8510, 0.4588, 0.9059, 0.4000, 0.9020, 0.6510, 0.4000],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        [0.6196, 0.3725, 0.4392, 0.1608, 0.6510, 0.6706, 0.4627, 0.4000],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        [0.4667, 0.0078, 0.7020, 0.5412, 0.1176, 0.0078, 0.1137, 0.4000],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        'Dark2',
        size);
    }
    
    
    private static function GnBu(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.9686, 0.8784, 0.8000, 0.6588, 0.4824, 0.3059, 0.1686, 0.0314, 0.0314],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9882, 0.9529, 0.9216, 0.8667, 0.8000, 0.7020, 0.5490, 0.4078, 0.2510],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9412, 0.8588, 0.7725, 0.7098, 0.7686, 0.8275, 0.7451, 0.6745, 0.5059],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'GnBu',
        size);
    }
    
    
    private static function Greens(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.9686, 0.8980, 0.7804, 0.6314, 0.4549, 0.2549, 0.1373, 0.0000, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9882, 0.9608, 0.9137, 0.8510, 0.7686, 0.6706, 0.5451, 0.4275, 0.2667],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9608, 0.8784, 0.7529, 0.6078, 0.4627, 0.3647, 0.2706, 0.1725, 0.1059],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'Greens',
        size);
    }
    
    
    private static function Greys(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.9412, 0.8510, 0.7412, 0.5882, 0.4510, 0.3216, 0.1451, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [1.0000, 0.9412, 0.8510, 0.7412, 0.5882, 0.4510, 0.3216, 0.1451, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [1.0000, 0.9412, 0.8510, 0.7412, 0.5882, 0.4510, 0.3216, 0.1451, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'Greys',
        size);
    }
    
    
    private static function Oranges(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.9961, 0.9922, 0.9922, 0.9922, 0.9451, 0.8510, 0.6510, 0.4980],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9608, 0.9020, 0.8157, 0.6824, 0.5529, 0.4118, 0.2824, 0.2118, 0.1529],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9216, 0.8078, 0.6353, 0.4196, 0.2353, 0.0745, 0.0039, 0.0118, 0.0157],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'Oranges',
        size);
    }
    
    
    private static function OrRd(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.9961, 0.9922, 0.9922, 0.9882, 0.9373, 0.8431, 0.7020, 0.4980],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9686, 0.9098, 0.8314, 0.7333, 0.5529, 0.3961, 0.1882, 0.0000, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9255, 0.7843, 0.6196, 0.5176, 0.3490, 0.2824, 0.1216, 0.0000, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'OrRd',
        size);
    }
    
    
    private static function Paired(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.6510, 0.1216, 0.6980, 0.2000, 0.9843, 0.8902, 0.9922, 1.0000, 0.7922, 0.4157, 1.0000, 0.6941],
        [0.0000, 0.0909, 0.1818, 0.2727, 0.3636, 0.4545, 0.5455, 0.6364, 0.7273, 0.8182, 0.9091, 1.0000],
        [0.8078, 0.4706, 0.8745, 0.6275, 0.6039, 0.1020, 0.7490, 0.4980, 0.6980, 0.2392, 1.0000, 0.3490],
        [0.0000, 0.0909, 0.1818, 0.2727, 0.3636, 0.4545, 0.5455, 0.6364, 0.7273, 0.8182, 0.9091, 1.0000],
        [0.8902, 0.7059, 0.5412, 0.1725, 0.6000, 0.1098, 0.4353, 0.0000, 0.8392, 0.6039, 0.6000, 0.1569],
        [0.0000, 0.0909, 0.1818, 0.2727, 0.3636, 0.4545, 0.5455, 0.6364, 0.7273, 0.8182, 0.9091, 1.0000],
        'Paired',
        size);
    }
    
    
    public static function Pastel1(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.9843, 0.7020, 0.8000, 0.8706, 0.9961, 1.0000, 0.8980, 0.9922, 0.9490],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.7059, 0.8039, 0.9216, 0.7961, 0.8510, 1.0000, 0.8471, 0.8549, 0.9490],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.6824, 0.8902, 0.7725, 0.8941, 0.6510, 0.8000, 0.7412, 0.9255, 0.9490],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'Pastel1',
        size);
    }
    
    
    public static function Pastel2(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.7020, 0.9922, 0.7961, 0.9569, 0.9020, 1.0000, 0.9451, 0.8000],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        [0.8863, 0.8039, 0.8353, 0.7922, 0.9608, 0.9490, 0.8863, 0.8000],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        [0.8039, 0.6745, 0.9098, 0.8941, 0.7882, 0.6824, 0.8000, 0.8000],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        'Pastel2',
        size);
    }
    
    private static function PiYG(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.5569, 0.7725, 0.8706, 0.9451, 0.9922, 0.9686, 0.9020, 0.7216, 0.4980, 0.3020, 0.1529],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.0039, 0.1059, 0.4667, 0.7137, 0.8784, 0.9686, 0.9608, 0.8824, 0.7373, 0.5725, 0.3922],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.3216, 0.4902, 0.6824, 0.8549, 0.9373, 0.9686, 0.8157, 0.5255, 0.2549, 0.1294, 0.0980],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        'PiYG',
        size);
    }
    
    
    private static function PRGn(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.2510, 0.4627, 0.6000, 0.7608, 0.9059, 0.9686, 0.8510, 0.6510, 0.3529, 0.1059, 0.0000],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.0000, 0.1647, 0.4392, 0.6471, 0.8314, 0.9686, 0.9412, 0.8588, 0.6824, 0.4706, 0.2667],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.2941, 0.5137, 0.6706, 0.8118, 0.9098, 0.9686, 0.8275, 0.6275, 0.3804, 0.2157, 0.1059],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        'PRGn',
        size);
    }
    
    
    private static function PuBu(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.9255, 0.8157, 0.6510, 0.4549, 0.2118, 0.0196, 0.0157, 0.0078],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9686, 0.9059, 0.8196, 0.7412, 0.6627, 0.5647, 0.4392, 0.3529, 0.2196],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9843, 0.9490, 0.9020, 0.8588, 0.8118, 0.7529, 0.6902, 0.5529, 0.3451],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'PuBu',
        size);
    }
    
    
    private static function PuBuGn(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.9255, 0.8157, 0.6510, 0.4039, 0.2118, 0.0078, 0.0039, 0.0039],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9686, 0.8863, 0.8196, 0.7412, 0.6627, 0.5647, 0.5059, 0.4235, 0.2745],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9843, 0.9412, 0.9020, 0.8588, 0.8118, 0.7529, 0.5412, 0.3490, 0.2118],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'PuBuGn',
        size);
    }
    
    
    private static function PuOr(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.4980, 0.7020, 0.8784, 0.9922, 0.9961, 0.9686, 0.8471, 0.6980, 0.5020, 0.3294, 0.1765],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.2314, 0.3451, 0.5098, 0.7216, 0.8784, 0.9686, 0.8549, 0.6706, 0.4510, 0.1529, 0.0000],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.0314, 0.0235, 0.0784, 0.3882, 0.7137, 0.9686, 0.9216, 0.8235, 0.6745, 0.5333, 0.2941],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        'PuOr',
        size);
    }
    
    
    private static function PuRd(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.9686, 0.9059, 0.8314, 0.7882, 0.8745, 0.9059, 0.8078, 0.5961, 0.4039],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9569, 0.8824, 0.7255, 0.5804, 0.3961, 0.1608, 0.0706, 0.0000, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9765, 0.9373, 0.8549, 0.7804, 0.6902, 0.5412, 0.3373, 0.2627, 0.1216],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'PuRd',
        size);
    }
    
    
    private static function Purples(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.9882, 0.9373, 0.8549, 0.7373, 0.6196, 0.5020, 0.4157, 0.3294, 0.2471],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9843, 0.9294, 0.8549, 0.7412, 0.6039, 0.4902, 0.3176, 0.1529, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9922, 0.9608, 0.9216, 0.8627, 0.7843, 0.7294, 0.6392, 0.5608, 0.4902],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'Purples',
        size);
    }
    
    
    private static function RdBu(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.4039, 0.6980, 0.8392, 0.9569, 0.9922, 0.9686, 0.8196, 0.5725, 0.2627, 0.1294, 0.0196],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.0000, 0.0941, 0.3765, 0.6471, 0.8588, 0.9686, 0.8980, 0.7725, 0.5765, 0.4000, 0.1882],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.1216, 0.1686, 0.3020, 0.5098, 0.7804, 0.9686, 0.9412, 0.8706, 0.7647, 0.6745, 0.3804],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        'RdBu',
        size);
    }
    
    
    private static function RdGy(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.4039, 0.6980, 0.8392, 0.9569, 0.9922, 1.0000, 0.8784, 0.7294, 0.5294, 0.3020, 0.1020],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.0000, 0.0941, 0.3765, 0.6471, 0.8588, 1.0000, 0.8784, 0.7294, 0.5294, 0.3020, 0.1020],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.1216, 0.1686, 0.3020, 0.5098, 0.7804, 1.0000, 0.8784, 0.7294, 0.5294, 0.3020, 0.1020],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        'RdGy',
        size);
    }
    
    
    private static function RdPu(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.9922, 0.9882, 0.9804, 0.9686, 0.8667, 0.6824, 0.4784, 0.2863],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9686, 0.8784, 0.7725, 0.6235, 0.4078, 0.2039, 0.0039, 0.0039, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9529, 0.8667, 0.7529, 0.7098, 0.6314, 0.5922, 0.4941, 0.4667, 0.4157],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'RdPu',
        size);
    }
    
    
    private static function RdYlBu(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.6471, 0.8431, 0.9569, 0.9922, 0.9961, 1.0000, 0.8784, 0.6706, 0.4549, 0.2706, 0.1922],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.0000, 0.1882, 0.4275, 0.6824, 0.8784, 1.0000, 0.9529, 0.8510, 0.6784, 0.4588, 0.2118],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.1490, 0.1529, 0.2627, 0.3804, 0.5647, 0.7490, 0.9725, 0.9137, 0.8196, 0.7059, 0.5843],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        'RdYlBu',
        size);
    }
    
    
    private static function RdYlGn(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.6471, 0.8431, 0.9569, 0.9922, 0.9961, 1.0000, 0.8510, 0.6510, 0.4000, 0.1020, 0.0000],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.0000, 0.1882, 0.4275, 0.6824, 0.8784, 1.0000, 0.9373, 0.8510, 0.7412, 0.5961, 0.4078],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.1490, 0.1529, 0.2627, 0.3804, 0.5451, 0.7490, 0.5451, 0.4157, 0.3882, 0.3137, 0.2157],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        'RdYlGn',
        size);
    }
    
    
    private static function Reds(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.9961, 0.9882, 0.9882, 0.9843, 0.9373, 0.7961, 0.6471, 0.4039],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9608, 0.8784, 0.7333, 0.5725, 0.4157, 0.2314, 0.0941, 0.0588, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.9412, 0.8235, 0.6314, 0.4471, 0.2902, 0.1725, 0.1137, 0.0824, 0.0510],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'Reds',
        size);
    }
    
    
    private static function Set1(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.8941, 0.2157, 0.3020, 0.5961, 1.0000, 1.0000, 0.6510, 0.9686, 0.6000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.1020, 0.4941, 0.6863, 0.3059, 0.4980, 1.0000, 0.3373, 0.5059, 0.6000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.1098, 0.7216, 0.2902, 0.6392, 0.0000, 0.2000, 0.1569, 0.7490, 0.6000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'Set1',
        size);
    }
    
    
    private static function Set2(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.4000, 0.9882, 0.5529, 0.9059, 0.6510, 1.0000, 0.8980, 0.7020],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        [0.7608, 0.5529, 0.6275, 0.5412, 0.8471, 0.8510, 0.7686, 0.7020],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        [0.6471, 0.3843, 0.7961, 0.7647, 0.3294, 0.1843, 0.5804, 0.7020],
        [0.0000, 0.1429, 0.2857, 0.4286, 0.5714, 0.7143, 0.8571, 1.0000],
        'Set2',
        size);
    }
    
    
    private static function Set3(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.5529, 1.0000, 0.7451, 0.9843, 0.5020, 0.9922, 0.7020, 0.9882, 0.8510, 0.7373, 0.8000, 1.0000],
        [0.0000, 0.0909, 0.1818, 0.2727, 0.3636, 0.4545, 0.5455, 0.6364, 0.7273, 0.8182, 0.9091, 1.0000],
        [0.8275, 1.0000, 0.7294, 0.5020, 0.6941, 0.7059, 0.8706, 0.8039, 0.8510, 0.5020, 0.9216, 0.9294],
        [0.0000, 0.0909, 0.1818, 0.2727, 0.3636, 0.4545, 0.5455, 0.6364, 0.7273, 0.8182, 0.9091, 1.0000],
        [0.7804, 0.7020, 0.8549, 0.4471, 0.8275, 0.3843, 0.4118, 0.8980, 0.8510, 0.7412, 0.7725, 0.4353],
        [0.0000, 0.0909, 0.1818, 0.2727, 0.3636, 0.4545, 0.5455, 0.6364, 0.7273, 0.8182, 0.9091, 1.0000],
        'Set3',
        size);
    }
    
    
    private static function Spectral(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.6196, 0.8353, 0.9569, 0.9922, 0.9961, 1.0000, 0.9020, 0.6706, 0.4000, 0.1961, 0.3686],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.0039, 0.2431, 0.4275, 0.6824, 0.8784, 1.0000, 0.9608, 0.8667, 0.7608, 0.5333, 0.3098],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        [0.2588, 0.3098, 0.2627, 0.3804, 0.5451, 0.7490, 0.5961, 0.6431, 0.6471, 0.7412, 0.6353],
        [0.0000, 0.1000, 0.2000, 0.3000, 0.4000, 0.5000, 0.6000, 0.7000, 0.8000, 0.9000, 1.0000],
        'Spectral',
        size);
    }
    
    
    private static function YlGn(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.9686, 0.8510, 0.6784, 0.4706, 0.2549, 0.1373, 0.0000, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [1.0000, 0.9882, 0.9412, 0.8667, 0.7765, 0.6706, 0.5176, 0.4078, 0.2706],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.8980, 0.7255, 0.6392, 0.5569, 0.4745, 0.3647, 0.2627, 0.2157, 0.1608],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'YlGn',
        size);
    }
    
    
    private static function YlGnBu(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.9294, 0.7804, 0.4980, 0.2549, 0.1137, 0.1333, 0.1451, 0.0314],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [1.0000, 0.9725, 0.9137, 0.8039, 0.7137, 0.5686, 0.3686, 0.2039, 0.1137],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.8510, 0.6941, 0.7059, 0.7333, 0.7686, 0.7529, 0.6588, 0.5804, 0.3451],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'YlGnBu',
        size);
    }
    
    
    private static function YlOrBr(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 1.0000, 0.9961, 0.9961, 0.9961, 0.9255, 0.8000, 0.6000, 0.4000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [1.0000, 0.9686, 0.8902, 0.7686, 0.6000, 0.4392, 0.2980, 0.2039, 0.1451],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.8980, 0.7373, 0.5686, 0.3098, 0.1608, 0.0784, 0.0078, 0.0157, 0.0235],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'YlOrBr',
        size);
    }
    
    
    private static function YlOrRd(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 1.0000, 0.9961, 0.9961, 0.9922, 0.9882, 0.8902, 0.7412, 0.5020],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [1.0000, 0.9294, 0.8510, 0.6980, 0.5529, 0.3059, 0.1020, 0.0000, 0.0000],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        [0.8000, 0.6275, 0.4627, 0.2980, 0.2353, 0.1647, 0.1098, 0.1490, 0.1490],
        [0.0000, 0.1250, 0.2500, 0.3750, 0.5000, 0.6250, 0.7500, 0.8750, 1.0000],
        'YlOrRd',
        size);
    }
    
    
    private static function gist_earth(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0039, 0.0078, 0.0078, 0.0118, 0.0157, 0.0196, 0.0196, 0.0235, 0.0275, 0.0314, 0.0314, 0.0353, 0.0392, 0.0431, 0.0431, 0.0471, 0.0510, 0.0549, 0.0588, 0.0588, 0.0627, 0.0667, 0.0706, 0.0706, 0.0745, 0.0784, 0.0824, 0.0863, 0.0863, 0.0902, 0.0941, 0.0980, 0.1020, 0.1020, 0.1059, 0.1098, 0.1137, 0.1176, 0.1216, 0.1216, 0.1255, 0.1294, 0.1333, 0.1373, 0.1412, 0.1412, 0.1451, 0.1490, 0.1529, 0.1569, 0.1608, 0.1608, 0.1647, 0.1686, 0.1725, 0.1765, 0.1804, 0.1843, 0.1882, 0.1882, 0.1882, 0.1922, 0.1922, 0.1961, 0.1961, 0.2000, 0.2000, 0.2039, 0.2039, 0.2078, 0.2078, 0.2118, 0.2118, 0.2157, 0.2157, 0.2196, 0.2196, 0.2235, 0.2235, 0.2275, 0.2275, 0.2314, 0.2314, 0.2353, 0.2392, 0.2392, 0.2431, 0.2431, 0.2471, 0.2471, 0.2510, 0.2510, 0.2549, 0.2549, 0.2588, 0.2627, 0.2627, 0.2667, 0.2667, 0.2706, 0.2706, 0.2745, 0.2784, 0.2863, 0.2980, 0.3059, 0.3176, 0.3255, 0.3373, 0.3451, 0.3569, 0.3686, 0.3765, 0.3882, 0.3961, 0.4078, 0.4157, 0.4275, 0.4353, 0.4471, 0.4588, 0.4667, 0.4745, 0.4784, 0.4863, 0.4941, 0.5020, 0.5059, 0.5137, 0.5216, 0.5294, 0.5333, 0.5412, 0.5490, 0.5529, 0.5608, 0.5686, 0.5765, 0.5843, 0.5882, 0.5961, 0.6039, 0.6118, 0.6157, 0.6235, 0.6314, 0.6392, 0.6471, 0.6510, 0.6588, 0.6667, 0.6745, 0.6824, 0.6863, 0.6941, 0.7020, 0.7098, 0.7176, 0.7176, 0.7216, 0.7216, 0.7255, 0.7255, 0.7294, 0.7294, 0.7333, 0.7333, 0.7333, 0.7373, 0.7373, 0.7412, 0.7412, 0.7451, 0.7451, 0.7451, 0.7490, 0.7490, 0.7529, 0.7529, 0.7569, 0.7647, 0.7686, 0.7725, 0.7765, 0.7804, 0.7882, 0.7922, 0.7961, 0.8000, 0.8039, 0.8118, 0.8157, 0.8196, 0.8235, 0.8275, 0.8353, 0.8392, 0.8431, 0.8471, 0.8510, 0.8588, 0.8627, 0.8667, 0.8706, 0.8745, 0.8824, 0.8863, 0.8902, 0.8941, 0.8980, 0.9059, 0.9098, 0.9137, 0.9176, 0.9216, 0.9294, 0.9333, 0.9373, 0.9412, 0.9451, 0.9529, 0.9569, 0.9608, 0.9647, 0.9686, 0.9765, 0.9804, 0.9843, 0.9882, 0.9922],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0118, 0.0235, 0.0314, 0.0431, 0.0510, 0.0627, 0.0706, 0.0824, 0.0902, 0.1020, 0.1098, 0.1216, 0.1294, 0.1412, 0.1490, 0.1608, 0.1686, 0.1765, 0.1882, 0.1961, 0.2039, 0.2157, 0.2235, 0.2314, 0.2392, 0.2510, 0.2588, 0.2667, 0.2745, 0.2824, 0.2902, 0.3020, 0.3098, 0.3176, 0.3255, 0.3333, 0.3412, 0.3490, 0.3569, 0.3647, 0.3725, 0.3804, 0.3882, 0.3922, 0.4000, 0.4078, 0.4157, 0.4235, 0.4275, 0.4353, 0.4431, 0.4510, 0.4549, 0.4627, 0.4706, 0.4745, 0.4824, 0.4902, 0.4941, 0.5020, 0.5020, 0.5059, 0.5059, 0.5098, 0.5137, 0.5137, 0.5176, 0.5216, 0.5216, 0.5255, 0.5255, 0.5294, 0.5333, 0.5333, 0.5373, 0.5412, 0.5412, 0.5451, 0.5490, 0.5490, 0.5529, 0.5529, 0.5569, 0.5608, 0.5608, 0.5647, 0.5686, 0.5686, 0.5725, 0.5725, 0.5765, 0.5804, 0.5804, 0.5843, 0.5882, 0.5882, 0.5922, 0.5922, 0.5961, 0.6000, 0.6000, 0.6039, 0.6078, 0.6078, 0.6118, 0.6118, 0.6157, 0.6196, 0.6196, 0.6235, 0.6275, 0.6275, 0.6314, 0.6314, 0.6353, 0.6392, 0.6392, 0.6431, 0.6471, 0.6471, 0.6510, 0.6510, 0.6549, 0.6588, 0.6588, 0.6588, 0.6627, 0.6627, 0.6667, 0.6667, 0.6706, 0.6706, 0.6745, 0.6745, 0.6745, 0.6784, 0.6784, 0.6824, 0.6824, 0.6863, 0.6863, 0.6863, 0.6902, 0.6902, 0.6941, 0.6941, 0.6980, 0.6980, 0.7020, 0.7020, 0.7020, 0.7059, 0.7059, 0.7098, 0.7098, 0.7137, 0.7137, 0.7176, 0.7176, 0.7137, 0.7098, 0.7098, 0.7059, 0.7020, 0.6980, 0.6941, 0.6902, 0.6863, 0.6824, 0.6784, 0.6745, 0.6706, 0.6667, 0.6627, 0.6588, 0.6549, 0.6510, 0.6471, 0.6431, 0.6392, 0.6392, 0.6431, 0.6431, 0.6471, 0.6471, 0.6510, 0.6549, 0.6549, 0.6588, 0.6627, 0.6667, 0.6706, 0.6745, 0.6784, 0.6824, 0.6863, 0.6902, 0.6941, 0.6980, 0.7020, 0.7098, 0.7137, 0.7216, 0.7255, 0.7333, 0.7373, 0.7451, 0.7529, 0.7608, 0.7686, 0.7765, 0.7843, 0.7922, 0.8000, 0.8078, 0.8157, 0.8275, 0.8353, 0.8431, 0.8549, 0.8667, 0.8745, 0.8863, 0.8980, 0.9098, 0.9216, 0.9333, 0.9451, 0.9569, 0.9725, 0.9843],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [0.0000, 0.1804, 0.2275, 0.2706, 0.3176, 0.3608, 0.4078, 0.4549, 0.4549, 0.4549, 0.4549, 0.4549, 0.4588, 0.4588, 0.4588, 0.4588, 0.4588, 0.4627, 0.4627, 0.4627, 0.4627, 0.4627, 0.4667, 0.4667, 0.4667, 0.4667, 0.4667, 0.4706, 0.4706, 0.4706, 0.4706, 0.4706, 0.4745, 0.4745, 0.4745, 0.4745, 0.4745, 0.4784, 0.4784, 0.4784, 0.4784, 0.4784, 0.4824, 0.4824, 0.4824, 0.4824, 0.4824, 0.4863, 0.4863, 0.4863, 0.4863, 0.4863, 0.4902, 0.4902, 0.4902, 0.4902, 0.4902, 0.4941, 0.4941, 0.4941, 0.4941, 0.4941, 0.4980, 0.4980, 0.4980, 0.4980, 0.4980, 0.5020, 0.4941, 0.4902, 0.4863, 0.4824, 0.4784, 0.4706, 0.4667, 0.4627, 0.4588, 0.4510, 0.4471, 0.4431, 0.4353, 0.4314, 0.4275, 0.4235, 0.4157, 0.4118, 0.4078, 0.4000, 0.3961, 0.3922, 0.3843, 0.3804, 0.3765, 0.3686, 0.3647, 0.3608, 0.3529, 0.3490, 0.3451, 0.3373, 0.3333, 0.3294, 0.3216, 0.3176, 0.3137, 0.3059, 0.3020, 0.2980, 0.2902, 0.2863, 0.2784, 0.2745, 0.2784, 0.2824, 0.2824, 0.2863, 0.2863, 0.2902, 0.2941, 0.2941, 0.2980, 0.2980, 0.3020, 0.3020, 0.3059, 0.3098, 0.3098, 0.3137, 0.3137, 0.3176, 0.3216, 0.3216, 0.3216, 0.3255, 0.3255, 0.3255, 0.3294, 0.3294, 0.3294, 0.3333, 0.3333, 0.3333, 0.3373, 0.3373, 0.3373, 0.3412, 0.3412, 0.3412, 0.3451, 0.3451, 0.3451, 0.3490, 0.3490, 0.3490, 0.3529, 0.3529, 0.3529, 0.3569, 0.3569, 0.3569, 0.3608, 0.3608, 0.3608, 0.3647, 0.3647, 0.3647, 0.3686, 0.3686, 0.3686, 0.3725, 0.3725, 0.3725, 0.3765, 0.3765, 0.3804, 0.3804, 0.3804, 0.3843, 0.3843, 0.3843, 0.3882, 0.3882, 0.3882, 0.3922, 0.3922, 0.3922, 0.3961, 0.3961, 0.4078, 0.4157, 0.4235, 0.4353, 0.4431, 0.4549, 0.4627, 0.4745, 0.4824, 0.4941, 0.5059, 0.5137, 0.5255, 0.5373, 0.5451, 0.5569, 0.5686, 0.5804, 0.5882, 0.6000, 0.6118, 0.6235, 0.6353, 0.6471, 0.6588, 0.6667, 0.6784, 0.6902, 0.7020, 0.7137, 0.7255, 0.7412, 0.7529, 0.7647, 0.7765, 0.7882, 0.8000, 0.8118, 0.8275, 0.8392, 0.8510, 0.8627, 0.8784, 0.8902, 0.9020, 0.9176, 0.9294, 0.9451, 0.9569, 0.9725, 0.9843],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        'gist_earth',
        size);
    }
    
    
    private static function gist_gray(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 0.0039, 0.0078, 0.0118, 0.0157, 0.0196, 0.0235, 0.0275, 0.0353, 0.0392, 0.0431, 0.0471, 0.0510, 0.0549, 0.0588, 0.0627, 0.0667, 0.0706, 0.0745, 0.0784, 0.0824, 0.0863, 0.0902, 0.0980, 0.1020, 0.1059, 0.1098, 0.1137, 0.1176, 0.1216, 0.1255, 0.1294, 0.1333, 0.1373, 0.1412, 0.1451, 0.1490, 0.1529, 0.1608, 0.1647, 0.1686, 0.1725, 0.1765, 0.1804, 0.1843, 0.1882, 0.1922, 0.1961, 0.2000, 0.2039, 0.2078, 0.2118, 0.2157, 0.2235, 0.2275, 0.2314, 0.2353, 0.2392, 0.2431, 0.2471, 0.2510, 0.2549, 0.2588, 0.2627, 0.2667, 0.2706, 0.2745, 0.2784, 0.2863, 0.2902, 0.2941, 0.2980, 0.3020, 0.3059, 0.3098, 0.3137, 0.3176, 0.3216, 0.3255, 0.3294, 0.3333, 0.3373, 0.3412, 0.3490, 0.3529, 0.3569, 0.3608, 0.3647, 0.3686, 0.3725, 0.3765, 0.3804, 0.3843, 0.3882, 0.3922, 0.3961, 0.4000, 0.4039, 0.4118, 0.4157, 0.4196, 0.4235, 0.4275, 0.4314, 0.4353, 0.4392, 0.4431, 0.4471, 0.4510, 0.4549, 0.4588, 0.4627, 0.4667, 0.4745, 0.4784, 0.4824, 0.4863, 0.4902, 0.4941, 0.4980, 0.5020, 0.5059, 0.5098, 0.5137, 0.5176, 0.5216, 0.5255, 0.5294, 0.5373, 0.5412, 0.5451, 0.5490, 0.5529, 0.5569, 0.5608, 0.5647, 0.5686, 0.5725, 0.5765, 0.5804, 0.5843, 0.5882, 0.5922, 0.6000, 0.6039, 0.6078, 0.6118, 0.6157, 0.6196, 0.6235, 0.6275, 0.6314, 0.6353, 0.6392, 0.6431, 0.6471, 0.6510, 0.6549, 0.6627, 0.6667, 0.6706, 0.6745, 0.6784, 0.6824, 0.6863, 0.6902, 0.6941, 0.6980, 0.7020, 0.7059, 0.7098, 0.7137, 0.7176, 0.7255, 0.7294, 0.7333, 0.7373, 0.7412, 0.7451, 0.7490, 0.7529, 0.7569, 0.7608, 0.7647, 0.7686, 0.7725, 0.7765, 0.7804, 0.7882, 0.7922, 0.7961, 0.8000, 0.8039, 0.8078, 0.8118, 0.8157, 0.8196, 0.8235, 0.8275, 0.8314, 0.8353, 0.8392, 0.8431, 0.8510, 0.8549, 0.8588, 0.8627, 0.8667, 0.8706, 0.8745, 0.8784, 0.8824, 0.8863, 0.8902, 0.8941, 0.8980, 0.9020, 0.9059, 0.9137, 0.9176, 0.9216, 0.9255, 0.9294, 0.9333, 0.9373, 0.9412, 0.9451, 0.9490, 0.9529, 0.9569, 0.9608, 0.9647, 0.9686, 0.9765, 0.9804, 0.9843, 0.9882, 0.9922, 0.9961],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [0.0000, 0.0039, 0.0078, 0.0118, 0.0157, 0.0196, 0.0235, 0.0275, 0.0353, 0.0392, 0.0431, 0.0471, 0.0510, 0.0549, 0.0588, 0.0627, 0.0667, 0.0706, 0.0745, 0.0784, 0.0824, 0.0863, 0.0902, 0.0980, 0.1020, 0.1059, 0.1098, 0.1137, 0.1176, 0.1216, 0.1255, 0.1294, 0.1333, 0.1373, 0.1412, 0.1451, 0.1490, 0.1529, 0.1608, 0.1647, 0.1686, 0.1725, 0.1765, 0.1804, 0.1843, 0.1882, 0.1922, 0.1961, 0.2000, 0.2039, 0.2078, 0.2118, 0.2157, 0.2235, 0.2275, 0.2314, 0.2353, 0.2392, 0.2431, 0.2471, 0.2510, 0.2549, 0.2588, 0.2627, 0.2667, 0.2706, 0.2745, 0.2784, 0.2863, 0.2902, 0.2941, 0.2980, 0.3020, 0.3059, 0.3098, 0.3137, 0.3176, 0.3216, 0.3255, 0.3294, 0.3333, 0.3373, 0.3412, 0.3490, 0.3529, 0.3569, 0.3608, 0.3647, 0.3686, 0.3725, 0.3765, 0.3804, 0.3843, 0.3882, 0.3922, 0.3961, 0.4000, 0.4039, 0.4118, 0.4157, 0.4196, 0.4235, 0.4275, 0.4314, 0.4353, 0.4392, 0.4431, 0.4471, 0.4510, 0.4549, 0.4588, 0.4627, 0.4667, 0.4745, 0.4784, 0.4824, 0.4863, 0.4902, 0.4941, 0.4980, 0.5020, 0.5059, 0.5098, 0.5137, 0.5176, 0.5216, 0.5255, 0.5294, 0.5373, 0.5412, 0.5451, 0.5490, 0.5529, 0.5569, 0.5608, 0.5647, 0.5686, 0.5725, 0.5765, 0.5804, 0.5843, 0.5882, 0.5922, 0.6000, 0.6039, 0.6078, 0.6118, 0.6157, 0.6196, 0.6235, 0.6275, 0.6314, 0.6353, 0.6392, 0.6431, 0.6471, 0.6510, 0.6549, 0.6627, 0.6667, 0.6706, 0.6745, 0.6784, 0.6824, 0.6863, 0.6902, 0.6941, 0.6980, 0.7020, 0.7059, 0.7098, 0.7137, 0.7176, 0.7255, 0.7294, 0.7333, 0.7373, 0.7412, 0.7451, 0.7490, 0.7529, 0.7569, 0.7608, 0.7647, 0.7686, 0.7725, 0.7765, 0.7804, 0.7882, 0.7922, 0.7961, 0.8000, 0.8039, 0.8078, 0.8118, 0.8157, 0.8196, 0.8235, 0.8275, 0.8314, 0.8353, 0.8392, 0.8431, 0.8510, 0.8549, 0.8588, 0.8627, 0.8667, 0.8706, 0.8745, 0.8784, 0.8824, 0.8863, 0.8902, 0.8941, 0.8980, 0.9020, 0.9059, 0.9137, 0.9176, 0.9216, 0.9255, 0.9294, 0.9333, 0.9373, 0.9412, 0.9451, 0.9490, 0.9529, 0.9569, 0.9608, 0.9647, 0.9686, 0.9765, 0.9804, 0.9843, 0.9882, 0.9922, 0.9961],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [0.0000, 0.0039, 0.0078, 0.0118, 0.0157, 0.0196, 0.0235, 0.0275, 0.0353, 0.0392, 0.0431, 0.0471, 0.0510, 0.0549, 0.0588, 0.0627, 0.0667, 0.0706, 0.0745, 0.0784, 0.0824, 0.0863, 0.0902, 0.0980, 0.1020, 0.1059, 0.1098, 0.1137, 0.1176, 0.1216, 0.1255, 0.1294, 0.1333, 0.1373, 0.1412, 0.1451, 0.1490, 0.1529, 0.1608, 0.1647, 0.1686, 0.1725, 0.1765, 0.1804, 0.1843, 0.1882, 0.1922, 0.1961, 0.2000, 0.2039, 0.2078, 0.2118, 0.2157, 0.2235, 0.2275, 0.2314, 0.2353, 0.2392, 0.2431, 0.2471, 0.2510, 0.2549, 0.2588, 0.2627, 0.2667, 0.2706, 0.2745, 0.2784, 0.2863, 0.2902, 0.2941, 0.2980, 0.3020, 0.3059, 0.3098, 0.3137, 0.3176, 0.3216, 0.3255, 0.3294, 0.3333, 0.3373, 0.3412, 0.3490, 0.3529, 0.3569, 0.3608, 0.3647, 0.3686, 0.3725, 0.3765, 0.3804, 0.3843, 0.3882, 0.3922, 0.3961, 0.4000, 0.4039, 0.4118, 0.4157, 0.4196, 0.4235, 0.4275, 0.4314, 0.4353, 0.4392, 0.4431, 0.4471, 0.4510, 0.4549, 0.4588, 0.4627, 0.4667, 0.4745, 0.4784, 0.4824, 0.4863, 0.4902, 0.4941, 0.4980, 0.5020, 0.5059, 0.5098, 0.5137, 0.5176, 0.5216, 0.5255, 0.5294, 0.5373, 0.5412, 0.5451, 0.5490, 0.5529, 0.5569, 0.5608, 0.5647, 0.5686, 0.5725, 0.5765, 0.5804, 0.5843, 0.5882, 0.5922, 0.6000, 0.6039, 0.6078, 0.6118, 0.6157, 0.6196, 0.6235, 0.6275, 0.6314, 0.6353, 0.6392, 0.6431, 0.6471, 0.6510, 0.6549, 0.6627, 0.6667, 0.6706, 0.6745, 0.6784, 0.6824, 0.6863, 0.6902, 0.6941, 0.6980, 0.7020, 0.7059, 0.7098, 0.7137, 0.7176, 0.7255, 0.7294, 0.7333, 0.7373, 0.7412, 0.7451, 0.7490, 0.7529, 0.7569, 0.7608, 0.7647, 0.7686, 0.7725, 0.7765, 0.7804, 0.7882, 0.7922, 0.7961, 0.8000, 0.8039, 0.8078, 0.8118, 0.8157, 0.8196, 0.8235, 0.8275, 0.8314, 0.8353, 0.8392, 0.8431, 0.8510, 0.8549, 0.8588, 0.8627, 0.8667, 0.8706, 0.8745, 0.8784, 0.8824, 0.8863, 0.8902, 0.8941, 0.8980, 0.9020, 0.9059, 0.9137, 0.9176, 0.9216, 0.9255, 0.9294, 0.9333, 0.9373, 0.9412, 0.9451, 0.9490, 0.9529, 0.9569, 0.9608, 0.9647, 0.9686, 0.9765, 0.9804, 0.9843, 0.9882, 0.9922, 0.9961],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        'gist_gray',
        size);
    }
    
    
    private static function gist_heat(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 0.0039, 0.0078, 0.0157, 0.0196, 0.0275, 0.0314, 0.0392, 0.0431, 0.0510, 0.0588, 0.0667, 0.0706, 0.0784, 0.0824, 0.0902, 0.0941, 0.1020, 0.1059, 0.1098, 0.1176, 0.1216, 0.1294, 0.1333, 0.1412, 0.1451, 0.1529, 0.1569, 0.1647, 0.1686, 0.1804, 0.1843, 0.1922, 0.1961, 0.2039, 0.2078, 0.2157, 0.2196, 0.2235, 0.2314, 0.2353, 0.2431, 0.2471, 0.2549, 0.2588, 0.2667, 0.2706, 0.2745, 0.2824, 0.2863, 0.2980, 0.3059, 0.3098, 0.3176, 0.3216, 0.3294, 0.3333, 0.3373, 0.3451, 0.3490, 0.3608, 0.3686, 0.3725, 0.3804, 0.3843, 0.3882, 0.3961, 0.4000, 0.4078, 0.4118, 0.4235, 0.4314, 0.4353, 0.4431, 0.4471, 0.4510, 0.4588, 0.4627, 0.4706, 0.4745, 0.4824, 0.4863, 0.4941, 0.4980, 0.5020, 0.5098, 0.5137, 0.5216, 0.5255, 0.5333, 0.5451, 0.5490, 0.5529, 0.5608, 0.5647, 0.5725, 0.5765, 0.5843, 0.5882, 0.5961, 0.6000, 0.6078, 0.6118, 0.6157, 0.6235, 0.6275, 0.6353, 0.6392, 0.6471, 0.6510, 0.6627, 0.6667, 0.6745, 0.6784, 0.6863, 0.6902, 0.6980, 0.7020, 0.7098, 0.7137, 0.7255, 0.7294, 0.7373, 0.7412, 0.7490, 0.7529, 0.7608, 0.7647, 0.7725, 0.7765, 0.7882, 0.7922, 0.8000, 0.8039, 0.8118, 0.8157, 0.8235, 0.8275, 0.8314, 0.8392, 0.8431, 0.8510, 0.8549, 0.8627, 0.8667, 0.8745, 0.8784, 0.8863, 0.8902, 0.8941, 0.9059, 0.9137, 0.9176, 0.9255, 0.9294, 0.9373, 0.9412, 0.9451, 0.9529, 0.9569, 0.9647, 0.9686, 0.9765, 0.9804, 0.9882, 0.9922, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0039, 0.0118, 0.0196, 0.0275, 0.0353, 0.0431, 0.0588, 0.0667, 0.0706, 0.0784, 0.0863, 0.0941, 0.1020, 0.1098, 0.1176, 0.1255, 0.1373, 0.1451, 0.1529, 0.1608, 0.1686, 0.1765, 0.1843, 0.1922, 0.2000, 0.2039, 0.2118, 0.2196, 0.2275, 0.2353, 0.2431, 0.2510, 0.2588, 0.2667, 0.2706, 0.2784, 0.2941, 0.3020, 0.3098, 0.3176, 0.3255, 0.3333, 0.3373, 0.3451, 0.3529, 0.3608, 0.3686, 0.3765, 0.3843, 0.3922, 0.4000, 0.4039, 0.4118, 0.4196, 0.4275, 0.4353, 0.4510, 0.4588, 0.4667, 0.4706, 0.4784, 0.4863, 0.4941, 0.5020, 0.5098, 0.5176, 0.5333, 0.5373, 0.5451, 0.5529, 0.5608, 0.5686, 0.5765, 0.5843, 0.5922, 0.6000, 0.6118, 0.6196, 0.6275, 0.6353, 0.6431, 0.6510, 0.6588, 0.6667, 0.6706, 0.6784, 0.6863, 0.6941, 0.7020, 0.7098, 0.7176, 0.7255, 0.7333, 0.7373, 0.7451, 0.7529, 0.7686, 0.7765, 0.7843, 0.7922, 0.8000, 0.8039, 0.8118, 0.8196, 0.8275, 0.8353, 0.8431, 0.8510, 0.8588, 0.8667, 0.8706, 0.8784, 0.8863, 0.8941, 0.9020, 0.9098, 0.9255, 0.9333, 0.9373, 0.9451, 0.9529, 0.9608, 0.9686, 0.9765, 0.9843],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0275, 0.0431, 0.0588, 0.0745, 0.0902, 0.1059, 0.1216, 0.1373, 0.1529, 0.1686, 0.2000, 0.2118, 0.2275, 0.2431, 0.2588, 0.2745, 0.2902, 0.3059, 0.3216, 0.3373, 0.3529, 0.3686, 0.3843, 0.4000, 0.4118, 0.4275, 0.4431, 0.4588, 0.4745, 0.4902, 0.5216, 0.5373, 0.5529, 0.5686, 0.5843, 0.6000, 0.6118, 0.6275, 0.6431, 0.6588, 0.6745, 0.6902, 0.7059, 0.7216, 0.7373, 0.7529, 0.7686, 0.7843, 0.8000, 0.8118, 0.8431, 0.8588, 0.8745, 0.8902, 0.9059, 0.9216, 0.9373, 0.9529, 0.9686],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        'gist_heat',
        size);
    }
    
    
    private static function gist_ncar(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0039, 0.0431, 0.0824, 0.1176, 0.1569, 0.1961, 0.2314, 0.2706, 0.3098, 0.3490, 0.3843, 0.4039, 0.4157, 0.4235, 0.4314, 0.4431, 0.4510, 0.4588, 0.4706, 0.4784, 0.4902, 0.5020, 0.5255, 0.5490, 0.5725, 0.6000, 0.6235, 0.6471, 0.6706, 0.6941, 0.7216, 0.7451, 0.7686, 0.7922, 0.8157, 0.8392, 0.8627, 0.8863, 0.9098, 0.9333, 0.9569, 0.9804, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 0.9647, 0.9255, 0.8902, 0.8510, 0.8157, 0.7765, 0.7412, 0.7020, 0.6667, 0.6275, 0.6196, 0.6510, 0.6824, 0.7137, 0.7451, 0.7725, 0.8039, 0.8353, 0.8667, 0.8980, 0.9294, 0.9333, 0.9373, 0.9373, 0.9412, 0.9451, 0.9451, 0.9490, 0.9529, 0.9529, 0.9569, 0.9608, 0.9647, 0.9686, 0.9725, 0.9765, 0.9804, 0.9843, 0.9882, 0.9922, 0.9961],
        [0.0000, 0.0051, 0.0101, 0.0152, 0.0202, 0.0253, 0.0303, 0.0354, 0.0404, 0.0455, 0.0505, 0.0556, 0.0606, 0.0657, 0.0707, 0.0758, 0.0808, 0.0859, 0.0909, 0.0960, 0.1010, 0.1061, 0.1111, 0.1162, 0.1212, 0.1263, 0.1313, 0.1364, 0.1414, 0.1465, 0.1515, 0.1566, 0.1616, 0.1667, 0.1717, 0.1768, 0.1818, 0.1869, 0.1919, 0.1970, 0.2020, 0.2071, 0.2121, 0.2172, 0.2222, 0.2273, 0.2323, 0.2374, 0.2424, 0.2475, 0.2525, 0.2576, 0.2626, 0.2677, 0.2727, 0.2778, 0.2828, 0.2879, 0.2929, 0.2980, 0.3030, 0.3081, 0.3131, 0.3182, 0.3232, 0.3283, 0.3333, 0.3384, 0.3434, 0.3485, 0.3535, 0.3586, 0.3636, 0.3687, 0.3737, 0.3788, 0.3838, 0.3889, 0.3939, 0.3990, 0.4040, 0.4091, 0.4141, 0.4192, 0.4242, 0.4293, 0.4343, 0.4394, 0.4444, 0.4495, 0.4545, 0.4596, 0.4646, 0.4697, 0.4747, 0.4798, 0.4848, 0.4899, 0.4949, 0.5000, 0.5051, 0.5101, 0.5152, 0.5202, 0.5253, 0.5303, 0.5354, 0.5404, 0.5455, 0.5505, 0.5556, 0.5606, 0.5657, 0.5707, 0.5758, 0.5808, 0.5859, 0.5909, 0.5960, 0.6010, 0.6061, 0.6111, 0.6162, 0.6212, 0.6263, 0.6313, 0.6364, 0.6414, 0.6465, 0.6515, 0.6566, 0.6616, 0.6667, 0.6717, 0.6768, 0.6818, 0.6869, 0.6919, 0.6970, 0.7020, 0.7071, 0.7121, 0.7172, 0.7222, 0.7273, 0.7323, 0.7374, 0.7424, 0.7475, 0.7525, 0.7576, 0.7626, 0.7677, 0.7727, 0.7778, 0.7828, 0.7879, 0.7929, 0.7980, 0.8030, 0.8081, 0.8131, 0.8182, 0.8232, 0.8283, 0.8333, 0.8384, 0.8434, 0.8485, 0.8535, 0.8586, 0.8636, 0.8687, 0.8737, 0.8788, 0.8838, 0.8889, 0.8939, 0.8990, 0.9040, 0.9091, 0.9141, 0.9192, 0.9242, 0.9293, 0.9343, 0.9394, 0.9444, 0.9495, 0.9545, 0.9596, 0.9646, 0.9697, 0.9747, 0.9798, 0.9848, 0.9899, 0.9949, 1.0000],
        [0.0000, 0.0353, 0.0745, 0.1098, 0.1490, 0.1843, 0.2235, 0.2588, 0.2980, 0.3333, 0.3725, 0.3686, 0.3333, 0.2941, 0.2588, 0.2196, 0.1843, 0.1451, 0.1098, 0.0706, 0.0353, 0.0000, 0.0745, 0.1451, 0.2157, 0.2863, 0.3608, 0.4314, 0.5020, 0.5725, 0.6471, 0.7176, 0.7608, 0.7843, 0.8078, 0.8314, 0.8549, 0.8824, 0.9059, 0.9294, 0.9529, 0.9765, 0.9961, 0.9961, 0.9922, 0.9922, 0.9922, 0.9882, 0.9882, 0.9843, 0.9843, 0.9804, 0.9804, 0.9804, 0.9804, 0.9843, 0.9843, 0.9882, 0.9882, 0.9922, 0.9922, 0.9961, 0.9961, 0.9961, 0.9765, 0.9569, 0.9373, 0.9216, 0.9020, 0.8824, 0.8627, 0.8471, 0.8275, 0.8078, 0.8157, 0.8353, 0.8510, 0.8706, 0.8902, 0.9098, 0.9255, 0.9451, 0.9647, 0.9843, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 0.9922, 0.9804, 0.9647, 0.9490, 0.9333, 0.9176, 0.9059, 0.8902, 0.8745, 0.8588, 0.8431, 0.8314, 0.8196, 0.8118, 0.8000, 0.7882, 0.7765, 0.7647, 0.7529, 0.7412, 0.7294, 0.7098, 0.6667, 0.6235, 0.5804, 0.5373, 0.4941, 0.4510, 0.4039, 0.3608, 0.3176, 0.2745, 0.2471, 0.2196, 0.1961, 0.1686, 0.1451, 0.1176, 0.0902, 0.0667, 0.0392, 0.0157, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0157, 0.0314, 0.0510, 0.0667, 0.0863, 0.1059, 0.1216, 0.1412, 0.1569, 0.1765, 0.2000, 0.2314, 0.2588, 0.2902, 0.3216, 0.3529, 0.3843, 0.4157, 0.4431, 0.4745, 0.5059, 0.5294, 0.5529, 0.5725, 0.5961, 0.6196, 0.6431, 0.6627, 0.6863, 0.7098, 0.7294, 0.7529, 0.7804, 0.8039, 0.8275, 0.8510, 0.8745, 0.9020, 0.9255, 0.9490, 0.9725],
        [0.0000, 0.0051, 0.0101, 0.0152, 0.0202, 0.0253, 0.0303, 0.0354, 0.0404, 0.0455, 0.0505, 0.0556, 0.0606, 0.0657, 0.0707, 0.0758, 0.0808, 0.0859, 0.0909, 0.0960, 0.1010, 0.1061, 0.1111, 0.1162, 0.1212, 0.1263, 0.1313, 0.1364, 0.1414, 0.1465, 0.1515, 0.1566, 0.1616, 0.1667, 0.1717, 0.1768, 0.1818, 0.1869, 0.1919, 0.1970, 0.2020, 0.2071, 0.2121, 0.2172, 0.2222, 0.2273, 0.2323, 0.2374, 0.2424, 0.2475, 0.2525, 0.2576, 0.2626, 0.2677, 0.2727, 0.2778, 0.2828, 0.2879, 0.2929, 0.2980, 0.3030, 0.3081, 0.3131, 0.3182, 0.3232, 0.3283, 0.3333, 0.3384, 0.3434, 0.3485, 0.3535, 0.3586, 0.3636, 0.3687, 0.3737, 0.3788, 0.3838, 0.3889, 0.3939, 0.3990, 0.4040, 0.4091, 0.4141, 0.4192, 0.4242, 0.4293, 0.4343, 0.4394, 0.4444, 0.4495, 0.4545, 0.4596, 0.4646, 0.4697, 0.4747, 0.4798, 0.4848, 0.4899, 0.4949, 0.5000, 0.5051, 0.5101, 0.5152, 0.5202, 0.5253, 0.5303, 0.5354, 0.5404, 0.5455, 0.5505, 0.5556, 0.5606, 0.5657, 0.5707, 0.5758, 0.5808, 0.5859, 0.5909, 0.5960, 0.6010, 0.6061, 0.6111, 0.6162, 0.6212, 0.6263, 0.6313, 0.6364, 0.6414, 0.6465, 0.6515, 0.6566, 0.6616, 0.6667, 0.6717, 0.6768, 0.6818, 0.6869, 0.6919, 0.6970, 0.7020, 0.7071, 0.7121, 0.7172, 0.7222, 0.7273, 0.7323, 0.7374, 0.7424, 0.7475, 0.7525, 0.7576, 0.7626, 0.7677, 0.7727, 0.7778, 0.7828, 0.7879, 0.7929, 0.7980, 0.8030, 0.8081, 0.8131, 0.8182, 0.8232, 0.8283, 0.8333, 0.8384, 0.8434, 0.8485, 0.8535, 0.8586, 0.8636, 0.8687, 0.8737, 0.8788, 0.8838, 0.8889, 0.8939, 0.8990, 0.9040, 0.9091, 0.9141, 0.9192, 0.9242, 0.9293, 0.9343, 0.9394, 0.9444, 0.9495, 0.9545, 0.9596, 0.9646, 0.9697, 0.9747, 0.9798, 0.9848, 0.9899, 0.9949, 1.0000],
        [0.5020, 0.4510, 0.4039, 0.3569, 0.3098, 0.2588, 0.2118, 0.1647, 0.1176, 0.0706, 0.0196, 0.0471, 0.1451, 0.2392, 0.3333, 0.4314, 0.5255, 0.6196, 0.7176, 0.8118, 0.9059, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 0.9922, 0.9569, 0.9176, 0.8824, 0.8431, 0.8039, 0.7686, 0.7294, 0.6902, 0.6549, 0.6157, 0.5647, 0.5098, 0.4510, 0.3922, 0.3333, 0.2784, 0.2196, 0.1608, 0.1059, 0.0471, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0039, 0.0275, 0.0510, 0.0745, 0.0941, 0.1176, 0.1412, 0.1647, 0.1882, 0.2118, 0.2353, 0.2235, 0.2000, 0.1765, 0.1529, 0.1294, 0.1098, 0.0863, 0.0627, 0.0392, 0.0157, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0039, 0.0078, 0.0118, 0.0196, 0.0235, 0.0314, 0.0353, 0.0431, 0.0471, 0.0549, 0.0549, 0.0510, 0.0431, 0.0392, 0.0314, 0.0275, 0.0196, 0.0157, 0.0118, 0.0039, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0314, 0.1294, 0.2235, 0.3216, 0.4157, 0.5098, 0.6078, 0.7020, 0.7961, 0.8941, 0.9882, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 0.9961, 0.9882, 0.9843, 0.9765, 0.9686, 0.9647, 0.9569, 0.9490, 0.9451, 0.9373, 0.9333, 0.9333, 0.9373, 0.9373, 0.9412, 0.9451, 0.9451, 0.9490, 0.9529, 0.9529, 0.9569, 0.9608, 0.9647, 0.9686, 0.9725, 0.9765, 0.9804, 0.9843, 0.9882, 0.9922, 0.9961],
        [0.0000, 0.0051, 0.0101, 0.0152, 0.0202, 0.0253, 0.0303, 0.0354, 0.0404, 0.0455, 0.0505, 0.0556, 0.0606, 0.0657, 0.0707, 0.0758, 0.0808, 0.0859, 0.0909, 0.0960, 0.1010, 0.1061, 0.1111, 0.1162, 0.1212, 0.1263, 0.1313, 0.1364, 0.1414, 0.1465, 0.1515, 0.1566, 0.1616, 0.1667, 0.1717, 0.1768, 0.1818, 0.1869, 0.1919, 0.1970, 0.2020, 0.2071, 0.2121, 0.2172, 0.2222, 0.2273, 0.2323, 0.2374, 0.2424, 0.2475, 0.2525, 0.2576, 0.2626, 0.2677, 0.2727, 0.2778, 0.2828, 0.2879, 0.2929, 0.2980, 0.3030, 0.3081, 0.3131, 0.3182, 0.3232, 0.3283, 0.3333, 0.3384, 0.3434, 0.3485, 0.3535, 0.3586, 0.3636, 0.3687, 0.3737, 0.3788, 0.3838, 0.3889, 0.3939, 0.3990, 0.4040, 0.4091, 0.4141, 0.4192, 0.4242, 0.4293, 0.4343, 0.4394, 0.4444, 0.4495, 0.4545, 0.4596, 0.4646, 0.4697, 0.4747, 0.4798, 0.4848, 0.4899, 0.4949, 0.5000, 0.5051, 0.5101, 0.5152, 0.5202, 0.5253, 0.5303, 0.5354, 0.5404, 0.5455, 0.5505, 0.5556, 0.5606, 0.5657, 0.5707, 0.5758, 0.5808, 0.5859, 0.5909, 0.5960, 0.6010, 0.6061, 0.6111, 0.6162, 0.6212, 0.6263, 0.6313, 0.6364, 0.6414, 0.6465, 0.6515, 0.6566, 0.6616, 0.6667, 0.6717, 0.6768, 0.6818, 0.6869, 0.6919, 0.6970, 0.7020, 0.7071, 0.7121, 0.7172, 0.7222, 0.7273, 0.7323, 0.7374, 0.7424, 0.7475, 0.7525, 0.7576, 0.7626, 0.7677, 0.7727, 0.7778, 0.7828, 0.7879, 0.7929, 0.7980, 0.8030, 0.8081, 0.8131, 0.8182, 0.8232, 0.8283, 0.8333, 0.8384, 0.8434, 0.8485, 0.8535, 0.8586, 0.8636, 0.8687, 0.8737, 0.8788, 0.8838, 0.8889, 0.8939, 0.8990, 0.9040, 0.9091, 0.9141, 0.9192, 0.9242, 0.9293, 0.9343, 0.9394, 0.9444, 0.9495, 0.9545, 0.9596, 0.9646, 0.9697, 0.9747, 0.9798, 0.9848, 0.9899, 0.9949, 1.0000],
        'gist_ncar',
        size);
    }
    
    
    private static function gist_rainbow(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 0.9608, 0.9412, 0.9216, 0.8980, 0.8784, 0.8588, 0.8353, 0.8157, 0.7922, 0.7725, 0.7529, 0.7294, 0.7098, 0.6863, 0.6667, 0.6235, 0.6039, 0.5843, 0.5608, 0.5412, 0.5176, 0.4980, 0.4784, 0.4549, 0.4353, 0.4157, 0.3922, 0.3725, 0.3490, 0.3294, 0.2863, 0.2667, 0.2471, 0.2235, 0.2039, 0.1804, 0.1608, 0.1412, 0.1176, 0.0980, 0.0745, 0.0549, 0.0353, 0.0118, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0078, 0.0275, 0.0706, 0.0941, 0.1137, 0.1333, 0.1569, 0.1765, 0.1961, 0.2196, 0.2392, 0.2627, 0.2824, 0.3020, 0.3255, 0.3451, 0.3647, 0.4078, 0.4314, 0.4510, 0.4706, 0.4941, 0.5137, 0.5333, 0.5569, 0.5765, 0.6000, 0.6196, 0.6392, 0.6627, 0.6824, 0.7059, 0.7451, 0.7686, 0.7882, 0.8078, 0.8314, 0.8510, 0.8745, 0.8941, 0.9137, 0.9373, 0.9569, 0.9765, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0196, 0.0431, 0.0627, 0.0863, 0.1059, 0.1255, 0.1490, 0.1686, 0.1882, 0.2118, 0.2314, 0.2549, 0.2745, 0.2941, 0.3176, 0.3569, 0.3804, 0.4000, 0.4235, 0.4431, 0.4627, 0.4863, 0.5059, 0.5294, 0.5490, 0.5686, 0.5922, 0.6118, 0.6314, 0.6549, 0.6980, 0.7176, 0.7373, 0.7608, 0.7804, 0.8000, 0.8235, 0.8431, 0.8667, 0.8863, 0.9059, 0.9294, 0.9490, 0.9686, 0.9922, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 0.9804, 0.9373, 0.9176, 0.8941, 0.8745, 0.8549, 0.8314, 0.8118, 0.7882, 0.7686, 0.7490, 0.7255, 0.7059, 0.6824, 0.6627, 0.6431, 0.6000, 0.5804, 0.5569, 0.5373, 0.5137, 0.4941, 0.4745, 0.4510, 0.4314, 0.4118, 0.3882, 0.3686, 0.3451, 0.3255, 0.3059, 0.2627, 0.2431, 0.2196, 0.2000, 0.1765, 0.1569, 0.1373, 0.1137, 0.0941, 0.0706, 0.0510, 0.0314, 0.0078, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [0.1647, 0.1412, 0.1216, 0.1020, 0.0784, 0.0588, 0.0392, 0.0157, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0000, 0.0039, 0.0471, 0.0667, 0.0902, 0.1098, 0.1294, 0.1529, 0.1725, 0.1922, 0.2157, 0.2353, 0.2588, 0.2784, 0.2980, 0.3216, 0.3412, 0.3843, 0.4039, 0.4275, 0.4471, 0.4667, 0.4902, 0.5098, 0.5294, 0.5529, 0.5725, 0.5961, 0.6157, 0.6353, 0.6588, 0.6784, 0.7216, 0.7412, 0.7647, 0.7843, 0.8039, 0.8275, 0.8471, 0.8706, 0.8902, 0.9098, 0.9333, 0.9529, 0.9725, 0.9961, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 1.0000, 0.9961, 0.9765, 0.9529, 0.9137, 0.8902, 0.8706, 0.8510, 0.8275, 0.8078],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        'gist_rainbow',
        size);
    }
    
    
    private static function gist_stern(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [0.0000, 0.0706, 0.1412, 0.2118, 0.2824, 0.3529, 0.4235, 0.4980, 0.5686, 0.6392, 0.7804, 0.8510, 0.9216, 0.9961, 0.9765, 0.9569, 0.9373, 0.9176, 0.8980, 0.8745, 0.8549, 0.8353, 0.8157, 0.7961, 0.7725, 0.7529, 0.7333, 0.7137, 0.6941, 0.6745, 0.6314, 0.6118, 0.5922, 0.5725, 0.5490, 0.5294, 0.5098, 0.4902, 0.4706, 0.4510, 0.4275, 0.4078, 0.3882, 0.3686, 0.3490, 0.3255, 0.3059, 0.2863, 0.2667, 0.2471, 0.2039, 0.1843, 0.1647, 0.1451, 0.1255, 0.1020, 0.0824, 0.0627, 0.0431, 0.0235, 0.2510, 0.2549, 0.2588, 0.2627, 0.2667, 0.2706, 0.2745, 0.2784, 0.2824, 0.2863, 0.2941, 0.2980, 0.3020, 0.3059, 0.3098, 0.3137, 0.3176, 0.3216, 0.3255, 0.3294, 0.3333, 0.3373, 0.3412, 0.3451, 0.3490, 0.3529, 0.3569, 0.3608, 0.3647, 0.3686, 0.3765, 0.3804, 0.3843, 0.3882, 0.3922, 0.3961, 0.4000, 0.4039, 0.4078, 0.4118, 0.4157, 0.4196, 0.4235, 0.4275, 0.4314, 0.4353, 0.4392, 0.4431, 0.4471, 0.4510, 0.4588, 0.4627, 0.4667, 0.4706, 0.4745, 0.4784, 0.4824, 0.4863, 0.4902, 0.4941, 0.5020, 0.5059, 0.5098, 0.5137, 0.5176, 0.5216, 0.5255, 0.5294, 0.5333, 0.5373, 0.5451, 0.5490, 0.5529, 0.5569, 0.5608, 0.5647, 0.5686, 0.5725, 0.5765, 0.5804, 0.5843, 0.5882, 0.5922, 0.5961, 0.6000, 0.6039, 0.6078, 0.6118, 0.6157, 0.6196, 0.6275, 0.6314, 0.6353, 0.6392, 0.6431, 0.6471, 0.6510, 0.6549, 0.6588, 0.6627, 0.6667, 0.6706, 0.6745, 0.6784, 0.6824, 0.6863, 0.6902, 0.6941, 0.6980, 0.7020, 0.7098, 0.7137, 0.7176, 0.7216, 0.7255, 0.7294, 0.7333, 0.7373, 0.7412, 0.7451, 0.7529, 0.7569, 0.7608, 0.7647, 0.7686, 0.7725, 0.7765, 0.7804, 0.7843, 0.7882, 0.7961, 0.8000, 0.8039, 0.8078, 0.8118, 0.8157, 0.8196, 0.8235, 0.8275, 0.8314, 0.8353, 0.8392, 0.8431, 0.8471, 0.8510, 0.8549, 0.8588, 0.8627, 0.8667, 0.8706, 0.8784, 0.8824, 0.8863, 0.8902, 0.8941, 0.8980, 0.9020, 0.9059, 0.9098, 0.9137, 0.9176, 0.9216, 0.9255, 0.9294, 0.9333, 0.9373, 0.9412, 0.9451, 0.9490, 0.9529, 0.9608, 0.9647, 0.9686, 0.9725, 0.9765, 0.9804, 0.9843, 0.9882, 0.9922],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [0.0000, 0.0039, 0.0078, 0.0118, 0.0157, 0.0196, 0.0235, 0.0275, 0.0314, 0.0353, 0.0431, 0.0471, 0.0510, 0.0549, 0.0588, 0.0627, 0.0667, 0.0706, 0.0745, 0.0784, 0.0824, 0.0863, 0.0902, 0.0941, 0.0980, 0.1020, 0.1059, 0.1098, 0.1137, 0.1176, 0.1255, 0.1294, 0.1333, 0.1373, 0.1412, 0.1451, 0.1490, 0.1529, 0.1569, 0.1608, 0.1647, 0.1686, 0.1725, 0.1765, 0.1804, 0.1843, 0.1882, 0.1922, 0.1961, 0.2000, 0.2078, 0.2118, 0.2157, 0.2196, 0.2235, 0.2275, 0.2314, 0.2353, 0.2392, 0.2431, 0.2510, 0.2549, 0.2588, 0.2627, 0.2667, 0.2706, 0.2745, 0.2784, 0.2824, 0.2863, 0.2941, 0.2980, 0.3020, 0.3059, 0.3098, 0.3137, 0.3176, 0.3216, 0.3255, 0.3294, 0.3333, 0.3373, 0.3412, 0.3451, 0.3490, 0.3529, 0.3569, 0.3608, 0.3647, 0.3686, 0.3765, 0.3804, 0.3843, 0.3882, 0.3922, 0.3961, 0.4000, 0.4039, 0.4078, 0.4118, 0.4157, 0.4196, 0.4235, 0.4275, 0.4314, 0.4353, 0.4392, 0.4431, 0.4471, 0.4510, 0.4588, 0.4627, 0.4667, 0.4706, 0.4745, 0.4784, 0.4824, 0.4863, 0.4902, 0.4941, 0.5020, 0.5059, 0.5098, 0.5137, 0.5176, 0.5216, 0.5255, 0.5294, 0.5333, 0.5373, 0.5451, 0.5490, 0.5529, 0.5569, 0.5608, 0.5647, 0.5686, 0.5725, 0.5765, 0.5804, 0.5843, 0.5882, 0.5922, 0.5961, 0.6000, 0.6039, 0.6078, 0.6118, 0.6157, 0.6196, 0.6275, 0.6314, 0.6353, 0.6392, 0.6431, 0.6471, 0.6510, 0.6549, 0.6588, 0.6627, 0.6667, 0.6706, 0.6745, 0.6784, 0.6824, 0.6863, 0.6902, 0.6941, 0.6980, 0.7020, 0.7098, 0.7137, 0.7176, 0.7216, 0.7255, 0.7294, 0.7333, 0.7373, 0.7412, 0.7451, 0.7529, 0.7569, 0.7608, 0.7647, 0.7686, 0.7725, 0.7765, 0.7804, 0.7843, 0.7882, 0.7961, 0.8000, 0.8039, 0.8078, 0.8118, 0.8157, 0.8196, 0.8235, 0.8275, 0.8314, 0.8353, 0.8392, 0.8431, 0.8471, 0.8510, 0.8549, 0.8588, 0.8627, 0.8667, 0.8706, 0.8784, 0.8824, 0.8863, 0.8902, 0.8941, 0.8980, 0.9020, 0.9059, 0.9098, 0.9137, 0.9176, 0.9216, 0.9255, 0.9294, 0.9333, 0.9373, 0.9412, 0.9451, 0.9490, 0.9529, 0.9608, 0.9647, 0.9686, 0.9725, 0.9765, 0.9804, 0.9843, 0.9882, 0.9922],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [0.0000, 0.0039, 0.0118, 0.0196, 0.0275, 0.0353, 0.0431, 0.0510, 0.0588, 0.0667, 0.0824, 0.0902, 0.0980, 0.1059, 0.1137, 0.1216, 0.1294, 0.1373, 0.1451, 0.1529, 0.1608, 0.1686, 0.1765, 0.1843, 0.1922, 0.2000, 0.2078, 0.2157, 0.2235, 0.2314, 0.2471, 0.2549, 0.2627, 0.2706, 0.2784, 0.2863, 0.2941, 0.3020, 0.3098, 0.3176, 0.3255, 0.3333, 0.3412, 0.3490, 0.3569, 0.3647, 0.3725, 0.3804, 0.3882, 0.3961, 0.4118, 0.4196, 0.4275, 0.4353, 0.4431, 0.4510, 0.4588, 0.4667, 0.4745, 0.4824, 0.4980, 0.5059, 0.5137, 0.5216, 0.5294, 0.5373, 0.5451, 0.5529, 0.5608, 0.5686, 0.5843, 0.5922, 0.6000, 0.6078, 0.6157, 0.6235, 0.6314, 0.6392, 0.6471, 0.6549, 0.6627, 0.6706, 0.6784, 0.6863, 0.6941, 0.7020, 0.7098, 0.7176, 0.7255, 0.7333, 0.7490, 0.7569, 0.7647, 0.7725, 0.7804, 0.7882, 0.7961, 0.8039, 0.8118, 0.8196, 0.8275, 0.8353, 0.8431, 0.8510, 0.8588, 0.8667, 0.8745, 0.8824, 0.8902, 0.8980, 0.9137, 0.9216, 0.9294, 0.9373, 0.9451, 0.9529, 0.9608, 0.9686, 0.9765, 0.9843, 1.0000, 0.9843, 0.9686, 0.9529, 0.9333, 0.9176, 0.9020, 0.8863, 0.8667, 0.8510, 0.8196, 0.8000, 0.7843, 0.7686, 0.7529, 0.7333, 0.7176, 0.7020, 0.6863, 0.6667, 0.6510, 0.6353, 0.6196, 0.6000, 0.5843, 0.5686, 0.5529, 0.5333, 0.5176, 0.5020, 0.4667, 0.4510, 0.4353, 0.4196, 0.4000, 0.3843, 0.3686, 0.3529, 0.3333, 0.3176, 0.3020, 0.2863, 0.2667, 0.2510, 0.2353, 0.2196, 0.2000, 0.1843, 0.1686, 0.1529, 0.1176, 0.1020, 0.0863, 0.0667, 0.0510, 0.0353, 0.0196, 0.0000, 0.0118, 0.0275, 0.0588, 0.0745, 0.0863, 0.1020, 0.1176, 0.1333, 0.1490, 0.1608, 0.1765, 0.1922, 0.2235, 0.2353, 0.2510, 0.2667, 0.2824, 0.2980, 0.3098, 0.3255, 0.3412, 0.3569, 0.3725, 0.3843, 0.4000, 0.4157, 0.4314, 0.4471, 0.4588, 0.4745, 0.4902, 0.5059, 0.5373, 0.5490, 0.5647, 0.5804, 0.5961, 0.6118, 0.6235, 0.6392, 0.6549, 0.6706, 0.6863, 0.6980, 0.7137, 0.7294, 0.7451, 0.7608, 0.7725, 0.7882, 0.8039, 0.8196, 0.8471, 0.8627, 0.8784, 0.8941, 0.9098, 0.9216, 0.9373, 0.9529, 0.9686],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        'gist_stern',
        size);
    }
    
    
    private static function gist_yarg(size:int = DEFAULT_SIZE):ColorPalette {
      return ColorPalette.createPaletteFromRGB(
        [1.0000, 0.9961, 0.9922, 0.9882, 0.9843, 0.9804, 0.9765, 0.9725, 0.9647, 0.9608, 0.9569, 0.9529, 0.9490, 0.9451, 0.9412, 0.9373, 0.9333, 0.9294, 0.9255, 0.9216, 0.9176, 0.9137, 0.9098, 0.9020, 0.8980, 0.8941, 0.8902, 0.8863, 0.8824, 0.8784, 0.8745, 0.8706, 0.8667, 0.8627, 0.8588, 0.8549, 0.8510, 0.8471, 0.8392, 0.8353, 0.8314, 0.8275, 0.8235, 0.8196, 0.8157, 0.8118, 0.8078, 0.8039, 0.8000, 0.7961, 0.7922, 0.7882, 0.7843, 0.7765, 0.7725, 0.7686, 0.7647, 0.7608, 0.7569, 0.7529, 0.7490, 0.7451, 0.7412, 0.7373, 0.7333, 0.7294, 0.7255, 0.7216, 0.7137, 0.7098, 0.7059, 0.7020, 0.6980, 0.6941, 0.6902, 0.6863, 0.6824, 0.6784, 0.6745, 0.6706, 0.6667, 0.6627, 0.6588, 0.6510, 0.6471, 0.6431, 0.6392, 0.6353, 0.6314, 0.6275, 0.6235, 0.6196, 0.6157, 0.6118, 0.6078, 0.6039, 0.6000, 0.5961, 0.5882, 0.5843, 0.5804, 0.5765, 0.5725, 0.5686, 0.5647, 0.5608, 0.5569, 0.5529, 0.5490, 0.5451, 0.5412, 0.5373, 0.5333, 0.5255, 0.5216, 0.5176, 0.5137, 0.5098, 0.5059, 0.5020, 0.4980, 0.4941, 0.4902, 0.4863, 0.4824, 0.4784, 0.4745, 0.4706, 0.4627, 0.4588, 0.4549, 0.4510, 0.4471, 0.4431, 0.4392, 0.4353, 0.4314, 0.4275, 0.4235, 0.4196, 0.4157, 0.4118, 0.4078, 0.4000, 0.3961, 0.3922, 0.3882, 0.3843, 0.3804, 0.3765, 0.3725, 0.3686, 0.3647, 0.3608, 0.3569, 0.3529, 0.3490, 0.3451, 0.3373, 0.3333, 0.3294, 0.3255, 0.3216, 0.3176, 0.3137, 0.3098, 0.3059, 0.3020, 0.2980, 0.2941, 0.2902, 0.2863, 0.2824, 0.2745, 0.2706, 0.2667, 0.2627, 0.2588, 0.2549, 0.2510, 0.2471, 0.2431, 0.2392, 0.2353, 0.2314, 0.2275, 0.2235, 0.2196, 0.2118, 0.2078, 0.2039, 0.2000, 0.1961, 0.1922, 0.1882, 0.1843, 0.1804, 0.1765, 0.1725, 0.1686, 0.1647, 0.1608, 0.1569, 0.1490, 0.1451, 0.1412, 0.1373, 0.1333, 0.1294, 0.1255, 0.1216, 0.1176, 0.1137, 0.1098, 0.1059, 0.1020, 0.0980, 0.0941, 0.0863, 0.0824, 0.0784, 0.0745, 0.0706, 0.0667, 0.0627, 0.0588, 0.0549, 0.0510, 0.0471, 0.0431, 0.0392, 0.0353, 0.0314, 0.0235, 0.0196, 0.0157, 0.0118, 0.0078, 0.0039],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [1.0000, 0.9961, 0.9922, 0.9882, 0.9843, 0.9804, 0.9765, 0.9725, 0.9647, 0.9608, 0.9569, 0.9529, 0.9490, 0.9451, 0.9412, 0.9373, 0.9333, 0.9294, 0.9255, 0.9216, 0.9176, 0.9137, 0.9098, 0.9020, 0.8980, 0.8941, 0.8902, 0.8863, 0.8824, 0.8784, 0.8745, 0.8706, 0.8667, 0.8627, 0.8588, 0.8549, 0.8510, 0.8471, 0.8392, 0.8353, 0.8314, 0.8275, 0.8235, 0.8196, 0.8157, 0.8118, 0.8078, 0.8039, 0.8000, 0.7961, 0.7922, 0.7882, 0.7843, 0.7765, 0.7725, 0.7686, 0.7647, 0.7608, 0.7569, 0.7529, 0.7490, 0.7451, 0.7412, 0.7373, 0.7333, 0.7294, 0.7255, 0.7216, 0.7137, 0.7098, 0.7059, 0.7020, 0.6980, 0.6941, 0.6902, 0.6863, 0.6824, 0.6784, 0.6745, 0.6706, 0.6667, 0.6627, 0.6588, 0.6510, 0.6471, 0.6431, 0.6392, 0.6353, 0.6314, 0.6275, 0.6235, 0.6196, 0.6157, 0.6118, 0.6078, 0.6039, 0.6000, 0.5961, 0.5882, 0.5843, 0.5804, 0.5765, 0.5725, 0.5686, 0.5647, 0.5608, 0.5569, 0.5529, 0.5490, 0.5451, 0.5412, 0.5373, 0.5333, 0.5255, 0.5216, 0.5176, 0.5137, 0.5098, 0.5059, 0.5020, 0.4980, 0.4941, 0.4902, 0.4863, 0.4824, 0.4784, 0.4745, 0.4706, 0.4627, 0.4588, 0.4549, 0.4510, 0.4471, 0.4431, 0.4392, 0.4353, 0.4314, 0.4275, 0.4235, 0.4196, 0.4157, 0.4118, 0.4078, 0.4000, 0.3961, 0.3922, 0.3882, 0.3843, 0.3804, 0.3765, 0.3725, 0.3686, 0.3647, 0.3608, 0.3569, 0.3529, 0.3490, 0.3451, 0.3373, 0.3333, 0.3294, 0.3255, 0.3216, 0.3176, 0.3137, 0.3098, 0.3059, 0.3020, 0.2980, 0.2941, 0.2902, 0.2863, 0.2824, 0.2745, 0.2706, 0.2667, 0.2627, 0.2588, 0.2549, 0.2510, 0.2471, 0.2431, 0.2392, 0.2353, 0.2314, 0.2275, 0.2235, 0.2196, 0.2118, 0.2078, 0.2039, 0.2000, 0.1961, 0.1922, 0.1882, 0.1843, 0.1804, 0.1765, 0.1725, 0.1686, 0.1647, 0.1608, 0.1569, 0.1490, 0.1451, 0.1412, 0.1373, 0.1333, 0.1294, 0.1255, 0.1216, 0.1176, 0.1137, 0.1098, 0.1059, 0.1020, 0.0980, 0.0941, 0.0863, 0.0824, 0.0784, 0.0745, 0.0706, 0.0667, 0.0627, 0.0588, 0.0549, 0.0510, 0.0471, 0.0431, 0.0392, 0.0353, 0.0314, 0.0235, 0.0196, 0.0157, 0.0118, 0.0078, 0.0039],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        [1.0000, 0.9961, 0.9922, 0.9882, 0.9843, 0.9804, 0.9765, 0.9725, 0.9647, 0.9608, 0.9569, 0.9529, 0.9490, 0.9451, 0.9412, 0.9373, 0.9333, 0.9294, 0.9255, 0.9216, 0.9176, 0.9137, 0.9098, 0.9020, 0.8980, 0.8941, 0.8902, 0.8863, 0.8824, 0.8784, 0.8745, 0.8706, 0.8667, 0.8627, 0.8588, 0.8549, 0.8510, 0.8471, 0.8392, 0.8353, 0.8314, 0.8275, 0.8235, 0.8196, 0.8157, 0.8118, 0.8078, 0.8039, 0.8000, 0.7961, 0.7922, 0.7882, 0.7843, 0.7765, 0.7725, 0.7686, 0.7647, 0.7608, 0.7569, 0.7529, 0.7490, 0.7451, 0.7412, 0.7373, 0.7333, 0.7294, 0.7255, 0.7216, 0.7137, 0.7098, 0.7059, 0.7020, 0.6980, 0.6941, 0.6902, 0.6863, 0.6824, 0.6784, 0.6745, 0.6706, 0.6667, 0.6627, 0.6588, 0.6510, 0.6471, 0.6431, 0.6392, 0.6353, 0.6314, 0.6275, 0.6235, 0.6196, 0.6157, 0.6118, 0.6078, 0.6039, 0.6000, 0.5961, 0.5882, 0.5843, 0.5804, 0.5765, 0.5725, 0.5686, 0.5647, 0.5608, 0.5569, 0.5529, 0.5490, 0.5451, 0.5412, 0.5373, 0.5333, 0.5255, 0.5216, 0.5176, 0.5137, 0.5098, 0.5059, 0.5020, 0.4980, 0.4941, 0.4902, 0.4863, 0.4824, 0.4784, 0.4745, 0.4706, 0.4627, 0.4588, 0.4549, 0.4510, 0.4471, 0.4431, 0.4392, 0.4353, 0.4314, 0.4275, 0.4235, 0.4196, 0.4157, 0.4118, 0.4078, 0.4000, 0.3961, 0.3922, 0.3882, 0.3843, 0.3804, 0.3765, 0.3725, 0.3686, 0.3647, 0.3608, 0.3569, 0.3529, 0.3490, 0.3451, 0.3373, 0.3333, 0.3294, 0.3255, 0.3216, 0.3176, 0.3137, 0.3098, 0.3059, 0.3020, 0.2980, 0.2941, 0.2902, 0.2863, 0.2824, 0.2745, 0.2706, 0.2667, 0.2627, 0.2588, 0.2549, 0.2510, 0.2471, 0.2431, 0.2392, 0.2353, 0.2314, 0.2275, 0.2235, 0.2196, 0.2118, 0.2078, 0.2039, 0.2000, 0.1961, 0.1922, 0.1882, 0.1843, 0.1804, 0.1765, 0.1725, 0.1686, 0.1647, 0.1608, 0.1569, 0.1490, 0.1451, 0.1412, 0.1373, 0.1333, 0.1294, 0.1255, 0.1216, 0.1176, 0.1137, 0.1098, 0.1059, 0.1020, 0.0980, 0.0941, 0.0863, 0.0824, 0.0784, 0.0745, 0.0706, 0.0667, 0.0627, 0.0588, 0.0549, 0.0510, 0.0471, 0.0431, 0.0392, 0.0353, 0.0314, 0.0235, 0.0196, 0.0157, 0.0118, 0.0078, 0.0039],
        [0.0000, 0.0042, 0.0084, 0.0126, 0.0168, 0.0210, 0.0252, 0.0294, 0.0336, 0.0378, 0.0420, 0.0462, 0.0504, 0.0546, 0.0588, 0.0630, 0.0672, 0.0714, 0.0756, 0.0798, 0.0840, 0.0882, 0.0924, 0.0966, 0.1008, 0.1050, 0.1092, 0.1134, 0.1176, 0.1218, 0.1261, 0.1303, 0.1345, 0.1387, 0.1429, 0.1471, 0.1513, 0.1555, 0.1597, 0.1639, 0.1681, 0.1723, 0.1765, 0.1807, 0.1849, 0.1891, 0.1933, 0.1975, 0.2017, 0.2059, 0.2101, 0.2143, 0.2185, 0.2227, 0.2269, 0.2311, 0.2353, 0.2395, 0.2437, 0.2479, 0.2521, 0.2563, 0.2605, 0.2647, 0.2689, 0.2731, 0.2773, 0.2815, 0.2857, 0.2899, 0.2941, 0.2983, 0.3025, 0.3067, 0.3109, 0.3151, 0.3193, 0.3235, 0.3277, 0.3319, 0.3361, 0.3403, 0.3445, 0.3487, 0.3529, 0.3571, 0.3613, 0.3655, 0.3697, 0.3739, 0.3782, 0.3824, 0.3866, 0.3908, 0.3950, 0.3992, 0.4034, 0.4076, 0.4118, 0.4160, 0.4202, 0.4244, 0.4286, 0.4328, 0.4370, 0.4412, 0.4454, 0.4496, 0.4538, 0.4580, 0.4622, 0.4664, 0.4706, 0.4748, 0.4790, 0.4832, 0.4874, 0.4916, 0.4958, 0.5000, 0.5042, 0.5084, 0.5126, 0.5168, 0.5210, 0.5252, 0.5294, 0.5336, 0.5378, 0.5420, 0.5462, 0.5504, 0.5546, 0.5588, 0.5630, 0.5672, 0.5714, 0.5756, 0.5798, 0.5840, 0.5882, 0.5924, 0.5966, 0.6008, 0.6050, 0.6092, 0.6134, 0.6176, 0.6218, 0.6261, 0.6303, 0.6345, 0.6387, 0.6429, 0.6471, 0.6513, 0.6555, 0.6597, 0.6639, 0.6681, 0.6723, 0.6765, 0.6807, 0.6849, 0.6891, 0.6933, 0.6975, 0.7017, 0.7059, 0.7101, 0.7143, 0.7185, 0.7227, 0.7269, 0.7311, 0.7353, 0.7395, 0.7437, 0.7479, 0.7521, 0.7563, 0.7605, 0.7647, 0.7689, 0.7731, 0.7773, 0.7815, 0.7857, 0.7899, 0.7941, 0.7983, 0.8025, 0.8067, 0.8109, 0.8151, 0.8193, 0.8235, 0.8277, 0.8319, 0.8361, 0.8403, 0.8445, 0.8487, 0.8529, 0.8571, 0.8613, 0.8655, 0.8697, 0.8739, 0.8782, 0.8824, 0.8866, 0.8908, 0.8950, 0.8992, 0.9034, 0.9076, 0.9118, 0.9160, 0.9202, 0.9244, 0.9286, 0.9328, 0.9370, 0.9412, 0.9454, 0.9496, 0.9538, 0.9580, 0.9622, 0.9664, 0.9706, 0.9748, 0.9790, 0.9832, 0.9874, 0.9916, 0.9958, 1.0000],
        'gist_yarg',
        size);
    }
    
    
    /**
     * Create a palette using colors and keyframes
     */
    public static function createPalette(colors:Array, keyframes:Array, size:int = DEFAULT_SIZE):ColorPalette {
      var cm:Array = new Array(size);
      for (var i:uint = 0; i < size; i++) {
        var p:Number = i / (size - 1);
        for (var j:uint = 0; j < keyframes.length - 1; j++) {
          if (p >= keyframes[j] && p <= keyframes[j + 1]) {
            var f:Number = (p - keyframes[j]) / (keyframes[j + 1] - keyframes[j]);
            cm[i] = Colors.interpolate(colors[j], colors[j + 1], f);
            break;
          }
        }
      }
      return new ColorPalette(cm)
    }
    
    
    /**
     * Create a palette using separate values and keyframes
     * for each color channel.
     *
     * @param redValues desired red value at keyframe positions
     * @param redKeyframes desired red keyframes
     * @param greenValues desired green value at keyframe positions
     * @param greenKeyframes desired green keyframes
     * @param blueValues desired blue value at keyframe positions
     * @param blueKeyframes desired blue keyframes
     * @param nm a name for the palette
     * @param size the length of the palette
     *
     */
    public static function createPaletteFromRGB(redValues:Array,
                                                redKeyframes:Array,
                                                greenValues:Array,
                                                greenKeyframes:Array,
                                                blueValues:Array,
                                                blueKeyframes:Array,
                                                nm:String = 'undefined',
                                                size:int = DEFAULT_SIZE):ColorPalette {
      
      function lookup(p:Number, values:Array, keyframes:Array):Number {
        for (var j:uint = 0; j < keyframes.length - 1; j++) {
          if (p >= keyframes[j] && p <= keyframes[j + 1]) {
            // find the interpolation fraction
            var f:Number = (p - keyframes[j]) / (keyframes[j + 1] - keyframes[j]);
            // interpolate the values
            return (1 - f) * values[j] + f * values[j + 1];
          }
        }
        return 1.0;
      }
      
      var cm:Array = new Array(size), r:Number, g:Number, b:Number;
      for (var i:uint = 0; i < size; i++) {
        var p:Number = i / (size - 1);
        r = lookup(p, redValues, redKeyframes);
        g = lookup(p, greenValues, greenKeyframes);
        b = lookup(p, blueValues, blueKeyframes);
        cm[i] = Colors.rgba(r * 255, g * 255, b * 255);
      }
      return new ColorPalette(cm, null, nm);
    }
    
    
    /**
     * Convert a Flare ColorPalette to a JuiceKit ColorPalette
     *
     * @param cp a flare ColorPalette
     * @returns a JuiceKit ColorPalette
     */
    public static function fromFlareColorPalette(cp:ColorPalette):ColorPalette {
      return new ColorPalette(cp.values.slice());
    }
    
    
    //----------------------------------
    // ColorPalette manipulation functions
    // These functions mirror options in the
    // Colors utility class
    // but affect the whole palette
    //----------------------------------
    
    /**
     * (NodeBox) Darken all the colors in the input list
     * @param step an optional step value, default=0.1
     * @return a list containing darkened color values
     */
    public function darken(step:Number = 0.1):ColorPalette {
      const len:int = this.values.length;
      for (var i:int = 0; i < len; i++) {
        this.values[i] = Colors.darken(this.values[i], step);
      }
      dispatchEvent(new Event("colorsChanged"));
      return this;
    }
    
    /**
     * (NodeBox) Lighten all the colors in the input list
     * @param step an optional step value, default=0.1
     * @return a list containing lightened color values
     */
    public function lighten(step:Number = 0.1):ColorPalette {
      return darken(-step);
    }
    
    public var lighter:Function = lighten;
    public var darker:Function = darken;
    
    
    /**
     * (NodeBox) Saturate all the colors in the input list
     * @param step an optional step value, default=0.1
     * @return a list containing more saturated color values
     */
    public function saturate(step:Number = 0.1):ColorPalette {
      const len:int = this.values.length;
      for (var i:int = 0; i < len; i++) {
        this.values[i] = Colors.saturate(this.values[i], step);
      }
      dispatchEvent(new Event("colorsChanged"));
      return this;
    }
    
    
    /**
     * (NodeBox) Desaturate all the colors in the input list
     * @param step an optional step value, default=0.1
     * @return a list containing more saturated color values
     */
    public function desaturate(step:Number = 0.1):ColorPalette {
      return saturate(-step);
    }
    
    
    /**
     * (NodeBox) Adjust contrast on all the colors in the input list
     * @param step an optional step value, default=0.1
     * @return a list containing contrast adjusted color values
     */
    public function adjustContrast(step:Number = 0.1):ColorPalette {
      const len:int = this.values.length;
      for (var i:int = 0; i < len; i++) {
        this.values[i] = Colors.adjustContrast(this.values[i], step);
      }
      dispatchEvent(new Event("colorsChanged"));
      return this;
    }
    
    
    /**
     * (NodeBox) Completely desaturate all colors in the input list
     * @return a list containing completely desaturated colors
     */
    public function desaturate2():ColorPalette {
      const len:int = this.values.length;
      for (var i:int = 0; i < len; i++) {
        this._values[i] = Colors.desaturate2(this._values[i]);
      }
      dispatchEvent(new Event("colorsChanged"));
      return this;
    }
    
    /**
     * (NodeBox) Complement all the colors in the input list
     * @return a list containing complementary colors
     */
    public function complement():ColorPalette {
      const len:int = this.values.length;
      for (var i:int = 0; i < len; i++) {
        this.values[i] = Colors.complement(this.values[i]);
      }
      dispatchEvent(new Event("colorsChanged"));
      return this;
    }
    
    
    /**
     * (NodeBox) Get analagous colors for all colors in the input list
     * @return a list containing analagous colors
     */
    public function analog():ColorPalette {
      const len:int = this.values.length;
      for (var i:int = 0; i < len; i++) {
        this.values[i] = Colors.analog(this.values[i]);
      }
      dispatchEvent(new Event("colorsChanged"));
      return this;
    }
    
    
    /**
     * Reverse the order of colors in the Palette
     */
    public function reverse():ColorPalette {
      this.reversed = !this.reversed;
      this.values = this.values.reverse();
      dispatchEvent(new Event("colorsChanged"));
      return this;
    }
    
    //-------------------------------
    // ColorPalette query functions
    // These functions return a color from the palette
    // based on some property
    //-------------------------------
    
    /**
     * Return the lightest color in the array
     */
    public function lightest():uint {
      const white:uint = 0xffffff;
      var best:uint = NaN;
      for each (var c:uint in this._values) {
        if (isNaN(best))
          best = c;
        else if (Colors.luminosityDifference(white, best) > Colors.luminosityDifference(white, c))
          best = c;
      }
      return best;
    }
    
    
    /**
     * Return the darkest color in the array
     */
    public function darkest():uint {
      const white:uint = 0xffffff;
      var best:uint = NaN;
      for each (var c:uint in this._values) {
        if (isNaN(best))
          best = c;
        else if (Colors.luminosityDifference(white, best) < Colors.luminosityDifference(white, c))
          best = c;
      }
      return best;
    }
    
    
    /**
     * Create sorts by color properties
     */
    private function sortFactory(cmp:Function):Function {
      return function():ColorPalette {
        function order(a:uint, b:uint):Number {
          if (a == b) return 0;
          else {
            if (cmp(a) > cmp(b)) return -1;
            else return 1;
          }
        }
        
        this._values.sort(order);
        dispatchEvent(new Event(COLORS_CHANGED));
        return this;
      }
    }
    
    public var sortByLuminance:Function = sortFactory(Colors.luminance);
    public var sortByLuminanceBlack:Function = sortFactory(Colors.luminanceFromBlack);
    public var sortByHue:Function = sortFactory(Colors.hue);
    public var sortBySaturation:Function = sortFactory(Colors.saturation);
    public var sortByValue:Function = sortFactory(Colors.value);
    public var sortByRed:Function = sortFactory(Colors.r);
    public var sortByGreen:Function = sortFactory(Colors.g);
    public var sortByBlue:Function = sortFactory(Colors.b);
    public var sortByAlpha:Function = sortFactory(Colors.a);
    
    
    /**
     * Extend the list by adding complements for all colors
     * @return a list containing the original colors and complements
     */
    public function extendWithComplements():ColorPalette {
      var len:uint = this._values.length;
      for (var i:int = 0; i < len; i++) {
        this._values.push(Colors.complement(this._values[i]));
      }
      return this;
    }
    
    
    //-------------------------------
    // ColorPalette generation functions
    // These functions generate a palette from a color
    //-------------------------------
    
    /**
     * A palette containing the color and it's complement
     *
     * @param c a base color
     */
    public static function complement(c:uint):ColorPalette {
      var ca:Array = [];
      ca.push(c);
      ca.push(Colors.complement(c));
      return new ColorPalette(ca);
    }
    
    
    /**
     * A palette containing six total colors that are related
     * to the base color
     *
     * @param c a base color
     */
    public static function complementary(c:uint):ColorPalette {
      var ca:Array = [];
      // The original color.
      ca.push(c);
      var origclr:uint = c;
      
      // A contrasting color: much darker or lighter than the original.
      var brightness:Number = Colors.value(c);
      var sat:Number = Colors.saturation(c);
      if (brightness > 0.4)
        ca.push(Colors.setValue(c, 0.1 + brightness * 0.25));
      else
        ca.push(Colors.setValue(c, 1.0 - brightness * 0.25));
      
      // A soft supporting color: lighter and less saturated.
      ca.push(Colors.setHsv(origclr, NaN, 0.1 + sat * 0.3, 0.3 + brightness));
      
      // A contrasting complement: very dark or very light.
      var comp:uint = Colors.complement(c);
      brightness = Colors.value(comp);
      sat = Colors.saturation(comp);
      if (brightness > 0.3)
        ca.push(Colors.setValue(comp, 0.1 + brightness * 0.25));
      else
        ca.push(Colors.setValue(comp, 1.0 - brightness * 0.25));
      
      // the complement
      ca.push(comp);
      // A soft supporting variant of the complement
      ca.push(Colors.setHsv(comp, NaN, 0.1 + sat * 0.3, 0.3 + brightness));
      return new ColorPalette(ca);
    }
    
    /**
     * A palette containing the split complementary colors of a base color
     *
     * @param c a base color
     */
    public static function splitComplementary(c:uint):ColorPalette {
      var ca:Array = [];
      ca.push(c);
      
      var clr:uint = Colors.rotateColorwheel(c, -30. / 360);
      ca.push(Colors.adjustValue(clr, 0.1));
      
      clr = Colors.rotateColorwheel(c, 30. / 360);
      ca.push(Colors.adjustValue(clr, 0.1));
      
      return new ColorPalette(ca);
    }
    
    
    /**
     * Returns the left half of the split complement.
     *
     * A list is returned with the same darker and softer colors
     * as in the complementary list, but using the hue of the
     * left split complement instead of the complement itself.
     *
     * (per NodeBox documentation)
     *
     * @param c a base color
     */
    public static function leftComplement(c:uint):ColorPalette {
      var left:uint = splitComplementary(c).values[1];
      
      var ca:Array = complementary(c).values;
      var h:Number = Colors.hue(left);
      ca[3] = Colors.setHue(ca[3], h);
      ca[4] = Colors.setHue(ca[4], h);
      ca[5] = Colors.setHue(ca[5], h);
      
      var left_ca:Array = [];
      left_ca.push(ca[0]);
      left_ca.push(ca[2]);
      left_ca.push(ca[1]);
      left_ca.push(ca[3]);
      left_ca.push(ca[4]);
      left_ca.push(ca[5]);
      return new ColorPalette(left_ca);
    }
    
    
    /**
     * Returns the right half of the split complement.
     *
     * A list is returned with the same darker and softer colors
     * as in the complementary list, but using the hue of the
     * right split complement instead of the complement itself.
     *
     * (per NodeBox documentation)
     *
     * @param c a base color
     */
    public static function rightComplement(c:uint):ColorPalette {
      var right:uint = splitComplementary(c).values[2];
      
      var ca:Array = complementary(c).values;
      var h:Number = Colors.hue(right);
      ca[3] = Colors.setHue(ca[3], h);
      ca[4] = Colors.setHue(ca[4], h);
      ca[5] = Colors.setHue(ca[5], h);
      
      var right_ca:Array = [];
      right_ca.push(ca[0]);
      right_ca.push(ca[2]);
      right_ca.push(ca[1]);
      right_ca.push(ca[5]);
      right_ca.push(ca[4]);
      right_ca.push(ca[3]);
      return new ColorPalette(right_ca);
    }
    
    
    /**
     * Returns colors that are next to each other on the wheel.
     *
     * These yield natural color schemes (like shades of water or sky).
     * The angle determines how far the colors are apart,
     * making it bigger will introduce more variation.
     * The contrast determines the darkness/lightness of
     * the analogue colors in respect to the given colors.
     *
     * @param c a base color
     * @param angle how far the colors are apart between 0-1, default=0.02777 (5 degrees)
     * @param contrast the darkness/lightness of the analogue colors with respect
     *   to the base colors, default=0.25
     *
     */
    public static function analagous(c:uint, angle:Number = 0.02777, contrast:Number = 0.25):ColorPalette {
      contrast = Maths.clampValue(contrast, 0, 1);
      var ca:Array = [];
      ca.push(c);
      for each (var arr:Array in[
        [1.0, 2.2],
        [2.0, 1.0],
        [-1.0, -0.5],
        [-2.0, -1.0]
      ]) {
        var i:Number = arr[0];
        var j:Number = arr[1];
        var t:Number = 0.44 - j * 0.1;
        var newc:uint = Colors.rotateColorwheel(c, angle * i);
        if (Colors.value(c) - contrast * j < t) {
          newc = Colors.setValue(newc, t);
        } else {
          newc = Colors.setValue(newc, Colors.value(c) - contrast * j);
        }
        newc = Colors.adjustSaturation(newc, -0.05);
        ca.push(newc);
      }
      return new ColorPalette(ca);
    }
    
    
    /**
     * Returns colors in the same hue with varying brightness/saturation.
     *
     * @param c a base color
     */
    public static function monochrome(c:uint):ColorPalette {
      function _wrap(x:Number, min:Number, threshold:Number, plus:Number):Number {
        return (x - min < threshold) ? x + plus : x - min;
      }
      
      var ca:Array = [];
      ca.push(c);
      
      var newc:uint;
      
      newc = c;
      newc = Colors.setValue(newc, _wrap(Colors.value(c), 0.5, 0.2, 0.3));
      newc = Colors.setSaturation(newc, _wrap(Colors.saturation(c), 0.3, 0.1, 0.3));
      ca.push(newc);
      
      newc = c;
      newc = Colors.setValue(newc, _wrap(Colors.value(c), 0.3, 0.1, 0.3));
      ca.push(newc);
      
      newc = c;
      var b:Number = Colors.value(c);
      newc = Colors.setValue(newc, Math.max(0.2, b + (1 - b) * 0.2));
      newc = Colors.setSaturation(newc, _wrap(Colors.saturation(c), 0.3, 0.1, 0.3));
      ca.push(newc);
      
      newc = c;
      newc = Colors.setValue(newc, _wrap(Colors.value(c), 0.5, 0.3, 0.2));
      ca.push(newc);
      
      return new ColorPalette(ca);
    }
    
    
    /**
     * Roughly the complement and some far analogs.
     *
     * @param c a base color
     */
    public static function compound(c:uint, flip:Boolean = false):ColorPalette {
      function _wrap(x:Number, min:Number, threshold:Number, plus:Number):Number {
        return (x - min < threshold) ? x + plus : x - min;
      }
      
      const d:int = (flip) ? -1 : 1;
      var ca:Array = [];
      ca.push(c);
      
      var newc:uint;
      
      newc = c;
      newc = Colors.rotateColorwheel(newc, d * 30.0 / 360);
      newc = Colors.setValue(newc, _wrap(Colors.value(c), 0.25, 0.6, 0.25));
      ca.push(newc);
      
      newc = c;
      newc = Colors.rotateColorwheel(newc, d * 30.0 / 360);
      newc = Colors.setSaturation(newc, _wrap(Colors.saturation(c), 0.4, 0.1, 0.4));
      newc = Colors.setValue(newc, _wrap(Colors.value(c), 0.4, 0.2, 0.4));
      ca.push(newc);
      
      newc = c;
      newc = Colors.rotateColorwheel(newc, d * 160.0 / 360);
      newc = Colors.setSaturation(newc, _wrap(Colors.saturation(c), 0.25, 0.1, 0.25));
      newc = Colors.setValue(newc, Math.max(0.2, Colors.value(c)));
      ca.push(newc);
      
      newc = c;
      newc = Colors.rotateColorwheel(newc, d * 150.0 / 360);
      newc = Colors.setSaturation(newc, _wrap(Colors.saturation(c), 0.1, 0.8, 0.1));
      newc = Colors.setValue(newc, _wrap(Colors.value(c), 0.3, 0.6, 0.3));
      ca.push(newc);
      
      newc = c;
      newc = Colors.rotateColorwheel(newc, d * 150.0 / 360);
      newc = Colors.setSaturation(newc, _wrap(Colors.saturation(c), 0.1, 0.8, 0.1));
      newc = Colors.setValue(newc, _wrap(Colors.value(c), 0.4, 0.2, 0.2));
      ca.push(newc);
      
      return new ColorPalette(ca);
    }
    
    
    /**
     * Roughly the complement and some far analogs.
     *
     * @param c a base color
     */
    public static function flippedCompound(c:uint):ColorPalette {
      return compound(c, true);
    }
    
    
    /**
     * Returns a triad of colors.
     *
     * The triad is made up of this color and two other colors
     * that together make up an equilateral triangle on
     * the artistic color wheel.
     *
     * @param c a base color
     * @param angle the angle between the colors beween 0-1
     *   the angle is calculated using the artistic color wheel
     *   default=0.33333 (120 degrees)
     */
    public static function triad(c:uint, angle:Number = 0.33333):ColorPalette {
      var ca:Array = [];
      ca.push(c);
      ca.push(Colors.lighten(Colors.rotateColorwheel(c, angle), 0.1));
      ca.push(Colors.lighten(Colors.rotateColorwheel(c, -angle), 0.1));
      return new ColorPalette(ca);
    }
    
    
    /**
     * Returns a tetrad of colors.
     *
     * The tetrad is made up of this color and three other colors
     * that together make up an square on
     * the artistic color wheel.
     *
     * @param c a base color
     * @param angle the angle between the colors beween 0-1
     *   the angle is calculated using the artistic color wheel
     *   default=0.25 (90 degrees)
     */
    public static function tetrad(c:uint, angle:Number = 0.25):ColorPalette {
      var ca:Array = [];
      ca.push(c);
      ca.push(Colors.lighten(Colors.rotateColorwheel(c, angle), (Colors.value(c) < 0.5) ? 0.2 : -0.2));
      ca.push(Colors.lighten(Colors.rotateColorwheel(c, 2 * angle), (Colors.value(c) < 0.5) ? 0.1 : -0.1));
      ca.push(Colors.lighten(Colors.rotateColorwheel(c, 3 * angle), 0.1));
      return new ColorPalette(ca);
    }
    
    
    /**
     * A color palette containing white and black
     */
    private static function whiteBlackColors():ColorPalette {
      return new ColorPalette([0xffffff, 0x000000]);
    }
    
    
    /**
     * A color palette containing six Google inspired colors as used
     * in google trend charts.
     *
     * Google colors are intense with high saturation.
     */
    private static function googleColors():ColorPalette {
      return new ColorPalette([0x4684ee, 0xdc3912, 0xff9900, 0x008000, 0x4942cc, 0x111111]);
    }
    
    
    /**
     * A color palette containing New York Times inspired colors as used
     * in NY Times visualizations.
     */
    private static function NYTimesColors():ColorPalette {
      var ca:Array = [];
      // TODO: determine appropriate colors for a New York Times color scheme
      for each (var c:uint in[0x4684ee, 0xdc3912, 0xff9900, 0x008000, 0x4942cc, 0x111111]) {
        ca.push(c);
      }
      return new ColorPalette(ca);
    }
    
    
    /**
     * A color palette containing Economist inspired colors as used
     * in Economist magazine graphs.
     */
    private static function EconomistColors():ColorPalette {
      var ca:Array = [];
      // TODO: determine appropriate colors for a Economist color scheme
      for each (var c:uint in[0x4684ee, 0xdc3912, 0xff9900, 0x008000, 0x4942cc, 0x111111]) {
        ca.push(c);
      }
      return new ColorPalette(ca);
    }
    
    /**
     * A color array containing a single color
     */
    public static function fromColor(c:uint):ColorPalette {
      var ca:Array = [c];
      return new ColorPalette(ca);
    }
    
    
    /**
     * Derives a color palette from a user input.
     *
     * <p>The value passed in can be a String, uint, or ColorPalette. If the value is a color
     * palette name, it can be prefixed with a "-" to reverse the palette.</p>
     *
     * <p>Some examples:</p>
     *
     * <ul>
     * <li><code>"0xff0000"</code> - A single color red palette</li>
     * <li><code>"#ff0000"</code> - A single color red palette (CSS notation)</li>
     * <li><code>"red"</code> - A single color red palette (CSS literal color notation)</li>
     * <li><code>"0x88ff0000"</code> - A semi-transparent single color red palette</li>
     * <li><code>0x88ff0000</code> - A semi-transparent single color red palette</li>
     * <li><code>"Reds"</code> - The built-in "Reds" ColorPalette</li>
     * <li><code>"-Reds"</code> - The built-in "Reds" ColorPalette reversed</li>
     * <li><code>ColorPalette.getPaletteByName('Reds').darken()</code> - A darker version of the built-in "Reds" ColorPalette</li>
     * <li><code>ColorPalette.getPaletteByName('Reds').darken(0.2).reverse()</code> - A still darker, reversed version of the built-in "Reds" ColorPalette</li>
     * </ul>
     *
     * @default 'spectral'
     */
    public static function fromString(v:*):ColorPalette {
      var _colorPalette:ColorPalette;
      
      if (v is ColorPalette) {
        _colorPalette = v;
      }
      else if (v is String) {
        // try to determine the color given a string
        var s:String = v as String;
        
        var c:uint = StyleManager.getStyleManager(null).getColorName(s);
        if (c != StyleManager.NOT_A_COLOR) {
          if (Colors.a(c) == 0) c = Colors.setAlpha(c, 255);
          _colorPalette = fromColor(c);
        } else {
          _colorPalette = getPaletteByName(v);
        }
      }
      else if (v is uint) {
        _colorPalette = fromColor(v);
      }
      
      return _colorPalette;
    }
    
    /**
     * [Deprecated(replacement="fromString")]
     */
    public static function fromHeuristic(v:*):ColorPalette {
      return fromString(v);
    }
    
  }
}