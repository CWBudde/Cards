unit Card.Main;

interface

{$DEFINE SOLVER}

uses
  ECMA.TypedArray, W3C.DOM4, W3C.HTML5, W3C.WebAudio, Card.Framework,
  Card.Cards, Card.Confetti;

type
  TTopButton = class(TButtonElement);

  TCardTargetCanvas = class(TCanvas2DElement)
  private
    FCardColor: TCardColor;
    FPixelRatio: Float;
  public
    constructor Create(Owner: IHtmlElementOwner; CardColor: TCardColor); overload;

    procedure Resize;
    procedure Paint;

    property CardColor: TCardColor read FCardColor;
  end;

  TCardTarget = class(TDivElement)
  private
    FCanvasElement: TCardTargetCanvas;
  public
    constructor Create(Owner: IHtmlElementOwner; CardColor: TCardColor); overload;

    property CanvasElement: TCardTargetCanvas read FCanvasElement;
  end;

  TPark = class
  private
    FCards: TArrayOfCard;
  protected
    procedure UpdatePositions(LargeAdvance: Float); virtual; abstract;
  public
    constructor Create; virtual;

    property Cards: TArrayOfCard read FCards;
    property Position: TVector2f;
  end;

  TPile = class(TPark)
  public
    procedure UpdatePositions(LargeAdvance: Float); override;
  end;

  TDeck = class(TPark)
  private
    FTinyOffsets: array [TCardValue] of Float;
  public
    constructor Create; override;

    procedure UpdatePositions(LargeAdvance: Float); override;

    property CardTarget: TCardTarget;
  end;

  TPiles = array [0..7] of TPile;
  TDecks = array [TCardColor] of TDeck;

(*
  TModalButton = class(TButtonElement);

  TModalContent = class(TDivElement)
  private
    FHeading: TH1Element;
    FButton: TModalButton;
  public
    constructor Create(Owner: IHtmlElementOwner); overload; override;
  end;

  TModalDialog = class(TDivElement)
  private
    FContent: TModalContent;
  public
    constructor Create(Owner: IHtmlElementOwner); overload; override;

    procedure Show;
    procedure Hide;
  end;
*)

  TMainScreen = class(TDivElement)
  private
    FBackgroundHeader: TH1Element;
    FSolvable: TH5Element;
    FButtonNew: TTopButton;
    FButtonRetry: TTopButton;
    FButtonUndo: TTopButton;
    //FButtonSelect: TTopButton;
    FButtonFinish: TTopButton;
{$IFDEF SOLVER}
    FButtonSolve: TTopButton;
    FLabel: TParagraphElement;
{$ENDIF}
    FCards: TArrayOfCard;
    FCurrentCards: TArrayOfCard;
    FCurrentPark: TPark;
    FPreviousOldPark: TPark;
    FPreviousNewPark: TPark;
    FPreviousCards: TArrayOfCard;
    FHighlightCard: TCard;
    FHintCards: array of TCard;
    FPiles: TPiles;
    FDecks: TDecks;
    FOffset: TVector2f;
    FDown: Boolean;
    FCardWidth: Float;
    FCardHeight: Float;
    FCardUnderCursor: TCard;
    FLargeAdvance: Float;
    FTimeOut: Integer;
    //FModalDialog: TModalDialog;
    FCurrentSeed: Integer;
    FConfetti: TConfetti;
    FHashList: array of Integer;
    FSeedIndex: Integer;
    procedure MouseDownEventHandler(Event: JEvent);
    procedure MouseMoveEventHandler(Event: JEvent);
    procedure MouseUpEventHandler(Event: JEvent);
    procedure TouchStartEventHandler(Event: JEvent);
    procedure TouchMoveEventHandler(Event: JEvent);
    procedure TouchEndEventHandler(Event: JEvent);
  protected
    procedure TouchMouseDown(Position: TVector2f);
    procedure TouchMouseMove(Position: TVector2f);
    procedure TouchMouseUp(Position: TVector2f);
    function GetClosestPile: TPark;
    function GetDeck: TPark;
    function CheckDone: Boolean;
    procedure ShowMouseHint;
    procedure ResetHintCards;

    function LocateTargets(Card: TCard): array of TPark;
    function LocateCardUnderCursor(Position: TVector2f): TCard;
    function FinishOneCard: Boolean;
{$IFDEF SOLVER}
    function GetParkForCard(Card: TCard): TPark;
    function GetPilePriority: array of Integer;
    function GetPossibleCards(OnlyUseful: Boolean = False): TArrayOfCard;
    function GetConcealedHeight(Pile: TPile): Integer;
    procedure Solve;
    function FindFirstNonConcealed(Pile: TPile): TCard;
    function FindFirstNonConcealedIndex(Pile: TPile): Integer;
    function UnveilConcealed: Boolean;
    function CalculateHash: Integer;
    function RandomMove: Boolean;
{$ENDIF}
  public
    constructor Create(Owner: IHtmlElementOwner); overload; override;

    procedure Resize(Event: JEvent);

    procedure Shuffle(RandomSeed: Integer = 0);
    procedure Retry;
    procedure Select;
    procedure Undo;
    procedure ClearUndo;
    procedure Finish;

  end;

var
  MainScreen: TMainScreen;

implementation

uses
  ECMA.Date, ECMA.Console, W3C.Geometry, W3C.CSSOM, W3C.CSSOMView,
  W3C.UIEvents, W3C.TouchEvents, W3C.WebStorage;

