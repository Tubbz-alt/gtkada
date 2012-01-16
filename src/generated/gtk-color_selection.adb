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

pragma Style_Checks (Off);
pragma Warnings (Off, "*is already use-visible*");
with Glib.Type_Conversion_Hooks; use Glib.Type_Conversion_Hooks;
with GtkAda.C;                   use GtkAda.C;
with Interfaces.C.Strings;       use Interfaces.C.Strings;

package body Gtk.Color_Selection is

   package Color_Arrays is new Gtkada.C.Unbounded_Arrays
     (Gdk.Color.Gdk_Color, Gdk.Color.Null_Color, Natural,
      Gdk.Color.Gdk_Color_Array);

   -------------------------
   -- Palette_From_String --
   -------------------------

   function Palette_From_String (Str : String) return Gdk_Color_Array is
      use Color_Arrays;
      function Internal
        (Str : String;
         Colors : access Unbounded_Array_Access;
         N : access Gint)
      return Gboolean;
      pragma Import (C, Internal, "gtk_color_selection_palette_from_string");

      N      : aliased Gint;
      Output : aliased Unbounded_Array_Access;
   begin
      if Internal (Str & ASCII.NUL, Output'Access, N'Access) = 0 then
         Output := null;
      end if;

      declare
         Result : constant Gdk_Color_Array := To_Array (Output, Integer (N));
      begin
         G_Free (Output);
         return Result;
      end;
   end Palette_From_String;

   -----------------------
   -- Palette_To_String --
   -----------------------

   function Palette_To_String (Colors : Gdk_Color_Array) return String is
      function Internal
        (Colors   : System.Address;
         N_Colors : Gint)
      return Interfaces.C.Strings.chars_ptr;
      pragma Import (C, Internal, "gtk_color_selection_palette_to_string");
      Str : chars_ptr;
   begin
      if Colors'Length = 0 then
         return "";
      else
         Str := Internal (Colors (Colors'First)'Address, Colors'Length);

         declare
            Result : constant String := Value (Str);
         begin
            Free (Str);
            return Result;
         end;
      end if;
   end Palette_To_String;

   package Type_Conversion is new Glib.Type_Conversion_Hooks.Hook_Registrator
     (Get_Type'Access, Gtk_Color_Selection_Record);
   pragma Unreferenced (Type_Conversion);

   -------------
   -- Gtk_New --
   -------------

   procedure Gtk_New (Colorsel : out Gtk_Color_Selection) is
   begin
      Colorsel := new Gtk_Color_Selection_Record;
      Gtk.Color_Selection.Initialize (Colorsel);
   end Gtk_New;

   ----------------
   -- Initialize --
   ----------------

   procedure Initialize (Colorsel : access Gtk_Color_Selection_Record'Class) is
      function Internal return System.Address;
      pragma Import (C, Internal, "gtk_color_selection_new");
   begin
      Set_Object (Colorsel, Internal);
   end Initialize;

   -----------------------
   -- Get_Current_Alpha --
   -----------------------

   function Get_Current_Alpha
      (Colorsel : access Gtk_Color_Selection_Record) return guint16
   is
      function Internal (Colorsel : System.Address) return guint16;
      pragma Import (C, Internal, "gtk_color_selection_get_current_alpha");
   begin
      return Internal (Get_Object (Colorsel));
   end Get_Current_Alpha;

   -----------------------
   -- Get_Current_Color --
   -----------------------

   procedure Get_Current_Color
      (Colorsel : access Gtk_Color_Selection_Record;
       Color    : out Gdk.Color.Gdk_Color)
   is
      procedure Internal
         (Colorsel : System.Address;
          Color    : out Gdk.Color.Gdk_Color);
      pragma Import (C, Internal, "gtk_color_selection_get_current_color");
   begin
      Internal (Get_Object (Colorsel), Color);
   end Get_Current_Color;

   ----------------------
   -- Get_Current_Rgba --
   ----------------------

   procedure Get_Current_Rgba
      (Colorsel : access Gtk_Color_Selection_Record;
       Rgba     : out GdkRGBA)
   is
      procedure Internal (Colorsel : System.Address; Rgba : out GdkRGBA);
      pragma Import (C, Internal, "gtk_color_selection_get_current_rgba");
   begin
      Internal (Get_Object (Colorsel), Rgba);
   end Get_Current_Rgba;

   -----------------------------
   -- Get_Has_Opacity_Control --
   -----------------------------

   function Get_Has_Opacity_Control
      (Colorsel : access Gtk_Color_Selection_Record) return Boolean
   is
      function Internal (Colorsel : System.Address) return Integer;
      pragma Import (C, Internal, "gtk_color_selection_get_has_opacity_control");
   begin
      return Boolean'Val (Internal (Get_Object (Colorsel)));
   end Get_Has_Opacity_Control;

   ---------------------
   -- Get_Has_Palette --
   ---------------------

   function Get_Has_Palette
      (Colorsel : access Gtk_Color_Selection_Record) return Boolean
   is
      function Internal (Colorsel : System.Address) return Integer;
      pragma Import (C, Internal, "gtk_color_selection_get_has_palette");
   begin
      return Boolean'Val (Internal (Get_Object (Colorsel)));
   end Get_Has_Palette;

   ------------------------
   -- Get_Previous_Alpha --
   ------------------------

   function Get_Previous_Alpha
      (Colorsel : access Gtk_Color_Selection_Record) return guint16
   is
      function Internal (Colorsel : System.Address) return guint16;
      pragma Import (C, Internal, "gtk_color_selection_get_previous_alpha");
   begin
      return Internal (Get_Object (Colorsel));
   end Get_Previous_Alpha;

   ------------------------
   -- Get_Previous_Color --
   ------------------------

   procedure Get_Previous_Color
      (Colorsel : access Gtk_Color_Selection_Record;
       Color    : out Gdk.Color.Gdk_Color)
   is
      procedure Internal
         (Colorsel : System.Address;
          Color    : out Gdk.Color.Gdk_Color);
      pragma Import (C, Internal, "gtk_color_selection_get_previous_color");
   begin
      Internal (Get_Object (Colorsel), Color);
   end Get_Previous_Color;

   -----------------------
   -- Get_Previous_Rgba --
   -----------------------

   procedure Get_Previous_Rgba
      (Colorsel : access Gtk_Color_Selection_Record;
       Rgba     : out GdkRGBA)
   is
      procedure Internal (Colorsel : System.Address; Rgba : out GdkRGBA);
      pragma Import (C, Internal, "gtk_color_selection_get_previous_rgba");
   begin
      Internal (Get_Object (Colorsel), Rgba);
   end Get_Previous_Rgba;

   ------------------
   -- Is_Adjusting --
   ------------------

   function Is_Adjusting
      (Colorsel : access Gtk_Color_Selection_Record) return Boolean
   is
      function Internal (Colorsel : System.Address) return Integer;
      pragma Import (C, Internal, "gtk_color_selection_is_adjusting");
   begin
      return Boolean'Val (Internal (Get_Object (Colorsel)));
   end Is_Adjusting;

   -----------------------
   -- Set_Current_Alpha --
   -----------------------

   procedure Set_Current_Alpha
      (Colorsel : access Gtk_Color_Selection_Record;
       Alpha    : guint16)
   is
      procedure Internal (Colorsel : System.Address; Alpha : guint16);
      pragma Import (C, Internal, "gtk_color_selection_set_current_alpha");
   begin
      Internal (Get_Object (Colorsel), Alpha);
   end Set_Current_Alpha;

   -----------------------
   -- Set_Current_Color --
   -----------------------

   procedure Set_Current_Color
      (Colorsel : access Gtk_Color_Selection_Record;
       Color    : in out Gdk.Color.Gdk_Color)
   is
      procedure Internal
         (Colorsel : System.Address;
          Color    : in out Gdk.Color.Gdk_Color);
      pragma Import (C, Internal, "gtk_color_selection_set_current_color");
   begin
      Internal (Get_Object (Colorsel), Color);
   end Set_Current_Color;

   ----------------------
   -- Set_Current_Rgba --
   ----------------------

   procedure Set_Current_Rgba
      (Colorsel : access Gtk_Color_Selection_Record;
       Rgba     : in out GdkRGBA)
   is
      procedure Internal (Colorsel : System.Address; Rgba : in out GdkRGBA);
      pragma Import (C, Internal, "gtk_color_selection_set_current_rgba");
   begin
      Internal (Get_Object (Colorsel), Rgba);
   end Set_Current_Rgba;

   -----------------------------
   -- Set_Has_Opacity_Control --
   -----------------------------

   procedure Set_Has_Opacity_Control
      (Colorsel    : access Gtk_Color_Selection_Record;
       Has_Opacity : Boolean)
   is
      procedure Internal (Colorsel : System.Address; Has_Opacity : Integer);
      pragma Import (C, Internal, "gtk_color_selection_set_has_opacity_control");
   begin
      Internal (Get_Object (Colorsel), Boolean'Pos (Has_Opacity));
   end Set_Has_Opacity_Control;

   ---------------------
   -- Set_Has_Palette --
   ---------------------

   procedure Set_Has_Palette
      (Colorsel    : access Gtk_Color_Selection_Record;
       Has_Palette : Boolean)
   is
      procedure Internal (Colorsel : System.Address; Has_Palette : Integer);
      pragma Import (C, Internal, "gtk_color_selection_set_has_palette");
   begin
      Internal (Get_Object (Colorsel), Boolean'Pos (Has_Palette));
   end Set_Has_Palette;

   ------------------------
   -- Set_Previous_Alpha --
   ------------------------

   procedure Set_Previous_Alpha
      (Colorsel : access Gtk_Color_Selection_Record;
       Alpha    : guint16)
   is
      procedure Internal (Colorsel : System.Address; Alpha : guint16);
      pragma Import (C, Internal, "gtk_color_selection_set_previous_alpha");
   begin
      Internal (Get_Object (Colorsel), Alpha);
   end Set_Previous_Alpha;

   ------------------------
   -- Set_Previous_Color --
   ------------------------

   procedure Set_Previous_Color
      (Colorsel : access Gtk_Color_Selection_Record;
       Color    : in out Gdk.Color.Gdk_Color)
   is
      procedure Internal
         (Colorsel : System.Address;
          Color    : in out Gdk.Color.Gdk_Color);
      pragma Import (C, Internal, "gtk_color_selection_set_previous_color");
   begin
      Internal (Get_Object (Colorsel), Color);
   end Set_Previous_Color;

   -----------------------
   -- Set_Previous_Rgba --
   -----------------------

   procedure Set_Previous_Rgba
      (Colorsel : access Gtk_Color_Selection_Record;
       Rgba     : in out GdkRGBA)
   is
      procedure Internal (Colorsel : System.Address; Rgba : in out GdkRGBA);
      pragma Import (C, Internal, "gtk_color_selection_set_previous_rgba");
   begin
      Internal (Get_Object (Colorsel), Rgba);
   end Set_Previous_Rgba;

   -----------------------------------------
   -- Set_Change_Palette_With_Screen_Hook --
   -----------------------------------------

   procedure Set_Change_Palette_With_Screen_Hook
      (Func : Gtk_Color_Selection_Change_Palette_With_Screen_Func)
   is
      procedure Internal (Func : System.Address);
      pragma Import (C, Internal, "gtk_color_selection_set_change_palette_with_screen_hook");
   begin
      Internal (Func'Address);
   end Set_Change_Palette_With_Screen_Hook;

   ---------------------
   -- Get_Orientation --
   ---------------------

   function Get_Orientation
      (Self : access Gtk_Color_Selection_Record)
       return Gtk.Enums.Gtk_Orientation
   is
      function Internal (Self : System.Address) return Integer;
      pragma Import (C, Internal, "gtk_orientable_get_orientation");
   begin
      return Gtk.Enums.Gtk_Orientation'Val (Internal (Get_Object (Self)));
   end Get_Orientation;

   ---------------------
   -- Set_Orientation --
   ---------------------

   procedure Set_Orientation
      (Self        : access Gtk_Color_Selection_Record;
       Orientation : Gtk.Enums.Gtk_Orientation)
   is
      procedure Internal (Self : System.Address; Orientation : Integer);
      pragma Import (C, Internal, "gtk_orientable_set_orientation");
   begin
      Internal (Get_Object (Self), Gtk.Enums.Gtk_Orientation'Pos (Orientation));
   end Set_Orientation;

end Gtk.Color_Selection;
