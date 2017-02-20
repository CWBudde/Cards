unit Card.Drawer;

interface

uses
  W3C.Canvas2DContext;

type
  TCustomCardColorDrawer = class abstract
  protected
    class function GetWidth: Float; virtual; abstract;
    class function GetHeight: Float; virtual; abstract;
    class function GetColor: String; virtual; abstract;
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); virtual; abstract;
  public
    class procedure Draw(Context: JCanvasRenderingContext2D; ScaleFactor: Float = 1; Flip: Boolean = False);

    property Color: String read GetColor;
    property Width: Float read GetWidth;
    property Height: Float read GetHeight;
  end;
  TCustomCardColorDrawerClass = class of TCustomCardColorDrawer;

  TCardColorDrawerRed = class(TCustomCardColorDrawer)
  protected
    class function GetColor: String; override;
  end;

  TCardColorDrawerBlack = class(TCustomCardColorDrawer)
  protected
    class function GetColor: String; override;
  end;

  TCardColorDrawerSpade = class(TCardColorDrawerBlack)
  protected
    class function GetWidth: Float; override;
    class function GetHeight: Float; override;
  public
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardColorDrawerHeart = class(TCardColorDrawerRed)
  protected
    class function GetWidth: Float; override;
    class function GetHeight: Float; override;
  public
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardColorDrawerClub = class(TCardColorDrawerBlack)
  protected
    class function GetWidth: Float; override;
    class function GetHeight: Float; override;
  public
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardColorDrawerDiamond = class(TCardColorDrawerRed)
  protected
    class function GetWidth: Float; override;
    class function GetHeight: Float; override;
  public
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCustomCardValueDrawer = class
  protected
    class function GetWidth: Float; virtual;
    class function GetHeight: Float; virtual;
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); virtual; abstract;
  public
    class procedure Draw(Context: JCanvasRenderingContext2D;
      ScaleFactor: Float = 1; Center: Boolean = False);
    property Width: Float read GetWidth;
    property Height: Float read GetHeight;
  end;
  TCustomCardValueDrawerClass = class of TCustomCardValueDrawer;

  TCardValueDrawerA = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawer2 = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawer3 = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawer4 = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawer5 = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawer6 = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawer7 = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawer8 = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawer9 = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawer10 = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawerJ = class(TCustomCardValueDrawer)
  protected
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawerQ = class(TCustomCardValueDrawer)
  protected
    class function GetWidth: Float; override;
    class function GetHeight: Float; override;
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardValueDrawerK = class(TCustomCardValueDrawer)
  protected
    class function GetWidth: Float; override;
    class function GetHeight: Float; override;
    class procedure DrawRaw(Context: JCanvasRenderingContext2D); override;
  end;

  TCardDrawerOrnament = class
  protected
    class function GetWidth: Float;
    class function GetHeight: Float;
    class procedure DrawRaw(Context: JCanvasRenderingContext2D);
  public
    class procedure Draw(Context: JCanvasRenderingContext2D; ScaleFactor: Float = 1; Flip: Boolean = False);

    property Width: Float read GetWidth;
    property Height: Float read GetHeight;
  end;

implementation

uses
  ECMA.Console;

procedure BezierCurveToContext(Context: JCanvasRenderingContext2D; Points: array of Float);
begin
{$IFDEF DEBUG}
  Assert((Length(Points) - 2) mod 6 = 0);
{$ENDIF}

  Context.MoveTo(Points[0], Points[1]);
  for var Index := 0 to (Length(Points) - 2) div 6 - 1 do
    Context.bezierCurveTo(Points[6 * Index + 2], Points[6 * Index + 3],
      Points[6 * Index + 4], Points[6 * Index + 5],
      Points[6 * Index + 6], Points[6 * Index + 7]);
end;

procedure PolygonToContext(Context: JCanvasRenderingContext2D; Points: array of Float);
begin
{$IFDEF DEBUG}
  Assert(Length(Points) mod 2 = 0);
{$ENDIF}

  Context.MoveTo(Points[0], Points[1]);
  for var Index := 1 to (Length(Points) div 2) - 1 do
    Context.LineTo(Points[2 * Index], Points[2 * Index + 1]);
end;

{ TCustomCardColorDrawer }

class procedure TCustomCardColorDrawer.Draw(Context: JCanvasRenderingContext2D;
  ScaleFactor: Float = 1; Flip: Boolean = False);
begin
  Context.Scale(ScaleFactor, ScaleFactor);
  if Flip then Context.rotate(Pi);
  Context.Translate(-0.5 * GetWidth, -0.5 * GetHeight);
  DrawRaw(Context);
  Context.closePath;
  Context.Translate(0.5 * GetWidth, 0.5 * GetHeight);
  if Flip then Context.rotate(Pi);
  Context.Scale(1 / ScaleFactor, 1 / ScaleFactor);
end;


{ TCardColorDrawerRed }

class function TCardColorDrawerRed.GetColor: String;
begin
  Result := '#C00';
end;


{ TCardColorDrawerBlack }

class function TCardColorDrawerBlack.GetColor: String;
begin
  Result := '#000';
end;


{ TCardColorDrawerSpade }

class procedure TCardColorDrawerSpade.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [5.28, 0, 2.75, 3.61, 0, 5.9, 0, 8.5, 0, 11.1,
    3.73, 11.92, 4.64, 9.5, 4.71, 9.32, 4.31, 11.94, 3.62, 13.17]);
  Context.lineTo(6.93, 13.17);
  Context.bezierCurveTo(6.24, 11.94, 5.85, 9.32, 5.92, 9.5);
  Context.bezierCurveTo(6.81, 11.91, 10.55, 11.46, 10.55, 8.5);
  Context.bezierCurveTo(10.55, 5.55, 7.8, 3.61, 5.28, 0);
end;

class function TCardColorDrawerSpade.GetWidth: Float;
begin
  Result := 10.55;
end;

class function TCardColorDrawerSpade.GetHeight: Float;
begin
  Result := 13.17;
end;


{ TCardColorDrawerHeart }

