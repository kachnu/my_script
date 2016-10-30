#!/usr/bin/env python
# -*- coding:utf-8 -*-
#
#      antix2usb.py
#
#      Copyright 2012 antiX team
#
#      This program is free software; you can redistribute it and/or modify
#      it under the terms of the GNU General Public License as published by
#      the Free Software Foundation; either version 2 of the License, or
#      (at your option) any later version.
#
#      This program is distributed in the hope that it will be useful,
#      but WITHOUT ANY WARRANTY; without even the implied warranty of
#      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#      GNU General Public License for more details.
#
#      You should have received a copy of the GNU General Public License
#      along with this program; if not, write to the Free Software
#      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#

#-------------------------------------------------------------------------------
import pygtk
pygtk.require('2.0')
import gtk
import gtk.glade
import pango
import getopt
import locale

import os, sys
import gobject
import glib
import subprocess, shlex
import signal

#-------------------------------------------------------------------------------
DO_DEBUG = False # Set by option -d
DO_TEST = False  # Set by option -t

ANTIX2USB_GLADE = 'antix2usb.glade'
ANTIX2USB_SCRIPT = "antix2usb.sh"
ANTIX2USB_PREFIX = "antix2usb" # glade file expected under /usr/share/antix2usb

# About dialog
APP_NAME = "antix2usb" 
APP_COPYRIGHT = "\302\251 Copyright 2013 the antiX team"
APP_WEBSITE = "http://antix.freeforums.org"
APP_VERSION = "13.0.0"
APP_DATE = "2013/05/13"

# Help
HTML_HELP_FILE = "http://www.mepiscommunity.org/wiki/help-files/help-mx-create-live-usb-antix2usb"

# Default sizes for persistence files
HOMEFS_DEFAULT_SIZE = 256
ROOTFS_DEFAULT_SIZE = 512

LANGUAGES = [["bg_BG", "Bulgarian"],
    ["lang=ca_ES", "Catalan"],
    ["lang=cs_CZ", "Czech"],
    ["lang=da_DK", "Danish"],
    ["lang=de_DE", "German"],
    ["lang=el_GR", "Greek"],
    ["lang=en_GB", "English (GB)"],
    ["",           "English (US)"],
    ["lang=es_ES", "Spanish"],
    ["lang=fr_FR", "French"],
    ["lang=hr_HR", "Croatian"],
    ["lang=hu_HU", "Hungarian"],
    ["lang=it_IT", "Italian"],
    ["lang=ja_JP", "Japanese"],
    ["lang=nl_NL", "Dutch"],
    ["lang=pl_PL", "Polish"],
    ["lang=pt_BR", "Portuguese (Brasil)"],
    ["lang=pt_PT", "Portuguese (Portugal)"],
    ["lang=ro_RO", "Romanian"],
    ["lang=ru_RU", "Russian"],
    ["lang=se_SV", "Swedish"],
    ["lang=uk_UA", "Ukrainian"]
    ]

#-------------------------------------------------------------------------------
# TODO: Path to glade file...
# During execution: a Quit btn to kill the script, and on termination, a Close
# button to close the application
# A Quit Dialog confirmation?
# TODO: restaurer check_params, a installer sur "Next", avant la page confirm
# restaurer set_sensitive(false) sur next_button (pas sur apply)
# ** TODO Ajouter recherche du chemin du script Shell et du fichier glade **
# TODO Ajouter cheat code lang
# Nommer ces fichiers !!!
#
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# Utils
#
def debug(str):
    if DO_DEBUG:
        print str

def usage():
    prog_name = os.path.basename(sys.argv[0])
    print "Usage: " + prog_name + " [OPTIONS...]"
    print "Options:"
    print "  -h  Print this message"
    print "  -v  Print version"
    print "  -d  Show debugging information while processing"     
    print "  -t  Show debugging information and do not execute installation"     

def find_shell_script(filename):
    # this_file_dir = os.path.split(__file__)[0]
    # sys.path[0] is the directory containing **this** script "that was used 
    # to invoke the Python interpreter"
    path_list = os.environ["PATH"].split(os.pathsep)
    path_list.insert(0, sys.path[0]) 
    print path_list
    for fpath in path_list:
        exe_file = os.path.join(fpath, filename)
        if os.path.exists(exe_file) and os.access(exe_file, os.X_OK):
            if DO_DEBUG: print "Accessing " + filename + " as: " + exe_file
            
            return exe_file
    # Not found
    print "file " + filename + " not found."
    return None

def find_shell_script_old(filename):
    # this_file_dir = os.path.split(__file__)[0]
    # path[0] is the directory containing **this** script "that was used 
    # to invoke the Python interpreter"
    path_list = [
        os.path.join(sys.path[0], filename),
        os.path.join(sys.prefix, 'bin', filename),
        os.path.join(sys.prefix, 'local', 'bin', filename)
        ]
    # print path_list
    for fpath in path_list:
        if os.path.exists(fpath) and os.access(fpath, os.X_OK):
            if DO_DEBUG: print "Accessing " + filename + " as: " + fpath
            
            return fpath
    # Not found
    print "file " + filename + " not found."
    return None

def find_glade_file(dir, filename):
    path_list = [
        os.path.join(sys.path[0], filename),
        os.path.join(sys.prefix, 'share', dir, filename),
        os.path.join(sys.prefix, 'share', 'local', dir, filename)
        ]
    # print path_list
    for fpath in path_list:
        if os.path.isfile(fpath) and os.access(fpath, os.R_OK):
            if DO_DEBUG: print "Accessing " + filename + " as: " + fpath
            
            return fpath
    # Not found
    print "file " + filename + " not found."
    return None

def check_if_user_is_root():
    if os.getuid() != 0 :
        return False
    else:
        return True

