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
	
	import pathfinding.utils.IsConcave;

	public class Border
	{
		private var border:SinglePolygon;
		private var holes:Vector.<SinglePolygon>;
		
		//all nodes vector
		private var _nodes:Vector.<IntPoint>;
		
		/**
		 * 
		 * @param border: default constructor
		 * - It will add a border and initialize the holes and nodes vector
		 * 
		 */		
		public function Border(_border:SinglePolygon):void
		{
			border = _border;
			holes = new Vector.<SinglePolygon>();
			_nodes = new Vector.<IntPoint>();
			border.nodes = findNodes(border);
			
		}
		
		
		/**
		 * 
		 * @param hole: the hole to add on the holes array
		 * 
		 */		
		public function addHole(_hole:SinglePolygon):void
		{
			holes.push(_hole);
			holes[holes.length-1].nodes = findNodes(_hole);
		}
		
		/**
		 * 
		 * @param poly: the polygon to check
		 * @param hole: ToDo. add convex vertex if is a hole
		 * @return 
		 * 
		 */		
		private function findNodes(poly:SinglePolygon, hole:Boolean = false):Vector.<IntPoint>
		{
			var tempNodes:Vector.<IntPoint> = new Vector.<IntPoint>();
			for (var i:int = 0; i<poly.length(); i++)
			{
				if (IsConcave(poly.points(), i))
				{
					_nodes.push(poly.at(i));
					tempNodes.push(poly.at(i));
					
				}
			}
			return tempNodes;
		}
		
		/**
		 * 
		 * @return all the single polygons
		 * 
		 */		
		public function getPolygons():Vector.<SinglePolygon>
		{
			var result:Vector.<SinglePolygon> = new Vector.<SinglePolygon>();
			result.push(border);
			for each (var p:SinglePolygon in holes)
			{
				result.push(p);					
			}
			return result;
		}
		
		/**
		 * 
		 * @return all the holes 
		 * in format of single polygons
		 */		
		public function getHoles():Vector.<SinglePolygon>	{ return holes;	}

		
		public function get nodes():Vector.<IntPoint> {	return _nodes; }
		public function get poly():SinglePolygon      { return border; }
	}
}