const
  CWorkingSeeds = [1476865939254, 1476269729858, 1476279959891, 1476284075669,
    1476288143993, 1476288349873, 1476288756145, 1476288876115, 1476288966305,
    1476289060665, 1476312883639, 1476313825635, 1476314411891, 1476316120917,
    1476321342064, 1476321569834, 1476321750585, 1476322931647, 1476322987251,
    1476324264739, 1476324353562, 1476324424646, 1476324491202, 1476324724538,
    1476324909418, 1476324977202, 1476354545149, 1476354614628, 1476354677709,
    1476354748565, 1476354866415, 1476355118645, 1476355206087, 1476360560334,
    1476360607758, 1476360705999, 1476360826197, 1476361035381, 1476362732813,
    1476362790908, 1476362898852, 1476704659018, 1476704768474, 1476704834522,
    1476705123146, 1476705211026, 1476705325106, 1476705362634, 1476705466770,
    1476705510682, 1476705708714, 1476865666788, 1476865836591, 1476865849666,
    1476866480312, 1476866723283, 1476867192083, 1476867234667, 1476867300548,
    1476880882143, 1476881704526, 1476881776466, 1476881792584, 1476881941182,
    1476881996070, 1476908135375, 1476908447190, 1476908692430, 1476908712726,
    1476908891654, 1476909287087, 1476909314892, 1476909491583, 1476909801151,
    1476910789015, 1476911105966, 1476911141126, 1476911456063, 1476911494344,
    1476912098112, 1476912186375, 1476912207633, 1476912229910, 1476912274478,
    1476912309487, 1476912549062, 1476912574300, 1476912618814, 1476912764312,
    1476913144367, 1476913229725, 1477124441663, 1477124528823, 1477124652408,
    1477124947711, 1479936899513, 1479936972480, 1479937018459, 1479937086536,
    1479937120480, 1479937133005, 1479937275817, 1479937288171, 1479937327712,
    1479937365585, 1479937474488, 1479937980632, 1479938162465, 1479938284632,
    1479938349827, 1479938392504, 1479938403227, 1479938447480, 1479938731096,
    1481292487562, 1481292547946, 1481292737490, 1481292750264, 1481292770389,
    1481292794162, 1481293006786, 1481293127642, 1481293239035, 1481293254146,
    1483015523385, 1483015574337, 1483015652449, 1483015994921, 1483016019041];

{ TCardTargetCanvas }

constructor TCardTargetCanvas.Create(Owner: IHtmlElementOwner; CardColor: TCardColor);
begin
  inherited Create(Owner);

  // determine pixel ratio
  FPixelRatio := 1;
  asm
    @FPixelRatio = window.devicePixelRatio || 1;
  end;

  FCardColor := CardColor;
  Resize;
end;

procedure TCardTargetCanvas.Resize;
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

procedure TCardTargetCanvas.Paint;
begin
  var Scale := CanvasElement.Width / 13;
  Context.setTransform(Scale, 0, 0, Scale, 0, 0);
  Context.ClearRect(0, 0, CanvasElement.Width, CanvasElement.Height);

  Context.lineWidth := 0.28;
  Context.fillStyle := 'rgba(0,0,0,0.15)';
  Context.beginPath;
  case FCardColor of
    ccSpade:
      begin
        Context.moveTo(5.28, 0);
        Context.bezierCurveTo(2.75, 3.61, 0, 5.9, 0, 8.5);
        Context.bezierCurveTo(0, 11.1, 3.73, 11.92, 4.64, 9.5);
        Context.bezierCurveTo(4.71, 9.32, 4.31, 11.94, 3.62, 13.17);
        Context.lineTo(6.93, 13.17);
        Context.bezierCurveTo(6.24, 11.94, 5.85, 9.32, 5.92, 9.5);
        Context.bezierCurveTo(6.81, 11.91, 10.55, 11.46, 10.55, 8.5);
        Context.bezierCurveTo(10.55, 5.55, 7.8, 3.61, 5.28, 0);
      end;
    ccHeart:
      begin
        Context.moveTo(6.2, 12.64);
        Context.bezierCurveTo(4.09, 9.31, 0, 5.76, 0, 3.61);
        Context.bezierCurveTo(0, 1.47, 1.35, 0, 3.03, 0);
        Context.bezierCurveTo(4.72, 0, 5.92, 1.88, 6.2, 3.07);
        Context.bezierCurveTo(6.48, 1.88, 7.68, 0, 9.36, 0);
        Context.bezierCurveTo(11.05, 0, 12.43, 1.45, 12.4, 3.61);
        Context.bezierCurveTo(12.36, 5.78, 8.39, 9.22, 6.2, 12.64);
      end;
    ccClub:
      begin
        Context.moveTo(6.1, 0);
        Context.bezierCurveTo(9.07, 0, 10.02, 2.84, 7.49, 5.67);
        Context.bezierCurveTo(10.86, 4.15, 12.85, 6.42, 12.03, 9.02);
        Context.bezierCurveTo(11.21, 11.63, 7.53, 11, 6.63, 9.1);
        Context.bezierCurveTo(6.3, 10.45, 7.18, 12.04, 7.7, 13.16);
        Context.lineTo(4.51, 13.16);
        Context.bezierCurveTo(5.03, 12.04, 5.92, 10.45, 5.58, 9.1);
        Context.bezierCurveTo(4.69, 11, 1, 11.63, 0.18, 9.02);
        Context.bezierCurveTo(-0.64, 6.42, 1.35, 4.15, 4.72, 5.67);
        Context.bezierCurveTo(2.19, 2.84, 3.14, 0.01, 6.11, 0);
      end;
    ccDiamond:
      begin
        Context.moveTo(5.3, 13.17);
        Context.bezierCurveTo(3.88, 10.82, 1.87, 8.53, 0, 6.58);
        Context.bezierCurveTo(1.87, 4.63, 3.88, 2.35, 5.3, 0);
        Context.bezierCurveTo(6.72, 2.35, 8.73, 4.63, 10.6, 6.58);
        Context.bezierCurveTo(8.73, 8.53, 6.72, 10.82, 5.3, 13.17);
      end;
  end;

  Context.closePath;
  Context.fill;
