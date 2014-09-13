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
 * The container of the polygons												*
 * when initialized the class search for borders and holes                      *
 * and depatch them into corresponding vectors									*
 *******************************************************************************/

package pathfinding
{
	import com.logicom.geom.IntPoint;
	import com.logicom.geom.Polygon;
	import com.logicom.geom.Polygons;
	
	import pathfinding.utils.PolygonsToSinglePoly;

	public class Map
	{
		public static var borders:Vector.<Border>;
		public static var holes:Vector.<SinglePolygon>;
		
		private static var _map:Vector.<SinglePolygon>;

		public function Map(polys:Polygons = null)
		{
			borders = new Vector.<Border>();
			depatchIt(PolygonsToSinglePoly(polys));	
		}
		
		private function depatchIt(polys:Vector.<SinglePolygon> ):void
		{
			var tempHoles:Vector.<SinglePolygon> = new Vector.<SinglePolygon>();
			for each (var poly:SinglePolygon in polys)
			{
				var isBorder:Boolean = true;
				//take his first point and search if is inside any other polygon
				var pointToCheck:IntPoint = poly.first();
				for (var i:int = 0; i<polys.length; i++)
				{
					if (polys[i] != poly)
					{
						if (polys[i].InsideSingle(pointToCheck))
							isBorder = false;
					}
				}
				if (isBorder)
					borders.push(new Border(poly));
				else
					tempHoles.push(poly);
			}
			
			findHoles(tempHoles);
		}
		
		private function findHoles(tempHoles:Vector.<SinglePolygon>):void
		{
			for each (var hole:SinglePolygon in tempHoles)
			{
				for each (var border:Border in borders)
				{
					if (border.poly.InsideSingle(hole.first()))
						border.addHole(hole);
				}
			}
		}
		
		public function getBorders():Vector.<Border> { return borders; }
	}
}