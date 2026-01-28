unit ABSnake;

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.ExtCtrls,
  Vcl.Forms, Vcl.Controls;

const
 TIMER = 1;

type
  TSouradnice = record
    x, y: Integer;
  end;

procedure DrawSnakeSegmentWithBorder(CellSize, x, y: Integer; bodyColor, borderColor: TColor);
procedure Initialize;
procedure GenerateFood;
procedure CheckAll;
procedure PaintSnake(ResultStr, PauseStr: String);
procedure CreateSnake(Form: TForm; PaintBox: TPaintBox);
procedure DestroySnake;
type
  TKeyHandler = class
    class procedure SnakeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    class procedure SnakeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
  end;

implementation

var
 CurrentPaintBox: TPaintBox;
 CurrentForm: TForm;
 had: array[1..MAX_PATH] of TSouradnice;
 dlzka: Integer;
 smer, smerBuffer: Char;
 CellSize: Integer;
 Food: TSouradnice;
 IsRunning: Boolean;
 IsPaused: Boolean;
 Score: Integer;
 KeysDown: array[0..255] of Boolean;

procedure DrawSnakeSegmentWithBorder(CellSize, x, y: Integer; bodyColor, borderColor: TColor);
var
  R: TRect;
  borderWidth: Integer;
begin
  borderWidth := 2;
  R := Rect(x, y, x + CellSize, y + CellSize);

  // Внешняя рамка
  CurrentPaintBox.Canvas.Brush.Color := borderColor;
  CurrentPaintBox.Canvas.FillRect(R);

  // Внутренняя часть
  InflateRect(R, -borderWidth, -borderWidth);
  CurrentPaintBox.Canvas.Brush.Color := bodyColor;
  CurrentPaintBox.Canvas.FillRect(R);
end;

procedure Initialize;
var
 i: Integer;
begin
 dlzka := 3;
 smer := 'd';
 smerBuffer := 'd'; // сброс буфера
 for i := 1 to dlzka do
 begin
  had[i].x := 10 - i;
  had[i].y := 10;
 end;
 GenerateFood;
end;

procedure GenerateFood;
var
  i: Integer;
  ValidPosition: Boolean;
begin
  Randomize;
  repeat
    Food.x := Random(CurrentPaintBox.Width div CellSize);
    Food.y := Random(CurrentPaintBox.Height div CellSize);
    ValidPosition := True;

    // Проверяем, не совпадает ли позиция еды с телом змейки
    for i := 1 to dlzka do
    begin
      if (Food.x = had[i].x) and (Food.y = had[i].y) then
      begin
        ValidPosition := False;
        Break;
      end;
    end;
  until ValidPosition;
end;

procedure CheckAll;
var
  i: Integer;
  newHead: TSouradnice;
begin
  smer := smerBuffer; // применяем буфер.

  // создаём новую голову на основе текущего направления
  newHead := had[1];
  case smer of
    'w': Dec(newHead.y);
    's': Inc(newHead.y);
    'a': Dec(newHead.x);
    'd': Inc(newHead.x);
  end;

  // Проверка столкновений
  if (newHead.x < 0) or (newHead.x >= CurrentPaintBox.Width div CellSize) or
     (newHead.y < 0) or (newHead.y >= CurrentPaintBox.Height div CellSize) then
  begin
    KillTimer(CurrentForm.Handle,TIMER);
    IsRunning := False;
    Exit;
  end;

  // Столкновение с собой
for i := 1 to dlzka do
  if (had[i].x = newHead.x) and (had[i].y = newHead.y) then
  begin
    KillTimer(CurrentForm.Handle,TIMER);
    IsRunning := False;
    Exit;
  end;

  // Сдвиг змеи
  for i := dlzka downto 2 do
    had[i] := had[i - 1];

  // Обновляем голову
  had[1] := newHead;

  // Проверка еды
  if (newHead.x = Food.x) and (newHead.y = Food.y) then
  begin
    Inc(dlzka);
    Inc(Score);
    had[dlzka] := had[dlzka - 1]; // добавить хвост
    GenerateFood;
  end;
end;

procedure PaintSnake(ResultStr, PauseStr: String);
var
  i: Integer;
  s: string;
  TextSize: TSize;
  gradientStep: Integer;
  startColor, endColor: TColor;
  currentColor: TColor;
  r1, g1, b1, r2, g2, b2: Byte;