#-------------------------------------------------------------------------------
# Dialogs
#
def warning_dialog(message):
    dlg = gtk.MessageDialog(gui.main_window, 0, gtk.MESSAGE_WARNING, gtk.BUTTONS_CLOSE, message)
    dlg.set_position(gtk.WIN_POS_CENTER_ON_PARENT)
    dlg.set_title("Warning")
    dlg.run()
    dlg.destroy()

def info_dialog(message):
    dlg = gtk.MessageDialog(gui.main_window, 0, gtk.MESSAGE_INFO, gtk.BUTTONS_CLOSE, message)
    dlg.set_position(gtk.WIN_POS_CENTER_ON_PARENT)
    dlg.set_title("Info")
    dlg.run()
    dlg.destroy()

def error_quit_dialog(message) :
    dialog = gtk.MessageDialog(None, 0, gtk.MESSAGE_ERROR, gtk.BUTTONS_CLOSE, message)
    dialog.set_position(gtk.WIN_POS_CENTER)
    dialog.run()
    sys.exit(1)

NO_USB_DEVICE_FOUND_ERROR="No removable USB device has been detected.\n\
Plug in the USB key and retry."

def retry_or_quit_dialog(message):
    dlg = gtk.MessageDialog(gui.main_window, 
                            gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
                            gtk.MESSAGE_WARNING, gtk.BUTTONS_OK_CANCEL, message)
    dlg.set_position(gtk.WIN_POS_CENTER_ON_PARENT)
    dlg.set_title("Warning")
    response = dlg.run()
    debug("retry_or_quit_dialog response: %s" % response)
    if response == gtk.RESPONSE_OK:
        debug("retry_or_quit_dialog response: OK")
        dlg.destroy()
        return True
    else:
        debug("retry_or_quit_dialog response: CANCEL")
        dlg.destroy()
        return False

def quit_confirm_dialog(message):
    dlg = gtk.MessageDialog(gui.main_window, 
                            gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
                            gtk.MESSAGE_WARNING, gtk.BUTTONS_OK_CANCEL, message)
    dlg.set_position(gtk.WIN_POS_CENTER_ON_PARENT)
    dlg.set_title("Warning")
    response = dlg.run()
    debug("retry_or_quit_dialog response: %s" % response)
    if response == gtk.RESPONSE_OK:
        debug("quit_confirm_dialog response: OK")
        dlg.destroy()
        return True
    else:
        debug("quit_confirm_dialog response: CANCEL")
        dlg.destroy()
        return False

def about_dialog(message):
    global gui
    dialog = gtk.AboutDialog()
    dialog.set_transient_for(gui.main_window)
    dialog.set_position(gtk.WIN_POS_CENTER_ON_PARENT)
    dialog.set_name(APP_NAME)
    dialog.set_comments("Version: " + APP_VERSION + " " + APP_DATE)
    dialog.set_copyright(APP_COPYRIGHT)
    dialog.set_website(APP_WEBSITE)
    ## Close dialog on user response
    dialog.connect ("response", lambda d, r: d.destroy())
    dialog.run()
  