end;


{ TCardTarget }

constructor TCardTarget.Create(Owner: IHtmlElementOwner; CardColor: TCardColor);
begin
  inherited Create(Owner);

  FCanvasElement := TCardTargetCanvas.Create(Self as IHtmlElementOwner, CardColor);
end;


{ TPark }

constructor TPark.Create;
begin
  FCards.Clear;
end;


{ TPile }

procedure TPile.UpdatePositions(LargeAdvance: Float);
begin
  var Advance := 0.0;
  var Index := 1;
  var SmallAdvance := 0.5 * LargeAdvance;
  var HasLargeAdvance := False;
  for var Card in Cards do
  begin
    Card.Style.left := FloatToStr(Position.X) + 'px';
    Card.Style.top := FloatToStr(Position.Y + Advance) + 'px';
    Card.Style.zIndex := IntToStr(Index);

    Inc(Index);
    if Card.IsConcealed then
      Advance += SmallAdvance
    else
    begin
      if not HasLargeAdvance then
      begin
        var MissingCards := (Length(Cards) - Index) + 3;
        var Distance := Window.innerHeight - Card.CanvasElement.getBoundingClientRect.Top;
        LargeAdvance := Min(LargeAdvance, Distance / MissingCards);
        HasLargeAdvance := True;
      end;

      Advance += LargeAdvance;
    end;
  end;
end;


{ TDeck }

constructor TDeck.Create;
begin
  for var Index := cvA to cvK do
    FTinyOffsets[Index] := 0.1 + 0.2 * (Random + Random + Random);
end;

procedure TDeck.UpdatePositions(LargeAdvance: Float);
begin
  var Index := 1;
  var Offset := 0.0;
  for var Card in Cards do
  begin
    Card.Style.left := FloatToStr(Position.X - Offset) + 'px';
    Card.Style.top := FloatToStr(Position.Y - Offset) + 'px';
    Card.Style.zIndex := IntToStr(Index);
    Offset += FTinyOffsets[Card.Value];
    Inc(Index);
  end;
end;


(*
{ TModalDialog }

constructor TModalDialog.Create(Owner: IHtmlElementOwner);
begin
  inherited Create(Owner);

  FContent := TModalContent.Create(Self as IHtmlElementOwner);

  Style.display := 'none';
end;

procedure TModalDialog.Show;
begin
  Style.display := 'block';
end;

procedure TModalDialog.Hide;
begin
  Style.display := 'none';
end;


{ TModalContent }

constructor TModalContent.Create(Owner: IHtmlElementOwner);
begin
  inherited Create(Owner);

  FHeading := TH1Element.Create(Self as IHtmlElementOwner);
  FHeading.Text := 'You did it!';

  FButton := TModalButton.Create(Self as IHtmlElementOwner);
  FButton.Text := 'Retry';
end;
*)

{ TMainScreen }

constructor TMainScreen.Create(Owner: IHtmlElementOwner);
begin
  inherited Create(Owner);

  MainScreen := Self;
  DivElement.ID := 'main';

  FBackgroundHeader := TH1Element.Create(Self as IHtmlElementOwner);
  FBackgroundHeader.Text := 'SOLITAIRE';

  FButtonNew := TTopButton.Create(Self as IHtmlElementOwner);
  FButtonNew.Text := 'New';
  FButtonNew.ButtonElement.addEventListener('click', lambda
    Shuffle;
  end);
  FButtonNew.ButtonElement.addEventListener('touchstart', lambda
    Shuffle;
  end);

  FButtonRetry := TTopButton.Create(Self as IHtmlElementOwner);
  FButtonRetry.Text := 'Retry';
  FButtonRetry.Style.marginLeft := '0';
  FButtonRetry.ButtonElement.addEventListener('click', @Retry);
  FButtonRetry.ButtonElement.addEventListener('touchstart', @Retry);

(*
  FButtonSelect := TTopButton.Create(Self as IHtmlElementOwner);
  FButtonSelect.Text := 'Select';
  FButtonSelect.ButtonElement.addEventListener('click', lambda
    Select;
  end);
  FButtonSelect.ButtonElement.addEventListener('touchstart', lambda
    Select;
  end);
*)

  FButtonFinish := TTopButton.Create(Self as IHtmlElementOwner);
  FButtonFinish.Text := 'Finish';
  FButtonFinish.Style.setProperty('float', 'right');
  FButtonFinish.Style.marginLeft := '0';
  FButtonFinish.ButtonElement.addEventListener('click', @Finish);
  FButtonFinish.ButtonElement.addEventListener('touchstart', @Finish);

{$IFDEF SOLVER}
  FButtonSolve := TTopButton.Create(Self as IHtmlElementOwner);
  FButtonSolve.Text := 'Solve';
  FButtonSolve.Style.setProperty('float', 'right');
  FButtonSolve.ButtonElement.addEventListener('click', @Solve);
  FButtonSolve.ButtonElement.addEventListener('touchstart', @Solve);
{$ENDIF}

  FButtonUndo := TTopButton.Create(Self as IHtmlElementOwner);
  FButtonUndo.Text := 'Undo';
  FButtonUndo.Style.setProperty('float', 'right');
  FButtonUndo.ButtonElement.addEventListener('click', @Undo);
  FButtonUndo.ButtonElement.addEventListener('touchstart', @Undo);

