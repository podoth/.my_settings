import XMonad
import XMonad.Config.Gnome
import Control.OldException
import Control.Monad
import DBus
import DBus.Connection
import DBus.Message
import XMonad
import XMonad.Config.Gnome
import XMonad.Hooks.DynamicLog
import XMonad.Actions.GridSelect
import XMonad.Config.Desktop (desktopLayoutModifiers)
import XMonad.Layout.Grid
import XMonad.Layout.Tabbed

getWellKnownName :: Connection -> IO ()
getWellKnownName dbus = tryGetName `catchDyn` (\ (DBus.Error _ _) -> getWellKnownName dbus)
 where
  tryGetName = do
    namereq <- newMethodCall serviceDBus pathDBus interfaceDBus "RequestName"
    addArgs namereq [String "org.xmonad.Log", Word32 5]
    sendWithReplyAndBlock dbus namereq 0
    return ()


------------------------------------------------------------------------
-- --Layouts:
myLayout = tiled ||| Mirror tiled ||| Grid ||| simpleTabbed ||| Full
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled = Tall nmaster delta ratio
     -- The default number of windows in the master pane
     nmaster = 1
     -- Default proportion of screen occupied by master pane
     ratio = 1/2
     -- Percent of screen to increment by when resizing panes
     delta = 3/100

------------------------------------------------------------------------


main :: IO ()
main = withConnection Session $ \ dbus -> do
  putStrLn "Getting well-known name."
  getWellKnownName dbus
  putStrLn "Got name, starting XMonad."
  xmonad $ gnomeConfig {
  manageHook = manageHook gnomeConfig
  , layoutHook = desktopLayoutModifiers $ myLayout
  , logHook    = do
      logHook gnomeConfig
      dynamicLogWithPP $ defaultPP {
                   ppOutput   = \ str -> do
                     let str'  = "<span font=\"UmePlus P Gothic\" weight=\"bold\">" ++ str ++ "</span>"
                     msg <- newSignal "/org/xmonad/Log" "org.xmonad.Log" "Update"
                     addArgs msg [String str']
                     -- If the send fails, ignore it.
                     send dbus msg 0 `catchDyn` (\ (DBus.Error _name _msg) -> return 0)
                     return ()
                 , ppTitle    = pangoColor "#FFFFFF" . shorten 60 . escape
                 , ppCurrent  = pangoColor "#FFFFFF" . wrap "[" "]"
                 , ppVisible  = pangoColor "#666666" . wrap "_" ""
                 , ppHidden   = wrap "" ""
                 , ppUrgent   = pangoColor "red"
                 }
  , modMask = mod3Mask
  , focusFollowsMouse = False
  , focusedBorderColor = "#00dd00"
  , borderWidth = 4
  }



pangoColor :: String -> String -> String
pangoColor fg = wrap left right
 where
  left  = "<span foreground=\"" ++ fg ++ "\">"
  right = "</span>"

escape :: String -> String
escape = concatMap escapeChar
escapeChar :: Char -> String
escapeChar '<' = "&lt;"
escapeChar '>' = "&gt;"
escapeChar '&' = "&amp;"
escapeChar '"' = "&quot;"
escapeChar c = [c]

