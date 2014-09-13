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
 * The main scene of the application. Here are initialized the scenes and is	* 
 * showed the welcome scene													    *
 *******************************************************************************/
package
{
	import events.NavigationEvents;
	
	import scenes.PathFinding_PoS;
	import scenes.LightningExample;
	import scenes.PathFinding_AStar;
	import scenes.Welcome;
	
	import scenes.AnimationScene;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;

	
	public class Demo extends Sprite
	{
		
		private var lightScene:LightningExample;
		private var pathFinding:PathFinding_AStar;
		private var clipper:PathFinding_PoS;
		private var animation:AnimationScene;
		
		private var welcomeScreen:Welcome;
		
		public function Demo()
		{
			super();
			this.addEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			this.removeEventListener(starling.events.Event.ADDED_TO_STAGE, onAddedToStage);
			
			initialize();
		}
		
		private function initialize():void
		{
			addEventListener(NavigationEvents.CHANGE_SCREEN, onChangeScreen);
			
			lightScene = new LightningExample();
			//pathFinding=new PathFinding_AStar();
			clipper=new PathFinding_PoS();
			animation = new AnimationScene();
			welcomeScreen = new Welcome();
			addChild(welcomeScreen);
			
		}
		
		// this method receive the bubbled custom event "change screen" from the different scenes
		// change the screen depending on his ID param
		private function onChangeScreen(event:NavigationEvents):void
		{
			switch (event.params.id)
			{
				case "Light Example":
					addChild(lightScene);
					break;
				// removed from the example scenes
				//case "Path Finding - Grid":
				//	addChild(pathFinding);
				//	break;
				case "Path Finding - Point of sight":
					addChild(clipper);
					break;
				case "Animation Scene":
					addChild(animation);
					break;
			}
			removeChild(welcomeScreen,false);
		}		
		
	}
}