{$IFDEF SOLVER}
  FLabel := TParagraphElement.Create(Self as IHTMLElementOwner);
  FLabel.Style.position := 'fixed';
  FLabel.Style.color := '#fff';
  FLabel.Style.margin := '0';
  FLabel.Style.top := '0';
{$ENDIF}

  FSolvable := TH5Element.Create(Self as IHTMLElementOwner);
  FSolvable.Text := 'Solvable';
  FSolvable.Style.position := 'fixed';
  FSolvable.Style.color := 'rgba(0,0,0,0.3)';
  FSolvable.Style.margin := '0';
  FSolvable.Style.bottom := '0';

  FLargeAdvance := 32;
  if Variant(LocalStorage.GetItem('SeedIndex')) = null then
  begin
    LocalStorage.SetItem('SeedIndex', '0');
    FSeedIndex := 0;
  end
  else
    FSeedIndex := StrToInt(LocalStorage.GetItem('SeedIndex'));

  for var Index := Low(FPiles) to High(FPiles) do
    FPiles[Index] := TPile.Create;
  for var CardColor in TCardColor do
  begin
    FDecks[CardColor] := TDeck.Create;
    FDecks[CardColor].CardTarget := TCardTarget.Create(Self as IHtmlElementOwner, CardColor);
  end;

  for var CardColor in TCardColor do
    for var CardValue in TCardValue do
    begin
      var Card := TCard.Create(Self as IHtmlElementOwner, CardColor, CardValue);
      Card.TransitionTime := 0.02;
      FCards.Add(Card);
    end;

  // FModalDialog := TModalDialog.Create(Self as IHtmlElementOwner);

  FConfetti := TConfetti.Create(Self as IHtmlElementOwner);
  FConfetti.CanvasElement.addEventListener('click', lambda
    if FConfetti.Rise then
    begin
      FConfetti.Stop;
      Shuffle;
    end;
  end);
  FConfetti.CanvasElement.addEventListener('touchstart', lambda
    if FConfetti.Rise then
    begin
      FConfetti.Stop;
      Shuffle;
    end;
  end);

  // add event listeners
  Window.addEventListener('resize', @Resize);
  DivElement.addEventListener('mousedown', @MouseDownEventHandler);
  DivElement.addEventListener('mousemove', @MouseMoveEventHandler);
  DivElement.addEventListener('mouseup', @MouseUpEventHandler);
  DivElement.addEventListener('touchstart', @TouchStartEventHandler);
  DivElement.addEventListener('touchmove', @TouchMoveEventHandler);
  DivElement.addEventListener('touchend', @TouchEndEventHandler);
  Window.addEventListener('keypress', lambda(Event: JEvent)
    var KeyboardEvent := JKeyboardEvent(Event);
    case KeyboardEvent.keyCode of
{$IFDEF SOLVER}
      115:
        Solve;
{$ENDIF}
      114:
        Shuffle(FCurrentSeed);
      110:
        Shuffle;
      102:
        Finish;
      117:
        Undo;
    end;
  end);

  Resize(nil);
  Shuffle;
end;

procedure TMainScreen.Resize(Event: JEvent);
begin
  var MinWidth := Min(Window.innerWidth, 4 * Window.innerHeight / 3);
  var MinHeight := 3 * MinWidth / 4;

  FCardWidth := MinWidth / 9;
  FCardHeight := 4 * FCardWidth / 3;

  FLargeAdvance := Max(FCardHeight / 5.1, Window.innerHeight / 32);

  for var Card in FCards do
  begin
    Card.Style.width := IntToStr(Round(FCardWidth)) + 'px';
    Card.Style.height := IntToStr(Round(FCardHeight)) + 'px';
    Card.Resize;
  end;

  var ButtonRect := FButtonFinish.ButtonElement.getBoundingClientRect;
  var X := Window.innerWidth - 0.5 * (Window.innerWidth - MinWidth) - 3 * FCardWidth;
  var Y := Max(2 * ButtonRect.top + ButtonRect.height, 0.12 * Window.innerHeight);
  for var Deck in FDecks do
  begin
    Deck.Position := TVector2f.Create(X, Y);
    Deck.UpdatePositions(FLargeAdvance);
    X -= 1.4 * FCardWidth;

    var Style := Deck.CardTarget.Style;
    Style.left := IntToStr(Round(Deck.Position.X) - 6) + 'px';
    Style.top := IntToStr(Round(Deck.Position.Y) - 6) + 'px';
    Style.width := IntToStr(Round(FCardWidth)) + 'px';
    Style.height := IntToStr(Round(FCardHeight)) + 'px';
    Deck.CardTarget.CanvasElement.Resize;
  end;

  X := 0.5 * (Window.innerWidth - MinWidth) + 0.1 * FCardWidth;
  Y := Y + FCardHeight + ButtonRect.top;
  for var Pile in FPiles do
  begin
    Pile.Position := TVector2f.Create(X, Y);
    Pile.UpdatePositions(FLargeAdvance);
    X += 1.1 * FCardWidth;
  end;

  FConfetti.Resize;
end;

procedure TMainScreen.MouseDownEventHandler(Event: JEvent);
begin
  TouchMouseDown(TVector2f.Create(
    JMouseEvent(Event).clientX,
    JMouseEvent(Event).ClientY));
end;

procedure TMainScreen.MouseMoveEventHandler(Event: JEvent);
begin
  Window.clearTimeout(FTimeOut);
  FTimeOut := Window.setTimeout(lambda
      ShowMouseHint;
    end, 500);


  TouchMouseMove(TVector2f.Create(
    JMouseEvent(Event).clientX,
    JMouseEvent(Event).ClientY));
end;

procedure TMainScreen.MouseUpEventHandler(Event: JEvent);
begin
  TouchMouseUp(TVector2f.Create(
    JMouseEvent(Event).clientX,
    JMouseEvent(Event).ClientY));
end;

