package
{
	import flash.display.Sprite;
	
	import net.hires.debug.Stats;
	
	import starling.core.Starling;
	
	[SWF(width="1024",height="768", frameRate="60", backgroundColor=0x000000)]
	public class SalvatoreDemo extends Sprite
	{
		private var mStarling:Starling;
		private var stats:Stats;
		
		public function SalvatoreDemo()
		{
			stats = new Stats();
			this.addChild(stats);
			
			
			mStarling = new Starling(Demo,stage);
			
			mStarling.antiAliasing =1;
			
			mStarling.start();
		}
	}
}