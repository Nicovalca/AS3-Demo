package
{
	import flash.display.Bitmap;
	import flash.utils.Dictionary;
	
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;

	public class Assets
	{
		[Embed(source="../media/graphic/platform.png")]
		public static const Platform:Class;
		
		[Embed(source="../media/graphic/title-logo.png")]
		public static const Logo:Class;
		
		[Embed(source="../media/graphic/Background.png")]
		public static const BG:Class;
		
		[Embed(source="../media/graphic/lightMain.png")]
		public static const lightMain:Class;
		
		[Embed(source="../media/graphic/lightMain_Over.png")]
		public static const lightMain_Over:Class;
		
		[Embed(source="../media/graphic/button.png")]
		public static const btnImage:Class;
		
		[Embed(source="../media/graphic/sprites.png")]
		public static const AtlasCharachter:Class;
		
		[Embed(source="../media/graphic/sprites.xml", mimeType="application/octet-stream")]
		public static const AtlasXmlCharachter:Class;
			
		private static var gameTextures:Dictionary = new Dictionary();
		private static var atlas:TextureAtlas;
			
		/**
		 * 
		 * @param name: the name of the class texture
		 * @return: the texture searched
		 * 
		 */		
		public static function getTexture(name:String):Texture
		{
			if (gameTextures[name] == undefined)
			{
				var bitmap:Bitmap = new Assets[name]();
				gameTextures[name] = Texture.fromBitmap(bitmap);
			}
			return gameTextures[name];
		}
		
		/**
		 * 
		 * @return the texture atlast 
		 * 
		 */		
		public static function getAtlas():TextureAtlas
		{
			if (atlas == null)
			{
				var texture:Texture = getTexture("AtlasCharachter");
				var xml:XML = XML(new AtlasXmlCharachter());
				atlas = new TextureAtlas(texture,xml);
			}
			return atlas;
		}
	}
}