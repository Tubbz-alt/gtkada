-----------------------------------------------------------------------
--          GtkAda - Ada95 binding for the Gimp Toolkit              --
--                                                                   --
--                     Copyright (C) 1998-1999                       --
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

package body Gtk.Fixed is

   ------------------
   -- Get_Children --
   ------------------

   function Get_Children (Widget : access Gtk_Fixed_Record)
                          return      Widget.Widget_List.Glist
   is
      function Internal (Widget : in System.Address)
                         return      System.Address;
      pragma Import (C, Internal, "ada_fixed_get_children");
      use Gtk.Widget.Widget_List;
      Children : Gtk.Widget.Widget_List.Glist;
   begin
      Set_Object (Children, Internal (Get_Object (Widget)));
      return Children;
   end Get_Children;

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New (Widget : out Gtk_Fixed)
   is
   begin
      Widget := new Gtk_Fixed_Record;
      Initialize (Widget);
   end Gtk_New;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Widget : access Gtk_Fixed_Record)
   is
      function Internal return System.Address;
      pragma Import (C, Internal, "gtk_fixed_new");
   begin
      Set_Object (Widget, Internal);
      Initialize_User_Data (Widget);
   end Initialize;

   ----------
   -- Move --
   ----------

   procedure Move
      (Fixed  : access Gtk_Fixed_Record;
       Widget : in Gtk.Widget.Gtk_Widget;
       X      : in Gint16;
       Y      : in Gint16)
   is
      procedure Internal
         (Fixed  : in System.Address;
          Widget : in System.Address;
          X      : in Gint16;
          Y      : in Gint16);
      pragma Import (C, Internal, "gtk_fixed_move");
   begin
      Internal (Get_Object (Fixed),
                Get_Object (Widget),
                X,
                Y);
   end Move;

   ---------
   -- Put --
   ---------

   procedure Put
      (Fixed  : access Gtk_Fixed_Record;
       Widget : in Gtk.Widget.Gtk_Widget;
       X      : in Gint16;
       Y      : in Gint16)
   is
      procedure Internal
         (Fixed  : in System.Address;
          Widget : in System.Address;
          X      : in Gint16;
          Y      : in Gint16);
      pragma Import (C, Internal, "gtk_fixed_put");
   begin
      Internal (Get_Object (Fixed),
                Get_Object (Widget),
                X,
                Y);
   end Put;

end Gtk.Fixed;
