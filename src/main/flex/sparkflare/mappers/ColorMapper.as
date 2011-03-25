
package sparkflare.mappers
{
	import org.juicekit.palette.ColorPalette;
	import org.juicekit.palette.IPalette;
	
	/**
	 * Maps a number value to a color uint.
	 */
	[Bindable]
	public class ColorMapper extends Mapper
	{
		
		/** 
		 * The palette used to map scale values to visual values. 
		 **/
		override public function get palette():IPalette {
			return _palette;
		}
		
		override public function set palette(p:*):void {
			if (p is ColorPalette) {
				_palette = p;
			} else {
				_palette = ColorPalette.fromString(p);
			} 	
		}
		
		
		/**
		 * Set exact values. 
		 */
		public function set targetValues(v:Array):void {
			palette.values = v;
		}
		
		public function get targetValues():Array {
			return palette.values;
		}
		
	} // end of class Encoder
}