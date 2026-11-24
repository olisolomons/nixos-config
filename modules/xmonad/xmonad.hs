import qualified Data.Map.Strict as M
import Data.Monoid ((<>))
import System.Exit
import System.Process
import XMonad
import qualified XMonad.Actions.CopyWindow as Copy
import XMonad.Actions.Submap (submap)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Prompt
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import qualified XMonad.Util.Hacks as Hacks
import XMonad.Util.Run

main :: IO ()
main =
  xmonad $
    ewmh $
      withEasySB (statusBarProp "xmobar" (pure def)) defToggleStrutsKey $
        Hacks.javaHack $
          def
            { modMask = mod4Mask,
              terminal = "alacritty",
              layoutHook = myLayout,
              handleEventHook =
                handleEventHook def
                  <> Hacks.trayerPaddingXmobarEventHook,
              keys = myKeys
            }

myLayout = smartBorders (spiral (5 / 6)) ||| noBorders Full

mkSubmap :: XConfig Layout -> [(String, X ())] -> X ()
mkSubmap conf = submap . mkKeymap conf

myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf =
  mkKeymap conf $
    [ ("M-s", spawn "dmenu_run"), -- %! Launch dmenu
      ("M-S-q", Copy.kill1), -- %! Close the focused window
      ("M-<Space>", sendMessage NextLayout), -- %! Rotate through the available layout algorithms
      ("M-S-<Space>", setLayout $ XMonad.layoutHook conf), -- %!  Reset the layouts on the current workspace to default
      ("M-<F5>", refresh), -- %! Resize viewed windows to the correct size

      -- move focus up or down the window stack
      ("M-<Tab>", windows W.focusDown), -- %! Move focus to the next window
      ("M-S-<Tab>", windows W.focusUp), -- %! Move focus to the previous window
      ("M-j", windows W.focusDown), -- %! Move focus to the next window
      ("M-k", windows W.focusUp), -- %! Move focus to the previous window
      ("M-m", windows W.focusMaster), -- %! Move focus to the master window

      -- modifying the window order
      ("M-<Return>", windows W.swapMaster), -- %! Swap the focused window and the master window
      ("M-S-j", windows W.swapDown), -- %! Swap the focused window with the next window
      ("M-S-k", windows W.swapUp), -- %! Swap the focused window with the previous window

      -- resizing the master/slave ratio
      ("M-h", sendMessage Shrink), -- %! Shrink the master area
      ("M-l", sendMessage Expand), -- %! Expand the master area

      -- floating layer support
      ("M-t", withFocused $ windows . W.sink), -- %! Push window back into tiling

      -- increase or decrease number of windows in the master area
      ("M-,", sendMessage (IncMasterN 1)), -- %! Increment the number of windows in the master area
      ("M-.", sendMessage (IncMasterN (-1))), -- %! Deincrement the number of windows in the master area

      -- ==== additional keys ====
      -- brightness
      ("M-z", brightnessSubmap conf),
      -- volume
      ("M-S-z", audioSubmap conf),
      -- mpris audio
      ("<XF86AudioPlay>", spawn "playerctl play-pause"),
      ("<XF86AudioStop>", spawn "playerctl stop"),
      ("<XF86AudioPrev>", spawn "playerctl position 5-"),
      ("<XF86AudioNext>", spawn "playerctl position 5+"),
      -- power options
      ("M-x s", spawn "systemctl suspend"),
      ("M-x u", spawn "systemctl poweroff"),
      ("M-x r", spawn "systemctl reboot"),
      -- - lock
      ("M-x l", spawn "light-locker-command -l"),
      -- - log out
      ("M-x S-l", spawn "pkill -u $USER"),
      -- custom launching
      ("M-r t", spawn $ XMonad.terminal conf),
      ("M-r f", spawn "firefox"),
      ("M-r M-t p", runInTerm "" "python3"),
      -- notification managment
      ("M-n n", spawn "dunstctl close"),
      ("M-n S-n", spawn "dunstctl close-all"),
      ("M-n <XF86AudioPlay>", spawn "dunstctl set-paused false"),
      ("M-n <XF86AudioStop>", spawn "dunstctl set-paused true"),
      -- screenshot
      ("<Print>", spawn "flameshot gui"),
      ("M-<Print>", spawn "flameshot"),
      ("S-<Print>", spawn "killall flameshot"),
      -- copy window
      ("M-`", windows Copy.copyToAll),
      ("M-S-`", Copy.killAllOtherCopies)
    ]
      ++
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      [ ("M" <> maybeShift <> "-" <> [k], windows $ f i)
      | (i, k) <- zip (XMonad.workspaces conf) ['1' .. '9'],
        (f, maybeShift) <- [(W.greedyView, ""), (W.shift, "-S")]
      ]
      ++
      -- mod-alt-[1..4] %! move to screen
      [ ("M-M1-" <> [k], screenWorkspace sc >>= flip whenJust (windows . W.view))
      | (k, sc) <- zip ['1' .. '4'] [0 ..]
      ]

brightnessSubmap :: XConfig Layout -> X ()
brightnessSubmap conf =
  mkSubmap
    conf
    [ ("q", spawn "brightnessctl set 2%+" >> brightnessSubmap conf),
      ("a", spawn "brightnessctl set 2%- --min-value 1" >> brightnessSubmap conf),
      ("z", spawn "brightnessctl set 1"),
      ("M-z", spawn "brightnessctl set 1"),
      ("<Escape>", return ())
    ]

audioSubmap :: XConfig Layout -> X ()
audioSubmap conf =
  mkSubmap
    conf
    [ ("q", spawn "pactl set-sink-volume @DEFAULT_SINK@ +10%" >> audioSubmap conf),
      ("a", spawn "pactl set-sink-volume @DEFAULT_SINK@ -10%" >> audioSubmap conf),
      ("z", spawn "pactl set-sink-mute @DEFAULT_SINK@ 0"),
      ("S-z", spawn "pactl set-sink-mute @DEFAULT_SINK@ 1"),
      ("<Escape>", return ())
    ]
