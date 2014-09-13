package pathfinding.utils
{
	import nape.geom.Vec2;
	import com.logicom.geom.IntPoint;
	
	public function pointToNape(point:IntPoint):Vec2
	{
		return new Vec2(point.X, point.Y);
	}
	
}