unit Cordova.Device;

type
  JDevice = class external 'device'
    cordova: String; // read only
    isVirtual: Boolean; // read only
    model: String; // read only
    platform: String; // read only
    manufacturer: String; // read only
    serial: String; // read only
    uuid: String; // read only
    version: String; // read only
  end;

var Device external 'device': JDevice;
