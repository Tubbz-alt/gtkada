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
--  The Gtk.Editable.Gtk_Editable interface is an interface which should be
--  implemented by text editing widgets, such as Gtk.GEntry.Gtk_Entry and
--  Gtk_Text. It contains functions for generically manipulating an editable
--  widget, a large number of action signals used for key bindings, and several
--  signals that an application can connect to to modify the behavior of a
--  widget.
--
--  As an example of the latter usage, by connecting the following handler to
--  "insert_text", an application can convert all entry into a widget into
--  uppercase.
--
--  == Forcing entry to uppercase. ==
--
--    include <ctype.h>
--    void
--    insert_text_handler (GtkEditable *editable,
--       const gchar *text,
--       gint         length,
--       gint        *position,
--       gpointer     data)
--    {
--       gchar *result = g_utf8_strup (text, length);
--       g_signal_handlers_block_by_func (editable,
--            (gpointer) insert_text_handler, data);
--       gtk_editable_insert_text (editable, result, length, position);
--       g_signal_handlers_unblock_by_func (editable,
--            (gpointer) insert_text_handler, data);
--       g_signal_stop_emission_by_name (editable, "insert_text");
--       g_free (result);
--    }
--
--
--  </description>

pragma Warnings (Off, "*is already use-visible*");
with Glib;       use Glib;
with Glib.Types; use Glib.Types;

