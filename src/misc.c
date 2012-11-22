/*
-----------------------------------------------------------------------
--               GtkAda - Ada95 binding for Gtk+/Gnome               --
--                                                                   --
--   Copyright (C) 1998-2000 E. Briot, J. Brobecker and A. Charlet   --
--                Copyright (C) 2000-2012, AdaCore                   --
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
*/

#include "config.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>
#include <glib-object.h>
#include <pango/pango.h>
#include <gdk/gdk.h>
#include <gtk/gtk.h>

/********************************************************************
 *  Returns the major/minor/macro version number of Gtk+. This is
 *  needed as the windows version uses a different convention for the
 *  corresponding variables gtk_{major/minor/micro)_version than the
 *  unix version.
 ********************************************************************/

guint
ada_gtk_major_version ()
{
  return GTK_MAJOR_VERSION;
}

guint
ada_gtk_minor_version ()
{
  return GTK_MINOR_VERSION;
}

guint
ada_gtk_micro_version ()
{
  return GTK_MICRO_VERSION;
}

/********************************************************************
 **  var_arg wrappers.
 ********************************************************************/

gpointer
ada_g_object_new (GType object_type)
{
  return g_object_new (object_type, NULL);
}

void
ada_g_object_get_ulong (gpointer object,
		        const gchar *property_name,
		        gulong *property)
{
  g_object_get (object, property_name, property, NULL);
}


void
ada_g_object_set_string (gpointer object,
			 const gchar *property_name,
			 const gchar *property)
{
  g_object_set (object, property_name, property, NULL);
}

void
ada_g_object_set_int (gpointer object,
		      const gchar *property_name,
		      gint property)
{
  g_object_set (object, property_name, property, NULL);
}

void
ada_g_object_set_ulong (gpointer object,
		        const gchar *property_name,
		        gulong property)
{
  g_object_set (object, property_name, property, NULL);
}

void
ada_g_object_set_ptr (gpointer object,
		      const gchar *property_name,
		      void *property)
{
  g_object_set (object, property_name, property, NULL);
}

void
ada_g_object_set_float (gpointer object,
			const gchar *property_name,
			gfloat property)
{
  g_object_set (object, property_name, property, NULL);
}

void
ada_g_object_set_double (gpointer object,
			 const gchar *property_name,
			 gdouble property)
{
  g_object_set (object, property_name, property, NULL);
}

void
ada_g_signal_emit_by_name (gpointer     instance,
			   const gchar *detailed_signal)
{
  g_signal_emit_by_name (instance, detailed_signal);
}

void
ada_g_signal_emit_by_name_ptr (gpointer     instance,
			       const gchar *detailed_signal,
			       void *arg)
{
  g_signal_emit_by_name (instance, detailed_signal, arg);
}

void
ada_g_signal_emit_by_name_ptr_ptr (gpointer     instance,
			           const gchar *detailed_signal,
			           void *arg1,
			           void *arg2)
{
  g_signal_emit_by_name (instance, detailed_signal, arg1, arg2);
}

void
ada_g_signal_emit_by_name_int_ptr (gpointer     instance,
			           const gchar *detailed_signal,
			           gint arg1,
			           void *arg2)
{
  g_signal_emit_by_name (instance, detailed_signal, arg1, arg2);
}

void
ada_gtk_list_store_set_ptr (GtkListStore *list_store,
                            GtkTreeIter  *iter,
                            gint          col,
                            void         *val)
{
  gtk_list_store_set (list_store, iter, col, val, -1);
}


void
ada_gtk_list_store_set_int (GtkListStore *list_store,
                            GtkTreeIter  *iter,
                            gint          col,
                            gint          val)
{
  gtk_list_store_set (list_store, iter, col, val, -1);
}

void
ada_gtk_tree_store_set_ptr (GtkTreeStore *tree_store,
			    GtkTreeIter  *iter,
			    gint          col,
			    void         *val)
{
  gtk_tree_store_set (tree_store, iter, col, val, -1);
}

void
ada_gtk_tree_store_set_int (GtkTreeStore *tree_store,
			    GtkTreeIter  *iter,
			    gint          col,
			    gint          val)
{
  gtk_tree_store_set (tree_store, iter, col, val, -1);
}

GtkWidget*
ada_gtk_dialog_new_with_buttons (const gchar     *title,
                                 GtkWindow       *parent,
                                 GtkDialogFlags   flags)
{
  return gtk_dialog_new_with_buttons (title, parent, flags,
                                      NULL /* first_button_text*/, NULL);
}

gboolean
ada_gdk_pixbuf_save (GdkPixbuf  *pixbuf,
		     const char *filename,
		     const char *type,
		     GError    **error,
		     char       *key,
		     char       *value)
{
  return gdk_pixbuf_save (pixbuf, filename, type, error, key, value, NULL);
}

