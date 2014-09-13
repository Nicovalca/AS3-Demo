package pathfinding.utils
{
	import com.logicom.geom.IntPoint;
	import com.logicom.geom.Polygon;

	public function PolygonToVector(polygon:Polygon):Vector.<IntPoint>
	{
		var result:Vector.<IntPoint> = new Vector.<IntPoint>();
		for each (var p:IntPoint in polygon.getPoints())
		{
			result.push(p);
		}
		
		return result;
	}
}