with Component_Handling;
with Enginemath; use Enginemath;

package Entity_System is

  subtype Entity_Index is Natural range 1 .. 999999;

  type Entity_Table (Size : Entity_Index) is private;
  type Entity_Table_Access is access Entity_Table;
  
  -- use generics for the type of the component arrays, instantiate for each component type we want
  package Position2DComponentArray is new Component_Handling(Component => Vector2D);

  -- Should RNG hashing be used instead of string hashing?
  -- function spawn_entity () return Entity_Index;
  
  --type  is new ;

  -- implement these for each component type
  --function entity_get_component (ID : Entity_Index) return ;
  --function entity_set_component (ID : Entity_Index) return ;
  
  -- procedure destroy_entity (ID : Entity_Index);

private

  type Entity_Exists is (Yep, Nah);
  type Entity_Exists_Array is array (Entity_Index) of Entity_Exists;
  type Entity_Table (Size : Entity_Index) is record
    -- store the current number of entities
    -- array of Entity_Exists types to mark whether an entity exists for that index
    Positions : Position2DComponentArray.Component_Array(Entity_Index);
  end record;
-- Design:
-- array of access types
--- each access type holds another array of a component
-- a component is basically a flat "some" type pattern

  function hash (ET : Entity_Table) return Entity_Index;

end Entity_System;
