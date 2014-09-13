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
	import com.logicom.geom.IntPoint;
	
	import nape.geom.Vec2;
	
	import pathfinding.utils.pointToNape;

	public class SinglePolygon
	{
		private var _points:Vector.<IntPoint>;
		private var _nodes:Vector.<IntPoint>;
	
		
		public function SinglePolygon(points:Vector.<IntPoint>)
		{
			_points = points;
			_nodes = new Vector.<IntPoint>();
		}
		
		public function get nodes():Vector.<IntPoint>	{	return _nodes;	}

		public function set nodes(value:Vector.<IntPoint>):void {_nodes = value;}

		public function first():IntPoint { return _points[0]; }
		
		public function Inside(points:Vector.<IntPoint>, position:IntPoint, tolerance:Boolean = true):Boolean
		{
			//trace("--------START");
			var point:IntPoint = position;
			
			var inside:Boolean = false;
			
			var epsilon:Number = 0.5;
			
			//trace("_points inside : " + _points.length);
			/*if (_points.length <3) 
			{
				trace("too short");
				return false;
			}*/
			
			var oldPoint:IntPoint = points[points.length-1];
			var oldSqDist:Number = Vec2.dsq(pointToNape(oldPoint), pointToNape(point));
			
			for (var i:int = 0; i<points.length;i++)
			{
				var newPoint:IntPoint = points[i];
				var newSqDist:Number = Vec2.dsq(pointToNape(newPoint), pointToNape(point));
				
				
				
				if (oldSqDist + newSqDist +2* Math.sqrt(oldSqDist*newSqDist) - Vec2.dsq(pointToNape(newPoint), pointToNape(oldPoint)) < epsilon)
				{
					//trace("----END return strange");
					return tolerance;
				}
				
				var left:IntPoint = new IntPoint();
				var right:IntPoint = new IntPoint();
				
				if (newPoint.X > oldPoint.X)
				{
					left = oldPoint;
					right = newPoint;
				}
				else
				{
					left = newPoint;
					right = oldPoint;
				}
				
				if (left.X < point.X && point.X <= right.X && (point.Y - left.Y)*(right.X - left.X) <(right.Y - left.Y)*(point.X-left.X))
					inside = !inside;
				
				oldPoint = newPoint;
				oldSqDist = newSqDist;
			}
			//trace("------END");
			return inside;
		
		}
		
		public function InsideSingle(position:IntPoint, tolerance:Boolean = true):Boolean
		{
			//trace("--------START");
			var point:IntPoint = position;
			
			var inside:Boolean = false;
			
			var epsilon:Number = 0.5;
			
			//trace("_points inside : " + _points.length);
			/*if (_points.length <3) 
			{
			trace("too short");
			return false;
			}*/
			
			var oldPoint:IntPoint = _points[_points.length-1];
			var oldSqDist:Number = Vec2.dsq(pointToNape(oldPoint), pointToNape(point));
			
			for (var i:int = 0; i<_points.length;i++)
			{
				var newPoint:IntPoint = _points[i];
				var newSqDist:Number = Vec2.dsq(pointToNape(newPoint), pointToNape(point));
				
				
				if (oldSqDist + newSqDist +2* Math.sqrt(oldSqDist*newSqDist) - Vec2.dsq(pointToNape(newPoint), pointToNape(oldPoint)) < epsilon)
				{
					//trace("----END return strange");
					return tolerance;
				}
				
				var left:IntPoint = new IntPoint();
				var right:IntPoint = new IntPoint();
				
				if (newPoint.X > oldPoint.X)
				{
					left = oldPoint;
					right = newPoint;
				}
				else
				{
					left = newPoint;
					right = oldPoint;
				}
				
				if (left.X < point.X && point.X <= right.X && (point.Y - left.Y)*(right.X - left.X) <(right.Y - left.Y)*(point.X-left.X))
					inside = !inside;
				
				oldPoint = newPoint;
				oldSqDist = newSqDist;
			}
			//trace("------END");
			return inside;
			
		}
		
		public function length():int {	return _points.length; }
		
		public function at(n:int):IntPoint { return _points[n]; }
		
		public function points():Vector.<IntPoint> { return _points; }
		
		
			
		
	}
}