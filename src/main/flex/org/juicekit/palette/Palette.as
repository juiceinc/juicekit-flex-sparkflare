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
  import flash.events.Event;
  import flash.events.EventDispatcher;
  
  import mx.core.IMXMLObject;

  /**
   * Dispatched when the palette has changed
   *
   * @eventType flash.events.Event
   */
  [Event(name="updatePalette", type="flash.events.Event")]
  
  
  
  /**
   * Base class for palettes, such as color and size palettes, that map from
   * interpolated scale values into visual properties
   */
  [Bindable]
  public class Palette extends EventDispatcher implements IMXMLObject, IPalette
  {
	  protected var _binCount:int = -1;
	  
	  public function set binCount(v:int):void {
		  if (v == 0) v = -1;
		  if (v != _binCount) {
			  _binCount = v;
			  updatePalette();
		  }
	  }
	  
	  public function get binCount():int {
		  return _binCount;
	  }
	  
    
    /** Array of palette values. */
    protected var _values:Array;
    
    /** The number of values in the palette. */
    public function get size():int {
      return _values == null ? 0 : _values.length;
    }
    
    /** Array of palette values. */
    public function get values():Array {
      return _values;
    }
    
    public function set values(a:Array):void {
      _values = a;
      updatePalette();
    }
    
    [Bindable(event='updatePalette')]
    public function get length():int {
		if (_values) {
			return _values.length;
		} else {
			return -1;
		}
    }
    
    public function set length(v:int):void {   
    }
    
    protected function updatePalette():void {
      dispatchEvent(new Event('updatePalette'));  
    }
	
	/**
	 * Interpolate a fraction into bins
	 */
	protected function binInterp(f:Number):Number {
		const cnt:int = binCount;
		f = Math.floor(f*cnt);
		if (f >= cnt)
			f = cnt - 1.0;
		return f / (cnt - 1.0)			
	}
	
	
    
    /**
     * Retrieves the palette value corresponding to the input interpolation
     * fraction.
     * @param f an interpolation fraction
     * @return the palette value corresponding to the input fraction
     */
    [Bindable(event="updatePalette")]
    public function getValue(f:Number):Object
    {
      if (binCount != -1) 
		f = binInterp(f);
      if (_values == null || _values.length == 0)
        return 0;
      return _values[uint(Math.round(f * (_values.length - 1)))];
    }
    
    /** Constructor */
    public function Palette():void {
      super();
    }
    
    // -- MXML ------------------------------------------------------------
    
    /** @private */
    public function initialized(document:Object, id:String):void
    {
      // do nothing
    }
    
  } // end of class Palette
}