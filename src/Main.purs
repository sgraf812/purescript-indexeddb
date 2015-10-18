module Main where

import Prelude
import Data.Maybe
import Data.Either
import Control.Monad.Eff
import Control.Monad.Eff.Console
import Control.Monad.Eff.Class
import Control.Monad.Aff
import IndexedDB (UpgradeNeededEvent(), IDB(), CreateObjectStoreOptions(..))
import qualified IndexedDB as IDB

upgrade
  :: forall eff
   . UpgradeNeededEvent
  -> Eff _ Unit
upgrade evt = do
  log "hi"
  store <- IDB.createObjectStore evt.db "hello" (KeyPath ["id", "id2"])
  pure unit


main = launchAff do
  db <- attempt $ IDB.open "hi" 1 upgrade
  either (liftEff <<< print) (const $ liftEff $ log "success") db