procedure TMainScreen.TouchStartEventHandler(Event: JEvent);
begin
  // prevent default handling
  Event.preventDefault;

  // calculate bounding rectangle
  var Touches := JTouchEvent(Event).changedTouches;
  TouchMouseDown(TVector2f.Create(Touches[0].pageX, Touches[0].pageY));
end;

procedure TMainScreen.TouchMoveEventHandler(Event: JEvent);
begin
  // prevent default handling
  Event.preventDefault;

  // calculate bounding rectangle
  var Touches := JTouchEvent(Event).changedTouches;
  TouchMouseMove(TVector2f.Create(Touches[0].pageX, Touches[0].pageY));
end;

procedure TMainScreen.TouchEndEventHandler(Event: JEvent);
begin
  // prevent default handling
  Event.preventDefault;

  // calculate bounding rectangle
  var Touches := JTouchEvent(Event).changedTouches;
  TouchMouseUp(TVector2f.Create(Touches[0].pageX, Touches[0].pageY));
end;

function Intersect(A, B: JDomRect): Boolean;
begin
  Result := not ((A.Left + A.Width < B.Left) or (B.Left + B.Width < A.Left) or
    (A.Top + A.Height < B.Top) or (B.Top + B.Height < A.Top));
end;

procedure TMainScreen.TouchMouseDown(Position: TVector2f);
begin
  // ignore multitouch
  if FDown then
    Exit;

  // get element under mouse cursor
  var CurrentElement := Document.elementFromPoint(Position.X, Position.Y);

  // ignore this element
  if CurrentElement = DivElement then
    Exit;

  var Found := False;
  for var Pile in FPiles do
  begin
    var ZCount := 0;
    for var Card in Pile.Cards do
    begin
      // check if the current pile contains the card of choice
      if CurrentElement = Card.CanvasElement then
      begin
        FCurrentPark := Pile;
        Found := True;
      end;

      if Found then
      begin
        if Card.IsConcealed then
        begin
          if Pile.Cards[High(Pile.Cards)] = Card then
            Card.IsConcealed := False;

          ClearUndo;
          Exit;
        end;

        FCurrentCards.Add(Card);
        Card.TransitionTime := 0;
        Card.Style.zIndex := IntToStr(100 + ZCount);
        Inc(ZCount);
      end;
    end;

    if Found then
    begin
      // remove current cards from pile
      for var Card in FCurrentCards do
        Pile.Cards.Remove(Card);

      break;
    end;
  end;

  if not Found then
  begin
    for var Deck in FDecks do
    begin
      if Deck.Cards.Length = 0 then
        continue;

      var Card := Deck.Cards[High(Deck.Cards)];

      // check if the current pile contains the card of choice
      if CurrentElement = Card.CanvasElement then
      begin
        FCurrentPark := Deck;
        Found := True;

        FCurrentCards.Add(Card);
        Card.TransitionTime := 0;
        Card.Style.zIndex := IntToStr(100);

        // remove current card from deck
        Deck.Cards.Remove(Card);
        break;
      end;
    end;
  end;

  if not Found then
    Exit;

  var R := FCurrentCards[0].CanvasElement.getBoundingClientRect;
  FOffset.X := Position.X - R.Left;
  FOffset.Y := Position.Y - R.Top;
  FDown := True;
end;

procedure TMainScreen.TouchMouseMove(Position: TVector2f);

  procedure ResetHighlighting;
  begin
    if Assigned(FHighlightCard) then
    begin
      FHighlightCard.IsHighlighted := False;
      FHighlightCard := nil;
    end;
  end;

begin
  if FDown then
  begin
    var YOffset := 0.0;
    for var Card in FCurrentCards do
    begin
      Card.Style.left := FloatToStr(Position.X - FOffset.X) + 'px';
      Card.Style.top := FloatToStr(Position.Y - FOffset.Y + YOffset) + 'px';

      YOffset += FLargeAdvance;
    end;

    var FoundPark := GetClosestPile;
    if Assigned(FoundPark) and (FoundPark.Cards.Length > 1) then
    begin
      if FHighlightCard <> FoundPark.Cards[0] then
      begin
        ResetHighlighting;
        FHighlightCard := FoundPark.Cards[High(FoundPark.Cards)];
        FHighlightCard.IsHighlighted := True;
      end;
    end
    else
    if Assigned(FHighlightCard) then
    begin
      FHighlightCard.IsHighlighted := False;
      FHighlightCard := nil;
    end;
  end
  else
  begin
    ResetHintCards;
    FCardUnderCursor := LocateCardUnderCursor(Position);
  end;
end;

procedure TMainScreen.TouchMouseUp(Position: TVector2f);

  procedure Transfer(Park: TPark); overload;
  begin
    Assert(Assigned(Park));

    // eventually store undo information
    if Park <> FCurrentPark then
    begin
      FPreviousCards.Clear;
      FPreviousCards.Add(FCurrentCards);
      FPreviousOldPark := FCurrentPark;
      FPreviousNewPark := Park;
    end;

    Park.Cards.Add(FCurrentCards);
    for var Card in FCurrentCards do
      Card.TransitionTime := 0.02;
    Park.UpdatePositions(FLargeAdvance);
    if Park <> FCurrentPark then
      FCurrentPark.UpdatePositions(FLargeAdvance);
    FCurrentCards.Clear;
    CheckDone;
  end;

begin
  // ignore multitouch
  if not FDown then
    Exit;

  FDown := False;

  if Assigned(FHighlightCard) then
  begin
    FHighlightCard.IsHighlighted := False;
    FHighlightCard := nil;
  end;

  // ignore if no card is selected
  if FCurrentCards.Length = 0 then
    Exit;

  var FoundPark := GetClosestPile;

  // eventually check deck as well
  if not Assigned(FoundPark) or (FoundPark = FCurrentPark) then
    FoundPark := GetDeck;

  // check if a park position could be found
  if Assigned(FoundPark) then
    Transfer(FoundPark)
  else
    Transfer(FCurrentPark);