begin
  with CurrentPaintBox do
  begin
   Canvas.Pen.Color := clBlack;
   Canvas.Pen.Width := 1;
   Canvas.Rectangle(-0, -0, CurrentPaintBox.ClientWidth, CurrentPaintBox.ClientHeight);
  end;

  if not IsRunning then
  begin
    // Draw Game Over
    CurrentPaintBox.Canvas.Brush.Style := bsClear;
    CurrentPaintBox.Canvas.Font.Color := clBlack;
    CurrentPaintBox.Canvas.Font.Size := 20;
    s := ResultStr + IntToStr(Score);
    TextSize := CurrentPaintBox.Canvas.TextExtent(s);
    CurrentPaintBox.Canvas.TextOut(
      (CurrentPaintBox.Width - TextSize.cx) div 2,
      (CurrentPaintBox.Height - TextSize.cy) div 2,
      s);
    Exit;
  end;

  // Draw Food
  DrawSnakeSegmentWithBorder(CellSize, Food.x * CellSize, Food.y * CellSize, clRed, clMaroon);

  // Gradient colors for snake body
  startColor := clLime;       // Start color (bright green)
  endColor := clGreen;        // End color (dark green)

  // Extract RGB components
  r1 := GetRValue(startColor);
  g1 := GetGValue(startColor);
  b1 := GetBValue(startColor);
  r2 := GetRValue(endColor);
  g2 := GetGValue(endColor);
  b2 := GetBValue(endColor);

  // Draw Snake with gradient
  for i := 1 to dlzka do
  begin
    if i = 1 then
    begin
      // Draw black head
      DrawSnakeSegmentWithBorder(CellSize,
        had[i].x * CellSize,
        had[i].y * CellSize,
        clLime,           // Head color (black)
        clGreen            // Border color (black)
      );
    end
    else
    begin
      // Calculate gradient color for this segment
      if dlzka > 2 then
      begin
        gradientStep := Round(255 * (i / dlzka));
        currentColor := RGB(
          r1 + (r2 - r1) * gradientStep div 255,
          g1 + (g2 - g1) * gradientStep div 255,
          b1 + (b2 - b1) * gradientStep div 255
        );
      end
      else
        currentColor := startColor;

      DrawSnakeSegmentWithBorder(CellSize,
        had[i].x * CellSize,
        had[i].y * CellSize,
        currentColor,           // Body color (gradient)
        clGreen                // Border color (dark green)
      );
    end;
  end;

  // Draw Pause
  if IsPaused then
  begin
    CurrentPaintBox.Canvas.Brush.Style := bsClear;
    CurrentPaintBox.Canvas.Font.Color := clBlack;
    CurrentPaintBox.Canvas.Font.Size := 20;
    s := PauseStr;
    TextSize := CurrentPaintBox.Canvas.TextExtent(s);
    CurrentPaintBox.Canvas.TextOut(
      (CurrentPaintBox.Width - TextSize.cx) div 2,
      (CurrentPaintBox.Height - TextSize.cy) div 2,
      s);
  end;
end;

procedure TimerCallBack(uTimerID, uMessage: UINT; dwUser, dw1, dw2: DWORD); stdcall;
begin
 if not IsPaused then // Проверяем, не на паузе ли игра
  begin
   CheckAll;
   CurrentPaintBox.Repaint;
  end;
end;

procedure CreateSnake(Form: TForm; PaintBox: TPaintBox);
begin
with Form do
 begin
  CurrentForm := Form;
  CurrentPaintBox := PaintBox;
  CurrentPaintBox.ControlStyle := CurrentPaintBox.ControlStyle + [csOpaque];
  DoubleBuffered := True;
  KeyPreview := True;
  CellSize := 10;
  IsRunning := True;
  IsPaused := False;
  Initialize;
  SetTimer(Handle,TIMER, 200, @TimerCallBack);
  OnKeyDown := TKeyHandler.SnakeKeyDown;
  OnKeyUp := TKeyHandler.SnakeKeyUp;
 end;
end;

procedure DestroySnake;
var
  i: Integer;
begin
  // Stop the timer
  if CurrentForm <> nil then
  begin
    KillTimer(CurrentForm.Handle, TIMER);
  end;

  // Reset game state
  dlzka := 0;
  smer := #0;
  smerBuffer := #0;
  IsRunning := False;
  IsPaused := False;
  Score := 0;
  Food.x := 0;
  Food.y := 0;

  // Clear snake array
  for i := 1 to Length(had) do
  begin
    had[i].x := 0;
    had[i].y := 0;
  end;

  // Clear key states
  for i := Low(KeysDown) to High(KeysDown) do
  begin
    KeysDown[i] := False;
  end;

  // Clear PaintBox canvas
  if CurrentPaintBox <> nil then
  begin
    CurrentPaintBox.Canvas.Brush.Color := clBtnFace;
    CurrentPaintBox.Canvas.FillRect(CurrentPaintBox.ClientRect);
  end;

  // Remove event handlers
  if CurrentForm <> nil then
  begin
    CurrentForm.OnKeyDown := nil;
    CurrentForm.OnKeyUp := nil;
  end;

  // Reset form and paintbox references
  CurrentForm := nil;
  CurrentPaintBox := nil;
end;

class procedure TKeyHandler.SnakeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 KeysDown[Key] := True;

 // Обработка паузы (клавиша P)
 if (Key = VK_PAUSE) and IsRunning then
  begin
    IsPaused := not IsPaused;
    CurrentPaintBox.Repaint; // Перерисовываем, чтобы показать/убрать текст паузы
    Exit;
  end;

 if not IsRunning and (Key = VK_SPACE) then
 begin
  Initialize;
  Score := 0; // <--- сбрасываем только при рестарте
  IsRunning := True;
  IsPaused := False;
  SetTimer(CurrentForm.Handle, TIMER, 170, @TimerCallBack);
  Exit;
 end;

 // Игнорируем управление, если игра на паузе
 if IsPaused then Exit;

 // Проверяем, нажата ли одновременно вторая стрелка
 if (KeysDown[VK_UP] and KeysDown[VK_LEFT]) or
    (KeysDown[VK_UP] and KeysDown[VK_RIGHT]) or
    (KeysDown[VK_DOWN] and KeysDown[VK_LEFT]) or
    (KeysDown[VK_DOWN] and KeysDown[VK_RIGHT]) then
   Exit; // игнорируем направление

 // Управление: стрелки + WASD
  case Key of
    VK_LEFT, Ord('A'): if smer <> 'd' then smerBuffer := 'a';
    VK_RIGHT, Ord('D'): if smer <> 'a' then smerBuffer := 'd';
    VK_UP, Ord('W'): if smer <> 's' then smerBuffer := 'w';
    VK_DOWN, Ord('S'): if smer <> 'w' then smerBuffer := 's';
  end;
end;

class procedure TKeyHandler.SnakeKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
 KeysDown[Key] := False;
end;

end.

