unit Card.Confetti;

interface

uses
  W3C.HighResolutionTime, Cards.Framework;

type
  TConfetti = class;

  TConfettiSnippet = class
  private
    FOwner: TConfetti;
    FRotationSpeed: Float;
    FAngle: Float;
    FRotation: Float;
    FOscillationSpeed: Float;
    FSpeed: TVector2f;
    FTime: Float;
    FCorners: array [0..3] of TVector2f;
    FColors: array [0..1] of String;
    FPosition: TVector2f;
  public
    constructor Create(Owner: TConfetti);

    procedure Resize;
    procedure Draw(ElapsedSeconds: Float = 0);
  end;

  TConfetti = class(TCanvas2DElement)
  private
    FConfettiSnippets: array of TConfettiSnippet;
    FRunning: Boolean;
    FRise: Boolean;
    FAlpha: Float;
    FAnimHandle: Integer;
    FPixelRatio: Float;
    FLastTimeStamp: TDOMHighResTimeStamp;
  public
    constructor Create(Owner: IHtmlElementOwner); overload; override;

    procedure Resize;
    procedure Draw(TimeStamp: TDOMHighResTimeStamp);

    procedure Start;
    procedure Stop;
    procedure Reset;

    property Running: Boolean read FRunning;
    property PixelRatio: Float read FPixelRatio;
    property Rise: Boolean read FRise;
  end;

implementation

uses
  ECMA.Console, W3C.HTML5;

var GRequestAnimFrame: function(const AMethod: TFrameRequestCallback): Integer;
var GCancelAnimFrame: procedure(Handle: Integer);

procedure InitAnimationFrameShim;
begin
  asm
    @GRequestAnimFrame = (function(){
      return  window.requestAnimationFrame       ||
              window.webkitRequestAnimationFrame ||
              window.mozRequestAnimationFrame    ||
              window.msRequestAnimationFrame     ||
              function( callback ){
                return window.setTimeout(callback(50/3), 50/3);
              };
    })();
    @GCancelAnimFrame = (function(){
      return  window.cancelAnimationFrame       ||
              window.webkitCancelAnimationFrame ||
              window.mozCancelAnimationFrame    ||
              window.msCancelAnimationFrame     ||
              function( handle ){
                window.clearTimeout(handle);
              };
    })();
  end;
end;

function RequestAnimationFrame(const AMethod: TFrameRequestCallback): Integer;
begin
  if not Assigned(GRequestAnimFrame) then
    InitAnimationFrameShim;
  Result := GRequestAnimFrame(aMethod);
end;

procedure CancelAnimationFrame(Handle: Integer);
begin
  if not Assigned(GCancelAnimFrame) then
    InitAnimationFrameShim;
  GCancelAnimFrame(handle);
end;


{ TConfettiSnippet }

constructor TConfettiSnippet.Create(Owner: TConfetti);
const
  CColors = [
    ['#df0049', '#660671'],
    ['#00e857', '#005291'],
    ['#2bebbc', '#05798a'],
    ['#ffd200', '#b06c00']
  ];
begin
  FOwner := Owner;

  FPosition := TVector2F.Create(
    Random * FOwner.CanvasElement.Width,
    Random * FOwner.CanvasElement.Height);
  FColors := CColors[RandomInt(CColors.Length)];

  var PixelRatio := FOwner.PixelRatio;
  FRotationSpeed := 2 * Pi * (Random + 1);
  FAngle := Random * 2 * Pi;
  FRotation := Random * 2 * Pi;
  FOscillationSpeed := Random * 1.5 + 0.5;
  FSpeed := TVector2f.Create(PixelRatio * (40), PixelRatio * (Random * 60 + 50));
  for var Index := 0 to 3 do
    FCorners[Index] := TVector2f.Create(
      Cos(FAngle + Pi * (Index * 0.5 + 0.25)) * 5 * PixelRatio,
      Sin(FAngle + Pi * (Index * 0.5 + 0.25)) * 5 * PixelRatio);
  FTime := random;
