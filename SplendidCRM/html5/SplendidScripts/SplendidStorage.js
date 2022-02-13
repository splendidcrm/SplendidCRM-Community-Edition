/*
 * This program is free software: you can redistribute it and/or modify it under the terms of the 
 * GNU Affero General Public License as published by the Free Software Foundation, either version 3 
 * of the License, or (at your option) any later version.
 * 
 * In accordance with Section 7(b) of the GNU Affero General Public License version 3, 
 * the Appropriate Legal Notices must display the following words on all interactive user interfaces: 
 * "Copyright (C) 2005-2022 SplendidCRM Software, Inc. All rights reserved."
 */

// http://dev.w3.org/html5/webstorage/
// http://www.w3.org/TR/webdatabase/
var SplendidStorage = 
{
	db: null
	, maxDatabase: null
	, Init: function(callback, context)
	{
		if ( window.openDatabase )
		{
			try
			{
				// 10/23/2011 Paul.  Set database size to 100M. 
				if ( this.maxDatabase == null || this.maxDatabase <= 0 )
					this.maxDatabase = 100*1024*1024;
				SplendidError.SystemMessage('Opening Web SQL database.');
				this.db = openDatabase('SplendidCRM', '1.0', 'SplendidCRM HTML5 Offline Client', this.maxDatabase, function(db)
				{
					// 10/23/2011 Paul.  This event does not fire if the database already exists, 
					SplendidError.SystemMessage('Web SQL Database has been created.');
				});
				// 10/22/2011 Paul.  openDatabase() returns before the callback, but it may not call the callback if the database already exists. 
				if ( this.db != null )
				{
					SplendidError.SystemMessage('Using Web SQL.');
					this.db.transaction(function(tx)
					{
						tx.executeSql('create table if not exists LOCAL_STORAGE(KEY unique, VALUE)', [], function(tx, results)
						{
							if ( callback )
								callback.call(context||this, 1, '');
						}
						, function(err)
						{
							SplendidError.SystemMessage('SplendidStorage.Init() execute: ' + err.message);
							// 10/21/2011 Paul.  If there was an error opening the database, then just use localStorage. 
							this.db = null;
							if ( callback )
								callback.call(context||this, 1, '');
						});
					}
					, function(err)
					{
						SplendidError.SystemMessage('SplendidStorage.Init() transaction: ' + err.message);
						// 10/21/2011 Paul.  If there was an error opening the database, then just use localStorage. 
						this.db = null;
						if ( callback )
							callback.call(context||this, 1, '');
					}
					, function(tx)
					{
						// 05/06/2013 Paul.  Success callback is causing Chrome to execute SplendidUI_Init twice. 
						//if ( callback )
						//	callback.call(context||this, 1, '');
					});
				}
			}
			catch(e)
			{
				SplendidError.SystemMessage('SplendidStorage.Init() ' + e.message);
				// 10/21/2011 Paul.  If there was an error opening the database, then just use localStorage. 
				// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
				if ( window.localStorage )
					SplendidError.SystemMessage('Using localStorage.');
				else
					SplendidError.SystemMessage('localStorage is not supported.');
				this.db = null;
				if ( callback )
					callback.call(context||this, 1, '');
			}
		}
		else
		{
			// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
			if ( window.localStorage )
				SplendidError.SystemMessage('Using localStorage.');
			else
				SplendidError.SystemMessage('localStorage is not supported.');
			// 10/21/2011 Paul.  localStorage does not need to be initialized. 
			if ( callback )
				callback.call(context||this, 1, '');
		}
	}
	, setItem: function(key, value, callback, context)
	{
		if ( this.db != null )
		{
			this.db.transaction(function(tx)
			{
				// 10/21/2011 Paul.  Using insertions protect against SQL injection, so no further escaping is necessary. 
				// 10/21/2011 Paul.  SQLite supports replacing a row if it already exists. 
				// http://www.sqlite.org/lang_insert.html
				tx.executeSql('insert or replace into LOCAL_STORAGE values(?, ?)', [key, value], function(tx, results)
				{
					//alert('setItem ' + results.rowsAffected + ', ' + results.insertId);
					//if ( results.rowsAffected > 0 && results.insertId != null )
					//	SplendidError.SystemLog('SplendidStorage.setItem(' + key + ') executeSql: inserted row ' + results.insertId);
					callback.call(context||this, 1, '');
				}
				, function(err)
				{
					callback.call(context||this, -1, 'SplendidStorage.setItem(' + key + ') executeSql: ' + err.message);
				});
			}
			, function(err)
			{
				callback.call(context||this, -1, 'SplendidStorage.setItem(' + key + ') transaction: ' + err.message);
			}
			, function(tx)
			{
				// 10/21/2011 Paul.  Success callback is from executeSql. 
				//SplendidError.SystemLog('SplendidStorage.setItem(' + key + ') transaction complete');
			});
		}
		else
		{
			// 10/19/2011 Paul.  IE6 does not support localStorage. 
			try
			{
				// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
				if ( bENABLE_OFFLINE && window.localStorage )
				{
					try
					{
						localStorage[key] = value;
						callback.call(context||this, 1, '');
					}
					catch(e)
					{
						// 03/10/2013 Paul.  IE9 is throwing an out-of-memory error. Just ignore the error. 
						//if ( window.localStorage.remainingSpace !== undefined )
						//	alert('remainingSpace = ' + window.localStorage.remainingSpace);
						callback.call(context||this, -1, SplendidError.FormatError(e, 'SplendidStorage.setItem'));
					}
				}
			}
			catch(e)
			{
				callback.call(context||this, -1, SplendidError.FormatError(e, 'SplendidStorage.setItem'));
			}
		}
	}
	, getItem: function(key, callback, context)
	{
		if ( this.db != null )
		{
			this.db.transaction(function(tx)
			{
				// 10/21/2011 Paul.  Not sure if count(*) will work, so just return the entire table. 
				tx.executeSql('select * from LOCAL_STORAGE where key = ?', [key], function(tx, results)
				{
					if ( results.rows.length > 0 )
					{
						// 11/27/2011 Paul.  Return the value, not the key. 
						callback.call(context||this, 1, results.rows.item(0).VALUE);
					}
					else
					{
						callback.call(context||this, -1, null);
					}
				}
				, function(err)
				{
					callback.call(context||this, -1, 'SplendidStorage.getItem(' + key + ') executeSql: ' + err.message);
				});
			}
			, function(err)
			{
				callback.call(context||this, -1, 'SplendidStorage.getItem(' + key + ') transaction: ' + err.message);
			}
			, function(tx)
			{
				// 10/21/2011 Paul.  Success callback is from executeSql. 
				//SplendidError.SystemLog('SplendidStorage.getItem(' + key + ') transaction complete');
			});
		}
		else
		{
			// 10/19/2011 Paul.  IE6 does not support localStorage. 
			// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
			if ( bENABLE_OFFLINE && window.localStorage )
				callback.call(context||this, 1, localStorage[key]);
			else
				callback.call(context||this, -1, null);
		}
	}
	, removeItem: function(key, callback, context)
	{
		if ( this.db != null )
		{
			this.db.transaction(function(tx)
			{
				tx.executeSql('delete from LOCAL_STORAGE where KEY = ?', [key], function(tx, results)
				{
					if ( callback )
						callback.call(context||this, 1, '');
				}
				, function(err)
				{
					if ( callback )
						callback.call(context||this, -1, 'SplendidStorage.removeItem(' + key + ') executeSql: ' + err.message);
				});
			}
			, function(err)
			{
				if ( callback )
					callback.call(context||this, -1, 'SplendidStorage.removeItem(' + key + ') transaction: ' + err.message);
			}
			, function(tx)
			{
				// 10/21/2011 Paul.  Success callback is from executeSql. 
				//SplendidError.SystemLog('SplendidStorage.removeItem(' + key + ') transaction complete');
			});
		}
		else
		{
			// 10/21/2011 Paul.  removeItem will do nothing if the item does not exist. 
			// 10/19/2011 Paul.  IE6 does not support localStorage. 
			// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
			if ( bENABLE_OFFLINE && window.localStorage )
				localStorage.removeItem(key);
			if ( callback )
				callback.call(context||this, 1, '');
		}
	}
	, foreach: function(callback, context)
	{
		if ( this.db != null )
		{
			this.db.transaction(function(tx)
			{
				// 10/21/2011 Paul.  Not sure if count(*) will work, so just return the entire table. 
				tx.executeSql('select * from LOCAL_STORAGE', [], function(tx, results)
				{
					try
					{
						for ( var i = 0; i < results.rows.length; i++ )
						{
							callback.call(context||this, 1, results.rows.item(i).KEY, results.rows.item(i).VALUE);
						}
						callback.call(context||this, 0, '');
					}
					catch(e)
					{
						SplendidError.SystemMessage(SplendidError.FormatError(e, ''));
					}
				}
				, function(err)
				{
					callback.call(context||this, -1, 'SplendidStorage.foreach() executeSql: ' + err.message);
				});
			}
			, function(err)
			{
				callback.call(context||this, -1, 'SplendidStorage.foreach() transaction: ' + err.message);
			}
			, function(tx)
			{
				// 10/21/2011 Paul.  Success callback is from executeSql. 
			});
		}
		// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
		else if ( window.localStorage )
		{
			var nLength = localStorage.length;
			for ( var i = 0; i < localStorage.length; i++ )
			{
				var key = localStorage.key(i);
				callback.call(context||this, 1, key, localStorage[key]);
			}
			callback.call(context||this, 0, '');
		}
		else
		{
			// 10/19/2011 Paul.  IE6 does not support localStorage. 
			callback.call(context||this, -1, 'Storage not supported.');
		}
	}
	, key: function(index, callback, context)
	{
		if ( this.db != null )
		{
			this.db.transaction(function(tx)
			{
				// 10/21/2011 Paul.  Not sure if count(*) will work, so just return the entire table. 
				tx.executeSql('select * from LOCAL_STORAGE', [], function(tx, results)
				{
					if ( index < results.rows.length )
					{
						callback.call(context||this, 1, results.rows.item(index).KEY);
					}
					else
					{
						callback.call(context||this, 1, null);
					}
				}
				, function(err)
				{
					callback.call(context||this, -1, 'SplendidStorage.key(' + index + ') executeSql: ' + err.message);
				});
			}
			, function(err)
			{
				callback.call(context||this, -1, 'SplendidStorage.key(' + index + ') transaction: ' + err.message);
			}
			, function(tx)
			{
				// 10/21/2011 Paul.  Success callback is from executeSql. 
				//SplendidError.SystemLog('SplendidStorage.key(' + index + ') transaction complete');
			});
		}
		else
		{
			// 10/19/2011 Paul.  IE6 does not support localStorage. 
			// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
			if ( bENABLE_OFFLINE && window.localStorage )
				callback.call(context||this, 1, localStorage.key(index));
			else
				callback.call(context||this, 1, null);
		}
	}
	, length: function(callback, context)
	{
		if ( this.db != null )
		{
			this.db.transaction(function(tx)
			{
				// 10/21/2011 Paul.  Not sure if count(*) will work, so just return the entire table. 
				tx.executeSql('select * from LOCAL_STORAGE', [], function(tx, results)
				{
					callback.call(context||this, 1, results.rows.length);
				}
				, function(err)
				{
					callback.call(context||this, -1, 'SplendidStorage.length() executeSql: ' + err.message);
				});
			}
			, function(err)
			{
				callback.call(context||this, -1, 'SplendidStorage.length() transaction: ' + err.message);
			}
			, function(tx)
			{
				// 10/21/2011 Paul.  Success callback is from executeSql. 
				//SplendidError.SystemLog('SplendidStorage.length() transaction complete');
			});
		}
		else
		{
			// 10/19/2011 Paul.  IE6 does not support localStorage. 
			// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
			if ( bENABLE_OFFLINE && window.localStorage )
				callback.call(context||this, 1, localStorage.length);
			else
				callback.call(context||this, 1, 0);
		}
	}
	, clear: function(callback, context)
	{
		if ( this.db != null )
		{
			this.db.transaction(function(tx)
			{
				tx.executeSql('delete from LOCAL_STORAGE', function(tx, results)
				{
					if ( callback )
						callback.call(context||this, 1, '');
				}
				, function(err)
				{
					if ( callback )
						callback.call(context||this, -1, 'SplendidStorage.clear() executeSql: ' + err.message);
				});
			}
			, function(err)
			{
				if ( callback )
					callback.call(context||this, -1, 'SplendidStorage.clear() transaction: ' + err.message);
			}
			, function(tx)
			{
				// 10/21/2011 Paul.  Success callback is from executeSql. 
				//SplendidError.SystemLog('SplendidStorage.clear() transaction complete');
			});
		}
		else
		{
			// 10/19/2011 Paul.  IE6 does not support localStorage. 
			// 12/08/2011 Paul.  IE7 defines window.XMLHttpRequest but not window.localStorage. 
			if ( bENABLE_OFFLINE && window.localStorage )
				localStorage.clear();
			if ( callback )
				callback.call(context||this, 1, '');
		}
	}
};