#------------------------------------------------------------------------------
# Class Data: parameters
#
class Data:
    
    def __init__(self):
        # ISO file: complete path
        self.iso_file_path = ""
        self.iso_file_size = 0
        self.iso_name = "ISO file ?" # basename, extension stripped
        # Current selected device: sdx
        self.device = "nodev"
        self.device_description = ""
        # Size of the first partition
        self.full_device = False
        self.partition_size = 1024
        self.partition_min_size = 1024
        self.partition_max_size = 4096
        # File system
        self.format = "ext4"
        self.bootloader = "extlinux"
        self.persistence = "none"
        
        # Persistence files
        self.homefs_size = HOMEFS_DEFAULT_SIZE
        self.rootfs_size = ROOTFS_DEFAULT_SIZE
        self.language = ""

        self.devices_list = []
        self.devices_info_list = []
        self.devices_size = {}

    def print_params(self):
        print "--------------------------------"
        print "iso_name: %s" % self.iso_name
        print "iso_file_path: %s" % self.iso_file_path
        print "iso_file_size: %d" % self.iso_file_size
        print "device: %s" % self.device
        print "format: %s" % self.format
        print "bootloader: %s" % self.bootloader
        print "full_device: %s" % self.full_device
        print "partition_size: %s" % self.partition_size
        print "partition_min_size: %s" % self.partition_min_size
        print "partition_max_size: %s" % self.partition_max_size
        print "persistence: %s" % self.persistence
        print "language: %s" % self.language
        print "--------------------------------"

    def get_usb_devices(self):
        debug("Data.get_usb_devices")
        # devices names: sdb, sdc
        devlist = []
        devices = []
        self.device_size = {}

        # Get a list of usb devices (not partitions)
        cmd = "ls /dev/disk/by-id/usb-* 2>/dev/null | grep -v '\-part[0-9]' "
        for line in os.popen(cmd).readlines():
            # We got links, get the /dev/sdx path
            cmd2 = "readlink -f %s" % line
            lnk = os.popen(cmd2).readlines()[0][:-1] # strip end of line
            if lnk[-1].isdigit() :
                # Presume it a CD-rom burner
                debug ("Ignoring " + lnk)
                continue
            # We have now a /dev/sdx device path: get the name: sdx
            device_name = lnk.split('/')[2]
            devlist.append(device_name)

        # cat /proc/partitions and sort by name
        cmd = "cat /proc/partitions | grep '[h,s].[a-z]$' | sort --key=4 2> /dev/null"   

        # I would like to have the self.device_size
        for line in os.popen(cmd).readlines():       # run command            
            fields = line.split()
            dev = fields[3]                          # dev: sdx or hdx
            size = int(fields[2]) / 1024             # size in MB
            self.device_size[dev] = size

        # Now prepare a list of devices: name description size
        for dev in devlist :
            # vendor and model are fixed size strings completed with spaces
            cmd = "cat /sys/block/" + dev + "/device/vendor"
            vendor = os.popen(cmd).readlines()[0][:-1].strip().rstrip()
            cmd = "cat /sys/block/" + dev + "/device/model"
            model = os.popen(cmd).readlines()[0][:-1].strip().rstrip()
            # my description: vendor + model    
            description = vendor + " " + model
            try :
                size = self.device_size[dev]
                str = "%s %s %6d MB" % (dev, description, self.device_size[dev])
            except KeyError :
                # device not listed in /proc/partitions
                str = "%s %s" % (dev, description)

            devices.append(str)
     
        self.devices_list = devlist
        self.devices_info_list = devices

        if devlist:
            self.device = devlist[0]
            #gui.device_combobox.set_list(devices)
            gui.update_devices(devices)
            self.partition_max_size = self.device_size[self.device]
            # Set max size in partition size combobox
            gui.update()
            return True
        else:
            return False

    def check_params(self):
        """ Returns True when ok"""
        # ISO file name set?
        if self.iso_file_path == "" :
            warning_dialog("No ISO file selected!")
            return False
        # ISO file exists?
        if not os.path.isfile(self.iso_file_path) :
            warning_dialog("Cannot access file %s" % self.iso_file_path)
            return False
        # Is it a ISO file?
        # Removed this because of this:
        # $ file antiX-13_x64-base.iso
        # antiX-13_x64-base.iso: x86 boot sector
        #~ type = os.popen("file -b %s" % self.iso_file_path).readlines()[0]
        #~ name = os.path.basename(self.iso_file_path)
        #~ if type.find("ISO") < 0:
            #~ warning_dialog("File '%s' does not look like an ISO file." % name)
            #~ return False
        # Does the ISO fit into the partition?
        req_size = int(self.iso_file_size) + 30
        if req_size > self.partition_size :
            warning_dialog("File '%s' does not fit \nin %s MB partition"
                           % (name, self.partition_size))
            return False
        # Do the homefs and rootfs fit into the partition?
        if self.full_device:
            available_space = self.partition_max_size
        else:
            available_space = self.partition_size
        if self.persistence == "home":
            req_size += self.homefs_size
            if req_size  > available_space :
                print "Required size: %d MB" % (req_size) 
                warning_dialog("You need extra space for %s persistence file in the partition.\n\n\
Estimated minimum partition size is %d MB" % (self.persistence, req_size))
                return False
        elif self.persistence == "root":
            req_size += self.rootfs_size
            if req_size  > available_space :
                print "Required size: %d MB" % (req_size) 
                warning_dialog("You need extra space for %s persistence file in the partition.\n\n\
Estimated minimum partition size is %d MB" % (self.persistence, req_size))
                return False
        elif self.persistence == "both":
            req_size = req_size + self.rootfs_size + self.homefs_size
            if req_size  > available_space :
                print "Required size: %d MB" % (req_size) 
                warning_dialog("You need extra space for root and home persistence files in the partition.\n\n\
Estimated minimum partition size is %d MB" % req_size)
                return False
                
        if self.device == "":
            warning_dialog("No device selected")
            return False
        return True

    def check_device_mounted(self):
        debug("Data.check_device_mounted")
        msg = ""
        status = True # OK, device is not mounted
        dev = self.device
        # Get a list of mounted /dev/xxx partitions
        cmd = "mount | grep '^/dev'"
        for line in os.popen(cmd).readlines() :
            #print "**** check_device_mounted: line: [%s] dev: [%s]" % (line.strip(), dev)
            chunks = line.split()
            if dev and chunks[0].find(dev) >= 0 :
                msg = "Device %s appears to be mounted on %s\n" % (chunks[0], chunks[2])
                msg += "Unmount the device and prevent any application\n"
                msg += "to auto-mount it.\n"
                warning_dialog(msg)
                return False 
        return True # Ok

    def build_command_line(self):
        if debug :
            print "AntixUsbLiveData.build_command_line:"
            self.print_params()

        ## Done in on_next_button_clicked
        # status = self.check_params()
        # if not status :
        #    return ""

        # -q : "quiet" option: script will not ask for confirmation
        # we don't want to have the script hanging waiting for user input 
        args = "-q "
        
        # The ISO
        args += "-f %s " % self.format
        if self.full_device == False:
            args += "-s %d " % self.partition_size
        else:
            # no partition size in the command line defaults to full device
            pass 

        # persistence
        if self.persistence == "root":
            args += "-p root "
            args += "--rootfssz %d " % self.rootfs_size
        elif self.persistence == "home":
            args += "-p home "
            args += "--homefssz %d " % self.homefs_size
        elif self.persistence == "both":
            args += "-p both "
            args += "--rootfssz %d " % self.rootfs_size
            args += "--homefssz %d " % self.homefs_size
        if DO_DEBUG :
            args += "-d "
            
        # bootloader
        args += "-b %s " % self.bootloader

        #if options.defaultCheatcodesPresent :
        args += "%s " % self.iso_file_path

        # The target device
        args += "/dev/" + self.device + " "

        args += self.language
        
        exec_file = find_shell_script(ANTIX2USB_SCRIPT)
        cmd = exec_file + " " + args
        return cmd



#-------------------------------------------------------------------------------
# Class MainWindow
#

