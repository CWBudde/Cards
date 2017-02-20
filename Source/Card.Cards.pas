unit Card.Cards;

interface

uses
  ECMA.TypedArray, W3C.DOM4, W3C.HTML5, W3C.WebAudio, W3C.Canvas2DContext,
  Card.Framework, Card.Drawer;

type
  TCardColor = (ccSpade, ccHeart, ccClub, ccDiamond);
  TCardValue = (cvA, cv2, cv3, cv4, cv5, cv6, cv7, cv8, cv9, cv10, cvJ, cvQ, cvK);

  TCard = class(TCanvas2DElement)
  private
    FColor: TCardColor;
    FValue: TCardValue;
    FIsConcealed: Boolean;
    FIsHighlighted: Boolean;
    FTransitionTime: Float;
    FPixelRatio: Float;
    FDrawerColor: TCustomCardColorDrawerClass;
    FDrawerValue: TCustomCardValueDrawerClass;
    procedure SetIsConcealed(Value: Boolean);
    procedure SetIsHighlighted(Value: Boolean);
    procedure SetTransitionTime(Value: Float);
  public
    constructor Create(Owner: IHtmlElementOwner; Color: TCardColor; Value: TCardValue); overload; virtual;

    procedure Resize;
    procedure Paint;

    property Color: TCardColor read FColor;
    property Value: TCardValue read FValue;
    property IsConcealed: Boolean read FIsConcealed write SetIsConcealed;
    property IsHighlighted: Boolean read FIsHighlighted write SetIsHighlighted;
    property TransitionTime: Float read FTransitionTime write SetTransitionTime;
  end;

  TArrayOfCard = array of TCard;

implementation

uses
  ECMA.Console;

{ TCard }

constructor TCard.Create(Owner: IHtmlElementOwner; Color: TCardColor; Value: TCardValue);
const
  CDrawerColor: array [TCardColor] of TCustomCardColorDrawerClass =
    (TCardColorDrawerSpade, TCardColorDrawerHeart, TCardColorDrawerClub,
     TCardColorDrawerDiamond);
  CDrawerValue: array [TCardValue] of TCustomCardValueDrawerClass =
    (TCardValueDrawerA, TCardValueDrawer2, TCardValueDrawer3, TCardValueDrawer4,
     TCardValueDrawer5, TCardValueDrawer6, TCardValueDrawer7, TCardValueDrawer8,
     TCardValueDrawer9, TCardValueDrawer10, TCardValueDrawerJ,
     TCardValueDrawerQ, TCardValueDrawerK);
begin
  inherited Create(Owner);

  FColor := Color;
  FValue := Value;
  FIsConcealed := True;
  FTransitionTime := 0;

  // determine pixel ratio
  FPixelRatio := 1;
  asm
    @FPixelRatio = window.devicePixelRatio || 1;
  end;

  FDrawerColor := CDrawerColor[Color];
  FDrawerValue := CDrawerValue[Value];

  Resize;
end;

procedure TCard.Resize;
begin
  var R := CanvasElement.getBoundingClientRect;
  if (CanvasElement.width <> Round(FPixelRatio * R.width)) or
    (CanvasElement.height <> Round(FPixelRatio * R.height)) then
  begin
    CanvasElement.Width := Round(FPixelRatio * R.width);
    CanvasElement.Height := Round(FPixelRatio * R.height);

    Paint;
  end;
end;

procedure TCard.Paint;
const
  CText: array [TCardValue] of String = ('A', '2', '3', '4', '5', '6', '7',
    '8', '9', '=', 'J', 'Q', 'K');
