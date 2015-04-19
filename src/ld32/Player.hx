package ld32;
import dl.input.Keyboard;
import flash.display.MovieClip;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionType;
import nape.dynamics.Arbiter;
import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.phys.Material;
import nape.shape.Polygon;
//import nape.space.Space;

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
	var _anim:PlayerUI;
	var _currentAnim:String;
	
	public var velX = 700;
	public var velJump = 1000;
	public var velXJump = 300;
	
	public var dir:Vec2;
	
	public function new() 
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
		//body.space = space;
		body.allowRotation = false;
		body.userData.name = "player";
		body.userData.display = this;
		napeDatas = new NapeDatas();
		body.userData.napeDatas = napeDatas;
		
		display = _anim = new PlayerUI();
		
		controller = new Keyboard( 0.08 );
		
		dir = PhysicManager.gravityBottom;
		
		controller.addKeyListener( Keys.keyBottom, null, changeDir );
		controller.addKeyListener( Keys.keyB1, null, moveToDir );
	}
	
	function changeDir()
	{
		if ( dir == PhysicManager.gravityBottom )
			dir = PhysicManager.gravityRight;
		else if ( dir == PhysicManager.gravityRight )
			dir = PhysicManager.gravityTop;
		else if ( dir == PhysicManager.gravityTop )
			dir = PhysicManager.gravityLeft;
		else
			dir = PhysicManager.gravityBottom;
		
		//var angle = _anim.rotation - ( (dir.angle - PhysicManager.i().currentGravity.angle) - Entity.HALF_PI) * Entity.RAD_TO_DEGREES;
		var angle = (PhysicManager.i().currentGravity.angle - dir.angle) * Entity.RAD_TO_DEGREES;
		motion.Actuate.tween( _anim.arrowScaleUI.arrowRotUI, 0.5, { rotation: PhysicManager.modRotDegrees( _anim.arrowScaleUI.arrowRotUI.rotation, angle ) } ).ease(motion.easing.Elastic.easeOut);
	}
	
	function moveToDir()
	{
		if ( dir != PhysicManager.i().currentGravity )
			PhysicManager.i().changeG( dir );
		
		motion.Actuate.tween( _anim.arrowScaleUI.arrowRotUI, 0.5, { rotation:0 } ).ease (motion.easing.Elastic.easeOut);
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
		{
			_anim.scaleX = dir;
			_anim.arrowScaleUI.scaleX = dir;
		}
		
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