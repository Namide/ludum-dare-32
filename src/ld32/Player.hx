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
	//public var napeDatas:NapeDatas;
	public var isPlayable:Bool;
	public var isDead:Bool;
	
	var _mat:Material;
	var _anim:PlayerUI;
	var _currentAnim:String;
	
	public var velX = 700;
	public var velJump = 1000;
	public var velXJump = 300;
	
	public var dir:Vec2;
	
	public var onMove:Void->Void;
	public var onDead:Void->Void;
	public var onJump:Void->Void;
	public var onChangeG:Void->Void;
	public var onAppliG:Void->Void;
	
	public function removeListener()
	{
		onMove = 
		onDead =
		onJump =
		onChangeG = 
		onAppliG = null;
	}
	
	public function new() 
	{
		super();
		
		//playable = false;
		
		var shape = new Polygon(Polygon.rect( -24, -0, 48, 32));
		_mat = shape.material;
		_mat.staticFriction = 0;
		_mat.elasticity = 0;
		_mat.density = 0.01;
		
		r = 32;
		
		
		body = new Body( BodyType.DYNAMIC );
		body.shapes.add( shape );
		body.position.setxy(-50, 0);
		//body.space = space;
		body.allowRotation = false;
		body.userData.name = "player";
		//body.userData.display = this;
		//napeDatas = new NapeDatas();
		//body.userData.napeDatas = napeDatas;
		
		display = _anim = new PlayerUI();
		
		controller = new Keyboard( 0.08 );
		
		dir = PhysicManager.gravityBottom;
		
		controller.addKeyListener( Keys.keyBottom, null, changeDir );
		controller.addKeyListener( Keys.keyB1, null, moveToDir );
		
		pause();
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
		
		if ( onChangeG != null )
			onChangeG();
		
		//var angle = _anim.rotation - ( (dir.angle - PhysicManager.i().currentGravity.angle) - Entity.HALF_PI) * Entity.RAD_TO_DEGREES;
		var angle = (PhysicManager.i().currentGravity.angle - dir.angle) * Entity.RAD_TO_DEGREES;
		motion.Actuate.tween( _anim.arrowScaleUI.arrowRotUI, 0.5, { rotation: PhysicManager.modRotDegrees( _anim.arrowScaleUI.arrowRotUI.rotation, angle ) } ).ease(motion.easing.Elastic.easeOut);
	}
	
	function moveToDir()
	{
		if ( dir != PhysicManager.i().currentGravity )
		{
			PhysicManager.i().changeG( dir );
			
			if ( onAppliG != null )
				onAppliG();
		}
		
		motion.Actuate.tween( _anim.arrowScaleUI.arrowRotUI, 0.5, { rotation:0 } ).ease (motion.easing.Elastic.easeOut);
	}
	
	override public function dispose() 
	{
		pause();
		super.dispose();
		controller.dispose();
	}
	
	public function dead()
	{
		isPlayable = false;
		isDead = true;
		
		_currentAnim = "dead";
		_anim.gotoAndStop( _currentAnim );
	}
	
	function pause()
	{
		isPlayable = false;
		
		_anim.scaleX = 1;
		if ( _anim.arrowScaleUI != null )
			_anim.arrowScaleUI.scaleX = 1;
		
		_currentAnim = "pause";
		_anim.gotoAndStop( _currentAnim );
	}
	
	public override function upd( t:Float )
	{
		if ( isDead )
			return;
		
		super.upd( t );
		
		if ( !isPlayable )
			return;
		
		var contacts = Entity.getContacts( body );
		var axisX = controller.getAxisX();
		var axisY = controller.getAxisY();
		
		
		// DEAD!
		if ( contacts.top && contacts.bottom )
		{
			if ( onDead != null )
				onDead();
			return;
			//trace("ecrasé");
		}
		else if ( contacts.left && contacts.right )
		{
			if ( onDead != null )
				onDead();
			return;
			//trace("pressé");
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
				
				if ( onMove != null )
					onMove();
			}
			else if ( axisX < 0 )
			{
				dir = -1;
				nextAnim = "run";
				
				if ( onMove != null )
					onMove();
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
			
			if ( onJump != null )
				onJump();
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