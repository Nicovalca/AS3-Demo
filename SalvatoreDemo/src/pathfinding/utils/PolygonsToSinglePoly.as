package pathfinding.utils
{
	import com.logicom.geom.Polygon;
	import com.logicom.geom.Polygons;
	
	import pathfinding.SinglePolygon;
	import pathfinding.utils.PolygonToVector;

	public function PolygonsToSinglePoly(polygons:Polygons):Vector.<SinglePolygon>
	{
		var result:Vector.<SinglePolygon> = new Vector.<SinglePolygon>();
		for each (var poly:Polygon in polygons.getPolygons())
		{
			var p:SinglePolygon = new SinglePolygon(PolygonToVector(poly));
			result.push(p);
		}
		return result;
	}
}