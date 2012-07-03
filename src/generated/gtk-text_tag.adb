------------------------------------------------------------------------------
--                                                                          --
--      Copyright (C) 1998-2000 E. Briot, J. Brobecker and A. Charlet       --
--                     Copyright (C) 2000-2012, AdaCore                     --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

pragma Ada_05;
pragma Style_Checks (Off);
pragma Warnings (Off, "*is already use-visible*");
with Glib.Type_Conversion_Hooks; use Glib.Type_Conversion_Hooks;
with Interfaces.C.Strings;       use Interfaces.C.Strings;

package body Gtk.Text_Tag is

   package Type_Conversion_Gtk_Text_Tag is new Glib.Type_Conversion_Hooks.Hook_Registrator
     (Get_Type'Access, Gtk_Text_Tag_Record);
   pragma Unreferenced (Type_Conversion_Gtk_Text_Tag);

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New (Tag : out Gtk_Text_Tag; Name : UTF8_String := "") is
   begin
      Tag := new Gtk_Text_Tag_Record;
      Gtk.Text_Tag.Initialize (Tag, Name);
   end Gtk_New;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize
      (Tag  : not null access Gtk_Text_Tag_Record'Class;
       Name : UTF8_String := "")
   is
      function Internal
         (Name : Interfaces.C.Strings.chars_ptr) return System.Address;
      pragma Import (C, Internal, "gtk_text_tag_new");
      Tmp_Name   : Interfaces.C.Strings.chars_ptr;
      Tmp_Return : System.Address;
   begin
      if Name = "" then
         Tmp_Name := Interfaces.C.Strings.Null_Ptr;
      else
         Tmp_Name := New_String (Name);
      end if;
      Tmp_Return := Internal (Tmp_Name);
      Free (Tmp_Name);
      Set_Object (Tag, Tmp_Return);
   end Initialize;

   -----------
   -- Event --
   -----------

   function Event
      (Tag          : not null access Gtk_Text_Tag_Record;
       Event_Object : not null access Glib.Object.GObject_Record'Class;
       Event        : Gdk.Event.Gdk_Event;
       Iter         : Gtk.Text_Iter.Gtk_Text_Iter) return Boolean
   is
      function Internal
         (Tag          : System.Address;
          Event_Object : System.Address;
          Event        : Gdk.Event.Gdk_Event;
          Iter         : System.Address) return Integer;
      pragma Import (C, Internal, "gtk_text_tag_event");
   begin
      return Boolean'Val (Internal (Get_Object (Tag), Get_Object (Event_Object), Event, Get_Object (Iter)));
   end Event;

   ------------------
   -- Get_Priority --
   ------------------

   function Get_Priority
      (Tag : not null access Gtk_Text_Tag_Record) return Gint
   is
      function Internal (Tag : System.Address) return Gint;
      pragma Import (C, Internal, "gtk_text_tag_get_priority");
   begin
      return Internal (Get_Object (Tag));
   end Get_Priority;

   ------------------
   -- Set_Priority --
   ------------------

   procedure Set_Priority
      (Tag      : not null access Gtk_Text_Tag_Record;
       Priority : Gint)
   is
      procedure Internal (Tag : System.Address; Priority : Gint);
      pragma Import (C, Internal, "gtk_text_tag_set_priority");
   begin
      Internal (Get_Object (Tag), Priority);
   end Set_Priority;

end Gtk.Text_Tag;