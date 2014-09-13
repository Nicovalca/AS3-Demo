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
 * Character controller.														*
 * This class contains all the needed to control a character					*				
 *  - movement																	*
 *  - phisyc																	*
 *  - animations																*
 *  - events                                                               		*
 *******************************************************************************/

package objects
{
	import animations.AnimTree;
	
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Character extends Sprite
	{
		private var _space:Space;
	
		private var dyno:Image;
		private var body:Body;
		private var anim:AnimTree;
		
		private var direction:int =0;
		
		private var isJumping:Boolean = false;
		
		private const deltaTime:Number = 1/24;
		private const zeroFriction:Material = new Material(0,0,0);
		
		
		public function Character(space:Space)
		{
			super();
			
			_space = space;
			
			addEventListener(Event.ADDED_TO_STAGE, initialize);
		}
		
		private function initialize(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			
			initAnimations();	
			initPhysic();
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function initAnimations():void
		{
			anim = new AnimTree(Assets.getAtlas(),128);
			//add pivot to his middle
			anim.pivotX = 64;
			anim.pivotY = 64;
			
			anim.addClip("walk", "walk_", true, 18);
			anim.addClip("startJump", "jump_", false,24);
			anim.addClip("jumpLoop", "jumpLoop_");
			anim.addClip("land", "land_", false,48);
			anim.addClip("bless", "bless_", false);
			anim.addClip("eat", "eat_", false);
			anim.addClip("fire", "fire_", false);
			
			Starling.juggler.add(anim);
			addChild(anim);
		}
		
		
		private function initPhysic():void
		{
			body = new Body(BodyType.DYNAMIC);						// create the body
			body.shapes.add(new Polygon(Polygon.box(80,120)));		// make a box that contains the graphic
			body.setShapeMaterials(zeroFriction);					// add a no-friction material. absolutly not realistic, but good for our simple simulation
			body.allowRotation = false;								// avoid wrong raycast
			body.position.setxy(x,y);								// align his position with the object
			body.space = _space;									// add it to the nape space
		}
		
		private function update(event:Event):void
		{
			x = body.position.x;
			y = body.position.y;		
			
			updateMovement();
		}
		
		private function updateMovement():void
		{
			if (!grounded())
			{
				//apply fake gravity
				body.applyImpulse(new Vec2(0,100));
			}
			else
			{
				if (isJumping)
				{
					anim.play("land", nextAnim);
					isJumping=false;
				}
			}
	
			body.velocity.x = direction*deltaTime*1000;
		}
		
		/**
		 * 
		 * @param direction
		 * @param deltaTime
		 * 
		 */
		public function move(_direction:int):void
		{
			scaleX = _direction;
			direction = _direction;
			if (grounded())
				anim.play("walk");
		}
		
		// called by 
		public function stop():void { 
			direction =0;
			if (!isJumping)
				anim.stop();
		}
		
		// apply a vertical impulse if the charachter is grounded
		public function jump():void
		{
			if (grounded())
			{
				body.applyImpulse(new Vec2(0,-2500));
				anim.play("startJump", nextAnim);
			}
		}
		
		// this function is to show the CallBack method of the animTree.
		// when the anim reach the last frame, this function is called 
		// with, as parameter, the animTree itself
		private function nextAnim(anim:AnimTree):void
		{
			if (anim.clipName =="startJump")
			{
				isJumping = true;
				anim.play("jumpLoop", nextAnim);
				return;
			}
			
			if (anim.clipName == "land")
			{
				if (direction != 0)
					anim.play("walk");
			}
		}
		
		/**
		 * 
		 * @return True if the ray casted at the bottom of the character hit something
		 * 
		 */		
		private function grounded():Boolean
		{
			var ray:Ray = new Ray(body.position, new Vec2(body.position.x, (body.position.y+body.bounds.height)));
			ray.maxDistance = body.bounds.height;
			
			var raycast:RayResult = _space.rayCast(ray);
			
			return raycast != null;
		}
		
		
		//added three other functions just to show some different animations. They can be freely implemented
		public function fire():void
		{
			stop();
			if (grounded())
				anim.play("fire");
		}
		
		public function eat():void
		{
			stop();
			if (grounded())
				anim.play("eat");
		}
		
		public function apologize():void
		{
			stop();
			if (grounded())
				anim.play("bless");
		}
	}
}