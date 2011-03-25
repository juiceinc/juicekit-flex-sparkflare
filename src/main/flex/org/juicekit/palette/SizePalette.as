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

package org.juicekit.palette
{
  /**
   * Palette for size values represeneted as scale factors. The SizePalette
   * class distinguishes between 1D and 2D scale factors, with a square
   * root being applied to 2D scale factors to ensure that area scales
   * linearly with the size value.
   */
  [Bindable]
  public class SizePalette extends Palette implements IPalette
  {
	private var _minSize:Number = 1;
	private var _maxSize:Number = 6;
    private var _range:Number = 6;
    private var _is2D:Boolean = false;
	private var _binCount:int = -1;
	
	public function set binCount(v:int):void {
		if (v != _binCount) {
			_binCount = v;
			updatePalette();
		}
	}
    
    /** The minimum scale factor in this size palette. */
    public function get min():Number {
      return _minSize;
    }
    
    public function set min(s:Number):void {
      _minSize = s;
	  _range = _maxSize - _minSize;
      updatePalette();
    }
    
    /** the maximum scale factor in this size palette. */
    public function get max():Number {
      return _minSize + _range;
    }
    
    public function set max(s:Number):void {
	  _maxSize = s;
      _range = _maxSize - _minSize;
      updatePalette();
    }
    
    /** Flag indicating if this size palette is for 2D shapes. */
    public function get is2D():Boolean {
      return _is2D;
    }
    
    public function set is2D(b:Boolean):void {
      _is2D = b;
      updatePalette();
    }
    
    // --------------------------------------------------------------------
    
    /**
     * Creates a new SizePalette.
     * @param minSize the minimum scale factor in the palette
     * @param maxSize the maximum scale factor in the palette
     * @param is2D flag indicating if the size values are for a 2D shape,
     *  false by default
     */
    public function SizePalette(minSize:Number = 1, maxSize:Number = 6, is2D:Boolean = false)
    {
      _minSize = minSize;
      _range = maxSize - minSize;
      _is2D = is2D;
    }
    
    /** @inheritDoc */
    [Bindable(event="updatePalette")]
    public override function getValue(f:Number):Object
    {
      return getSize(f);
    }
	
	private function binInterp(f:Number):Number {
		f = Math.floor(f*_binCount);
		if (f >= _binCount)
			f = _binCount - 1.0;
		return f / (_binCount - 1.0)			
	}
	
    
    /**
     * Retrieves the size value corresponding to the input interpolation
     * fraction. If the <code>is2D</code> flag is true, the square root
     * of the size value is returned.
     * @param f an interpolation fraction
     * @return the size value corresponding to the input fraction
     */
    [Bindable(event="updatePalette")]
    public function getSize(f:Number):Number
    {
      var s:Number;
      if (_values == null) {
		  if (_binCount != -1) 
			  f = binInterp(f);
		  s = _minSize + f * _range;
      } else {
        s = _values[uint(Math.round(f * (_values.length - 1)))];
      }
      return _is2D ? Math.sqrt(s) : s;
    }
    
  } // end of class SizePalette
}