void
ada_g_log (const gchar    *log_domain,
	   GLogLevelFlags  log_level,
	   const gchar    *format)
{
  g_log (log_domain, log_level, format);
}

void
c_sprintf (char *s, char *format, int arg1, int arg2, int arg3)
{
  sprintf (s, format, arg1, arg2, arg3);
}

/********************************************************************
 **  This function should only be used for debug purposes.
 ********************************************************************/

guint
ada_gtk_debug_get_ref_count (GObject* object) {
  return G_OBJECT (object)->ref_count;
}

/******************************************
 ** GSignal                              **
 ******************************************/

const gchar*
ada_gsignal_query_signal_name (GSignalQuery* query)
{
  return query->signal_name;
}

const GType*
ada_gsignal_query_params (GSignalQuery* query, guint* n_params)
{
  *n_params = query->n_params;
  return query->param_types;
}

guint
ada_gsignal_query_id (GSignalQuery* query)
{
  return query->signal_id;
}

GType
ada_gsignal_query_return_type (GSignalQuery* query)
{
  return query->return_type;
}

/*********************************************************************
 ** Creating new widgets
 ** For each new widget created by the user, we create a new
 ** class record, that has the following layout:
 **
 **  struct NewClassRecord {
 **     struct AncestorClass ancestor_class;   // the ancestor
 **     void (*handler1) (...);                // handler for first signal
 **     void (*handler2) (...);                // handler for second signal
 **     ...
 **     void (*handlern) (...);                // handler for nth signal
 **     GObjectGetPropertyFunc real_get_property;
 **                                            // pointer to the get_property
 **                                            // in user's code
 **     GObjectSetPropertyFunc real_set_property;
 **                                            // likewise for set_property
 **  };
 *********************************************************************/

typedef struct {
   GObjectClass* klass;   // The C class structure.
   GObjectClass* parent_class; // The parent class (used for calling inherited ops).
                          // This is cached for efficiency.
   GType type;            // The type. This also acts as a lock while
                          // initializing the class record.
} AdaGObjectClass;
//  Type must be synchronized with Ada.

GType
ada_type_from_class (GObjectClass* klass)
{
  return G_TYPE_FROM_CLASS (klass);
}

void
ada_initialize_class_record
  (GObject*      object,
   gint          nsignals,
   char*         signals[],
   GType         parameters[],
   gint          max_parameters,
   AdaGObjectClass* klass,   /* in out AdaGObjectClass*/
   gchar*        type_name)
{
   // Make this function thread-safe and ensure we only initialize the class
   // once
   if (g_once_init_enter (&klass->type)) {
       /* Note: The memory allocated in this function is never freed. No need
          to worry, since this is only allocated once per user's widget type,
          and might be used until the end of the application */

       /************************
        * When this function is called, object has already been initialized
        * by a call to parent_type_new(). So the C structure has been allocated
        * enough space for instances of the parent type (which is good enough
        * since any additional instance field will be in the Ada structure
        * anyway.
        * However, parent_type_new() has called g_object_new(), which does a
        * number of additional setup for constructors and properties. These all
        * seem to be C specific though, so we can simply replace the klass
        * field at the bottom of this function.
        ************************/

       /* Right now, object->klass points to the ancestor's class */
       GType ancestor = G_TYPE_FROM_CLASS (G_OBJECT_GET_CLASS (object));
       GTypeQuery query;
       int j;

       /* We need to know the ancestor's class/instance sizes */
       g_type_query (ancestor, &query);

       /*************************
        * This code is the equivalent of type_name@@_get_type in C.  In Ada, the
        * type will be accessible only once at least one instance of it has been
        * created (whereas in C the GType is created at elaboration time.
        *************************/

       GType new_type = g_type_register_static_simple
          (ancestor /* parent_type */,
           type_name /* type_name */,
           query.class_size  /* class_size */
              + nsignals * sizeof (void*)
              + sizeof (GObjectGetPropertyFunc)
              + sizeof (GObjectSetPropertyFunc),
           NULL /* class_init */,
           query.instance_size  /* instance_size */,
           NULL /* instance_init */,
           0  /* GTypeFlags */);

       /*************************
        * This code is generally called by g_object_new (which itself is called
        * from type_name_new() in C). Its result is to create and initialized
        * (via class_init) the class the first time an instance of it is
        * created. In Ada, we do not us a _class_init, so we initialize the
        * signals immediately after creating the class.
        *************************/

       klass->klass = g_type_class_ref (new_type);
       g_assert (klass->klass != NULL);

       for (j = 0; j < nsignals; j++) {
          int count = 0;
          GClosure *closure;

          while (count < max_parameters &&
                  (parameters [j * max_parameters + count] != G_TYPE_NONE))
          {
                count++;
          }

          closure = g_signal_type_cclosure_new
              (new_type, query.class_size + j * sizeof (void*)); /* offset */

          /* id = */ g_signal_newv
            (signals[j],                       /* signal_name */
             new_type,                         /* itype */
             G_SIGNAL_RUN_LAST,                /* signal_flags */
             closure,                          /* class_closure */
             NULL,                             /* accumulator */
             NULL,                             /* accu_data */
             g_cclosure_marshal_VOID__VOID,    /* c_marshaller, unused at the
               Ada level ??? This probably makes the widget unusable from C */
             G_TYPE_NONE,                      /* return_type */
             count,                            /* n_params */
             parameters + j * max_parameters); /* param_types */
        }

        /* Initialize the function pointers for the new signals to NULL */
        memset ((char*)(klass->klass) + query.class_size, 0,
 	      nsignals * sizeof (void*)
 	      + sizeof (GObjectGetPropertyFunc)
 	      + sizeof (GObjectSetPropertyFunc));

        klass->parent_class = g_type_class_peek_parent (klass->klass);

        g_once_init_leave (&klass->type, new_type); // sets klass->type

   } else {
      // Since the class has already been created, this never calls _class_init
      // but still increases the reference counting on the class.
      (void) g_type_class_ref (klass->type);
   }

   ((GTypeInstance*)object)->g_class = (GTypeClass*) klass->klass;
}

