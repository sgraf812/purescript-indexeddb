"use strict"

// module IndexedDB

exports.openNative = function(dbName, version, onSuccess, onFailure, onUpgradeNeeded) {
  return function() {
    if (indexedDB) {
      var request;

      try {
        request = indexedDB.open(dbName, version);
      } catch (exception) {
        onFailure(exception)();
      }

      request.onupgradeneeded = function(event) {
        onUpgradeNeeded({
          old: event.oldVersion,
          new: event.newVersion,
          db: event.target.result,
          transaction: event.target.transaction
        })();
      };

      request.onsuccess = function(event) {
        onSuccess(event.target.result)();
      }

      request.onerror = function(error) {
        onFailure(error)();
      }
    } else {
      onFailure(new Error("This environment does not support indexedDB."))();
    }
  };
};

exports.createObjectStoreNative = function(db, name, options) {
  return function() {
    var Data_Maybe = PS["Data.Maybe"] || {};
    var o = {};

    if (exports.KeyPath && options instanceof exports.KeyPath) {
      o.keyPath = options.value0;
    } else if (exports.AutoIncrement && options instanceof exports.AutoIncrement) {
      o.autoIncrement = true;
      var m = options.value0;
      if (Data_Maybe.Just && m instanceof Data_Maybe.Just) {
        o.keyPath = m.value0;
      } else if (Data_Maybe.Nothing && m instanceof Data_Maybe.Nothing) {
      }
    }

    return db.createObjectStore(name, o);
  }
}