end;

procedure TMainScreen.ResetHintCards;
begin
  if FHintCards.Length > 0 then
  begin
    for var Card in FHintCards do
      Card.IsHighlighted := False;
    FHintCards.Clear;
  end;
end;

procedure TMainScreen.ShowMouseHint;
begin
  ResetHintCards;

  if Assigned(FCardUnderCursor) then
  begin
    var Targets := LocateTargets(FCardUnderCursor);

    for var Target in Targets do
    begin
      var Cards := Target.Cards;
      if Cards.Length > 0 then
      begin
        var Card := Cards[High(Cards)];
        FHintCards.Add(Card);
        Card.IsHighlighted := True;
      end;
    end;
  end;
end;

function TMainScreen.GetClosestPile: TPark;
var
  SqrDistance: Float;
begin
  Result := nil;

  var BottomCard := FCurrentCards[0];
  var BR := BottomCard.CanvasElement.getBoundingClientRect;

  for var Pile in FPiles do
  begin
    if Pile.Cards.Length > 0 then
    begin
      // get top card of the pile
      var TopCard := Pile.Cards[High(Pile.Cards)];

      // skip pile if not under the cursor
      var TR := TopCard.CanvasElement.getBoundingClientRect;
      if not Intersect(BR, TR) then
        continue;

      // skip pile if the top card is an ace
      if TopCard.Value = cvA then
        continue;

      if (BottomCard.Color in [ccClub, ccSpade]) = not (TopCard.Color in [ccClub, ccSpade]) then
        if Integer(BottomCard.Value) + 1 = Integer(TopCard.Value) then
        begin
          // calculate squared card distance
          var NewSqrDistance := Sqr(BR.Left - TR.Left) + Sqr(BR.Top - TR.Top);
          if (Result = nil) or (NewSqrDistance < SqrDistance) then
          begin
            Result := Pile;
            SqrDistance := NewSqrDistance;
          end;
        end;
    end
    else
    if BottomCard.Value = cvK then
    begin
      if not ((BR.Left + BR.Width < Pile.Position.X) or (Pile.Position.X + FCardWidth < BR.Left) or
        (BR.Top + BR.Height < Pile.Position.Y) or (Pile.Position.Y + FCardHeight < BR.Top)) then
      begin
        // calculate squared card distance
        var NewSqrDistance := Sqr(BR.Left - Pile.Position.X) +
          Sqr(BR.Top - Pile.Position.Y);
        if (Result = nil) or (NewSqrDistance < SqrDistance) then
        begin
          Result := Pile;
          SqrDistance := NewSqrDistance;
        end;
      end;
    end;
  end;
end;

function TMainScreen.GetDeck: TPark;
begin
  Result := nil;

  if FCurrentCards.Length = 1 then
  begin
    var BottomCard := FCurrentCards[0];
    var Deck := FDecks[BottomCard.Color];

    if Deck.Cards.Length > 0 then
    begin
      // get top card of the pile
      var TopCard := Deck.Cards[High(Deck.Cards)];

      // skip pile if the top card is an ace
      if Integer(BottomCard.Value) = Integer(TopCard.Value) + 1 then
        Exit(Deck);
    end
    else
    if BottomCard.Value = cvA then
      Exit(Deck);
  end;
end;

procedure TMainScreen.Undo;
begin
  if Assigned(FPreviousOldPark) and Assigned(FPreviousNewPark) and
    (FPreviousOldPark <> FPreviousNewPark) and (FPreviousCards.Length > 0) then
  begin
    // ensure the new park position contains the cards
    if FPreviousNewPark.Cards.IndexOf(FPreviousCards[0]) < 0 then
      exit;

    // remove cards from pile
    for var Card in FPreviousCards do
      FPreviousNewPark.Cards.Remove(Card);

    // add cards to previous (old) park position
    FPreviousOldPark.Cards.Add(FPreviousCards);

    // update card positions
    FPreviousOldPark.UpdatePositions(FLargeAdvance);
    FPreviousNewPark.UpdatePositions(FLargeAdvance);

    ClearUndo;
  end;
end;

procedure TMainScreen.ClearUndo;
begin
  FPreviousCards.Clear;
  FPreviousOldPark := nil;
  FPreviousNewPark := nil;
end;

procedure TMainScreen.Shuffle(RandomSeed: Integer = 0);
const
  CPileLength : array [0..7] of Integer = (3, 4, 5, 6, 7, 8, 9, 10);
var
  Cards: TArrayOfCard;
begin
  // clear undo and hash list
  ClearUndo;
  FHashList.Clear;

  // clear all piles all decks
  for var Pile in FPiles do
    Pile.Cards.Clear;
  for var Deck in FDecks do
    Deck.Cards.Clear;

  // reset card transition time
  for var Card in FCards do
    Card.TransitionTime := 0;

  // specify random seed
  if RandomSeed = 0 then
  begin
    {$IFNDEF SOLVER}
    if FSeedIndex < Length(CWorkingSeeds) then
    begin
      FCurrentSeed := CWorkingSeeds[FSeedIndex];
      Inc(FSeedIndex);
      LocalStorage.SetItem('SeedIndex', IntToStr(FSeedIndex));
      FSolvable.Style.removeProperty('visibility');
    end
    else
    {$ENDIF}
    begin
      FCurrentSeed := JDate.Now;
      FSolvable.Style.visibility := 'hidden';
    end;
  end;
  SetRandSeed(FCurrentSeed);
  Console.Log('Random Seed: ' + IntToStr(FCurrentSeed));

