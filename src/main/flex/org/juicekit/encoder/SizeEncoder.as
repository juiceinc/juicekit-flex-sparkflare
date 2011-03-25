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
  import org.juicekit.palette.IPalette;
  import org.juicekit.palette.SizePalette;
  import org.juicekit.scale.Scale;
  
  /**
   * Encodes a data field into size values, using a scale transform and a
   * size palette to determines an item's scale. The target property of a
   * SizeEncoder is assumed to be the <code>DataSprite.size</code> property.
   */
  [Bindable]
  public class SizeEncoder extends Encoder
  {
    protected var _palette:SizePalette;
    
    /** @inheritDoc */
    public override function get palette():* {
      return _palette;
    }
    
    public override function set palette(p:*):void {
      _palette = p;
      updateEncoder();
    }
    
    public function set paletteMin(v:Number):void {
      _palette.min = v;
      updateEncoder();
    }
    
    public function get paletteMin():Number {
      return _palette.min;
    }

    public function set paletteMax(v:Number):void {
      _palette.max = v;
      updateEncoder();
    }
    
    public function get paletteMax():Number {
      return _palette.max;
    }
    
	
	public function set paletteIs2D(v:Boolean):void {
		_palette.is2D = v;
		updateEncoder();
	}
	
	public function get paletteIs2D():Boolean {
		return _palette.is2D;
	}
    
    /** The palette as a SizePalette instance. */
    public function get sizes():SizePalette {
      return _palette;
    }
    
    // --------------------------------------------------------------------
    
    /**
     * Creates a new SizeEncoder. By default, the scale type is set to
     * a quantile scale grouped into 5 bins. Adjust the values of the
     * <code>scale</code> property to change these defaults.
     * @param source the source property
     * @param group the data group to process
     * @param palette the size palette to use. If null, a default size
     *  palette will be used.
     */
    public function SizeEncoder(source:String = null, target:String = "size",
                                 scale:Scale = null, palette:SizePalette = null)
    {
      super(source, target, scale);
      if (palette) {
        this.palette = palette;
      } else {
        this.palette = new SizePalette();
      }
	  paletteIs2D = false;
	  
    }
    
    /** @inheritDoc */
    [Bindable(event="updateEncoder")]
    override public function encode(val:Object):*
    {
      return _palette.getSize(scale.interpolate(val));
    }
    
  } // end of class SizeEncoder
}