void
ada_gtk_widget_set_default_size_allocate_handler
   (AdaGObjectClass* klass, void (*handler)(GtkWidget        *widget,
				    GtkAllocation    *allocation))
{
  GTK_WIDGET_CLASS (klass->klass)->size_allocate = handler;
}

void
ada_gtk_set_draw_handler
   (AdaGObjectClass* klass,
    gboolean (*draw) (GtkWidget *, cairo_t*))
{
  if (draw && GTK_IS_WIDGET_CLASS (klass->klass)) {
      GTK_WIDGET_CLASS (klass->klass)->draw = draw;
  }
}

/*****************************************************
 ** Gtk.Selection and Gtk.Dnd functions
 *****************************************************/

guint ada_gtk_dnd_context_targets_count (GdkDragContext* context)
{
  return g_list_length (gdk_drag_context_list_targets (context));
}

void ada_gtk_dnd_context_get_targets (GdkDragContext* context, GdkAtom* result)
{
  GList *glist = gdk_drag_context_list_targets (context);
  GdkAtom* tmp = result;
  while (glist != NULL)
    {
      *tmp++ = (GdkAtom)glist->data;
//      gchar *name = gdk_atom_name ((GdkAtom)glist->data);
//      *tmp++ = name;
      glist = glist->next;
    }
}

/*
 * Gnode macros
 *
 */

gboolean
ada_gnode_is_root (GNode * node)
{
  return G_NODE_IS_ROOT (node);
}

gboolean
ada_gnode_is_leaf (GNode * node)
{
  return G_NODE_IS_LEAF (node);
}

GNode*
ada_gnode_prev_sibling (GNode * node)
{
  return g_node_prev_sibling (node);
}

GNode*
ada_gnode_next_sibling (GNode * node)
{
  return g_node_next_sibling (node);
}

GNode*
ada_gnode_first_child (GNode * node)
{
  return g_node_first_child (node);
}

/**********************************************************
 **  Support for events
 **********************************************************/

#ifdef _WIN32
#define ada_gdk_invalid_gdouble_value 1.79769313486232e308
#define ada_gdk_invalid_gint_value ((2<<31) - 1)
#define ada_gdk_invalid_guint_value (guint)((2LL<<32) - 1)
#define ada_gdk_invalid_guint32_value (guint32)((2LL<<32) - 1)
#define ada_gdk_invalid_gulong_value (gulong)((2LL<<32) - 1)

#else
extern const gdouble ada_gdk_invalid_gdouble_value;
extern const gint    ada_gdk_invalid_gint_value;
extern const guint   ada_gdk_invalid_guint_value;
extern const guint32 ada_gdk_invalid_guint32_value;
extern const gulong  ada_gdk_invalid_gulong_value;
#endif

GdkAtom
ada_make_atom (gulong num)
{
  return _GDK_MAKE_ATOM (num);
}

GdkEventType
ada_gdk_event_get_event_type (GdkEvent *event) {
  return event->type;
}

guint
ada_gdk_event_get_button (GdkEvent * event)
{
  guint button;
  if (!gdk_event_get_button(event, &button)) {
    return ada_gdk_invalid_guint_value;
  }
  return button;
}

GdkModifierType
ada_gdk_event_get_state (GdkEvent * event)
{
  GdkModifierType state;
  if (!gdk_event_get_state(event, &state)) {
    return ada_gdk_invalid_guint_value;
  }
  return state;
}

