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
  import org.juicekit.util.Shapes;
  
  /**
   * Palette for shape values that maps integer indices to shape drawing
   * functions.
   * @see flare.vis.util.graphics.Shapes
   */
  public class ShapePalette extends Palette
  {
    /**
     * Creates a new, empty ShapePalette.
     */
    public function ShapePalette() {
      _values = new Array();
    }
    
    /**
     * Adds a shape to this ShapePalette.
     * @param shape the name of the shape. This name should be registered
     *  with a drawing function using the
     *  <code>flare.vis.util.graphics.Shapes</code> class.
     */
    public function addShape(shape:String):void
    {
      _values.push(shape);
    }
    
    /**
     * Gets the shape at the given index into the palette.
     * @param idx the index of the shape
     * @return the name of the shape
     */
    public function getShape(idx:uint):String
    {
      return _values[idx % _values.length];
    }
    
    /**
     * Sets the shape at the given index into the palette.
     * @param idx the index of the shape
     * @param shape the name of the shape. This name should be registered
     *  with a drawing function using the
     *  <code>flare.vis.util.graphics.Shapes</code> class.
     */
    public function setShape(idx:uint, shape:String):void
    {
      _values[idx] = shape;
    }
    
    /**
     * Returns a default shape palette instance. The default palette
     * consists of (in order): circle, square, cross, "x", diamond,
     * down-triangle, up-triangle, left-triangle, and right-triangle
     * shapes.
     * @return the default shape palette
     */
    public static function defaultPalette():ShapePalette
    {
      var p:ShapePalette = new ShapePalette();
      p.addShape(Shapes.CIRCLE);
      p.addShape(Shapes.SQUARE);
      p.addShape(Shapes.CROSS);
      p.addShape(Shapes.X);
      p.addShape(Shapes.DIAMOND);
      p.addShape(Shapes.TRIANGLE_DOWN);
      p.addShape(Shapes.TRIANGLE_UP);
      p.addShape(Shapes.TRIANGLE_LEFT);
      p.addShape(Shapes.TRIANGLE_RIGHT);
      return p;
    }
    
  } // end of class ShapePalette
}