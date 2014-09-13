package pathfinding.utils
{
	import com.logicom.geom.IntPoint;

	public  function IsConcave(polygon:Vector.<IntPoint>, vertex:int):Boolean
	{	
		var current:IntPoint = polygon[vertex];
		var next:IntPoint = polygon[(vertex+1) % polygon.length];
		var previous:IntPoint = polygon[vertex ==0 ? polygon.length-1 : vertex-1];
		
		var left:IntPoint = new IntPoint(current.X-previous.X, current.Y-previous.Y);
		var right:IntPoint = new IntPoint(next.X-current.X, next.Y-current.Y);
				
		var cross:Number = (left.X*right.Y)-(left.Y*right.X);
				
		return cross<0;
		
	}
}