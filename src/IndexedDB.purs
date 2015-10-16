module IndexedDB
  ( IDB(), Name(), Version(), Connection(), Transaction(), UpgradeNeededEvent()
  , open
  ) where

import Prelude
import Data.Either
import Data.Function
import Control.Monad.Aff
import Control.Monad.Eff
import Control.Monad.Eff.Exception
import Control.Monad.Cont.Trans

type Name = String
type Version = Int

foreign import data IDB :: !
foreign import data Connection :: *
foreign import data Transaction :: *

type UpgradeNeededEvent =
  { old :: Version
  , new :: Version
  , db :: Connection
  , transaction :: Transaction
  }


foreign import openIDBNative
  :: forall eff. Fn5
      Name
      Version
      (Connection -> Eff (idb :: IDB | eff) Unit)
      (Error -> Eff (idb :: IDB | eff) Unit)
      (Version -> Version -> Connection -> Transaction -> Eff (idb :: IDB | eff) Unit)
      (Eff (idb :: IDB | eff) Unit)


open
  :: forall eff. Name
  -> Version
  -> (UpgradeNeededEvent -> Eff (idb :: IDB | eff) Unit)
  -> Aff (idb :: IDB | eff) Connection
open name version upgrade =
  makeAff
    (\error success ->
      runFn5 openIDBNative name version success error
        (\old new db transaction ->
          upgrade { old: old, new: new, db: db, transaction: transaction }))