guint
ada_gdk_event_get_keyval (GdkEvent * event)
{
  guint keyval;
  if (!gdk_event_get_keyval(event, &keyval)) {
    return ada_gdk_invalid_gint_value;
  }
  return keyval;
}

GdkWindow*
ada_gdk_event_get_window (GdkEvent * event)
{
  return ((GdkEventAny*)event)->window;
}

guint16
ada_gdk_event_get_keycode (GdkEvent * event)
{
  guint16 keycode;
  if (!gdk_event_get_keycode(event, &keycode)) {
    return 0;
  }
  return keycode;
}

/***************************************************
 *  Functions for Objects
 ***************************************************/

GType
ada_gobject_get_type (GObject* object)
{
  return G_OBJECT_TYPE (object);
}

/***************************************************
 *  Functions for GClosure
 ***************************************************/

void*
ada_gclosure_get_data (GClosure *closure)
{
  return closure->data;
}

/***************************************************
 *  Functions for GValue
 ***************************************************/

gpointer
ada_gvalue_get_pointer (GValue* value)
{
  return value->data[0].v_pointer;
}

void
ada_gvalue_nth (GValue* value, guint num, GValue* val)
{
  *val = *(value + num);
}

int
ada_c_gvalue_size ()
{
  return sizeof (GValue);
}

void
ada_gvalue_set (GValue* value, void *val)
{
  if G_VALUE_HOLDS_CHAR (value)
    g_value_set_schar (value, *(gchar*)val);
  else if G_VALUE_HOLDS_UCHAR (value)
    g_value_set_uchar (value, *(guchar*)val);
  else if G_VALUE_HOLDS_BOOLEAN (value)
    g_value_set_boolean (value, *(char*)val);
  else if G_VALUE_HOLDS_INT (value)
    g_value_set_int (value, *(gint*)val);
  else if G_VALUE_HOLDS_UINT (value)
    g_value_set_uint (value, *(guint*)val);
  else if G_VALUE_HOLDS_LONG (value)
    g_value_set_long (value, *(glong*)val);
  else if G_VALUE_HOLDS_ULONG (value)
    g_value_set_ulong (value, *(gulong*)val);
  else if G_VALUE_HOLDS_FLOAT (value)
    g_value_set_float (value, *(gfloat*)val);
  else if G_VALUE_HOLDS_DOUBLE (value)
    g_value_set_double (value, *(gdouble*)val);
  else if G_VALUE_HOLDS_POINTER (value)
    g_value_set_pointer (value, *(gpointer*)val);
  else
    fprintf (stderr, "GtkAda: Return value type not supported\n");
}

/**********************************************
 ** Functions for Box
 **********************************************/

GtkWidget*
ada_box_get_child (GtkBox* widget, gint num)
{
  GList * list;
  list = gtk_container_get_children ((GtkContainer*)widget);
  if (list && num < g_list_length (list))
    return ((GtkWidget*) (g_list_nth_data (list, num)));
  return NULL;
}

/**********************************************
 ** Functions for Glib.Glist
 **********************************************/

GList*
ada_list_next (GList* list)
{
  if (list)
    return list->next;
  else
    return NULL;
}

GList*
ada_list_prev (GList* list)
{
  if (list)
    return list->prev;
  else
    return NULL;
}

gpointer
ada_list_get_data (GList* list)
{
  if (list)
     return list->data;
  else
     return NULL;
}

/**********************************************
 ** Functions for Glib.GSlist
 **********************************************/

GSList*
ada_gslist_next (GSList* list)
{
  if (list)
    return list->next;
  else
    return NULL;
}

gpointer
ada_gslist_get_data (GSList* list)
{
  return list->data;
}

gpointer
ada_slist_get_data (GSList* list)
{
  return list->data;
}


/*
 *
 * GdkWindowAttr
 *
 */

GdkWindowAttr*
ada_gdk_window_attr_new (void)
{
  GdkWindowAttr *result;

  result = (GdkWindowAttr*) g_new (GdkWindowAttr, 1);

  if (result)
    {
      result->title = NULL;
      result->visual = NULL;
      result->cursor = NULL;
      result->wmclass_name = NULL;
      result->wmclass_class = NULL;
      /*
       * Here, we only set the pointers to NULL to avoid any dangling
       * pointer. All the other values are left as is. It is the
       * responsibility of the client to make sure they are properly
       * set before they are accessed.
       */
    }

  return result;
}

void
ada_gdk_window_attr_destroy (GdkWindowAttr *window_attr)
{
  g_return_if_fail (window_attr != NULL);

  if (window_attr->title) g_free (window_attr->title);
  if (window_attr->wmclass_name) g_free (window_attr->wmclass_name);
  if (window_attr->wmclass_class) g_free (window_attr->wmclass_class);

  g_free (window_attr);
}

