package sparkflare.util
{
	import flash.events.IEventDispatcher;

	public interface ISelectionManager extends IEventDispatcher
	{
		function isSelected(obj:Object, overrideField:String=null):Boolean 
		
	}
}