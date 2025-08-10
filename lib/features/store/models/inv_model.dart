// ignore_for_file: unnecessary_getters_setters

import 'dart:convert';

import 'package:c_ri/features/store/models/gsheet_models/inv_sheet_fields.dart';

class CInventoryModel {
  int? _productId;

  String _userId = "";
  String _userEmail = "";
  String _userName = "";

  String _pCode = "";
  String _name = "";
  int _markedAsFavorite = 0;
  int _quantity = 0;
  int _qtySold = 0;
  int _qtyRefunded = 0;
  double _buyingPrice = 0.0;
  double _unitBp = 0.0;
  double _unitSellingPrice = 0.0;
  int _lowStockNotifierLimit = 0;
  String _supplierName = "";
  String _supplierContacts = "";
  String _dateAdded = "";
  String _lastModified = "";
  int _isSynced = 0;
  String _syncAction = "";

  CInventoryModel(
    //this._productId,
    this._userId,
    this._userEmail,
    this._userName,
    this._pCode,
    this._name,
    this._markedAsFavorite,
    this._quantity,
    this._qtySold,
    this._qtyRefunded,
    this._buyingPrice,
    this._unitBp,
    this._unitSellingPrice,
    this._lowStockNotifierLimit,
    this._supplierName,
    this._supplierContacts,
    this._dateAdded,
    this._lastModified,
    this._isSynced,
    this._syncAction,
  );

  CInventoryModel.withID(
    this._productId,
    this._userId,
    this._userEmail,
    this._userName,
    this._pCode,
    this._name,
    this._markedAsFavorite,
    this._quantity,
    this._qtySold,
    this._qtyRefunded,
    this._buyingPrice,
    this._unitBp,
    this._unitSellingPrice,
    this._lowStockNotifierLimit,
    this._supplierName,
    this._supplierContacts,
    this._dateAdded,
    this._lastModified,
    this._isSynced,
    this._syncAction,
  );

  CInventoryModel empty() {
    return CInventoryModel('', '', '', '', '', 0, 0, 0, 0, 0.0, 0.0, 0.0, 0, '',
        '', '', '', 0, '');
  }

  int? get productId => _productId;
  String get userId => _userId;
  String get userEmail => _userEmail;
  String get userName => _userName;

  String get pCode => _pCode;
  String get name => _name;

  int get markedAsFavorite => _markedAsFavorite;

  int get quantity => _quantity;
  int get qtySold => _qtySold;
  int get qtyRefunded => _qtyRefunded;

  double get buyingPrice => _buyingPrice;
  double get unitBp => _unitBp;
  double get unitSellingPrice => _unitSellingPrice;

  int get lowStockNotifierLimit => _lowStockNotifierLimit;

  String get supplierName => _supplierName;
  String get supplierContacts => _supplierContacts;
  String get dateAdded => _dateAdded;
  String get lastModified => _lastModified;
  int get isSynced => _isSynced;
  String get syncAction => _syncAction;

  set userId(String newUid) {
    _userId = newUid;
  }

  set userEmail(String newUEmail) {
    _userEmail = newUEmail;
  }

  set userName(String newUName) {
    _userName = newUName;
  }

  set productId(int? newId) {
    _productId = newId;
  }

  set pCode(String newPcode) {
    _pCode = newPcode;
  }

  set name(String newName) {
    _name = newName;
  }

  set markedAsFavorite(int isMarkedAsFavorite) {
    _markedAsFavorite = isMarkedAsFavorite;
  }

  set quantity(int newQty) {
    if (newQty >= 0) {
      _quantity = newQty;
    }
  }

  set qtySold(int newQtySold) {
    _qtySold = newQtySold;
  }

  set qtyRefunded(int newQtyRefunded) {
    _qtyRefunded = newQtyRefunded;
  }

  set buyingPrice(double newBP) {
    _buyingPrice = newBP;
  }

  set unitBp(double newUBP) {
    _unitBp = newUBP;
  }

