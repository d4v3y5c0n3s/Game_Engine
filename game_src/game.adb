with Ada.Directories;
with Ada.Calendar; use Ada.Calendar;
with Ada.Text_IO;
with Interfaces.C; use Interfaces.C;
with Interfaces; use Interfaces;
with System; use System;
with Ada.Unchecked_Conversion;
with allegro5_events_h; use allegro5_events_h;
with allegro5_system_h; use allegro5_system_h;
with allegro5_base_h; use allegro5_base_h;
with allegro5_keyboard_h; use allegro5_keyboard_h;
with allegro_primitives_h; use allegro_primitives_h;
with allegro_image_h; use allegro_image_h;
with allegro5_display_h; use allegro5_display_h;
with allegro5_color_h; use allegro5_color_h;
with allegro5_drawing_h; use allegro5_drawing_h;
with allegro_font_h; use allegro_font_h;
with Entity_System; use Entity_System;

procedure Game is

  function dlopen (FN : char_array; Flags : int) return Address;
  pragma Import (C, dlopen);
  
  function dlclose (Handle : Address) return Integer;
  pragma Import (C, dlclose);
  
  function dlsym (Handle : Address; Symbol : char_array) return Address;
  pragma Import (C, dlsym);

  type external_process is access procedure (UpdateDelta : Duration; ET : Entity_Table_Access);
  function To_Ptr is new Ada.Unchecked_Conversion(Address, external_process);
  
  UpdateInterval : constant Duration := 0.033;
  LibraryName : constant String := "reloadable_project/lib/libReloadable_Project.so";
  Allegro_Initialization_Failure : exception;
  EntityCount : constant Entity_Index := 99999;
  Dynamic_Library_Not_Found : exception;
  
  protected HotLibrary is
    function GetProcessFunc return external_process;
    --function GetInputFunc () return ;
    function GetLib return Address;
    procedure SetLibAndFuncs (L : Address; ProcFunc : external_process);
  private
    Library : Address := Null_Address;
    ProcessFunc : external_process := null;
  end HotLibrary;
  
  protected Entities is
    procedure Set_ET (Table : Entity_Table_Access);
    function Get_ET return Entity_Table_Access;
  private
    ET : Entity_Table_Access := new Entity_Table(EntityCount);
  end Entities;
  
  protected body HotLibrary is
    procedure SetLibAndFuncs (L : Address; ProcFunc : external_process) is
    begin
      Library := L;
      ProcessFunc := ProcFunc;
    end SetLibAndFuncs;
    
    function GetProcessFunc return external_process is
    begin
      return ProcessFunc;
    end GetProcessFunc;
    
    function GetLib return Address is
    begin
      return Library;
    end GetLib;
  end HotLibrary;
  
  protected body Entities is
    procedure Set_ET (Table : Entity_Table_Access) is
    begin
      ET := Table;
    end Set_ET;
    function Get_ET return Entity_Table_Access is
    begin
      return ET;
    end Get_ET;
  end Entities;
  
  task HotReloadProgram;
  --task RunInput;
  --task DrawGame;
  
  task body HotReloadProgram is
    LastUpdateTime : Ada.Calendar.Time := Time_Of(1901, 1, 1);
    CurrentUpdateTime : Ada.Calendar.Time := Time_Of(1901, 1, 1);
  begin
    loop
      if Ada.Directories.Exists(LibraryName) then
        CurrentUpdateTime := Ada.Directories.Modification_Time(LibraryName);
      elsif not Ada.Directories.Exists(LibraryName) then
        raise Dynamic_Library_Not_Found;
      end if;
      if CurrentUpdateTime /= LastUpdateTime then
        ReloadLibrary: declare
          PrevLibHandle : Address := HotLibrary.GetLib;
          CurLibHandle : Address := Null_Address;
          ProcFuncTemp : external_process := null;
          test_close_ret : Integer;
        begin
          LastUpdateTime := CurrentUpdateTime;
          if PrevLibHandle /= Null_Address then
            test_close_ret := dlclose(PrevLibHandle);
          end if;
          CurLibHandle := dlopen(To_C(LibraryName), 1);
          HotLibrary.SetLibAndFuncs(CurLibHandle, To_Ptr(dlsym(CurLibHandle, To_C("process"))));
        end ReloadLibrary;
      end if;
      delay 3.0;
    end loop;
  end HotReloadProgram;
  
  --task body RunInput is
  --begin
  --  null;
  --end RunInput;
  --
  --task body DrawGame is
  --begin
  --  null;
  --end DrawGame;
  
  Q : access ALLEGRO_EVENT_QUEUE;
  Display : access ALLEGRO_DISPLAY;
  DisplayEventSrc : access ALLEGRO_EVENT_SOURCE;
  KBEventSrc : access ALLEGRO_EVENT_SOURCE;
  
  pf : external_process := null;
  PrevUpdateTime : Time := Clock;
  CurrentUpdateTime : Time := PrevUpdateTime;
  TempTable : Entity_Table_Access;

begin
  if al_install_system(Interfaces.C.int(al_get_allegro_version), null) and
  al_install_keyboard and
  al_init_primitives_addon and
  al_init_image_addon then
    Q := al_create_event_queue;
    Display := al_create_display(600, 400);
    DisplayEventSrc := al_get_display_event_source(Display);
    al_register_event_source(Q, DisplayEventSrc);
    KBEventSrc := al_get_keyboard_event_source;
    loop
      pf := HotLibrary.GetProcessFunc;
      CurrentUpdateTime := Clock;
      if pf /= null then
        TempTable := Entities.Get_ET;
        pf(CurrentUpdateTime - PrevUpdateTime, TempTable);
        Entities.Set_ET(TempTable);
        PrevUpdateTime := CurrentUpdateTime;
      end if;
      delay until CurrentUpdateTime + UpdateInterval;
    end loop;
    al_register_event_source(Q, KBEventSrc);
    al_destroy_event_queue(Q);
    al_destroy_display(Display);
  else
    raise Allegro_Initialization_Failure;
  end if;
end Game;
