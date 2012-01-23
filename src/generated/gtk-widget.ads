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
--  GtkWidget is the base class all widgets in GTK+ derive from. It manages
--  the widget lifecycle, states and style.
--
--  == Height-for-width Geometry Management ==
--
--  GTK+ uses a height-for-width (and width-for-height) geometry management
--  system. Height-for-width means that a widget can change how much vertical
--  space it needs, depending on the amount of horizontal space that it is
--  given (and similar for width-for-height). The most common example is a
--  label that reflows to fill up the available width, wraps to fewer lines,
--  and therefore needs less height.
--
--  Height-for-width geometry management is implemented in GTK+ by way of five
--  virtual methods:
--
--  *Gtk.Widget_Class.Gtk_Widget_Class.get_request_mode
--  *Gtk.Widget_Class.Gtk_Widget_Class.get_preferred_width
--  *Gtk.Widget_Class.Gtk_Widget_Class.get_preferred_height
--  *Gtk.Widget_Class.Gtk_Widget_Class.get_preferred_height_for_width
--  *Gtk.Widget_Class.Gtk_Widget_Class.get_preferred_width_for_height
--
--  There are some important things to keep in mind when implementing
--  height-for-width and when using it in container implementations.
--
--  The geometry management system will query a widget hierarchy in only one
--  orientation at a time. When widgets are initially queried for their minimum
--  sizes it is generally done in two initial passes in the
--  Gtk.Enums.Gtk_Size_Request_Mode chosen by the toplevel.
--
--  For example, when queried in the normal GTK_SIZE_REQUEST_HEIGHT_FOR_WIDTH
--  mode: First, the default minimum and natural width for each widget in the
--  interface will be computed using Gtk.Widget.Get_Preferred_Width. Because
--  the preferred widths for each container depend on the preferred widths of
--  their children, this information propagates up the hierarchy, and finally a
--  minimum and natural width is determined for the entire toplevel. Next, the
--  toplevel will use the minimum width to query for the minimum height
--  contextual to that width using Gtk.Widget.Get_Preferred_Height_For_Width,
--  which will also be a highly recursive operation. The minimum height for the
--  minimum width is normally used to set the minimum size constraint on the
--  toplevel (unless gtk_window_set_geometry_hints is explicitly used instead).
--
--  After the toplevel window has initially requested its size in both
--  dimensions it can go on to allocate itself a reasonable size (or a size
--  previously specified with gtk_window_set_default_size). During the
--  recursive allocation process it's important to note that request cycles
--  will be recursively executed while container widgets allocate their
--  children. Each container widget, once allocated a size, will go on to first
--  share the space in one orientation among its children and then request each
--  child's height for its target allocated width or its width for allocated
--  height, depending. In this way a Gtk.Widget.Gtk_Widget will typically be
--  requested its size a number of times before actually being allocated a
--  size. The size a widget is finally allocated can of course differ from the
--  size it has requested. For this reason, Gtk.Widget.Gtk_Widget caches a
--  small number of results to avoid re-querying for the same sizes in one
--  allocation cycle.
--
--  See <link linkend="container-geometry-management">GtkContainer's geometry
--  management section</link> to learn more about how height-for-width
--  allocations are performed by container widgets.
--
--  If a widget does move content around to intelligently use up the allocated
--  size then it must support the request in both Gtk_Size_Request_Modes even
--  if the widget in question only trades sizes in a single orientation.
--
--  For instance, a Gtk.Label.Gtk_Label that does height-for-width word
--  wrapping will not expect to have
--  Gtk.Widget_Class.Gtk_Widget_Class.get_preferred_height called because that
--  call is specific to a width-for-height request. In this case the label must
--  return the height required for its own minimum possible width. By following
--  this rule any widget that handles height-for-width or width-for-height
--  requests will always be allocated at least enough space to fit its own
--  content.
--
--  Here are some examples of how a GTK_SIZE_REQUEST_HEIGHT_FOR_WIDTH widget
--  generally deals with width-for-height requests, for
--  Gtk.Widget_Class.Gtk_Widget_Class.get_preferred_height it will do:
--
--    static void
--    foo_widget_get_preferred_height (GtkWidget *widget, gint *min_height, gint *nat_height)
--    {
--       if (i_am_in_height_for_width_mode)
--       {
--          gint min_width;
--          GTK_WIDGET_GET_CLASS (widget)->get_preferred_width (widget, &min_width, NULL);
--          GTK_WIDGET_GET_CLASS (widget)->get_preferred_height_for_width (widget, min_width,
--             min_height, nat_height);
--       }
--    else
--       {
--          ... some widgets do both. For instance, if a GtkLabel is rotated to 90 degrees
--          it will return the minimum and natural height for the rotated label here.
--       }
--    }
--
--  And in Gtk.Widget_Class.Gtk_Widget_Class.get_preferred_width_for_height it
--  will simply return the minimum and natural width:
--
--    static void
--    foo_widget_get_preferred_width_for_height (GtkWidget *widget, gint for_height,
--       gint *min_width, gint *nat_width)
--    {
--       if (i_am_in_height_for_width_mode)
--       {
--          GTK_WIDGET_GET_CLASS (widget)->get_preferred_width (widget, min_width, nat_width);
--       }
--    else
--       {
--          ... again if a widget is sometimes operating in width-for-height mode
--            (like a rotated GtkLabel) it can go ahead and do its real width for
--          height calculation here.
--       }
--    }
--
--  Often a widget needs to get its own request during size request or
--  allocation. For example, when computing height it may need to also compute
--  width. Or when deciding how to use an allocation, the widget may need to
--  know its natural size. In these cases, the widget should be careful to call
--  its virtual methods directly, like this:
--
--  == Widget calling its own size request method. ==
--
--    GTK_WIDGET_GET_CLASS(widget)->get_preferred_width (widget),
--    &min, &natural);
--
--  It will not work to use the wrapper functions, such as
--  Gtk.Widget.Get_Preferred_Width inside your own size request implementation.
--  These return a request adjusted by Gtk.Size_Group.Gtk_Size_Group and by the
--  Gtk.Widget_Class.Gtk_Widget_Class.adjust_size_request virtual method. If a
--  widget used the wrappers inside its virtual method implementations, then
--  the adjustments (such as widget margins) would be applied twice. GTK+
--  therefore does not allow this and will warn if you try to do it.
--
--  Of course if you are getting the size request for *another* widget, such
--  as a child of a container, you *must* use the wrapper APIs. Otherwise, you
--  would not properly consider widget margins, Gtk.Size_Group.Gtk_Size_Group,
--  and so forth.
--
--  == Style Properties ==
--
--  <structname>GtkWidget</structname> introduces 'style properties' - these
--  are basically object properties that are stored not on the object, but in
--  the style object associated to the widget. Style properties are set in
--  <link linkend="gtk-Resource-Files">resource files</link>. This mechanism is
--  used for configuring such things as the location of the scrollbar arrows
--  through the theme, giving theme authors more control over the look of
--  applications without the need to write a theme engine in C.
--  Use gtk_widget_class_install_style_property to install style properties
--  for a widget class, gtk_widget_class_find_style_property or
--  gtk_widget_class_list_style_properties to get information about existing
--  style properties and Gtk.Widget.Style_Get_Property, gtk_widget_style_get or
--  Gtk.Widget.Style_Get_Valist to obtain the value of a style property.
--
--  == GtkWidget as GtkBuildable ==
--
--  The GtkWidget implementation of the GtkBuildable interface supports a
--  custom <accelerator> element, which has attributes named key, modifiers and
--  signal and allows to specify accelerators.
--
--  == A UI definition fragment specifying an accelerator ==
--
--    <object class="GtkButton">
--    <accelerator key="q" modifiers="GDK_CONTROL_MASK" signal="clicked"/>
--    </object>
--
--  In addition to accelerators, <structname>GtkWidget</structname> also
--  support a custom <accessible> element, which supports actions and
--  relations. Properties on the accessible implementation of an object can be
--  set by accessing the internal child "accessible" of a
--  <structname>GtkWidget</structname>.
--
--  == A UI definition fragment specifying an accessible ==
--
--    <object class="GtkButton" id="label1"/>
--    <property name="label">I am a Label for a Button</property>
--    </object>
--    <object class="GtkButton" id="button1">
--    <accessibility>
--    <action action_name="click" translatable="yes">Click the button.</action>
--    <relation target="label1" type="labelled-by"/>
--    </accessibility>
--    <child internal-child="accessible">
--    <object class="AtkObject" id="a11y-button1">
--    <property name="AtkObject::name">Clickable Button</property>
--    </object>
--    </child>
--    </object>
--
--  Finally, GtkWidget allows style information such as style classes to be
--  associated with widgets, using the custom <style> element:
--
--  == A UI definition fragment specifying an style class ==
--
--    <object class="GtkButton" id="button1">
--    <style>
--    <class name="my-special-button-class"/>
--    <class name="dark-button"/>
--    </style>
--    </object>
--
--
--  </description>

pragma Warnings (Off, "*is already use-visible*");
with Cairo;             use Cairo;
with Cairo.Region;      use Cairo.Region;
with Gdk.Atom;          use Gdk.Atom;
with Gdk.Color;         use Gdk.Color;
with Gdk.Device;        use Gdk.Device;
with Gdk.Display;       use Gdk.Display;
with Gdk.Drag_Contexts; use Gdk.Drag_Contexts;
with Gdk.Event;         use Gdk.Event;
with Gdk.Pixbuf;        use Gdk.Pixbuf;
with Gdk.RGBA;          use Gdk.RGBA;
with Gdk.Rectangle;     use Gdk.Rectangle;
with Gdk.Screen;        use Gdk.Screen;
with Gdk.Types;         use Gdk.Types;
with Gdk.Visual;        use Gdk.Visual;
with Gdk.Window;        use Gdk.Window;
with Glib;              use Glib;
with Glib.GSlist;       use Glib.GSlist;
with Glib.G_Icon;       use Glib.G_Icon;
with Glib.Glist;        use Glib.Glist;
with Glib.Object;       use Glib.Object;
with Glib.Properties;   use Glib.Properties;
with Glib.Types;        use Glib.Types;
with Glib.Values;       use Glib.Values;
with Gtk.Accel_Group;   use Gtk.Accel_Group;
with Gtk.Buildable;     use Gtk.Buildable;
with Gtk.Enums;         use Gtk.Enums;
with Gtk.Rc_Style;      use Gtk.Rc_Style;
with Gtk.Selection;     use Gtk.Selection;
with Gtk.Style;         use Gtk.Style;
with Gtk.Style_Context; use Gtk.Style_Context;
with Pango.Context;     use Pango.Context;
with Pango.Layout;      use Pango.Layout;

