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
 * A pathfinding example scene													*
 * This scene uses the polygonClipper expansion library to draw the map         *
 * and the NavMesh class to generate the navmesh and the path					*
 *******************************************************************************/

package scenes
{
	import com.logicom.geom.ClipType;
	import com.logicom.geom.Clipper;
	import com.logicom.geom.IntPoint;
	import com.logicom.geom.PolyFillType;
	import com.logicom.geom.PolyType;
	import com.logicom.geom.Polygon;
	import com.logicom.geom.Polygons;
	
	import flash.display.MovieClip;
	import flash.geom.Point;
	
	import nape.geom.Vec2;
	import nape.space.Space;
	import nape.util.Debug;
	import nape.util.ShapeDebug;
	
	import pathfinding.Border;
	import pathfinding.Map;
	import pathfinding.NavMesh;
	import pathfinding.SinglePolygon;
	import pathfinding.utils.ClickType;
	import pathfinding.utils.pointToNape;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.Color;
	
	
	public class PathFinding_PoS extends Sprite
	{
		private var space:Space;
		private var debug:Debug;
		
		private var tempStart:Point;
		private var tempPoly:Array;
		
		private var clipper:Clipper;			// the clipper class that will contain the polygons
		private var clipperMap:Polygons;		// the clipper map of polyons
		private var clipType:int;				// to have different clipping (merge, substract or add) 
		
		private var map:Map;					// a map of polygons
		
		private var clickType:int;				// enum of clicks: draw or search stat	
		private var drawSpace:Quad;				// the space where the user can draw
		
		private var pathStart:Point;			// the start and the end point of the path
		private var pathEnd:Point;
		
		//UI variables
		private var btnLoadExample:Button;
		private var btnMakeNavMesh:Button;
		private var btnDrawNew:Button;
		private var btnSearchPath:Button;
		private var tglShowNavMesh:TextField;
		private var tglShowNodes:TextField;
		private var drawAdvice:TextField;
		private var showNavMesh:Boolean = false;
		private var showNodes:Boolean = false;
		
		public function PathFinding_PoS()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage():void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			//need to add the debug layer as overlay in order to work on this version
			space = new Space();
			debug = new ShapeDebug(stage.stageWidth, stage.stageHeight, stage.color);
			
			// instantiate the debugger as movieclip in order to work
			var MovieClipDebug:flash.display.MovieClip = new flash.display.MovieClip();
			MovieClipDebug.addChild(debug.display);
			starling.core.Starling.current.nativeOverlay.addChild(MovieClipDebug);
			
			//draw a bg color
			drawSpace = new Quad(stage.stageWidth,stage.stageHeight-100, Color.WHITE);
			drawSpace.y = 100;
			addChild(drawSpace);
			
			//initialize the tempPoly
			tempPoly = new Array();
			
			//initialize the clipper and his clipType
			clipper = new Clipper();
			clipType = ClipType.UNION;
			clickType = ClickType.DRAW;
			
			//this will containt the full poly map
			clipperMap = new Polygons();
			
			initializeUI();
			
			stage.addEventListener(TouchEvent.TOUCH, onTouch);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
		}
		
		private function initializeUI():void
		{
			btnLoadExample = new Button(Assets.getTexture("btnImage"), "Load \n Example");
			btnLoadExample.fontSize = 36;
			btnLoadExample.x = stage.stageWidth/6*1-90;
			btnLoadExample.y = 10;
			btnLoadExample.width = 180;
			btnLoadExample.height = 80;
			addChild(btnLoadExample);
			
			btnDrawNew = new Button(Assets.getTexture("btnImage"), "Draw new");
			btnDrawNew.fontSize = 36;
			btnDrawNew.x = stage.stageWidth/6*2-90;
			btnDrawNew.y = 10;
			btnDrawNew.width = 180;
			btnDrawNew.height = 80;
			addChild(btnDrawNew);
			
			btnMakeNavMesh = new Button(Assets.getTexture("btnImage"), "Calculate \n navMesh");
			btnMakeNavMesh.fontSize = 36;
			btnMakeNavMesh.x = stage.stageWidth/6*3-90;
			btnMakeNavMesh.y = 10;
			btnMakeNavMesh.height = 80;
			btnMakeNavMesh.width = 180;
			addChild(btnMakeNavMesh);
			
			btnSearchPath = new Button(Assets.getTexture("btnImage"), "Search Path");
			btnSearchPath.fontSize = 36;
			btnSearchPath.x = stage.stageWidth/6*4-90;
			btnSearchPath.y = 10;
			btnSearchPath.height = 80;
			btnSearchPath.width = 180;
			addChild(btnSearchPath);
			
			tglShowNavMesh = new TextField(180,22, "Show NavMesh: off", "Verdana", 18, Color.WHITE, false);
			tglShowNavMesh.x = stage.stageWidth/6*5-80;
			tglShowNavMesh.y = 5;
			addChild(tglShowNavMesh);
			
			tglShowNodes = new TextField(180,22, "Show Nodes: off", "Verdana", 18, Color.WHITE, false);
			tglShowNodes.x = stage.stageWidth/6*5-80;
			tglShowNodes.y = 50;
			addChild(tglShowNodes);
			
			drawAdvice = new TextField(800,28, "Push 'V' when close a poly to Substract it instead of add", "Verdana", 18, Color.BLACK, false);
			drawAdvice.y = stage.stageHeight -40;
			addChild(drawAdvice);
			
			btnLoadExample.addEventListener(Event.TRIGGERED, loadExample);
			btnDrawNew.addEventListener(Event.TRIGGERED, draw);
			btnSearchPath.addEventListener(Event.TRIGGERED, searchPath);
			btnMakeNavMesh.addEventListener(Event.TRIGGERED, calculateNavMesh);
			tglShowNodes.addEventListener(TouchEvent.TOUCH, toggleNodes);
			tglShowNavMesh.addEventListener(TouchEvent.TOUCH, toggleNavMesh);
		}
		
		private function calculateNavMesh():void
		{
			trace("calculate navmesh");
			drawAdvice.text = "Navmesh generated";
			map = new Map(clipperMap);
			NavMesh.makeNavMesh(space, map);
			refreshDebugDraw();
		}		
		
		
// region INPUT
		
		private function draw():void
		{ 	
			clickType = ClickType.DRAW;
			
			clipper = new Clipper();
			var solution:Polygons = new Polygons();
			clipper.execute(ClipType.UNION, solution, PolyFillType.EVEN_ODD, PolyFillType.EVEN_ODD);
			clipperMap = solution;
			
			NavMesh.destroy();
			map = null;
			drawAdvice.text = "Push 'V' when close a poly to Substract it instead of add";
			refreshDebugDraw();
		} 
		
		private function searchPath(event:Event):void 	
		{	
			clickType = ClickType.SEARCH;
			drawAdvice.text = "click anywhere inside the map";
		}
		
		private function onKeyUp(event:KeyboardEvent):void
		{
			//if key "V" release, return to Union Type
			if (event.keyCode == 86)
				clipType = ClipType.UNION;
		}
		
		private function onKeyDown(event:KeyboardEvent):void
		{
			//if key "V" is pressed, make the clipping as difference instead of union
			if (event.keyCode == 86 && clipType ==1)
				clipType = ClipType.DIFFERENCE;
			
			if (event.keyCode ==13)
			{
				var _map:Map = new Map(clipperMap);
				NavMesh.makeNavMesh(space, _map);
			}
		}	
		
		private function onTouch(event:TouchEvent):void
		{
			// manage the right click
			var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
			
			if (touch)
			{
				debug.clear();
				
				// check if the click is inside the draw space and draw if yes
				var point:Point = new Point(touch.globalX, touch.globalY);
				if (drawSpace.bounds.containsPoint(point))
				{
					switch (clickType)
					{
						case ClickType.DRAW:
							addPoint(point);
							break;
						case ClickType.SEARCH:
							pathSearching(point);
							break;
					}
				}	
				refreshDebugDraw();
			}
		}
		// toggler for the textFields. Not a smart choice.
		// made just for example purpose. Absolutly to avoid a solution like this for production
		private function toggleNavMesh(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
			
			if (touch)
			{
				showNavMesh = !showNavMesh;
				if (showNavMesh)
					tglShowNavMesh.text = "Show NavMesh: on";
				else
					tglShowNavMesh.text = "Show NavMesh: off";
				
				refreshDebugDraw();
			}
		}
		
		private function toggleNodes(event:TouchEvent):void
		{
			var touch:Touch = event.getTouch(this, TouchPhase.BEGAN);
			
			if (touch)
			{
				showNodes = !showNodes;
				if (showNodes)
					tglShowNodes.text = "Show Nodes: on";
				else
					tglShowNodes.text = "Show Nodes: off";
				
				refreshDebugDraw();
			}
		}
		
// endregion
		
// region PATHFINDING
		
		private function pathSearching(point:Point):void
		{
			//make a pathStart if there is none
			if (pathStart == null)//|| pathStart != point)
				pathStart=point;
			else
			{
				pathEnd=point;
				makePath(pathStart, pathEnd);
				pathStart=null;
			}
		}
		
		private function makePath(pathStart:Point, pathEnd:Point):void
		{
			if (!NavMesh.navMesh) 
			{
				drawAdvice.text = "no navMesh founded, please generate one first";
				return;
			}
			
			var a:IntPoint = new IntPoint(pathStart.x, pathStart.y);
			var b:IntPoint = new IntPoint(pathEnd.x, pathEnd.y);
			
			var path:Array = NavMesh.Path(a,b);
			for each (var o:Object in path)
			{
				debug.drawLine(pointToNape(o.a), pointToNape(o.b), Color.FUCHSIA);
			}
		}
		
		private function addPoint(point:Point):void
		{
			//if is the first point of the scene create one and draw the quad
			if (tempStart == null)
			{
				tempStart = point;
				tempPoly.push(point);
				DrawVertexMark(point);
			}
			else
			{
				//if the point is not near the origin, just draw a line between them
				if (!PointNear(point, tempStart))
				{
					tempPoly.push(point);
					DrawPolys(tempPoly);
				}
				//the poly is finished, make it as a new poly or merge on the existing one
				else 
				{
					clipper = new Clipper();
					clipper.addPolygons(clipperMap, PolyType.SUBJECT);
					clipper.addPolygon(ClipperPoly(tempPoly),PolyType.CLIP);
					var solution:Polygons = new Polygons();
					clipper.execute(clipType, solution, PolyFillType.EVEN_ODD, PolyFillType.EVEN_ODD);
					
					//add the border to the polymap
					clipperMap = solution;
				
					tempStart = null;
					tempPoly = new Array();
				}
			}
		}
		
		private function ClipperPoly(_poly:Array):Polygon
		{
			var poly:Polygon = new Polygon();
			for each (var point:Point in _poly)
			{
				var p:IntPoint = new IntPoint(point.x, point.y);
				poly.addPoint(p);
			}
			return poly;
		}

// endregion
		
// region Debug DRAW
		
		private function refreshDebugDraw():void
		{
			DrawFinishedPolys();
			
			if (showNodes)
				DrawNodes();
			
			if (showNavMesh)
				DrawNavMesh();
			
			debug.draw(space);
			debug.flush();
		}
		
		private function DrawNodes():void
		{
			if (map == null) return;
			
			for each (var section:Border in map.getBorders())
			{
				for each (var node:IntPoint in section.nodes)
				{
					debug.drawFilledCircle(new Vec2(node.X, node.Y), 4, Color.PURPLE);
				}
			}
		}
		 
		private function DrawFinishedPolys():void
		{
			for each (var poly:Polygon in clipperMap.getPolygons()) 
			{
				ConvertPolyInArray(poly);
			}
		}
		
		private function ConvertPolyInArray(_poly:Polygon):void
		{
			var debugPoly:Array = new Array();
			for each (var intpoint:IntPoint in _poly.getPoints())
			{
				var point:Point = new Point(intpoint.X, intpoint.Y);
				debugPoly.push(PointToNape(point));
			}
			debug.drawPolygon(debugPoly, Color.BLACK);
		}
				
		private function DrawVertexMark(point:Point):void
		{
			debug.drawFilledCircle(PointToNape(point), 4, Color.RED);	
		}
			
		private function DrawPolys(poly:Array):void
		{	
			DrawVertexMark(tempPoly[0]);
			//draw the temp poly
			for (var i:int = 0; i<poly.length-1;i++)
			{
				debug.drawLine(PointToNape(tempPoly[i]), PointToNape(tempPoly[i+1]),Color.BLUE);
				DrawVertexMark(tempPoly[i+1]);
			}
		}
		
		private function DrawNavMesh():void
		{
			if (NavMesh.navMesh == null) 
				return;
			
			for each (var o:Object in NavMesh.navMesh)
			{
				debug.drawLine(pointToNape(o.a), pointToNape(o.b), Color.GREEN);
			}
		}
		
// endregion
		
// region UTILS
		
		// check if a point is near another by intersecting 2 quad generated on the 2 points
		private function PointNear(a:Point, b:Point):Boolean
		{
			var quad1:Quad = new Quad(10,10, Color.WHITE);
			quad1.pivotX = a.x;
			quad1.pivotY = a.y;
			
			var quad2:Quad = new Quad(10,10, Color.WHITE);
			quad2.pivotX = b.x;
			quad2.pivotY = b.y;
			
			return quad1.bounds.intersects(quad2.bounds);
		}
		
		//conversion facilities
		private function PointToNape(_point:Point):Vec2 
		{
			return new Vec2(_point.x, _point.y);
		}
		
// endregion
		
// region EXAMPLE
		
		/**
		 *	Draw a bunch of polygons as example 
		 * 	it will overwrite the existing polymap if exist one
		 */		
		private function loadExample():void
		{
			clipperMap = new Polygons();
			debug.clear();
			
			var p1:Polygon = new Polygon();
			p1.addPoint(new IntPoint(80,160));
			p1.addPoint(new IntPoint(800,160));
			p1.addPoint(new IntPoint(800,700));
			p1.addPoint(new IntPoint(600,700));
			p1.addPoint(new IntPoint(400,600));
			p1.addPoint(new IntPoint(400,500));
			p1.addPoint(new IntPoint(300,400));
			p1.addPoint(new IntPoint(200,700));
			p1.addPoint(new IntPoint(80,700));
			
			var p2:Polygon = new Polygon();
			p2.addPoint(new IntPoint(150,250));
			p2.addPoint(new IntPoint(500,250));
			p2.addPoint(new IntPoint(500,300));
			p2.addPoint(new IntPoint(150,300));
			
			var p3:Polygon = new Polygon();
			p3.addPoint(new IntPoint(600,350));
			p3.addPoint(new IntPoint(700,350));
			p3.addPoint(new IntPoint(700,500));
			p3.addPoint(new IntPoint(600,500));
			
			
			clipper = new Clipper();
			clipper.addPolygon(p1,PolyType.CLIP);
			clipper.addPolygon(p2,PolyType.CLIP);
			clipper.addPolygon(p3,PolyType.CLIP);
			var solution:Polygons = new Polygons();
			clipper.execute(ClipType.UNION, solution, PolyFillType.EVEN_ODD, PolyFillType.EVEN_ODD);
			
			//add the border to the polymap
			clipperMap = solution;
			
			DrawFinishedPolys();
		}
	}
// endregion
}

