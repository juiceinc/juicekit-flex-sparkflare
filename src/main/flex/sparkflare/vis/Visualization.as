package sparkflare.vis
{
	import spark.components.DataGroup;
	import spark.components.Group;

	/**
	 * A Visualization is a  
	 * 
	 * Group
	 * 	 DataGroup (for visualization items)
	 *     dataProvider
	 *     itemRenderer
	 *   AnnotationDataGroup [DEFERRED]
	 *     annotationDataProvider
	 *     annotationItemRenderer
	 *   AxisGroup (for axis and gridlines)
	 *     labelItemRenderer
	 *     gridlineItemRenderer
	 */
	public class Visualization extends Group implements IVisualization
	{
		
		public var dataGroup:DataGroup = new DataGroup();
		public var axisGroup:Group =  new Group();
		
		// Not implemented yet.
		public var annotationGroup:DataGroup = new DataGroup();
		
		/**
		 * Constructor
		 */
		public function Visualization()
		{
			this.addElement(dataGroup);
			this.addElement(axisGroup);			
		}
	}
}