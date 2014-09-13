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
 * A platform class																*
 * it will contain an image and a static body									*
 * the static body typically is the bounds of the image							*
 *******************************************************************************/

package objects
{
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	
	
	public class Platform extends Sprite
	{
		private var _space:Space;
		private var body:Body;
		
		private var graphic:Image;
		
		public function Platform(space:Space)
		{
			_space = space;
			
			super();
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		private function initialize(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			initGraphic();
			initPhysic();
		}
		
		private function initGraphic():void
		{
			graphic = new Image(Assets.getTexture("Platform"));
			graphic.pivotX = graphic.width/2;
			graphic.pivotY = graphic.height/2;
			addChild(graphic);
		}
		
		
		private function initPhysic():void
		{
			body = new Body(BodyType.STATIC);
			body.shapes.add(new Polygon(Polygon.box(graphic.width-20, graphic.height-20)));
			body.position.setxy(x,y);
			body.space = _space;
		}
		
		
	}
}