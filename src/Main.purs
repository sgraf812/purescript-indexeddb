module Main where

import Prelude
import Data.Either
import Control.Monad.Eff
import Control.Monad.Eff.Console
import Control.Monad.Eff.Class
import Control.Monad.Aff
import IndexedDB (UpgradeNeededEvent(), IDB())
import qualified IndexedDB as IDB

upgrade
  :: forall eff
   . UpgradeNeededEvent
  -> Eff (console :: CONSOLE, idb :: IDB | eff) Unit
upgrade evt = do
  store <- IDB.createObjectStore evt.db "hello" []
  pure unit


main = launchAff do
  db <- attempt $ IDB.open "hi" 1 upgrade
  either (liftEff <<< print) (const $ liftEff $ log "success") db
