package Enginemath is
  
  type Scalar is digits 9 range -9000.0 .. 9000.0;
  
  type Vector2D is record
    X : Scalar;
    Y : Scalar;
  end record;
  
  function Vector2DZero return Vector2D;
  
  function Vector2DCrossProduct (A : Vector2D; B : Vector2D) return Scalar;
  
  function Vector2DMagnitude (V : Vector2D) return Scalar;
  
  function Vector2DNormalize (V : Vector2D) return Vector2D;
  
  function Vector2DSubtract (V1 : Vector2D; V2 : Vector2D) return Vector2D;
  
  function Vector2DAdd (V1 : Vector2D; V2 : Vector2D) return Vector2D;
  
  function Vector2DDivideScalar (V : Vector2D; S : Scalar) return Vector2D;
  
  function Vector2DDotProduct (V1 : Vector2D; V2 : Vector2D) return Scalar;
  
  function Vector2DNegate (V : Vector2D) return Vector2D;
  
  function Vector2DMultScalar (V : Vector2D; S : Scalar) return Vector2D;
  
  type Polygon2D is array (Positive range <>) of Vector2D with Dynamic_Predicate => Polygon2D'Length >= 3;
  subtype ConvexPolygon2D is Polygon2D with Dynamic_Predicate => (for all I in ConvexPolygon2D'Range => (Vector2DCrossProduct(ConvexPolygon2D(I), ConvexPolygon2D(I mod ConvexPolygon2D'Length + 1)) < 0.0) = (Vector2DCrossProduct(ConvexPolygon2D(I - 2 mod ConvexPolygon2D'Length + 1), ConvexPolygon2D(I)) < 0.0));
  type Polygon2DAccess is access Polygon2D;
  type ConvexPolygon2DAccess is access ConvexPolygon2D;
  type Collision2D is record
    CollidingNow : Boolean := false;
    CollisionComing : Boolean := false;
    Uncollide : Vector2D := Vector2D'(X => 0.0, Y => 0.0);
  end record;
  
  function DoPolygon2DCollision (PA : ConvexPolygon2DAccess; PAPos : Vector2D; PB : ConvexPolygon2DAccess; PBPos : Vector2D; Velocity : Vector2D) return Collision2D;
  
  function AABBs_Overlap (B1_TL : Vector2D; B1_BR : Vector2D; B2_TL : Vector2D; B2_BR : Vector2D) return Boolean;
  
end Enginemath;