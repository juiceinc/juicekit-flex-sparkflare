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

package org.juicekit.scale
{
  import flash.events.Event;
  
  import org.juicekit.util.Maths;
  import org.juicekit.util.Strings;
  
  /**
   * Base class for representing quantitative numerical data scales.
   */
  [Bindable]
  public class QuantitativeScale extends Scale
  {
    /** The minimum data value. */
    protected var _dmin:Number;
    /** The maximum data value. */
    protected var _dmax:Number;
    /** The minimum value of the scale range. */
    protected var _smin:Number;
    /** The maximum value of the scale range. */
    protected var _smax:Number;
    /** The number base of the scale. */
    protected var _base:Number;
    
    /**
     * Creates a new QuantitativeScale.
     * @param min the minimum data value
     * @param max the maximum data value
     * @param base the number base to use
     * @param flush the flush flag for scale padding
     * @param labelFormat the formatting pattern for value labels
     */
    public function QuantitativeScale(min:Number = 0, max:Number = 0, base:Number = 10,
                                      flush:Boolean = false, labelFormat:String = Strings.DEFAULT_NUMBER)
    {
      this.base = base;
      this.dataMin = min;
      this.dataMax = max;
      this.flush = flush;
      this.labelFormat = labelFormat;
    }
    
    /** @inheritDoc */
    public override function clone():Scale
    {
      throw new Error("This is an abstract class");
    }
    
    // -- Properties ------------------------------------------------------
    
    /** @inheritDoc */
    public override function set flush(val:Boolean):void
    {
      _flush = val;
      updateScale();
    }
    
    /** @inheritDoc */
    public override function get min():Object {
      return dataMin;
    }
    
    public override function set min(o:Object):void {
      dataMin = Number(o);
    }
    
    /** @inheritDoc */
    public override function get max():Object {
      return dataMax;
    }
    
    public override function set max(o:Object):void {
      dataMax = Number(o);
    }
    
    /** The minimum data value. This property is the same as the
     *  <code>minimum</code> property, but properly typed. */
    public function get dataMin():Number
    {
      return _dmin;
    }
    
    public function set dataMin(val:Number):void
    {
      _dmin = val;
      updateScale();
    }
    
    /** The maximum data value. This property is the same as the
     *  <code>maximum</code> property, but properly typed. */
    public function get dataMax():Number
    {
      return _dmax;
    }
    
    public function set dataMax(val:Number):void
    {
      _dmax = val;
      updateScale();
    }
    
    /** The minimum value of the scale range. */
    public function get scaleMin():Number
    {
      return _smin;
    }
    
    /** The maximum value of the scale range. */
    public function get scaleMax():Number
    {
      return _smax;
    }
    
    /** The number base used by the scale.
     *  By default, base 10 numbers are assumed. */
    public function get base():Number
    {
      return _base;
    }
    
    public function set base(val:Number):void
    {
      _base = val;
    }
    
    // -- Scale Methods ---------------------------------------------------
    
    /**
     * Updates the scale range after a change to the data range.
     */
    protected function updateScale():void
    {
      if (!_flush) {
        var step:Number = getStep(_dmin, _dmax);
        _smin = step === 0 ? 0 : Math.floor(_dmin / (step / 4)) * step / 4;
        _smax = step === 0 ? 0 : Math.ceil(_dmax / (step / 4)) * step / 4;
      } else {
        _smin = _dmin;
        _smax = _dmax;
      }
      dispatchEvent(new Event('updateScale'));
    }
    
    /**
     * Returns the default step value between label values. The step is
     * computed according to the current number base.
     * @param min the minimum scale value
     * @param max the maximum scale value
     * @return the default step value between label values
     */
    protected function getStep(min:Number, max:Number):Number
    {
      var range:Number = max - min;
      var exp:Number = Math.round(Maths.log(range, _base)) - 1;
      return Math.pow(base, exp);
    }
    
    /** @inheritDoc */
    [Bindable(event="updateScale")]
    public override function lookup(f:Number):Object
    {
      return null;
    }
    
    /** @inheritDoc */
    [Bindable(event="updateScale")]
    public override function interpolate(value:Object):Number
    {
      return interp(Number(value));
    }
    
    /**
     * Returns the interpolation fraction for the given input number.
     * @param val the input number
     * @return the interpolation fraction for the input value
     */
    protected function interp(val:Number):Number
    {
      return -1;
    }
    
    /** @inheritDoc */
    [Bindable(event="updateScale")]
    public override function values(num:int = -1):Array /*Number*/
    {
      var a:Array = new Array();
      var range:Number = _smax - _smin;
      
      if (range == 0) {
        a.push(_smin);
      } else {
        var step:Number = getStep(_smin, _smax);
        var stride:Number = num < 0 ? 1 : Math.max(1, Math.floor(range / (step * num)));
        for (var x:Number = _smin; x <= _smax; x += stride * step) {
          a.push(x);
        }
      }
      return a;
    }
    
  } // end of class QuantitativeScale
}