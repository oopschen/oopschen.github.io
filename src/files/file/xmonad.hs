{-
 - Xmonad configuration file
 - @author linxray@gmail.com
 - @since 2014.3.8
 - 
 - features:
 -  key binding:
 -    M-d: run app launcher
 -    M-s: run ssh
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
import XMonad.Layout.Master
import XMonad.Layout.GridVariants
-- prompt
import XMonad.Prompt
import XMonad.Prompt.Shell
import XMonad.Prompt.Ssh


myWorkspaces = ["main","web","im","media", "other"]
chromeFullModeTitle = "Google Chrome"

mylayouts = Full ||| myGrid 
  where 
    myGrid = SplitGrid T 1 1 (2/5) (16/9) (5/100)
    myTall = mastered (1/100) (1/3) $ Tall 1 (5/100) (2/3)

myManageHook = composeAll . concat $
   [
     [ title =? chromeFullModeTitle --> doFloat ] -- full screen page will have Chromium in title
     , [ title =? chromeFullModeTitle --> viewShift "media" ] -- full screen page will have Chromium in title
     , [ fmap ( b `isInfixOf`) className --> viewShift "main" | b <- devShfits ]
     , [ fmap ( b `isInfixOf`) className --> viewShift "web" | b <- webShifts ]
     , [ fmap ( b `isInfixOf`) className --> viewShift "media" | b <- mediaShifts ]
     , [ fmap ( b `isInfixOf`) className --> viewShift "im" | b <- imShifts ]
   ]
   where 
    viewShift = doF . liftM2 (.) W.greedyView W.shift
    webShifts = ["google-chrome-stable", "Google-chrome-stable"]
    devShfits = ["URxvt"]
    imShifts = ["Skype"]
    mediaShifts = ["MPlayer"]

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
        ("M-d", shellPrompt myXPConfig)
        ,("M-s", sshPrompt myXPConfig)
        ] 

myXmonadConfig = defaultConfig {
            workspaces = myWorkspaces
          , manageHook = myManageHook
          , terminal = "urxvt"
          , modMask = mod4Mask
          , borderWidth = 1
          , focusedBorderColor = "#3079ed"
          , layoutHook = smartBorders mylayouts
        }
        `additionalKeysP` myKeys


main = do
    xmonad myXmonadConfig
        
