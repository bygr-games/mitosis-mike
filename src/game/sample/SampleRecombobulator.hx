package sample;

class SampleRecombobulator extends Entity {
	static inline var TAG_STEP = 10;
	static inline var MAX_TAG_VALUE = 100;
	static inline var REQUIRED_EPSILON = 0.001;

	public var completePercentage(default,null) = 0.0;
	public var requiredPercentage(default,null) : Float;

	var hasSpawnedPlayer = false;
	var currentTag : Null<String>;

	public function new(cx:Int, cy:Int, requiredPercentage:Float) {
		super(cx, cy);
		iwid = 16;
		ihei = 32;
		this.requiredPercentage = M.fmax(0, requiredPercentage);
		updateTag();
	}

	inline function getDisplayValue() {
		return (MAX_TAG_VALUE - requiredPercentage) + completePercentage;
	}

	function getRoundedTag() {
		var steppedValue = Std.int(Math.floor(getDisplayValue() / TAG_STEP)) * TAG_STEP;
		return M.iclamp(steppedValue, 0, MAX_TAG_VALUE);
	}

	function updateTag() {
		var nextTag = Std.string(getRoundedTag());
		if( currentTag==nextTag )
			return;

		currentTag = nextTag;
		if( Assets.recombobulator.exists(nextTag) ) {
			spr.set(Assets.recombobulator, nextTag, 0);
			if( spr.group!=null && spr.group.anim!=null && spr.group.anim.length>0 )
				spr.anim.playAndLoop(nextTag);
			else if( spr.animAllocated )
				spr.anim.stopWithoutStateAnims(nextTag, 0);
		}
		else
			spr.setEmptyTexture();
	}

	inline function isComplete() {
		return completePercentage + REQUIRED_EPSILON >= requiredPercentage;
	}

	function trySpawnPlayer() {
		if( hasSpawnedPlayer || !isComplete() )
			return;

		hasSpawnedPlayer = true;
		var spawnX = right + Const.GRID * 0.5;
		var spawnY = attachY;
		new SamplePlayer(spawnX, spawnY, true);
	}

	public function absorbPercentage(value:Float) {
		if( hasSpawnedPlayer || value<=0 )
			return;

		completePercentage = M.fmin(requiredPercentage, completePercentage + value);
		updateTag();
		trySpawnPlayer();
	}

	override function postUpdate() {
		super.postUpdate();
		updateTag();
	}
}