# List of widgets
# ------------------------------------------------------------------------------
# id                       class              handler
# ------------------------------------------------------------------------------
# iso_filechooserbutton    GtkFileChooserButton on_iso_filechooserbutton_file_set
# size_combobox            GtkComboBox        on_size_combobox_changed
# full_device_checkbutton  GtkCheckButton     on_full_device_checkbutton_toggled
# partition_size_spinbutton  GtkSpinButton    on_partition_size_spinbutton_value_changed
# language_combobox        GtkComboBox        on_language_combobox_changed
# ext4_radiobutton         GtkRadioButton     on_ext4_radiobutton_toggled
# fat32_radiobutton        GtkRadioButton     on_fat32_radiobutton_toggled
# extlinux_radiobutton     GtkRadioButton     on_extlinux_radiobutton_toggled
# grub_radiobutton         GtkRadioButton     on_grub_radiobutton_toggled
# syslinux_radiobutton     GtkRadioButton     on_syslinux_radiobutton_toggled
# persist_root_checkbutton GtkCheckButton     on_persist_root_checkbutton_toggled
# persist_home_checkbutton GtkCheckButton     on_persist_home_checkbutton_toggled
# cancel_button            GtkButton          on_cancel_button_clicked
# apply_button             GtkButton          on_apply_button_clicked
# ------------------------------------------------------------------------------


