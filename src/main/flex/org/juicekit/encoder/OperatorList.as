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
  import flash.utils.Proxy;
  import flash.utils.flash_proxy;
  
  import mx.collections.ArrayCollection;
  
  import org.juicekit.animate.Transitioner;
  import org.juicekit.util.Arrays;
  
  /**
   * An OperatorList maintains a sequential chain of operators that are
   * invoked one after the other. Operators can be added to an OperatorList
   * using the <code>add</code> method. Once added, operators can be
   * retrieved and set using their index in the lists, either with array
   * notation (<code>[]</code>) or with the <code>getOperatorAt</code> and
   * <code>setOperatorAt</code> methods.
   */
  [Bindable]
  public class OperatorList extends Proxy implements IOperator
  {
    // -- Properties ------------------------------------------------------
    
    protected var _enabled:Boolean = true;
    protected var _list:Array = new Array();
    private var _dataProvider:ArrayCollection;

    
    /** The array collection processed by this OperatorList. */
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
      Operator.applyParameters(this, params);
    }
    
    /** An array of the operators contained in the operator list. */
    public function set list(ops:Array):void {
      // first remove all current operators
      while (_list.length > 0) {
        removeOperatorAt(_list.length - 1);
      }
      // then add the new operators
      for each (var op:IOperator in ops) {
        add(op);
      }
    }
    
    /** The number of operators in the list. */
    public function get length():uint {
      return _list.length;
    }
    
    /** Returns the first operator in the list. */
    public function get first():Object {
      return _list[0];
    }
    
    /** Returns the last operator in the list. */
    public function get last():Object {
      return _list[_list.length - 1];
    }
    
    // --------------------------------------------------------------------
    
    /**
     * Creates a new OperatorList.
     * @param ops an ordered set of operators to include in the list.
     */
    public function OperatorList(...ops) {
      for each (var op:IOperator in ops) {
        add(op);
      }
    }
    
    /** @inheritDoc */
    public function setup():void
    {
      for each (var op:IOperator in _list) {
        op.setup();
      }
    }
    
    /**
     * Proxy method for retrieving operators from the internal array.
     */
    flash_proxy override function getProperty(name:*):*
    {
      return _list[name];
    }
    
    /**
     * Proxy method for setting operators in the internal array.
     */
    flash_proxy override function setProperty(name:*, value:*):void
    {
      if (value is IOperator) {
        var op:IOperator = IOperator(value);
        _list[name] = op;
        op.dataProvider = dataProvider;
      } else {
        throw new ArgumentError("Input value must be an IOperator.");
      }
    }
    
    /**
     * Returns the operator at the specified position in the list
     * @param i the index into the operator list
     * @return the requested operator
     */
    public function getOperatorAt(i:uint):IOperator
    {
      return _list[i];
    }
    
    /**
     * Removes the operator at the specified position in the list
     * @param i the index into the operator list
     * @return the removed operator
     */
    public function removeOperatorAt(i:uint):IOperator
    {
      return Arrays.removeAt(_list, i) as IOperator;
    }
    
    /**
     * Set the operator at the specified position in the list
     * @param i the index into the operator list
     * @param op the operator to place in the list
     * @return the operator previously at the index
     */
    public function setOperatorAt(i:uint, op:IOperator):IOperator
    {
      var old:IOperator = _list[i];
      op.dataProvider = dataProvider;
      _list[i] = op;
      return old;
    }
    
    /**
     * Adds an operator to the end of this list.
     * @param op the operator to add
     */
    public function add(op:IOperator):void
    {
      op.dataProvider = dataProvider;
      _list.push(op);
    }
    
    /**
     * Removes an operator from this list.
     * @param op the operator to remove
     * @return true if the operator was found and removed, false otherwise
     */
    public function remove(op:IOperator):Boolean
    {
      return Arrays.remove(_list, op) >= 0;
    }
    
    /**
     * Removes all operators from this list.
     */
    public function clear():void
    {
      Arrays.clear(_list);
    }
    
    /** @inheritDoc */
    public function operate(t:Transitioner = null):void
    {
      t = (t != null ? t : Transitioner.DEFAULT);
      for each (var op:IOperator in _list) {
        if (op.enabled) op.operate(t);
      }
    }
    
    // -- MXML ------------------------------------------------------------
    
    /** @private */
    public function initialized(document:Object, id:String):void
    {
      // do nothing
    }
    
  } // end of class OperatorList
}