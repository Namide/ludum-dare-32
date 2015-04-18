package ld32;
import dl.input.Keyboard;
import flash.display.MovieClip;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionType;
import nape.dynamics.Arbiter;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
import nape.space.Space;

/**
 * ...
 * @author Namide (Damien Doussaud)
 */
class Player extends Entity
{
	//public var body:Body;
	public var controller:Keyboard;
	public var napeDatas:NapeDatas;
	
	var _mat:Material;
	var _anim:MovieClip;
	var _currentAnim:String;
	
	public var velX = 700;
	public var velJump = 600;
	public var velXJump = 300;
	
	public function new( space:Space ) 
	{
		super();
		
		var shape = new Polygon(Polygon.rect( -24, -32, 48, 64));
		_mat = shape.material;
		_mat.staticFriction = 0;
		_mat.elasticity = 0;
		_mat.density = 0.01;
		
		body = new Body( BodyType.DYNAMIC );
		body.shapes.add( shape );
		body.position.setxy(-50, 0);
		body.space = space;
		body.allowRotation = false;
		body.userData.name = "player";
		body.userData.display = this;
		napeDatas = new NapeDatas();
		body.userData.napeDatas = napeDatas;
		
		display = _anim = new PlayerUI();
		
		controller = new Keyboard( 0 );
	}
	
	public override function upd( t:Float )
	{
		var contacts = Entity.getContacts( body );
		var axisX = controller.getAxisX();
		var axisY = controller.getAxisY();
		
		
		// DEAD!
		if ( contacts.top && contacts.bottom )
		{
			trace("ecrasé");
		}
		else if ( contacts.left && contacts.right )
		{
			trace("pressé");
		}
		
		
		// CONTROLS
		if ( contacts.bottom )
		{
			updX( axisX * velX );
			
			if ( axisX == 0 )
			{
				_mat.dynamicFriction = 0; //Take away friction so he can accelerate.
				_mat.staticFriction = 0;
			}
			else
			{
				_mat.dynamicFriction = 1;
				_mat.staticFriction = 2;
			}
			
			if ( axisY < 0 )
			{
				updY( -velJump );
				
				if ( body.velocity.x > velXJump  )
					updX( velXJump );
					
				if ( body.velocity.x < -velXJump )
					updX( -velXJump );
					
				if ( axisX == 0 )
					updX( 0 );
			}
		}
		else
		{
			if ( 	(axisX > 0 && !contacts.right) ||
					(axisX < 0 && !contacts.left) )
			{
				updX( axisX * velXJump );
			}
		}
		
		// ANIMATION
		var nextAnim = "pause";
		var dir = 0;
		if ( contacts.bottom )
		{
			if ( axisX > 0 )
			{
				dir = 1;
				nextAnim = "run";
			}
			else if ( axisX < 0 )
			{
				dir = -1;
				nextAnim = "run";
			}
		}
		else
		{
			if ( axisX > 0 )
			{
				dir = 1;
			}
			else if ( axisX < 0 )
			{
				dir = -1;
			}
			nextAnim = "jump";
		}
		
		if ( dir != 0 && dir != Std.int( _anim.scaleX ) )
			_anim.scaleX = dir;
		
		if ( nextAnim != _currentAnim )
		{
			_currentAnim = nextAnim;
			_anim.gotoAndStop( nextAnim );
		}
		
		
		
		
		super.upd( t );
	}
	
	public function updY( v:Float )
	{
		var cg = PhysicManager.i().currentGravity;
		
		if ( cg == PhysicManager.gravityBottom )
		{
			body.velocity.y = v;
		}
		else if ( cg == PhysicManager.gravityTop )
		{
			body.velocity.y = -v;
		}
		else if ( cg == PhysicManager.gravityLeft )
		{
			body.velocity.x = -v;
		}
		else // PhysicManager.gravityRight
		{
			body.velocity.x = v;
		}
	}
	
	public function updX( v:Float )
	{
		var cg = PhysicManager.i().currentGravity;
		
		if ( cg == PhysicManager.gravityBottom )
		{
			body.velocity.x = v;
		}
		else if ( cg == PhysicManager.gravityTop )
		{
			body.velocity.x = -v;
		}
		else if ( cg == PhysicManager.gravityLeft )
		{
			body.velocity.y = v;
		}
		else // PhysicManager.gravityRight
		{
			body.velocity.y = -v;
		}
	}
	
}