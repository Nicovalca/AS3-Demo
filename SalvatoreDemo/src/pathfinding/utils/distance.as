package pathfinding.utils
{
	import com.logicom.geom.IntPoint;
	
		public function distance(vec1:IntPoint, vec2:IntPoint):Number
		{
			return Math.sqrt(Math.pow(vec2.X-vec1.X,2)+Math.pow(vec2.Y-vec1.Y,2));
		}
	
}