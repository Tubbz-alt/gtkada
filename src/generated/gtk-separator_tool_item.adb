-----------------------------------------------------------------------
--               GtkAda - Ada95 binding for Gtk+/Gnome               --
--                                                                   --
--   Copyright (C) 1998-2000 E. Briot, J. Brobecker and A. Charlet   --
--                Copyright (C) 2000-2011, AdaCore                   --
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

pragma Style_Checks (Off);
pragma Warnings (Off, "*is already use-visible*");
with Glib.Type_Conversion_Hooks; use Glib.Type_Conversion_Hooks;

package body Gtk.Separator_Tool_Item is

   package Type_Conversion is new Glib.Type_Conversion_Hooks.Hook_Registrator
     (Get_Type'Access, Gtk_Separator_Tool_Item_Record);
   pragma Unreferenced (Type_Conversion);

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New (Item : out Gtk_Separator_Tool_Item) is
   begin
      Item := new Gtk_Separator_Tool_Item_Record;
      Gtk.Separator_Tool_Item.Initialize (Item);
   end Gtk_New;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Item : access Gtk_Separator_Tool_Item_Record'Class) is
      function Internal return System.Address;
      pragma Import (C, Internal, "gtk_separator_tool_item_new");
   begin
      Set_Object (Item, Internal);
   end Initialize;

   --------------
   -- Get_Draw --
   --------------

   function Get_Draw
      (Item : access Gtk_Separator_Tool_Item_Record) return Boolean
   is
      function Internal (Item : System.Address) return Integer;
      pragma Import (C, Internal, "gtk_separator_tool_item_get_draw");
   begin
      return Boolean'Val (Internal (Get_Object (Item)));
   end Get_Draw;

   --------------
   -- Set_Draw --
   --------------

   procedure Set_Draw
      (Item : access Gtk_Separator_Tool_Item_Record;
       Draw : Boolean)
   is
      procedure Internal (Item : System.Address; Draw : Integer);
      pragma Import (C, Internal, "gtk_separator_tool_item_set_draw");
   begin
      Internal (Get_Object (Item), Boolean'Pos (Draw));
   end Set_Draw;

end Gtk.Separator_Tool_Item;