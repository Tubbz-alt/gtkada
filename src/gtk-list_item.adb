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
with Gtk.Util; use Gtk.Util;

package body Gtk.List_Item is

   --------------
   -- Deselect --
   --------------

   procedure Deselect (List_Item : access Gtk_List_Item_Record) is
      procedure Internal (List_Item : in System.Address);
      pragma Import (C, Internal, "gtk_list_item_deselect");
   begin
      Internal (Get_Object (List_Item));
   end Deselect;

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New (List_Item : out Gtk_List_Item;
                      Label     : in String := "") is
   begin
      List_Item := new Gtk_List_Item_Record;
      Initialize (List_Item, Label);
   end Gtk_New;

   ----------------
   -- Gtk_Select --
   ----------------

   procedure Gtk_Select (List_Item : access Gtk_List_Item_Record) is
      procedure Internal (List_Item : in System.Address);
      pragma Import (C, Internal, "gtk_list_item_select");
   begin
      Internal (Get_Object (List_Item));
   end Gtk_Select;

   --------------
   -- Generate --
   --------------

   procedure Generate (N         : in Node_Ptr;
                       File      : in File_Type) is
   begin
      Gen_New (N, "List_Item", Get_Field (N, "label").all,
        File => File, Delim => '"');
      Item.Generate (N, File);
   end Generate;

   procedure Generate (List_Item : in out Gtk_Object;
                       N         : in Node_Ptr) is
   begin
      if not N.Specific_Data.Created then
         Gtk_New (Gtk_List_Item (List_Item), Get_Field (N, "label").all);
         Set_Object (Get_Field (N, "name"), List_Item);
         N.Specific_Data.Created := True;
      end if;

      Item.Generate (List_Item, N);
   end Generate;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (List_Item : access Gtk_List_Item_Record'Class;
                         Label     : in String := "") is
      function Internal (Label : in String)
                         return System.Address;
      pragma Import (C, Internal, "gtk_list_item_new_with_label");
   begin
      Set_Object (List_Item, Internal (Label & ASCII.Nul));
      Initialize_User_Data (List_Item);
   end Initialize;

end Gtk.List_Item;