class AntixUsbGui(object):
    
    # Index of pages
    SETTINGS = 0
    CONFIRM = 1
    EXEC = 2

    def __init__(self):
        
        # Data object stores parameters collected from the gui
        # build and executes the subprocess
        self.data = Data()
        self.child_process = None
        
        # Load the gui
        self.builder = gtk.Builder()
        path = find_glade_file(ANTIX2USB_PREFIX, ANTIX2USB_GLADE)
        self.builder.add_from_file(path)
        self.builder.connect_signals(self)
        
        # Hooks to the interface components
        self.main_window = self.builder.get_object("main_window")
        self.main_window.set_title(APP_NAME)
        self.main_vbox = self.builder.get_object("main_vbox")
        
        # This is the first page of the dialog: a HBox containing two vertical
        # panes
        self.top_hbox = self.builder.get_object("top_hbox")
        self.page_settings = self.top_hbox
        self.current_page_id = self.SETTINGS

        # Left vbox
        self.iso_filechooserbutton = self.builder.get_object("iso_filechooserbutton")
        filter = gtk.FileFilter()
        filter.set_name("ISO files")
        filter.add_mime_type("application/x-cd-image")
        filter.add_pattern("*.iso")
        filter.add_pattern("*.ISO")
        self.iso_filechooserbutton.add_filter(filter)

        self.device_combobox = self.builder.get_object("device_combobox")
        self.device_store = gtk.ListStore(gobject.TYPE_STRING)
        self.device_combobox.set_model(self.device_store)
        cell = gtk.CellRendererText()
        self.device_combobox.pack_start(cell, True)
        self.device_combobox.add_attribute(cell, 'text', 0)
        self.device_combobox.set_property('width-request', 260) 

        self.full_device_checkbutton = self.builder.get_object("full_device_checkbutton")
        self.partition_size_spinbutton = self.builder.get_object("partition_size_spinbutton")
        self.language_combobox = self.builder.get_object("language_combobox")
        
        # Language combobox and model
        self.language_combobox = self.builder.get_object("language_combobox")
        self.language_store = gtk.ListStore(gobject.TYPE_STRING, gobject.TYPE_STRING)
        self.language_combobox.set_model(self.language_store)
        cell = gtk.CellRendererText()
        self.language_combobox.pack_start(cell, True)
        self.language_combobox.add_attribute(cell, 'text', 1)
        self.language_store.clear()

        code, encoding = locale.getdefaultlocale()
        i = 0
        index = 7 # index of English (US) in LANGUAGES
        for lang in LANGUAGES:
            self.language_store.append(row = lang)
            if lang[0] == code:
                index = i
                # print "*** Got lang: %s index: %d" % (code, index)
            i += 1
        self.language_combobox.set_active(index) 
        code = self.language_combobox.get_model()[index][0]
        self.data.language = code
 
        # Right vbox
        self.options_frame = self.builder.get_object("options_frame")
        self.options_frame.set_property('width-request', 220)
        self.ext4_radiobutton = self.builder.get_object("ext4_radiobutton")
        self.fat32_radiobutton = self.builder.get_object("fat32_radiobutton")
        self.extlinux_radiobutton = self.builder.get_object("extlinux_radiobutton")
        self.grub_radiobutton = self.builder.get_object("grub_radiobutton")
        self.syslinux_radiobutton = self.builder.get_object("syslinux_radiobutton")
        self.persist_root_checkbutton = self.builder.get_object("persist_root_checkbutton")
        self.persist_home_checkbutton = self.builder.get_object("persist_home_checkbutton")
        self.rootfs_size_spinbutton = self.builder.get_object("rootfs_size_spinbutton")
        self.homefs_size_spinbutton = self.builder.get_object("homefs_size_spinbutton")
        self.rootfs_size_spinbutton.set_value(self.data.rootfs_size)
        self.homefs_size_spinbutton.set_value(self.data.homefs_size)
        self.homefs_size_spinbutton.set_sensitive(False)
        self.rootfs_size_spinbutton.set_sensitive(False)

        # Button row
        self.apply_button = self.builder.get_object("apply_button")
        self.cancel_button = self.builder.get_object("cancel_button")
        self.close_button = self.builder.get_object("close_button")
        self.quit_button = self.builder.get_object("quit_button")
        self.previous_button = self.builder.get_object("previous_button")
        self.next_button = self.builder.get_object("next_button")
        self.about_button = self.builder.get_object("about_button")
        self.help_button = self.builder.get_object("help_button")
        self.next_button.set_sensitive(False)
        self.apply_button.set_sensitive(False)

        # First page (settings) buttons => Cancel or Next
        self.previous_button.hide()
        self.close_button.hide()
        self.quit_button.hide()
        self.apply_button.hide()
        self.next_button.show()
        self.cancel_button.show()
        
        #-----------------------------------------------------------------------
        # Build the page for execution
        # This page controls the execution of the shell script and provides 
        # feedback to the user
        #
        # Frame
        #  |__ ScrolledWindow
        #        |__ CommandTextView
        #              |__ TextBuffer
        #
        self.text_frame = gtk.Frame("Installing...")
        self.page_exec = self.text_frame
        self.text_frame.set_border_width(10)
        self.text_frame.set_shadow_type(gtk.SHADOW_NONE)

        self.scrolled_window = gtk.ScrolledWindow()
        self.scrolled_window.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
        
        self.command_textview = CommandTextView(self)
        self.command_textview.modify_font(pango.FontDescription("monospace 9"))
        self.command_textview.modify_base(gtk.STATE_NORMAL, gtk.gdk.Color("black"))
        self.command_textview.modify_text(gtk.STATE_NORMAL, gtk.gdk.Color("white"))

        self.text_buffer = self.command_textview.get_buffer()

        # ----------------------------------------------------------------------
        # Build the confirmation page
        #
        confirm_alignment = gtk.Alignment()
        self.page_confirm = confirm_alignment
        confirm_alignment.set_padding(10, 10, 10, 10)
        self.confirm_label = gtk.Label()
        self.confirm_label.set_line_wrap(True)
        self.confirm_label.set_use_markup(True)
        self.confirm_label.connect("size-allocate", self.on_label_size_request)

        confirm_alignment.add(self.confirm_label)

        self.scrolled_window.add(self.command_textview)
        self.text_frame.add(self.scrolled_window)

        # Show the main window (first page: settings)
        self.main_window.show()        
    
    def on_label_size_request(self, label, size ):
        # print "on_label_size_request"
        pass

    def set_format(self, format):
        if format != self.data.format:
            self.data.format = format
            self.update()
        
    def set_bootloader(self, bootloader):
        if bootloader != self.data.bootloader:
            self.data.bootloader = bootloader
            self.update()
        
    def set_persistence(self, persistence):
        if persistence != self.data.persistence:
            self.data.persistence = persistence
        
    def on_about_button_clicked(self, widget):
        # print "on_about_button_clicked"
        about_dialog("Hello")
        pass

    def on_next_button_clicked(self, widget):
        # print "on_next_button_clicked"
        status = self.data.check_params()
        if status:
            status = self.data.check_device_mounted()
        
        if not status :
            self.show_settings()
        elif self.current_page_id == self.SETTINGS:
            self.data.print_params()
            print self.summary()
            self.show_confirm()

    def on_previous_button_clicked(self, widget):
        # print "on_previous_button_clicked"
        if self.current_page_id == self.CONFIRM:
            # Back to first page
            self.show_settings()

    def on_apply_button_clicked(self, widget):
        if self.current_page_id == self.CONFIRM:
            command = self.data.build_command_line()
            self.show_execution()
            
            if command and DO_TEST:
                # Print command and return
                print "Dry test: command: [%s]" % command
                return
            if command :
                debug("Executing " + command)
                #print "***** THIS IS A TEST: EXECUTING A STUB COMMAND *******"
                #test_command = "./count.sh"
                #self.command_textview.set_command(test_command)
                self.command_textview.set_command(command)
                self.command_textview.run()

    def on_close_button_clicked(self, widget):
        # print "on_close_button_clicked"
        self.close_application()
        pass

    def on_cancel_button_clicked(self, widget):
        # print "on_cancel_button_clicked"
        self.close_application()
        pass

    def on_help_button_clicked(self, widget):
        # print "on_help_button_clicked"
        #if os.path.exists(HTML_HELP_FILE) and os.access(HTML_HELP_FILE, os.R_OK):
        #    help_cmd = "x-www-browser " + HTML_HELP_FILE + " &"
        #    os.popen(help_cmd)
        #else:
        #    warning_dialog("Sorry, Cannot find help file.")
        #pass
        help_cmd = "mx-viewer " + HTML_HELP_FILE + " &"
        os.popen(help_cmd)

    def on_quit_button_clicked(self, widget):
        # print "on_quit_button_clicked"
        if not self.child_process is None:
            # Send SIGTERM signal
            # print "Calling terminate..."
            self.child_process.terminate()
            self.child_process.wait()
            msg = "\nProcess interrupted by user.\n"
            warning_dialog(msg)
            # close_application()
        pass

    def on_language_combobox_changed(self, widget):
        # print "on_language_combobox_changed"
        model = self.language_store
        active = widget.get_active()
        if active < 0:
            return None
        code = model[active][0]
        self.data.language = code
        # print "on_language_combobox_changed: code: " + code
        pass

    def on_main_window_delete_event(self, widget, event, data=None):
        # If you return FALSE in the "delete_event" signal handler,
        # GTK will emit the "destroy" signal. Returning TRUE means
        # you don't want the window to be destroyed.
        # This is useful for popping up 'are you sure you want to quit?'
        # type dialogs.
        print "on_main_window_delete_event"
        answer = quit_confirm_dialog("Are you sure you want to quit?")
        # The main window will be destroyed if return value is False.
        if answer:
            # Quit => close the application
            # print "on_main_window_delete_event Quit"
            self.close_application()
            return False
        else:
            # Cancel
            # print "on_main_window_delete_event Cancel"
            return True

    def on_main_window_destroy_event(self, widget, data=None):
        ## ? Investigate: don't catch a destroy event, even when the delete
        ## callback returns True 
        ## => close_application now in: on_main_window_delete_event
        # print "on_main_window_destroy_event"
        self.close_application()
 
    # In these callbacks: block *this* callback on enter, unblock when leaving
    # to prevent infinite loops: get_active sends a toggled event for radiobuttons
    # in the same group, including *this* button...
    # 
    def on_format_radiobutton_toggled(self, widget):
        #print "on_format_radiobutton_toggled"
        widget.handler_block_by_func(self.on_format_radiobutton_toggled)
        if widget == self.ext4_radiobutton and widget.get_active():
             self.set_format("ext4")
        elif widget == self.fat32_radiobutton and widget.get_active():
             self.set_format("fat32")
        widget.handler_unblock_by_func(self.on_format_radiobutton_toggled)
        pass

    def on_bootloader_radiobutton_toggled(self, widget):
        widget.handler_block_by_func(self.on_bootloader_radiobutton_toggled)
        # print "on_bootloader_radiobutton_toggled"
        if widget == self.extlinux_radiobutton and widget.get_active():
             self.set_bootloader("extlinux")
        if widget == self.grub_radiobutton and widget.get_active():
             self.set_bootloader("grub")
        if widget == self.syslinux_radiobutton and widget.get_active():
             self.set_bootloader("syslinux")
        widget.handler_unblock_by_func(self.on_bootloader_radiobutton_toggled)
        pass

    def on_persist_checkbutton_toggled(self, widget):
        self.homefs_size_spinbutton.set_sensitive(False)
        self.rootfs_size_spinbutton.set_sensitive(False)
        if self.persist_root_checkbutton.get_active() and self.persist_home_checkbutton.get_active():
            self.set_persistence("both")
            self.homefs_size_spinbutton.set_sensitive(True)
            self.rootfs_size_spinbutton.set_sensitive(True)
        elif self.persist_root_checkbutton.get_active():
            self.set_persistence("root")
            self.rootfs_size_spinbutton.set_sensitive(True)
        elif self.persist_home_checkbutton.get_active():
            self.set_persistence("home")
            self.homefs_size_spinbutton.set_sensitive(True)
        else:
            self.set_persistence("none")
        
    def on_iso_filechooserbutton_file_set(self, widget):
        value = widget.get_filename()
        # If Cancel clicked...
        if value == None :
            warning_dialog("No ISO file selected!")
            return
        self.data.iso_file_path = value
        # Store file size in MB
        size = os.path.getsize(self.data.iso_file_path) 
        self.data.iso_file_size = size / (1024*1024)
        # Add 30 MB and round up to 64 MB
        self.data.partition_min_size = ((self.data.iso_file_size + 30 + 64) / 64) * 64
        if self.data.partition_min_size > self.data.partition_size :
            self.data.partition_size = self.data.partition_min_size
        # Update min size of size combobox
        gui.update()
        # Get the name of the ISO, '.iso' extension stripped
        name = os.path.basename(self.data.iso_file_path)
        i = name.find(".iso")
        if i > 0 :
            self.data.iso_name = name[0:i]
        else :
            print "Selected file does not look like an ISO file."
            warning_dialog("Selected file does not look like an ISO file.")
            self.data.iso_name = ""
        if self.data.iso_name and self.data.device:
            self.next_button.set_sensitive(True)

        debug ("AntixUsbLiveGui.on_iso_filechooserbutton_file_set")
        debug("   ISO name: %s\n   path: '%s'\n   size: %.1f MB" \
                         % (self.data.iso_name, self.data.iso_file_path, self.data.iso_file_size))
        return

    def on_partition_size_spinbutton_value_changed(self, widget):
        self.data.partition_size = widget.get_value_as_int()
        #print "on_partition_size_spinbutton_value_changed: %d" % self.data.partition_size
        pass

    def on_homefs_size_spinbutton_value_changed(self, widget):
        self.data.homefs_size = widget.get_value_as_int()
        #print "on_homefs_size_spinbutton_value_changed: %d" % self.data.homefs_size
        pass

    def on_rootfs_size_spinbutton_value_changed(self, widget):
        self.data.rootfs_size = widget.get_value_as_int()
        #print "on_rootfs_size_spinbutton_value_changed: %d" % self.data.rootfs_size
        pass

    def on_device_combobox_changed(self, widget):
        # print "on_device_combobox_changed"
        model = self.device_store
        active = widget.get_active()
        if active < 0:
            return None
        devtext = model[active][0]
        self.data.device_description = devtext
        dev = devtext.split()[0]
        self.data.device = dev
        pass

    def on_refresh_devices_button_clicked(self, widget):
        #print "on_refresh_devices_button_clicked"
        self.data.get_usb_devices()
        pass

    def on_full_device_checkbutton_toggled(self, widget):
        # print "on_full_device_checkbutton_toggled"
        widget.handler_block_by_func(self.on_full_device_checkbutton_toggled)
        self.data.full_device = widget.get_active()
        self.update()
        widget.handler_unblock_by_func(self.on_full_device_checkbutton_toggled)
        pass
        
    def update_devices(self, devices):
        combo = self.device_combobox
        self.device_store.clear()
        for device in devices:
            if device:
                # print "======= " + device
                self.device_store.append(row=[device])
        # self.device_store.append(row=["sdc This is a test"])
        if devices:
            self.data.device_description = device[0]
            combo.set_active(0)
            
    def update_buttons(self):
        if self.current_page_index == 1:
            self.previous_button.hide()
            self.next_button.show()
            self.cancel_button.show()
            self.apply_button.hide()
            self.quit_button.hide()
        elif self.current_page_index == 2:
            self.previous_button.show()
            self.next_button.hide()
            self.cancel_button.hide()
            self.apply_button.show()
            self.quit_button.hide()
        elif self.current_page_index == 3:
            self.previous_button.hide()
            self.next_button.hide()
            self.cancel_button.hide()
            self.apply_button.hide()
            self.quit_button.show()
            self.quit_button.set_sensitive(False)
        if self.data.iso_file_path and self.data.device:
            self.apply_button.set_sensitive(True)
            self.next_button.set_sensitive(True)
        

    def update(self):
        """ 
        Update status or sensitivity of the various controls.
        Critical piece of code: the logics of mutual exclusion of fs, bootloader,
        and persistence. 
        gtk.ToggleButton.set_active() emits a toggled signal that calls 
        the on_btn_toggled() method which in turn emits also a toggled signal,
        entering an infinite loop.
        To avoid this, the code of the callbacks is guarded in a 
        handler_block_by_func and handler_unblock_by_func block.
        A better way to do it ?...
        """
        # prinf "AntixUsbLiveGui.update: entry")
        data = self.data
        format = self.data.format
        bootloader = self.data.bootloader
        if DO_DEBUG:
            self.data.print_params()

        self.partition_size_spinbutton.set_range(data.partition_min_size, 
                                       data.partition_max_size)
        self.partition_size_spinbutton.set_value(data.partition_size)

        if format == "fat32":
            self.syslinux_radiobutton.set_sensitive(True)
            self.syslinux_radiobutton.set_active(True)
            self.extlinux_radiobutton.set_sensitive(False)
            self.grub_radiobutton.set_sensitive(False)
            self.persist_home_checkbutton.set_sensitive(True)
            self.persist_root_checkbutton.set_sensitive(True)
            self.homefs_size_spinbutton.set_sensitive(True)
            self.rootfs_size_spinbutton.set_sensitive(True)
        else:
            if bootloader == "syslinux":
                bootloader = "extlinux"
            self.extlinux_radiobutton.set_sensitive(True)
            self.extlinux_radiobutton.set_active(bootloader == "extlinux")
            self.syslinux_radiobutton.set_sensitive(False)
            self.grub_radiobutton.set_sensitive(False)
            self.grub_radiobutton.set_active(bootloader == "grub")
            self.persist_home_checkbutton.set_sensitive(True)
            self.persist_root_checkbutton.set_sensitive(True)
            if self.persist_home_checkbutton.get_active():
                self.homefs_size_spinbutton.set_sensitive(True)
            if self.persist_root_checkbutton.get_active():
                self.rootfs_size_spinbutton.set_sensitive(True)
            
        if data.full_device:
            self.partition_size_spinbutton.set_sensitive(False)
        else:
            self.partition_size_spinbutton.set_sensitive(True)
            
        if data.iso_name and data.device:
            self.apply_button.set_sensitive(True)
            
    def summary(self):
        """ Format a summary of the current settings, to be displayed in the
        confirmation page (pango format)
        """
        data = self.data
        text = "Ready to install <b>%s\n</b>" % data.iso_name
        text += "on device <b>%s</b>\n\n" % data.device_description
        if data.full_device:
            text += "Installation will use full device.\n"
            text += "Format: <b>%s</b>.\n" % data.format
        else:
            text += "Installation will use <b>%d MB</b> on device.\n" % data.partition_size
            text += "Format of the partition: <b>%s</b>\n" % data.format
            
        if data.persistence == "root":
            text += "A persistent root file system will be created.\n"
        elif data.persistence == "home":
            text += "A persistent home file sytem will be created.\n"
        elif data.persistence == "both":
            text += "Persistent root and home file sytems will be created.\n"
               
        text += "The Live USB device will boot using <b>%s</b> bootloader.\n" % data.bootloader
       # text += "The Live USB device will boot using <b>%s</b> language.\n" % data.language
        text += "\n<b>All data existing on the device will be erased.</b>"
        return text

    def show_confirm(self):
        """ Display the confirmation page """
        # To get a correct line wrapping in the label...
        rect = self.page_settings.get_allocation()
        self.confirm_label.set_size_request(rect.width -20 , -1)

        # Set the text of the confirmation page
        txt = self.summary()
        self.confirm_label.set_markup(txt)
        
        # Replace the content of the main window
        self.main_vbox.remove(self.page_settings)
        self.main_vbox.pack_start(self.page_confirm)
        self.main_vbox.reorder_child(self.page_confirm, 0)
        self.page_confirm.show_all()
        
        # Adjust buttons: second page (Confirm) => Previous or Apply
        self.previous_button.show()
        self.close_button.hide()
        self.apply_button.show()
        self.next_button.hide()
        self.cancel_button.show()
        self.about_button.hide()
        
        self.current_page_id = self.CONFIRM

    def show_execution(self):
        """ Display the execution page """
        # Switch page
        self.main_vbox.remove(self.page_confirm)
        self.main_vbox.pack_start(self.page_exec)
        self.main_vbox.reorder_child(self.page_exec, 0)
        self.page_exec.show_all()
        
        # Adjust buttons: last page (execution) => Quit
        self.previous_button.hide()
        self.close_button.hide()
        self.quit_button.show()
        self.apply_button.hide()
        self.next_button.hide()
        self.cancel_button.hide()
        
        self.current_page_id = self.EXEC

    def show_settings(self):
        """ Display the main page, on "Previous" button clicked """
        # Return to first page
        self.main_vbox.remove(self.page_confirm)
        self.main_vbox.pack_start(self.page_settings)
        self.main_vbox.reorder_child(self.page_settings, 0)
        #self.page_settings.show_all()
        
        # Buttons: back to first page (settings) => Cancel or Next
        self.previous_button.hide()
        self.close_button.hide()
        self.apply_button.hide()
        self.next_button.show()
        self.cancel_button.show()
        self.about_button.show()
        
        self.current_page_id = self.SETTINGS
       
    def close_application(self):
        debug("in close_application: gtk.main_quit()")
        if not self.child_process is None:
            # Send SIGTERM signal
            print "Calling terminate..."
            try:
                self.child_process.terminate()
                self.child_process.wait()
            except:
                # When the process already ended, we get an OS exeception
                # Ignore it
                pass
        # Bye
        gtk.main_quit()

