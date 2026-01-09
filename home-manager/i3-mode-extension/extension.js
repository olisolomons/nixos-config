import { Extension } from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';
import Shell from 'gi://Shell';
import Meta from 'gi://Meta';
import Clutter from 'gi://Clutter';

export default class I3ModeExtension extends Extension {
    enable() {
        this._settings = this.getSettings('org.gnome.shell.extensions.i3mode');
        
        // Bind Super+R for Launch and Super+P for Power
        this._addKeybinding('launch-mode', () => this._enterMode('🚀 Launch', this._launchMap));
        this._addKeybinding('power-mode', () => this._enterMode('⚡ Power', this._powerMap));
    }

    _addKeybinding(name, callback) {
        Main.wm.addKeybinding(name, this._settings, Meta.KeyBindingFlags.NONE, Shell.ActionMode.NORMAL, callback);
    }

    _enterMode(title, map) {
        global.stage.grab_key_focus();
        let grab = Main.pushModal(global.stage);
        
        if (!grab) return;

        let eventId = global.stage.connect('key-press-event', (actor, event) => {
            let symbol = event.get_key_symbol();
            let unicode = Clutter.keysym_to_unicode(symbol);
            let keyName = String.fromCharCode(unicode); // This preserves case (v vs V)

            if (symbol === Clutter.KEY_Escape) {
                console.log("I3-MODE: Canceled");
            } else if (map[keyName]) {
                console.log(`I3-MODE: Action for ${keyName}`);
                map[keyName]();
            }

            global.stage.disconnect(eventId);
            Main.popModal(grab);
            return Clutter.EVENT_STOP;
        });
    }

    _launchMap = {
        'f': () => this._launchApp('firefox.desktop'),
        't': () => this._launchApp('alacritty.desktop'),
        'c': () => this._launchApp('chromium.desktop'),
        'v': () => Util.trySpawnCommandLine('obs --startvirtualcam --minimize-to-tray'),
        'V': () => Util.trySpawnCommandLine('pkill obs'), // The requested Kill command
    };

    _powerMap = {
        's': () => Util.spawnCommandLine('systemctl suspend'),
        'l': () => Util.spawnCommandLine('loginctl lock-session'),
        'u': () => Util.spawnCommandLine('systemctl poweroff'),
        'r': () => Util.spawnCommandLine('systemctl reboot'),
    };

    _launchApp(desktopId) {
        let app = Shell.AppSystem.get_default().lookup_app(desktopId);
        if (app) {
            app.activate();
        } else {
            console.error(`I3-MODE: Could not find app ${desktopId}`);
            // Fallback for NixOS if desktop file naming is weird
            Util.trySpawnCommandLine(desktopId.replace('.desktop', ''));
        }
    }

    disable() {
        Main.wm.removeKeybinding('launch-mode');
        Main.wm.removeKeybinding('power-mode');
        this._settings = null;
    }
}

// Helper for shell commands
import * as Util from 'resource:///org/gnome/shell/misc/util.js';