{$IFDEF SOLVER}
  FLabel.Text := IntToStr(FCurrentSeed);
{$ENDIF}

  // shuffle cards
  Cards.Clear;
  Cards.Add(FCards);

  // shuffle cards to piles
  while Cards.Length > 0 do
  begin
    var PileIndex := RandomInt(8);
    if FPiles[PileIndex].Cards.Length < CPileLength[PileIndex] then
    begin
      var Card := Cards[RandomInt(Cards.Length)];
      FPiles[PileIndex].Cards.Add(Card);
      Card.IsConcealed := FPiles[PileIndex].Cards.Length <= CPileLength[PileIndex] - 3;
      Cards.Remove(Card);
    end;
  end;

  // update positions
  for var Pile in FPiles do
    Pile.UpdatePositions(FLargeAdvance);

  // update card transition time
  for var Card in FCards do
    Card.TransitionTime := 0.02;
end;

procedure TMainScreen.Retry;
begin
  Shuffle(FCurrentSeed);
end;

function TMainScreen.FinishOneCard: Boolean;
begin
  Result := False;
  for var Pile in FPiles do
    if Pile.Cards.Length > 0 then
    begin
      var TopCard := Pile.Cards[High(Pile.Cards)];
      var Deck := FDecks[TopCard.Color];

      // eventually unveil concealed card
      if TopCard.IsConcealed then
        TopCard.IsConcealed := False;

      if Deck.Cards.Length > 0 then
      begin
        var BottomCard := FDecks[TopCard.Color].Cards[High(Deck.Cards)];

        if Integer(BottomCard.Value) + 1 = Integer(TopCard.Value) then
        begin
          Deck.Cards.Add(TopCard);
          Pile.Cards.Remove(TopCard);

          TopCard.TransitionTime := 0.1;
          Pile.UpdatePositions(FLargeAdvance);
          Deck.UpdatePositions(FLargeAdvance);
          Exit(True);
        end;
      end
      else
        if TopCard.Value = cvA then
        begin
          Deck.Cards.Add(TopCard);
          Pile.Cards.Remove(TopCard);

          TopCard.TransitionTime := 0.1;
          Pile.UpdatePositions(FLargeAdvance);
          Deck.UpdatePositions(FLargeAdvance);
          Exit(True);
        end;
    end;
end;

function TMainScreen.CheckDone: Boolean;
begin
  Result := FCards.Length =
    FDecks[ccClub].Cards.Length +
    FDecks[ccSpade].Cards.Length +
    FDecks[ccDiamond].Cards.Length +
    FDecks[ccHeart].Cards.Length;
  if Result then
    FConfetti.Start;
end;

procedure TMainScreen.Finish;
begin
  Window.clearTimeout(FTimeOut);

  var Found := FinishOneCard;

  if Found then
    FTimeOut := Window.setTimeout(Finish, 10)
  else
    CheckDone;
end;

procedure TMainScreen.Select;
begin
  // FModalDialog.Show;
end;

function TMainScreen.LocateCardUnderCursor(Position: TVector2f): TCard;
begin
  var CurrentElement := Document.elementFromPoint(Position.X, Position.Y);

  // ignore this element
  if CurrentElement = DivElement then
    Exit;

  for var Card in FCards do
    if Card.CanvasElement = CurrentElement then
      Exit(Card);
end;

function TMainScreen.LocateTargets(Card: TCard): array of TPark;
begin
  for var Pile in FPiles do
  begin
    if Pile.Cards.Length > 0 then
    begin
      // get top card of the pile
      var TopCard := Pile.Cards[High(Pile.Cards)];

      // skip pile if the top card is an ace
      if TopCard.Value = cvA then
        continue;

      if (Card.Color in [ccClub, ccSpade]) = not (TopCard.Color in [ccClub, ccSpade]) then
        if (Integer(Card.Value) + 1 = Integer(TopCard.Value)) then
          Result.Add(Pile);
    end
    else
    if Card.Value = cvK then
      Result.Add(Pile);
  end;
end;

{$IFDEF SOLVER}
function TMainScreen.GetConcealedHeight(Pile: TPile): Integer;
begin
  Result := 0;
  for var Card in Pile.Cards do
    if Card.IsConcealed then
      Inc(Result)
    else
      Exit;
end;

function TMainScreen.GetPilePriority: array of Integer;
var
  Priorities: array [0..7] of Integer;
begin
  Priorities[0] := 0;
  for var Index := 1 to High(FPiles) do
    Priorities[Index] := GetConcealedHeight(FPiles[Index]);

  var Height := 0;
  while Result.Length < 8 do
  begin
    for var PriorityIndex := 0 to 7 do
      if Priorities[PriorityIndex] = Height then
        Result.Add(PriorityIndex);
    Inc(Height);
  end;

  Result.Reverse;
end;

function TMainScreen.FindFirstNonConcealed(Pile: TPile): TCard;
begin
  Result := nil;
  for var Card in Pile.Cards do
    if not Card.IsConcealed then
      Exit(Card);
end;

function TMainScreen.FindFirstNonConcealedIndex(Pile: TPile): Integer;
begin
  Result := -1;
  for var Index := 0 to High(Pile.Cards) do
    if not Pile.Cards[Index].IsConcealed then
      Exit(Index);
end;