#-------------------------------------------------------------------------------
# CommandTextView
# http://pygabriel.wordpress.com/2009/07/27/redirecting-the-stdout-on-a-gtk-textview
# Redirecting the stdout on a gtk.TextView by gabrielelanaro
#
# Simpler: use a virtual terminal from vte module, but vte is not in the
# python-gtk2 package
#-------------------------------------------------------------------------------

class CommandTextView(gtk.TextView):
    """ The class provides a run() method that starts the command in a 
    subprocess. The output of the command is read and displayed in the TextView
    (*this* object)
    It would be more elegant to use a VTE, when the vte module is available.
    """
    def __init__(self, gui):
        super(CommandTextView,self).__init__()
        self.gui = gui # a reference to the main class instance
        self.command = None
        
    def set_command(self, command):
        self.command = command

    def run(self):
        self.line = ''
        if (self.command is None):
            return
        # Don't start the command in a bash subprocess 
        # When Bash receives a signal for which a trap has been set while 
        # waiting for a command to complete, the trap will not be executed 
        # until the command completes !               
        # proc = subprocess.Popen(self.command,shell=True,stdout=subprocess.PIPE)
        args = shlex.split(self.command)
        try:
            #print  "**** run: args: ",
            print self.command
            print args
            proc = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        except OSError:
            print "Failed to start command " + self.command
            return

        self.gui.child_process = proc
        glib.io_add_watch(proc.stdout,
                          glib.IO_IN | glib.IO_ERR | glib.IO_HUP,
                          self.__write_to_buffer)
                          
    # The callback called when something is to be read on command's stdout
    def __write_to_buffer(self, fd, condition):
        if condition == glib.IO_IN:
            # We read one byte per time, to avoid blocking
            # Consider using proc.stdout to avoid blocking (unix only)
            # fcntl.fcntl(proc.stdout, fcntl.F_SETFL, \
            #             fcntl.fcntl(proc.stdout, fcntl.F_GETFL) | os.O_NONBLOCK) 
            char = fd.read(1)
            #print "**** read char: [%s]" % char
            char.decode('utf-8', 'replace')
            
            if char == '\n':
                self.line = self.line + char
                # print "**** read line: " + self.line ,
                # get the TextBuffer of the TextView
                buf = self.get_buffer()
                buf.insert_at_cursor(self.line)
                self.scroll_to_mark(buf.get_insert(), 0)
                self.line = ''            
            else:
                self.line = self.line + char
            # return True otherwise the callback isn't recalled
            return True
        else:
            if DO_DEBUG: print "**** Got some other condition on child pipe:"
            if DO_DEBUG: print "**** Nothing to read: I presume job is done"
            # Switch button: Quit => Close
            info_dialog("Process completed.\nYou can close the application.")
            gui.quit_button.hide()
            gui.close_button.show()
            # Then click "Close" to end the dialog
            return False