class procedure TCardColorDrawerHeart.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [6.2, 12.64, 4.09, 9.31, 0, 5.76, 0, 3.61, 0,
    1.47, 1.35, 0, 3.03, 0, 4.72, 0, 5.92, 1.88, 6.2, 3.07, 6.48, 1.88, 7.68,
    0, 9.36, 0, 11.05, 0, 12.43, 1.45, 12.4, 3.61, 12.36, 5.78, 8.39, 9.22,
    6.2, 12.64]);
end;

class function TCardColorDrawerHeart.GetWidth: Float;
begin
  Result := 12.36;
end;

class function TCardColorDrawerHeart.GetHeight: Float;
begin
  Result := 12.64;
end;


{ TCardColorDrawerClub }

class procedure TCardColorDrawerClub.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [6.1, 0, 9.07, 0, 10.02, 2.84, 7.49, 5.67,
    10.86, 4.15, 12.85, 6.42, 12.03, 9.02, 11.21, 11.63, 7.53, 11, 6.63,
    9.1, 6.3, 10.45, 7.18, 12.04, 7.7, 13.16]);
  Context.lineTo(4.51, 13.16);
  Context.bezierCurveTo(5.03, 12.04, 5.92, 10.45, 5.58, 9.1);
  Context.bezierCurveTo(4.69, 11, 1, 11.63, 0.18, 9.02);
  Context.bezierCurveTo(-0.64, 6.42, 1.35, 4.15, 4.72, 5.67);
  Context.bezierCurveTo(2.19, 2.84, 3.14, 0.01, 6.11, 0);
end;

class function TCardColorDrawerClub.GetWidth: Float;
begin
  Result := 12.85;
end;

class function TCardColorDrawerClub.GetHeight: Float;
begin
  Result := 13.16;
end;


{ TCardColorDrawerDiamond }

class procedure TCardColorDrawerDiamond.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [5.3, 13.17, 3.88, 10.82, 1.87, 8.53, 0, 6.58,
    1.87, 4.63, 3.88, 2.35, 5.3, 0, 6.72, 2.35, 8.73, 4.63, 10.6, 6.58, 8.73,
    8.53, 6.72, 10.82, 5.3, 13.17]);
end;

class function TCardColorDrawerDiamond.GetWidth: Float;
begin
  Result := 10.6;
end;

class function TCardColorDrawerDiamond.GetHeight: Float;
begin
  Result := 13.17;
end;


{ TCustomCardValueDrawer }

class procedure TCustomCardValueDrawer.Draw(Context: JCanvasRenderingContext2D;
  ScaleFactor: Float = 1; Center: Boolean = False);
begin
  Context.Scale(ScaleFactor, ScaleFactor);
  if Center then Context.translate(-0.5 * Width, -0.5 * Height);
  Context.BeginPath;
  DrawRaw(Context);
  Context.ClosePath;
  Context.Fill;
  if Center then Context.translate(0.5 * Width, 0.5 * Height);
  Context.Scale(1 / ScaleFactor, 1 / ScaleFactor);
end;

class function TCustomCardValueDrawer.GetWidth: Float;
begin
  Result := 4;
end;

class function TCustomCardValueDrawer.GetHeight: Float;
begin
  Result := 6;
end;


{ TCardValueDrawerA }

class procedure TCardValueDrawerA.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  PolygonToContext(Context, [3.87, 6.03, 2.29, 6.03, 2.29, 5.32, 2.63, 5.32,
    2.52, 4.7, 1.35, 4.7, 1.23, 5.32, 1.57, 5.32, 1.57, 6.03, 0, 6.03, 0, 5.32,
    0.51, 5.32, 1.49, 0.12, 2.37, 0.12, 3.35, 5.32, 3.87, 5.32]);
  Context.moveTo(2.38, 4);
  Context.lineTo(1.93, 1.58);
  Context.lineTo(1.48, 4);
end;

{ TCardValueDrawer2 }

class procedure TCardValueDrawer2.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [0.01, 6, 0, 5.58, 0.02, 5.13, 0.09, 4.77, 0.15,
    4.5, 0.22, 4.27, 0.3, 4.08, 0.42, 3.73, 0.63, 3.43, 0.83, 3.13, 1.06, 2.81,
    1.25, 2.51, 1.45, 2.17, 1.56, 1.95, 1.58, 1.72, 1.59, 1.49, 1.59, 1.23,
    1.54, 1.02, 1.44, 0.85, 1.34, 0.68, 1.21, 0.59, 1.05, 0.59, 0.94, 0.59,
    0.86, 0.63, 0.8, 0.7, 0.67, 0.85, 0.64, 1.04, 0.6, 1.22, 0.58, 1.41, 0.6,
    1.59, 0.62, 1.77]);
  Context.lineTo(0.04, 1.89);
  Context.bezierCurveTo(0, 1.73, 0, 1.59, 0, 1.43);
  Context.bezierCurveTo(0, 1.17, 0.03, 0.95, 0.09, 0.77);
  Context.bezierCurveTo(0.15, 0.59, 0.23, 0.44, 0.33, 0.32);
  Context.bezierCurveTo(0.54, 0.1, 0.74, 0.02, 1.05, 0.01);
  Context.bezierCurveTo(1.36, -0.01, 1.65, 0.14, 1.86, 0.42);
  Context.bezierCurveTo(2.08, 0.71, 2.16, 1.13, 2.18, 1.49);
  Context.bezierCurveTo(2.18, 1.66, 2.15, 1.82, 2.13, 1.97);
  Context.bezierCurveTo(2.02, 2.53, 1.62, 3.02, 1.32, 3.46);
  Context.bezierCurveTo(1.16, 3.69, 0.99, 3.96, 0.88, 4.19);
  Context.bezierCurveTo(0.72, 4.59, 0.63, 5.01, 0.61, 5.4);
  Context.lineTo(1.6, 5.4);
  Context.lineTo(1.6, 4.63);
  Context.lineTo(2.19, 4.63);
  Context.lineTo(2.19, 6);
end;


{ TCardValueDrawer3 }

