/*******************************************************************************
 *                                                                              *
 * Author    :  Valcasara Nicola                                                *
 * Version   :  1.0.0                                                           *
 * Date      :  August 2014														*                                                
 * Website   :  http://nicolavalcasara.weebly.com/                              *                                        
 *                                                                              *
 * License:                                                                     *
 * Use, modification & distribution is subject to GPL open source license		*
 * http://opensource.org/licenses/GPL-3.0                                      	*
 *                                                                              *
 * Class description:															*
 * The light example scene.														*
 * it will use an external library (starling lighting extension)                *
 * this scene show how this library can be implemented							*
 *******************************************************************************/

package scenes
{
	import flash.display.Stage;
	
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.extensions.lighting.core.LightLayer;
	import starling.extensions.lighting.geometry.QuadShadowGeometry;
	import starling.extensions.lighting.lights.PointLight;
	import starling.extensions.lighting.lights.SpotLight;
	import starling.utils.Color;
	
	import starling.core.Starling;
	
	public class LightningExample extends Sprite
	{
		private var bgImage:Image;

		private var lightLayer:LightLayer;
		
		private var spotLight:SpotLight;
		private var pointLight:PointLight;
		private var pointLights:Vector.<PointLight>;
		
		private var mouseLight:PointLight;
		private var touch:Touch;
		private var mouseX:Number;
		private var mouseY:Number;
		
		private var hScale:Number;
		private var vScale:Number;
		
		private var button:Button;
		
		private var state:int;
		private var direction:int;
		
		public function LightningExample()
		{
			super();
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			initialize();
			
		}
		
		private function initialize():void
		{	
			state = 0;
			direction = 1;
			
			bgImage = new Image(Assets.getTexture("lightMain"));
			//determine the resolution scale before resize the image
			hScale = stage.stageWidth/bgImage.width;
			vScale = stage.stageHeight/bgImage.height;
			//resize it to fit the screen
			bgImage.height = stage.stageHeight;
			bgImage.width = stage.stageWidth;
			addChild(bgImage);
			
			// generate the lightLayer, it will contain all the light of the stage
			// give him a full dark black that fit all the scene
			lightLayer = new LightLayer(stage.stageWidth, stage.stageHeight, Color.BLACK, 0);
			
			addChild(lightLayer);
			
			//add the bgImage overlay to make a fake effect of not be affected by the light layer
			bgImage = new Image(Assets.getTexture("lightMain_Over"));
			bgImage.height = stage.stageHeight;
			bgImage.width = stage.stageWidth;
			addChild(bgImage);
			
			button = new Button(Assets.getTexture("btnImage"), "Show Lights");
			button.x = stage.stageWidth/2-90;
			button.y = 30;
			button.height = 60;
			button.width = 180;
			button.fontSize = 48;
			addChild(button);
			
			button.addEventListener(Event.TRIGGERED, onButtonClicked);
			
		}
		
		private function onButtonClicked(event:Event):void
		{
			switch (state)
			{
				case 0:
					createLight();
					button.text="Add Geometry";
					break;
				
				case 1:
					createGeometry();
					button.text ="Add Dynamic";
					break;
				case 2:
					addEventListener(EnterFrameEvent.ENTER_FRAME, updateSpotLight);
					button.text = "Add MouseLight";
					break;
				case 3:
					stage.addEventListener(TouchEvent.TOUCH, updateMouseLight);
					removeEventListener(EnterFrameEvent.ENTER_FRAME, updateSpotLight);
					lightLayer.removeLight(spotLight);
					mouseLight = new PointLight(0, 0, 200, Color.YELLOW, 0.6);
					lightLayer.addLight(mouseLight);
					button.text = "Add light effect";
					break;
				case 4:
					addEventListener(EnterFrameEvent.ENTER_FRAME, updateFireEffect);
					break;
			}
			state++;
		}
		
		private function updateFireEffect(event:EnterFrameEvent):void
		{
			for each (var light:PointLight in pointLights)
			{
				if (light.brightness < 0.6)
					light.brightness = 0.6+ Math.random()*0.4;
				else
					light.brightness-=0.01;
				//light.brightness = light.brightness + (Math.random()*2)-1;
			}
		}
		
		private function updateSpotLight():void
		{
			spotLight.x += direction;
			if (spotLight.x > stage.stageWidth || spotLight.x < 30 ) direction = -direction;
		}
		
		// on touch events used only to change the coordinates of the mouse light 
		private function updateMouseLight(event:TouchEvent):void
		{
			mouseLight.x = Starling.current.nativeStage.mouseX;
			mouseLight.y = Starling.current.nativeStage.mouseY;
		}		
		
		//create the geometry of the walls and all the objects that block the lightSource
		private function createGeometry():void
		{	
			//initialize a vector of coordinates for the shaders objects
			//for a better use, is probably better an xml file that contains all the references
			//of different assets. This is only for example sake
			var coordinates:Vector.<Vector.<int>> = new <Vector.<int>> [ 
				new <int>[185,435], new <int>[435,185],
				new <int>[435,435],	new <int>[185,185],
				new <int>[310,310]];
			
			//i'm generating a standard quad of the dimention of a tile.
			// i'll use the same for all the obstacles.
			// I'm using quad to keep the drawcall low but it works also with complex objects.
			var w:int = 30*hScale;
			var h:int = 30*vScale;
			var quad:Quad = new Quad(w,h,0x000000);
			
			for (var i:int=0; i<coordinates.length;++i)
			{
				quad = new Quad(w,h,0x000000);
				quad.x = coordinates[i][0] *hScale;
				quad.y = coordinates[i][1] *vScale;
				lightLayer.addShadowGeometry(new QuadShadowGeometry(quad));
			}
		}		
		
		private function createLight():void
		{
			//needed for further manipulations
			pointLights = new Vector.<PointLight>();
			
			//add 4 pointLight on the 4 corners
			pointLight = new PointLight(620*hScale,30*vScale,400,Color.WHITE,0.8);
			pointLights.push(pointLight);
			lightLayer.addLight(pointLight);
			
			
			pointLight = new PointLight(30*hScale,30*vScale,400,Color.WHITE,0.8);
			pointLights.push(pointLight);
			lightLayer.addLight(pointLight);
			
			pointLight = new PointLight(30*hScale,620*vScale,400,Color.WHITE,0.5);
			pointLights.push(pointLight);
			lightLayer.addLight(pointLight);
			
			pointLight = new PointLight(620*hScale,620*vScale,400,Color.WHITE,0.5);
			pointLights.push(pointLight);
			lightLayer.addLight(pointLight);
			
			spotLight = new SpotLight(stage.stageWidth/2, 30, 800, 90, 90, 20, Color.RED, 1);
			pointLights.push(pointLight);
			lightLayer.addLight(spotLight);
		}
	
	}
}