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

package sparkflare.mappers
{  
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;
	
	import org.juicekit.animate.Transitioner;
	import org.juicekit.util.Property;
	
	/**
	 * Applies the properties in <code>targetValues</code> to
	 * each mappable item.
	 */
	[Bindable]
	public class PropertyMapper extends MapperBase
	{
		protected var _values:Object = {};
		protected var _defaultValues:Object = {};
		
		/**
		 * Set exact values. 
		 */
		public function set targetValues(v:Object):void {
			_values = v;
		}
		
		public function get targetValues():Object {
			return _values;
		}
		
		/**
		 * Set default values. 
		 */
		public function set defaultValues(v:Object):void {
			_defaultValues = v;
		}
		
		public function get defaultValues():Object {
			return _defaultValues;
		}
		
		
		/** @inheritDoc */
		override public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null, doImmediate:Boolean=false):void
		{
			if (enabled && targetValues) {
				var _t:Transitioner = (t != null ? t : Transitioner.DEFAULT);
				var restoreImmediate:Boolean = _t.immediate;
				if (immediate || doImmediate) _t.immediate = true;
				
				if (items) {
					var targetProps:Array = [];
					var defaultProps:Array = [];
					for (var _target:* in targetValues) {
						var targetProp:Property = Property.$(_target);
						targetProps.push(targetProp);
					}
					for (var _def:* in defaultValues) {
						var defaultProp:Property = Property.$(_def);
						defaultProps.push(defaultProp);
					}
					
					//					items.disableAutoUpdate();
					for each (var row:Object in items) {
						if (filterFn == null || filterFn(row)) {
							for each (var prop:Property in targetProps) {
								var newValue:Object = targetValues[prop.name];
								var oldValue:Object = targetProp.getValue(row);
								_t.setValue(row, prop.name, newValue);
								//								items.itemUpdated(row, prop.name, oldValue, newValue); 
							}
						} else {
							if (defaultProps.length > 0) {
								for each (prop in defaultProps) {
									newValue = defaultValues[prop.name];
									oldValue = defaultProp.getValue(row);
									_t.setValue(row, prop.name, newValue);
									//									items.itemUpdated(row, prop.name, oldValue, newValue); 
								}
							}
						}
					}
					//					items.enableAutoUpdate();
				}					
				
				_t.immediate = restoreImmediate;
				_t = null;
			}
		}
		
	} 
}