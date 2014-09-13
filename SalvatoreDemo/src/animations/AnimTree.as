/*******************************************************************************
 *                                                                              *
 * Author    :  Valcasara Nicola                                                *
 * Version   :  1.0.0                                                           *
 * Date      :  August 2014                                                     *
 * Website   :  http://nicolavalcasara.weebly.com/                              *                                         *
 *                                                                              *
 * License:                                                                     *
 * Use, modification & distribution is subject to GPL open source license		*
 * http://opensource.org/licenses/GPL-3.0                                      	*
 *                                                                              *
 * Class description:															*
 * AnimTree class                                                             	*                
 * this class is useful when you have a bunch of animations all hinertit a		*
 * single spritesheet and want to merge togheter on a single class				*
 * This class main methods are:													*
 *  - addClip ( add a single clip form a spritesheet)							*
 *  - play ( play the given animation)											*
 *  - stop ( stop an animation)													*
 * simple initialize this class into your scene passing as argument the			*
 * texture atlast and the base name of your animations							*
 *******************************************************************************/
package animations
{
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	
	public class AnimTree extends Image implements IAnimatable
	{
		private var spriteSheet:TextureAtlas;		// the texture atlas
		private var clips:Vector.<SeqData>;			// a vector of clips in format of seqDada: it will contain all the animations
		
		private var finished:Boolean;				// store if a clip is finished
		private var curClip:SeqData;				// store the current clip
		private var _frame:int;						// store the currrent frame
		
		protected var frameTimer:Number;			// the calculated timer where the next frame call occurs
		private var callBack:Function;				// a callback function 
		
		private static var idle:Texture;			// the "idle" frame that will be created when the animtree is created. Default is the first frame of the spritesheet
		
		private var showWhenDone:Boolean = false;	// if true will show the last frame when animation is finished
		
		/**
		 * 
		 * @param atlas: the texture atlas
		 * @param size: the dimension of the animation (power of 2 preferrable)
		 * 
		 */		
		public function AnimTree(atlas:TextureAtlas, size:Number)
		{
			spriteSheet = atlas;
			
			if (idle == null)
				idle = atlas.getTextures("")[0];
			
			super(idle);
			
			clips = new Vector.<SeqData>();
		}
		
		/**
		 * 
		 * @param name: the custom name of the animation.  Will be used on the function Play()
		 * @param base: the base name on the xml spritesheet file
		 * @param looped: if looped
		 * @param frameRate: fps of the animation
		 * @param reverse: if is reverse animation
		 * 
		 */		
		public function addClip(name:String, base:String, looped:Boolean = true, frameRate:Number = 12, reverse:Boolean = false):void
		{
			var frames:Vector.<Texture> = spriteSheet.getTextures(base);
			if (!frames || frames.length == 0) {
				trace("error: not textures found!");
				return;
			}
			
			if (reverse) frames.reverse();
			
			addInternalClip(name, frames, frameRate, looped);	
		}
		
		//internal function. It create a seqData of the given animation and add it to the vector
		private function addInternalClip(name:String, frames:Vector.<Texture>, frameRate:Number, looped:Boolean):void
		{
			var c:SeqData = new SeqData(name, frames, frameRate, looped);
			clips.push(c);
			
			if (!curClip){
				curClip = c;
				_frame =0;
				finished = true;
				readjustSize();
			}
		}
		
		// find a clip by name
		private function findClip(name:String):SeqData
		{
			for each (var c:SeqData in clips)
			{
				if (c.name == name)
					return c;
			}
			return null;
		}
		
		/**
		 * 
		 * @param name: the name of the animation that you want to play
		 * @param _callBack: a callback function. the child function need to have 
		 * an animTree parameter in order to work
		 * 
		 */		
		public function play(name:String = null, _callBack:Function = null):void
		{	
			callBack = _callBack;
			frameTimer = 0;
			finished = false;
			
			// if no name is wrote, just return and play the default clip
			if (!name)
				return;
			
			//set first frame
			_frame = 0;
			
			if (!curClip || curClip.name != name)
			{
				curClip = findClip(name);
				if (!curClip)
				{
					trace ("play: cannot find clip "+name);
					return;
				}
				
				update();
				readjustSize();
			}
			
			if (curClip.frames.length ==1) finished = true;
		}
		

		// remove from the starling juggler when finished
		// and show if required
		private function endPlay(a:AnimTree):void
		{
			Starling.juggler.remove(a);
			a.visible = showWhenDone;
		}
		
		public function attachAndPlayOnce(name:String=null, showAfterStop:Boolean =false):void
		{
			showWhenDone = showAfterStop;
			Starling.juggler.add(this);
			this.visible=true;
			this.play(name, endPlay);
		}
		
		// set as finished and show the idle texture
		public function stop():void 
		{ 
			finished = true;
			texture = idle;
		}
		
		// callback handler
		public function internal_stop():void
		{
			finished = true;
			texture = idle;
			
			if (callBack != null)
				callBack(this);
		}
		
		//tick function. Just refresh the texture according with the frame
		private function update():void { texture = curClip.frames[_frame]; }
		
		// tick function. Check the time passed and call the next frame when needed
		public function advanceTime(deltaTime:Number):void
		{
			if (curClip != null && curClip.frameTime >0 && !finished)
			{
				frameTimer += deltaTime;
				
				while(frameTimer > curClip.frameTime)
				{
					frameTimer = frameTimer - curClip.frameTime;
					nextFrame();
				}
			}
		}
		
		// go to next frame if exist
		private function nextFrame():void
		{
			if (_frame == curClip.frames.length -1)
			{
				if (curClip.loop) 
					_frame=0;
				else
					internal_stop();
			}
			else
				++_frame;
			
			update();
		}
		
		//getters and setters
		public function get clipName():String { return curClip.name; }
		public function get clipsCount():int {return clips.length; }
		
		public function get frame():int { return _frame; }
		public function set frame(f:int):void 	// set a frame and reset the timer
		{ 
			_frame = f;
			frameTimer = 0;
			
			update();
		}
		
		override public function dispose():void
		{
			spriteSheet = null;
			
			while (clips.length >0) { 
				clips.pop(); }
			
			super.dispose();
		}
	}
}

import starling.textures.Texture;

// this is the sequelce class for each animation
// it contains a bunch of useful informations of a clip
internal class SeqData
{
	public var name:String;
	public var frames:Vector.<Texture>;
	public var fps:int;
	public var loop:Boolean;
	public var frameTime:Number = 0;
	
	public function SeqData(_name:String, _frames:Vector.<Texture>, frameRate:Number = 0, looped:Boolean = true)
	{
		name = _name;
		frames = _frames;
		fps = frameRate;
		loop = looped;
		
		frameTime = 1.0 / frameRate;
	}
}
