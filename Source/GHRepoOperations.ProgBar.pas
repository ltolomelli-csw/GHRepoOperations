unit GHRepoOperations.ProgBar;

interface

uses
  Vcl.Forms, Vcl.ComCtrls, Vcl.StdCtrls,
  System.Classes, System.SysUtils;

type
  IGHRepoOpProgressBar = interface(IInterface)
    ['{95F8842F-68E1-4959-BAF8-27332A875960}']
    procedure Clear;
    procedure SetMessage(const AMsg: string; const AShowProgNum: Boolean = True);
    procedure Step(const AValue: Integer = 1);
    procedure Max(const AValue: Integer);
    function GetMax: Integer;
    procedure Hide(const AClear: Boolean);
  end;

  TGHRepoOpProgressBar = class(TInterfacedObject, IGHRepoOpProgressBar)
  private
    FProgBar: TProgressBar;
    FStatusPanel: TStatusPanel;
    FPBAssigned, FStatusPanelAssigned: Boolean;
    FInitialMsg: string;
    FShowProgNum: Boolean;
    function IsPBAssigned: Boolean;
    function IsStatusPanelAssigned: Boolean;
    procedure SetInitialMsg(const Value: string);
  public
    constructor Create(const AProgBar: TProgressBar; const AStatusPanel: TStatusPanel);

    procedure Clear;
    procedure SetMessage(const AMsg: string; const AShowProgNum: Boolean = True);
    procedure Step(const AValue: Integer = 1);
    procedure Max(const AValue: Integer);
    function GetMax: Integer;
    procedure Hide(const AClear: Boolean);

    property InitialMsg: string read FInitialMsg write SetInitialMsg;
    property ShowProgNum: Boolean read FShowProgNum write FShowProgNum;
  end;

procedure InitializeGHRepoProgBar(AJSIProgBar: IGHRepoOpProgressBar; const AMsg: string; const AMax: Integer);

implementation

procedure InitializeGHRepoProgBar(AJSIProgBar: IGHRepoOpProgressBar; const AMsg: string; const AMax: Integer);
begin
  if Assigned(AJSIProgBar) then
  begin
    AJSIProgBar.Clear;
    AJSIProgBar.Max(AMax);
    (AJSIProgBar as TGHRepoOpProgressBar).InitialMsg := AMsg;
    AJSIProgBar.SetMessage(AMsg, False);
  end;
end;

{ TGHRepoOpProgressBar }

procedure TGHRepoOpProgressBar.Clear;
begin
  if IsPBAssigned then
  begin
    FProgBar.Position := 1;
    FProgBar.Step := 1;
    FProgBar.Min  := 1;
    FProgBar.Max  := 100;
  end;

  if IsStatusPanelAssigned then
    FStatusPanel.Text := '';
end;

constructor TGHRepoOpProgressBar.Create(const AProgBar: TProgressBar; const AStatusPanel: TStatusPanel);
begin
  FPBAssigned := Assigned(AProgBar);
  if IsPBAssigned then
    FProgBar := AProgBar;

  FStatusPanelAssigned := Assigned(AStatusPanel);
  if IsStatusPanelAssigned then
    FStatusPanel := AStatusPanel;
end;

function TGHRepoOpProgressBar.GetMax: Integer;
begin
  Result := FProgBar.Max;
end;

procedure TGHRepoOpProgressBar.Hide(const AClear: Boolean);
begin
  if IsPBAssigned then
    FProgBar.Hide;

  if AClear then
    Clear;
end;

function TGHRepoOpProgressBar.IsStatusPanelAssigned: Boolean;
begin
  Result := FStatusPanelAssigned;
end;

function TGHRepoOpProgressBar.IsPBAssigned: Boolean;
begin
  Result := FPBAssigned;
end;

procedure TGHRepoOpProgressBar.Max(const AValue: Integer);
begin
  if IsPBAssigned then
  begin
    FProgBar.Max := AValue;
    Application.ProcessMessages;
  end;
end;

procedure TGHRepoOpProgressBar.SetInitialMsg(const Value: string);
begin
  FInitialMsg := Value;
  FProgBar.Visible := True;
  Application.ProcessMessages;
end;

procedure TGHRepoOpProgressBar.SetMessage(const AMsg: string; const AShowProgNum: Boolean);
var
  LMsg: string;
begin
  if IsStatusPanelAssigned then
  begin
    if AMsg.IsEmpty then
      LMsg := FInitialMsg
    else
      LMsg := AMsg;

    if AShowProgNum then
      LMsg := '[' + IntToStr(FProgBar.Position) + ' / ' + IntToStr(FProgBar.Max) + '] ' + LMsg;

    FStatusPanel.Text := LMsg;
    Application.ProcessMessages;
  end;
end;

procedure TGHRepoOpProgressBar.Step(const AValue: Integer);
begin
  if IsPBAssigned then
  begin
    if AValue <= 1 then
      FProgBar.StepIt
    else
      FProgBar.StepBy(AValue);
    Application.ProcessMessages;
  end;
end;

end.
