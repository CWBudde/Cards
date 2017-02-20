unit Cordova.StatusBar;

interface

uses
  W3C.HTML5, W3C.DOM4;

type
  JStatusBar = class external 'StatusBar'
  public
    isVisible: Boolean; // read only
    procedure overlaysWebView(Value: Boolean);
    procedure styleDefault;
    procedure styleLightContent;
    procedure styleBlackTranslucent;
    procedure styleBlackOpaque;
    procedure backgroundColorByName(Color: String);    
    procedure backgroundColorByHexString(Color: String);
    procedure hide;
    procedure show;
  end;
  
var StatusBar external 'StatusBar': JStatusBar;

implementation

end.