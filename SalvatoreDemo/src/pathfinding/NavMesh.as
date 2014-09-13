/*******************************************************************************
 *                                                                              *
 * Author    :  Valcasara Nicola                                                *
 * Version   :  1.0.0                                                           *
 * Date      :  August 2014                                                 	*
 * Website   :  http://nicolavalcasara.weebly.com/                              *                                         
 *                                                                              *
 * License:                                                                     *
 * Use, modification & distribution is subject to GPL open source license		*
 * http://opensource.org/licenses/GPL-3.0                                      	*
 *                                                                              *
 * Class description:															*
 * NavMesh Class																*
 * this class handle all the functions needed to create a navmesh				*
 * parameters needed:															*
 *  @space = the space where the scene is										*
 * 	@map = the polygons map of the walls and holes								*
 * this class use the point of sight method to generate the navmesh				*
 * and the Dijkstra's algorithm as pathfinding method                           *
 *******************************************************************************/

package pathfinding
{
	import com.logicom.geom.IntPoint;
	import com.logicom.geom.Polygon;
	import com.logicom.geom.Polygons;
	
	import nape.dynamics.Arbiter;
	import nape.geom.Ray;
	import nape.geom.RayResult;
	import nape.geom.Vec2;
	import nape.geom.Vec2List;
	import nape.space.Space;
	import nape.util.Debug;
	
	import pathfinding.Map;
	import pathfinding.utils.distance;
	import pathfinding.utils.pointToNape;
	
	import utils.Input;
		
	public class NavMesh
	{
		public static var navMesh:Array;
		
		private static var space:Space;
		private static var debug:Debug;
		private static var map:Map;
		
		private static var epsilon:Number = 0.5;
		
		/**
		 * 
		 *  param _space = the space where the scene is
 		 * 	param _map = the polygons map of the walls and holes	
		 * 
		 */		
		public static function makeNavMesh(_space:Space, _map:Map):void
		{
			space = _space;
			map = _map;
			
			navMesh = new Array();
			
			//for each section find the connections
			for each (var segment:Border in map.getBorders())
			{
				findConnections(segment);
			}
		}
		
		/**
		 * 
		 * @param segment: the segment of the map where to check the connections
		 * 
		 */
		private static function findConnections(segment:Border):void
		{
			//first fillup the holes
			var holes:Vector.<SinglePolygon> = segment.getHoles();
			for each (var hole:SinglePolygon in holes)
			{
				var n:int = hole.nodes.length;
				for (var i:int = 0; i < n; i++)
				{
					var a:IntPoint = hole.nodes[i];
					var b:IntPoint = hole.nodes[(i+1)%n];
					if (MapLineOfSight(segment,a,b))
					{
						var connection:Object = {a:a, b:b};
						navMesh.push(connection);
						
						connection = {a:b, b:a};
						navMesh.push(connection);
					}
				}
			}
			
			//now check the border
			var borderNodes:Vector.<IntPoint> = segment.poly.nodes;
			for (i = 0; i<borderNodes.length; i++)
			{
				a = borderNodes[i];
				for (var j:int = 0; j<borderNodes.length; j++)
				{
					b = borderNodes[j];
					if (a != b)
					{
						if (MapLineOfSight(segment,a,b))
						{
							connection = {a:a, b:b};
							navMesh.push(connection);
						}
					}
				}
			}
			
			//and now check all the connections on all the external polygons
			var polygons:Vector.<SinglePolygon> = segment.getPolygons();
			for each (var poly:SinglePolygon in polygons)
			{
				var points:Vector.<IntPoint> = poly.nodes;
				for (i =0; i<points.length;i++)
				{
					a = points[i];
					for each (var poly2:SinglePolygon in polygons)
					{
						if (poly != poly2)
						{
							var points2:Vector.<IntPoint> = poly2.nodes;
							for (j = 0; j<points2.length;j++)
							{
								b = points2[j];
								if (MapLineOfSight(segment, a,b))
								{
									connection = {a:a, b:b};
									navMesh.push(connection);
								}
							}
						}
					}
				}
			}
		}
			
		private static function MapLineOfSight(segment:Border, a:IntPoint, b:IntPoint):Boolean
		{				
			//check if the line cross any of the vertices of the segment
			for each (var vertices:SinglePolygon in segment.getPolygons())
			{
				var n:int = vertices.length();
				for (var i:int = 0; i<n; i++)
				{
					if (SegmentCross(a,b,vertices.at(i),vertices.at((i+1)%n)))
						return false;
				}
			}
			
			//the path node is inside the map and can be drawed
			var middle:IntPoint = new IntPoint((a.X+b.X)/2,(a.Y+b.Y)/2); 
			return segment.poly.InsideSingle(middle);
		}
		
		/**
		 * 
		 * @param a: start point of the first segment
		 * @param b: end point of the first segment
		 * @param c: start point of the second segment
		 * @param d: end point of the second segment
		 * @return: true if the first segment cross the second one
		 * 
		 */		
		public static function SegmentCross(a:IntPoint, b:IntPoint, c:IntPoint, d:IntPoint):Boolean
		{
			var denominator:Number = ((b.X -a.X)*(d.Y -c.Y))-((b.Y-a.Y)*(d.X-c.X));
			
			if (denominator == 0) return false;
			
			var numerator1:Number = ((a.Y-c.Y)*(d.X-c.X))-((a.X-c.X)*(d.Y-c.Y));
			var numerator2:Number = ((a.Y-c.Y)*(b.X-a.X))-((a.X-c.X)*(b.Y-a.Y));
			
			if (numerator1==0 || numerator2 == 0) return false;
			
			var r:Number = numerator1/denominator;
			var s:Number = numerator2/denominator;
			
			return (r>0 && r<1)&& (s>0 && s<1);
		}
		
		/**
		 * 
		 * @param start: the start point of the path
		 * @param end: the desired end point of the path
		 * @return the shortest path from point a to point b
		 * 
		 */		
		public static function Path(start:IntPoint, end:IntPoint):Array
		{
			var path:Array = new Array();
			
			// check if the start and end point are inside the same segment
			// return a warning if not
			for each (var segment:Border in map.getBorders())
			{
				if (segment.poly.InsideSingle(start) && segment.poly.InsideSingle(end))
				{
					// if the start and end are in direct line of sight, just return the direct connection between them
					if (MapLineOfSight(segment, start, end))
					{
						var connection:Object = { a:start, b:end };
						path.push(connection);
						return path;
					}
					//else calculate the path
					else
						path = DijkstraAlghoritm(segment, start, end);
				}	
				else
				{
					trace("start and end not in the same segment. impossible to calculate");
					return null;
				}
			}
			
			return path;
		}
		
		/**
		 * 
		 * @param segment: the segment of the map where the path will be
		 * @param start: the start point
		 * @param end: the end desired point
		 * @return: the shortest path
		 * 
		 */
		private static function DijkstraAlghoritm(segment:Border, start:IntPoint, end:IntPoint):Array
		{
			var tempNavmesh:Array = navMesh.concat();
			//connect the start and the end to the navMesh			
			var connection:Object;
			for each (var node:IntPoint in segment.nodes)
			{
				if (MapLineOfSight(segment, start, node) )
				{
					connection = {a:start, b:node};
					tempNavmesh.push(connection);
				}
				if (MapLineOfSight(segment, end, node) )
				{
					connection = {a:node, b:end};
					tempNavmesh.push(connection);
				}
			}
			
			//convert the start and the end point to nodes of the graph
			var startNode:Object = {point:start, parent:start, distance:0 };
			var endNode:Object = {point:end, parent:IntPoint, distance:100000};
			
			// convert the other nodes to graph nodes
			var graph:Array = makeGraphNodes(segment.nodes);
			graph.push(startNode);
			graph.push(endNode);
			
			
			var result:Array = new Array();
			
			var unvisitedNodes:Array = graph.concat();
			var visitedNodes:Vector.<IntPoint> = new Vector.<IntPoint>();
			
			while (unvisitedNodes.length != 0)
			{
				// find nearest node to the origin point
				// the first loop call will find the origin point
				unvisitedNodes.sortOn('distance', Array.NUMERIC);
				var currentNode:Object = unvisitedNodes.shift(); // shift the unvisited nodes
				visitedNodes.push(currentNode.point);			 // and push that node to the visited vector
				// find all the connected nodes 
				var neighbors:Vector.<IntPoint> = findNeighbors(tempNavmesh, currentNode);
				for each (var tempPoint:IntPoint in neighbors)
				{
					// if the neighbor was visited just continue with the next node
					if (visitedNodes.indexOf(tempPoint) <0)
					{
						// get the neighbor node and check his distance
						var nextNode:Object = getNode(graph, tempPoint);
						var dist:Number = distance(tempPoint, currentNode.point) + currentNode.distance;
						if (dist < nextNode.distance)
						{
							nextNode.distance = dist;
							nextNode.parent = currentNode.point;
						}
					}
				}
			}
				
			// when done, return the reversed path
			return reversePath(graph, end);
			
		}
		
		// make the path 
		// from the goal point, get the parent node 
		// and build the path
		private static function reversePath(graph:Array, end:IntPoint):Array
		{
			var start:Object = getNode(graph, end);
			var path:Array = new Array;
			var connection:Object;
			var done:Boolean = false
			while (!done)
			{
				connection = {a:start.point, b:start.parent};
				path.push(connection);
				if (start.distance ==0) done = true;
				else start = getNode(graph, start.parent);
			}
			
			trace(path.length);
			return path;
		}
		
		/**
		 * 
		 * @param graph: a graph nodes array
		 * @param point: the point to search the node
		 * @return his Node object
		 * 
		 */		
		private static function getNode(graph:Array, point:IntPoint):Object
		{
			for each (var o:Object in graph)
			{
				if (o.point == point)
					return o;
			}
			return null;
		}
		
		/**
		 * 
		 * @param nodes: the nodes point of the segment
		 * @return: a generated array of graph nodes
		 * a graph node object contains:
		 * 	- the node point
		 *  - a parent (initialized at null
		 *  - a distance (initialized at big number (is needed to avoid fake results when search the path))
		 */		
		private static function makeGraphNodes(nodes:Vector.<IntPoint>):Array
		{
			var node:Object = {point:IntPoint, parent:IntPoint, distance:Number};
			var result:Array = new Array();
			
			for each (var p:IntPoint in nodes)
			{
				node= {point:p, parent:IntPoint, distance:100000};		
				result.push(node);
			}
			return result;
		}
		
		/**
		 * 
		 * @param nodes: the array of all the connections of the map
		 * @param node: the graph node object where to search the parents
		 * @return: a Vector of points directly connected with the original node
		 * 
		 */		
		private static function findNeighbors(nodes:Array, node:Object):Vector.<IntPoint>
		{
			var result:Vector.<IntPoint> = new Vector.<IntPoint>();
			for each (var o:Object in nodes)
			{
				if (o.a == node.point)
					result.push(o.b);
			}
			return result;
		}
		
		
		public static function destroy():void
		{
			navMesh = new Array();
			map = null;
		}
	}
	
	
}