package Gtk.Editable is

   type Gtk_Editable is new Glib.Types.GType_Interface;

   ------------------
   -- Constructors --
   ------------------

   function Get_Type return Glib.GType;
   pragma Import (C, Get_Type, "gtk_editable_get_type");

   -------------
   -- Methods --
   -------------

   procedure Copy_Clipboard (Editable : Gtk_Editable);
   pragma Import (C, Copy_Clipboard, "gtk_editable_copy_clipboard");
   --  Copies the contents of the currently selected content in the editable
   --  and puts it on the clipboard.

   procedure Cut_Clipboard (Editable : Gtk_Editable);
   pragma Import (C, Cut_Clipboard, "gtk_editable_cut_clipboard");
   --  Removes the contents of the currently selected content in the editable
   --  and puts it on the clipboard.

   procedure Delete_Selection (Editable : Gtk_Editable);
   pragma Import (C, Delete_Selection, "gtk_editable_delete_selection");
   --  Deletes the currently selected text of the editable. This call doesn't
   --  do anything if there is no selected text.

   procedure Delete_Text
      (Editable  : Gtk_Editable;
       Start_Pos : Gint;
       End_Pos   : Gint := -1);
   pragma Import (C, Delete_Text, "gtk_editable_delete_text");
   --  Deletes a sequence of characters. The characters that are deleted are
   --  those characters at positions from Start_Pos up to, but not including
   --  End_Pos. If End_Pos is negative, then the the characters deleted are
   --  those from Start_Pos to the end of the text.
   --  Note that the positions are specified in characters, not bytes.
   --  "start_pos": start position
   --  "end_pos": end position

   function Get_Chars
      (Editable  : Gtk_Editable;
       Start_Pos : Gint;
       End_Pos   : Gint := -1) return UTF8_String;
   --  Retrieves a sequence of characters. The characters that are retrieved
   --  are those characters at positions from Start_Pos up to, but not
   --  including End_Pos. If End_Pos is negative, then the the characters
   --  retrieved are those characters from Start_Pos to the end of the text.
   --  Note that positions are specified in characters, not bytes.
   --  string. This string is allocated by the Gtk.Editable.Gtk_Editable
   --  implementation and should be freed by the caller.
   --  "start_pos": start of text
   --  "end_pos": end of text

   function Get_Editable (Editable : Gtk_Editable) return Boolean;
   procedure Set_Editable (Editable : Gtk_Editable; Is_Editable : Boolean);
   --  Determines if the user can edit the text in the editable widget or not.
   --  "is_editable": True if the user is allowed to edit the text in the
   --  widget

   function Get_Position (Editable : Gtk_Editable) return Gint;
   pragma Import (C, Get_Position, "gtk_editable_get_position");
   procedure Set_Position (Editable : Gtk_Editable; Position : Gint);
   pragma Import (C, Set_Position, "gtk_editable_set_position");
   --  Sets the cursor position in the editable to the given value.
   --  The cursor is displayed before the character with the given (base 0)
   --  index in the contents of the editable. The value must be less than or
   --  equal to the number of characters in the editable. A value of -1
   --  indicates that the position should be set after the last character of
   --  the editable. Note that Position is in characters, not in bytes.
   --  "position": the position of the cursor

   procedure Insert_Text
      (Editable        : Gtk_Editable;
       New_Text        : UTF8_String;
       New_Text_Length : Gint;
       Position        : in out Gint);
   --  Inserts New_Text_Length bytes of New_Text into the contents of the
   --  widget, at position Position.
   --  Note that the position is in characters, not in bytes. The function
   --  updates Position to point after the newly inserted text.
   --  "new_text": the text to append
   --  "new_text_length": the length of the text in bytes, or -1
   --  "position": location of the position text will be inserted at

   procedure Paste_Clipboard (Editable : Gtk_Editable);
   pragma Import (C, Paste_Clipboard, "gtk_editable_paste_clipboard");
   --  Pastes the content of the clipboard to the current position of the
   --  cursor in the editable.

   procedure Select_Region
      (Editable  : Gtk_Editable;
       Start_Pos : Gint;
       End_Pos   : Gint := -1);
   pragma Import (C, Select_Region, "gtk_editable_select_region");
   --  Selects a region of text. The characters that are selected are those
   --  characters at positions from Start_Pos up to, but not including End_Pos.
   --  If End_Pos is negative, then the the characters selected are those
   --  characters from Start_Pos to the end of the text.
   --  Note that positions are specified in characters, not bytes.
   --  "start_pos": start of region
   --  "end_pos": end of region

   ----------------------
   -- GtkAda additions --
   ----------------------

   procedure Insert_Text
     (Editable : Gtk_Editable;
      New_Text : UTF8_String;
      Position : in out Gint);
   --  Convenience subprogram, identical to Insert_Text above without
   --  the requirement to supply the New_Text_Length argument.

   -------------
   -- Signals --
   -------------
   --  The following new signals are defined for this widget:
   --
   --  "changed"
   --     procedure Handler (Self : access Gtk_Editable);
   --  The ::changed signal is emitted at the end of a single user-visible
   --  operation on the contents of the Gtk.Editable.Gtk_Editable.
   --
   --  E.g., a paste operation that replaces the contents of the selection
   --  will cause only one signal emission (even though it is implemented by
   --  first deleting the selection, then inserting the new content, and may
   --  cause multiple ::notify::text signals to be emitted).
   --
   --  "delete-text"
   --     procedure Handler
   --       (Self      : access Gtk_Editable;
   --        Start_Pos : Gint;
   --        End_Pos   : Gint);
   --    --  "start_pos": the starting position
   --    --  "end_pos": the end position
   --  This signal is emitted when text is deleted from the widget by the
   --  user. The default handler for this signal will normally be responsible
   --  for deleting the text, so by connecting to this signal and then stopping
   --  the signal with g_signal_stop_emission, it is possible to modify the
   --  range of deleted text, or prevent it from being deleted entirely. The
   --  Start_Pos and End_Pos parameters are interpreted as for
   --  Gtk.Editable.Delete_Text.
   --
   --  "insert-text"
   --     procedure Handler
   --       (Self            : access Gtk_Editable;
   --        New_Text        : UTF8_String;
   --        New_Text_Length : Gint;
   --        Position        : Gint);
   --    --  "new_text": the new text to insert
   --    --  "new_text_length": the length of the new text, in bytes, or -1 if
   --    --  new_text is nul-terminated
   --    --  "position": the position, in characters, at which to insert the new
   --    --  text. this is an in-out parameter. After the signal emission is
   --    --  finished, it should point after the newly inserted text.
   --  This signal is emitted when text is inserted into the widget by the
   --  user. The default handler for this signal will normally be responsible
   --  for inserting the text, so by connecting to this signal and then
   --  stopping the signal with g_signal_stop_emission, it is possible to
   --  modify the inserted text, or prevent it from being inserted entirely.

   Signal_Changed : constant Glib.Signal_Name := "changed";
   Signal_Delete_Text : constant Glib.Signal_Name := "delete-text";
   Signal_Insert_Text : constant Glib.Signal_Name := "insert-text";

end Gtk.Editable;