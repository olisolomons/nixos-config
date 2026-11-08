import qualified Data.Map.Strict as M
import Data.Monoid ((<>))
import System.Exit
import System.Process
import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Layout.NoBorders
import XMonad.Layout.Spiral
import XMonad.Prompt
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import XMonad.Util.Run
import qualified XMonad.Util.Hacks as Hacks
import qualified XMonad.Actions.CopyWindow as Copy

main :: IO ()
main =
  xmonad $
    ewmh $
      withEasySB (statusBarProp "xmobar ~/.config/xmobar/xmobarrc" (pure def)) defToggleStrutsKey $
      Hacks.javaHack $
        def
          { modMask = mod4Mask,
            terminal = "alacritty",
            layoutHook = myLayout,
            handleEventHook = handleEventHook def
                 <> Hacks.trayerPaddingXmobarEventHook,
            keys = myKeys
          }

backlight = ("/sys/class/backlight/intel_backlight/" <>)

modifyBrightness :: Float -> Float -> Int -> IO ()
modifyBrightness percentChange smallStepThresholdPercent smallStepSize = do
  brightness <- read <$> readFile (backlight "brightness")
  maxBrightness <- read <$> readFile (backlight "max_brightness")
  let brightnessFrac =
        brightness / maxBrightness
      smallStepThreshold = smallStepThresholdPercent / 100
      newBrightness =
        between 1 (round maxBrightness) $
          if brightnessFrac < smallStepThreshold
            || brightnessFrac + percentChange / 100 < smallStepThreshold
            then round brightness + smallStepSize
            else round $ (brightnessFrac + percentChange / 100) * maxBrightness
  brightness `seq` writeFile (backlight "brightness") (show (newBrightness :: Int))
  where
    between low high = max low . min high

myLayout = smartBorders (spiral (5/6)) ||| noBorders Full


myKeys :: XConfig Layout -> M.Map (KeyMask, KeySym) (X ())
myKeys conf =
  mkKeymap conf $
    -- launching and killing programs
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
    -- launching and killing programs
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
    -- launching and killing programs
    -- launching and killing programs
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
    -- launching and killing programs
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
    -- launching and killing programs
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
    -- launching and killing programs
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
    -- launching and killing programs
    -- launching and killing programs
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
    -- launching and killing programs
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
    -- launching and killing programs
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
    -- launching and killing programs
    -- launching and killing programs
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
    -- launching and killing programs
    [ ("M-s", spawn "dmenu_run"), -- %! Launch dmenu
      ("M1-<F4>", Copy.kill1), -- %! Close the focused window, (Alt-F4)
      ("M-<Space>", sendMessage NextLayout), -- %! Rotate through the available layout algorithms
      ("M-S-<Space>", setLayout $ XMonad.layoutHook conf), -- %!  Reset the layouts on the current workspace to default
      ("M-<F5>", refresh), -- %! Resize viewed windows to the correct size

      -- move focus up or down the window stack
      ("M-<Tab>", windows W.focusDown), -- %! Move focus to the next window
      ("M-S-<Tab>", windows W.focusUp), -- %! Move focus to the previous window
      ("M1-<Tab>", windows W.focusDown), -- %! Move focus to the next window
      ("M1-S-<Tab>", windows W.focusUp), -- %! Move focus to the previous window
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

      -- quit, or restart
      ("M-S-q", io exitSuccess), -- %! Quit xmonad
      ("M-q", spawn "if type xmonad; then xmonad --recompile && xmonad --restart; else xmessage xmonad not in \\$PATH: \"$PATH\"; fi"), -- %! Restart xmonad

      -- ==== additional keys ====
      -- brightness
      ("<XF86MonBrightnessUp>", liftIO $ modifyBrightness 10 5 2),
      ("<XF86MonBrightnessDown>", liftIO $ modifyBrightness (-10) 5 (-2)),
      ("M-z q", liftIO $ modifyBrightness 10 5 2),
      ("M-z a", liftIO $ modifyBrightness (-10) 5 (-2)),
      ("M-z z", liftIO $ writeFile (backlight "brightness") "1"),
      ("M-z M-z", liftIO $ writeFile (backlight "brightness") "1"),
      ("M-z w", spawn "redshift -x"),
      ("M-z s", spawn "redshift -x -O 3000k"),
      -- volume
      ("<XF86AudioLowerVolume>", spawn "amixer -D pipewire sset Master 5%-"),
      ("<XF86AudioRaiseVolume>", spawn "amixer -D pipewire sset Master 5%+"),
      ("<XF86AudioMute>", spawn "amixer -D pipewire sset Master toggle"),
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
      ("M-r p", spawn "pycharm"),
      ("M-r f", spawn "firefox -p default"),
      ("M-r S-f", spawn "firefox"),
      ("M-r M-t p", runInTerm "" "python3"),
      ("M-r m", spawn "minecraft-launcher"),
      ("M-r e", spawn fileExplorer),

      -- notification managment
      ("M-n n", spawn "dunstctl close"),
      ("M-n S-n", spawn "dunstctl close-all"),
      ("M-n <XF86AudioPlay>", spawn "dunstctl set-paused false"),
      ("M-n <XF86AudioStop>", spawn "dunstctl set-paused true"),

      -- screenshot
      ("<Print>", spawn "flameshot gui"),
      ("M-<Print>", spawn "flameshot"),
      ("S-<Print>", spawn "killall flameshot"),

      -- external monitor stuff
      ("M-p", externalMontiorChange True),
      ("M-S-p", externalMontiorChange False),

      -- copy window
      ("M-`", windows Copy.copyToAll),
      ("M-S-`", Copy.killAllOtherCopies)
    ]
      ++
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      -- mod-alt-[1..4] %! move to screen
      -- mod-[1..9] %! Switch to workspace N
      -- mod-shift-[1..9] %! Move client to workspace N
      [ ("M" <> maybeShift <> "-" <> [k], windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) ['1' .. '9'],
          (f, maybeShift) <- [(W.greedyView, ""), (W.shift, "-S")]
      ]
      ++
      -- mod-alt-[1..4] %! move to screen
      [ ("M-M1-"<>[k], screenWorkspace sc >>= flip whenJust (windows . W.view))
        | (k, sc) <- zip ['1'..'4'] [0..]
      ]


fileExplorer = "nautilus"

externalMontiorChange use = do
  spawn "~/dotfiles/hdmi_sound_toggle.sh"
  if use
    then do spawn $ xrandr "HDMI1" True
            spawn $ xrandr mainMonitor False
    else spawn $ xrandr mainMonitor True
  where
    mainMonitor = "eDP1"
    xrandr monitor isTurningOn = "xrandr --output " <> monitor <> " --" <> (if isTurningOn then "auto" else "off")