package Gtk.Widget is

   type Gtk_Widget_Record is new GObject_Record with null record;
   type Gtk_Widget is access all Gtk_Widget_Record'Class;

   type Gtk_Requisition is record
      Width : Gint;
      Height : Gint;
   end record;
   pragma Convention (C, Gtk_Requisition);
   --  A <structname>GtkRequisition</structname> represents the desired size
   --  of a widget. See <xref linkend="geometry-management"/> for more
   --  information.

   function Convert (R : Gtk.Widget.Gtk_Widget) return System.Address;
   function Convert (R : System.Address) return Gtk.Widget.Gtk_Widget;
   package Widget_List is new Generic_List (Gtk.Widget.Gtk_Widget);

   package Widget_SList is new Generic_SList (Gtk.Widget.Gtk_Widget);

   subtype Gtk_Allocation is Gdk.Rectangle.Gdk_Rectangle;

   type Gtk_Requisition_Access is access all Gtk_Requisition;
   type Gtk_Allocation_Access is access all Gtk_Allocation;
   pragma Convention (C, Gtk_Requisition_Access);
   pragma Convention (C, Gtk_Allocation_Access);

   ------------------
   -- Constructors --
   ------------------

   function Get_Type return Glib.GType;
   pragma Import (C, Get_Type, "gtk_widget_get_type");

   -------------
   -- Methods --
   -------------

   function Activate
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  For widgets that can be "activated" (buttons, menu items, etc.) this
   --  function activates them. Activation is what happens when you press Enter
   --  on a widget during key navigation. If Widget isn't activatable, the
   --  function returns False.

   procedure Add_Accelerator
      (Widget       : not null access Gtk_Widget_Record;
       Accel_Signal : UTF8_String;
       Accel_Group  : not null access Gtk.Accel_Group.Gtk_Accel_Group_Record'Class;
       Accel_Key    : Gtk.Accel_Group.Gtk_Accel_Key;
       Accel_Mods   : Gdk.Types.Gdk_Modifier_Type;
       Accel_Flags  : Gtk.Accel_Group.Gtk_Accel_Flags);
   --  Installs an accelerator for this Widget in Accel_Group that causes
   --  Accel_Signal to be emitted if the accelerator is activated. The
   --  Accel_Group needs to be added to the widget's toplevel via
   --  gtk_window_add_accel_group, and the signal must be of type G_RUN_ACTION.
   --  Accelerators added through this function are not user changeable during
   --  runtime. If you want to support accelerators that can be changed by the
   --  user, use Gtk.Accel_Map.Add_Entry and Gtk.Widget.Set_Accel_Path or
   --  Gtk.Menu_Item.Set_Accel_Path instead.
   --  "accel_signal": widget signal to emit on accelerator activation
   --  "accel_group": accel group for this widget, added to its toplevel
   --  "accel_key": GDK keyval of the accelerator
   --  "accel_mods": modifier key combination of the accelerator
   --  "accel_flags": flag accelerators, e.g. Gtk.Accel_Group.Accel_Visible

   procedure Add_Device_Events
      (Widget : not null access Gtk_Widget_Record;
       Device : not null access Gdk.Device.Gdk_Device_Record'Class;
       Events : Gdk.Event.Gdk_Event_Mask);
   --  Adds the device events in the bitfield Events to the event mask for
   --  Widget. See Gtk.Widget.Set_Device_Events for details.
   --  Since: gtk+ 3.0
   --  "device": a Gdk.Device.Gdk_Device
   --  "events": an event mask, see Gdk.Event.Gdk_Event_Mask

   procedure Add_Events
      (Widget : not null access Gtk_Widget_Record;
       Events : Gdk.Event.Gdk_Event_Mask);
   --  Adds the events in the bitfield Events to the event mask for Widget.
   --  See Gtk.Widget.Set_Events for details.
   --  "events": an event mask, see Gdk.Event.Gdk_Event_Mask

   procedure Add_Mnemonic_Label
      (Widget : not null access Gtk_Widget_Record;
       Label  : not null access Gtk_Widget_Record'Class);
   --  Adds a widget to the list of mnemonic labels for this widget. (See
   --  Gtk.Widget.List_Mnemonic_Labels). Note the list of mnemonic labels for
   --  the widget is cleared when the widget is destroyed, so the caller must
   --  make sure to update its internal state at this point as well, by using a
   --  connection to the Gtk.Widget.Gtk_Widget::destroy signal or a weak
   --  notifier.
   --  Since: gtk+ 2.4
   --  "label": a Gtk.Widget.Gtk_Widget that acts as a mnemonic label for
   --  Widget

   function Can_Activate_Accel
      (Widget    : not null access Gtk_Widget_Record;
       Signal_Id : Guint) return Boolean;
   --  Determines whether an accelerator that activates the signal identified
   --  by Signal_Id can currently be activated. This is done by emitting the
   --  Gtk.Widget.Gtk_Widget::can-activate-accel signal on Widget; if the
   --  signal isn't overridden by a handler or in a derived widget, then the
   --  default check is that the widget must be sensitive, and the widget and
   --  all its ancestors mapped.
   --  Since: gtk+ 2.4
   --  "signal_id": the ID of a signal installed on Widget

   function Child_Focus
      (Widget    : not null access Gtk_Widget_Record;
       Direction : Gtk.Enums.Gtk_Direction_Type) return Boolean;
   --  This function is used by custom widget implementations; if you're
   --  writing an app, you'd use Gtk.Widget.Grab_Focus to move the focus to a
   --  particular widget, and Gtk.Container.Set_Focus_Chain to change the focus
   --  tab order. So you may want to investigate those functions instead.
   --  Gtk.Widget.Child_Focus is called by containers as the user moves around
   --  the window using keyboard shortcuts. Direction indicates what kind of
   --  motion is taking place (up, down, left, right, tab forward, tab
   --  backward). Gtk.Widget.Child_Focus emits the Gtk.Widget.Gtk_Widget::focus
   --  signal; widgets override the default handler for this signal in order to
   --  implement appropriate focus behavior.
   --  The default ::focus handler for a widget should return True if moving in
   --  Direction left the focus on a focusable location inside that widget, and
   --  False if moving in Direction moved the focus outside the widget. If
   --  returning True, widgets normally call Gtk.Widget.Grab_Focus to place the
   --  focus accordingly; if returning False, they don't modify the current
   --  focus location.
   --  "direction": direction of focus movement

   procedure Child_Notify
      (Widget         : not null access Gtk_Widget_Record;
       Child_Property : UTF8_String);
   --  Emits a Gtk.Widget.Gtk_Widget::child-notify signal for the <link
   --  linkend="child-properties">child property</link> Child_Property on
   --  Widget.
   --  This is the analogue of g_object_notify for child properties.
   --  Also see Gtk.Container.Child_Notify.
   --  "child_property": the name of a child property installed on the class
   --  of Widget<!-- -->'s parent

   function Compute_Expand
      (Widget      : not null access Gtk_Widget_Record;
       Orientation : Gtk.Enums.Gtk_Orientation) return Boolean;
   --  Computes whether a container should give this widget extra space when
   --  possible. Containers should check this, rather than looking at
   --  Gtk.Widget.Get_Hexpand or Gtk.Widget.Get_Vexpand.
   --  This function already checks whether the widget is visible, so
   --  visibility does not need to be checked separately. Non-visible widgets
   --  are not expanded.
   --  The computed expand value uses either the expand setting explicitly set
   --  on the widget itself, or, if none has been explicitly set, the widget
   --  may expand if some of its children do.
   --  "orientation": expand direction

   function Create_Pango_Context
      (Widget : not null access Gtk_Widget_Record)
       return Pango.Context.Pango_Context;
   --  Creates a new Pango.Context.Pango_Context with the appropriate font
   --  map, font description, and base direction for drawing text for this
   --  widget. See also Gtk.Widget.Get_Pango_Context.

   function Create_Pango_Layout
      (Widget : not null access Gtk_Widget_Record;
       Text   : UTF8_String := "") return Pango.Layout.Pango_Layout;
   --  Creates a new Pango.Layout.Pango_Layout with the appropriate font map,
   --  font description, and base direction for drawing text for this widget.
   --  If you keep a Pango.Layout.Pango_Layout created in this way around, in
   --  order to notify the layout of changes to the base direction or font of
   --  this widget, you must call pango_layout_context_changed in response to
   --  the Gtk.Widget.Gtk_Widget::style-updated and
   --  Gtk.Widget.Gtk_Widget::direction-changed signals for the widget.
   --  "text": text to set on the layout (can be null)

   procedure Destroyed
      (Widget         : not null access Gtk_Widget_Record;
       Widget_Pointer : not null access Gtk_Widget_Record'Class);
   --  This function sets *Widget_Pointer to null if Widget_Pointer != null.
   --  It's intended to be used as a callback connected to the "destroy" signal
   --  of a widget. You connect Gtk.Widget.Destroyed as a signal handler, and
   --  pass the address of your widget variable as user data. Then when the
   --  widget is destroyed, the variable will be set to null. Useful for
   --  example to avoid multiple copies of the same dialog.
   --  "widget_pointer": address of a variable that contains Widget

   function Device_Is_Shadowed
      (Widget : not null access Gtk_Widget_Record;
       Device : not null access Gdk.Device.Gdk_Device_Record'Class)
       return Boolean;
   --  Returns True if Device has been shadowed by a GTK+ device grab on
   --  another widget, so it would stop sending events to Widget. This may be
   --  used in the Gtk.Widget.Gtk_Widget::grab-notify signal to check for
   --  specific devices. See gtk_device_grab_add.
   --  by another Gtk.Widget.Gtk_Widget than Widget.
   --  Since: gtk+ 3.0
   --  "device": a Gdk.Device.Gdk_Device

   function Drag_Begin
      (Widget  : not null access Gtk_Widget_Record;
       Targets : Gtk.Selection.Target_List;
       Actions : Gdk.Drag_Contexts.Gdk_Drag_Action;
       Button  : Gint;
       Event   : Gdk.Event.Gdk_Event) return Gdk.Drag_Contexts.Drag_Context;
   --  Initiates a drag on the source side. The function only needs to be used
   --  when the application is starting drags itself, and is not needed when
   --  Gtk.Widget.Drag_Source_Set is used.
   --  The Event is used to retrieve the timestamp that will be used internally
   --  to grab the pointer. If Event is NULL, then GDK_CURRENT_TIME will be
   --  used. However, you should try to pass a real event in all cases, since
   --  that can be used by GTK+ to get information about the start position of
   --  the drag, for example if the Event is a GDK_MOTION_NOTIFY.
   --  Generally there are three cases when you want to start a drag by hand by
   --  calling this function:
   --  1. During a Gtk.Widget.Gtk_Widget::button-press-event handler, if you
   --  want to start a drag immediately when the user presses the mouse button.
   --  Pass the Event that you have in your
   --  Gtk.Widget.Gtk_Widget::button-press-event handler.
   --  2. During a Gtk.Widget.Gtk_Widget::motion-notify-event handler, if you
   --  want to start a drag when the mouse moves past a certain threshold
   --  distance after a button-press. Pass the Event that you have in your
   --  Gtk.Widget.Gtk_Widget::motion-notify-event handler.
   --  3. During a timeout handler, if you want to start a drag after the mouse
   --  button is held down for some time. Try to save the last event that you
   --  got from the mouse, using gdk_event_copy, and pass it to this function
   --  (remember to free the event with gdk_event_free when you are done). If
   --  you can really not pass a real event, pass NULL instead.
   --  "targets": The targets (data formats) in which the source can provide
   --  the data.
   --  "actions": A bitmask of the allowed drag actions for this drag.
   --  "button": The button the user clicked to start the drag.
   --  "event": The event that triggered the start of the drag.

   function Drag_Check_Threshold
      (Widget    : not null access Gtk_Widget_Record;
       Start_X   : Gint;
       Start_Y   : Gint;
       Current_X : Gint;
       Current_Y : Gint) return Boolean;
   --  Checks to see if a mouse drag starting at (Start_X, Start_Y) and ending
   --  at (Current_X, Current_Y) has passed the GTK+ drag threshold, and thus
   --  should trigger the beginning of a drag-and-drop operation.
   --  "start_x": X coordinate of start of drag
   --  "start_y": Y coordinate of start of drag
   --  "current_x": current X coordinate
   --  "current_y": current Y coordinate

   procedure Drag_Dest_Add_Image_Targets
      (Widget : not null access Gtk_Widget_Record);
   --  Add the image targets supported by Gtk_Selection to the target list of
   --  the drag destination. The targets are added with Info = 0. If you need
   --  another value, use gtk_target_list_add_image_targets and
   --  Gtk.Widget.Drag_Dest_Set_Target_List.
   --  Since: gtk+ 2.6

   procedure Drag_Dest_Add_Text_Targets
      (Widget : not null access Gtk_Widget_Record);
   --  Add the text targets supported by Gtk_Selection to the target list of
   --  the drag destination. The targets are added with Info = 0. If you need
   --  another value, use gtk_target_list_add_text_targets and
   --  Gtk.Widget.Drag_Dest_Set_Target_List.
   --  Since: gtk+ 2.6

   procedure Drag_Dest_Add_Uri_Targets
      (Widget : not null access Gtk_Widget_Record);
   --  Add the URI targets supported by Gtk_Selection to the target list of
   --  the drag destination. The targets are added with Info = 0. If you need
   --  another value, use gtk_target_list_add_uri_targets and
   --  Gtk.Widget.Drag_Dest_Set_Target_List.
   --  Since: gtk+ 2.6

   function Drag_Dest_Find_Target
      (Widget      : not null access Gtk_Widget_Record;
       Context     : not null access Gdk.Drag_Contexts.Drag_Context_Record'Class;
       Target_List : Gtk.Selection.Target_List) return Gdk.Atom.Gdk_Atom;
   --  Looks for a match between the supported targets of Context and the
   --  Dest_Target_List, returning the first matching target, otherwise
   --  returning GDK_NONE. Dest_Target_List should usually be the return value
   --  from Gtk.Widget.Drag_Dest_Get_Target_List, but some widgets may have
   --  different valid targets for different parts of the widget; in that case,
   --  they will have to implement a drag_motion handler that passes the
   --  correct target list to this function.
   --  and the dest can accept, or GDK_NONE
   --  "context": drag context
   --  "target_list": list of droppable targets, or null to use
   --  gtk_drag_dest_get_target_list (Widget).

   function Drag_Dest_Get_Target_List
      (Widget : not null access Gtk_Widget_Record)
       return Gtk.Selection.Target_List;
   procedure Drag_Dest_Set_Target_List
      (Widget      : not null access Gtk_Widget_Record;
       Target_List : Gtk.Selection.Target_List);
   --  Sets the target types that this widget can accept from drag-and-drop.
   --  The widget must first be made into a drag destination with
   --  Gtk.Widget.Drag_Dest_Set.
   --  "target_list": list of droppable targets, or null for none

   function Drag_Dest_Get_Track_Motion
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Drag_Dest_Set_Track_Motion
      (Widget       : not null access Gtk_Widget_Record;
       Track_Motion : Boolean);
   --  Tells the widget to emit Gtk.Widget.Gtk_Widget::drag-motion and
   --  Gtk.Widget.Gtk_Widget::drag-leave events regardless of the targets and
   --  the GTK_DEST_DEFAULT_MOTION flag.
   --  This may be used when a widget wants to do generic actions regardless of
   --  the targets that the source offers.
   --  Since: gtk+ 2.10
   --  "track_motion": whether to accept all targets

   procedure Drag_Dest_Set
      (Widget    : not null access Gtk_Widget_Record;
       Flags     : Gtk_Dest_Defaults;
       Targets   : array_of_Gtk_Target_Entry;
       N_Targets : Gint;
       Actions   : Gdk.Drag_Contexts.Gdk_Drag_Action);
   --  Sets a widget as a potential drop destination, and adds default
   --  behaviors.
   --  The default behaviors listed in Flags have an effect similar to
   --  installing default handlers for the widget's drag-and-drop signals
   --  (Gtk.Widget.Gtk_Widget::drag-motion, Gtk.Widget.Gtk_Widget::drag-drop,
   --  ...). They all exist for convenience. When passing GTK_DEST_DEFAULT_ALL
   --  for instance it is sufficient to connect to the widget's
   --  Gtk.Widget.Gtk_Widget::drag-data-received signal to get primitive, but
   --  consistent drag-and-drop support.
   --  Things become more complicated when you try to preview the dragged data,
   --  as described in the documentation for
   --  Gtk.Widget.Gtk_Widget::drag-motion. The default behaviors described by
   --  Flags make some assumptions, that can conflict with your own signal
   --  handlers. For instance GTK_DEST_DEFAULT_DROP causes invokations of
   --  gdk_drag_status in the context of Gtk.Widget.Gtk_Widget::drag-motion,
   --  and invokations of gtk_drag_finish in
   --  Gtk.Widget.Gtk_Widget::drag-data-received. Especially the later is
   --  dramatic, when your own Gtk.Widget.Gtk_Widget::drag-motion handler calls
   --  Gtk.Widget.Drag_Get_Data to inspect the dragged data.
   --  There's no way to set a default action here, you can use the
   --  Gtk.Widget.Gtk_Widget::drag-motion callback for that. Here's an example
   --  which selects the action to use depending on whether the control key is
   --  pressed or not: |[ static void drag_motion (GtkWidget *widget,
   --  GdkDragContext *context, gint x, gint y, guint time) { GdkModifierType
   --  mask;
   --  gdk_window_get_pointer (gtk_widget_get_window (widget), NULL, NULL,
   --  &mask); if (mask & GDK_CONTROL_MASK) gdk_drag_status (context,
   --  GDK_ACTION_COPY, time); else gdk_drag_status (context, GDK_ACTION_MOVE,
   --  time); } ]|
   --  "flags": which types of default drag behavior to use
   --  "targets": a pointer to an array of
   --  Gtk.Target_Entry.Gtk_Target_Entry<!-- -->s indicating the drop types
   --  that this Widget will accept, or null. Later you can access the list
   --  with Gtk.Widget.Drag_Dest_Get_Target_List and
   --  Gtk.Widget.Drag_Dest_Find_Target.
   --  "n_targets": the number of entries in Targets
   --  "actions": a bitmask of possible actions for a drop onto this Widget.

   procedure Drag_Dest_Set_Proxy
      (Widget          : not null access Gtk_Widget_Record;
       Proxy_Window    : Gdk.Window.Gdk_Window;
       Protocol        : Gdk.Drag_Contexts.Gdk_Drag_Protocol;
       Use_Coordinates : Boolean);
   --  Sets this widget as a proxy for drops to another window.
   --  "proxy_window": the window to which to forward drag events
   --  "protocol": the drag protocol which the Proxy_Window accepts (You can
   --  use gdk_drag_get_protocol to determine this)
   --  "use_coordinates": If True, send the same coordinates to the
   --  destination, because it is an embedded subwindow.

   procedure Drag_Dest_Unset (Widget : not null access Gtk_Widget_Record);
   --  Clears information about a drop destination set with
   --  Gtk.Widget.Drag_Dest_Set. The widget will no longer receive notification
   --  of drags.

   procedure Drag_Get_Data
      (Widget  : not null access Gtk_Widget_Record;
       Context : not null access Gdk.Drag_Contexts.Drag_Context_Record'Class;
       Target  : Gdk.Atom.Gdk_Atom;
       Time    : guint32);
   --  Gets the data associated with a drag. When the data is received or the
   --  retrieval fails, GTK+ will emit a
   --  Gtk.Widget.Gtk_Widget::drag-data-received signal. Failure of the
   --  retrieval is indicated by the length field of the Selection_Data signal
   --  parameter being negative. However, when Gtk.Widget.Drag_Get_Data is
   --  called implicitely because the GTK_DEST_DEFAULT_DROP was set, then the
   --  widget will not receive notification of failed drops.
   --  "context": the drag context
   --  "target": the target (form of the data) to retrieve.
   --  "time_": a timestamp for retrieving the data. This will generally be
   --  the time received in a Gtk.Widget.Gtk_Widget::drag-motion" or
   --  Gtk.Widget.Gtk_Widget::drag-drop" signal.

   procedure Drag_Highlight (Widget : not null access Gtk_Widget_Record);
   --  Draws a highlight around a widget. This will attach handlers to
   --  Gtk.Widget.Gtk_Widget::draw, so the highlight will continue to be
   --  displayed until Gtk.Widget.Drag_Unhighlight is called.

   procedure Drag_Source_Add_Image_Targets
      (Widget : not null access Gtk_Widget_Record);
   --  Add the writable image targets supported by Gtk_Selection to the target
   --  list of the drag source. The targets are added with Info = 0. If you
   --  need another value, use gtk_target_list_add_image_targets and
   --  Gtk.Widget.Drag_Source_Set_Target_List.
   --  Since: gtk+ 2.6

   procedure Drag_Source_Add_Text_Targets
      (Widget : not null access Gtk_Widget_Record);
   --  Add the text targets supported by Gtk_Selection to the target list of
   --  the drag source. The targets are added with Info = 0. If you need
   --  another value, use gtk_target_list_add_text_targets and
   --  Gtk.Widget.Drag_Source_Set_Target_List.
   --  Since: gtk+ 2.6

   procedure Drag_Source_Add_Uri_Targets
      (Widget : not null access Gtk_Widget_Record);
   --  Add the URI targets supported by Gtk_Selection to the target list of
   --  the drag source. The targets are added with Info = 0. If you need
   --  another value, use gtk_target_list_add_uri_targets and
   --  Gtk.Widget.Drag_Source_Set_Target_List.
   --  Since: gtk+ 2.6

   function Drag_Source_Get_Target_List
      (Widget : not null access Gtk_Widget_Record)
       return Gtk.Selection.Target_List;
   procedure Drag_Source_Set_Target_List
      (Widget      : not null access Gtk_Widget_Record;
       Target_List : Gtk.Selection.Target_List);
   --  Changes the target types that this widget offers for drag-and-drop. The
   --  widget must first be made into a drag source with
   --  Gtk.Widget.Drag_Source_Set.
   --  Since: gtk+ 2.4
   --  "target_list": list of draggable targets, or null for none

   procedure Drag_Source_Set
      (Widget            : not null access Gtk_Widget_Record;
       Start_Button_Mask : Gdk.Types.Gdk_Modifier_Type;
       Targets           : array_of_Gtk_Target_Entry;
       N_Targets         : Gint;
       Actions           : Gdk.Drag_Contexts.Gdk_Drag_Action);
   --  Sets up a widget so that GTK+ will start a drag operation when the user
   --  clicks and drags on the widget. The widget must have a window.
   --  "start_button_mask": the bitmask of buttons that can start the drag
   --  "targets": the table of targets that the drag will support, may be null
   --  "n_targets": the number of items in Targets
   --  "actions": the bitmask of possible actions for a drag from this widget

   procedure Drag_Source_Set_Icon_Gicon
      (Widget : not null access Gtk_Widget_Record;
       Icon   : Glib.G_Icon.G_Icon);
   --  Sets the icon that will be used for drags from a particular source to
   --  Icon. See the docs for Gtk.Icon_Theme.Gtk_Icon_Theme for more details.
   --  Since: gtk+ 3.2
   --  "icon": A GIcon

   procedure Drag_Source_Set_Icon_Name
      (Widget    : not null access Gtk_Widget_Record;
       Icon_Name : UTF8_String);
   --  Sets the icon that will be used for drags from a particular source to a
   --  themed icon. See the docs for Gtk.Icon_Theme.Gtk_Icon_Theme for more
   --  details.
   --  Since: gtk+ 2.8
   --  "icon_name": name of icon to use

   procedure Drag_Source_Set_Icon_Pixbuf
      (Widget : not null access Gtk_Widget_Record;
       Pixbuf : not null access Gdk.Pixbuf.Gdk_Pixbuf_Record'Class);
   --  Sets the icon that will be used for drags from a particular widget from
   --  a Gdk.Pixbuf.Gdk_Pixbuf. GTK+ retains a reference for Pixbuf and will
   --  release it when it is no longer needed.
   --  "pixbuf": the Gdk.Pixbuf.Gdk_Pixbuf for the drag icon

   procedure Drag_Source_Set_Icon_Stock
      (Widget   : not null access Gtk_Widget_Record;
       Stock_Id : UTF8_String);
   --  Sets the icon that will be used for drags from a particular source to a
   --  stock icon.
   --  "stock_id": the ID of the stock icon to use

   procedure Drag_Source_Unset (Widget : not null access Gtk_Widget_Record);
   --  Undoes the effects of Gtk.Widget.Drag_Source_Set.

   procedure Drag_Unhighlight (Widget : not null access Gtk_Widget_Record);
   --  Removes a highlight set by Gtk.Widget.Drag_Highlight from a widget.

   procedure Draw
      (Widget : not null access Gtk_Widget_Record;
       Cr     : in out Cairo.Cairo_Context);
   --  Draws Widget to Cr. The top left corner of the widget will be drawn to
   --  the currently set origin point of Cr.
   --  You should pass a cairo context as Cr argument that is in an original
   --  state. Otherwise the resulting drawing is undefined. For example
   --  changing the operator using cairo_set_operator or the line width using
   --  cairo_set_line_width might have unwanted side effects. You may however
   --  change the context's transform matrix - like with cairo_scale,
   --  cairo_translate or cairo_set_matrix and clip region with cairo_clip
   --  prior to calling this function. Also, it is fine to modify the context
   --  with cairo_save and cairo_push_group prior to calling this function.
   --   Note: Special purpose widgets may contain special code for rendering to
   --  the screen and might appear differently on screen and when rendered
   --  using Gtk.Widget.Draw.
   --  Since: gtk+ 3.0
   --  "cr": a cairo context to draw to

   procedure Ensure_Style (Widget : not null access Gtk_Widget_Record);
   --  Ensures that Widget has a style (Widget->style).
   --  Not a very useful function; most of the time, if you want the style, the
   --  widget is realized, and realized widgets are guaranteed to have a style
   --  already.
   --  Deprecated:3.0: Use Gtk.Style_Context.Gtk_Style_Context instead

   procedure Error_Bell (Widget : not null access Gtk_Widget_Record);
   --  Notifies the user about an input-related error on this widget. If the
   --  Gtk.Settings.Gtk_Settings:gtk-error-bell setting is True, it calls
   --  gdk_window_beep, otherwise it does nothing.
   --  Note that the effect of gdk_window_beep can be configured in many ways,
   --  depending on the windowing backend and the desktop environment or window
   --  manager that is used.
   --  Since: gtk+ 2.12

   function Event
      (Widget : not null access Gtk_Widget_Record;
       Event  : Gdk.Event.Gdk_Event) return Boolean;
   --  Rarely-used function. This function is used to emit the event signals
   --  on a widget (those signals should never be emitted without using this
   --  function to do so). If you want to synthesize an event though, don't use
   --  this function; instead, use gtk_main_do_event so the event will behave
   --  as if it were in the event queue. Don't synthesize expose events;
   --  instead, use gdk_window_invalidate_rect to invalidate a region of the
   --  window.
   --  the event was handled)
   --  "event": a Gdk_Event

   procedure Freeze_Child_Notify
      (Widget : not null access Gtk_Widget_Record);
   --  Stops emission of Gtk.Widget.Gtk_Widget::child-notify signals on
   --  Widget. The signals are queued until Gtk.Widget.Thaw_Child_Notify is
   --  called on Widget.
   --  This is the analogue of g_object_freeze_notify for child properties.

   function Get_Allocated_Height
      (Widget : not null access Gtk_Widget_Record) return int;
   --  Returns the height that has currently been allocated to Widget. This
   --  function is intended to be used when implementing handlers for the
   --  Gtk.Widget.Gtk_Widget::draw function.

   function Get_Allocated_Width
      (Widget : not null access Gtk_Widget_Record) return int;
   --  Returns the width that has currently been allocated to Widget. This
   --  function is intended to be used when implementing handlers for the
   --  Gtk.Widget.Gtk_Widget::draw function.

   procedure Get_Allocation
      (Widget     : not null access Gtk_Widget_Record;
       Allocation : out Gtk_Allocation);
   procedure Set_Allocation
      (Widget     : not null access Gtk_Widget_Record;
       Allocation : in out Gtk_Allocation);
   --  Sets the widget's allocation. This should not be used directly, but
   --  from within a widget's size_allocate method.
   --  The allocation set should be the "adjusted" or actual allocation. If
   --  you're implementing a Gtk.Container.Gtk_Container, you want to use
   --  Gtk.Widget.Size_Allocate instead of Gtk.Widget.Set_Allocation. The
   --  GtkWidgetClass::adjust_size_allocation virtual method adjusts the
   --  allocation inside Gtk.Widget.Size_Allocate to create an adjusted
   --  allocation.
   --  Since: gtk+ 2.18
   --  "allocation": a pointer to a Gtk_Allocation to copy from

   function Get_Ancestor
      (Widget      : not null access Gtk_Widget_Record;
       Widget_Type : GType) return Gtk_Widget;
   --  Gets the first ancestor of Widget with type Widget_Type. For example,
   --  <literal>gtk_widget_get_ancestor (widget, GTK_TYPE_BOX)</literal> gets
   --  the first Gtk.Box.Gtk_Box that's an ancestor of Widget. No reference
   --  will be added to the returned widget; it should not be unreferenced. See
   --  note about checking for a toplevel Gtk.Window.Gtk_Window in the docs for
   --  Gtk.Widget.Get_Toplevel.
   --  Note that unlike Gtk.Widget.Is_Ancestor, Gtk.Widget.Get_Ancestor
   --  considers Widget to be an ancestor of itself.
   --  "widget_type": ancestor type

   function Get_App_Paintable
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_App_Paintable
      (Widget        : not null access Gtk_Widget_Record;
       App_Paintable : Boolean);
   --  Sets whether the application intends to draw on the widget in an
   --  Gtk.Widget.Gtk_Widget::draw handler.
   --  This is a hint to the widget and does not affect the behavior of the
   --  GTK+ core; many widgets ignore this flag entirely. For widgets that do
   --  pay attention to the flag, such as Gtk.Event_Box.Gtk_Event_Box and
   --  Gtk.Window.Gtk_Window, the effect is to suppress default themed drawing
   --  of the widget's background. (Children of the widget will still be
   --  drawn.) The application is then entirely responsible for drawing the
   --  widget background.
   --  Note that the background is still drawn when the widget is mapped.
   --  "app_paintable": True if the application will paint on the widget

   function Get_Can_Default
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Can_Default
      (Widget      : not null access Gtk_Widget_Record;
       Can_Default : Boolean);
   --  Specifies whether Widget can be a default widget. See
   --  Gtk.Widget.Grab_Default for details about the meaning of "default".
   --  Since: gtk+ 2.18
   --  "can_default": whether or not Widget can be a default widget.

   function Get_Can_Focus
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Can_Focus
      (Widget    : not null access Gtk_Widget_Record;
       Can_Focus : Boolean);
   --  Specifies whether Widget can own the input focus. See
   --  Gtk.Widget.Grab_Focus for actually setting the input focus on a widget.
   --  Since: gtk+ 2.18
   --  "can_focus": whether or not Widget can own the input focus.

   procedure Get_Child_Requisition
      (Widget      : not null access Gtk_Widget_Record;
       Requisition : out Gtk_Requisition);
   pragma Obsolescent (Get_Child_Requisition);
   --  This function is only for use in widget implementations. Obtains
   --  Widget->requisition, unless someone has forced a particular geometry on
   --  the widget (e.g. with Gtk.Widget.Set_Size_Request), in which case it
   --  returns that geometry instead of the widget's requisition.
   --  This function differs from Gtk.Widget.Size_Request in that it retrieves
   --  the last size request value from Widget->requisition, while
   --  Gtk.Widget.Size_Request actually calls the "size_request" method on
   --  Widget to compute the size request and fill in Widget->requisition, and
   --  only then returns Widget->requisition.
   --  Because this function does not call the "size_request" method, it can
   --  only be used when you know that Widget->requisition is up-to-date, that
   --  is, Gtk.Widget.Size_Request has been called since the last time a resize
   --  was queued. In general, only container implementations have this
   --  information; applications should use Gtk.Widget.Size_Request.
   --  Deprecated since 3.0, Use Gtk.Widget.Get_Preferred_Size instead.
   --  "requisition": a Gtk.Requisition.Gtk_Requisition to be filled in

   function Get_Child_Visible
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Child_Visible
      (Widget     : not null access Gtk_Widget_Record;
       Is_Visible : Boolean);
   --  Sets whether Widget should be mapped along with its when its parent is
   --  mapped and Widget has been shown with Gtk.Widget.Show.
   --  The child visibility can be set for widget before it is added to a
   --  container with Gtk.Widget.Set_Parent, to avoid mapping children
   --  unnecessary before immediately unmapping them. However it will be reset
   --  to its default state of True when the widget is removed from a
   --  container.
   --  Note that changing the child visibility of a widget does not queue a
   --  resize on the widget. Most of the time, the size of a widget is computed
   --  from all visible children, whether or not they are mapped. If this is
   --  not the case, the container can queue a resize itself.
   --  This function is only useful for container implementations and never
   --  should be called by an application.
   --  "is_visible": if True, Widget should be mapped along with its parent.

   function Get_Composite_Name
      (Widget : not null access Gtk_Widget_Record) return UTF8_String;
   procedure Set_Composite_Name
      (Widget : not null access Gtk_Widget_Record;
       Name   : UTF8_String);
   --  Sets a widgets composite name. The widget must be a composite child of
   --  its parent; see Gtk.Widget.Push_Composite_Child.
   --  "name": the name to set

   function Get_Device_Enabled
      (Widget : not null access Gtk_Widget_Record;
       Device : not null access Gdk.Device.Gdk_Device_Record'Class)
       return Boolean;
   procedure Set_Device_Enabled
      (Widget  : not null access Gtk_Widget_Record;
       Device  : not null access Gdk.Device.Gdk_Device_Record'Class;
       Enabled : Boolean);
   --  Enables or disables a Gdk.Device.Gdk_Device to interact with Widget and
   --  all its children.
   --  It does so by descending through the Gdk.Window.Gdk_Window hierarchy and
   --  enabling the same mask that is has for core events (i.e. the one that
   --  gdk_window_get_events returns).
   --  Since: gtk+ 3.0
   --  "device": a Gdk.Device.Gdk_Device
   --  "enabled": whether to enable the device

   function Get_Device_Events
      (Widget : not null access Gtk_Widget_Record;
       Device : not null access Gdk.Device.Gdk_Device_Record'Class)
       return Gdk.Event.Gdk_Event_Mask;
   procedure Set_Device_Events
      (Widget : not null access Gtk_Widget_Record;
       Device : not null access Gdk.Device.Gdk_Device_Record'Class;
       Events : Gdk.Event.Gdk_Event_Mask);
   --  Sets the device event mask (see Gdk.Event.Gdk_Event_Mask) for a widget.
   --  The event mask determines which events a widget will receive from
   --  Device. Keep in mind that different widgets have different default event
   --  masks, and by changing the event mask you may disrupt a widget's
   --  functionality, so be careful. This function must be called while a
   --  widget is unrealized. Consider Gtk.Widget.Add_Device_Events for widgets
   --  that are already realized, or if you want to preserve the existing event
   --  mask. This function can't be used with GTK_NO_WINDOW widgets; to get
   --  events on those widgets, place them inside a Gtk.Event_Box.Gtk_Event_Box
   --  and receive events on the event box.
   --  Since: gtk+ 3.0
   --  "device": a Gdk.Device.Gdk_Device
   --  "events": event mask

   function Get_Direction
      (Widget : not null access Gtk_Widget_Record) return Gtk_Text_Direction;
   procedure Set_Direction
      (Widget : not null access Gtk_Widget_Record;
       Dir    : Gtk_Text_Direction);
   --  Sets the reading direction on a particular widget. This direction
   --  controls the primary direction for widgets containing text, and also the
   --  direction in which the children of a container are packed. The ability
   --  to set the direction is present in order so that correct localization
   --  into languages with right-to-left reading directions can be done.
   --  Generally, applications will let the default reading direction present,
   --  except for containers where the containers are arranged in an order that
   --  is explicitely visual rather than logical (such as buttons for text
   --  justification).
   --  If the direction is set to GTK_TEXT_DIR_NONE, then the value set by
   --  Gtk.Widget.Set_Default_Direction will be used.
   --  "dir": the new direction

   function Get_Display
      (Widget : not null access Gtk_Widget_Record)
       return Gdk.Display.Gdk_Display;
   --  Get the Gdk.Display.Gdk_Display for the toplevel window associated with
   --  this widget. This function can only be called after the widget has been
   --  added to a widget hierarchy with a Gtk.Window.Gtk_Window at the top.
   --  In general, you should only create display specific resources when a
   --  widget has been realized, and you should free those resources when the
   --  widget is unrealized.
   --  Since: gtk+ 2.2

   function Get_Double_Buffered
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Double_Buffered
      (Widget          : not null access Gtk_Widget_Record;
       Double_Buffered : Boolean);
   --  Widgets are double buffered by default; you can use this function to
   --  turn off the buffering. "Double buffered" simply means that
   --  gdk_window_begin_paint_region and gdk_window_end_paint are called
   --  automatically around expose events sent to the widget.
   --  gdk_window_begin_paint diverts all drawing to a widget's window to an
   --  offscreen buffer, and gdk_window_end_paint draws the buffer to the
   --  screen. The result is that users see the window update in one smooth
   --  step, and don't see individual graphics primitives being rendered.
   --  In very simple terms, double buffered widgets don't flicker, so you
   --  would only use this function to turn off double buffering if you had
   --  special needs and really knew what you were doing.
   --  Note: if you turn off double-buffering, you have to handle expose
   --  events, since even the clearing to the background color or pixmap will
   --  not happen automatically (as it is done in gdk_window_begin_paint).
   --  "double_buffered": True to double-buffer a widget

   function Get_Events
      (Widget : not null access Gtk_Widget_Record)
       return Gdk.Event.Gdk_Event_Mask;
   procedure Set_Events
      (Widget : not null access Gtk_Widget_Record;
       Events : Gdk.Event.Gdk_Event_Mask);
   --  Sets the event mask (see Gdk.Event.Gdk_Event_Mask) for a widget. The
   --  event mask determines which events a widget will receive. Keep in mind
   --  that different widgets have different default event masks, and by
   --  changing the event mask you may disrupt a widget's functionality, so be
   --  careful. This function must be called while a widget is unrealized.
   --  Consider Gtk.Widget.Add_Events for widgets that are already realized, or
   --  if you want to preserve the existing event mask. This function can't be
   --  used with GTK_NO_WINDOW widgets; to get events on those widgets, place
   --  them inside a Gtk.Event_Box.Gtk_Event_Box and receive events on the
   --  event box.
   --  "events": event mask

   function Get_Halign
      (Widget : not null access Gtk_Widget_Record) return Gtk_Align;
   procedure Set_Halign
      (Widget : not null access Gtk_Widget_Record;
       Align  : Gtk_Align);
   --  Sets the horizontal alignment of Widget. See the
   --  Gtk.Widget.Gtk_Widget:halign property.
   --  "align": the horizontal alignment

   function Get_Has_Tooltip
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Has_Tooltip
      (Widget      : not null access Gtk_Widget_Record;
       Has_Tooltip : Boolean);
   --  Sets the has-tooltip property on Widget to Has_Tooltip. See
   --  Gtk.Widget.Gtk_Widget:has-tooltip for more information.
   --  Since: gtk+ 2.12
   --  "has_tooltip": whether or not Widget has a tooltip.

   function Get_Has_Window
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Has_Window
      (Widget     : not null access Gtk_Widget_Record;
       Has_Window : Boolean);
   --  Specifies whether Widget has a Gdk.Window.Gdk_Window of its own. Note
   --  that all realized widgets have a non-null "window" pointer
   --  (gtk_widget_get_window never returns a null window when a widget is
   --  realized), but for many of them it's actually the Gdk.Window.Gdk_Window
   --  of one of its parent widgets. Widgets that do not create a %window for
   --  themselves in Gtk.Widget.Gtk_Widget::realize must announce this by
   --  calling this function with Has_Window = False.
   --  This function should only be called by widget implementations, and they
   --  should call it in their init function.
   --  Since: gtk+ 2.18
   --  "has_window": whether or not Widget has a window.

   function Get_Hexpand
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Hexpand
      (Widget : not null access Gtk_Widget_Record;
       Expand : Boolean);
   --  Sets whether the widget would like any available extra horizontal
   --  space. When a user resizes a Gtk.Window.Gtk_Window, widgets with
   --  expand=TRUE generally receive the extra space. For example, a list or
   --  scrollable area or document in your window would often be set to expand.
   --  Call this function to set the expand flag if you would like your widget
   --  to become larger horizontally when the window has extra room.
   --  By default, widgets automatically expand if any of their children want
   --  to expand. (To see if a widget will automatically expand given its
   --  current children and state, call Gtk.Widget.Compute_Expand. A container
   --  can decide how the expandability of children affects the expansion of
   --  the container by overriding the compute_expand virtual method on
   --  Gtk.Widget.Gtk_Widget.).
   --  Setting hexpand explicitly with this function will override the
   --  automatic expand behavior.
   --  This function forces the widget to expand or not to expand, regardless
   --  of children. The override occurs because Gtk.Widget.Set_Hexpand sets the
   --  hexpand-set property (see Gtk.Widget.Set_Hexpand_Set) which causes the
   --  widget's hexpand value to be used, rather than looking at children and
   --  widget state.
   --  "expand": whether to expand

   function Get_Hexpand_Set
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Hexpand_Set
      (Widget : not null access Gtk_Widget_Record;
       Set    : Boolean);
   --  Sets whether the hexpand flag (see Gtk.Widget.Get_Hexpand) will be
   --  used.
   --  The hexpand-set property will be set automatically when you call
   --  Gtk.Widget.Set_Hexpand to set hexpand, so the most likely reason to use
   --  this function would be to unset an explicit expand flag.
   --  If hexpand is set, then it overrides any computed expand value based on
   --  child widgets. If hexpand is not set, then the expand value depends on
   --  whether any children of the widget would like to expand.
   --  There are few reasons to use this function, but it's here for
   --  completeness and consistency.
   --  "set": value for hexpand-set property

   function Get_Mapped
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Mapped
      (Widget : not null access Gtk_Widget_Record;
       Mapped : Boolean);
   --  Marks the widget as being realized.
   --  This function should only ever be called in a derived widget's "map" or
   --  "unmap" implementation.
   --  Since: gtk+ 2.20
   --  "mapped": True to mark the widget as mapped

   function Get_Margin_Bottom
      (Widget : not null access Gtk_Widget_Record) return Gint;
   procedure Set_Margin_Bottom
      (Widget : not null access Gtk_Widget_Record;
       Margin : Gint);
   --  Sets the bottom margin of Widget. See the
   --  Gtk.Widget.Gtk_Widget:margin-bottom property.
   --  Since: gtk+ 3.0
   --  "margin": the bottom margin

   function Get_Margin_Left
      (Widget : not null access Gtk_Widget_Record) return Gint;
   procedure Set_Margin_Left
      (Widget : not null access Gtk_Widget_Record;
       Margin : Gint);
   --  Sets the left margin of Widget. See the
   --  Gtk.Widget.Gtk_Widget:margin-left property.
   --  Since: gtk+ 3.0
   --  "margin": the left margin

   function Get_Margin_Right
      (Widget : not null access Gtk_Widget_Record) return Gint;
   procedure Set_Margin_Right
      (Widget : not null access Gtk_Widget_Record;
       Margin : Gint);
   --  Sets the right margin of Widget. See the
   --  Gtk.Widget.Gtk_Widget:margin-right property.
   --  Since: gtk+ 3.0
   --  "margin": the right margin

   function Get_Margin_Top
      (Widget : not null access Gtk_Widget_Record) return Gint;
   procedure Set_Margin_Top
      (Widget : not null access Gtk_Widget_Record;
       Margin : Gint);
   --  Sets the top margin of Widget. See the Gtk.Widget.Gtk_Widget:margin-top
   --  property.
   --  Since: gtk+ 3.0
   --  "margin": the top margin

   function Get_Modifier_Style
      (Widget : not null access Gtk_Widget_Record)
       return Gtk.Rc_Style.Gtk_Rc_Style;
   --  Returns the current modifier style for the widget. (As set by
   --  gtk_widget_modify_style.) If no style has previously set, a new
   --  Gtk.Rc_Style.Gtk_Rc_Style will be created with all values unset, and set
   --  as the modifier style for the widget. If you make changes to this rc
   --  style, you must call gtk_widget_modify_style, passing in the returned rc
   --  style, to make sure that your changes take effect.
   --  Caution: passing the style back to gtk_widget_modify_style will normally
   --  end up destroying it, because gtk_widget_modify_style copies the
   --  passed-in style and sets the copy as the new modifier style, thus
   --  dropping any reference to the old modifier style. Add a reference to the
   --  modifier style if you want to keep it alive.
   --  This rc style is owned by the widget. If you want to keep a pointer to
   --  value this around, you must add a refcount using g_object_ref.
   --  Deprecated:3.0: Use Gtk.Style_Context.Gtk_Style_Context with a custom
   --  Gtk.Style_Provider.Gtk_Style_Provider instead

   function Get_Name
      (Widget : not null access Gtk_Widget_Record) return UTF8_String;
   procedure Set_Name
      (Widget : not null access Gtk_Widget_Record;
       Name   : UTF8_String);
   --  Widgets can be named, which allows you to refer to them from a CSS
   --  file. You can apply a style to widgets with a particular name in the CSS
   --  file. See the documentation for the CSS syntax (on the same page as the
   --  docs for Gtk.Style_Context.Gtk_Style_Context).
   --  Note that the CSS syntax has certain special characters to delimit and
   --  represent elements in a selector (period, &num;, &gt;, &ast;...), so
   --  using these will make your widget impossible to match by name. Any
   --  combination of alphanumeric symbols, dashes and underscores will
   --  suffice.
   --  "name": name for the widget

   function Get_No_Show_All
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_No_Show_All
      (Widget      : not null access Gtk_Widget_Record;
       No_Show_All : Boolean);
   --  Sets the Gtk.Widget.Gtk_Widget:no-show-all property, which determines
   --  whether calls to Gtk.Widget.Show_All will affect this widget.
   --  This is mostly for use in constructing widget hierarchies with
   --  externally controlled visibility, see Gtk.Uimanager.Gtk_Uimanager.
   --  Since: gtk+ 2.4
   --  "no_show_all": the new value for the "no-show-all" property

   function Get_Pango_Context
      (Widget : not null access Gtk_Widget_Record)
       return Pango.Context.Pango_Context;
   --  Gets a Pango.Context.Pango_Context with the appropriate font map, font
   --  description, and base direction for this widget. Unlike the context
   --  returned by Gtk.Widget.Create_Pango_Context, this context is owned by
   --  the widget (it can be used until the screen for the widget changes or
   --  the widget is removed from its toplevel), and will be updated to match
   --  any changes to the widget's attributes.
   --  If you create and keep a Pango.Layout.Pango_Layout using this context,
   --  you must deal with changes to the context by calling
   --  pango_layout_context_changed on the layout in response to the
   --  Gtk.Widget.Gtk_Widget::style-updated and
   --  Gtk.Widget.Gtk_Widget::direction-changed signals for the widget.

   function Get_Parent
      (Widget : not null access Gtk_Widget_Record) return Gtk_Widget;
   procedure Set_Parent
      (Widget : not null access Gtk_Widget_Record;
       Parent : not null access Gtk_Widget_Record'Class);
   --  This function is useful only when implementing subclasses of
   --  Gtk.Container.Gtk_Container. Sets the container as the parent of Widget,
   --  and takes care of some details such as updating the state and style of
   --  the child to reflect its new location. The opposite function is
   --  Gtk.Widget.Unparent.
   --  "parent": parent container

   function Get_Parent_Window
      (Widget : not null access Gtk_Widget_Record)
       return Gdk.Window.Gdk_Window;
   procedure Set_Parent_Window
      (Widget        : not null access Gtk_Widget_Record;
       Parent_Window : Gdk.Window.Gdk_Window);
   --  Sets a non default parent window for Widget.
   --  For GtkWindow classes, setting a Parent_Window effects whether the
   --  window is a toplevel window or can be embedded into other widgets.
   --   Note: For GtkWindow classes, this needs to be called before the window
   --  is realized.
   --  "parent_window": the new parent window.

   procedure Get_Pointer
      (Widget : not null access Gtk_Widget_Record;
       X      : out Gint;
       Y      : out Gint);
   --  Obtains the location of the mouse pointer in widget coordinates. Widget
   --  coordinates are a bit odd; for historical reasons, they are defined as
   --  Widget->window coordinates for widgets that are not GTK_NO_WINDOW
   --  widgets, and are relative to Widget->allocation.x, Widget->allocation.y
   --  for widgets that are GTK_NO_WINDOW widgets.
   --  "x": return location for the X coordinate, or null
   --  "y": return location for the Y coordinate, or null

   procedure Get_Preferred_Height
      (Widget         : not null access Gtk_Widget_Record;
       Minimum_Height : out Gint;
       Natural_Height : out Gint);
   --  Retrieves a widget's initial minimum and natural height.
   --   Note: This call is specific to width-for-height requests.
   --  The returned request will be modified by the
   --  GtkWidgetClass::adjust_size_request virtual method and by any
   --  Gtk.Size_Group.Gtk_Size_Group<!-- -->s that have been applied. That is,
   --  the returned request is the one that should be used for layout, not
   --  necessarily the one returned by the widget itself.
   --  Since: gtk+ 3.0
   --  "minimum_height": location to store the minimum height, or null
   --  "natural_height": location to store the natural height, or null

   procedure Get_Preferred_Height_For_Width
      (Widget         : not null access Gtk_Widget_Record;
       Width          : Gint;
       Minimum_Height : out Gint;
       Natural_Height : out Gint);
   --  Retrieves a widget's minimum and natural height if it would be given
   --  the specified Width.
   --  The returned request will be modified by the
   --  GtkWidgetClass::adjust_size_request virtual method and by any
   --  Gtk.Size_Group.Gtk_Size_Group<!-- -->s that have been applied. That is,
   --  the returned request is the one that should be used for layout, not
   --  necessarily the one returned by the widget itself.
   --  Since: gtk+ 3.0
   --  "width": the width which is available for allocation
   --  "minimum_height": location for storing the minimum height, or null
   --  "natural_height": location for storing the natural height, or null

   procedure Get_Preferred_Size
      (Widget       : not null access Gtk_Widget_Record;
       Minimum_Size : out Gtk_Requisition;
       Natural_Size : out Gtk_Requisition);
   --  Retrieves the minimum and natural size of a widget, taking into account
   --  the widget's preference for height-for-width management.
   --  This is used to retrieve a suitable size by container widgets which do
   --  not impose any restrictions on the child placement. It can be used to
   --  deduce toplevel window and menu sizes as well as child widgets in
   --  free-form containers such as GtkLayout.
   --   Note: Handle with care. Note that the natural height of a
   --  height-for-width widget will generally be a smaller size than the
   --  minimum height, since the required height for the natural width is
   --  generally smaller than the required height for the minimum width.
   --  Since: gtk+ 3.0
   --  "minimum_size": location for storing the minimum size, or null
   --  "natural_size": location for storing the natural size, or null

   procedure Get_Preferred_Width
      (Widget        : not null access Gtk_Widget_Record;
       Minimum_Width : out Gint;
       Natural_Width : out Gint);
   --  Retrieves a widget's initial minimum and natural width.
   --   Note: This call is specific to height-for-width requests.
   --  The returned request will be modified by the
   --  GtkWidgetClass::adjust_size_request virtual method and by any
   --  Gtk.Size_Group.Gtk_Size_Group<!-- -->s that have been applied. That is,
   --  the returned request is the one that should be used for layout, not
   --  necessarily the one returned by the widget itself.
   --  Since: gtk+ 3.0
   --  "minimum_width": location to store the minimum width, or null
   --  "natural_width": location to store the natural width, or null

   procedure Get_Preferred_Width_For_Height
      (Widget        : not null access Gtk_Widget_Record;
       Height        : Gint;
       Minimum_Width : out Gint;
       Natural_Width : out Gint);
   --  Retrieves a widget's minimum and natural width if it would be given the
   --  specified Height.
   --  The returned request will be modified by the
   --  GtkWidgetClass::adjust_size_request virtual method and by any
   --  Gtk.Size_Group.Gtk_Size_Group<!-- -->s that have been applied. That is,
   --  the returned request is the one that should be used for layout, not
   --  necessarily the one returned by the widget itself.
   --  Since: gtk+ 3.0
   --  "height": the height which is available for allocation
   --  "minimum_width": location for storing the minimum width, or null
   --  "natural_width": location for storing the natural width, or null

   function Get_Realized
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Realized
      (Widget   : not null access Gtk_Widget_Record;
       Realized : Boolean);
   --  Marks the widget as being realized.
   --  This function should only ever be called in a derived widget's "realize"
   --  or "unrealize" implementation.
   --  Since: gtk+ 2.20
   --  "realized": True to mark the widget as realized

   function Get_Receives_Default
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Receives_Default
      (Widget           : not null access Gtk_Widget_Record;
       Receives_Default : Boolean);
   --  Specifies whether Widget will be treated as the default widget within
   --  its toplevel when it has the focus, even if another widget is the
   --  default.
   --  See Gtk.Widget.Grab_Default for details about the meaning of "default".
   --  Since: gtk+ 2.18
   --  "receives_default": whether or not Widget can be a default widget.

   function Get_Request_Mode
      (Widget : not null access Gtk_Widget_Record)
       return Gtk.Enums.Gtk_Size_Request_Mode;
   --  Gets whether the widget prefers a height-for-width layout or a
   --  width-for-height layout.
   --   Note: Gtk.Bin.Gtk_Bin widgets generally propagate the preference of
   --  their child, container widgets need to request something either in
   --  context of their children or in context of their allocation
   --  capabilities.
   --  Since: gtk+ 3.0

   procedure Get_Requisition
      (Widget      : not null access Gtk_Widget_Record;
       Requisition : out Gtk_Requisition);
   pragma Obsolescent (Get_Requisition);
   --  Retrieves the widget's requisition.
   --  This function should only be used by widget implementations in order to
   --  figure whether the widget's requisition has actually changed after some
   --  internal state change (so that they can call Gtk.Widget.Queue_Resize
   --  instead of Gtk.Widget.Queue_Draw).
   --  Normally, Gtk.Widget.Size_Request should be used.
   --   removed, If you need to cache sizes across requests and allocations,
   --  add an explicit cache to the widget in question instead.
   --  Since: gtk+ 2.20
   --  Deprecated since 3.0, The Gtk.Requisition.Gtk_Requisition cache on the
   --  widget was
   --  "requisition": a pointer to a Gtk.Requisition.Gtk_Requisition to copy
   --  to

   function Get_Root_Window
      (Widget : not null access Gtk_Widget_Record)
       return Gdk.Window.Gdk_Window;
   --  Get the root window where this widget is located. This function can
   --  only be called after the widget has been added to a widget hierarchy
   --  with Gtk.Window.Gtk_Window at the top.
   --  The root window is useful for such purposes as creating a popup
   --  Gdk.Window.Gdk_Window associated with the window. In general, you should
   --  only create display specific resources when a widget has been realized,
   --  and you should free those resources when the widget is unrealized.
   --  Since: gtk+ 2.2

   function Get_Screen
      (Widget : not null access Gtk_Widget_Record)
       return Gdk.Screen.Gdk_Screen;
   --  Get the Gdk.Screen.Gdk_Screen from the toplevel window associated with
   --  this widget. This function can only be called after the widget has been
   --  added to a widget hierarchy with a Gtk.Window.Gtk_Window at the top.
   --  In general, you should only create screen specific resources when a
   --  widget has been realized, and you should free those resources when the
   --  widget is unrealized.
   --  Since: gtk+ 2.2

   function Get_Sensitive
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Sensitive
      (Widget    : not null access Gtk_Widget_Record;
       Sensitive : Boolean := True);
   --  Sets the sensitivity of a widget. A widget is sensitive if the user can
   --  interact with it. Insensitive widgets are "grayed out" and the user
   --  can't interact with them. Insensitive widgets are known as "inactive",
   --  "disabled", or "ghosted" in some other toolkits.
   --  "sensitive": True to make the widget sensitive

   procedure Get_Size_Request
      (Widget : not null access Gtk_Widget_Record;
       Width  : out Gint;
       Height : out Gint);
   procedure Set_Size_Request
      (Widget : not null access Gtk_Widget_Record;
       Width  : Gint;
       Height : Gint);
   procedure Size_Request
      (Widget      : not null access Gtk_Widget_Record;
       Requisition : out Gtk_Requisition);
   pragma Obsolescent (Size_Request);
   --  This function is typically used when implementing a
   --  Gtk.Container.Gtk_Container subclass. Obtains the preferred size of a
   --  widget. The container uses this information to arrange its child widgets
   --  and decide what size allocations to give them with
   --  Gtk.Widget.Size_Allocate.
   --  You can also call this function from an application, with some caveats.
   --  Most notably, getting a size request requires the widget to be
   --  associated with a screen, because font information may be needed.
   --  Multihead-aware applications should keep this in mind.
   --  Also remember that the size request is not necessarily the size a widget
   --  will actually be allocated.
   --  Deprecated since 3.0, Use Gtk.Widget.Get_Preferred_Size instead.
   --  "requisition": a Gtk.Requisition.Gtk_Requisition to be filled in

   function Get_State
      (Widget : not null access Gtk_Widget_Record)
       return Gtk.Enums.Gtk_State_Type;
   pragma Obsolescent (Get_State);
   procedure Set_State
      (Widget : not null access Gtk_Widget_Record;
       State  : Gtk.Enums.Gtk_State_Type);
   pragma Obsolescent (Set_State);
   --  This function is for use in widget implementations. Sets the state of a
   --  widget (insensitive, prelighted, etc.) Usually you should set the state
   --  using wrapper functions such as Gtk.Widget.Set_Sensitive.
   --  Deprecated since None, 3.0. Use Gtk.Widget.Set_State_Flags instead.
   --  "state": new state for Widget

   function Get_State_Flags
      (Widget : not null access Gtk_Widget_Record)
       return Gtk.Enums.Gtk_State_Flags;
   procedure Set_State_Flags
      (Widget : not null access Gtk_Widget_Record;
       Flags  : Gtk.Enums.Gtk_State_Flags;
       Clear  : Boolean);
   --  This function is for use in widget implementations. Turns on flag
   --  values in the current widget state (insensitive, prelighted, etc.).
   --  It is worth mentioning that any other state than
   --  GTK_STATE_FLAG_INSENSITIVE, will be propagated down to all non-internal
   --  children if Widget is a Gtk.Container.Gtk_Container, while
   --  GTK_STATE_FLAG_INSENSITIVE itself will be propagated down to all
   --  Gtk.Container.Gtk_Container children by different means than turning on
   --  the state flag down the hierarchy, both Gtk.Widget.Get_State_Flags and
   --  Gtk.Widget.Is_Sensitive will make use of these.
   --  Since: gtk+ 3.0
   --  "flags": State flags to turn on
   --  "clear": Whether to clear state before turning on Flags

   function Get_Style
      (Widget : not null access Gtk_Widget_Record)
       return Gtk.Style.Gtk_Style;
   procedure Set_Style
      (Widget : not null access Gtk_Widget_Record;
       Style  : access Gtk.Style.Gtk_Style_Record'Class);
   --  Used to set the Gtk.Style.Gtk_Style for a widget (Widget->style). Since
   --  GTK 3, this function does nothing, the passed in style is ignored.
   --  Deprecated:3.0: Use Gtk.Style_Context.Gtk_Style_Context instead
   --  "style": a Gtk.Style.Gtk_Style, or null to remove the effect of a
   --  previous call to Gtk.Widget.Set_Style and go back to the default style

   function Get_Style_Context
      (Widget : not null access Gtk_Widget_Record)
       return Gtk.Style_Context.Gtk_Style_Context;
   --  Returns the style context associated to Widget.
   --  must not be freed.

   function Get_Support_Multidevice
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Support_Multidevice
      (Widget              : not null access Gtk_Widget_Record;
       Support_Multidevice : Boolean);
   --  Enables or disables multiple pointer awareness. If this setting is
   --  True, Widget will start receiving multiple, per device enter/leave
   --  events. Note that if custom Gdk.Window.Gdk_Window<!-- -->s are created
   --  in Gtk.Widget.Gtk_Widget::realize, gdk_window_set_support_multidevice
   --  will have to be called manually on them.
   --  Since: gtk+ 3.0
   --  "support_multidevice": True to support input from multiple devices.

   function Get_Tooltip_Window
      (Widget : not null access Gtk_Widget_Record) return Gtk_Widget;
   procedure Set_Tooltip_Window
      (Widget        : not null access Gtk_Widget_Record;
       Custom_Window : access Gtk_Widget_Record'Class);
   --  Replaces the default, usually yellow, window used for displaying
   --  tooltips with Custom_Window. GTK+ will take care of showing and hiding
   --  Custom_Window at the right moment, to behave likewise as the default
   --  tooltip window. If Custom_Window is null, the default tooltip window
   --  will be used.
   --  If the custom window should have the default theming it needs to have
   --  the name "gtk-tooltip", see Gtk.Widget.Set_Name.
   --  Since: gtk+ 2.12
   --  "custom_window": a Gtk.Window.Gtk_Window, or null

   function Get_Toplevel
      (Widget : not null access Gtk_Widget_Record) return Gtk_Widget;
   --  This function returns the topmost widget in the container hierarchy
   --  Widget is a part of. If Widget has no parent widgets, it will be
   --  returned as the topmost widget. No reference will be added to the
   --  returned widget; it should not be unreferenced.
   --  Note the difference in behavior vs. Gtk.Widget.Get_Ancestor;
   --  <literal>gtk_widget_get_ancestor (widget, GTK_TYPE_WINDOW)</literal>
   --  would return null if Widget wasn't inside a toplevel window, and if the
   --  window was inside a Gtk.Window.Gtk_Window-derived widget which was in
   --  turn inside the toplevel Gtk.Window.Gtk_Window. While the second case
   --  may seem unlikely, it actually happens when a Gtk.Plug.Gtk_Plug is
   --  embedded inside a Gtk.Socket.Gtk_Socket within the same application.
   --  To reliably find the toplevel Gtk.Window.Gtk_Window, use
   --  Gtk.Widget.Get_Toplevel and check if the TOPLEVEL flags is set on the
   --  result. |[ GtkWidget *toplevel = gtk_widget_get_toplevel (widget); if
   --  (gtk_widget_is_toplevel (toplevel)) { /&ast; Perform action on toplevel.
   --  &ast;/ } ]|
   --  if there's no ancestor.

   function Get_Valign
      (Widget : not null access Gtk_Widget_Record) return Gtk_Align;
   procedure Set_Valign
      (Widget : not null access Gtk_Widget_Record;
       Align  : Gtk_Align);
   --  Sets the vertical alignment of Widget. See the
   --  Gtk.Widget.Gtk_Widget:valign property.
   --  "align": the vertical alignment

   function Get_Vexpand
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Vexpand
      (Widget : not null access Gtk_Widget_Record;
       Expand : Boolean);
   --  Sets whether the widget would like any available extra vertical space.
   --  See Gtk.Widget.Set_Hexpand for more detail.
   --  "expand": whether to expand

   function Get_Vexpand_Set
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Vexpand_Set
      (Widget : not null access Gtk_Widget_Record;
       Set    : Boolean);
   --  Sets whether the vexpand flag (see Gtk.Widget.Get_Vexpand) will be
   --  used.
   --  See Gtk.Widget.Set_Hexpand_Set for more detail.
   --  "set": value for vexpand-set property

   function Get_Visible
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   procedure Set_Visible
      (Widget  : not null access Gtk_Widget_Record;
       Visible : Boolean);
   --  Sets the visibility state of Widget. Note that setting this to True
   --  doesn't mean the widget is actually viewable, see
   --  Gtk.Widget.Get_Visible.
   --  This function simply calls Gtk.Widget.Show or Gtk.Widget.Hide but is
   --  nicer to use when the visibility of the widget depends on some
   --  condition.
   --  Since: gtk+ 2.18
   --  "visible": whether the widget should be shown or not

   function Get_Visual
      (Widget : not null access Gtk_Widget_Record)
       return Gdk.Visual.Gdk_Visual;
   procedure Set_Visual
      (Widget : not null access Gtk_Widget_Record;
       Visual : Gdk.Visual.Gdk_Visual);
   --  Sets the visual that should be used for by widget and its children for
   --  creating Gdk_Windows. The visual must be on the same
   --  Gdk.Screen.Gdk_Screen as returned by gdk_widget_get_screen, so handling
   --  the Gtk.Widget.Gtk_Widget::screen-changed signal is necessary.
   --  Setting a new Visual will not cause Widget to recreate its windows, so
   --  you should call this function before Widget is realized.
   --  "visual": visual to be used or null to unset a previous one

   function Get_Window
      (Widget : not null access Gtk_Widget_Record)
       return Gdk.Window.Gdk_Window;
   procedure Set_Window
      (Widget : not null access Gtk_Widget_Record;
       Window : Gdk.Window.Gdk_Window);
   --  Sets a widget's window. This function should only be used in a widget's
   --  Gtk.Widget.Gtk_Widget::realize implementation. The %window passed is
   --  usually either new window created with gdk_window_new, or the window of
   --  its parent widget as returned by Gtk.Widget.Get_Parent_Window.
   --  Widgets must indicate whether they will create their own
   --  Gdk.Window.Gdk_Window by calling Gtk.Widget.Set_Has_Window. This is
   --  usually done in the widget's init function.
   --   Note: This function does not add any reference to Window.
   --  Since: gtk+ 2.18
   --  "window": a Gdk.Window.Gdk_Window

   procedure Grab_Add (Widget : not null access Gtk_Widget_Record);
   --  Makes Widget the current grabbed widget.
   --  This means that interaction with other widgets in the same application
   --  is blocked and mouse as well as keyboard events are delivered to this
   --  widget.
   --  If Widget is not sensitive, it is not set as the current grabbed widget
   --  and this function does nothing.

   procedure Grab_Default (Widget : not null access Gtk_Widget_Record);
   --  Causes Widget to become the default widget. Widget must have the
   --  GTK_CAN_DEFAULT flag set; typically you have to set this flag yourself
   --  by calling <literal>gtk_widget_set_can_default (Widget, True)</literal>.
   --  The default widget is activated when the user presses Enter in a window.
   --  Default widgets must be activatable, that is, Gtk.Widget.Activate should
   --  affect them. Note that Gtk.GEntry.Gtk_Entry widgets require the
   --  "activates-default" property set to True before they activate the
   --  default widget when Enter is pressed and the Gtk.GEntry.Gtk_Entry is
   --  focused.

   procedure Grab_Focus (Widget : not null access Gtk_Widget_Record);
   --  Causes Widget to have the keyboard focus for the Gtk.Window.Gtk_Window
   --  it's inside. Widget must be a focusable widget, such as a
   --  Gtk.GEntry.Gtk_Entry; something like Gtk.Frame.Gtk_Frame won't work.
   --  More precisely, it must have the GTK_CAN_FOCUS flag set. Use
   --  Gtk.Widget.Set_Can_Focus to modify that flag.
   --  The widget also needs to be realized and mapped. This is indicated by
   --  the related signals. Grabbing the focus immediately after creating the
   --  widget will likely fail and cause critical warnings.

   procedure Grab_Remove (Widget : not null access Gtk_Widget_Record);
   --  Removes the grab from the given widget.
   --  You have to pair calls to Gtk.Widget.Grab_Add and
   --  Gtk.Widget.Grab_Remove.
   --  If Widget does not have the grab, this function does nothing.

   function Has_Default
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Determines whether Widget is the current default widget within its
   --  toplevel. See Gtk.Widget.Set_Can_Default.
   --  its toplevel, False otherwise
   --  Since: gtk+ 2.18

   function Has_Focus
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Determines if the widget has the global input focus. See
   --  Gtk.Widget.Is_Focus for the difference between having the global input
   --  focus, and only having the focus within a toplevel.
   --  Since: gtk+ 2.18

   function Has_Grab
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Determines whether the widget is currently grabbing events, so it is
   --  the only widget receiving input events (keyboard and mouse).
   --  See also Gtk.Widget.Grab_Add.
   --  Since: gtk+ 2.18

   function Has_Rc_Style
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Determines if the widget style has been looked up through the rc
   --  mechanism.
   --  mechanism, False otherwise.
   --   Deprecated:3.0: Use Gtk.Style_Context.Gtk_Style_Context instead
   --  Since: gtk+ 2.20

   function Has_Screen
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Checks whether there is a Gdk.Screen.Gdk_Screen is associated with this
   --  widget. All toplevel widgets have an associated screen, and all widgets
   --  added into a hierarchy with a toplevel window at the top.
   --  with the widget.
   --  Since: gtk+ 2.2

   function Has_Visible_Focus
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Determines if the widget should show a visible indication that it has
   --  the global input focus. This is a convenience function for use in ::draw
   --  handlers that takes into account whether focus indication should
   --  currently be shown in the toplevel window of Widget. See
   --  gtk_window_get_focus_visible for more information about focus
   --  indication.
   --  To find out if the widget has the global input focus, use
   --  Gtk.Widget.Has_Focus.
   --  Since: gtk+ 3.2

   procedure Hide (Widget : not null access Gtk_Widget_Record);
   --  Reverses the effects of Gtk.Widget.Show, causing the widget to be
   --  hidden (invisible to the user).

   function Hide_On_Delete
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Utility function; intended to be connected to the
   --  Gtk.Widget.Gtk_Widget::delete-event signal on a Gtk.Window.Gtk_Window.
   --  The function calls Gtk.Widget.Hide on its argument, then returns True.
   --  If connected to ::delete-event, the result is that clicking the close
   --  button for a window (on the window frame, top right corner usually) will
   --  hide but not destroy the window. By default, GTK+ destroys windows when
   --  ::delete-event is received.

   function In_Destruction
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Returns whether the widget is currently being destroyed. This
   --  information can sometimes be used to avoid doing unnecessary work.

   procedure Input_Shape_Combine_Region
      (Widget : not null access Gtk_Widget_Record;
       Region : in out Cairo.Region.Cairo_Region);
   --  Sets an input shape for this widget's GDK window. This allows for
   --  windows which react to mouse click in a nonrectangular region, see
   --  gdk_window_input_shape_combine_region for more information.
   --  Since: gtk+ 3.0
   --  "region": shape to be added, or null to remove an existing shape

   function Is_Ancestor
      (Widget   : not null access Gtk_Widget_Record;
       Ancestor : not null access Gtk_Widget_Record'Class) return Boolean;
   --  Determines whether Widget is somewhere inside Ancestor, possibly with
   --  intermediate containers.
   --  grandchild, great grandchild, etc.
   --  "ancestor": another Gtk.Widget.Gtk_Widget

   function Is_Composited
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Whether Widget can rely on having its alpha channel drawn correctly. On
   --  X11 this function returns whether a compositing manager is running for
   --  Widget's screen.
   --  Please note that the semantics of this call will change in the future if
   --  used on a widget that has a composited window in its hierarchy (as set
   --  by gdk_window_set_composited).
   --  channel being drawn correctly.
   --  Since: gtk+ 2.10

   function Is_Drawable
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Determines whether Widget can be drawn to. A widget can be drawn to if
   --  it is mapped and visible.
   --  Since: gtk+ 2.18

   function Is_Focus
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Determines if the widget is the focus widget within its toplevel. (This
   --  does not mean that the HAS_FOCUS flag is necessarily set; HAS_FOCUS will
   --  only be set if the toplevel widget additionally has the global input
   --  focus.)

   function Is_Sensitive
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Returns the widget's effective sensitivity, which means it is sensitive
   --  itself and also its parent widget is sensitive
   --  Since: gtk+ 2.18

   function Is_Toplevel
      (Widget : not null access Gtk_Widget_Record) return Boolean;
   --  Determines whether Widget is a toplevel widget.
   --  Currently only Gtk.Window.Gtk_Window and Gtk.Invisible.Gtk_Invisible
   --  (and out-of-process Gtk_Plugs) are toplevel widgets. Toplevel widgets
   --  have no parent widget.
   --  Since: gtk+ 2.18

   function Keynav_Failed
      (Widget    : not null access Gtk_Widget_Record;
       Direction : Gtk.Enums.Gtk_Direction_Type) return Boolean;
   --  This function should be called whenever keyboard navigation within a
   --  single widget hits a boundary. The function emits the
   --  Gtk.Widget.Gtk_Widget::keynav-failed signal on the widget and its return
   --  value should be interpreted in a way similar to the return value of
   --  Gtk.Widget.Child_Focus:
   --  When True is returned, stay in the widget, the failed keyboard
   --  navigation is Ok and/or there is nowhere we can/should move the focus
   --  to.
   --  When False is returned, the caller should continue with keyboard
   --  navigation outside the widget, e.g. by calling Gtk.Widget.Child_Focus on
   --  the widget's toplevel.
   --  The default ::keynav-failed handler returns True for GTK_DIR_TAB_FORWARD
   --  and GTK_DIR_TAB_BACKWARD. For the other values of
   --  Gtk.Enums.Gtk_Direction_Type, it looks at the
   --  Gtk.Settings.Gtk_Settings:gtk-keynav-cursor-only setting and returns
   --  False if the setting is True. This way the entire user interface becomes
   --  cursor-navigatable on input devices such as mobile phones which only
   --  have cursor keys but no tab key.
   --  Whenever the default handler returns True, it also calls
   --  Gtk.Widget.Error_Bell to notify the user of the failed keyboard
   --  navigation.
   --  A use case for providing an own implementation of ::keynav-failed
   --  (either by connecting to it or by overriding it) would be a row of
   --  Gtk.GEntry.Gtk_Entry widgets where the user should be able to navigate
   --  the entire row with the cursor keys, as e.g. known from user interfaces
   --  that require entering license keys.
   --  if the emitting widget should try to handle the keyboard navigation
   --  attempt in its parent container(s).
   --  Since: gtk+ 2.12
   --  "direction": direction of focus movement

   function List_Mnemonic_Labels
      (Widget : not null access Gtk_Widget_Record) return Widget_List.Glist;
   --  Returns a newly allocated list of the widgets, normally labels, for
   --  which this widget is the target of a mnemonic (see for example,
   --  Gtk.Label.Set_Mnemonic_Widget). The widgets in the list are not
   --  individually referenced. If you want to iterate through the list and
   --  perform actions involving callbacks that might destroy the widgets, you
   --  <emphasis>must</emphasis> call <literal>g_list_foreach (result,
   --  (GFunc)g_object_ref, NULL)</literal> first, and then unref all the
   --  widgets afterwards. mnemonic labels; free this list with g_list_free
   --  when you are done with it.
   --  Since: gtk+ 2.4

   procedure Map (Widget : not null access Gtk_Widget_Record);
   --  This function is only for use in widget implementations. Causes a
   --  widget to be mapped if it isn't already.

   function Mnemonic_Activate
      (Widget        : not null access Gtk_Widget_Record;
       Group_Cycling : Boolean) return Boolean;
   --  Emits the Gtk.Widget.Gtk_Widget::mnemonic-activate signal.
   --  The default handler for this signal activates the Widget if
   --  Group_Cycling is False, and just grabs the focus if Group_Cycling is
   --  True.
   --  "group_cycling": True if there are other widgets with the same mnemonic

   procedure Modify_Cursor
      (Widget    : not null access Gtk_Widget_Record;
       Primary   : Gdk.Color.Gdk_Color;
       Secondary : Gdk.Color.Gdk_Color);
   pragma Obsolescent (Modify_Cursor);
   --  Sets the cursor color to use in a widget, overriding the
   --  Gtk.Widget.Gtk_Widget:cursor-color and
   --  Gtk.Widget.Gtk_Widget:secondary-cursor-color style properties.
   --  All other style values are left untouched. See also
   --  gtk_widget_modify_style.
   --  Since: gtk+ 2.12
   --  Deprecated since None, 3.0. Use gtk_widget_override_cursor instead.
   --  "primary": the color to use for primary cursor (does not need to be
   --  allocated), or null to undo the effect of previous calls to of
   --  Gtk.Widget.Modify_Cursor.
   --  "secondary": the color to use for secondary cursor (does not need to be
   --  allocated), or null to undo the effect of previous calls to of
   --  Gtk.Widget.Modify_Cursor.

   procedure Modify_Font
      (Widget    : not null access Gtk_Widget_Record;
       Font_Desc : in out Pango_Font_Description);
   --  Sets the font to use for a widget.
   --  All other style values are left untouched. See also
   --  gtk_widget_modify_style.
   --  Deprecated:3.0: Use Gtk.Widget.Override_Font instead
   --  "font_desc": the font description to use, or null to undo the effect of
   --  previous calls to Gtk.Widget.Modify_Font

   procedure Override_Font
      (Widget    : not null access Gtk_Widget_Record;
       Font_Desc : in out Pango_Font_Description);
   --  Sets the font to use for a widget. All other style values are left
   --  untouched. See gtk_widget_override_color.
   --  Since: gtk+ 3.0
   --  "font_desc": the font descriptiong to use, or null to undo the effect
   --  of previous calls to Gtk.Widget.Override_Font

   procedure Override_Symbolic_Color
      (Widget : not null access Gtk_Widget_Record;
       Name   : UTF8_String;
       Color  : Gdk.RGBA.Gdk_RGBA);
   --  Sets a symbolic color for a widget.
   --  All other style values are left untouched. See gtk_widget_override_color
   --  for overriding the foreground or background color.
   --  Since: gtk+ 3.0
   --  "name": the name of the symbolic color to modify
   --  "color": the color to assign (does not need to be allocated), or null
   --  to undo the effect of previous calls to
   --  Gtk.Widget.Override_Symbolic_Color

   procedure Queue_Compute_Expand
      (Widget : not null access Gtk_Widget_Record);
   --  Mark Widget as needing to recompute its expand flags. Call this
   --  function when setting legacy expand child properties on the child of a
   --  container.
   --  See Gtk.Widget.Compute_Expand.

   procedure Queue_Draw (Widget : not null access Gtk_Widget_Record);
   --  Equivalent to calling Gtk.Widget.Queue_Draw_Area for the entire area of
   --  a widget.

   procedure Queue_Draw_Area
      (Widget : not null access Gtk_Widget_Record;
       X      : Gint;
       Y      : Gint;
       Width  : Gint;
       Height : Gint);
   --  Convenience function that calls Gtk.Widget.Queue_Draw_Region on the
   --  region created from the given coordinates.
   --  The region here is specified in widget coordinates. Widget coordinates
   --  are a bit odd; for historical reasons, they are defined as
   --  Widget->window coordinates for widgets that are not GTK_NO_WINDOW
   --  widgets, and are relative to Widget->allocation.x, Widget->allocation.y
   --  for widgets that are GTK_NO_WINDOW widgets.
   --  "x": x coordinate of upper-left corner of rectangle to redraw
   --  "y": y coordinate of upper-left corner of rectangle to redraw
   --  "width": width of region to draw
   --  "height": height of region to draw

   procedure Queue_Draw_Region
      (Widget : not null access Gtk_Widget_Record;
       Region : in out Cairo.Region.Cairo_Region);
   --  Invalidates the rectangular area of Widget defined by Region by calling
   --  gdk_window_invalidate_region on the widget's window and all its child
   --  windows. Once the main loop becomes idle (after the current batch of
   --  events has been processed, roughly), the window will receive expose
   --  events for the union of all regions that have been invalidated.
   --  Normally you would only use this function in widget implementations. You
   --  might also use it to schedule a redraw of a
   --  Gtk.Drawing_Area.Gtk_Drawing_Area or some portion thereof.
   --  Since: gtk+ 3.0
   --  "region": region to draw

   procedure Queue_Resize (Widget : not null access Gtk_Widget_Record);
   --  This function is only for use in widget implementations. Flags a widget
   --  to have its size renegotiated; should be called when a widget for some
   --  reason has a new size request. For example, when you change the text in
   --  a Gtk.Label.Gtk_Label, Gtk.Label.Gtk_Label queues a resize to ensure
   --  there's enough space for the new text.
   --   Note: You cannot call Gtk.Widget.Queue_Resize on a widget from inside
   --  its implementation of the GtkWidgetClass::size_allocate virtual method.
   --  Calls to Gtk.Widget.Queue_Resize from inside
   --  GtkWidgetClass::size_allocate will be silently ignored.

   procedure Queue_Resize_No_Redraw
      (Widget : not null access Gtk_Widget_Record);
   --  This function works like Gtk.Widget.Queue_Resize, except that the
   --  widget is not invalidated.
   --  Since: gtk+ 2.4

   procedure Realize (Widget : not null access Gtk_Widget_Record);
   --  Creates the GDK (windowing system) resources associated with a widget.
   --  For example, Widget->window will be created when a widget is realized.
   --  Normally realization happens implicitly; if you show a widget and all
   --  its parent containers, then the widget will be realized and mapped
   --  automatically.
   --  Realizing a widget requires all the widget's parent widgets to be
   --  realized; calling Gtk.Widget.Realize realizes the widget's parents in
   --  addition to Widget itself. If a widget is not yet inside a toplevel
   --  window when you realize it, bad things will happen.
   --  This function is primarily used in widget implementations, and isn't
   --  very useful otherwise. Many times when you think you might need it, a
   --  better approach is to connect to a signal that will be called after the
   --  widget is realized automatically, such as Gtk.Widget.Gtk_Widget::draw.
   --  Or simply g_signal_connect () to the Gtk.Widget.Gtk_Widget::realize
   --  signal.

   function Remove_Accelerator
      (Widget      : not null access Gtk_Widget_Record;
       Accel_Group : not null access Gtk.Accel_Group.Gtk_Accel_Group_Record'Class;
       Accel_Key   : Gtk.Accel_Group.Gtk_Accel_Key;
       Accel_Mods  : Gdk.Types.Gdk_Modifier_Type) return Boolean;
   --  Removes an accelerator from Widget, previously installed with
   --  Gtk.Widget.Add_Accelerator.
   --  "accel_group": accel group for this widget
   --  "accel_key": GDK keyval of the accelerator
   --  "accel_mods": modifier key combination of the accelerator

   procedure Remove_Mnemonic_Label
      (Widget : not null access Gtk_Widget_Record;
       Label  : not null access Gtk_Widget_Record'Class);
   --  Removes a widget from the list of mnemonic labels for this widget. (See
   --  Gtk.Widget.List_Mnemonic_Labels). The widget must have previously been
   --  added to the list with Gtk.Widget.Add_Mnemonic_Label.
   --  Since: gtk+ 2.4
   --  "label": a Gtk.Widget.Gtk_Widget that was previously set as a mnemnic
   --  label for Widget with Gtk.Widget.Add_Mnemonic_Label.

   function Render_Icon
      (Widget   : not null access Gtk_Widget_Record;
       Stock_Id : UTF8_String;
       Size     : Gtk.Enums.Gtk_Icon_Size;
       Detail   : UTF8_String := "") return Gdk.Pixbuf.Gdk_Pixbuf;
   pragma Obsolescent (Render_Icon);
   --  A convenience function that uses the theme settings for Widget to look
   --  up Stock_Id and render it to a pixbuf. Stock_Id should be a stock icon
   --  ID such as GTK_STOCK_OPEN or GTK_STOCK_OK. Size should be a size such as
   --  GTK_ICON_SIZE_MENU. Detail should be a string that identifies the widget
   --  or code doing the rendering, so that theme engines can special-case
   --  rendering for that widget or code.
   --  The pixels in the returned Gdk.Pixbuf.Gdk_Pixbuf are shared with the
   --  rest of the application and should not be modified. The pixbuf should be
   --  freed after use with g_object_unref.
   --  stock ID wasn't known
   --  Deprecated since 3.0, Use Gtk.Widget.Render_Icon_Pixbuf instead.
   --  "stock_id": a stock ID
   --  "size": a stock size. A size of (GtkIconSize)-1 means render at the
   --  size of the source and don't scale (if there are multiple source sizes,
   --  GTK+ picks one of the available sizes).
   --  "detail": render detail to pass to theme engine

   function Render_Icon_Pixbuf
      (Widget   : not null access Gtk_Widget_Record;
       Stock_Id : UTF8_String;
       Size     : Gtk.Enums.Gtk_Icon_Size) return Gdk.Pixbuf.Gdk_Pixbuf;
   --  A convenience function that uses the theme engine and style settings
   --  for Widget to look up Stock_Id and render it to a pixbuf. Stock_Id
   --  should be a stock icon ID such as GTK_STOCK_OPEN or GTK_STOCK_OK. Size
   --  should be a size such as GTK_ICON_SIZE_MENU.
   --  The pixels in the returned Gdk.Pixbuf.Gdk_Pixbuf are shared with the
   --  rest of the application and should not be modified. The pixbuf should be
   --  freed after use with g_object_unref.
   --  stock ID wasn't known
   --  Since: gtk+ 3.0
   --  "stock_id": a stock ID
   --  "size": a stock size. A size of (GtkIconSize)-1 means render at the
   --  size of the source and don't scale (if there are multiple source sizes,
   --  GTK+ picks one of the available sizes).

   procedure Reparent
      (Widget     : not null access Gtk_Widget_Record;
       New_Parent : not null access Gtk_Widget_Record'Class);
   --  Moves a widget from one Gtk.Container.Gtk_Container to another,
   --  handling reference count issues to avoid destroying the widget.
   --  "new_parent": a Gtk.Container.Gtk_Container to move the widget into

   procedure Reset_Rc_Styles (Widget : not null access Gtk_Widget_Record);
   --  Reset the styles of Widget and all descendents, so when they are looked
   --  up again, they get the correct values for the currently loaded RC file
   --  settings.
   --  This function is not useful for applications.
   --  Deprecated:3.0: Use Gtk.Style_Context.Gtk_Style_Context instead, and
   --  Gtk.Widget.Reset_Style

   procedure Reset_Style (Widget : not null access Gtk_Widget_Record);
   --  Updates the style context of Widget and all descendents by updating its
   --  widget path. Gtk.Container.Gtk_Container<!-- -->s may want to use this
   --  on a child when reordering it in a way that a different style might
   --  apply to it. See also Gtk.Container.Get_Path_For_Child.
   --  Since: gtk+ 3.0

   function Send_Expose
      (Widget : not null access Gtk_Widget_Record;
       Event  : Gdk.Event.Gdk_Event) return Gint;
   --  Very rarely-used function. This function is used to emit an expose
   --  event on a widget. This function is not normally used directly. The only
   --  time it is used is when propagating an expose event to a child NO_WINDOW
   --  widget, and that is normally done using Gtk.Container.Propagate_Draw.
   --  If you want to force an area of a window to be redrawn, use
   --  gdk_window_invalidate_rect or gdk_window_invalidate_region. To cause the
   --  redraw to be done immediately, follow that call with a call to
   --  gdk_window_process_updates.
   --  the event was handled)
   --  "event": a expose Gdk_Event

   function Send_Focus_Change
      (Widget : not null access Gtk_Widget_Record;
       Event  : Gdk.Event.Gdk_Event) return Boolean;
   --  Sends the focus change Event to Widget
   --  This function is not meant to be used by applications. The only time it
   --  should be used is when it is necessary for a Gtk.Widget.Gtk_Widget to
   --  assign focus to a widget that is semantically owned by the first widget
   --  even though it's not a direct child - for instance, a search entry in a
   --  floating window similar to the quick search in
   --  Gtk.Tree_View.Gtk_Tree_View.
   --  An example of its usage is:
   --  |[ GdkEvent *fevent = gdk_event_new (GDK_FOCUS_CHANGE);
   --  fevent->focus_change.type = GDK_FOCUS_CHANGE; fevent->focus_change.in =
   --  TRUE; fevent->focus_change.window = gtk_widget_get_window (widget); if
   --  (fevent->focus_change.window != NULL) g_object_ref
   --  (fevent->focus_change.window);
   --  gtk_widget_send_focus_change (widget, fevent);
   --  gdk_event_free (event); ]|
   --  if the event was handled, and False otherwise
   --  Since: gtk+ 2.20
   --  "event": a Gdk_Event of type GDK_FOCUS_CHANGE

   procedure Set_Accel_Path
      (Widget      : not null access Gtk_Widget_Record;
       Accel_Path  : UTF8_String := "";
       Accel_Group : access Gtk.Accel_Group.Gtk_Accel_Group_Record'Class);
   --  Given an accelerator group, Accel_Group, and an accelerator path,
   --  Accel_Path, sets up an accelerator in Accel_Group so whenever the key
   --  binding that is defined for Accel_Path is pressed, Widget will be
   --  activated. This removes any accelerators (for any accelerator group)
   --  installed by previous calls to Gtk.Widget.Set_Accel_Path. Associating
   --  accelerators with paths allows them to be modified by the user and the
   --  modifications to be saved for future use. (See gtk_accel_map_save.)
   --  This function is a low level function that would most likely be used by
   --  a menu creation system like Gtk.Uimanager.Gtk_Uimanager. If you use
   --  Gtk.Uimanager.Gtk_Uimanager, setting up accelerator paths will be done
   --  automatically.
   --  Even when you you aren't using Gtk.Uimanager.Gtk_Uimanager, if you only
   --  want to set up accelerators on menu items Gtk.Menu_Item.Set_Accel_Path
   --  provides a somewhat more convenient interface.
   --  Note that Accel_Path string will be stored in a Glib.GQuark. Therefore,
   --  if you pass a static string, you can save some memory by interning it
   --  first with g_intern_static_string.
   --  "accel_path": path used to look up the accelerator
   --  "accel_group": a Gtk.Accel_Group.Gtk_Accel_Group.

   procedure Set_Redraw_On_Allocate
      (Widget             : not null access Gtk_Widget_Record;
       Redraw_On_Allocate : Boolean);
   --  Sets whether the entire widget is queued for drawing when its size
   --  allocation changes. By default, this setting is True and the entire
   --  widget is redrawn on every size change. If your widget leaves the upper
   --  left unchanged when made bigger, turning this setting off will improve
   --  performance. Note that for NO_WINDOW widgets setting this flag to False
   --  turns off all allocation on resizing: the widget will not even redraw if
   --  its position changes; this is to allow containers that don't draw
   --  anything to avoid excess invalidations. If you set this flag on a
   --  NO_WINDOW widget that <emphasis>does</emphasis> draw on Widget->window,
   --  you are responsible for invalidating both the old and new allocation of
   --  the widget when the widget is moved and responsible for invalidating
   --  regions newly when the widget increases size.
   --  "redraw_on_allocate": if True, the entire widget will be redrawn when
   --  it is allocated to a new size. Otherwise, only the new portion of the
   --  widget will be redrawn.

   procedure Set_Tooltip_Markup
      (Widget : not null access Gtk_Widget_Record;
       Markup : UTF8_String := "");
   --  Sets Markup as the contents of the tooltip, which is marked up with the
   --  <link linkend="PangoMarkupFormat">Pango text markup language</link>.
   --  This function will take care of setting
   --  Gtk.Widget.Gtk_Widget:has-tooltip to True and of the default handler for
   --  the Gtk.Widget.Gtk_Widget::query-tooltip signal.
   --  See also the Gtk.Widget.Gtk_Widget:tooltip-markup property and
   --  Gtk.Tooltip.Set_Markup.
   --  Since: gtk+ 2.12
   --  "markup": the contents of the tooltip for Widget, or null

   procedure Set_Tooltip_Text
      (Widget : not null access Gtk_Widget_Record;
       Text   : UTF8_String);
   --  Sets Text as the contents of the tooltip. This function will take care
   --  of setting Gtk.Widget.Gtk_Widget:has-tooltip to True and of the default
   --  handler for the Gtk.Widget.Gtk_Widget::query-tooltip signal.
   --  See also the Gtk.Widget.Gtk_Widget:tooltip-text property and
   --  Gtk.Tooltip.Set_Text.
   --  Since: gtk+ 2.12
   --  "text": the contents of the tooltip for Widget

   procedure Shape_Combine_Region
      (Widget : not null access Gtk_Widget_Record;
       Region : in out Cairo.Region.Cairo_Region);
   --  Sets a shape for this widget's GDK window. This allows for transparent
   --  windows etc., see gdk_window_shape_combine_region for more information.
   --  Since: gtk+ 3.0
   --  "region": shape to be added, or null to remove an existing shape

   procedure Show (Widget : not null access Gtk_Widget_Record);
   --  Flags a widget to be displayed. Any widget that isn't shown will not
   --  appear on the screen. If you want to show all the widgets in a
   --  container, it's easier to call Gtk.Widget.Show_All on the container,
   --  instead of individually showing the widgets.
   --  Remember that you have to show the containers containing a widget, in
   --  addition to the widget itself, before it will appear onscreen.
   --  When a toplevel container is shown, it is immediately realized and
   --  mapped; other shown widgets are realized and mapped when their toplevel
   --  container is realized and mapped.

   procedure Show_All (Widget : not null access Gtk_Widget_Record);
   --  Recursively shows a widget, and any child widgets (if the widget is a
   --  container).

   procedure Show_Now (Widget : not null access Gtk_Widget_Record);
   --  Shows a widget. If the widget is an unmapped toplevel widget (i.e. a
   --  Gtk.Window.Gtk_Window that has not yet been shown), enter the main loop
   --  and wait for the window to actually be mapped. Be careful; because the
   --  main loop is running, anything can happen during this function.

   procedure Size_Allocate
      (Widget     : not null access Gtk_Widget_Record;
       Allocation : in out Gtk_Allocation);
   --  This function is only used by Gtk.Container.Gtk_Container subclasses,
   --  to assign a size and position to their child widgets.
   --  In this function, the allocation may be adjusted. It will be forced to a
   --  1x1 minimum size, and the adjust_size_allocation virtual method on the
   --  child will be used to adjust the allocation. Standard adjustments
   --  include removing the widget's margins, and applying the widget's
   --  Gtk.Widget.Gtk_Widget:halign and Gtk.Widget.Gtk_Widget:valign
   --  properties.
   --  "allocation": position and size to be allocated to Widget

   procedure Style_Attach (Widget : not null access Gtk_Widget_Record);
   pragma Obsolescent (Style_Attach);
   --  This function attaches the widget's Gtk.Style.Gtk_Style to the widget's
   --  Gdk.Window.Gdk_Window. It is a replacement for
   --  <programlisting> widget->style = gtk_style_attach (widget->style,
   --  widget->window); </programlisting>
   --  and should only ever be called in a derived widget's "realize"
   --  implementation which does not chain up to its parent class' "realize"
   --  implementation, because one of the parent classes (finally
   --  Gtk.Widget.Gtk_Widget) would attach the style itself.
   --  Since: gtk+ 2.20
   --  Deprecated since None, 3.0. This step is unnecessary with
   --  Gtk.Style_Context.Gtk_Style_Context.

   procedure Style_Get_Property
      (Widget        : not null access Gtk_Widget_Record;
       Property_Name : UTF8_String;
       Value         : in out Glib.Values.GValue);
   --  Gets the value of a style property of Widget.
   --  "property_name": the name of a style property
   --  "value": location to return the property value

   procedure Style_Get_Valist
      (Widget              : not null access Gtk_Widget_Record;
       First_Property_Name : UTF8_String;
       Var_Args            : va_list);
   --  Non-vararg variant of gtk_widget_style_get. Used primarily by language
   --  bindings.
   --  "first_property_name": the name of the first property to get
   --  "var_args": a <type>va_list</type> of pairs of property names and
   --  locations to return the property values, starting with the location for
   --  First_Property_Name.

   procedure Thaw_Child_Notify (Widget : not null access Gtk_Widget_Record);
   --  Reverts the effect of a previous call to
   --  Gtk.Widget.Freeze_Child_Notify. This causes all queued
   --  Gtk.Widget.Gtk_Widget::child-notify signals on Widget to be emitted.

   procedure Trigger_Tooltip_Query
      (Widget : not null access Gtk_Widget_Record);
   --  Triggers a tooltip query on the display where the toplevel of Widget is
   --  located. See Gtk.Tooltip.Trigger_Tooltip_Query for more information.
   --  Since: gtk+ 2.12

   procedure Unmap (Widget : not null access Gtk_Widget_Record);
   --  This function is only for use in widget implementations. Causes a
   --  widget to be unmapped if it's currently mapped.

   procedure Unparent (Widget : not null access Gtk_Widget_Record);
   --  This function is only for use in widget implementations. Should be
   --  called by implementations of the remove method on
   --  Gtk.Container.Gtk_Container, to dissociate a child from the container.

   procedure Unrealize (Widget : not null access Gtk_Widget_Record);
   --  This function is only useful in widget implementations. Causes a widget
   --  to be unrealized (frees all GDK resources associated with the widget,
   --  such as Widget->window).

   procedure Unset_State_Flags
      (Widget : not null access Gtk_Widget_Record;
       Flags  : Gtk.Enums.Gtk_State_Flags);
   --  This function is for use in widget implementations. Turns off flag
   --  values for the current widget state (insensitive, prelighted, etc.). See
   --  Gtk.Widget.Set_State_Flags.
   --  Since: gtk+ 3.0
   --  "flags": State flags to turn off

   ---------------
   -- Functions --
   ---------------

   function Get_Default_Direction return Gtk_Text_Direction;
   procedure Set_Default_Direction (Dir : Gtk_Text_Direction);
   --  Sets the default reading direction for widgets where the direction has
   --  not been explicitly set by Gtk.Widget.Set_Direction.
   --  "dir": the new default direction. This cannot be GTK_TEXT_DIR_NONE.

   function Get_Default_Style return Gtk.Style.Gtk_Style;
   --  Returns the default style used by all widgets initially.
   --  object is owned by GTK+ and should not be modified or freed.
   --  Deprecated:3.0: Use Gtk.Style_Context.Gtk_Style_Context instead, and
   --  gtk_css_provider_get_default to obtain a
   --  Gtk.Style_Provider.Gtk_Style_Provider with the default widget style
   --  information.

   procedure Pop_Composite_Child;
   --  Cancels the effect of a previous call to
   --  Gtk.Widget.Push_Composite_Child.

   procedure Push_Composite_Child;
   --  Makes all newly-created widgets as composite children until the
   --  corresponding Gtk.Widget.Pop_Composite_Child call.
   --  A composite child is a child that's an implementation detail of the
   --  container it's inside and should not be visible to people using the
   --  container. Composite children aren't treated differently by GTK (but see
   --  Gtk.Container.Foreach vs. Gtk.Container.Forall), but e.g. GUI builders
   --  might want to treat them in a different way.
   --  Here is a simple example: |[ gtk_widget_push_composite_child ();
   --  scrolled_window->hscrollbar = gtk_scrollbar_new
   --  (GTK_ORIENTATION_HORIZONTAL, hadjustment); gtk_widget_set_composite_name
   --  (scrolled_window->hscrollbar, "hscrollbar");
   --  gtk_widget_pop_composite_child (); gtk_widget_set_parent
   --  (scrolled_window->hscrollbar, GTK_WIDGET (scrolled_window));
   --  g_object_ref (scrolled_window->hscrollbar); ]|

   ---------------------------------------------
   -- Inherited subprograms (from interfaces) --
   ---------------------------------------------
   --  Methods inherited from the Buildable interface are not duplicated here
   --  since they are meant to be used by tools, mostly. If you need to call
   --  them, use an explicit cast through the "-" operator below.

   ----------------
   -- Interfaces --
   ----------------
   --  This class implements several interfaces. See Glib.Types
   --
   --  - "Buildable"

   package Implements_Buildable is new Glib.Types.Implements
     (Gtk.Buildable.Gtk_Buildable, Gtk_Widget_Record, Gtk_Widget);
   function "+"
     (Widget : access Gtk_Widget_Record'Class)
   return Gtk.Buildable.Gtk_Buildable
   renames Implements_Buildable.To_Interface;
   function "-"
     (Interf : Gtk.Buildable.Gtk_Buildable)
   return Gtk_Widget
   renames Implements_Buildable.To_Object;

   ----------------
   -- Properties --
   ----------------
   --  The following properties are defined for this widget. See
   --  Glib.Properties for more information on properties)
   --
   --  Name: App_Paintable_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Can_Default_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Can_Focus_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Composite_Child_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Double_Buffered_Property
   --  Type: Boolean
   --  Flags: read-write
   --  Whether the widget is double buffered.
   --
   --  Name: Events_Property
   --  Type: Gdk.Event_Mask
   --  Flags: read-write
   --
   --  Name: Expand_Property
   --  Type: Boolean
   --  Flags: read-write
   --  Whether to expand in both directions. Setting this sets both
   --  Gtk.Widget.Gtk_Widget:hexpand and Gtk.Widget.Gtk_Widget:vexpand
   --
   --  Name: Halign_Property
   --  Type: Align
   --  Flags: read-write
   --  How to distribute horizontal space if widget gets extra space, see
   --  Gtk_Align
   --
   --  Name: Has_Default_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Has_Focus_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Has_Tooltip_Property
   --  Type: Boolean
   --  Flags: read-write
   --  Enables or disables the emission of
   --  Gtk.Widget.Gtk_Widget::query-tooltip on Widget. A value of True
   --  indicates that Widget can have a tooltip, in this case the widget will
   --  be queried using Gtk.Widget.Gtk_Widget::query-tooltip to determine
   --  whether it will provide a tooltip or not.
   --  Note that setting this property to True for the first time will change
   --  the event masks of the GdkWindows of this widget to include leave-notify
   --  and motion-notify events. This cannot and will not be undone when the
   --  property is set to False again.
   --
   --  Name: Height_Request_Property
   --  Type: Gint
   --  Flags: read-write
   --
   --  Name: Hexpand_Property
   --  Type: Boolean
   --  Flags: read-write
   --  Whether to expand horizontally. See Gtk.Widget.Set_Hexpand.
   --
   --  Name: Hexpand_Set_Property
   --  Type: Boolean
   --  Flags: read-write
   --  Whether to use the Gtk.Widget.Gtk_Widget:hexpand property. See
   --  Gtk.Widget.Get_Hexpand_Set.
   --
   --  Name: Is_Focus_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Margin_Property
   --  Type: Gint
   --  Flags: read-write
   --  Sets all four sides' margin at once. If read, returns max margin on any
   --  side.
   --
   --  Name: Margin_Bottom_Property
   --  Type: Gint
   --  Flags: read-write
   --  Margin on bottom side of widget.
   --  This property adds margin outside of the widget's normal size request,
   --  the margin will be added in addition to the size from
   --  Gtk.Widget.Set_Size_Request for example.
   --
   --  Name: Margin_Left_Property
   --  Type: Gint
   --  Flags: read-write
   --  Margin on left side of widget.
   --  This property adds margin outside of the widget's normal size request,
   --  the margin will be added in addition to the size from
   --  Gtk.Widget.Set_Size_Request for example.
   --
   --  Name: Margin_Right_Property
   --  Type: Gint
   --  Flags: read-write
   --  Margin on right side of widget.
   --  This property adds margin outside of the widget's normal size request,
   --  the margin will be added in addition to the size from
   --  Gtk.Widget.Set_Size_Request for example.
   --
   --  Name: Margin_Top_Property
   --  Type: Gint
   --  Flags: read-write
   --  Margin on top side of widget.
   --  This property adds margin outside of the widget's normal size request,
   --  the margin will be added in addition to the size from
   --  Gtk.Widget.Set_Size_Request for example.
   --
   --  Name: Name_Property
   --  Type: UTF8_String
   --  Flags: read-write
   --
   --  Name: No_Show_All_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Parent_Property
   --  Type: Gtk.Container.Gtk_Container
   --  Flags: read-write
   --
   --  Name: Receives_Default_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Sensitive_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Style_Property
   --  Type: Gtk.Style.Gtk_Style
   --  Flags: read-write
   --
   --  Name: Tooltip_Markup_Property
   --  Type: UTF8_String
   --  Flags: read-write
   --  Sets the text of tooltip to be the given string, which is marked up
   --  with the <link linkend="PangoMarkupFormat">Pango text markup
   --  language</link>. Also see Gtk.Tooltip.Set_Markup.
   --  This is a convenience property which will take care of getting the
   --  tooltip shown if the given string is not null:
   --  Gtk.Widget.Gtk_Widget:has-tooltip will automatically be set to True and
   --  there will be taken care of Gtk.Widget.Gtk_Widget::query-tooltip in the
   --  default signal handler.
   --
   --  Name: Tooltip_Text_Property
   --  Type: UTF8_String
   --  Flags: read-write
   --  Sets the text of tooltip to be the given string.
   --  Also see Gtk.Tooltip.Set_Text.
   --  This is a convenience property which will take care of getting the
   --  tooltip shown if the given string is not null:
   --  Gtk.Widget.Gtk_Widget:has-tooltip will automatically be set to True and
   --  there will be taken care of Gtk.Widget.Gtk_Widget::query-tooltip in the
   --  default signal handler.
   --
   --  Name: Valign_Property
   --  Type: Align
   --  Flags: read-write
   --  How to distribute vertical space if widget gets extra space, see
   --  Gtk_Align
   --
   --  Name: Vexpand_Property
   --  Type: Boolean
   --  Flags: read-write
   --  Whether to expand vertically. See Gtk.Widget.Set_Vexpand.
   --
   --  Name: Vexpand_Set_Property
   --  Type: Boolean
   --  Flags: read-write
   --  Whether to use the Gtk.Widget.Gtk_Widget:vexpand property. See
   --  Gtk.Widget.Get_Vexpand_Set.
   --
   --  Name: Visible_Property
   --  Type: Boolean
   --  Flags: read-write
   --
   --  Name: Width_Request_Property
   --  Type: Gint
   --  Flags: read-write
   --
   --  Name: Window_Property
   --  Type: Gdk.Window
   --  Flags: read-write
   --  The widget's window if it is realized, null otherwise.

   App_Paintable_Property : constant Glib.Properties.Property_Boolean;
   Can_Default_Property : constant Glib.Properties.Property_Boolean;
   Can_Focus_Property : constant Glib.Properties.Property_Boolean;
   Composite_Child_Property : constant Glib.Properties.Property_Boolean;
   Double_Buffered_Property : constant Glib.Properties.Property_Boolean;
   Events_Property : constant Glib.Properties.Property_Boxed;
   Expand_Property : constant Glib.Properties.Property_Boolean;
   Halign_Property : constant Glib.Properties.Property_Boxed;
   Has_Default_Property : constant Glib.Properties.Property_Boolean;
   Has_Focus_Property : constant Glib.Properties.Property_Boolean;
   Has_Tooltip_Property : constant Glib.Properties.Property_Boolean;
   Height_Request_Property : constant Glib.Properties.Property_Int;
   Hexpand_Property : constant Glib.Properties.Property_Boolean;
   Hexpand_Set_Property : constant Glib.Properties.Property_Boolean;
   Is_Focus_Property : constant Glib.Properties.Property_Boolean;
   Margin_Property : constant Glib.Properties.Property_Int;
   Margin_Bottom_Property : constant Glib.Properties.Property_Int;
   Margin_Left_Property : constant Glib.Properties.Property_Int;
   Margin_Right_Property : constant Glib.Properties.Property_Int;
   Margin_Top_Property : constant Glib.Properties.Property_Int;
   Name_Property : constant Glib.Properties.Property_String;
   No_Show_All_Property : constant Glib.Properties.Property_Boolean;
   Parent_Property : constant Glib.Properties.Property_Object;
   Receives_Default_Property : constant Glib.Properties.Property_Boolean;
   Sensitive_Property : constant Glib.Properties.Property_Boolean;
   Style_Property : constant Glib.Properties.Property_Object;
   Tooltip_Markup_Property : constant Glib.Properties.Property_String;
   Tooltip_Text_Property : constant Glib.Properties.Property_String;
   Valign_Property : constant Glib.Properties.Property_Boxed;
   Vexpand_Property : constant Glib.Properties.Property_Boolean;
   Vexpand_Set_Property : constant Glib.Properties.Property_Boolean;
   Visible_Property : constant Glib.Properties.Property_Boolean;
   Width_Request_Property : constant Glib.Properties.Property_Int;
   Window_Property : constant Glib.Properties.Property_Boxed;

   -------------
   -- Signals --
   -------------
   --  The following new signals are defined for this widget:
   --
   --  "accel-closures-changed"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --
   --  "button-press-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Button) return Boolean;
   --    --  "event": the Gdk_Event_Button which triggered this signal.
   --  The ::button-press-event signal will be emitted when a button
   --  (typically from a mouse) is pressed.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_BUTTON_PRESS_MASK mask.
   --  This signal will be sent to the grab widget if there is one.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "button-release-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Button) return Boolean;
   --    --  "event": the Gdk_Event_Button which triggered this signal.
   --  The ::button-release-event signal will be emitted when a button
   --  (typically from a mouse) is released.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_BUTTON_RELEASE_MASK mask.
   --  This signal will be sent to the grab widget if there is one.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "can-activate-accel"
   --     function Handler
   --       (Self      : access Gtk_Widget_Record'Class;
   --        Signal_Id : Guint) return Boolean;
   --    --  "signal_id": the ID of a signal installed on Widget
   --  Determines whether an accelerator that activates the signal identified
   --  by Signal_Id can currently be activated. This signal is present to allow
   --  applications and derived widgets to override the default
   --  Gtk.Widget.Gtk_Widget handling for determining whether an accelerator
   --  can be activated.
   --  Returns True if the signal can be activated.
   --
   --  "child-notify"
   --     procedure Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Pspec : GObject.Param_Spec);
   --    --  "pspec": the GParam_Spec of the changed child property
   --  The ::child-notify signal is emitted for each <link
   --  linkend="child-properties">child property</link> that has changed on an
   --  object. The signal's detail holds the property name.
   --
   --  "composited-changed"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --  The ::composited-changed signal is emitted when the composited status
   --  of Widget<!-- -->s screen changes. See Gdk.Screen.Is_Composited.
   --
   --  "configure-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Configure) return Boolean;
   --    --  "event": the Gdk_Event_Configure which triggered this signal.
   --  The ::configure-event signal will be emitted when the size, position or
   --  stacking of the Widget's window has changed.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_STRUCTURE_MASK mask. GDK will enable this
   --  mask automatically for all new windows.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "damage-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Expose) return Boolean;
   --    --  "event": the Gdk_Event_Expose event
   --  Emitted when a redirected window belonging to Widget gets drawn into.
   --  The region/area members of the event shows what area of the redirected
   --  drawable was drawn into.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "delete-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event) return Boolean;
   --    --  "event": the event which triggered this signal
   --  The ::delete-event signal is emitted if a user requests that a toplevel
   --  window is closed. The default handler for this signal destroys the
   --  window. Connecting Gtk.Widget.Hide_On_Delete to this signal will cause
   --  the window to be hidden instead, so that it can later be shown again
   --  without reconstructing it.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "destroy"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --  Signals that all holders of a reference to the widget should release
   --  the reference that they hold. May result in finalization of the widget
   --  if all references are released.
   --
   --  "destroy-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event) return Boolean;
   --    --  "event": the event which triggered this signal
   --  The ::destroy-event signal is emitted when a Gdk.Window.Gdk_Window is
   --  destroyed. You rarely get this signal, because most widgets disconnect
   --  themselves from their window before they destroy it, so no widget owns
   --  the window at destroy time.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_STRUCTURE_MASK mask. GDK will enable this
   --  mask automatically for all new windows.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "direction-changed"
   --     procedure Handler
   --       (Self               : access Gtk_Widget_Record'Class;
   --        Previous_Direction : Text_Direction);
   --    --  "previous_direction": the previous text direction of Widget
   --  The ::direction-changed signal is emitted when the text direction of a
   --  widget changes.
   --
   --  "drag-begin"
   --     procedure Handler
   --       (Self         : access Gtk_Widget_Record'Class;
   --        Drag_Context : Gdk.Drag_Context);
   --    --  "drag_context": the drag context
   --  The ::drag-begin signal is emitted on the drag source when a drag is
   --  started. A typical reason to connect to this signal is to set up a
   --  custom drag icon with gtk_drag_source_set_icon.
   --  Note that some widgets set up a drag icon in the default handler of this
   --  signal, so you may have to use g_signal_connect_after to override what
   --  the default handler did.
   --
   --  "drag-data-delete"
   --     procedure Handler
   --       (Self         : access Gtk_Widget_Record'Class;
   --        Drag_Context : Gdk.Drag_Context);
   --    --  "drag_context": the drag context
   --  The ::drag-data-delete signal is emitted on the drag source when a drag
   --  with the action Gdk.Drag_Contexts.Action_Move is successfully completed.
   --  The signal handler is responsible for deleting the data that has been
   --  dropped. What "delete" means depends on the context of the drag
   --  operation.
   --
   --  "drag-data-get"
   --     procedure Handler
   --       (Self         : access Gtk_Widget_Record'Class;
   --        Drag_Context : Gdk.Drag_Context;
   --        Data         : Gtk.Selection_Data.Gtk_Selection_Data;
   --        Info         : Guint;
   --        Time         : Guint);
   --    --  "drag_context": the drag context
   --    --  "data": the Gtk.Selection_Data.Gtk_Selection_Data to be filled with the
   --    --  dragged data
   --    --  "info": the info that has been registered with the target in the
   --    --  Gtk.Target_List.Gtk_Target_List
   --    --  "time": the timestamp at which the data was requested
   --  The ::drag-data-get signal is emitted on the drag source when the drop
   --  site requests the data which is dragged. It is the responsibility of the
   --  signal handler to fill Data with the data in the format which is
   --  indicated by Info. See gtk_selection_data_set and
   --  gtk_selection_data_set_text.
   --
   --  "drag-data-received"
   --     procedure Handler
   --       (Self         : access Gtk_Widget_Record'Class;
   --        Drag_Context : Gdk.Drag_Context;
   --        X            : Gint;
   --        Y            : Gint;
   --        Data         : Gtk.Selection_Data.Gtk_Selection_Data;
   --        Info         : Guint;
   --        Time         : Guint);
   --    --  "drag_context": the drag context
   --    --  "x": where the drop happened
   --    --  "y": where the drop happened
   --    --  "data": the received data
   --    --  "info": the info that has been registered with the target in the
   --    --  Gtk.Target_List.Gtk_Target_List
   --    --  "time": the timestamp at which the data was received
   --  The ::drag-data-received signal is emitted on the drop site when the
   --  dragged data has been received. If the data was received in order to
   --  determine whether the drop will be accepted, the handler is expected to
   --  call gdk_drag_status and <emphasis>not</emphasis> finish the drag. If
   --  the data was received in response to a Gtk.Widget.Gtk_Widget::drag-drop
   --  signal (and this is the last target to be received), the handler for
   --  this signal is expected to process the received data and then call
   --  gtk_drag_finish, setting the Success parameter depending on whether the
   --  data was processed successfully.
   --  The handler may inspect and modify Drag_Context->action before calling
   --  gtk_drag_finish, e.g. to implement Gdk.Drag_Contexts.Action_Ask as shown
   --  in the following example: |[ void drag_data_received (GtkWidget *widget,
   --  GdkDragContext *drag_context, gint x, gint y, GtkSelectionData *data,
   --  guint info, guint time) { if ((data->length >= 0) && (data->format ==
   --  8)) { if (drag_context->action == GDK_ACTION_ASK) { GtkWidget *dialog;
   --  gint response;
   --  dialog = gtk_message_dialog_new (NULL, GTK_DIALOG_MODAL |
   --  GTK_DIALOG_DESTROY_WITH_PARENT, GTK_MESSAGE_INFO, GTK_BUTTONS_YES_NO,
   --  "Move the data ?\n"); response = gtk_dialog_run (GTK_DIALOG (dialog));
   --  gtk_widget_destroy (dialog);
   --  if (response == GTK_RESPONSE_YES) drag_context->action =
   --  GDK_ACTION_MOVE; else drag_context->action = GDK_ACTION_COPY; }
   --  gtk_drag_finish (drag_context, TRUE, FALSE, time); return; }
   --  gtk_drag_finish (drag_context, FALSE, FALSE, time); } ]|
   --
   --  "drag-drop"
   --     function Handler
   --       (Self         : access Gtk_Widget_Record'Class;
   --        Drag_Context : Gdk.Drag_Context;
   --        X            : Gint;
   --        Y            : Gint;
   --        Time         : Guint) return Boolean;
   --    --  "drag_context": the drag context
   --    --  "x": the x coordinate of the current cursor position
   --    --  "y": the y coordinate of the current cursor position
   --    --  "time": the timestamp of the motion event
   --  The ::drag-drop signal is emitted on the drop site when the user drops
   --  the data onto the widget. The signal handler must determine whether the
   --  cursor position is in a drop zone or not. If it is not in a drop zone,
   --  it returns False and no further processing is necessary. Otherwise, the
   --  handler returns True. In this case, the handler must ensure that
   --  gtk_drag_finish is called to let the source know that the drop is done.
   --  The call to gtk_drag_finish can be done either directly or in a
   --  Gtk.Widget.Gtk_Widget::drag-data-received handler which gets triggered
   --  by calling Gtk.Widget.Drag_Get_Data to receive the data for one or more
   --  of the supported targets.
   --  Returns whether the cursor position is in a drop zone
   --
   --  "drag-end"
   --     procedure Handler
   --       (Self         : access Gtk_Widget_Record'Class;
   --        Drag_Context : Gdk.Drag_Context);
   --    --  "drag_context": the drag context
   --  The ::drag-end signal is emitted on the drag source when a drag is
   --  finished. A typical reason to connect to this signal is to undo things
   --  done in Gtk.Widget.Gtk_Widget::drag-begin.
   --
   --  "drag-failed"
   --     function Handler
   --       (Self         : access Gtk_Widget_Record'Class;
   --        Drag_Context : Gdk.Drag_Context;
   --        Result       : Drag_Result) return Boolean;
   --    --  "drag_context": the drag context
   --    --  "result": the result of the drag operation
   --  The ::drag-failed signal is emitted on the drag source when a drag has
   --  failed. The signal handler may hook custom code to handle a failed DND
   --  operation based on the type of error, it returns True is the failure has
   --  been already handled (not showing the default "drag operation failed"
   --  animation), otherwise it returns False.
   --  Returns True if the failed drag operation has been already handled.
   --
   --  "drag-leave"
   --     procedure Handler
   --       (Self         : access Gtk_Widget_Record'Class;
   --        Drag_Context : Gdk.Drag_Context;
   --        Time         : Guint);
   --    --  "drag_context": the drag context
   --    --  "time": the timestamp of the motion event
   --  The ::drag-leave signal is emitted on the drop site when the cursor
   --  leaves the widget. A typical reason to connect to this signal is to undo
   --  things done in Gtk.Widget.Gtk_Widget::drag-motion, e.g. undo
   --  highlighting with Gtk.Widget.Drag_Unhighlight
   --
   --  "drag-motion"
   --     function Handler
   --       (Self         : access Gtk_Widget_Record'Class;
   --        Drag_Context : Gdk.Drag_Context;
   --        X            : Gint;
   --        Y            : Gint;
   --        Time         : Guint) return Boolean;
   --    --  "drag_context": the drag context
   --    --  "x": the x coordinate of the current cursor position
   --    --  "y": the y coordinate of the current cursor position
   --    --  "time": the timestamp of the motion event
   --  The drag-motion signal is emitted on the drop site when the user moves
   --  the cursor over the widget during a drag. The signal handler must
   --  determine whether the cursor position is in a drop zone or not. If it is
   --  not in a drop zone, it returns False and no further processing is
   --  necessary. Otherwise, the handler returns True. In this case, the
   --  handler is responsible for providing the necessary information for
   --  displaying feedback to the user, by calling gdk_drag_status.
   --  If the decision whether the drop will be accepted or rejected can't be
   --  made based solely on the cursor position and the type of the data, the
   --  handler may inspect the dragged data by calling Gtk.Widget.Drag_Get_Data
   --  and defer the gdk_drag_status call to the
   --  Gtk.Widget.Gtk_Widget::drag-data-received handler. Note that you cannot
   --  not pass GTK_DEST_DEFAULT_DROP, GTK_DEST_DEFAULT_MOTION or
   --  GTK_DEST_DEFAULT_ALL to Gtk.Widget.Drag_Dest_Set when using the
   --  drag-motion signal that way.
   --  Also note that there is no drag-enter signal. The drag receiver has to
   --  keep track of whether he has received any drag-motion signals since the
   --  last Gtk.Widget.Gtk_Widget::drag-leave and if not, treat the drag-motion
   --  signal as an "enter" signal. Upon an "enter", the handler will typically
   --  highlight the drop site with Gtk.Widget.Drag_Highlight. |[ static void
   --  drag_motion (GtkWidget *widget, GdkDragContext *context, gint x, gint y,
   --  guint time) { GdkAtom target;
   --  PrivateData *private_data = GET_PRIVATE_DATA (widget);
   --  if (!private_data->drag_highlight) { private_data->drag_highlight = 1;
   --  gtk_drag_highlight (widget); }
   --  target = gtk_drag_dest_find_target (widget, context, NULL); if (target
   --  == GDK_NONE) gdk_drag_status (context, 0, time); else {
   --  private_data->pending_status = context->suggested_action;
   --  gtk_drag_get_data (widget, context, target, time); }
   --  return TRUE; }
   --  static void drag_data_received (GtkWidget *widget, GdkDragContext
   --  *context, gint x, gint y, GtkSelectionData *selection_data, guint info,
   --  guint time) { PrivateData *private_data = GET_PRIVATE_DATA (widget);
   --  if (private_data->suggested_action) { private_data->suggested_action =
   --  0;
   --  /&ast; We are getting this data due to a request in drag_motion, *
   --  rather than due to a request in drag_drop, so we are just * supposed to
   --  call gdk_drag_status (), not actually paste in * the data. &ast;/ str =
   --  gtk_selection_data_get_text (selection_data); if (!data_is_acceptable
   --  (str)) gdk_drag_status (context, 0, time); else gdk_drag_status
   --  (context, private_data->suggested_action, time); } else { /&ast; accept
   --  the drop &ast;/ } } ]|
   --  Returns whether the cursor position is in a drop zone
   --
   --  "draw"
   --     function Handler
   --       (Self : access Gtk_Widget_Record'Class;
   --        Cr   : cairo.Context) return Boolean;
   --    --  "cr": the cairo context to draw to
   --  This signal is emitted when a widget is supposed to render itself. The
   --  Widget's top left corner must be painted at the origin of the passed in
   --  context and be sized to the values returned by
   --  Gtk.Widget.Get_Allocated_Width and Gtk.Widget.Get_Allocated_Height.
   --  Signal handlers connected to this signal can modify the cairo context
   --  passed as Cr in any way they like and don't need to restore it. The
   --  signal emission takes care of calling cairo_save before and
   --  cairo_restore after invoking the handler.
   --
   --  "enter-notify-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Crossing) return Boolean;
   --    --  "event": the Gdk_Event_Crossing which triggered this signal.
   --  The ::enter-notify-event will be emitted when the pointer enters the
   --  Widget's window.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_ENTER_NOTIFY_MASK mask.
   --  This signal will be sent to the grab widget if there is one.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event) return Boolean;
   --    --  "event": the Gdk_Event which triggered this signal
   --  The GTK+ main loop will emit three signals for each GDK event delivered
   --  to a widget: one generic ::event signal, another, more specific, signal
   --  that matches the type of event delivered (e.g.
   --  Gtk.Widget.Gtk_Widget::key-press-event) and finally a generic
   --  Gtk.Widget.Gtk_Widget::event-after signal.
   --  and to cancel the emission of the second specific ::event signal. False
   --  to propagate the event further and to allow the emission of the second
   --  signal. The ::event-after signal is emitted regardless of the return
   --  value.
   --  Returns True to stop other handlers from being invoked for the event
   --
   --  "event-after"
   --     procedure Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event);
   --    --  "event": the Gdk_Event which triggered this signal
   --  After the emission of the Gtk.Widget.Gtk_Widget::event signal and
   --  (optionally) the second more specific signal, ::event-after will be
   --  emitted regardless of the previous two signals handlers return values.
   --
   --  "focus"
   --     function Handler
   --       (Self    : access Gtk_Widget_Record'Class;
   --        Returns : Gtk.Enums.Gtk_Direction_Type) return Boolean;
   --    --  "returns": True to stop other handlers from being invoked for the
   --    --  event. False to propagate the event further.
   -- 
   --  Returns True to stop other handlers from being invoked for the event.
   --  False to propagate the event further.
   --
   --  "focus-in-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Focus) return Boolean;
   --    --  "event": the Gdk_Event_Focus which triggered this signal.
   --  The ::focus-in-event signal will be emitted when the keyboard focus
   --  enters the Widget's window.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_FOCUS_CHANGE_MASK mask.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "focus-out-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Focus) return Boolean;
   --    --  "event": the Gdk_Event_Focus which triggered this signal.
   --  The ::focus-out-event signal will be emitted when the keyboard focus
   --  leaves the Widget's window.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_FOCUS_CHANGE_MASK mask.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "grab-broken-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Grab_Broken) return Boolean;
   --    --  "event": the Gdk_Event_Grab_Broken event
   --  Emitted when a pointer or keyboard grab on a window belonging to Widget
   --  gets broken.
   --  On X11, this happens when the grab window becomes unviewable (i.e. it or
   --  one of its ancestors is unmapped), or if the same application grabs the
   --  pointer or keyboard again.
   --  the event. False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for
   --
   --  "grab-focus"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --
   --  "grab-notify"
   --     procedure Handler
   --       (Self        : access Gtk_Widget_Record'Class;
   --        Was_Grabbed : Boolean);
   --    --  "was_grabbed": False if the widget becomes shadowed, True if it becomes
   --    --  unshadowed
   --  The ::grab-notify signal is emitted when a widget becomes shadowed by a
   --  GTK+ grab (not a pointer or keyboard grab) on another widget, or when it
   --  becomes unshadowed due to a grab being removed.
   --  A widget is shadowed by a Gtk.Widget.Grab_Add when the topmost grab
   --  widget in the grab stack of its window group is not its ancestor.
   --
   --  "hide"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --
   --  "hierarchy-changed"
   --     procedure Handler
   --       (Self              : access Gtk_Widget_Record'Class;
   --        Previous_Toplevel : access Gtk_Widget_Record'Class);
   --    --  "previous_toplevel": the previous toplevel ancestor, or null if the
   --    --  widget was previously unanchored
   --  The ::hierarchy-changed signal is emitted when the anchored state of a
   --  widget changes. A widget is <firstterm>anchored</firstterm> when its
   --  toplevel ancestor is a Gtk.Window.Gtk_Window. This signal is emitted
   --  when a widget changes from un-anchored to anchored or vice-versa.
   --
   --  "key-press-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Key) return Boolean;
   --    --  "event": the Gdk_Event_Key which triggered this signal.
   --  The ::key-press-event signal is emitted when a key is pressed. The
   --  signal emission will reoccur at the key-repeat rate when the key is kept
   --  pressed.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_KEY_PRESS_MASK mask.
   --  This signal will be sent to the grab widget if there is one.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "key-release-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Key) return Boolean;
   --    --  "event": the Gdk_Event_Key which triggered this signal.
   --  The ::key-release-event signal is emitted when a key is released.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_KEY_RELEASE_MASK mask.
   --  This signal will be sent to the grab widget if there is one.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "keynav-failed"
   --     function Handler
   --       (Self      : access Gtk_Widget_Record'Class;
   --        Direction : Gtk.Enums.Gtk_Direction_Type) return Boolean;
   --    --  "direction": the direction of movement
   --  Gets emitted if keyboard navigation fails. See Gtk.Widget.Keynav_Failed
   --  for details.
   --  if the emitting widget should try to handle the keyboard navigation
   --  attempt in its parent container(s).
   --  Returns True if stopping keyboard navigation is fine, False
   --
   --  "leave-notify-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Crossing) return Boolean;
   --    --  "event": the Gdk_Event_Crossing which triggered this signal.
   --  The ::leave-notify-event will be emitted when the pointer leaves the
   --  Widget's window.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_LEAVE_NOTIFY_MASK mask.
   --  This signal will be sent to the grab widget if there is one.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "map"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --
   --  "map-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Any) return Boolean;
   --    --  "event": the Gdk_Event_Any which triggered this signal.
   --  The ::map-event signal will be emitted when the Widget's window is
   --  mapped. A window is mapped when it becomes visible on the screen.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_STRUCTURE_MASK mask. GDK will enable this
   --  mask automatically for all new windows.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "mnemonic-activate"
   --     function Handler
   --       (Self   : access Gtk_Widget_Record'Class;
   --        Object : Boolean) return Boolean;
   --
   --  "motion-notify-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Motion) return Boolean;
   --    --  "event": the Gdk_Event_Motion which triggered this signal.
   --  The ::motion-notify-event signal is emitted when the pointer moves over
   --  the widget's Gdk.Window.Gdk_Window.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_POINTER_MOTION_MASK mask.
   --  This signal will be sent to the grab widget if there is one.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "move-focus"
   --     procedure Handler
   --       (Self   : access Gtk_Widget_Record'Class;
   --        Object : Gtk.Enums.Gtk_Direction_Type);
   --
   --  "parent-set"
   --     procedure Handler
   --       (Self       : access Gtk_Widget_Record'Class;
   --        Old_Parent : access Gtk_Widget_Record'Class);
   --    --  "old_parent": the previous parent, or null if the widget just got its
   --    --  initial parent.
   --  The ::parent-set signal is emitted when a new parent has been set on a
   --  widget.
   --
   --  "popup-menu"
   --     function Handler
   --       (Self : access Gtk_Widget_Record'Class) return Boolean;
   --  This signal gets emitted whenever a widget should pop up a context
   --  menu. This usually happens through the standard key binding mechanism;
   --  by pressing a certain key while a widget is focused, the user can cause
   --  the widget to pop up a menu. For example, the Gtk.GEntry.Gtk_Entry
   --  widget creates a menu with clipboard commands. See <xref
   --  linkend="checklist-popup-menu"/> for an example of how to use this
   --  signal.
   --  Returns True if a menu was activated
   --
   --  "property-notify-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Property) return Boolean;
   --    --  "event": the Gdk_Event_Property which triggered this signal.
   --  The ::property-notify-event signal will be emitted when a property on
   --  the Widget's window has been changed or deleted.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_PROPERTY_CHANGE_MASK mask.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "proximity-in-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Proximity) return Boolean;
   --    --  "event": the Gdk_Event_Proximity which triggered this signal.
   --  To receive this signal the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_PROXIMITY_IN_MASK mask.
   --  This signal will be sent to the grab widget if there is one.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "proximity-out-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Proximity) return Boolean;
   --    --  "event": the Gdk_Event_Proximity which triggered this signal.
   --  To receive this signal the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_PROXIMITY_OUT_MASK mask.
   --  This signal will be sent to the grab widget if there is one.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "query-tooltip"
   --     function Handler
   --       (Self          : access Gtk_Widget_Record'Class;
   --        X             : Gint;
   --        Y             : Gint;
   --        Keyboard_Mode : Boolean;
   --        Tooltip       : not null access Gtk.Tooltip.Gtk_Tooltip_Record'Class)
   --        return Boolean;
   --    --  "x": the x coordinate of the cursor position where the request has been
   --    --  emitted, relative to Widget's left side
   --    --  "y": the y coordinate of the cursor position where the request has been
   --    --  emitted, relative to Widget's top
   --    --  "keyboard_mode": True if the tooltip was trigged using the keyboard
   --    --  "tooltip": a Gtk.Tooltip.Gtk_Tooltip
   --  Emitted when Gtk.Widget.Gtk_Widget:has-tooltip is True and the
   --  Gtk.Settings.Gtk_Settings:gtk-tooltip-timeout has expired with the
   --  cursor hovering "above" Widget; or emitted when Widget got focus in
   --  keyboard mode.
   --  Using the given coordinates, the signal handler should determine whether
   --  a tooltip should be shown for Widget. If this is the case True should be
   --  returned, False otherwise. Note that if Keyboard_Mode is True, the
   --  values of X and Y are undefined and should not be used.
   --  The signal handler is free to manipulate Tooltip with the therefore
   --  destined function calls.
   --  Returns True if Tooltip should be shown right now, False otherwise.
   --
   --  "realize"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --
   --  "screen-changed"
   --     procedure Handler
   --       (Self            : access Gtk_Widget_Record'Class;
   --        Previous_Screen : Gdk.Screen);
   --    --  "previous_screen": the previous screen, or null if the widget was not
   --    --  associated with a screen before
   --  The ::screen-changed signal gets emitted when the screen of a widget
   --  has changed.
   --
   --  "scroll-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Scroll) return Boolean;
   --    --  "event": the Gdk_Event_Scroll which triggered this signal.
   --  The ::scroll-event signal is emitted when a button in the 4 to 7 range
   --  is pressed. Wheel mice are usually configured to generate button press
   --  events for buttons 4 and 5 when the wheel is turned.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_BUTTON_PRESS_MASK mask.
   --  This signal will be sent to the grab widget if there is one.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "selection-clear-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Selection) return Boolean;
   --    --  "event": the Gdk_Event_Selection which triggered this signal.
   --  The ::selection-clear-event signal will be emitted when the the
   --  Widget's window has lost ownership of a selection.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "selection-get"
   --     procedure Handler
   --       (Self   : access Gtk_Widget_Record'Class;
   --        Object : Gtk.Selection_Data.Gtk_Selection_Data;
   --        P0     : Guint;
   --        P1     : Guint);
   --
   --  "selection-notify-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Selection) return Boolean;
   -- 
   --  Returns True to stop other handlers from being invoked for the event.
   --  False to propagate the event further.
   --
   --  "selection-received"
   --     procedure Handler
   --       (Self   : access Gtk_Widget_Record'Class;
   --        Object : Gtk.Selection_Data.Gtk_Selection_Data;
   --        P0     : Guint);
   --
   --  "selection-request-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Selection) return Boolean;
   --    --  "event": the Gdk_Event_Selection which triggered this signal.
   --  The ::selection-request-event signal will be emitted when another
   --  client requests ownership of the selection owned by the Widget's window.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "show"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --
   --  "show-help"
   --     function Handler
   --       (Self   : access Gtk_Widget_Record'Class;
   --        Object : Widget_Help_Type) return Boolean;
   --
   --  "size-allocate"
   --     procedure Handler
   --       (Self   : access Gtk_Widget_Record'Class;
   --        Object : cairo.Rectangle_Int);
   --
   --  "state-changed"
   --     procedure Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        State : Gtk.Enums.Gtk_State_Type);
   --    --  "state": the previous state
   --  The ::state-changed signal is emitted when the widget state changes.
   --  See Gtk.Widget.Get_State.
   --
   --  "state-flags-changed"
   --     procedure Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Flags : Gtk.Enums.Gtk_State_Flags);
   --    --  "flags": The previous state flags.
   --  The ::state-flags-changed signal is emitted when the widget state
   --  changes, see Gtk.Widget.Get_State_Flags.
   --
   --  "style-set"
   --     procedure Handler
   --       (Self           : access Gtk_Widget_Record'Class;
   --        Previous_Style : access Gtk.Style.Gtk_Style_Record'Class);
   --    --  "previous_style": the previous style, or null if the widget just got
   --    --  its initial style
   --  The ::style-set signal is emitted when a new style has been set on a
   --  widget. Note that style-modifying functions like gtk_widget_modify_base
   --  also cause this signal to be emitted.
   --  Note that this signal is emitted for changes to the deprecated
   --  Gtk.Style.Gtk_Style. To track changes to the
   --  Gtk.Style_Context.Gtk_Style_Context associated with a widget, use the
   --  Gtk.Widget.Gtk_Widget::style-updated signal.
   --  Deprecated:3.0: Use the Gtk.Widget.Gtk_Widget::style-updated signal
   --
   --  "style-updated"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --  The ::style-updated signal is emitted when the
   --  Gtk.Style_Context.Gtk_Style_Context of a widget is changed. Note that
   --  style-modifying functions like gtk_widget_override_color also cause this
   --  signal to be emitted.
   --
   --  "unmap"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --
   --  "unmap-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Any) return Boolean;
   --    --  "event": the Gdk_Event_Any which triggered this signal
   --  The ::unmap-event signal will be emitted when the Widget's window is
   --  unmapped. A window is unmapped when it becomes invisible on the screen.
   --  To receive this signal, the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_STRUCTURE_MASK mask. GDK will enable this
   --  mask automatically for all new windows.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "unrealize"
   --     procedure Handler (Self : access Gtk_Widget_Record'Class);
   --
   --  "visibility-notify-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Visibility) return Boolean;
   --    --  "event": the Gdk_Event_Visibility which triggered this signal.
   --  The ::visibility-notify-event will be emitted when the Widget's window
   --  is obscured or unobscured.
   --  To receive this signal the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_VISIBILITY_NOTIFY_MASK mask.
   --  False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the event.
   --
   --  "window-state-event"
   --     function Handler
   --       (Self  : access Gtk_Widget_Record'Class;
   --        Event : Gdk.Event_Window_State) return Boolean;
   --    --  "event": the Gdk_Event_Window_State which triggered this signal.
   --  The ::window-state-event will be emitted when the state of the toplevel
   --  window associated to the Widget changes.
   --  To receive this signal the Gdk.Window.Gdk_Window associated to the
   --  widget needs to enable the GDK_STRUCTURE_MASK mask. GDK will enable this
   --  mask automatically for all new windows.
   --  event. False to propagate the event further.
   --  Returns True to stop other handlers from being invoked for the

   Signal_Accel_Closures_Changed : constant Glib.Signal_Name := "accel-closures-changed";
   Signal_Button_Press_Event : constant Glib.Signal_Name := "button-press-event";
   Signal_Button_Release_Event : constant Glib.Signal_Name := "button-release-event";
   Signal_Can_Activate_Accel : constant Glib.Signal_Name := "can-activate-accel";
   Signal_Child_Notify : constant Glib.Signal_Name := "child-notify";
   Signal_Composited_Changed : constant Glib.Signal_Name := "composited-changed";
   Signal_Configure_Event : constant Glib.Signal_Name := "configure-event";
   Signal_Damage_Event : constant Glib.Signal_Name := "damage-event";
   Signal_Delete_Event : constant Glib.Signal_Name := "delete-event";
   Signal_Destroy : constant Glib.Signal_Name := "destroy";
   Signal_Destroy_Event : constant Glib.Signal_Name := "destroy-event";
   Signal_Direction_Changed : constant Glib.Signal_Name := "direction-changed";
   Signal_Drag_Begin : constant Glib.Signal_Name := "drag-begin";
   Signal_Drag_Data_Delete : constant Glib.Signal_Name := "drag-data-delete";
   Signal_Drag_Data_Get : constant Glib.Signal_Name := "drag-data-get";
   Signal_Drag_Data_Received : constant Glib.Signal_Name := "drag-data-received";
   Signal_Drag_Drop : constant Glib.Signal_Name := "drag-drop";
   Signal_Drag_End : constant Glib.Signal_Name := "drag-end";
   Signal_Drag_Failed : constant Glib.Signal_Name := "drag-failed";
   Signal_Drag_Leave : constant Glib.Signal_Name := "drag-leave";
   Signal_Drag_Motion : constant Glib.Signal_Name := "drag-motion";
   Signal_Draw : constant Glib.Signal_Name := "draw";
   Signal_Enter_Notify_Event : constant Glib.Signal_Name := "enter-notify-event";
   Signal_Event : constant Glib.Signal_Name := "event";
   Signal_Event_After : constant Glib.Signal_Name := "event-after";
   Signal_Focus : constant Glib.Signal_Name := "focus";
   Signal_Focus_In_Event : constant Glib.Signal_Name := "focus-in-event";
   Signal_Focus_Out_Event : constant Glib.Signal_Name := "focus-out-event";
   Signal_Grab_Broken_Event : constant Glib.Signal_Name := "grab-broken-event";
   Signal_Grab_Focus : constant Glib.Signal_Name := "grab-focus";
   Signal_Grab_Notify : constant Glib.Signal_Name := "grab-notify";
   Signal_Hide : constant Glib.Signal_Name := "hide";
   Signal_Hierarchy_Changed : constant Glib.Signal_Name := "hierarchy-changed";
   Signal_Key_Press_Event : constant Glib.Signal_Name := "key-press-event";
   Signal_Key_Release_Event : constant Glib.Signal_Name := "key-release-event";
   Signal_Keynav_Failed : constant Glib.Signal_Name := "keynav-failed";
   Signal_Leave_Notify_Event : constant Glib.Signal_Name := "leave-notify-event";
   Signal_Map : constant Glib.Signal_Name := "map";
   Signal_Map_Event : constant Glib.Signal_Name := "map-event";
   Signal_Mnemonic_Activate : constant Glib.Signal_Name := "mnemonic-activate";
   Signal_Motion_Notify_Event : constant Glib.Signal_Name := "motion-notify-event";
   Signal_Move_Focus : constant Glib.Signal_Name := "move-focus";
   Signal_Parent_Set : constant Glib.Signal_Name := "parent-set";
   Signal_Popup_Menu : constant Glib.Signal_Name := "popup-menu";
   Signal_Property_Notify_Event : constant Glib.Signal_Name := "property-notify-event";
   Signal_Proximity_In_Event : constant Glib.Signal_Name := "proximity-in-event";
   Signal_Proximity_Out_Event : constant Glib.Signal_Name := "proximity-out-event";
   Signal_Query_Tooltip : constant Glib.Signal_Name := "query-tooltip";
   Signal_Realize : constant Glib.Signal_Name := "realize";
   Signal_Screen_Changed : constant Glib.Signal_Name := "screen-changed";
   Signal_Scroll_Event : constant Glib.Signal_Name := "scroll-event";
   Signal_Selection_Clear_Event : constant Glib.Signal_Name := "selection-clear-event";
   Signal_Selection_Get : constant Glib.Signal_Name := "selection-get";
   Signal_Selection_Notify_Event : constant Glib.Signal_Name := "selection-notify-event";
   Signal_Selection_Received : constant Glib.Signal_Name := "selection-received";
   Signal_Selection_Request_Event : constant Glib.Signal_Name := "selection-request-event";
   Signal_Show : constant Glib.Signal_Name := "show";
   Signal_Show_Help : constant Glib.Signal_Name := "show-help";
   Signal_Size_Allocate : constant Glib.Signal_Name := "size-allocate";
   Signal_State_Changed : constant Glib.Signal_Name := "state-changed";
   Signal_State_Flags_Changed : constant Glib.Signal_Name := "state-flags-changed";
   Signal_Style_Set : constant Glib.Signal_Name := "style-set";
   Signal_Style_Updated : constant Glib.Signal_Name := "style-updated";
   Signal_Unmap : constant Glib.Signal_Name := "unmap";
   Signal_Unmap_Event : constant Glib.Signal_Name := "unmap-event";
   Signal_Unrealize : constant Glib.Signal_Name := "unrealize";
   Signal_Visibility_Notify_Event : constant Glib.Signal_Name := "visibility-notify-event";
   Signal_Window_State_Event : constant Glib.Signal_Name := "window-state-event";

private
   App_Paintable_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("app-paintable");
   Can_Default_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("can-default");
   Can_Focus_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("can-focus");
   Composite_Child_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("composite-child");
   Double_Buffered_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("double-buffered");
   Events_Property : constant Glib.Properties.Property_Boxed :=
     Glib.Properties.Build ("events");
   Expand_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("expand");
   Halign_Property : constant Glib.Properties.Property_Boxed :=
     Glib.Properties.Build ("halign");
   Has_Default_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("has-default");
   Has_Focus_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("has-focus");
   Has_Tooltip_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("has-tooltip");
   Height_Request_Property : constant Glib.Properties.Property_Int :=
     Glib.Properties.Build ("height-request");
   Hexpand_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("hexpand");
   Hexpand_Set_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("hexpand-set");
   Is_Focus_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("is-focus");
   Margin_Property : constant Glib.Properties.Property_Int :=
     Glib.Properties.Build ("margin");
   Margin_Bottom_Property : constant Glib.Properties.Property_Int :=
     Glib.Properties.Build ("margin-bottom");
   Margin_Left_Property : constant Glib.Properties.Property_Int :=
     Glib.Properties.Build ("margin-left");
   Margin_Right_Property : constant Glib.Properties.Property_Int :=
     Glib.Properties.Build ("margin-right");
   Margin_Top_Property : constant Glib.Properties.Property_Int :=
     Glib.Properties.Build ("margin-top");
   Name_Property : constant Glib.Properties.Property_String :=
     Glib.Properties.Build ("name");
   No_Show_All_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("no-show-all");
   Parent_Property : constant Glib.Properties.Property_Object :=
     Glib.Properties.Build ("parent");
   Receives_Default_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("receives-default");
   Sensitive_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("sensitive");
   Style_Property : constant Glib.Properties.Property_Object :=
     Glib.Properties.Build ("style");
   Tooltip_Markup_Property : constant Glib.Properties.Property_String :=
     Glib.Properties.Build ("tooltip-markup");
   Tooltip_Text_Property : constant Glib.Properties.Property_String :=
     Glib.Properties.Build ("tooltip-text");
   Valign_Property : constant Glib.Properties.Property_Boxed :=
     Glib.Properties.Build ("valign");
   Vexpand_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("vexpand");
   Vexpand_Set_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("vexpand-set");
   Visible_Property : constant Glib.Properties.Property_Boolean :=
     Glib.Properties.Build ("visible");
   Width_Request_Property : constant Glib.Properties.Property_Int :=
     Glib.Properties.Build ("width-request");
   Window_Property : constant Glib.Properties.Property_Boxed :=
     Glib.Properties.Build ("window");
end Gtk.Widget;