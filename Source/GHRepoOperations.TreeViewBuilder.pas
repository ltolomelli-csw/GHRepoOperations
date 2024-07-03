unit GHRepoOperations.TreeViewBuilder;

interface

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  System.Variants,
  AdvTreeView,
  AdvTreeViewBase,
  AdvTreeViewData,
  GHRepoOperations.Messages,
  GHRepoOperations.Models,
  GHRepoOperations.Types,
  GHRepoOperations.Utils;

type
  TTreeViewBuilder = class
  private
    FTreeView: TAdvTreeView;
    procedure ResetColumns;
    function GetNewNodeData(const AIsRoot, AShowCheckBox: Boolean;
      const ARepository, ABranch, ATag: string; const AReleaseType: TPairGHReleaseType): TTVNodeData;
    procedure FreeNodeDatas;
    procedure FreeTVNodeData(ANode: TAdvTreeViewNode);
  public
    constructor Create(ATreeView: TAdvTreeView); reintroduce;
    destructor Destroy; override;

    procedure ResetTree;
    procedure LoadRepos(const ARepoModels: TArray<TGHCliRepoModel>);

    function AddTreeViewNode(AParent: TAdvTreeViewNode; const ARepository: string;
      const AShowCheckBox: Boolean): TAdvTreeViewNode; overload;
    function AddTreeViewNode(AParent: TAdvTreeViewNode; const ARepository, ABranch, ATag, APublishedDate: string;
      const AReleaseType: TPairGHReleaseType;
      const AShowCheckBox: Boolean): TAdvTreeViewNode; overload;

    class function GetTVNodeData(ANode: TAdvTreeViewNode; out ANodeData: TTVNodeData): Boolean;

    property TreeView: TAdvTreeView read FTreeView;
  end;

implementation

{ TTreeViewBuilder }

function TTreeViewBuilder.AddTreeViewNode(AParent: TAdvTreeViewNode;
  const ARepository: string; const AShowCheckBox: Boolean): TAdvTreeViewNode;
begin
  Result := AddTreeViewNode(AParent, ARepository, '', '', '', TGHReleaseTypeDecode.PairFromEnum(grtNull), AShowCheckBox);
end;

function TTreeViewBuilder.AddTreeViewNode(AParent: TAdvTreeViewNode;
  const ARepository, ABranch, ATag, APublishedDate: string; const AReleaseType: TPairGHReleaseType;
  const AShowCheckBox: Boolean): TAdvTreeViewNode;
var
  LNodeData: TTVNodeData;
begin
  LNodeData := GetNewNodeData(AParent = nil, AShowCheckBox, ARepository, '', '', TGHReleaseTypeDecode.PairFromEnum(grtNormal));
  Result := FTreeView.AddNode(AParent);
  Result.DataObject := LNodeData;

  if LNodeData.ShowCheckBox then
    Result.CheckTypes[0] := tvntCheckBox
  else
    Result.CheckTypes[0] := tvntNone;

  Result.Text[0] := IfThen(ABranch.Trim.IsEmpty, ARepository, ABranch);
  Result.Text[1] := ATag;

  Result.Text[2] := EmptyStr;
  if AReleaseType.Key <> grtNull then
    Result.Text[2] := AReleaseType.Value;

  Result.Text[3] := APublishedDate;
end;

constructor TTreeViewBuilder.Create(ATreeView: TAdvTreeView);
begin
  inherited Create;
  FTreeView := ATreeView;
end;

destructor TTreeViewBuilder.Destroy;
begin
  FreeNodeDatas;
  FTreeView := nil;
  inherited;
end;

procedure TTreeViewBuilder.FreeNodeDatas;
var
  LNode: TAdvTreeViewNode;
begin
  if FTreeView.Nodes.Count = 0 then
    Exit;

  LNode := FTreeView.GetFirstRootNode;
  repeat
    FreeTVNodeData(LNode);
    LNode := LNode.GetNext;
  until (LNode = nil); // sono arrivato a fine albero