void
ada_gdk_window_attr_set_title (GdkWindowAttr *window_attr,
			       gchar * title)
{
  g_return_if_fail (window_attr != NULL);

  if (window_attr->title) g_free (window_attr->title);
  window_attr->title = g_strdup (title);
}

gchar*
ada_gdk_window_attr_get_title (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, NULL);

  return window_attr->title;
}

void
ada_gdk_window_attr_set_event_mask (GdkWindowAttr *window_attr,
				    gint event_mask)
{
  g_return_if_fail (window_attr != NULL);

  window_attr->event_mask = event_mask;
}

gint
ada_gdk_window_attr_get_event_mask (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, 0);

  return window_attr->event_mask;
}

void
ada_gdk_window_attr_set_x (GdkWindowAttr * window_attr, gint x)
{
  g_return_if_fail (window_attr != NULL);

  window_attr->x = x;
}

gint
ada_gdk_window_attr_get_x (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, 0);

  return window_attr->x;
}

void
ada_gdk_window_attr_set_y (GdkWindowAttr * window_attr, gint y)
{
  g_return_if_fail (window_attr != NULL);

  window_attr->y = y;
}

gint
ada_gdk_window_attr_get_y (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, 0);

  return window_attr->y;
}

void
ada_gdk_window_attr_set_width (GdkWindowAttr * window_attr, gint width)
{
  g_return_if_fail (window_attr != NULL);

  window_attr->width = width;
}

gint
ada_gdk_window_attr_get_width (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, 0);

  return window_attr->width;
}

void
ada_gdk_window_attr_set_height (GdkWindowAttr * window_attr, gint height)
{
  g_return_if_fail (window_attr != NULL);

  window_attr->height = height;
}

gint
ada_gdk_window_attr_get_height (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, 0);

  return window_attr->height;
}

void
ada_gdk_window_attr_set_wclass (GdkWindowAttr *window_attr,
				GdkWindowWindowClass wclass)
{
  g_return_if_fail (window_attr != NULL);

  window_attr->wclass = wclass;
}

GdkWindowWindowClass
ada_gdk_window_attr_get_wclass (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, GDK_INPUT_OUTPUT);

  return window_attr->wclass;
}

void
ada_gdk_window_attr_set_visual (GdkWindowAttr *window_attr,
				GdkVisual *visual)
{
  g_return_if_fail (window_attr != NULL);

  window_attr->visual = visual;
}

GdkVisual*
ada_gdk_window_attr_get_visual (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, NULL);

  return window_attr->visual;
}

void
ada_gdk_window_attr_set_window_type (GdkWindowAttr *window_attr,
				     GdkWindowType window_type)
{
  g_return_if_fail (window_attr != NULL);

  window_attr->window_type = window_type;
}

GdkWindowType
ada_gdk_window_attr_get_window_type (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, GDK_WINDOW_ROOT);

  return window_attr->window_type;
}

void
ada_gdk_window_attr_set_cursor (GdkWindowAttr *window_attr,
				GdkCursor *cursor)
{
  g_return_if_fail (window_attr != NULL);

  window_attr->cursor = cursor;
}

GdkCursor*
ada_gdk_window_attr_get_cursor (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, NULL);

  return window_attr->cursor;
}

void
ada_gdk_window_attr_set_wmclass_name (GdkWindowAttr *window_attr,
				      gchar *wmclass_name)
{
  g_return_if_fail (window_attr != NULL);

  if (window_attr->wmclass_name) g_free (window_attr->wmclass_name);
  window_attr->wmclass_name = g_strdup (wmclass_name);
}

gchar*
ada_gdk_window_attr_get_wmclass_name (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, NULL);

  return window_attr->wmclass_name;
}

void
ada_gdk_window_attr_set_wmclass_class (GdkWindowAttr *window_attr,
				      gchar *wmclass_class)
{
  g_return_if_fail (window_attr != NULL);

  if (window_attr->wmclass_class) g_free (window_attr->wmclass_class);
  window_attr->wmclass_class = g_strdup (wmclass_class);
}

gchar*
ada_gdk_window_attr_get_wmclass_class (GdkWindowAttr *window_attr)
{
  g_return_val_if_fail (window_attr != NULL, NULL);

  return window_attr->wmclass_class;
}

void
ada_gdk_window_attr_set_override_redirect (GdkWindowAttr *window_attr,
					   gboolean override_redirect)
{
  g_return_if_fail (window_attr != NULL);

  window_attr->override_redirect = override_redirect;
}

gboolean
ada_gdk_window_attr_get_override_redirect (GdkWindowAttr * window_attr)
{
  g_return_val_if_fail (window_attr != NULL, FALSE);

  return window_attr->override_redirect;
}