class procedure TCardValueDrawer3.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [2.29, 3.98, 2.29, 4.31, 2.26, 4.61, 2.19, 4.88,
    2.12, 5.14, 2.03, 5.36, 1.92, 5.55, 1.71, 5.88, 1.42, 6.1, 1.1, 6.1, 0.57,
    6.09, 0.31, 5.56, 0.13, 5.14, 0.08, 4.96, 0.03, 4.79, 0, 4.61]);
  Context.lineTo(0.58, 4.5);
  Context.bezierCurveTo(0.63, 4.93, 0.84, 5.51, 1.1, 5.52);
  Context.bezierCurveTo(1.51, 5.53, 1.68, 4.52, 1.7, 3.98);
  Context.bezierCurveTo(1.71, 3.63, 1.63, 3.31, 1.53, 3);
  Context.bezierCurveTo(1.46, 2.79, 1.32, 2.63, 1.16, 2.64);
  Context.bezierCurveTo(1.01, 2.65, 1.01, 2.72, 0.94, 2.84);
  Context.lineTo(0.41, 2.58);
  Context.lineTo(1.32, 0.69);
  Context.lineTo(0.63, 0.69);
  Context.lineTo(0.63, 1.47);
  Context.lineTo(0.03, 1.47);
  Context.lineTo(0.03, 0.11);
  Context.lineTo(2.26, 0.11);
  Context.lineTo(1.32, 2.06);
  Context.bezierCurveTo(1.46, 2.09, 1.6, 2.15, 1.71, 2.26);
  Context.bezierCurveTo(1.84, 2.36, 1.94, 2.5, 2.02, 2.66);
  Context.bezierCurveTo(2.11, 2.82, 2.18, 3.02, 2.22, 3.25);
  Context.bezierCurveTo(2.27, 3.47, 2.29, 3.71, 2.29, 3.98);
end;


{ TCardValueDrawer4 }

class procedure TCardValueDrawer4.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  PolygonToContext(Context, [2.25, 6.02, 0.98, 6.02, 0.98, 5.43, 1.38, 5.43,
    1.38, 4.56, 0, 4.56, 1.42, 0.1, 1.97, 0.1, 1.97, 3.97, 2.24, 3.97,
    2.24, 4.56, 1.97, 4.56, 1.97, 5.43, 2.25, 5.43]);
  Context.moveTo(1.38, 3.97);
  Context.lineTo(1.38, 2.18);
  Context.lineTo(0.8, 3.97);
end;


{ TCardValueDrawer5 }

class procedure TCardValueDrawer5.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [2.25, 3.8, 2.25, 4.09, 2.22, 4.37, 2.17, 4.64,
    2.12, 4.92, 2.05, 5.17, 1.95, 5.39, 1.85, 5.61, 1.73, 5.79, 1.58, 5.93,
    1.43, 6.06, 1.27, 6.13, 1.08, 6.13, 0.83, 6.13, 0.61, 6.01, 0.42, 5.76,
    0.23, 5.51, 0.09, 5.16, 0, 4.71]);
  Context.lineTo(0.58, 4.59);
  Context.bezierCurveTo(0.61, 4.76, 0.65, 4.91, 0.7, 5.03);
  Context.bezierCurveTo(0.78, 5.28, 0.92, 5.55, 1.08, 5.55);
  Context.bezierCurveTo(1.24, 5.54, 1.36, 5.24, 1.45, 5.07);
  Context.bezierCurveTo(1.51, 4.92, 1.56, 4.74, 1.6, 4.53);
  Context.bezierCurveTo(1.64, 4.31, 1.66, 4.07, 1.66, 3.8);
  Context.bezierCurveTo(1.66, 3.54, 1.64, 3.3, 1.6, 3.09);
  Context.bezierCurveTo(1.56, 2.88, 1.51, 2.7, 1.45, 2.55);
  Context.bezierCurveTo(1.39, 2.4, 1.33, 2.29, 1.26, 2.22);
  Context.bezierCurveTo(1.19, 2.14, 1.13, 2.1, 1.08, 2.1);
  Context.bezierCurveTo(1.04, 2.1, 0.99, 2.13, 0.93, 2.19);
  Context.bezierCurveTo(0.87, 2.25, 0.81, 2.34, 0.75, 2.48);
  Context.lineTo(0.18, 2.36);
  Context.lineTo(0.18, 0.11);
  Context.lineTo(2.09, 0.11);
  Context.lineTo(2.09, 0.69);
  Context.lineTo(0.78, 0.69);
  Context.lineTo(0.78, 1.58);
  Context.bezierCurveTo(0.87, 1.53, 0.97, 1.51, 1.08, 1.51);
  Context.bezierCurveTo(1.23, 1.51, 1.37, 1.56, 1.51, 1.66);
  Context.bezierCurveTo(1.65, 1.76, 1.78, 1.9, 1.88, 2.1);
  Context.bezierCurveTo(1.99, 2.29, 2.08, 2.53, 2.14, 2.82);
  Context.bezierCurveTo(2.21, 3.1, 2.25, 3.43, 2.25, 3.8);
end;


{ TCardValueDrawer6 }

