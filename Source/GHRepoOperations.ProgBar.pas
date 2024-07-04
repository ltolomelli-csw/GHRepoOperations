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
  public
    constructor Create(AProgBar: TProgressBar; AStatusPanel: TStatusPanel);
    destructor Destroy; override;

    procedure Clear;
    procedure SetMessage(const AMsg: string; const AShowProgNum: Boolean = True);
    procedure Step(const AValue: Integer = 1);
    procedure Max(const AValue: Integer);
    function GetMax: Integer;
    procedure Hide(const AClear: Boolean);

    property ShowProgNum: Boolean read FShowProgNum write FShowProgNum;
  end;

implementation

{ TGHRepoOpProgressBar }

procedure TGHRepoOpProgressBar.Clear;
begin
  TThread.Synchronize(nil,
    procedure
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
    end
  );
end;

constructor TGHRepoOpProgressBar.Create(AProgBar: TProgressBar; AStatusPanel: TStatusPanel);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      FPBAssigned := Assigned(AProgBar);
      if IsPBAssigned then
        FProgBar := AProgBar;

      FStatusPanelAssigned := Assigned(AStatusPanel);
      if IsStatusPanelAssigned then
        FStatusPanel := AStatusPanel;
    end
  );
end;

destructor TGHRepoOpProgressBar.Destroy;
begin
  FProgBar := nil;
  FStatusPanel := nil;
  inherited;
end;

function TGHRepoOpProgressBar.GetMax: Integer;
begin
  Result := FProgBar.Max;
end;

procedure TGHRepoOpProgressBar.Hide(const AClear: Boolean);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      if IsPBAssigned then
        FProgBar.Hide;

      if AClear then
        Clear;
    end
  );
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
  TThread.Synchronize(nil,
    procedure
    begin
      if IsPBAssigned then
      begin
        FProgBar.Max := AValue;
      end;
    end
  );
end;

procedure TGHRepoOpProgressBar.SetMessage(const AMsg: string; const AShowProgNum: Boolean);
var
  LMsg: string;
begin
  TThread.Synchronize(nil,
    procedure
    begin
      if IsPBAssigned then
        FProgBar.Show;

      if IsStatusPanelAssigned then
      begin
        if AMsg.IsEmpty then
          LMsg := FInitialMsg
        else
          LMsg := AMsg;

        if AShowProgNum then
          LMsg := '[' + IntToStr(FProgBar.Position) + ' / ' + IntToStr(FProgBar.Max) + '] ' + LMsg;

        FStatusPanel.Text := LMsg;
      end;
    end
  );
end;

procedure TGHRepoOpProgressBar.Step(const AValue: Integer);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      if IsPBAssigned then
      begin
        if AValue <= 1 then
          FProgBar.StepIt
        else
          FProgBar.StepBy(AValue);
      end;
    end
  );
end;

end.