end;

procedure TConfettiSnippet.Resize;
begin
  FPosition := TVector2F.Create(
    Random * FOwner.CanvasElement.Width,
    Random * FOwner.CanvasElement.Height);
end;

procedure TConfettiSnippet.Draw(ElapsedSeconds: Float = 0);
begin
  FTime += ElapsedSeconds;
  FRotation += FRotationSpeed * ElapsedSeconds;
  var CosZ := Cos(FRotation);

  FPosition.x += Cos(FTime * FOscillationSpeed) * FSpeed.X * ElapsedSeconds;
  FPosition.y += FSpeed.Y * ElapsedSeconds;
  if FPosition.y > FOwner.CanvasElement.Height then
  begin
    FPosition.x := Random * FOwner.CanvasElement.Width;
    FPosition.y := 0;
  end;

  var Context := FOwner.Context;

  if CosZ > 0 then
    Context.fillStyle := FColors[0]
  else
    Context.fillStyle := FColors[1];

  Context.beginPath;
  Context.moveTo(
    FPosition.x + FCorners[0].x,
    FPosition.y + FCorners[0].y * CosZ);
  for var Index := 1 to 3 do
    Context.LineTo(
      FPosition.x + FCorners[Index].x,
      FPosition.y + FCorners[Index].y * CosZ);
  Context.closePath;
  Context.fill;
end;


{ TConfetti }

constructor TConfetti.Create(Owner: IHtmlElementOwner);
begin
  inherited Create(Owner);

  // determine pixel ratio
  FPixelRatio := 1;
  asm
    @FPixelRatio = window.devicePixelRatio || 1;
  end;

  CanvasElement.width := Round(FPixelRatio * Window.innerWidth);
  CanvasElement.height := Round(FPixelRatio * Window.innerHeight);

  Style.display := 'none';

  for var i := 0 to 99 do
    FConfettiSnippets.Add(TConfettiSnippet.Create(Self));

  FAlpha := 0;
end;

procedure TConfetti.Draw(TimeStamp: TDOMHighResTimeStamp);
begin
  // get time between the last frame
  var ElapsedSeconds := Clamp(0.001 * (TimeStamp - FLastTimeStamp), 0, 0.5);
  FLastTimeStamp := TimeStamp;

  Context.clearRect(0, 0, CanvasElement.width, CanvasElement.Height);

  Context.GlobalAlpha := FAlpha;
  for var ConfettiSnippet in FConfettiSnippets do
    ConfettiSnippet.Draw(ElapsedSeconds);
  Context.GlobalAlpha := 1;

  if FRise then
    FAlpha := Min(FAlpha + ElapsedSeconds, 1)
  else
  begin
    FAlpha := FAlpha - ElapsedSeconds;
    if FAlpha < 0 then
    begin
      FAlpha := 0;
      CancelAnimationFrame(FAnimHandle);
      Style.display := 'none';
      Exit;
    end;
  end;

  FAnimHandle := RequestAnimationFrame(Draw);
end;

procedure TConfetti.Resize;
begin
  var NewWidth := Round(FPixelRatio * Window.innerWidth);
  var NewHeight := Round(FPixelRatio * Window.innerHeight);

  if (CanvasElement.width <> NewWidth) or (CanvasElement.height <> NewHeight) then
  begin
    CanvasElement.width := NewWidth;
    CanvasElement.height := NewHeight;

    for var ConfettiSnippet in FConfettiSnippets do
      ConfettiSnippet.Resize;
  end;
end;

procedure TConfetti.Start;
begin
  FRise := True;
  Style.display := 'block';
  FLastTimeStamp := Now;
  FAnimHandle := RequestAnimationFrame(Draw);
end;

procedure TConfetti.Stop;
begin
  FRise := False;
end;

procedure TConfetti.Reset;
begin
  FRise := False;
end;

end.