"use strict"

// module IndexedDB

exports.openNative = function(dbName, version, onSuccess, onFailure, onUpgradeNeeded) {
  return function() {
    if (indexedDB) {
      var request;

      try {
        request = indexedDB.open(dbName, version);
        console.log("Created request" + request);
      } catch (exception) {
        onFailure(exception)();
      }

      request.onupgradeneeded = function(event) {
        onUpgradeNeeded(event.oldVersion)(event.newVersion)(event.target.result)(event.target.transaction)();
      };

      request.onsuccess = function(event) {
        console.log("Created db " + event.target.result);
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

exports.createObjectStoreNative = function(db, name, updates) {
  return function() {
    var o = {};

    for (var i = 0; i < updates.length; ++i) {
      var u = updates[i];
      if (u instanceof KeyPath) {
        o.keyPath = u.value0;
      } else if (u instanceof AutoIncrement) {
        o.autoIncrement = true;
      }
    }

    return db.createObjectStore(name, o);
  }
}