/*
 *
 * Gdk properties
 *
 */

void
ada_gdk_property_get (GdkWindow	 *window,
		      GdkAtom     property,
		      GdkAtom     type,
		      gulong      offset,
		      gulong      length,
		      gint        pdelete,
		      GdkAtom    *actual_property_type,
		      gint       *actual_format,
		      gint       *actual_length,
		      guchar    **data,
		      gint       *success)
{
  *success = gdk_property_get (window, property, type, offset, length,
			       pdelete, actual_property_type, actual_format,
			       actual_length, data);
}


/******************************************
 ** GEnumClass                           **
 ******************************************/

int
ada_c_enum_value_size ()
{
  return sizeof (GEnumValue);
}

GEnumValue*
ada_genum_nth_value (GEnumClass* klass, guint nth)
{
  return (nth < klass->n_values) ? &(klass->values[nth]) : NULL;
}

gint
ada_genum_get_value (GEnumValue* value)
{
  return value->value;
}

const gchar*
ada_genum_get_name (GEnumValue* value)
{
  return value->value_name;
}

const gchar*
ada_genum_get_nick (GEnumValue* value)
{
  return value->value_nick;
}

/******************************************
 ** GFlags                               **
 ******************************************/

GFlagsValue*
ada_gflags_nth_value (GFlagsClass* klass, guint nth)
{
  return (nth < klass->n_values) ? &(klass->values[nth]) : NULL;
}

gint
ada_gflags_get_value (GFlagsValue* value)
{
  return value->value;
}

const gchar*
ada_gflags_get_name (GFlagsValue* value)
{
  return value->value_name;
}

const gchar*
ada_gflags_get_nick (GFlagsValue* value)
{
  return value->value_nick;
}

/******************************************
 ** GParamSpec                           **
 ******************************************/

const char*
ada_gparam_get_name (GParamSpec* param)
{
  return param->name;
}

GParamFlags
ada_gparam_get_flags (GParamSpec* param)
{
  return param->flags;
}

GType
ada_gparam_get_owner_type (GParamSpec* param)
{
  return param->owner_type;
}

GType
ada_gparam_get_value_type (GParamSpec* param)
{
  return G_PARAM_SPEC_VALUE_TYPE (param);
}

void
ada_gparam_set_value_type (GParamSpec* param, GType value_type)
{
  G_PARAM_SPEC_VALUE_TYPE (param) = value_type;
}

gint8
ada_gparam_get_minimum_char (GParamSpecChar* param)
{
  return param->minimum;
}

gint8
ada_gparam_get_maximum_char (GParamSpecChar* param)
{
  return param->maximum;
}

gint8
ada_gparam_get_default_char (GParamSpecChar* param)
{
  return param->default_value;
}

guint8
ada_gparam_get_minimum_uchar (GParamSpecUChar* param)
{
  return param->minimum;
}

guint8
ada_gparam_get_maximum_uchar (GParamSpecUChar* param)
{
  return param->maximum;
}

guint8
ada_gparam_get_default_uchar (GParamSpecUChar* param)
{
  return param->default_value;
}

gboolean
ada_gparam_get_default_boolean (GParamSpecBoolean* param)
{
  return param->default_value;
}

gint
ada_gparam_get_minimum_int (GParamSpecInt* param)
{
  return param->minimum;
}

gint
ada_gparam_get_maximum_int (GParamSpecInt* param)
{
  return param->maximum;
}

gint
ada_gparam_get_default_int (GParamSpecInt* param)
{
  return param->default_value;
}

guint
ada_gparam_get_minimum_uint (GParamSpecUInt* param)
{
  return param->minimum;
}

guint
ada_gparam_get_maximum_uint (GParamSpecUInt* param)
{
  return param->maximum;
}

guint
ada_gparam_get_default_uint (GParamSpecUInt* param)
{
  return param->default_value;
}

glong
ada_gparam_get_minimum_long (GParamSpecLong* param)
{
  return param->minimum;
}

glong
ada_gparam_get_maximum_long (GParamSpecLong* param)
{
  return param->maximum;
}

glong
ada_gparam_get_default_long (GParamSpecLong* param)
{
  return param->default_value;
}

gulong
ada_gparam_get_minimum_ulong (GParamSpecULong* param)
{
  return param->minimum;
}

gulong
ada_gparam_get_maximum_ulong (GParamSpecULong* param)
{
  return param->maximum;
}

gulong
ada_gparam_get_default_ulong (GParamSpecULong* param)
{
  return param->default_value;
}

gunichar
ada_gparam_get_default_unichar (GParamSpecUnichar* param)
{
  return param->default_value;
}

gint
ada_gparam_get_default_enum (GParamSpecEnum* param)
{
  return param->default_value;
}

