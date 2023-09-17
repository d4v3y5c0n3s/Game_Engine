with Ada.Numerics.Elementary_Functions; use Ada.Numerics.Elementary_Functions;

package body Enginemath is

  function Vector2DZero return Vector2D is
  begin
    return Vector2D'(X => 0.0, Y => 0.0);
  end Vector2DZero;
  
  function Vector2DCrossProduct (A : Vector2D; B : Vector2D) return Scalar is
  begin
    return A.X * B.Y - A.Y * B.X;
  end Vector2DCrossProduct;
  
  function Vector2DMagnitude (V : Vector2D) return Scalar is
  begin
    return Scalar(Sqrt(Float(V.X ** 2 + V.Y ** 2)));
  end Vector2DMagnitude;
  
  function Vector2DNormalize (V : Vector2D) return Vector2D is
    magnitude : constant Scalar := Vector2DMagnitude(V);
  begin
    return Vector2D'(X => V.X / magnitude, Y => V.Y / magnitude);
  end Vector2DNormalize;
  
  function Vector2DSubtract (V1 : Vector2D; V2 : Vector2D) return Vector2D is
  begin
    return Vector2D'(X => V1.X - V2.X, Y => V1.Y - V2.Y);
  end Vector2DSubtract;
  
  function Vector2DAdd (V1 : Vector2D; V2 : Vector2D) return Vector2D is
  begin
    return Vector2D'(X => V1.X + V2.X, Y => V1.Y + V2.Y);
  end Vector2DAdd;
  
  function Vector2DDivideScalar (V : Vector2D; S : Scalar) return Vector2D is
  begin
    return Vector2D'(X => V.X / S, Y => V.Y / S);
  end Vector2DDivideScalar;
  
  function Vector2DDotProduct (V1 : Vector2D; V2 : Vector2D) return Scalar is
  begin
    return V1.X * V2.X + V1.Y * V2.Y;
  end Vector2DDotProduct;
  
  function Vector2DNegate (V : Vector2D) return Vector2D is
  begin
    return Vector2D'(X => -V.X, Y => -V.Y);
  end Vector2DNegate;
  
  function Vector2DMultScalar (V : Vector2D; S : Scalar) return Vector2D is
  begin
    return Vector2D'(X => V.X * S, Y => V.Y * S);
  end Vector2DMultScalar;
  
  function DoPolygon2DCollision (PA : ConvexPolygon2DAccess; PAPos : Vector2D; PB : ConvexPolygon2DAccess; PBPos : Vector2D; Velocity : Vector2D) return Collision2D is
    MinInterval : Scalar := Scalar'Last;
    MinIntervalAxis : Vector2D := Vector2D'(X => 0.0, Y => 0.0);
    RetCollision : Collision2D;
  begin
    RetCollision.CollidingNow := true;
    for I in 1 .. PA'Length + PB'Length loop
      ProcessEdges:
        declare
          function OnFirstPolygon return Boolean is begin
            return I <= PA'Length;
          end;
          VA : constant Vector2D := (if OnFirstPolygon then PA(I) else PB(I - PA'Length));
          VB : constant Vector2D := (if OnFirstPolygon then PA(I mod PA'Length + 1) else PB((I - PA'Length) mod PB'Length + 1));
          EdgeV : constant Vector2D := Vector2DSubtract(VB, VA);
          Axis : constant Vector2D := Vector2DNormalize(Vector2D'(X => -(EdgeV.Y), Y => EdgeV.X));
          MinA : Scalar;
          MaxA : Scalar;
          MinB : Scalar;
          MaxB : Scalar;
          procedure PolygonProjection (P : ConvexPolygon2DAccess; PPos : Vector2D; Min : out Scalar; Max : out Scalar) is
            dot : Scalar;
          begin
            Min := Vector2DDotProduct(Axis, Vector2DAdd(PPos, P(1)));
            Max := Vector2DDotProduct(Axis, Vector2DAdd(PPos, P(1)));
            for J in 1 .. P'Length loop
              dot := Vector2DDotProduct(Axis, Vector2DAdd(PPos, P(J)));
              if dot < Min then
                Min := dot;
              elsif dot > Max then
                Max := dot;
              end if;
            end loop;
          end PolygonProjection;
          function IntervalDist (Min1 : Scalar; Max1 : Scalar; Min2 : Scalar; Max2 : Scalar) return Scalar is
            ret : constant Scalar := Scalar'Min(abs(Min1 - Max2), abs(Min2 - Max1));
          begin
            if Min2 >= Max1 or Min1 >= Max2 then
              return ret;
            else
              return -ret;
            end if;
          end IntervalDist;
          VelProj : constant Scalar := Vector2DDotProduct(Axis, Velocity);
          ProjectedInterval : Scalar;
          UnprojectedInterval : Scalar;
        begin
          PolygonProjection(PA, PAPos, MinA, MaxA);
          PolygonProjection(PB, PBPos, MinB, MaxB);
          UnprojectedInterval := IntervalDist(MinA, MaxA, MinB, MaxB);
          if UnprojectedInterval > 0.0 then
            RetCollision.CollidingNow := false;
            if VelProj < 0.0 then
              MinA := MinA + VelProj;
            else
              MaxA := MaxA + VelProj;
            end if;
            ProjectedInterval := IntervalDist(MinA, MaxA, MinB, MaxB);
            if ProjectedInterval > 0.0 then
              return Collision2D'(CollisionComing => false, CollidingNow => false, Uncollide => Vector2D'(X => 0.0, Y => 0.0));
            else
              RetCollision.CollisionComing := true;
            end if;
            ProjectedInterval := abs(ProjectedInterval);
            if ProjectedInterval < MinInterval then
              MinInterval := ProjectedInterval;
              MinIntervalAxis := Axis;
              if Vector2DDotProduct(Vector2DSubtract(PAPos, PBPos), MinIntervalAxis) < 0.0 then
                MinIntervalAxis := Vector2DNegate(MinIntervalAxis);
              end if;
            end if;
          end if;
        end ProcessEdges;
    end loop;
    if RetCollision.CollisionComing then
      RetCollision.Uncollide := Vector2DMultScalar(MinIntervalAxis, MinInterval);
    end if;
    return RetCollision;
  end DoPolygon2DCollision;
  
  function AABBs_Overlap (B1_TL : Vector2D; B1_BR : Vector2D; B2_TL : Vector2D; B2_BR : Vector2D) return Boolean is
  begin
    return (B1_TL.X <= B2_BR.X and B2_TL.X <= B1_BR.X and B1_TL.Y <= B2_BR.Y and B2_TL.Y <= B1_BR.Y);
  end AABBs_Overlap;
  
end Enginemath;