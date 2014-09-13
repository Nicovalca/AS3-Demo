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
 * A pathfinding A* scene handler                                               *
 * removed from the example pages cause obsolete and replaced by the PoS scene  *
 *******************************************************************************/

package scenes
{	
	
	import flash.display.Shape;
	
	import nape.geom.Vec2;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.util.ShapeDebug;
	
	import pathfinding.Astar;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.utils.Color;
	import starling.utils.deg2rad;
	
	
	public class PathFinding_AStar extends Sprite
	{
		private var aStarMap:Astar;
		private var grid:Array;
		
		private var pos:Vec2;
		private var pos2:Vec2;
		
		private var sX:Number;
		private var sY:Number;
		
		private var debug:ShapeDebug;
		private var player:Image;
		
		
		
		public function PathFinding_AStar()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			aStarMap = new Astar(20,20);
			
			var v1:Vec2 = new Vec2(120,stage.stageHeight-120);
			var v2:Vec2 = new Vec2(stage.stageWidth-120,120);
			
			debug = new ShapeDebug(stage.stageWidth, stage.stageHeight, Color.WHITE);
			var MovieClipDebug:flash.display.MovieClip = new flash.display.MovieClip();
			MovieClipDebug.addChild(debug.display);
			starling.core.Starling.current.nativeOverlay.addChild(MovieClipDebug);
			
			debug.drawLine(v1, v2, Color.RED);
			
			player = new Image(Assets.getTexture("Logo"));
			player.x = v1.x;
			player.y = v1.y;
			player.pivotX = player.width/2;
			player.pivotY = player.height/2
			player.height = 80;
			player.width = 80;
			addChild(player);
			
			grid = aStarMap.getGrid();
			
			sX = stage.stageWidth/aStarMap.rows;
			sY = stage.stageHeight/aStarMap.columns;
			var quadOK:Quad = new Quad(sX, sY, Color.WHITE);
			var quadNO:Quad = new Quad(sX, sY,0xffffff);
			
			var quadObstacle:Quad = new Quad(70,120,Color.BLUE);
			quadObstacle.x = 380;
			quadObstacle.y = 250;
			quadObstacle.rotation = deg2rad(70);
			addChild(quadObstacle);
			aStarMap.addObstacle(quadObstacle);
			
			
			for (var i:int = 0; i<aStarMap.rows; i++)
			{
				for (var j:int = 0; j<aStarMap.columns; j++)
				{	
					if (grid[i][j] == 0)
					{
						quadOK=new Quad(sX, sY, Color.WHITE);
						quadOK.setVertexColor(0,Color.GRAY);
						quadOK.x = i*sX;
						quadOK.y = j*sY;
						
						addChild(quadOK);
					}
					else
					{
						quadNO=new Quad(sX, sY, Color.BLACK)
						quadNO.x = i*sX;
						quadNO.y = j*sY;
						addChild(quadNO);
					}
				}
			}
			addChild(quadObstacle);
			
			var path:Array = aStarMap.findPath(200,300,600,620);
			//var path2:Array = aStarMap.getPath(path);
			//trace("path2: "+ path2.length + " coordinate " + path2[0].i + "x"+path2[0].j);
			
			var text:TextField = new TextField(300,38, "lenght "+ grid.length,"Verdana", 24, Color.BLUE, false);
			text.x = 300;
			text.y = 10
			addChild(text);
			
			var text2:TextField = new TextField(500,38, " ","Verdana", 24, Color.BLUE, false);
			text2.x = 300;
			text2.y = 50;
			addChild(text2);
			
			var text3:TextField = new TextField(500,38, " ","Verdana", 24, Color.BLUE, false);
			text2.x = 300;
			text2.y = 80;
			addChild(text3);
			
			text2.text = "path lenght: "+path.length;
			trace(path[1].i);
			
			
			//var text:TextField = new TextField(0,0,"", "Verdana", 12, Color.RED, false);
			
			//draw numbers
			for (var z:int =0;z<path.length-1;z++)
			{
				pos = new Vec2();
				pos2 = new Vec2();
				pos.x = path[z].i*sX;
				pos.y = path[z].j*sY;
				
				pos2.x = path[z+1].i*sX;
				pos2.y = path[z+1].j*sY;
				
				//debug.drawLine(pos, pos2, Color.BLUE);
				
				text = new TextField(20,20,path[z].counter, "Verdana", 12, Color.RED, false);;
				text.x = pos.x;
				text.y = pos.y;
	
				
				addChild(text);
				
				//trace("pathX: "+path2[z].counter + " pathY: "+path2[z].j);
			addChild(player);
			}
			
			//draw path
			for (var u:int =0;u<path.length-1;u++)
			{
				pos = new Vec2();
				pos2 = new Vec2();
				pos.x = path[u].i*sX;
				pos.y = path[u].j*sY;
				
				pos2.x = path[u+1].i*sX;
				pos2.y = path[u+1].j*sY;
				
				debug.drawLine(pos, pos2, Color.BLUE);
			}
			addChild(quadOK);
			
	
		
			
		}
	}
}