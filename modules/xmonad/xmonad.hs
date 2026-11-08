import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.EZConfig

main :: IO ()
main =
  xmonad $
    docks
      def
        { modMask = mod4Mask,
          borderWidth = 2
        }
      `additionalKeysP` [ ("M-C-r", spawn "xmonad --restart")
                        ]

foo x=x
