with entity_system; use entity_system;

package Game_Logic is

  procedure process (UpdateDelta : Duration; ET : Entity_Table_Access) with Export => True, Convention => C, External_Name => "process";
  
  -- (Allegro Event Type, in out input state)
  --procedure input () with Export => True, Convention => C, External_Name => "input";

end Game_Logic;
