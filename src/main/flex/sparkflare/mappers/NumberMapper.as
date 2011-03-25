
package sparkflare.mappers
{  
	
	/**
	 * Maps a number to a number.
	 */
	[Bindable]
	public class NumberMapper extends Mapper
	{		
		
		/**
		 * Set exact values. 
		 */
		public function set targetValues(v:Array):void {
			palette.values = v;
		}
		
		public function get targetValues():Array {
			return palette.values;
		}
				
	} // end of class NumberMapper
}