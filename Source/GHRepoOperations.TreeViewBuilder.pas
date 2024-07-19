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
  GHRepoOperations.Constants,
  GHRepoOperations.Messages,
  GHRepoOperations.Models,
  GHRepoOperations.Types,
  GHRepoOperations.Utils;

type
  TTreeViewBuilder = class
  private
    FTreeView: TAdvTreeView;
    procedure ResetColumns;
    function GetNewNodeData(const AIsRoot, AShowCheckBox: Boolean; ARepoModel: TGHCliRepoModel;
      const ABranch, ATag, APublishedDate, ANewTag: string; const AReleaseType: TPairGHReleaseType): TTVNodeData;
    procedure FreeNodeDatas;
    procedure FreeTVNodeData(ANode: TAdvTreeViewNode);
    procedure CalculateNewMainTag(const ANewTagOperation: TNewTagOperation; ANode: TAdvTreeViewNode);
    function IncreaseReleaseNumber(const ALatestTag: string; const ANewTagOperation: TNewTagOperation): string;
  public
    constructor Create(ATreeView: TAdvTreeView); reintroduce;
    destructor Destroy; override;

    procedure ResetTree;
    procedure LoadRepos(const ARepoModels: TArray<TGHCliRepoModel>);
    procedure CalculateNewMainTags(const ANewTagOperation: TNewTagOperation; const AOnlySelected: Boolean);

    /// <summary>
    ///   Funziona che ritorna i nodi selezionati dell'albero.
    ///  AFilterSelected consente di applicare una funzione anonima di filtro, impostata dal chiamante
    ///  che accetta in input TTVNodeData (associato al nodo) e ritorna True se il nodo rispetta il filtro,
    ///  False se il nodo non rispetta il filtro
    /// </summary>
    function GetSelectedNodes(const AFilterSelected: TFunc<TTVNodeData, Boolean>; out ANodes: TArray<TAdvTreeViewNode>): Boolean;

    function AddTreeViewNode(AParent: TAdvTreeViewNode; ARepoModel: TGHCliRepoModel;
      const AShowCheckBox: Boolean): TAdvTreeViewNode; overload;
    function AddTreeViewNode(AParent: TAdvTreeViewNode; ARepoModel: TGHCliRepoModel; const ABranch, ATag, APublishedDate, ANewTag: string;
      const AReleaseType: TPairGHReleaseType;
      const AShowCheckBox: Boolean): TAdvTreeViewNode; overload;

    class function GetTVNodeData(ANode: TAdvTreeViewNode; out ANodeData: TTVNodeData): Boolean;

    property TreeView: TAdvTreeView read FTreeView;
  end;

implementation

{ TTreeViewBuilder }

function TTreeViewBuilder.AddTreeViewNode(AParent: TAdvTreeViewNode;
  ARepoModel: TGHCliRepoModel; const AShowCheckBox: Boolean): TAdvTreeViewNode;
begin
  Result := AddTreeViewNode(AParent, ARepoModel, '', '', '', '', TGHReleaseTypeDecode.PairFromEnum(grtNull), AShowCheckBox);
end;

function TTreeViewBuilder.AddTreeViewNode(AParent: TAdvTreeViewNode; ARepoModel: TGHCliRepoModel;
  const ABranch, ATag, APublishedDate, ANewTag: string; const AReleaseType: TPairGHReleaseType;
  const AShowCheckBox: Boolean): TAdvTreeViewNode;
var
  LNodeData: TTVNodeData;
begin
  LNodeData := GetNewNodeData(
                 AParent = nil, AShowCheckBox, ARepoModel, ABranch, ATag,
                 APublishedDate, ANewTag, TGHReleaseTypeDecode.PairFromEnum(grtNormal)
               );
  Result := FTreeView.AddNode(AParent);
  Result.DataObject := LNodeData;

  if LNodeData.ShowCheckBox then
    Result.CheckTypes[C_TREECOL_REPO_BRANCH] := tvntCheckBox
  else
    Result.CheckTypes[C_TREECOL_REPO_BRANCH] := tvntNone;

  Result.Text[C_TREECOL_REPO_BRANCH] := IfThen(ABranch.Trim.IsEmpty, ARepoModel.Name, ABranch);
  Result.Text[C_TREECOL_NEW_TAG] := ANewTag;
  Result.Text[C_TREECOL_TAG] := ATag;

  Result.Text[C_TREECOL_RELEASE_TYPE] := EmptyStr;
  if AReleaseType.Key <> grtNull then
    Result.Text[C_TREECOL_RELEASE_TYPE] := AReleaseType.Value;

  Result.Text[C_TREECOL_RELEASE_DATE] := APublishedDate;
