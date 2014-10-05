{-
 - Xmonad configuration file
 - @author linxray@gmail.com
 - @since 2014.3.8
 - 
 - features:
 -  key binding:
 -    M-d: run app launcher
 -    defaults
 -
 -  layouts:
 -    1. full screen, default
 -    2. auto master focus and grid
 -    2. auto master focus and grid, tall
 -
 -  workspace:
 -    1. main, default
 -    2. web, browser
 -    3. im, skype, webqq
 -    4. media, tab with "Chromium" title
 -    5. other, reserved
 -
 -}
import XMonad
import XMonad.Util.EZConfig(additionalKeysP)
import qualified XMonad.StackSet as W
import Data.List
import Data.Char
import Control.Monad
-- layout
import XMonad.Layout.NoBorders
import XMonad.Layout.GridVariants
-- prompt
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Hooks.SetWMName
import XMonad.Util.Run(unsafeSpawn)
import XMonad.Util.Run(safeSpawnProg)


myWorkspaces = ["terminal", "ide", "web", "main", "media", "other", "o1", "o2", "o3"]

mylayouts = noBorders Full ||| myTall
  where 
    myGrid = SplitGrid T 1 1 (2/5) (16/9) (5/100)
    myTall = Tall 1 (2/100) (1/2)

myManageHook = composeAll . concat $
   [
     [ fmap ( b `isInfixOf`) className --> viewShift "terminal" | b <- devShifts ]
     , [ fmap ( b `isInfixOf`) className --> viewShift "ide" | b <- ideShifts ]
     , [ fmap ( b `isInfixOf`) className --> viewShift "web" | b <- webShifts ]
     , [ fmap ( b `isInfixOf`) className --> viewShift "media" | b <- mediaShifts ]
   ]
   where 
    viewShift = doF . W.shift
    webShifts = ["google-chrome-stable", "Google-chrome-stable"]
    devShifts = ["URxvt"]
    ideShifts = [ "jetbrains-idea-ce"]
    mediaShifts = ["MPlayer", "mplayer2"]

myXPConfig = defaultXPConfig {
          font = "xft:Source Code Pro:size=11, xft:WenQuanYi Zen Hei Mono:size=11",
          fgColor = "#3079ed",
          bgColor = "#F1FFFF",
          position = Top,
          height = 23,
          promptBorderWidth=0,
          historySize = 10000
        }

myKeys = [ 
        ("M-r", shellPrompt myXPConfig)
        ] 

myXmonadConfig = defaultConfig {
            workspaces = myWorkspaces
          , manageHook = myManageHook
          , terminal = "urxvt"
          , modMask = mod4Mask
          , borderWidth = 1
          , focusedBorderColor = "#3079ed"
          , layoutHook = smartBorders mylayouts
          , startupHook = do
              setWMName "LG3D" -- java gui program must have this
              unsafeSpawn "urxvt -e tmux -2 attach"
              safeSpawnProg "google-chrome-stable"
              safeSpawnProg "fcitx"
        }
        `additionalKeysP` myKeys


main = do
    xmonad myXmonadConfig
        
