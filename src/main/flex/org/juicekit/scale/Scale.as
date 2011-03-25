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
  import flash.events.EventDispatcher;
  
  import mx.core.IMXMLObject;
  
  import org.juicekit.util.Strings;
  

  /**
   * Dispatched when the scale has changed
   *
   * @eventType flash.events.Event
   */
  [Event(name="updateScale", type="flash.events.Event")]
  
  
  /**
   * Base class for all data scale types.
   */
  [Bindable]
  public class Scale extends EventDispatcher implements IMXMLObject
  {
    
    public static const UPDATE_SCALE:String = 'updateScale';
    
    /** Flag indicating if the scale bounds should be flush with the data.
     *  False by default, thereby allowing some padding space on the end
     *  of the scale. */
    protected var _flush:Boolean = false;
    /** Formatting pattern for formatting labels for scale values.
     *  @see flare.util.Strings#format */
    protected var _format:String = null;
    
    /**
     * Flag indicating if the scale bounds should be flush with the data.
     * If true, the scale should be flush with the data range, such that
     * the min and max values should sit directly on the extremes of the
     * scale. If false, the scale should be padded as needed to make the
     * scale more readable and human-friendly.
     */
    public function get flush():Boolean {
      return _flush;
    }
    
    public function set flush(val:Boolean):void {
      _flush = val;
    }
    
    /**
     * Formatting pattern for formatting labels for scale values.
     * For details about the various formatting patterns, see the
     * documentation for the <code>Strings.format</code> method.
     * @see flare.util.String#format
     */
    public function get labelFormat():String
    {
      return _format == null ? null : _format.substring(3, _format.length - 1);
    }
    
    public function set labelFormat(fmt:String):void
    {
      _format = (fmt == null ? fmt : "{0:" + fmt + "}");
    }
    
    /** The minimum data value backing this scale. Note that the actual
     *  minimum scale value may be lower if the scale is not flush. */
    public function get min():Object
    {
      throw new Error("Unsupported property");
    }
    
    public function set min(o:Object):void
    {
      throw new Error("Unsupported property");
    }
    
    /** The maximum data value backing this scale. Note that the actual
     *  maximum scale value may be higher if the scale is not flush. */
    public function get max():Object
    {
      throw new Error("Unsupported property");
    }
    
    public function set max(o:Object):void
    {
      throw new Error("Unsupported property");
    }
    
    /**
     * Returns a cloned copy of the scale.
     * @return a cloned scale.
     */
    public function clone():Scale
    {
      return null;
    }
    
    /**
     * Returns an interpolation fraction indicating the position of the input
     * value within the scale range.
     * @param value a data value for which to return an interpolation
     *  fraction along the data scale
     * @return the interpolation fraction of the value in the data scale
     */
    public function interpolate(value:Object):Number
    {
      return 0;
    }
    
    /**
    * Returns an index value for a categorical scale.
    */
    public function index(value:Object):int {
      return 0;
    }
    
    /**
     * Returns a string label representing a value in this scale.
     * The labelFormat property determines how the value will be formatted.
     * @param value the data value to get the string label for
     * @return a string label for the value
     */
    public function label(value:Object):String
    {
      if (_format == null) {
        return value == null ? "" : value.toString();
      } else {
        return Strings.format(_format, value);
      }
    }
    
    /**
     * Performs a reverse lookup, returning an object value corresponding
     * to a interpolation fraction along the scale range.
     * @param f the interpolation fraction
     * @return the scale value at the interpolation fraction. May return
     *  null if no value corresponds to the input fraction.
     */
    public function lookup(f:Number):Object
    {
      return null;
    }
    
    /**
     * Returns a set of label values for this scale.
     * @param num a desired target number of labels. This parameter is
     *  handled idiosyncratically by different scale sub-classes.
     * @return an array of label values for the scale
     */
    public function values(num:int = -1):Array
    {
      return null;
    }
    
    // -- MXML ------------------------------------------------------------
    
    /** @private */
    public function initialized(document:Object, id:String):void
    {
      // do nothing
    }
    
    /** Constructor */
    public function Scale():void {
      super();
    }
    
  } // end of class Scale
}