end;

procedure TTreeViewBuilder.CalculateNewMainTag(const ANewTagOperation: TNewTagOperation; ANode: TAdvTreeViewNode);
var
  LNodeData: TTVNodeData;
  LNewTag: string;
begin
  LNodeData := TTVNodeData(ANode.DataObject);
  if ANewTagOperation = ntoClean then
    LNewTag := ''
  else
    LNewTag := IncreaseReleaseNumber(LNodeData.ReleaseModel.Tag, ANewTagOperation);

  LNodeData.ReleaseModel.NewTag := LNewTag;
  ANode.DataObject := LNodeData;
  ANode.Text[C_TREECOL_NEW_TAG] := LNewTag;
end;

procedure TTreeViewBuilder.CalculateNewMainTags(const ANewTagOperation: TNewTagOperation; const AOnlySelected: Boolean);
var
  LNode: TAdvTreeViewNode;
  LFilter: TFunc<TTVNodeData, Boolean>;
  LSelectedNodes: TArray<TAdvTreeViewNode>;
  I: Integer;
begin
  if FTreeView.Nodes.Count = 0 then
    Exit;

  FTreeView.BeginUpdate;
  try
    if AOnlySelected then
    begin
      // solo su quelli selezionati non
      LFilter :=
        function (ATVNodeData: TTVNodeData): Boolean
        begin
          Result := not(ATVNodeData.IsRoot);
        end;

      if not(GetSelectedNodes(LFilter, LSelectedNodes)) then
        Exit;

      for I := 0 to High(LSelectedNodes) do
        CalculateNewMainTag(ANewTagOperation, LSelectedNodes[I]);
    end
    else
    begin
      // ciclo su tutti i nodi
      LNode := FTreeView.GetFirstRootNode;
      repeat
        CalculateNewMainTag(ANewTagOperation, LNode);
        LNode := LNode.GetNext;
      until (LNode = nil); // sono arrivato a fine albero
    end;
  finally
    FTreeView.EndUpdate;
  end;
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

function TTreeViewBuilder.GetNewNodeData(const AIsRoot, AShowCheckBox: Boolean; ARepoModel: TGHCliRepoModel;
  const ABranch, ATag, APublishedDate, ANewTag: string; const AReleaseType: TPairGHReleaseType): TTVNodeData;
begin
  Result := TTVNodeData.Create;
  try
    Result.IsRoot := AIsRoot;
    Result.ShowCheckBox := AShowCheckBox;

    Result.RepoModel := TGHCliRepoModel.Create;
    Result.RepoModel.Organization := ARepoModel.Organization;
    Result.RepoModel.Name := ARepoModel.Name;

    Result.Branch := ABranch;

    Result.ReleaseModel := TGHCliReleaseModel.Create;
    Result.ReleaseModel.Tag := ATag;
    Result.ReleaseModel.ReleaseType := AReleaseType;
    Result.ReleaseModel.PublishedDate := APublishedDate;
    Result.ReleaseModel.NewTag := ANewTag;
  except
    begin
      FreeAndNil(Result);
      raise;
    end;
  end;
end;

function TTreeViewBuilder.GetSelectedNodes(const AFilterSelected: TFunc<TTVNodeData, Boolean>;
  out ANodes: TArray<TAdvTreeViewNode>): Boolean;
var
  LNode: TAdvTreeViewNode;
  LNodeData: TTVNodeData;
  LGoNext, LFilterOK: Boolean;
begin
  SetLength(ANodes, 0);
  if FTreeView.Nodes.Count = 0 then
    Exit( False );

  LNode := FTreeView.GetFirstRootNode;
  repeat
    LGoNext := True;
    LFilterOK := True;
    // se il nodo è da escludere rimane comunque checkato
    if LNode.Checked[0] then
    begin
      if GetTVNodeData(LNode, LNodeData) then
      begin
        if Assigned(AFilterSelected) then
          LFilterOK := AFilterSelected(LNodeData);

        if LFilterOK then
        begin
          // se il nodo considerato è checkato passo al successivo nodo considerando l'ordine numerico
          // (quello che effettivamente vedo come nodo successivo, indipendentemente dalla profondità)
          SetLength(ANodes, Length(ANodes) + 1);
          ANodes[High(ANodes)] := LNode;

          // siccome mi sposto già al prossimo, faccio in modo che il comando sotto non lo faccia
          LGoNext := False;
          LNode := LNode.GetNext
        end;
      end;
    end;

    if LGoNext then
      LNode := LNode.GetNext;
  until (LNode = nil); // sono arrivato a fine albero
  Result := Length(ANodes) > 0;