end;

procedure TTreeViewBuilder.FreeTVNodeData(ANode: TAdvTreeViewNode);
var
  LNodeData: TTVNodeData;
begin
  LNodeData := TTVNodeData(ANode.DataObject);
  ANode.DataObject := nil;
  FreeAndNil(LNodeData);
end;

function TTreeViewBuilder.GetNewNodeData(const AIsRoot, AShowCheckBox: Boolean;
  const ARepository, ABranch, ATag: string; const AReleaseType: TPairGHReleaseType): TTVNodeData;
begin
  Result := TTVNodeData.Create;
  try
    Result.IsRoot := AIsRoot;
    Result.ShowCheckBox := AShowCheckBox;
    Result.Repository := ARepository;
    Result.Branch := ABranch;
    Result.Tag := ATag;
    Result.ReleaseType := AReleaseType;
  except
    begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

class function TTreeViewBuilder.GetTVNodeData(ANode: TAdvTreeViewNode; out ANodeData: TTVNodeData): Boolean;
begin
  ANodeData := nil;
  Result := ANode.DataObject is TTVNodeData;
  if Result then
    ANodeData := TTVNodeData(ANode.DataObject);
end;

procedure TTreeViewBuilder.LoadRepos(const ARepoModels: TArray<TGHCliRepoModel>);
var
  I, J: Integer;
  LBranch, LTag, LPublishedDate: string;
  LReleaseType: TPairGHReleaseType;
  LRepoModel: TGHCliRepoModel;
  LNodeRepo: TAdvTreeViewNode;
begin
  ResetTree;

  for I := 0 to High(ARepoModels) do
  begin
    LRepoModel := ARepoModels[I];

    LNodeRepo := AddTreeViewNode(nil, LRepoModel.Name, True);
    for J := 0 to High(LRepoModel.Branches) do
    begin
      LBranch := LRepoModel.Branches[J];

      if SameText(LBranch, 'main') and (Length(LRepoModel.Tags) > 0) then
      begin
        // devo considerare sempre il Model in posizione 0 perch� sono ordinati in
        // modo decrescente (come su GitHub) e mi interessano quei valori
        LTag := LRepoModel.Tags[0].Tag;
        LReleaseType := LRepoModel.Tags[0].ReleaseType;
        LPublishedDate := LRepoModel.Tags[0].PublishedDate;
      end
      else
      begin
        LTag := EmptyStr;
        LReleaseType := TGHReleaseTypeDecode.PairFromEnum(grtNull);
        LPublishedDate := '';
      end;

      AddTreeViewNode(LNodeRepo, LRepoModel.Name, LBranch, LTag, LPublishedDate, LReleaseType, True);
    end;
  end;
end;

procedure TTreeViewBuilder.ResetColumns;
begin
  FTreeView.Columns.Add;
  FTreeView.Columns[0].Text := RS_Msg_TreeColTitle_RepoBranch;
  FTreeView.Columns.Add;
  FTreeView.Columns[1].Text := RS_Msg_TreeColTitle_Tag;
  FTreeView.Columns.Add;
  FTreeView.Columns[2].Text := RS_Msg_TreeColTitle_ReleaseType;
  FTreeView.Columns.Add;
  FTreeView.Columns[3].Text := RS_Msg_TreeColTitle_PublishedDate;
  FTreeView.Columns.Add;
  FTreeView.Columns[4].Text := RS_Msg_TreeColTitle_NewTag;

  FTreeView.ColumnsAppearance.Stretch := True;
  FTreeView.ColumnsAppearance.StretchAll := True;
end;

procedure TTreeViewBuilder.ResetTree;
begin
  FreeNodeDatas;
  FTreeView.Nodes.ClearAndResetID;
  FTreeView.Columns.ClearAndResetID;
  ResetColumns;
end;

end.
