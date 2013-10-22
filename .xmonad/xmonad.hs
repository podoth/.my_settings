{-# LANGUAGE OverloadedStrings #-}

import XMonad
-- import XMonad.Config.Gnome
-- import Control.OldException
import Control.Monad
-- import DBus
-- import DBus.Connection
-- import DBus.Client
-- import DBus.Message
import XMonad
-- import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Actions.GridSelect
import XMonad.Config.Desktop (desktopLayoutModifiers)
import XMonad.Layout.Grid
import XMonad.Layout.Tabbed
import XMonad.Util.EZConfig (additionalKeys)
-- バグ？Minimize.hsの最新版を.xmonad内に配置しないとminimizeWindowがないと怒られる
import XMonad.Layout.Minimize


import XMonad.Hooks.ManageDocks
import XMonad.Hooks.EwmhDesktops

import qualified DBus as D
import qualified DBus.Client as D
import qualified Codec.Binary.UTF8.String as UTF8

import XMonad.Config.Xfce
-- import Xmonad.Hooks.ManageDocks
-- import XMonad.Hooks.EwmhDesktops

-- getWellKnownName :: XMonad.Connection -> IO ()
-- getWellKnownName dbus = tryGetName `catchDyn` (\ (DBus.Error _ _) -> getWellKnownName dbus)
--  where
--   tryGetName = do
--     namereq <- newMethodCall serviceDBus pathDBus interfaceDBus "RequestName"
--     addArgs namereq [String "org.xmonad.Log", Word32 5]
--     sendWithReplyAndBlock dbus namereq 0
--     return ()


------------------------------------------------------------------------
-- --Layouts:
-- minimizeしたウィンドウをウィンドウ移動対象から外したければboringAutoがあるが、Fullレイアウト使用時に何故か上手く動かない
-- myLayout = minimize (tiled ||| Mirror tiled ||| Grid ||| simpleTabbed ||| Full)
myLayout = minimize (tiled ||| Mirror tiled ||| Grid ||| simpleTabbed)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled = Tall nmaster delta ratio
     -- The default number of windows in the master pane
     nmaster = 1
     -- Default proportion of screen occupied by master pane
     ratio = 1/2
     -- Percent of screen to increment by when resizing panes
     delta = 3/100

myKeys =
  [
  -- Minimize a window
  ((mod3Mask, xK_z),               withFocused minimizeWindow)
  , ((mod3Mask .|. shiftMask, xK_z), sendMessage RestoreNextMinimizedWin)
  , ((mod3Mask, xK_a),               spawn "amixer set Master 5%-")
  , ((mod3Mask, xK_s),               spawn "amixer set Master 5%+")
  , ((mod3Mask, xK_d),               spawn "firefox")
  , ((mod3Mask, xK_f),               spawn "emacs")
  ]

--------------------------------------------------------------------------

-- main :: IO ()
-- main = withConnection Session $ \ dbus -> do
--   putStrLn "Getting well-known name."
--   getWellKnownName dbus
--   putStrLn "Got name, starting XMonad."
--   xmonad $ gnomeConfig {
--   manageHook = manageHook gnomeConfig
--   , layoutHook = desktopLayoutModifiers $ myLayout
--   , logHook    = do
--       logHook gnomeConfig
--       dynamicLogWithPP $ defaultPP {
--                    ppOutput   = \ str -> do
--                      let str'  = "<span font=\"UmePlus P Gothic\" weight=\"bold\">" ++ str ++ "</span>"
--                      msg <- newSignal "/org/xmonad/Log" "org.xmonad.Log" "Update"
--                      addArgs msg [String str']
--                      -- If the send fails, ignore it.
--                      send dbus msg 0 `catchDyn` (\ (DBus.Error _name _msg) -> return 0)
--                      return ()
--                  , ppTitle    = pangoColor "#FFFFFF" . shorten 60 . escape
--                  , ppCurrent  = pangoColor "#FFFFFF" . wrap "[" "]"
--                  , ppVisible  = pangoColor "#666666" . wrap "_" ""
--                  , ppHidden   = wrap "" ""
--                  , ppUrgent   = pangoColor "red"
--                  }
--   , modMask = mod3Mask
--   , focusFollowsMouse = False
--   , focusedBorderColor = "#00dd00"
--   , borderWidth = 4
--   } `additionalKeys` myKeys

-- pangoColor :: String -> String -> String
-- pangoColor fg = wrap left right
--  where
--   left  = "<span foreground=\"" ++ fg ++ "\">"
--   right = "</span>"

-- escape :: String -> String
-- escape = concatMap escapeChar
-- escapeChar :: Char -> String
-- escapeChar '<' = "&lt;"
-- escapeChar '>' = "&gt;"
-- escapeChar '&' = "&amp;"
-- escapeChar '"' = "&quot;"
-- escapeChar c = [c]


prettyPrinter :: D.Client -> PP
prettyPrinter dbus = defaultPP
    { ppOutput = dbusOutput dbus
    , ppTitle = pangoSanitize
    , ppCurrent = pangoColor "black" . wrap "[" "]" . pangoSanitize
    , ppVisible = pangoColor "black" . wrap "_" "" . pangoSanitize
    , ppHidden = pangoColor "gray" . wrap "" ""
    , ppUrgent = pangoColor "red"
    , ppLayout = wrap "" ""
    , ppSep = " "
    }

getWellKnownName :: D.Client -> IO ()
getWellKnownName dbus = do
  D.requestName dbus (D.busName_ "org.xmonad.Log")
                [D.nameAllowReplacement, D.nameReplaceExisting, D.nameDoNotQueue]
  return ()

dbusOutput dbus str = do
    let signal = (D.signal "/org/xmonad/Log" "org.xmonad.Log" "Update") {
            D.signalBody = [D.toVariant ("<b>" ++ (UTF8.decodeString str) ++ "</b>")]
        }
    D.emit dbus signal

pangoColor :: String -> String -> String
pangoColor fg = wrap left right
  where
    left = "<span foreground=\"" ++ fg ++ "\">"
    right = "</span>"

pangoSanitize :: String -> String
pangoSanitize = foldr sanitize ""
  where
    sanitize '>' xs = "&gt;" ++ xs
    sanitize '<' xs = "&lt;" ++ xs
    sanitize '\"' xs = "&quot;" ++ xs
    sanitize '&' xs = "&amp;" ++ xs
    sanitize x xs = x:xs

-- main :: IO ()
-- main = do
--   dbus <- D.connectSession
--   getWellKnownName dbus
--   xmonad $ defaultConfig {
--          manageHook = manageDocks <+> manageHook defaultConfig
--          , layoutHook = avoidStruts $ layoutHook defaultConfig
--          -- , logHook = dynamicLogWithPP (prettyPrinter dbus)
--          , logHook = ewmhDesktopsLogHook
--          , handleEventHook = ewmhDesktopsLogHook
--          , startupHook = ewmhDesktopsStartup
--          , modMask = mod3Mask
--          , focusFollowsMouse = False
--          , focusedBorderColor = "green"
--          , borderWidth = 4
--   } `additionalKeys` myKeys


-- main = do
--   dbus <- D.connectSession
--   getWellKnownName dbus
--   xmonad $ xfceConfig {
--          manageHook = manageHook xfceConfig
--          , layoutHook = desktopLayoutModifiers $ myLayout
--          , logHook = dynamicLogWithPP (prettyPrinter dbus)
--          , modMask = mod3Mask
--          , focusFollowsMouse = False
--          , focusedBorderColor = "green"
--          , borderWidth = 4
--   } `additionalKeys` myKeys


main = do
  dbus <- D.connectSession
  getWellKnownName dbus
  xmonad $ xfceConfig {
         layoutHook = desktopLayoutModifiers $ myLayout
         , logHook = dynamicLogWithPP (prettyPrinter dbus)
         , modMask = mod3Mask
         , focusFollowsMouse = False
         , focusedBorderColor = "green"
         , borderWidth = 4
  } `additionalKeys` myKeys

defaultGaps :: [(Int,Int,Int,Int)]
defaultGaps = [(18,0,0,0)]