end;

class function TTreeViewBuilder.GetTVNodeData(ANode: TAdvTreeViewNode; out ANodeData: TTVNodeData): Boolean;
begin
  ANodeData := nil;
  Result := ANode.DataObject is TTVNodeData;
  if Result then
    ANodeData := TTVNodeData(ANode.DataObject);
end;

function TTreeViewBuilder.IncreaseReleaseNumber(const ALatestTag: string; const ANewTagOperation: TNewTagOperation): string;
var
  LArr: TArray<string>;
  LTmp: Integer;
  LNumberIndex: Integer;
begin
  Result := '';
  if ALatestTag.Trim.IsEmpty then
    Exit;

  LArr := ALatestTag.Split(['.']);
  if Length(LArr) = 0 then
    Exit;

  case ANewTagOperation of
    ntoIncreaseMinor: LNumberIndex := 2;
    ntoIncreaseFix:   LNumberIndex := 3;
    else
      Exit;
  end;

  LTmp := LArr[LNumberIndex].ToInteger;
  Inc(LTmp);
  LArr[LNumberIndex] := LTmp.ToString;
  // in questi casi devo azzerare anche l'ultimo numero
  if ANewTagOperation = ntoIncreaseMinor then
    LArr[High(LArr)] := '0';

  Result := TGHMiscUtils.ConcatStrings(LArr, '.');
end;

procedure TTreeViewBuilder.LoadRepos(const ARepoModels: TArray<TGHCliRepoModel>);
var
  I, J: Integer;
  LBranch, LTag, LPublishedDate, LNewTag: string;
  LReleaseType: TPairGHReleaseType;
  LRepoModel: TGHCliRepoModel;
  LNodeRepo: TAdvTreeViewNode;
begin
  ResetTree;

  for I := 0 to High(ARepoModels) do
  begin
    LRepoModel := ARepoModels[I];

    LNodeRepo := AddTreeViewNode(nil, LRepoModel, True);
    for J := 0 to High(LRepoModel.Branches) do
    begin
      LBranch := LRepoModel.Branches[J];

      if SameText(LBranch, 'main') and (Length(LRepoModel.Tags) > 0) then
      begin
        // devo considerare sempre il Model in posizione 0 perchè sono ordinati in
        // modo decrescente (come su GitHub) e mi interessano quei valori
        LTag := LRepoModel.Tags[0].Tag;
        LReleaseType := LRepoModel.Tags[0].ReleaseType;
        LPublishedDate := LRepoModel.Tags[0].PublishedDate;
        LNewTag := LRepoModel.Tags[0].NewTag;
      end
      else
      begin
        LTag := EmptyStr;
        LReleaseType := TGHReleaseTypeDecode.PairFromEnum(grtNull);
        LPublishedDate := '';
        LNewTag := '';
      end;

      AddTreeViewNode(LNodeRepo, LRepoModel, LBranch, LTag, LPublishedDate, LNewTag, LReleaseType, True);
    end;
  end;
end;

procedure TTreeViewBuilder.ResetColumns;
begin
  FTreeView.Columns.Add;
  FTreeView.Columns[C_TREECOL_REPO_BRANCH].Text := RS_Msg_TreeColTitle_RepoBranch;
  FTreeView.Columns.Add;
  FTreeView.Columns[C_TREECOL_NEW_TAG].Text := RS_Msg_TreeColTitle_NewTag;
  FTreeView.Columns.Add;
  FTreeView.Columns[C_TREECOL_TAG].Text := RS_Msg_TreeColTitle_Tag;
  FTreeView.Columns.Add;
  FTreeView.Columns[C_TREECOL_RELEASE_TYPE].Text := RS_Msg_TreeColTitle_ReleaseType;
  FTreeView.Columns.Add;
  FTreeView.Columns[C_TREECOL_RELEASE_DATE].Text := RS_Msg_TreeColTitle_PublishedDate;

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
