/*
* Copyright (c) 2007-2010 Regents of the University of California.
*   All rights reserved.
*
*   Redistribution and use in source and binary forms, with or without
*   modification, are permitted provided that the following conditions
*   are met:
*
*   1. Redistributions of source code must retain the above copyright
*   notice, this list of conditions and the following disclaimer.
*
*   2. Redistributions in binary form must reproduce the above copyright
*   notice, this list of conditions and the following disclaimer in the
*   documentation and/or other materials provided with the distribution.
*
*   3.  Neither the name of the University nor the names of its contributors
*   may be used to endorse or promote products derived from this software
*   without specific prior written permission.
*
*   THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
*   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
*   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
*   ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
*   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
*   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
*   OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
*   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
*   LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
*   OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
*   SUCH DAMAGE.
*/

package org.juicekit.encoder
{  
  import org.juicekit.animate.Transitioner;
  import org.juicekit.palette.ColorPalette;
  import org.juicekit.palette.IPalette;
  import org.juicekit.scale.Scale;
  
  /**
   * Encodes a data field into color values, using a scale transform and
   * color palette.
   */
  [Bindable]
  public class ColorEncoder extends Encoder
  {
    private var _palette:ColorPalette;
    private var _ordinal:Boolean = false;
    
    /** @inheritDoc */
    public override function get palette():* {
      return _palette;
    }
    
    public override function set palette(p:*):void {
      _palette = ColorPalette.fromString(p);
      updateEncoder();
    }
    
    /** The palette as a ColorPalette instance. */
    public function get colors():ColorPalette {
      return _palette;
    }
    
    // --------------------------------------------------------------------
    
    /**
     * Creates a new ColorEncoder.
     * @param source the source property
     * @param group the data group to encode ("nodes" by default)
     * @param target the target property ("lineColor" by default)
     * @param scaleType the type of scale to use. If null, the scale type
     *  will be determined by the underlying <code>ScaleBinding</code>
     *  instance, based on the type of data.
     * @param palette the color palette to use. If null, a default color
     *  palette will be determined based on the scale type.
     */
    public function ColorEncoder(source:String = null, target:String = "color",
                                 scale:Scale = null, palette:ColorPalette = null)
    {
      super(source, target, scale);
      this.palette = palette;
    }
    
    /** @inheritDoc */
    public override function operate(t:Transitioner = null):void
    {
      // create a default color palette if none explicitly set
      if (_palette == null) _palette = getDefaultPalette();
      super.operate(t); // run encoder
    }
    
    /**
     * Updates the encoder after a change to encoding parameters
     */
    override protected function updateEncoder(e:Event=null):void
    {
      dispatchEvent(new Event('updateEncoder'));
    }
    
    
    /** @inheritDoc */
    [Bindable(event="updateEncoder")]
    override public function encode(val:Object):*
    {
      if (_ordinal) {
        return _palette.getColorByIndex(scale.index(val)) as uint;
      } else {
        return _palette.getColor(scale.interpolate(val)) as uint;
      }
    }
    
    /**
     * Returns a default color palette based on the input scale.
     * @param scale the scale of values to map to colors
     * @return a default color palette for the input scale
     */
    protected function getDefaultPalette():ColorPalette
    {
      return ColorPalette.getPaletteByName('Blues') as ColorPalette;
      /// TODO: more intelligent color palette selection?
//      if (ScaleType.PERSISTENT_ORDINAL == _binding.scaleType)
//      {
//        return ColorPalette.category(20);
//      }
//      else if (ScaleType.isOrdinal(_binding.scaleType))
//      {
//        return ColorPalette.category(_binding.length);
//      }
//      else if (ScaleType.isQuantitative(_binding.scaleType))
//      {
//        var min:Number = Number(_binding.min);
//        var max:Number = Number(_binding.max);
//        if (min < 0 && max > 0)
//          return ColorPalette.diverging();
//      }
//      return ColorPalette.ramp();
    }
    
  } // end of class ColorEncoder
}