class procedure TCardValueDrawer6.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [2.14, 4.76, 2.09, 5.02, 2.02, 5.24, 1.93,
    5.45, 1.83, 5.65, 1.71, 5.81, 1.57, 5.94, 1.44, 6.07, 1.28, 6.13, 1.1,
    6.13, 0.61, 6.12, 0.35, 5.57, 0.23, 5.18, 0.17, 4.93, 0.12, 4.67, 0.08,
    4.41, 0.04, 4.14, 0.02, 3.89, 0.01, 3.64, 0, 3.4, 0, 3.2, 0, 3.04, 0,
    1.63, 0.16, 0.73, 0.47, 0.35, 0.67, 0.12, 0.88, 0, 1.11, 0, 1.32, 0,
    1.52, 0.09, 1.69, 0.27, 1.86, 0.45, 1.99, 0.7, 2.09, 1.02]);
  Context.lineTo(1.52, 1.18);
  Context.bezierCurveTo(1.47, 0.87, 1.28, 0.6, 1.11, 0.59);
  Context.bezierCurveTo(0.89, 0.59, 0.83, 0.93, 0.76, 1.11);
  Context.bezierCurveTo(0.71, 1.31, 0.67, 1.57, 0.64, 1.91);
  Context.bezierCurveTo(0.78, 1.78, 0.93, 1.71, 1.1, 1.71);
  Context.bezierCurveTo(1.26, 1.71, 1.41, 1.77, 1.55, 1.88);
  Context.bezierCurveTo(1.68, 1.99, 1.8, 2.15, 1.9, 2.35);
  Context.bezierCurveTo(2, 2.55, 2.07, 2.78, 2.12, 3.06);
  Context.bezierCurveTo(2.18, 3.34, 2.21, 3.65, 2.21, 3.94);
  Context.bezierCurveTo(2.21, 4.24, 2.19, 4.5, 2.14, 4.76);
  Context.moveTo(1.1, 2.3);
  Context.bezierCurveTo(0.61, 2.28, 0.62, 3.16, 0.65, 4.08);
  Context.bezierCurveTo(0.67, 5, 0.86, 5.54, 1.12, 5.55);
  Context.bezierCurveTo(1.37, 5.55, 1.65, 4.88, 1.66, 4.07);
  Context.bezierCurveTo(1.67, 3.27, 1.59, 2.32, 1.1, 2.3);
end;


{ TCardValueDrawer7 }

class procedure TCardValueDrawer7.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [2.41, 0.11, 2.14, 0.73, 1.94, 1.45, 1.8, 2, 1.68,
    2.47, 1.56, 3.06, 1.44, 3.75, 1.32, 4.44, 1.22, 5.22, 1.14, 6.1]);
  Context.lineTo(0.56, 6.04);
  Context.bezierCurveTo(0.61, 5.36, 0.69, 4.73, 0.78, 4.16);
  Context.bezierCurveTo(0.86, 3.59, 0.96, 3.08, 1.05, 2.63);
  Context.bezierCurveTo(1.15, 2.18, 1.24, 1.79, 1.33, 1.47);
  Context.bezierCurveTo(1.42, 1.14, 1.49, 0.88, 1.56, 0.69);
  Context.lineTo(0.59, 0.69);
  Context.lineTo(0.59, 1.47);
  Context.lineTo(0, 1.47);
  Context.lineTo(0, 0.11);
end;


{ TCardValueDrawer8 }

class procedure TCardValueDrawer8.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [2.25, 4.36, 2.25, 4.6, 2.22, 4.84, 2.16, 5.05,
    2.06, 5.45, 1.84, 5.73, 1.57, 5.98, 1.43, 6.07, 1.28, 6.12, 1.12, 6.12,
    0.97, 6.12, 0.82, 6.07, 0.68, 5.98, 0.35, 5.75, 0.2, 5.39, 0.08, 5.05,
    0.03, 4.84, 0, 4.6, 0, 4.36, 0, 4.04, 0.05, 3.74, 0.14, 3.49, 0.24,
    3.23, 0.37, 3.02, 0.52, 2.86, 0.4, 2.73, 0.3, 2.55, 0.23, 2.34, 0.16,
    2.11, 0.12, 1.87, 0.12, 1.6, 0.12, 1.38, 0.15, 1.18, 0.2, 0.99,
    0.28, 0.64, 0.48, 0.39, 0.73, 0.18, 0.85, 0.1, 0.98, 0.06, 1.12, 0.06,
    1.27, 0.06, 1.4, 0.1, 1.52, 0.18, 1.82, 0.38, 1.94, 0.69, 2.05, 0.99,
    2.11, 1.18, 2.13, 1.38, 2.13, 1.6, 2.13, 1.87, 2.09, 2.11, 2.02, 2.34,
    1.95, 2.55, 1.85, 2.73, 1.73, 2.86, 1.88, 3.02, 2.01, 3.23, 2.1, 3.49,
    2.2, 3.74, 2.25, 4.04, 2.25, 4.36]);
  BezierCurveToContext(Context, [1.55, 1.6, 1.54, 1.29, 1.39, 0.64, 1.12, 0.64,
    0.85, 0.65, 0.71, 1.25, 0.71, 1.6, 0.71, 1.96, 0.75, 2.56, 1.12, 2.56, 1.5,
    2.56, 1.56, 1.91, 1.55, 1.6]);
  BezierCurveToContext(Context, [1.66, 4.36, 1.67, 3.9, 1.59, 3.19, 1.12, 3.19,
    0.66, 3.19, 0.61, 3.9, 0.59, 4.36, 0.58, 4.82, 0.66, 5.51, 1.12, 5.52,
    1.59, 5.54, 1.65, 4.82, 1.66, 4.36]);
end;


{ TCardValueDrawer9 }

class procedure TCardValueDrawer9.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  BezierCurveToContext(Context, [2.05, 4.97, 2.01, 5.13, 1.97, 5.28, 1.91, 5.43,
    1.85, 5.57, 1.79, 5.68, 1.71, 5.78, 1.52, 6.01, 1.31, 6.12, 1.08, 6.12,
    0.87, 6.12, 0.68, 6.03, 0.51, 5.86, 0.34, 5.67, 0.21, 5.41, 0.12, 5.08]);
  Context.lineTo(0.68, 4.92);
  Context.bezierCurveTo(0.75, 5.2, 0.91, 5.54, 1.08, 5.54);
  Context.bezierCurveTo(1.32, 5.53, 1.38, 5.15, 1.45, 4.93);
  Context.bezierCurveTo(1.51, 4.7, 1.56, 4.4, 1.59, 4.03);
  Context.bezierCurveTo(1.44, 4.16, 1.28, 4.22, 1.1, 4.22);
  Context.bezierCurveTo(0.97, 4.22, 0.83, 4.17, 0.7, 4.09);
  Context.bezierCurveTo(0.57, 4, 0.45, 3.86, 0.35, 3.69);
  Context.bezierCurveTo(0.24, 3.51, 0.16, 3.29, 0.09, 3.03);
  Context.bezierCurveTo(0.03, 2.77, 0, 2.46, 0, 2.12);
  Context.bezierCurveTo(0, 1.77, 0.03, 1.47, 0.09, 1.21);
  Context.bezierCurveTo(0.16, 0.94, 0.24, 0.72, 0.35, 0.55);
  Context.bezierCurveTo(0.63, 0.11, 0.89, 0.02, 1.11, 0.01);
  Context.bezierCurveTo(1.56, 0, 1.86, 0.5, 1.98, 0.96);
  Context.bezierCurveTo(2.12, 1.49, 2.19, 2.01, 2.21, 2.53);
  Context.bezierCurveTo(2.24, 3.38, 2.2, 4.17, 2.05, 4.97);
  BezierCurveToContext(Context, [1.11, 0.6, 0.71, 0.59, 0.54, 1.6, 0.54, 2.12,
    0.54, 2.63, 0.73, 3.63, 1.11, 3.63, 1.49, 3.64, 1.64, 2.82, 1.64, 2.16,
    1.64, 1.5, 1.5, 0.61, 1.11, 0.6]);
