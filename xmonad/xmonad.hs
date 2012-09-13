import XMonad

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

main = xmonad $ defaultConfig
  { borderWidth = 0
  , normalBorderColor = "#000000"
  , focusedBorderColor = "#000000"
  , modMask = mod1Mask
  , focusFollowsMouse = False
  , keys = myKeys
  }

myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    -- M-S-enter: terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- M-S-q: recompile and restart/reload xmonad
    , ((modm .|. shiftMask, xK_q), spawn "xmonad --recompile && xmonad --restart")

    -- M-C-q: close focused
    , ((modm .|. controlMask, xK_q), kill)

    -- M-S-p: dmenu
    , ((modm .|. shiftMask, xK_p), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")

    -- M-space: rotate layout
    , ((modm, xK_space), sendMessage NextLayout)

    -- M-S-space: reset layout
    , ((modm .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf)

    -- M-j: focus next
    , ((modm, xK_j), windows W.focusDown)

    -- M-k: focus previous
    , ((modm, xK_k), windows W.focusUp  )

    -- M-enter: make master
    , ((modm, xK_Return), windows W.swapMaster)

    -- M-S-j: swap next
    , ((modm .|. shiftMask, xK_j), windows W.swapDown  )

    -- M-S-k: swap previous
    , ((modm .|. shiftMask, xK_k), windows W.swapUp    )

    -- M-h: shrink master
    , ((modm, xK_h), sendMessage Shrink)

    -- M-l: expand master
    , ((modm, xK_l), sendMessage Expand)

    -- M-,: allow more in master
    , ((modm, xK_comma), sendMessage (IncMasterN 1))

    -- M-.: allow fewer in master
    , ((modm, xK_period), sendMessage (IncMasterN (-1)))

    -- M-S-u: unfloat
    , ((modm .|. shiftMask, xK_u), withFocused $ windows . W.sink)
    ]

    ++

    -- M2-F1 .. M2-F9: switch to workspace
    -- M2-S-F1 .. M2-S-F9: move to workspace
    -- Note the list comprehension.
    [ ((modm .|. m, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_F1 .. xK_F9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]
    ]

