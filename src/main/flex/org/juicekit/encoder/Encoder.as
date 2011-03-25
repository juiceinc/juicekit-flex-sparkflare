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
  import flash.events.Event;
  
  import mx.events.CollectionEvent;
  
  import org.juicekit.animate.Transitioner;
  import org.juicekit.palette.IPalette;
  import org.juicekit.palette.Palette;
  import org.juicekit.scale.LinearScale;
  import org.juicekit.scale.Scale;
  import org.juicekit.util.Filter;
  import org.juicekit.util.Property;
  
  /**
   * Dispatched when the encoder has changed
   *
   * @eventType flash.events.Event
   */
  [Event(name="updateEncoder", type="flash.events.Event")]
  
  
  
  /**
   * Base class for Operators that perform encoding of visual variables such
   * as color, shape, and size. All Encoders share a similar structure:
   * A source property (e.g., a data field) is mapped to a target property
   * (e.g., a visual variable) using a <tt>ScaleBinding</tt> instance to map
   * between values and a <tt>Palette</tt> instance to map scaled output
   * into visual variables such as color, shape, and size.
   */
  [Bindable]
  public class Encoder extends Operator
  {
    /** Boolean function indicating which items to process. */
    protected var _filter:Function;
    /** The target property. */
    protected var _target:String;
    /** A transitioner for collecting value updates. */
    protected var _t:Transitioner;
    protected var _scale:Scale;
    protected var _source:String;
    
    /** A scale binding to the source data. */
    public function get scale():Scale {
      return _scale;
    }
    
    public function set scale(s:Scale):void {
      if (s is Scale) {
        if (scale) {
          _scale.removeEventListener(Scale.UPDATE_SCALE, updateEncoder);
        }
        _scale = s;
        _scale.addEventListener(Scale.UPDATE_SCALE, updateEncoder);
        updateEncoder();        
      }
    }
    
    /**
     * Set the encoder's scale maximum value
     */
    public function set scaleMax(v:Object):void {
      scale.max = v;
    }
    
    public function get scaleMax():Object {
      return scale.max;
    }

    /**
     * Set the encoder's scale minimum value
     */
    public function set scaleMin(v:Object):void {
      scale.min = v;
    }
    
    public function get scaleMin():Object {
      return scale.min;
    }
    
    /**
    * Set the encoder's palette length
    */
    public function set paletteLength(v:Number):void {
      (palette as Palette).length = v;
    }

    public function get paletteLength():Number {
      return (palette as Palette).length;
    }
    
    
    
        
    /** Boolean function indicating which items to process. Only items
     *  for which this function return true will be considered by the
     *  labeler. If the function is null, all items will be considered.
     *  @see flare.util.Filter */
    public function get filter():Function {
      return _filter;
    }
    
    public function set filter(f:*):void {
      _filter = Filter.$(f);
      updateEncoder();
    }
    
    /** The source property. */
    public function get source():String {
      return _source;
    }
    
    public function set source(f:String):void {
      _source = f;
      updateEncoder();
    }
    
    /** The target property. */
    public function get target():String {
      return _target;
    }
    
    public function set target(f:String):void {
      _target = f;
      updateEncoder();
    }
    
    /** The palette used to map scale values to visual values. */
    public function get palette():* {
      return null;
    }
    
    public function set palette(p:*):void {
    }
    
    /**
     * Updates the encoder after a change to encoding parameters
     */
    protected function updateEncoder(e:Event=null):void
    {
      dispatchEvent(new Event('updateEncoder'));
    }
    
    
    // --------------------------------------------------------------------
    
    /**
     * Creates a new Encoder.
     * @param source the source property
     * @param target the target property
     * @param group the data group to process
     * @param filter a filter function controlling which items are encoded
     */
    public function Encoder(source:String = null, target:String = null, scale:Scale = null, filter:* = null)
    {
      _source = source;
      _target = target;
      if (scale == null) {
        this.scale = new LinearScale();
      } else {
        this.scale = scale;
      }
      
      this.filter = filter;
      
    }
    
    /** @inheritDoc */
    public override function setup():void
    {
    }
    
    /** @inheritDoc */
    public override function operate(t:Transitioner = null):void
    {
      _t = (t != null ? t : Transitioner.DEFAULT);
      var p:Property = Property.$(_source);
      
      var targetProp:Property = Property.$(_target);
      if (dataProvider) {
        dataProvider.disableAutoUpdate();
        for each (var row:Object in dataProvider) {
          var oldValue:Object = targetProp.getValue(row);
          var newValue:Object = encode(p.getValue(row));
          _t.setValue(row, _target, newValue);
          dataProvider.itemUpdated(row, _target, oldValue, newValue); 
        }
        dataProvider.enableAutoUpdate();
      }
      
      _t = null;
    }
    
    /**
     * Computes an encoding for the input value.
     * @param val a data value to encode
     * @return the encoded visual value
     */
    [Bindable(event="updateEncoder")]
    public function encode(val:Object):*
    {
      // sub-classes can override this
      return null;
    }
    
  } // end of class Encoder
}