import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
import Data.List
import Data.Char
import Control.Monad
import XMonad.Layout.NoBorders


myWorkspaces = ["main","web","im","media", "other", "6", "7", "8", "9"]

myManageHook = composeAll . concat $
   [
     [ title =? "Chromium" --> viewShift "media" ] -- full screen page will have Chromium in title
     , [ fmap ( b `isInfixOf`) className --> viewShift "main" | b <- devShfits ]
     , [ fmap ( b `isInfixOf`) className --> viewShift "web" | b <- webShifts ]
     , [ fmap ( b `isInfixOf`) className --> viewShift "media" | b <- mediaShifts ]
     , [ fmap ( b `isInfixOf`) className --> viewShift "im" | b <- imShifts ]
   ]
   where 
    viewShift = doF . liftM2 (.) W.greedyView W.shift
    webShifts = ["Chromium"]
    devShfits = ["urxvt", "Terminal"]
    imShifts = ["Skype"]
    mediaShifts = ["mplayer"]

-- M-r means run programs
myKeys = [ 
          ("M-r c", spawn "chromium")
          , ("M-r i", spawn "fcitx")
        ] 

main = do
    xmonad $ defaultConfig {
            workspaces = myWorkspaces
          , manageHook = myManageHook
          , terminal = "urxvt"
          , modMask = mod4Mask
          , borderWidth = 2
          , focusedBorderColor = "#3079ed"
          , layoutHook = smartBorders $ layoutHook defaultConfig
        }
        `additionalKeysP` myKeys
        
