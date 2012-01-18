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
--  <description>
--  The Gtk.Viewport.Gtk_Viewport widget acts as an adaptor class,
--  implementing scrollability for child widgets that lack their own scrolling
--  capabilities. Use Gtk.Viewport.Gtk_Viewport to scroll child widgets such as
--  Gtk.Table.Gtk_Table, Gtk.Box.Gtk_Box, and so on.
--
--  If a widget has native scrolling abilities, such as
--  Gtk.Text_View.Gtk_Text_View, Gtk.Tree_View.Gtk_Tree_View or Gtk_Iconview,
--  it can be added to a Gtk.Scrolled_Window.Gtk_Scrolled_Window with
--  Gtk.Container.Add. If a widget does not, you must first add the widget to a
--  Gtk.Viewport.Gtk_Viewport, then add the viewport to the scrolled window.
--  The convenience function gtk_scrolled_window_add_with_viewport does exactly
--  this, so you can ignore the presence of the viewport.
--
--  The Gtk.Viewport.Gtk_Viewport will start scrolling content only if
--  allocated less than the child widget's minimum size in a given orientation.
--
--  </description>
--  <group>Scrolling</group>

pragma Warnings (Off, "*is already use-visible*");
with Gdk.Window;     use Gdk.Window;
with Glib;           use Glib;
with Glib.Types;     use Glib.Types;
with Gtk.Adjustment; use Gtk.Adjustment;
with Gtk.Bin;        use Gtk.Bin;
with Gtk.Buildable;  use Gtk.Buildable;
with Gtk.Enums;      use Gtk.Enums;
with Gtk.Scrollable; use Gtk.Scrollable;
with Gtk.Widget;     use Gtk.Widget;

package Gtk.Viewport is

   type Gtk_Viewport_Record is new Gtk_Bin_Record with null record;
   type Gtk_Viewport is access all Gtk_Viewport_Record'Class;

   ------------------
   -- Constructors --
   ------------------

   procedure Gtk_New
      (Viewport    : out Gtk_Viewport;
       Hadjustment : Gtk.Adjustment.Gtk_Adjustment := null;
       Vadjustment : Gtk.Adjustment.Gtk_Adjustment := null);
   procedure Initialize
      (Viewport    : access Gtk_Viewport_Record'Class;
       Hadjustment : Gtk.Adjustment.Gtk_Adjustment := null;
       Vadjustment : Gtk.Adjustment.Gtk_Adjustment := null);
   --  Creates a new Gtk.Viewport.Gtk_Viewport with the given adjustments.
   --  "hadjustment": horizontal adjustment
   --  "vadjustment": vertical adjustment

   function Get_Type return Glib.GType;
   pragma Import (C, Get_Type, "gtk_viewport_get_type");

   -------------
   -- Methods --
   -------------

   function Get_Bin_Window
      (Viewport : not null access Gtk_Viewport_Record)
       return Gdk.Window.Gdk_Window;
   --  Gets the bin window of the Gtk.Viewport.Gtk_Viewport.
   --  Since: gtk+ 2.20

   function Get_Shadow_Type
      (Viewport : not null access Gtk_Viewport_Record)
       return Gtk.Enums.Gtk_Shadow_Type;
   procedure Set_Shadow_Type
      (Viewport : not null access Gtk_Viewport_Record;
       The_Type : Gtk.Enums.Gtk_Shadow_Type);
   --  Sets the shadow type of the viewport.
   --  "type": the new shadow type.

   function Get_View_Window
      (Viewport : not null access Gtk_Viewport_Record)
       return Gdk.Window.Gdk_Window;
   --  Gets the view window of the Gtk.Viewport.Gtk_Viewport.
   --  Since: gtk+ 2.22

   ---------------------------------------------
   -- Inherited subprograms (from interfaces) --
   ---------------------------------------------
   --  Methods inherited from the Buildable interface are not duplicated here
   --  since they are meant to be used by tools, mostly. If you need to call
   --  them, use an explicit cast through the "-" operator below.

   function Get_Hadjustment
      (Self : not null access Gtk_Viewport_Record)
       return Gtk.Adjustment.Gtk_Adjustment;
   procedure Set_Hadjustment
      (Self        : not null access Gtk_Viewport_Record;
       Hadjustment : access Gtk.Adjustment.Gtk_Adjustment_Record'Class);

   function Get_Hscroll_Policy
      (Self : not null access Gtk_Viewport_Record)
       return Gtk.Enums.Gtk_Scrollable_Policy;
   procedure Set_Hscroll_Policy
      (Self   : not null access Gtk_Viewport_Record;
       Policy : Gtk.Enums.Gtk_Scrollable_Policy);

   function Get_Vadjustment
      (Self : not null access Gtk_Viewport_Record)
       return Gtk.Adjustment.Gtk_Adjustment;
   procedure Set_Vadjustment
      (Self        : not null access Gtk_Viewport_Record;
       Vadjustment : access Gtk.Adjustment.Gtk_Adjustment_Record'Class);

   function Get_Vscroll_Policy
      (Self : not null access Gtk_Viewport_Record)
       return Gtk.Enums.Gtk_Scrollable_Policy;
   procedure Set_Vscroll_Policy
      (Self   : not null access Gtk_Viewport_Record;
       Policy : Gtk.Enums.Gtk_Scrollable_Policy);

   ----------------
   -- Interfaces --
   ----------------
   --  This class implements several interfaces. See Glib.Types
   --
   --  - "Buildable"
   --
   --  - "Scrollable"

   package Implements_Buildable is new Glib.Types.Implements
     (Gtk.Buildable.Gtk_Buildable, Gtk_Viewport_Record, Gtk_Viewport);
   function "+"
     (Widget : access Gtk_Viewport_Record'Class)
   return Gtk.Buildable.Gtk_Buildable
   renames Implements_Buildable.To_Interface;
   function "-"
     (Interf : Gtk.Buildable.Gtk_Buildable)
   return Gtk_Viewport
   renames Implements_Buildable.To_Object;

   package Implements_Scrollable is new Glib.Types.Implements
     (Gtk.Scrollable.Gtk_Scrollable, Gtk_Viewport_Record, Gtk_Viewport);
   function "+"
     (Widget : access Gtk_Viewport_Record'Class)
   return Gtk.Scrollable.Gtk_Scrollable
   renames Implements_Scrollable.To_Interface;
   function "-"
     (Interf : Gtk.Scrollable.Gtk_Scrollable)
   return Gtk_Viewport
   renames Implements_Scrollable.To_Object;

   ----------------
   -- Properties --
   ----------------
   --  The following properties are defined for this widget. See
   --  Glib.Properties for more information on properties)
   --
   --  Name: Shadow_Type_Property
   --  Type: Gtk.Enums.Gtk_Shadow_Type
   --  Flags: read-write

   Shadow_Type_Property : constant Gtk.Enums.Property_Gtk_Shadow_Type;

private
   Shadow_Type_Property : constant Gtk.Enums.Property_Gtk_Shadow_Type :=
     Gtk.Enums.Build ("shadow-type");
end Gtk.Viewport;
