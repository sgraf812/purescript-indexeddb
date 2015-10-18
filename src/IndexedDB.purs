module IndexedDB
  ( IDB(), Version(), Connection(), Transaction(), ObjectStore()
  , UpgradeNeededEvent(), CreateObjectStoreOptions()
  , open, createObjectStore
  ) where

import Prelude
import Data.Either
import Data.Function
import Control.Monad.Aff
import Control.Monad.Eff
import Control.Monad.Eff.Exception
import Control.Monad.Cont.Trans

type Version = Int

-- TODO: Test if some phantom type for the transaction mode is sensible
foreign import data IDB :: !
foreign import data Connection :: *
foreign import data Transaction :: *
foreign import data ObjectStore :: *

type UpgradeNeededEvent =
  { old :: Version
  , new :: Version
  , db :: Connection
  , transaction :: Transaction
  }


data CreateObjectStoreOptions
  = KeyPath (Array String)
  | AutoIncrement


foreign import openNative
  :: forall eff
   . Fn5
      String
      Version
      (Connection -> Eff (idb :: IDB | eff) Unit)
      (Error -> Eff (idb :: IDB | eff) Unit)
      (Version -> Version -> Connection -> Transaction -> Eff (idb :: IDB | eff) Unit)
      (Eff (idb :: IDB | eff) Unit)


foreign import createObjectStoreNative
  :: forall eff
   . Fn3
      Connection
      String
      (Array CreateObjectStoreOptions)
      (Eff (idb :: IDB | eff) ObjectStore)


open
  :: forall eff
   . String
  -> Version
  -> (UpgradeNeededEvent -> Eff (idb :: IDB | eff) Unit)
  -> Aff (idb :: IDB | eff) Connection
open name version upgrade =
  makeAff
    (\error success ->
      runFn5 openNative name version success error
        (\old new db transaction ->
          upgrade { old: old, new: new, db: db, transaction: transaction }))


createObjectStore
  :: forall eff
   . Connection
  -> String
  -> Array CreateObjectStoreOptions
  -> (Eff (idb :: IDB | eff) ObjectStore)
createObjectStore db name options =
  runFn3 createObjectStoreNative db name options
