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
 * A pathfinding A* map handler                                                 *
 * removed from the example pages cause obsolete and replaced by the navMesh    *
 *******************************************************************************/

package pathfinding
{
	import flash.display.Sprite;
	
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.geom.Vec2;
	import nape.space.Space;
	
	import starling.core.Starling;
	import starling.display.Quad;


	public class Astar
	{
		private var _rows:Number;
		private var _columns:Number;
		
		private var grid:Array;
		private var queue:Array;
		
		public var startGridX:Number;
		public var startGridY:Number;
		
		private var spacingX:Number;
		private var spacingY:Number;
		
		private var obstacles:Vector.<Quad>;
		
		private var space:Space;
		private var intersection:Vec2;
		
		private var wall:Wall;
		
		public function Astar(rows:Number, columns:Number)
		{
			super();
			
			_rows = rows;
			_columns = columns;
			
			spacingX = Starling.current.stage.stageWidth/_rows;
			spacingY = Starling.current.stage.stageHeight/_columns;
			
			obstacles = new Vector.<Quad>();
			
			generateGrid(_rows, _columns);
			
			space=new Space();
			intersection = new Vec2();
			wall = new Wall(50,50,500,500);
			space.bodies.add(wall.body);
		}
		
		//generate an Empty grid without obstacles

		public function generateGrid(rows:int, columns:int):Array
		{
			grid = new Array(rows);
		
			
			for (var i:int = 0; i<rows; i++)
			{
				grid[i] = new Array(columns);
				for (var j:int = 0; j<columns; j++)
				{	
					grid[i][j]=0;
				}
			}
			return grid;
			
		}
		
		private function draw():void
		{
			var raySprite:flash.display.Sprite = new Sprite();
			raySprite.graphics.clear();
			raySprite.graphics.lineStyle(1);
			raySprite.graphics.lineTo(intersection.x, intersection.y);
		}
		
		//old pathfinding
		
		// add obstacles to the grid
		// @param quad = simple quad obstacle
		public function addObstacle(quad:Quad):void
		{
			obstacles.push(quad);
			
			refreshGrid();
		}
		
		//called when a new obstacle is added to the grid
		// it recursively chech all the position on the grid and make the modifies
		// call it ONLY when needed
		public function refreshGrid():void
		{
			//chech the grid and add the new obstacle on the calculus of the path
			for (var i:int = 0; i<_rows; i++)
			{
				for (var j:int = 0; j<_columns; j++)
				{	
					for each (var o:Quad in obstacles)
					{
						if (o.bounds.contains(i*spacingX, j*spacingY))
							grid[i][j]=1;
						else
							grid[i][j]=0;
					}
				}
			}
		}
		
		public function findPath(xStart:int, yStart:int, xGoal:int, yGoal:int):Array
		{
			queue = new Array();
			
			startGridX = Math.ceil(xStart/spacingX);
			startGridY = Math.ceil(yStart/spacingY);
			
			var finishObject:Object = { i:Math.ceil(xGoal/spacingX), j:Math.ceil(yGoal/spacingX), counter:0};
			
			queue.push(finishObject);
			
			checkQueue(0,1);
			
			var result:Array = getPath(xGoal, yGoal, queue);
			return result;
		}
		
		/**
		 * 
		 * @param startIndex
		 * @param counter
		 * 
		 */
		private function checkQueue(startIndex:int, counter:int):void
		{
			var lastQueueLength:int = queue.length;
			var i:int;
					
			for (i=startIndex;i<lastQueueLength; i++)
			{
				
				var coordinate:Object;
				
				//check top
				if (queue[i].j != 0 && grid[queue[i].i][queue[i].j-1] == 0)// grid[queue[i].i][grid[i].j -1] == 0)
				{
				
					coordinate = {i:queue[i].i, j:queue[i].j-1,counter:counter}; 
					if (coordinate.i == startGridX && coordinate.j == startGridY) return;
					
					if (canBeAddedToQueue(coordinate)) queue.push(coordinate);
				}
				
				//check right
				if (queue[i].i != grid.length-1 && grid[queue[i].i+1][queue[i].j] == 0)//queue[i].j != grid.length-1 && grid[queue[i].i +1][grid[i].j] == 0)
				{
					coordinate = {i:queue[i].i+1, j:queue[i].j,counter:counter}; 
					if (coordinate.i == startGridX && coordinate.j == startGridY) return;
					
					if (canBeAddedToQueue(coordinate)) queue.push(coordinate);
				}
				
				//check bottom
				if (queue[i].j != grid[queue[i].i].length-1 && grid[queue[i].i][queue[i].j+1] == 0)//queue[i].j != grid[queue[i].i].length-1 && grid[queue[i].i][grid[i].j +1] == 0)
				{
					coordinate = {i:queue[i].i, j:queue[i].j+1,counter:counter}; 
					if (coordinate.i == startGridX && coordinate.j == startGridY) return;
					
					if (canBeAddedToQueue(coordinate)) queue.push(coordinate);
				}
				
				//check left
				if (queue[i].i != 0 && grid[queue[i].i-1][queue[i].j] == 0)//queue[i].j != 0 && grid[queue[i].i-1][grid[i].j] == 0)
				{
					coordinate = {i:queue[i].i-1, j:queue[i].j,counter:counter}; 
					if (coordinate.i == startGridX && coordinate.j == startGridY) return;
					
					if (canBeAddedToQueue(coordinate)) queue.push(coordinate);
				}
			}
			
			checkQueue(lastQueueLength, counter+1);
		}
		
		private function canBeAddedToQueue(coordinate:Object):Boolean
		{
			for (var i:int = queue.length -1; i>=0; i--)
			{
				if (coordinate.i == queue[i].i && coordinate.j == queue[i].j)
				{
					if (coordinate.counter >= queue[i].counter) 
					{
						return false;
					}
					else
					{
						queue.splice(i,1);
						return true;
					}
					
				}
			}
			return true;
		}
		
		public function getPath(x:int, y:int, path:Array):Array
		{
			trace ("on final loop"+path.length);
			var result:Array = new Array();
			
			for (var i:int=1; i<path.length; i++)
			{
				var temp:Object = new Object();
				if (path[i].i <= x+1 && path[i].i >= x-1 && path[i].j <=y +1 && path[i].j >= y-1)
				{
					if (path[i].counter < temp.counter) 
					{
						temp = path[i];
						result.push(temp);
					}
				}
				
				
				if (path[i].counter ==0) return result;
			}
			return result;
		}
		
		public function get rows():Number { return _rows; }
		public function set rows(value:Number):void {	_rows = value;}

		public function get columns():Number{	return _columns;}
		public function set columns(value:Number):void	{	_columns = value;}

		public function getGrid():Array { return grid; }
	}
}