// Nicola Valcasara - 20/08/2014
// custom event - navigation handler

package events
{
	import starling.events.Event;
	
	public class NavigationEvents extends Event
	{
		public static const CHANGE_SCREEN:String = "changeScreen";
		
		public var params:Object
		
		public function NavigationEvents(type:String, _params:Object,bubbles:Boolean=false)
		{
			super(type, bubbles);
			params = _params;
		}
	}
}