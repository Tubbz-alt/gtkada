-----------------------------------------------------------------------
--          GtkAda - Ada95 binding for the Gimp Toolkit              --
--                                                                   --
--                     Copyright (C) 1998-2000                       --
--        Emmanuel Briot, Joel Brobecker and Arnaud Charlet          --
--                                                                   --
-- This library is free software; you can redistribute it and/or     --
-- modify it under the terms of the GNU General Public               --
-- License as published by the Free Software Foundation; either      --
-- version 2 of the License, or (at your option) any later version.  --
--                                                                   --
-- This library is distributed in the hope that it will be useful,   --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of    --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU --
-- General Public License for more details.                          --
--                                                                   --
-- You should have received a copy of the GNU General Public         --
-- License along with this library; if not, write to the             --
-- Free Software Foundation, Inc., 59 Temple Place - Suite 330,      --
-- Boston, MA 02111-1307, USA.                                       --
--                                                                   --
-- As a special exception, if other files instantiate generics from  --
-- this unit, or you link this unit with other files to produce an   --
-- executable, this  unit  does not  by itself cause  the resulting  --
-- executable to be covered by the GNU General Public License. This  --
-- exception does not however invalidate any other reasons why the   --
-- executable file  might be covered by the  GNU Public License.     --
-----------------------------------------------------------------------

with System;
with Gdk; use Gdk;
with Gtk.Util; use Gtk.Util;

package body Gtk.Color_Selection is

   ---------------
   -- Get_Color --
   ---------------

   procedure Get_Color (Colorsel : access Gtk_Color_Selection_Record;
                        Color    : out Color_Array)
   is
      procedure Internal (Colorsel : in System.Address;
                          Color    : out Color_Array);
      pragma Import (C, Internal, "gtk_color_selection_get_color");
   begin
      Color (Opacity) := 0.0;
      Internal (Get_Object (Colorsel), Color);
   end Get_Color;

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New (Widget : out Gtk_Color_Selection) is
   begin
      Widget := new Gtk_Color_Selection_Record;
      Initialize (Widget);
   end Gtk_New;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Widget : access Gtk_Color_Selection_Record'Class) is
      function Internal return System.Address;
      pragma Import (C, Internal, "gtk_color_selection_new");
   begin
      Set_Object (Widget, Internal);
      Initialize_User_Data (Widget);
   end Initialize;

   ---------------
   -- Set_Color --
   ---------------

   procedure Set_Color (Colorsel : access Gtk_Color_Selection_Record;
                        Color    : in Color_Array)
   is
      procedure Internal (Colorsel : in System.Address;
                          Color    : in System.Address);
      pragma Import (C, Internal, "gtk_color_selection_set_color");
   begin
      Internal (Get_Object (Colorsel), Color (Color'First)'Address);
   end Set_Color;

   -----------------
   -- Set_Opacity --
   -----------------

   procedure Set_Opacity (Colorsel    : access Gtk_Color_Selection_Record;
                          Use_Opacity : in Boolean)
   is
      procedure Internal (Colorsel    : in System.Address;
                          Use_Opacity : in Gint);
      pragma Import (C, Internal, "gtk_color_selection_set_opacity");
   begin
      Internal (Get_Object (Colorsel), Boolean'Pos (Use_Opacity));
   end Set_Opacity;

   -----------------------
   -- Set_Update_Policy --
   -----------------------

   procedure Set_Update_Policy (Colorsel : access Gtk_Color_Selection_Record;
                                Policy   : in Enums.Gtk_Update_Type)
   is
      procedure Internal (Colorsel : in System.Address;
                          Policy   : in Gint);
      pragma Import (C, Internal, "gtk_color_selection_set_update_policy");
   begin
      Internal (Get_Object (Colorsel), Enums.Gtk_Update_Type'Pos (Policy));
   end Set_Update_Policy;

   --------------
   -- Generate --
   --------------

   procedure Generate (N : in Node_Ptr; File : in File_Type) is
   begin
      Gen_New (N, "Color_Selection", File => File);
      Gen_Set (N, "Color_Selection", "Update_Policy", "policy", File => File);
      Box.Generate (N, File);
   end Generate;

   procedure Generate
     (Colorsel : in out Object.Gtk_Object;
      N        : in Node_Ptr)
   is
      S : String_Ptr;
   begin
      if not N.Specific_Data.Created then
         Gtk_New (Gtk_Color_Selection (Colorsel));
         Set_Object (Get_Field (N, "name"), Colorsel);
         N.Specific_Data.Created := True;
      end if;

      Box.Generate (Colorsel, N);

      S := Get_Field (N, "policy");

      if S /= null then
         Set_Update_Policy (Gtk_Color_Selection (Colorsel),
           Enums.Gtk_Update_Type'Value (S (S'First + 4 .. S'Last)));
      end if;
   end Generate;

end Gtk.Color_Selection;
