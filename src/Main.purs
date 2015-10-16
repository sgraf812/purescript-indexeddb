module Main where

import Prelude
import Data.Either
import Control.Monad.Eff
import Control.Monad.Eff.Console
import Control.Monad.Eff.Class
import Control.Monad.Aff
import IndexedDB (UpgradeNeededEvent(), IDB())
import qualified IndexedDB as IDB

upgrade :: forall eff. UpgradeNeededEvent -> Eff (console :: CONSOLE | eff) Unit
upgrade evt = do
  log "hi"
  print evt.old
  print evt.new
  pure unit


main = launchAff do
  db <- attempt $ IDB.open "hi" 1 upgrade
  either (const $ liftEff $ log "error") (const $ liftEff $ log "success") db