begin
  var Large := CanvasElement.Width / 40;
  var Small := CanvasElement.Width / 60;
  var LargeFont := CanvasElement.Width / 12;
  var SmallFont := CanvasElement.Width / 36;

  Context.setTransform(1, 0, 0, 1, 0, 0);
  Context.ClearRect(0, 0, CanvasElement.Width, CanvasElement.Height);

  var Gradient := Context.createLinearGradient(0, 0, 0, CanvasElement.Height);
  Gradient.addColorStop(0, '#e1e1e1');
  Gradient.addColorStop(1, '#fcfcfc');
  Context.fillStyle := Gradient;
  Context.fillRect(1, 1, CanvasElement.Width, CanvasElement.Height);
  Context.clearRect(1, 1, 1, 1);

  if FIsConcealed then
  begin
    const CRoundWidth = 1.3;
    const CHalfLineWidth = 1;
    const CLineWidth = 1.3 * CHalfLineWidth;
    var Offset := 0.025 * CanvasElement.width;
    var TopLeft := TVector2F.Create(Offset + CHalfLineWidth, Offset + CHalfLineWidth);
    var BottomRight :=  TVector2F.Create(CanvasElement.Width - CHalfLineWidth - Offset, CanvasElement.Height - CHalfLineWidth - Offset);
    Context.strokeStyle := '#888';
    Context.FillStyle := '#001381';
    Context.LineWidth := CLineWidth;
    Context.BeginPath;
    Context.MoveTo(TopLeft.X + CRoundWidth, TopLeft.Y);
    Context.LineTo(BottomRight.X - CRoundWidth, TopLeft.Y);
    Context.arcTo(BottomRight.X, TopLeft.Y, BottomRight.X, TopLeft.Y + CRoundWidth, CRoundWidth);
    Context.LineTo(BottomRight.X, BottomRight.Y - CRoundWidth);
    Context.arcTo(BottomRight.X, BottomRight.Y, BottomRight.X - CRoundWidth, BottomRight.Y, CRoundWidth);
    Context.LineTo(TopLeft.X + CRoundWidth, BottomRight.Y);
    Context.arcTo(TopLeft.X, BottomRight.Y, TopLeft.X, BottomRight.Y - CRoundWidth, CRoundWidth);
    Context.LineTo(TopLeft.X, TopLeft.Y + CRoundWidth);
    Context.arcTo(TopLeft.X, TopLeft.Y, TopLeft.X + CRoundWidth, TopLeft.Y, CRoundWidth);

    Context.closePath;
    Context.Fill;
    Context.Stroke;

    Context.fillStyle := 'rgba(255,255,255,0.5)';
    Offset *= 1.5;
    var Scale := (BottomRight.X - TopLeft.X - 2 * Offset) / TCardDrawerOrnament.Width;
    Context.Translate(TopLeft.X + Offset, TopLeft.Y + Offset);
    TCardDrawerOrnament.Draw(Context, Scale);
    Context.Translate(BottomRight.X - TopLeft.X - 2 * Offset, BottomRight.Y - TopLeft.Y - 2 * Offset);
    TCardDrawerOrnament.Draw(Context, Scale, True);
    Context.Translate(-BottomRight.X + Offset, -BottomRight.Y + Offset);
    Exit;
  end;

  if FIsHighlighted then
  begin
    Context.fillStyle := 'rgba(255,255,255,0.5)';
    Context.fillRect(0, 0, CanvasElement.Width, CanvasElement.Height);
  end;

  Context.FillStyle := FDrawerColor.Color;
  Context.Translate(FPixelRatio * 6, FPixelRatio * 6);
  if Value in [cv2..cv9] then
    Context.Scale(1.4, 1);
  FDrawerValue.Draw(Context, SmallFont);
  if Value in [cv2..cv9] then
    Context.Scale(1 / 1.4, 1);
  Context.Translate(-FPixelRatio * 6, -FPixelRatio * 6);

  var w := 0.8 * CanvasElement.width;
  var h := 0.6 * CanvasElement.height;
  Context.translate(0.1 * CanvasElement.width, 0.2 * CanvasElement.height);

  case FValue of
    cvA:
      begin
        Context.beginPath;
        Context.translate(0.5 * w, 0.5 * h);
        FDrawerColor.Draw(Context, Large);
        Context.fill;
      end;
    cv2:
      begin
        Context.beginPath;
        Context.translate(0.5 * w, 0);
        FDrawerColor.Draw(Context, Small);
        Context.translate(0, h);
        FDrawerColor.Draw(Context, Small, True);
        Context.fill;
      end;
    cv3:
      begin
        Context.beginPath;
        Context.translate(0.5 * w, 0);
        for var Index := 1 to 3 do
        begin
          FDrawerColor.Draw(Context, Small, Index = 3);
          Context.translate(0, 0.5 * h);
        end;
        Context.fill;
      end;
    cv4:
      begin
        Context.beginPath;
        for var X := 0 to 1 do
          for var Y := 0 to 1 do
          begin
            var Offset := TVector2f.Create((0.25 + 0.5 * X) * w, Y * h);
            Context.translate(Offset.X, Offset.Y);
            FDrawerColor.Draw(Context, Small, Y = 1);
            Context.translate(-Offset.X, -Offset.Y);
          end;
        Context.fill;
      end;
    cv5:
      begin
        Context.beginPath;
        for var X := 0 to 1 do
          for var Y := 0 to 1 do
          begin
            var Offset := TVector2f.Create((0.25 + 0.5 * X) * w, Y * h);
            Context.translate(Offset.X, Offset.Y);
            FDrawerColor.Draw(Context, Small, Y = 1);
            Context.translate(-Offset.X, -Offset.Y);
          end;
        Context.translate(0.5 * w, 0.5 * h);
        FDrawerColor.Draw(Context, Small);
        Context.fill;
      end;
    cv6:
      begin
        Context.beginPath;
        for var X := 0 to 1 do
          for var Y := 0 to 2 do
          begin
            var Offset := TVector2f.Create((0.25 + 0.5 * X) * w, 0.5 * Y * h);
            Context.translate(Offset.X, Offset.Y);
            FDrawerColor.Draw(Context, Small, Y = 2);
            Context.translate(-Offset.X, -Offset.Y);
          end;
        Context.fill;
      end;
    cv7:
      begin
        Context.beginPath;
        for var X := 0 to 1 do
          for var Y := 0 to 2 do
          begin
            var Offset := TVector2f.Create((0.25 + 0.5 * X) * w, 0.5 * Y * h);
            Context.translate(Offset.X, Offset.Y);
            FDrawerColor.Draw(Context, Small, Y = 2);
            Context.translate(-Offset.X, -Offset.Y);
          end;
        Context.translate(0.5 * w, 0.25 * h);
        FDrawerColor.Draw(Context, Small);
        Context.fill;
      end;
    cv8:
      begin
        Context.beginPath;
        for var X := 0 to 1 do
          for var Y := 0 to 2 do
          begin
            var Offset := TVector2f.Create((0.25 + 0.5 * X) * w, 0.5 * Y * h);
            Context.translate(Offset.X, Offset.Y);
            FDrawerColor.Draw(Context, Small, Y = 2);
            Context.translate(-Offset.X, -Offset.Y);
          end;
        Context.translate(0.5 * w, 0.25 * h);
        FDrawerColor.Draw(Context, Small);
        Context.translate(0, 0.5 * h);
        FDrawerColor.Draw(Context, Small, True);
        Context.fill;
      end;
    cv9:
      begin
        Context.beginPath;
        for var X := 0 to 1 do
          for var Y := 0 to 3 do
          begin
            var Offset := TVector2f.Create((0.25 + 0.5 * X) * w, Y / 3 * h);
            Context.translate(Offset.X, Offset.Y);
            FDrawerColor.Draw(Context, Small, Y >= 2);
            Context.translate(-Offset.X, -Offset.Y);
          end;
        Context.translate(0.5 * w, h / 6);
        FDrawerColor.Draw(Context, Small);
        Context.fill;
      end;
    cv10:
      begin
        Context.beginPath;
        for var X := 0 to 1 do
          for var Y := 0 to 3 do
          begin
            var Offset := TVector2f.Create((0.25 + 0.5 * X) * w, Y / 3 * h);
            Context.translate(Offset.X, Offset.Y);
            FDrawerColor.Draw(Context, Small, Y >= 2);
            Context.translate(-Offset.X, -Offset.Y);
          end;
        Context.translate(0.5 * w, h / 6);
        FDrawerColor.Draw(Context, Small);
        Context.translate(0, 2 / 3 * h);
        FDrawerColor.Draw(Context, Small, True);
        Context.fill;
      end;
    cvJ:
      begin
        Context.beginPath;
        Context.Rect(0, 0, w, h);
        Context.Stroke;

        Context.beginPath;
        var Offset := TVector2f.Create(0.25 * w, 0);
        Context.translate(Offset.X, Offset.Y);
        FDrawerColor.Draw(Context, Small);
        Context.translate(-Offset.X, -Offset.Y);
        Context.fill;

        Context.translate(0.5 * w, 0.5 * h);
        FDrawerValue.Draw(Context, LargeFont, True);
      end;
    cvQ:
      begin
        Context.beginPath;
        Context.Rect(0, 0, w, h);
        Context.Stroke;

        Context.beginPath;
        var Offset := TVector2f.Create(0.25 * w, 0);
        Context.translate(Offset.X, Offset.Y);
        FDrawerColor.Draw(Context, Small);
        Context.translate(-Offset.X, -Offset.Y);
        Context.fill;

        Context.translate(0.5 * w, 0.5 * h);
        FDrawerValue.Draw(Context, LargeFont, True);
      end;
    cvK:
      begin
        Context.beginPath;
        Context.Rect(0, 0, w, h);
        Context.StrokeStyle := #888;
        Context.Stroke;

        Context.beginPath;
        var Offset := TVector2f.Create(0.25 * w, 0);
        Context.translate(Offset.X, Offset.Y);
        FDrawerColor.Draw(Context, Small);
        Context.translate(-Offset.X, -Offset.Y);
        Context.fill;

        Context.translate(0.5 * w, 0.5 * h);
        FDrawerValue.Draw(Context, LargeFont, True);
      end;
  end;
end;

procedure TCard.SetIsConcealed(Value: Boolean);
begin
  if FIsConcealed <> Value then
  begin
    FIsConcealed := Value;
    Paint;
  end;
end;

procedure TCard.SetIsHighlighted(Value: Boolean);
begin
  if FIsHighlighted <> Value then
  begin
    FIsHighlighted := Value;
    Paint;
  end;
end;

procedure TCard.SetTransitionTime(Value: Float);
begin
  if FTransitionTime <> Value then
  begin
    FTransitionTime := Value;

    if FTransitionTime = 0 then
    begin
      Style.removeProperty('-webkit-transition');
      Style.removeProperty('transition');
    end
    else
    begin
      var s := FloatToStr(Value);
      s := 'left ' + s + 's, top ' + s + 's';
      Style.setProperty('-webkit-transition', s);
      Style.setProperty('transition', s);
    end;
  end;
end;

end.