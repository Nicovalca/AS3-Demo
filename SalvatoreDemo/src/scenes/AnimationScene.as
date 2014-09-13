/*******************************************************************************
 *                                                                              *
 * Author    :  Valcasara Nicola                                                *
 * Version   :  1.0.0                                                           *
 * Date      :  August 2014                                                     *
 * Website   :  http://nicolavalcasara.weebly.com/                              *                                         
 *                                                                              *
 * License:                                                                     *
 * Use, modification & distribution is subject to GPL open source license		*
 * http://opensource.org/licenses/GPL-3.0                                      	*
 *                                                                              *
 * Class description:															*
 * Animation Example Scene                                                      *
 * This class handle an example scene that shows the animation tree behaviour	*
 *******************************************************************************/

package scenes
{
	import flash.display.MovieClip;
	import flash.sampler.StackFrame;
	import flash.ui.Keyboard;
	
	import nape.geom.Vec2;
	import nape.space.Space;
	import nape.util.ShapeDebug;
	
	import objects.Character;
	import objects.Platform;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;
	
	import utils.Input;
	
	public class AnimationScene extends Sprite
	{
		private var space:Space;			// the space where nape will work
		private var debug:ShapeDebug;		// a debugger to see the phisyc in action
		
		private var dyno:Character;			// the main character of the scene
		private var platform:Platform;		// a static platform
		private var instruction:TextField;	// an instruction label
		
		private var keysDown:Array;			// boolean array: it will contain the key pressed by the user
		
		public function AnimationScene()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		private function initialize(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			debug = new ShapeDebug(stage.stageWidth, stage.stageHeight, stage.color);
			var MovieClipDebug:flash.display.MovieClip = new flash.display.MovieClip();
			MovieClipDebug.addChild(debug.display);
			starling.core.Starling.current.nativeOverlay.addChild(MovieClipDebug);
			
			space = new Space(Vec2.weak(0,0));					// initialize the space with no gravity at all
			keysDown = new Array();								// initialize the array
			
			platform = new Platform(space);						// initialize the platform and add to the scene
			platform.x = stage.width/2;							// every object that need phisic has the space as parameter
			platform.y = 600;
			addChild(platform);
			
			dyno = new Character(space);						// initialize the player. 
			dyno.x = 200;
			dyno.y = 400;
			addChild(dyno);
			
			// the instruction label
			var txt:String = "Animation Scene \n" +
				"\n" +
				" - arrows: move \n" +
				" - spacebar: jump \n" +
				" - q: attack \n" +
				" - w: apologize \n" +
				" - e: eat";
			
			instruction = new TextField(250,300, txt, "Verdana", 24, 0xffffff, false);
			instruction.x = stage.width-250;
			instruction.y = 10;
			instruction.hAlign = "left";
			addChild(instruction);
			
			addEventListener(Event.ENTER_FRAME, update);
			addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			addEventListener(KeyboardEvent.KEY_UP, keyReleased);
		}
		
		// handle the key release events and update the inputs
		private function keyReleased(key:KeyboardEvent):void
		{
			keysDown[key.keyCode] = false;
			keyReleaseCheck(key.keyCode);
		}
		
		// handle the key pressed by the user
		// the keysDown array help to keep the input check just once
		private function keyPressed(key:KeyboardEvent):void
		{
			if (!isKeyDown(key.keyCode))
			{
				keysDown[key.keyCode] = true;
				checkInputs(key.keyCode);
			}
		}
		
		// called by the key releae event.
		// stop the character if is a movement key
		private function keyReleaseCheck(key:int):void
		{
			if (key == Input.LEFT || key == Input.RIGHT)
				dyno.stop();
		}
		
		/**
		 * 
		 * @param keycode: the key to check
		 * @return true if pressed
		 * 
		 */		
		private function isKeyDown(keycode:Number):Boolean 
		{
			return keysDown[keycode];
		}
		
		// tick event
		// it will call the step event of the space (with the deltaTime as parameter)
		// and it will refresh the debug objects
		private function update(event:Event):void
		{
			space.step(1/24);
			
			debug.clear();
			debug.draw(space);
			debug.flush();
		}
		
		// called once when a key is pressed
		private function checkInputs(key:int):void
		{
			switch (key)
			{
				case Input.LEFT:
					dyno.move(-1);
					break;
				case Input.RIGHT:
					dyno.move(1);
					break;
				case Input.JUMP:
					dyno.jump();
					break;
				case Input.APOLOGIZE:
					dyno.apologize();
					break;
				case Input.EAT:
					dyno.eat();
					break
				case Input.FIRE:
					dyno.fire();
					break
			}
		}
	}
}