end;


{ TCardValueDrawer10 }

class procedure TCardValueDrawer10.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  Context.moveTo(3.68, 4.86);
  Context.bezierCurveTo(3.68, 5.63, 3.22, 6.13, 2.43, 6.13);
  Context.bezierCurveTo(1.65, 6.13, 1.19, 5.59, 1.19, 4.86);
  Context.lineTo(1.19, 1.28);
  Context.bezierCurveTo(1.18, 0.53, 1.64, 0.01, 2.43, 0.01);
  Context.bezierCurveTo(3.23, 0, 3.68, 0.62, 3.68, 1.28);
  Context.moveTo(0.76, 6);
  Context.lineTo(0, 6);
  Context.lineTo(0, 0.11);
  Context.lineTo(0.76, 0.11);
  Context.moveTo(2.92, 4.86);
  Context.lineTo(2.92, 1.28);
  Context.bezierCurveTo(2.92, 0.96, 2.75, 0.78, 2.43, 0.78);
  Context.bezierCurveTo(2.11, 0.78, 1.95, 0.96, 1.95, 1.28);
  Context.lineTo(1.95, 4.86);
  Context.bezierCurveTo(1.94, 5.16, 2.12, 5.36, 2.43, 5.36);
  Context.bezierCurveTo(2.75, 5.36, 2.92, 5.17, 2.92, 4.86);
end;


{ TCardValueDrawerJ }

class procedure TCardValueDrawerJ.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  PolygonToContext(Context, [2.39, 0.95, 1.75, 0.95, 1.75, 0.11, 3.81, 0.11,
    3.81, 0.95, 3.2, 0.95, 3.2, 4.44]);
  Context.bezierCurveTo(3.19, 5.34, 2.76, 6.12, 1.61, 6.13);
  Context.bezierCurveTo(0.31, 6.15, 0, 5.14, 0, 3.96);
  Context.lineTo(0.81, 3.96);
  Context.bezierCurveTo(0.8, 4.75, 0.93, 5.29, 1.61, 5.3);
  Context.bezierCurveTo(2.23, 5.31, 2.4, 4.95, 2.39, 4.44);
end;


{ TCardValueDrawerQ }

class procedure TCardValueDrawerQ.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  Context.moveTo(3.87, 6.02);
  Context.bezierCurveTo(3.28, 6.02, 3.09, 5.97, 2.86, 5.79);
  Context.bezierCurveTo(2.56, 6.03, 2.23, 6.14, 1.88, 6.15);
  Context.bezierCurveTo(0.94, 6.15, 0.39, 5.35, 0.39, 4.75);
  Context.lineTo(0.39, 4.23);
  Context.lineTo(0, 4.23);
  Context.lineTo(0, 3.52);
  Context.lineTo(0.39, 3.52);
  Context.lineTo(0.39, 1.43);
  Context.bezierCurveTo(0.4, 0.56, 1.01, 0.02, 1.88, 0.02);
  Context.bezierCurveTo(2.76, 0.02, 3.37, 0.58, 3.38, 1.43);
  Context.lineTo(3.38, 4.75);
  Context.bezierCurveTo(3.38, 4.91, 3.35, 5.07, 3.28, 5.22);
  Context.bezierCurveTo(3.56, 5.32, 3.65, 5.31, 3.87, 5.31);
  Context.moveTo(2.65, 1.43);
  Context.bezierCurveTo(2.65, 1.03, 2.3, 0.77, 1.88, 0.76);
  Context.bezierCurveTo(1.47, 0.76, 1.11, 1.02, 1.11, 1.43);
  Context.lineTo(1.11, 3.52);
  Context.bezierCurveTo(1.25, 3.53, 1.38, 3.57, 1.5, 3.63);
  Context.bezierCurveTo(1.63, 3.68, 1.75, 3.75, 1.86, 3.83);
  Context.bezierCurveTo(1.97, 3.91, 2.08, 4, 2.18, 4.1);
  Context.bezierCurveTo(2.36, 4.26, 2.5, 4.42, 2.65, 4.59);
  Context.moveTo(2.31, 5.27);
  Context.bezierCurveTo(2.04, 4.91, 1.7, 4.59, 1.41, 4.38);
  Context.bezierCurveTo(1.28, 4.28, 1.22, 4.26, 1.11, 4.24);
  Context.lineTo(1.11, 4.75);
  Context.bezierCurveTo(1.12, 5.18, 1.48, 5.4, 1.88, 5.4);
  Context.bezierCurveTo(2.03, 5.41, 2.17, 5.36, 2.31, 5.27);
end;

class function TCardValueDrawerQ.GetWidth: Float;
begin
  Result := 3.56;
end;

class function TCardValueDrawerQ.GetHeight: Float;
begin
  Result := 6.02;
end;


{ TCardValueDrawerK }

class procedure TCardValueDrawerK.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  PolygonToContext(Context, [3.88, 6.03, 2.07, 6.03, 2.07, 5.38, 2.65, 5.38,
    1.75, 3.27, 1.19, 4.14, 1.19, 5.38, 1.64, 5.38, 1.64, 6.03, 0, 6.03,
    0, 5.38, 0.54, 5.38, 0.54, 0.75, 0, 0.75, 0, 0.11, 1.64, 0.11, 1.64, 0.75,
    1.19, 0.75, 1.19, 3.01, 2.63, 0.75, 2.07, 0.75, 2.07, 0.11, 3.88, 0.11,
    3.88, 0.75, 3.37, 0.75, 2.19, 2.58, 3.39, 5.38, 3.88, 5.38]);