function TMainScreen.UnveilConcealed: Boolean;
begin
  Result := False;
  var PileIndexes := GetPilePriority;

  for var PileIndex in PileIndexes do
  begin
    var Pile := FPiles[PileIndex];
    var Card := FindFirstNonConcealed(Pile);

    if Assigned(Card) then
    begin
      // locate possible targets
      var Targets := LocateTargets(Card);

      // eventually remove current pile as possible target
      if Targets.IndexOf(Pile) >= 0 then
        Targets.Remove(Pile);

      if Targets.Length > 0 then
      begin
        var Target := Targets[0];
        var CardIndex := FindFirstNonConcealedIndex(Pile);

        // security check
        Assert(CardIndex >= 0);

        while Pile.Cards.Length - CardIndex > 0 do
        begin
          Target.Cards.Add(Pile.Cards[CardIndex]);
          Pile.Cards.Delete(CardIndex);
        end;

        if CardIndex > 0 then
          Pile.Cards[CardIndex - 1].IsConcealed := False;

        Targets[0].UpdatePositions(FLargeAdvance);
        Pile.UpdatePositions(FLargeAdvance);

        ClearUndo;
        Exit(True);
      end;
    end;
  end;
end;

function GetCardIndex(Card: TCard; Park: TPark): Integer;
begin
  Result := -1;
  for var Index := 0 to High(Park.Cards) do
    if Park.Cards[Index] = Card then
      Exit(Index);
end;

function TMainScreen.GetPossibleCards(OnlyUseful: Boolean = False): TArrayOfCard;
begin
  // search possible cards
  for var Card in FCards do
  begin
    if Card.IsConcealed then
      continue;

    var Targets := LocateTargets(Card);
    var CurrentPark := GetParkForCard(Card);
    if CurrentPark = nil then
      continue;
    if (CurrentPark is TDeck) and (Card <> CurrentPark.Cards[High(CurrentPark.Cards)]) then
      continue;

    if Targets.IndexOf(CurrentPark) >= 0 then
      Targets.Remove(CurrentPark);

    if Targets.Length > 0 then
    begin
      var CardIndex := GetCardIndex(Card, CurrentPark);

      if OnlyUseful then
      begin
        // ignore moves from the deck
        if CurrentPark is TDeck then
          continue;

        // ignore bottom card moves
        if CardIndex <= 0 then
          continue;

        // ignore sorted state
        var CardBelow := CurrentPark.Cards[CardIndex - 1];
        if (CardBelow.Color in [ccClub, ccSpade]) = not (Card.Color in [ccClub, ccSpade])
          and (Integer(CardBelow.Value) = Integer(Card.Value) + 1) then
          continue;
      end;

      // ignore moving kings around
      if (CardIndex = 0) and (Targets[0].Cards.Length = 0) then
        continue;

      Result.Add(Card);
    end;
  end;
end;

function TMainScreen.RandomMove: Boolean;
begin
  Result := False;
  var PossibleCards := GetPossibleCards(True);
  if PossibleCards.Length = 0 then
    PossibleCards := GetPossibleCards;

  // check if there are any possible cards to move
  if PossibleCards.Length = 0 then
    Exit(False);

  var Card := PossibleCards[RandomInt(PossibleCards.Length)];

  // locate possible targets
  var Targets := LocateTargets(Card);
  var CurrentPark := GetParkForCard(Card);

  // eventually remove current pile as possible target
  if Targets.IndexOf(CurrentPark) >= 0 then
    Targets.Remove(CurrentPark);

  if Targets.Length > 0 then
  begin
    var Target := Targets[RandomInt(Targets.Length)];
    var CardIndex := GetCardIndex(Card, CurrentPark);
    Assert(CardIndex >= 0);

    while CurrentPark.Cards.Length - CardIndex > 0 do
    begin
      Target.Cards.Add(CurrentPark.Cards[CardIndex]);
      CurrentPark.Cards.Delete(CardIndex);
    end;

    if CardIndex > 0 then
      CurrentPark.Cards[CardIndex - 1].IsConcealed := False;

    Targets[0].UpdatePositions(FLargeAdvance);
    CurrentPark.UpdatePositions(FLargeAdvance);

    ClearUndo;
    Exit(True);
  end;
end;

function TMainScreen.CalculateHash: Integer;
var
  Data: array of Integer;
begin
  for var Deck in FDecks do
    Data.Add(Deck.Cards.Length);
  for var Pile in FPiles do
  begin
    Data.Add(Pile.Cards.Length);
    for var Card in Pile.Cards do
      Data.Add(4 * Integer(Card.Value) + Integer(Card.Color));
  end;

  Result := 0;
	for var Item in Data do
    Result := (Result xor Item) * 16777619;
end;

function TMainScreen.GetParkForCard(Card: TCard): TPark;
begin
  Result := nil;

  // first check decks
  for var Deck in FDecks do
    if Deck.Cards.IndexOf(Card) >= 0 then
      Exit(Deck);

  // next check piles
  for var Pile in FPiles do
    if Pile.Cards.IndexOf(Card) >= 0 then
      Exit(Pile);
end;

procedure TMainScreen.Solve;
begin
  Window.clearTimeout(FTimeOut);

  //eventually exit if user interacts
  if FCurrentCards.Length > 0 then
    Exit;

  // try to finish a card
  var Found := FinishOneCard;
  if Found and CheckDone then
    Exit;

  // try to unveil a concealed card
  if not Found then
  begin
    Found := UnveilConcealed;
    if Found then
    begin
      if CheckDone then
        Exit;

      var HashValue := CalculateHash;
      if FHashList.IndexOf(HashValue) >= 0 then
        Found := False
      else
        FHashList.Add(HashValue);
    end;
  end;

  Randomize;
  if not Found then
  begin
    Found := RandomMove;

    if Found then
    begin
      if CheckDone then
        Exit;
      var HashValue := CalculateHash;
      if FHashList.IndexOf(HashValue) >= 0 then
        Found := False
      else
        FHashList.Add(HashValue);
    end;
  end;

  if Found then
    Window.setTimeout(Solve, 10)
  else
    CheckDone;
end;
{$ENDIF}

end.