  set unitSellingPrice(double newUSP) {
    _unitSellingPrice = newUSP;
  }

  set lowStockNotifierLimit(int newLimit) {
    _lowStockNotifierLimit = newLimit;
  }

  set supplierName(String supName) {
    _supplierName = supName;
  }

  set supplierContacts(String supContacts) {
    _supplierContacts = supContacts;
  }

  set dateAdded(String newDateAdded) {
    _dateAdded = newDateAdded;
  }

  set lastModified(String newLastModified) {
    _lastModified = newLastModified;
  }

  set isSynced(int syncState) {
    _isSynced = syncState;
  }

  set syncAction(String newSyncAction) {
    _syncAction = newSyncAction;
  }

  // convert an InventoryModel object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    if (productId != null) {
      map['productId'] = _productId;
    }
    map['userId'] = _userId;
    map['userEmail'] = _userEmail;
    map['userName'] = _userName;

    map['pCode'] = _pCode;
    map['name'] = _name;
    map['markedAsFavorite'] = _markedAsFavorite;

    map['quantity'] = _quantity;
    map['qtySold'] = _qtySold;
    map['qtyRefunded'] = _qtyRefunded;

    map['buyingPrice'] = _buyingPrice;
    map['unitBp'] = _unitBp;
    map['unitSellingPrice'] = _unitSellingPrice;
    map['lowStockNotifierLimit'] = _lowStockNotifierLimit;

    map['supplierName'] = _supplierName;
    map['supplierContacts'] = _supplierContacts;

    map['dateAdded'] = _dateAdded;
    map['lastModified'] = _lastModified;

    map['isSynced'] = _isSynced;
    map['syncAction'] = _syncAction;

    return map;
  }

  // extract a InventoryModel object from a Map object
  CInventoryModel.fromMapObject(Map<String, dynamic> map) {
    _productId = map['productId'];
    _userId = map['userId'];
    _userEmail = map['userEmail'];
    _userName = map['userName'];

    _name = map['name'];
    _markedAsFavorite = map['markedAsFavorite'];
    _pCode = map['pCode'];
    _quantity = map['quantity'];
    _qtySold = map['qtySold'];
    _qtyRefunded = map['qtyRefunded'];

    _buyingPrice = map['buyingPrice'];
    _unitBp = map['unitBp'];
    _unitSellingPrice = map['unitSellingPrice'];
    _lowStockNotifierLimit = map['lowStockNotifierLimit'];
    _supplierName = map['supplierName'];
    _supplierContacts = map['supplierContacts'];

    _dateAdded = map['dateAdded'];
    _lastModified = map['lastModified'];

    _isSynced = map['isSynced'];
    _syncAction = map['syncAction'];
  }

  // extract a CInventoryModel object from a GSheet Map object
  static CInventoryModel gSheetFromJson(Map<String, dynamic> json) {
    return CInventoryModel.withID(
      jsonDecode(json[InvSheetFields.productId]),
      json[InvSheetFields.userId],
      json[InvSheetFields.userEmail],
      json[InvSheetFields.userName],
      json[InvSheetFields.pCode],
      json[InvSheetFields.name],
      jsonDecode(json[InvSheetFields.markedAsFavorite]),
      jsonDecode(json[InvSheetFields.quantity]),
      jsonDecode(json[InvSheetFields.qtySold]),
      jsonDecode(json[InvSheetFields.qtyRefunded]),
      double.parse(json[InvSheetFields.buyingPrice]),
      double.parse(json[InvSheetFields.unitBp]),
      double.parse(json[InvSheetFields.unitSellingPrice]),
      jsonDecode(json[InvSheetFields.lowStockNotifierLimit]),
      json[InvSheetFields.supplierName],
      json[InvSheetFields.supplierContacts],
      json[InvSheetFields.dateAdded],
      json[InvSheetFields.lastModified],
      jsonDecode(json[InvSheetFields.isSynced]),
      json[InvSheetFields.syncAction],
    );
  }
}
