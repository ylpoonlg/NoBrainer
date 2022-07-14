const List<String> dbTables = [
  '''
    CellFolders (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cellid INTEGER,
      orderid INTEGER,
      name TEXT,
      parent INTEGER
    )
  ''',
  '''
    BrainCells (
      cellid INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT,
      type TEXT,
      color INTEGER,
      settings TEXT
    )
  ''',
  '''
    Settings (
      name TEXT PRIMARY KEY,
      value TEXT
    )
  ''',

//----------------------------------------------------------

  '''
    TodoItems (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cellid INTEGER,
      title TEXT,
      desc TEXT,
      deadline TEXT,
      notifyid INTEGER
    )
  ''',

//----------------------------------------------------------

  '''
    MoneyPitItems (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cellid INTEGER,
      title TEXT,
      desc TEXT,
      amount REAL,
      paymethod TEXT,
      category TEXT,
      time TEXT
    )
  ''',
  '''
    PayMethods (
      name TEXT PRIMARY KEY
    )
  ''',
  '''
    MoneyCategories (
      name TEXT PRIMARY KEY,
      icon TEXT,
      color INTEGER
    )
  ''',

//----------------------------------------------------------

  '''
    ShopItems (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      cellid INTEGER,
      title TEXT,
      desc TEXT,
      shops TEXT
    )
  ''',
  '''
    Shops (
      name TEXT PRIMARY KEY
    )
  ''',


];