#------------------------------------------------------------------------------
# Functions
#

# This idle callback is called once (always return False) at startup:
# calls get_usb_devices, loops until a USB device is detected
# or the the user cancels the retry dialog, closing the application
#
def wait_for_usb_devices(data):
    status = False
    while not status:
        status = data.get_usb_devices()
        # No USB device found
        if not status:
            # Display the dialog
            retry = retry_or_quit_dialog(NO_USB_DEVICE_FOUND_ERROR)
            # Action canceled by user
            if not retry:
                break
    # We have an USB device or we have cancelled
    if not status:
        # No device, action cancelled
        gtk.main_quit()
    # Remove the idle proc and continue
    debug("wait_for_usb_devices idle_proc: returning False")
    return False
    
def signal_handler(signum, frame):
    #debug("signal_handler: signal handler called with signal %s" % signum)
    print "Application interrupted"
    gui.close_application()

def main(argv):
    # The main window, used by dialogs, set as global symbol
    global gui
    
    # --------------------------------------------------------------------------
    # Parse command line options
    try:                                
        opts, args = getopt.getopt(argv, "hdt", ["help", "debug", "test"])
    except getopt.GetoptError:
        usage()
        sys.exit(2)

    global DO_DEBUG
    global DO_TEST
    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()                     
            sys.exit()                  
        elif opt in ("-d", "--debug"):
            print "Running DEBUG mode"
            DO_DEBUG = True                  
        elif opt in ("-t", "--test"):
            print "Running TEST mode"
            DO_DEBUG = True                  
            DO_TEST = True
                             
    # --------------------------------------------------------------------------
    # Preliminary checks
    early_error = False

    if not check_if_user_is_root():
        msg = "You need root privileges to run this script."
        print msg
        early_error = True
        error_quit_dialog(msg)
        sys.exit(1)
    
    path = find_shell_script(ANTIX2USB_SCRIPT)
    if not path:
        msg = "Cannot proceed. The script %s\n is not present in the path. " % ANTIX2USB_SCRIPT
        msg += "Sorry."
        print msg
        early_error = True
        error_quit_dialog(msg)
        sys.exit(1)
                
    path = find_glade_file(ANTIX2USB_PREFIX, ANTIX2USB_GLADE)
    if not path:
        msg = "Cannot proceed. The resource file %s\n is not accessible." % ANTIX2USB_GLADE
        msg += "Sorry."
        print msg
        early_error = True
        error_quit_dialog(msg)
        sys.exit(1)

    if early_error:
        sys.exit()

    # --------------------------------------------------------------------------
    # Set the signal handler and a 5-second alarm
    signal.signal(signal.SIGQUIT, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)

    # --------------------------------------------------------------------------
    # Build the main window
    gui = AntixUsbGui()
    gui.update()
    
    try:
        # The idle proc wait_for_usb_devices checks if a device is plugged and
        # eventually waits for ...
        # print "***** RESTORE gobject.idle_add(wait_for_usb_devices, gui.data) *********"
        gobject.idle_add(wait_for_usb_devices, gui.data)
        
        # Now we can enter the main loop
        gtk.main()
        
    except KeyboardInterrupt:
        debug("main: quitting on KeyboardInterrupt")
        gui.close_application()

    return 0       


if __name__ == "__main__":

    main(sys.argv[1:])
