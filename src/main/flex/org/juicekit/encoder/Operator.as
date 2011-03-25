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
  import mx.collections.ArrayCollection;
  
  import org.juicekit.animate.Transitioner;
  import org.juicekit.interfaces.IEvaluable;
  import org.juicekit.util.Property;

  /**
   * Operators performs processing tasks on the contents of a Visualization.
   * These tasks include layout, and color, shape, and size encoding.
   * Custom operators can be defined by subclassing this class.
   */
  public class Operator implements IOperator
  {
    // -- Properties ------------------------------------------------------
    private var _enabled:Boolean = true;
    
    private var _dataProvider:ArrayCollection;

    /** The array collection processed by this operator. */
    public function get dataProvider():ArrayCollection {
      return _dataProvider;
    }
    
    public function set dataProvider(v:ArrayCollection):void {
      _dataProvider = v;
      setup();
    }
    
    
    
    /** Indicates if the operator is enabled or disabled. */
    public function get enabled():Boolean {
      return _enabled;
    }
    
    public function set enabled(b:Boolean):void {
      _enabled = b;
    }
    
    /** @inheritDoc */
    public function set parameters(params:Object):void
    {
      applyParameters(this, params);
    }
    
    // -- Methods ---------------------------------------------------------
    
    /**
     * Performs an operation over the contents of a visualization.
     * @param t a Transitioner instance for collecting value updates.
     */
    public function operate(t:Transitioner = null):void {
      // for sub-classes to implement
    }
    
    /**
     * Setup method invoked whenever this operator's visualization
     * property is set.
     */
    public function setup():void
    {
      // for subclasses
    }
    
    // -- MXML ------------------------------------------------------------
    
    /** @private */
    public function initialized(document:Object, id:String):void
    {
      // do nothing
    }
    
    // -- Parameterization ------------------------------------------------
    
    /**
     * Static method that applies parameter settings to an operator.
     * @param op the operator
     * @param p the parameter object
     */
    public static function applyParameters(op:IOperator, params:Object):void
    {
      if (op == null || params == null) return;
      var o:Object = op as Object;
      for (var name:String in params) {
        var p:Property = Property.$(name);
        var v:* = params[name];
        var f:Function = v as Function;
        if (v is IEvaluable) f = IEvaluable(v).eval;
        p.setValue(op, f == null ? v : f(op));
      }
    }
    
    /** Constructor */
    public function Operator():void {
      super();
    }
    
  } // end of class Operator
}