GEnumClass*
ada_gparam_get_enum_class_enum (GParamSpecEnum* param)
{
  return param->enum_class;
}

GFlagsClass*
ada_gparam_get_flags_flags (GParamSpecFlags* param)
{
  return param->flags_class;
}

glong
ada_gparam_get_default_flags (GParamSpecFlags* param)
{
  return param->default_value;
}

gfloat
ada_gparam_get_minimum_gfloat (GParamSpecFloat* param)
{
  return param->minimum;
}

gfloat
ada_gparam_get_maximum_gfloat (GParamSpecFloat* param)
{
  return param->maximum;
}

gfloat
ada_gparam_get_default_gfloat (GParamSpecFloat* param)
{
  return param->default_value;
}

gfloat
ada_gparam_get_epsilon_gfloat (GParamSpecFloat* param)
{
  return param->epsilon;
}

gdouble
ada_gparam_get_minimum_gdouble (GParamSpecDouble* param)
{
  return param->minimum;
}

gdouble
ada_gparam_get_maximum_gdouble (GParamSpecDouble* param)
{
  return param->maximum;
}

gdouble
ada_gparam_get_default_gdouble (GParamSpecDouble* param)
{
  return param->default_value;
}

gdouble
ada_gparam_get_epsilon_gdouble (GParamSpecDouble* param)
{
  return param->epsilon;
}

gchar*
ada_gparam_default_string (GParamSpecString* param)
{
  return param->default_value;
}

gchar*
ada_gparam_cset_first_string (GParamSpecString* param)
{
  return param->cset_first;
}

gchar*
ada_gparam_cset_nth_string (GParamSpecString* param)
{
  return param->cset_nth;
}

gchar
ada_gparam_substitutor_string (GParamSpecString* param)
{
  return param->substitutor;
}

gboolean
ada_gparam_ensure_non_null_string (GParamSpecString* param)
{
  return param->ensure_non_null != 0;
}

/******************************************
 ** New widgets
 ******************************************/

void
ada_install_property_handlers
   (AdaGObjectClass* klass,
    GObjectSetPropertyFunc c_set_handler,
    GObjectGetPropertyFunc c_get_handler,
    GObjectSetPropertyFunc ada_set_handler,
    GObjectGetPropertyFunc ada_get_handler)
{
  GTypeQuery query;

  G_OBJECT_CLASS (klass->klass)->set_property = c_set_handler;
  G_OBJECT_CLASS (klass->klass)->get_property = c_get_handler;

  g_type_query (G_TYPE_FROM_CLASS (klass->klass), &query);
  *(GObjectGetPropertyFunc*)((char*)(klass->klass)
      + query.class_size
      - sizeof (GObjectGetPropertyFunc)
      - sizeof (GObjectSetPropertyFunc)) = ada_get_handler;
  *(GObjectSetPropertyFunc*)((char*)(klass->klass)
      + query.class_size
      - sizeof (GObjectSetPropertyFunc)) = ada_set_handler;
}

GObjectGetPropertyFunc
ada_real_get_property_handler (GObject* object)
{
  GTypeQuery query;
  g_type_query (G_TYPE_FROM_INSTANCE (object), &query);
  return *(GObjectGetPropertyFunc*)((char*)(G_OBJECT_GET_CLASS (object))
				  + query.class_size
 			     - sizeof (GObjectGetPropertyFunc)
				  - sizeof (GObjectSetPropertyFunc));
}

GObjectSetPropertyFunc
ada_real_set_property_handler (GObject* object)
{
  GTypeQuery query;
  g_type_query (G_TYPE_FROM_INSTANCE (object), &query);
  return *(GObjectSetPropertyFunc*)((char*)(G_OBJECT_GET_CLASS (object))
				  + query.class_size
				  - sizeof (GObjectSetPropertyFunc));
}

void
ada_genum_create_enum_value
  (gint value, gchar* name, gchar* nick, GEnumValue* val)
{
  val->value = value;
  val->value_name = g_strdup (name);
  val->value_nick = g_strdup (nick);
}

/******************************************
 ** GType                                **
 ******************************************/

GType
ada_gtype_fundamental (GType type)
{
  return G_TYPE_FUNDAMENTAL (type);
}

gboolean
ada_g_type_is_interface (GType type)
{
  return G_TYPE_IS_INTERFACE (type);
}

/******************************************
 ** Handling of tree Freeze/Thaw         **
 ******************************************/

gint
ada_gtk_tree_view_freeze_sort (GtkTreeStore* tree)
{
  gint save;
  GtkSortType order;
  gtk_tree_sortable_get_sort_column_id
    (GTK_TREE_SORTABLE (tree), &save, &order);
  gtk_tree_sortable_set_sort_column_id (GTK_TREE_SORTABLE (tree), -2, order);
  return save;
}