end;

class function TCardValueDrawerK.GetWidth: Float;
begin
  Result := 3.88;
end;

class function TCardValueDrawerK.GetHeight: Float;
begin
  Result := 6.03;
end;

{ TCardDrawerOrnament }

class procedure TCardDrawerOrnament.DrawRaw(Context: JCanvasRenderingContext2D);
begin
  Context.beginPath;
  BezierCurveToContext(Context, [44.35, 14.21, 43.05, 12.76, 41.91, 10.52,
    43.14, 8.67, 44.31, 6.91, 47.6, 7.31, 47.94, 9.49, 48.25, 11.43, 45.57,
    12.45, 44.22, 11.14, 43.32, 10.27, 45.12, 9, 45.35, 9.68, 45.54,
    10.23, 45.15, 10.36, 44.55, 10.49, 45.07, 10.61, 45.95, 10.38, 45.77,
    9.61, 45.42, 8.1, 42.21, 10.11, 44.22, 11.61, 45.9, 12.87, 48.55, 11.62,
    48.39, 9.55, 48.22, 7.4, 45.56, 6.55, 43.85, 7.53, 42.02, 8.58, 41.78,
    11.05, 42.79, 12.74, 44.13, 15, 46.28, 16.6, 47.69, 18.85, 48.36,
    19.91, 48.68, 21.58, 48.91, 22.46, 48.88, 18.79, 46.36, 16.43, 44.35,
    14.21]);
  BezierCurveToContext(Context, [4.82, 14.21, 6.13, 12.76, 7.26, 10.52, 6.03,
    8.67, 4.86, 6.91, 1.58, 7.31, 1.23, 9.49, 0.92, 11.43, 3.6, 12.45, 4.95,
    11.14, 5.85, 10.27, 4.06, 9, 3.82, 9.68, 3.63, 10.23, 4.02, 10.36, 4.63,
    10.49, 4.1, 10.61, 3.22, 10.38, 3.4, 9.61, 3.76, 8.1, 6.97, 10.11, 4.95,
    11.61, 3.27, 12.87, 0.63, 11.62, 0.79, 9.55, 0.95, 7.4, 3.62, 6.55, 5.32,
    7.53, 7.15, 8.58, 7.4, 11.05, 6.39, 12.74, 5.04, 15, 2.89, 16.6, 1.48,
    18.85, 0.82, 19.91, 0.49, 21.58, 0.26, 22.46, 0.3, 18.79, 2.81, 16.43,
    4.82, 14.21]);
  BezierCurveToContext(Context, [37.65, 4.88, 39.09, 6.19, 41.33, 7.32, 43.18,
    6.09, 44.94, 4.92, 44.54, 1.64, 42.36, 1.29, 40.42, 0.98, 39.41, 3.66,
    40.72, 5.01, 41.59, 5.91, 42.86, 4.12, 42.17, 3.88, 41.62, 3.69, 41.5,
    4.08, 41.37, 4.69, 41.24, 4.16, 41.48, 3.28, 42.25, 3.46, 43.76, 3.82,
    41.74, 7.03, 40.24, 5.01, 38.98, 3.33, 40.23, 0.68, 42.31, 0.84, 44.45,
    1.01, 45.31, 3.68, 44.32, 5.38, 43.27, 7.21, 40.81, 7.46, 39.11, 6.45,
    36.85, 5.1, 35.25, 2.95, 33, 1.54, 31.94, 0.88, 30.27, 0.55, 29.4,
    0.32, 33.22, 0.37, 35.42, 2.87, 37.65, 4.88]);
  BezierCurveToContext(Context, [20.35, 1.02, 19.13, 1.13, 17.21, 1.59, 15.72,
    2.57, 13.74, 3.87, 13.34, 5.55, 13.79, 7.24, 13.99, 8.01, 14.93, 9.42,
    16.44, 9.43, 18.04, 9.45, 18.72, 8.24, 18.68, 7.39, 18.64, 6.57, 18.21,
    5.66, 17.22, 5.29, 16.23, 4.93, 15.27, 5.53, 15.32, 6.44, 15.36, 7.04,
    15.84, 7.37, 16.36, 7.33, 16.83, 7.3, 17.08, 6.98, 17, 6.54, 16.89, 5.96,
    16.26, 5.88, 15.99, 6.21, 15.88, 6.35, 16.63, 6.43, 16.41, 6.74, 16.2,
    7.04, 15.73, 6.69, 15.7, 6.45, 15.59, 5.67, 16.54, 5.38, 17.16, 5.61, 18.2,
    6.13, 18.49, 7.13, 18.22, 7.9, 18.04, 8.44, 17.51, 8.97, 16.86, 8.97, 14.79,
    8.96, 13.95, 7.52, 14.17, 5.5, 14.3, 4.4, 15.48, 3.27, 16.42, 2.73, 17.36,
    2.2, 18.39, 1.88, 19.43, 1.63, 21.22, 1.26, 22.86, 1.13, 24.58, 1.13, 26.3,
    1.13, 27.95, 1.26, 29.73, 1.63, 30.77, 1.88, 31.8, 2.2, 32.74, 2.73, 33.68,
    3.27, 34.86, 4.4, 35, 5.5, 35.21, 7.52, 34.37, 8.96, 32.31, 8.97, 31.65,
    8.97, 31.12, 8.44, 30.94, 7.9, 30.67, 7.13, 30.96, 6.13, 32, 5.61, 32.62,
    5.38, 33.57, 5.67, 33.46, 6.45, 33.43, 6.69, 32.96, 7.04, 32.75, 6.74,
    32.53, 6.43, 33.28, 6.35, 33.17, 6.21, 32.9, 5.88, 32.27, 5.96, 32.16,
    6.54, 32.08, 6.98, 32.33, 7.3, 32.8, 7.33, 33.32, 7.37, 33.8, 7.04, 33.84,
    6.44, 33.89, 5.53, 32.93, 4.93, 31.94, 5.29, 30.95, 5.66, 30.52, 6.57,
    30.48, 7.39, 30.45, 8.24, 31.12, 9.45, 32.73, 9.43, 34.23, 9.42, 35.17,
    8.01, 35.37, 7.24, 35.82, 5.55, 35.42, 3.87, 33.44, 2.57, 31.95, 1.59,
    30.03, 1.13, 28.81, 1.02, 27.25, 0.91, 26.92, 0.75, 24.58, 0.75, 22.24,
    0.75, 21.62, 0.9, 20.35, 1.02]);
  BezierCurveToContext(Context, [25.37, 1.82, 25.9, 2.01, 26.72, 2.36, 27.2,
    2.94, 27.65, 3.48, 27.75, 4.08, 27.97, 4.49, 28.21, 4.93, 28.55, 5.15,
    28.6, 4.77, 28.79, 5.25, 29.96, 6.24, 29.72, 5.02, 30.52, 5.89, 30.95,
    5.68, 30.74, 4.93, 30.11, 2.73, 27.37, 1.95, 25.37, 1.82]);
  BezierCurveToContext(Context, [37.59, 9.84, 37.72, 9.6, 37.86, 9.31, 37.62,
    9.04, 37.43, 8.82, 37.1, 8.92, 36.85, 9.11, 35.61, 10.59, 38.46, 11.94,
    39.08, 9.58, 39.53, 8.26, 37.4, 6.35, 37.17, 6.21, 42.45, 9.24, 38.33,
    13.02, 36.45, 11.03, 36.18, 10.75, 35.92, 10.3, 35.98, 9.8, 36.05, 9.2,
    36.51, 8.6, 37.27, 8.64, 37.99, 8.71, 38.21, 9.48, 37.58, 9.84]);
  BezierCurveToContext(Context, [32.84, 0, 33.14, 0.04, 34.83, 0.23, 36.02,
    0.06, 37.91, -0.2, 39.02, 0.48, 36.77, 1.05, 37.52, 1.14, 38.25, 1.28,
    38.27, 1.62, 38.3, 2.2, 37.58, 2.36, 37.58, 2.36, 38.98, 3.06, 37.89, 5.3,
    36.77, 3.21, 36.12, 1.99, 33.91, 0.39, 32.84, 0]);
  BezierCurveToContext(Context, [11.5, 4.88, 10.06, 6.19, 7.82, 7.32, 5.97,
    6.09, 4.21, 4.92, 4.61, 1.64, 6.79, 1.29, 8.72, 0.98, 9.74, 3.66, 8.43,
    5.01, 7.56, 5.91, 6.29, 4.12, 6.97, 3.88, 7.53, 3.69, 7.65, 4.08, 7.78,
    4.69, 7.91, 4.16, 7.67, 3.28, 6.9, 3.46, 5.39, 3.82, 7.41, 7.03, 8.91,
    5.01, 10.17, 3.33, 8.92, 0.68, 6.84, 0.84, 4.7, 1.01, 3.84, 3.68, 4.82,
    5.38, 5.88, 7.21, 8.34, 7.46, 10.04, 6.45, 12.3, 5.1, 13.9, 2.95, 16.15,
    1.54, 17.21, 0.88, 18.88, 0.55, 19.75, 0.32, 16.08, 0.36, 13.73, 2.87,
    11.5, 4.88]);
  BezierCurveToContext(Context, [48.68, 27.64, 48.5, 27.11, 48.14, 26.29,
    47.56, 25.81, 47.03, 25.36, 46.42, 25.26, 46.01, 25.04, 45.57, 24.8,
    45.35, 24.46, 45.73, 24.41, 45.26, 24.21, 44.26, 23.05, 45.48, 23.29,
    44.61, 22.49, 44.82, 22.06, 45.57, 22.27, 47.77, 22.9, 48.55, 25.64,
    48.68, 27.64]);
  BezierCurveToContext(Context, [40.13, 14.36, 40.37, 14.23, 40.66, 14.09,
    40.94, 14.33, 41.15, 14.52, 41.05, 14.85, 40.87, 15.1, 39.39, 16.34,
    38.04, 13.49, 40.39, 12.87, 41.72, 12.41, 43.62, 14.54, 43.77, 14.78,
    40.73, 9.5, 36.95, 13.62, 38.94, 15.5, 39.23, 15.77, 39.68, 16.03, 40.17,
    15.97, 40.77, 15.9, 41.38, 15.44, 41.34, 14.67, 41.26, 13.96, 40.49, 13.73,
    40.13, 14.36]);
  BezierCurveToContext(Context, [49.05, 19.11, 49.01, 18.81, 48.82, 17.12,
    48.99, 15.93, 49.25, 14.04, 48.57, 12.93, 48, 15.18, 47.91, 14.43, 47.76,
    13.7, 47.42, 13.68, 46.84, 13.65, 46.69, 14.37, 46.69, 14.37, 45.99, 12.97,
    43.74, 14.06, 45.84, 15.18, 47.06, 15.83, 48.66, 18.04, 49.05, 19.11]);
  BezierCurveToContext(Context, [42.58, 21.93, 41.92, 21.94, 41.27, 21.62,
    40.85, 20.79, 40.1, 19.31, 41.27, 17.61, 42.75, 17.2, 48.63, 15.58, 49.5,
    26.14, 49.04, 30.22, 49.09, 27.76, 49.03, 25.21, 48.42, 22.74, 48.17, 21.7,
    47.86, 20.67, 47.31, 19.71, 46.77, 18.76, 45.63, 17.55, 44.49, 17.42, 43.54,
    17.3, 42.39, 17.47, 41.86, 17.96, 40.25, 19.46, 40.91, 21.21, 42.04, 21.63,
    42.75, 21.9, 43.68, 21.69, 44.31, 20.77, 44.35, 20.69, 44.4, 20.61, 44.44,
    20.52, 44.63, 20.03, 44.58, 19.36, 44.19, 19.08, 43.86, 18.86, 43.34, 18.82,
    43.12, 19.21, 42.9, 19.7, 43.57, 19.77, 43.78, 19.31, 43.89, 19.46, 43.95,
    19.86, 43.77, 20.09, 43.62, 20.27, 43.28, 20.39, 42.96, 20.11, 42.36, 19.59,
    43.01, 18.76, 43.54, 18.74, 44.69, 18.68, 44.99, 19.99, 44.55, 20.68]);
  Context.lineTo(44.55, 20.68);
  Context.bezierCurveTo(44.22, 21.4, 43.37, 21.92, 42.58, 21.93);
  BezierCurveToContext(Context, [23.78, 1.82,  23.25, 2.01, 22.43, 2.36, 21.94,
    2.94, 21.5, 3.48, 21.4, 4.08, 21.18, 4.49, 20.94, 4.93, 20.6, 5.15, 20.55,
    4.77, 20.35, 5.25, 19.19, 6.24, 19.43, 5.03, 18.63, 5.89, 18.19, 5.68,
    18.41, 4.93, 19.04, 2.73, 21.78, 1.95, 23.78, 1.82]);
  BezierCurveToContext(Context, [11.56, 9.84,  11.42, 9.6, 11.28, 9.31, 11.52,
    9.04, 11.71, 8.82, 12.04, 8.92, 12.3, 9.11, 13.54, 10.59, 10.68, 11.94,
    10.06, 9.59, 9.61, 8.26, 11.74, 6.36, 11.97, 6.21, 6.69, 9.24, 10.81, 13.02,
    12.69, 11.03, 12.97, 10.75, 13.23, 10.3, 13.17, 9.8, 13.09, 9.2, 12.63, 8.6,
    11.87, 8.64, 11.16, 8.71, 10.93, 9.49, 11.56, 9.84]);
  BezierCurveToContext(Context, [16.3, 0, 16.01, 0.04, 14.32, 0.23, 13.13,
    0.06, 11.24, -0.2, 10.12, 0.48, 12.37, 1.05, 11.63, 1.14, 10.89, 1.28,
    10.88, 1.62, 10.85, 2.2, 11.57, 2.36, 11.57, 2.36, 10.17, 3.06, 11.26, 5.3,
    12.38, 3.21, 13.03, 1.99, 15.24, 0.39, 16.3, 0]);
  BezierCurveToContext(Context, [0.47, 27.64, 0.65, 27.11, 1, 26.29, 1.59,
    25.81, 2.12, 25.36, 2.73, 25.26, 3.14, 25.04, 3.58, 24.8, 3.79, 24.46, 3.42,
    24.41, 3.89, 24.21, 4.89, 23.05, 3.67, 23.29, 4.54, 22.49, 4.32, 22.06,
    3.57, 22.27, 1.37, 22.9, 0.6, 25.64, 0.47, 27.64]);
  BezierCurveToContext(Context, [9.02, 14.36, 8.77, 14.23, 8.48, 14.09, 8.21,
    14.33, 8, 14.52, 8.1, 14.85, 8.28, 15.1, 9.76, 16.34, 11.11, 13.49, 8.76,
    12.87, 7.43, 12.41, 5.53, 14.54, 5.38, 14.78, 8.41, 9.5, 12.19, 13.62,
    10.21, 15.5, 9.92, 15.77, 9.47, 16.03, 8.97, 15.97, 8.37, 15.9, 7.77,
    15.44, 7.81, 14.67, 7.89, 13.96, 8.66, 13.73, 9.02, 14.36]);
  BezierCurveToContext(Context, [0.1, 19.11, 0.14, 18.81, 0.33, 17.12, 0.16,
    15.93, -0.1, 14.04, 0.58, 12.93, 1.15, 15.18, 1.24, 14.43, 1.39, 13.7,
    1.72, 13.68, 2.3, 13.65, 2.46, 14.37, 2.46, 14.37, 3.16, 12.97, 5.41,
    14.06, 3.31, 15.18, 2.09, 15.83, 0.49, 18.04, 0.1, 19.11]);
  BezierCurveToContext(Context, [6.57, 21.93, 7.23, 21.94, 7.88, 21.62, 8.3,
    20.79, 9.05, 19.31, 7.88, 17.61, 6.39, 17.2, 0.51, 15.58, -0.35, 26.14,
    0.1, 30.22, 0.06, 27.76, 0.12, 25.21, 0.73, 22.74, 0.98, 21.7, 1.29, 20.67,
    1.84, 19.71, 2.38, 18.76, 3.51, 17.55, 4.66, 17.42, 5.61, 17.3, 6.76, 17.47,
    7.28, 17.96, 8.9, 19.46, 8.23, 21.21, 7.1, 21.64, 6.39, 21.9, 5.47, 21.69,
    4.84, 20.77, 4.79, 20.69, 4.75, 20.61, 4.71, 20.52, 4.52, 20.03, 4.57,
    19.36, 4.96, 19.08, 5.28, 18.86, 5.8, 18.83, 6.03, 19.21, 6.25, 19.7, 5.58,
    19.78, 5.37, 19.32, 5.26, 19.46, 5.2, 19.86, 5.38, 20.09, 5.53, 20.27, 5.86,
    20.39, 6.18, 20.12, 6.79, 19.59, 6.14, 18.76, 5.61, 18.74, 4.45, 18.68,
    4.16, 19.99, 4.6, 20.68, 4.93, 21.41, 5.78, 21.92, 6.57, 21.93]);
  Context.closePath;
  Context.fill;
end;

class function TCardDrawerOrnament.GetWidth: Float;
begin
  Result := 49.09;
end;

class function TCardDrawerOrnament.GetHeight: Float;
begin
  Result := 30.2;
end;

class procedure TCardDrawerOrnament.Draw(Context: JCanvasRenderingContext2D; ScaleFactor: Float = 1; Flip: Boolean = False);
begin
  Context.Scale(ScaleFactor, ScaleFactor);
  if Flip then Context.rotate(Pi);
  DrawRaw(Context);
  if Flip then Context.rotate(Pi);
  Context.Scale(1 / ScaleFactor, 1 / ScaleFactor);
end;

end.