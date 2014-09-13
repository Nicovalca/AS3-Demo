/*******************************************************************************
 *                                                                              *
 * Author    :  Valcasara Nicola                                                *
 * Version   :  1.0.0                                                           *
 * Date      :  25 August 2014                                                  *
 * Website   :  http://nicolavalcasara.weebly.com/                              *                                         *
 *                                                                              *
 * License:                                                                     *
 * Use, modification & distribution is subject to GPL open source license		*
 * http://opensource.org/licenses/GPL-3.0                                      	*
 *                                                                              *
 * Class description:															*
 *                                                                              *
 *******************************************************************************/

package pathfinding
{
	import nape.phys.Body;
	import nape.phys.BodyType;
	
	import starling.display.Quad;
	import starling.display.Sprite;
	
	public class Wall extends Sprite
	{
		private var  _body:Body;
		
		public function Wall(x:int, y:int, widht:int, height:int)
		{
			super();
			body = new Body(BodyType.STATIC);
			var quad:Quad = new Quad(widht, height, 0x000000);
			quad.x =x;
			quad.y=y;
			addChild(quad);
			
		}

		public function get body():Body
		{
			return _body;
		}

		public function set body(value:Body):void
		{
			_body = value;
		}

	}
}