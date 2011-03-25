package org.juicekit.palette
{
  public interface IPalette
  {
	  
	  /** The number of values in the palette. */
	  function get size():int;
	  
	  /** Array of palette values. */
	  function get values():Array;
	  function set values(a:Array):void;
	  
	  function get length():int;
	  function set length(v:int):void; 

	  function getValue(f:Number):Object;
	  function initialized(document:Object, id:String):void;
	  
  }
}