void
ada_gtk_tree_view_thaw_sort (GtkTreeStore* tree, gint id)
{
  gint save;
  GtkSortType order;
  gtk_tree_sortable_get_sort_column_id
    (GTK_TREE_SORTABLE (tree), &save, &order);
  gtk_tree_sortable_set_sort_column_id
    (GTK_TREE_SORTABLE (tree), id, order);
}

/*****************************************************
 ** Glib
*****************************************************/

struct CustomGSource
{
  GSource source;
  gpointer user_data;
};

GSourceFuncs*
ada_allocate_g_source_funcs
  (gpointer prepare, gpointer check, gpointer dispatch, gpointer finalize)
{
  GSourceFuncs* result;
  result = (GSourceFuncs*) malloc (sizeof (GSourceFuncs));

  result->prepare  = prepare;
  result->check    = check;
  result->dispatch = dispatch;
  result->finalize = finalize;
  return result;
}

GSource*
ada_g_source_new (GSourceFuncs* type, gpointer user_data)
{
  struct CustomGSource* result =
    (struct CustomGSource*)g_source_new (type, sizeof (struct CustomGSource));
  result->user_data = user_data;
  return (GSource*)result;
}

gpointer
ada_g_source_get_user_data (GSource* source)
{
  return ((struct CustomGSource*)source)->user_data;
}

/***********************************************************
 ** Gtk_Text_Buffer
***********************************************************/

void
ada_gtk_text_buffer_insert_with_tags
 (GtkTextBuffer *buffer,
  GtkTextIter   *iter,
  const gchar   *text,
  gint           len,
  GtkTextTag    *tag)
{
  gtk_text_buffer_insert_with_tags
    (buffer, iter, text, len, tag, NULL);
}

GtkTextTag*
ada_gtk_text_buffer_create_tag (GtkTextBuffer* buffer, const gchar* name)
{
   return gtk_text_buffer_create_tag (buffer, name, NULL);
}

/***********************************************************
 ** Gtk_File_Chooser_Dialog
***********************************************************/

GtkWidget *
ada_gtk_file_chooser_dialog_new
  (const gchar          *title,
   GtkWindow            *parent,
   GtkFileChooserAction  action)
{
  return gtk_file_chooser_dialog_new
    (title, parent, action, NULL, (char *)NULL);
}

/***********************************************************
 ** Gtk_Recent_Chooser_Dialog
***********************************************************/

GtkWidget*
ada_gtk_recent_chooser_dialog_new
  (const gchar *title,
   GtkWindow   *parent)
{
  return gtk_recent_chooser_dialog_new (title, parent, NULL, NULL);
}

GtkWidget*
ada_gtk_recent_chooser_dialog_new_for_manager
  (const gchar      *title,
   GtkWindow        *parent,
   GtkRecentManager *manager)
{
  return gtk_recent_chooser_dialog_new_for_manager
    (title, parent, manager, NULL, NULL);
}

/**************************************************************
 **  Gtk_Bindings
**************************************************************/

void
ada_gtk_binding_entry_add_signal_NO
  (GtkBindingSet* set, guint keyval, GdkModifierType modifier,
   const gchar* signal_name)
{
  gtk_binding_entry_add_signal (set, keyval, modifier, signal_name, 0);
}

void
ada_gtk_binding_entry_add_signal_int
  (GtkBindingSet* set, guint keyval, GdkModifierType modifier,
   const gchar* signal_name, gint arg1)
{
  gtk_binding_entry_add_signal
    (set, keyval, modifier, signal_name, 1,
     G_TYPE_INT, arg1);
}

void
ada_gtk_binding_entry_add_signal_int_int
  (GtkBindingSet* set, guint keyval, GdkModifierType modifier,
   const gchar* signal_name, gint arg1, gint arg2)
{
  gtk_binding_entry_add_signal
    (set, keyval, modifier, signal_name, 2,
     G_TYPE_INT, arg1, G_TYPE_INT, arg2);
}

void
ada_gtk_binding_entry_add_signal_bool
  (GtkBindingSet* set, guint keyval, GdkModifierType modifier,
   const gchar* signal_name, gboolean arg1)
{
  gtk_binding_entry_add_signal
    (set, keyval, modifier, signal_name, 1,
     G_TYPE_BOOLEAN, arg1);
}

GdkModifierType
ada_gdk_get_default_modifier ()
{
#ifdef GDK_QUARTZ_BACKEND
  return GDK_MOD1_MASK;
#else
  return GDK_CONTROL_MASK;
#endif
}


// GtkPlug is only build on X11 backends

#ifndef GDK_WINDOWING_X11
int gtk_plug_get_type() {
   return 0;
}
int gtk_socket_get_type() {
   return 0;
}
#endif
