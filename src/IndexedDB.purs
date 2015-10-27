module IndexedDB
  ( IDB(), Version(), Connection(), Transaction(), ObjectStore(), Index()
  , UpgradeNeededEvent(), CreateObjectStoreOptions(..)
  , Unique(..), NonUnique(..), SingleEntry(..), MultiEntry(..)
  , Uniqueness, unique, ArrayIndexPolicy, multiEntry
  , open, createObjectStore, createIndex
  ) where

import Prelude
import Data.Maybe
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
foreign import data Transaction :: * -> *
foreign import data ObjectStore :: *
foreign import data Index :: * -> * -> *

type UpgradeNeededEvent =
  { old :: Version
  , new :: Version
  , db :: Connection
  , transaction :: Transaction VersionChange
  }


data CreateObjectStoreOptions
  = KeyPath (Array String)
  | AutoIncrement (Maybe String)


data MultiEntry
  = MultiEntry


data SingleEntry
  = SingleEntry


class ArrayIndexPolicy a where
  multiEntry :: a -> Boolean


instance multiEntryArrayIndexPolicy :: ArrayIndexPolicy MultiEntry where
  multiEntry _ = true


instance singleEntryArrayIndexPolicy :: ArrayIndexPolicy SingleEntry where
  multiEntry _ = false


data Unique
  = Unique


data NonUnique
  = NonUnique


class Uniqueness a where
  unique :: a -> Boolean


instance uniqueUniquess :: Uniqueness Unique where
  unique _ = true


instance uniqueUniqueness :: Uniqueness NonUnique where
  unique _ = false


data ReadOnly
  = ReadOnly


data ReadWrite
  = ReadWrite


data VersionChange
  = VersionChange


class TransactionMode a where
  transactionMode :: a -> String


instance readOnlyTransactionMode :: TransactionMode ReadOnly where
  transactionMode _ = "readonly"


instance readWriteTransactionMode :: TransactionMode ReadWrite where
  transactionMode _ = "readwrite"


instance versionChangeTransactionMode :: TransactionMode VersionChange where
  transactionMode _ = "versionchange"


foreign import openNative
  :: forall eff
   . Fn5
      String
      Version
      (Connection -> Eff (idb :: IDB | eff) Unit)
      (Error -> Eff (idb :: IDB | eff) Unit)
      (UpgradeNeededEvent -> Eff (idb :: IDB | eff) Unit)
      (Eff (idb :: IDB | eff) Unit)


foreign import createObjectStoreNative
  :: forall eff
   . Fn3
      Connection
      String
      CreateObjectStoreOptions
      (Eff (idb :: IDB | eff) ObjectStore)


foreign import createIndexNative
  :: forall eff uniq arrays
   . Fn5
      ObjectStore
      String
      String
      Boolean
      Boolean
      (Eff (idb :: IDB | eff) (Index uniq arrays))


open
  :: forall eff
   . String
  -> Version
  -> (UpgradeNeededEvent -> Eff (idb :: IDB | eff) Unit)
  -> Aff (idb :: IDB | eff) Connection
open name version upgrade =
  makeAff
    (\error success ->
      runFn5 openNative name version success error upgrade)


createObjectStore
  :: forall eff
   . Connection
  -> String
  -> CreateObjectStoreOptions
  -> (Eff (idb :: IDB | eff) ObjectStore)
createObjectStore db name options =
  runFn3 createObjectStoreNative db name options


createIndex
  :: forall eff uniq arrays
   . (Uniqueness uniq, ArrayIndexPolicy arrays)
  => ObjectStore
  -> String
  -> String
  -> uniq
  -> arrays
  -> Eff (idb :: IDB | eff) (Index uniq arrays)
createIndex name store keyPath uniqueness arrays =
  runFn5
    createIndexNative
      name
      store
      keyPath
      (unique uniqueness)
      (multiEntry arrays)
