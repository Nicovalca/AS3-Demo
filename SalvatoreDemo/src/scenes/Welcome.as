/*******************************************************************************
 *                                                                              *
 * Author    :  Valcasara Nicola                                                *
 * Version   :  1.0.0                                                           *
 * Date      :  August 2014                                                  	*
 * Website   :  http://nicolavalcasara.weebly.com/                              *                                         
 *                                                                              *
 * License:                                                                     *
 * Use, modification & distribution is subject to GPL open source license		*
 * http://opensource.org/licenses/GPL-3.0                                      	*
 *                                                                              *
 * Class description:															*
 * the Welcome scene, it show a menu and initialize the stats					*
 *******************************************************************************/


package scenes
{	
	import events.NavigationEvents;
	
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.Color;
	
	
	public class Welcome extends Sprite
	{
		private var menuChoices:Vector.<TextField>;
		
		public function Welcome()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			drawScreen();
		}
		
		private function drawScreen():void
		{
			menuChoices = new Vector.<TextField>;
			
			var lightScene:TextField = new TextField(300,52,"Light Example", "Verdana", 32, Color.WHITE, false);
			menuChoices.push(lightScene);
			
			// removed from the menu cause incomplete and obsolete
			// replaced by the Point of sight scene
			//var pathScene:TextField = new TextField(500,52,"Path Finding - Grid", "Verdana", 32, Color.WHITE, false);
			//menuChoices.push(pathScene);
			
			var pathScenePoint:TextField = new TextField(500,52,"Path Finding - Point of sight", "Verdana", 32, Color.WHITE, false);
			menuChoices.push(pathScenePoint);
			
			var animation:TextField = new TextField( 500,52,"Animation Scene", "Verdana", 32, Color.WHITE, false);
			menuChoices.push(animation);
			
			for (var i:int =0; i<menuChoices.length; ++i)
			{
				menuChoices[i].x = stage.stageWidth/2-menuChoices[i].width/2;
				menuChoices[i].y = stage.stageHeight/2-((menuChoices.length*78)/2)+(i*78);
				addChild(menuChoices[i]);
			}
			
			addEventListener(TouchEvent.TOUCH, onMenuClicked);
		}
		
		
		//receive the touch event
		// if is a textfield, dispatch event to change scene
		private function onMenuClicked(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
			
			if (touch)
			{
				var button:TextField = event.target as TextField;
				dispatchEvent(new NavigationEvents(NavigationEvents.CHANGE_SCREEN, { id: button.text }, true));
			}
		}
	}
}
