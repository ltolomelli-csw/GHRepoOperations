unit GHRepoOperations.MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, Vcl.StdCtrls,
  Vcl.Grids, Vcl.DBGrids,
  GHRepoOperations.Models, AdvCustomControl, AdvTreeViewBase, AdvTreeViewData,
  AdvCustomTreeView, AdvTreeView, Vcl.ComCtrls,
  System.Generics.Collections,
  System.IOUtils,
  System.Threading,
  GHRepoOperations.GHCommands,
  GHRepoOperations.MainRT,
  GHRepoOperations.Messages,
  GHRepoOperations.ProgBar,
  GHRepoOperations.TreeViewBuilder,
  GHRepoOperations.Types,
  GHRepoOperations.Utils;

type
  TFrmMain = class(TForm)
    pnlAll: TPanel;
    pnlTop: TPanel;
    pnlMain: TPanel;
    tvMain: TAdvTreeView;
    pbLoadData: TProgressBar;
    sbRepos: TStatusBar;
    pnlMainOptions: TPanel;
    cbxOrganizations: TComboBox;
    cbxTopics: TComboBox;
    lblOrganizations: TLabel;
    lblTopics: TLabel;
    pcFunctions: TPageControl;
    tbsPushNewTag: TTabSheet;
    rgNewMainTag: TRadioGroup;
    btnRepoList: TButton;
    btnExecuteFunction: TButton;
    procedure btnRepoListClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tvMainAfterUnCheckNode(Sender: TObject;
      ANode: TAdvTreeViewVirtualNode; AColumn: Integer);
    procedure tvMainAfterCheckNode(Sender: TObject;
      ANode: TAdvTreeViewVirtualNode; AColumn: Integer);
    procedure rgNewMainTagClick(Sender: TObject);
    procedure btnExecuteFunctionClick(Sender: TObject);
  private
    FMainRT: TGHRepoOperationsRT;
    FTreeViewBuilder: TTreeViewBuilder;
    procedure FillTreeView(const ARepoModels: TArray<TGHCliRepoModel>);
    procedure OnTerminateFillTreeView(Sender: TObject);
    procedure EnableBtnRepoList;
    procedure EnableRadioButton;
    function GetNewTagOperationFromSelection: TNewTagOperation;
    procedure InitComponents;

    procedure InitCompPushNewTag;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.btnExecuteFunctionClick(Sender: TObject);
var
  LSelectedNodes: TArray<TAdvTreeViewNode>;
  I: Integer;
  LNode: TAdvTreeViewNode;
  LNodeData: TTVNodeData;
  LFilter: TFunc<TTVNodeData, Boolean>;
  LMainRT: TGHRepoOperationsRT;
begin
  LFilter :=
    function (ATVNodeData: TTVNodeData): Boolean
    begin
      Result := not(ATVNodeData.IsRoot);
    end;

  if not(FTreeViewBuilder.GetSelectedNodes(LFilter, LSelectedNodes)) then
    Exit;

  {TODO -o04/07/2024 -c : Sicuramente migliorabile, da capire come}
  try
    for I := 0 to High(LSelectedNodes) do
    begin
      LNode := LSelectedNodes[I];
      if FTreeViewBuilder.GetTVNodeData(LNode, LNodeData) then
      begin
        LMainRT := TGHRepoOperationsRT.Create(True);
        LMainRT.TVNodeData := LNodeData;
        LMainRT.ThreadOperation := TThreadOperation.toTagPush; {TODO -o04/07/2024 -c : recuperare in base al valore selezionato}
        LMainRT.GHRepoOpProgressBar := TGHRepoOpProgressBar.Create(pbLoadData, sbRepos.Panels[0]);
        LMainRT.Start;
      end;
    end;
  finally
    TGHVCLUtils.EnableControlsAndChilds(pnlTop, True, True);
  end;
end;

procedure TFrmMain.btnRepoListClick(Sender: TObject);
var
  LOrg, LTopic: string;
begin
  LOrg   := cbxOrganizations.Items[cbxOrganizations.ItemIndex];
  LTopic := cbxTopics.Items[cbxTopics.ItemIndex];

  // utilizzo una variabile globale alla classe così da farci riferimento
  // nell'evento OnTerminate
  FMainRT := TGHRepoOperationsRT.Create(True);
  FMainRT.ThreadOperation := TThreadOperation.toRepoExtraction;
  FMainRT.GHRepoOpProgressBar := TGHRepoOpProgressBar.Create(pbLoadData, sbRepos.Panels[0]);
  FMainRT.Organization := LOrg;
  FMainRT.Topic := LTopic;
  FMainRT.OnTerminate := OnTerminateFillTreeView;

  // riabilito i controlli nell'OnTerminate
  TGHVCLUtils.EnableControlsAndChilds(pnlTop, False, True);
  FMainRT.Start;
end;

constructor TFrmMain.Create(AOwner: TComponent);
begin
  inherited;
  FTreeViewBuilder := TTreeViewBuilder.Create(tvMain);
end;

destructor TFrmMain.Destroy;
begin
  FreeAndNil(FTreeViewBuilder);
  inherited;
end;

procedure TFrmMain.EnableBtnRepoList;
begin
  btnRepoList.Enabled := True;
end;

procedure TFrmMain.EnableRadioButton;
begin
  rgNewMainTag.Enabled := tvMain.Nodes.Count > 0;
end;

procedure TFrmMain.OnTerminateFillTreeView(Sender: TObject);
begin
  try
    FillTreeView( FMainRT.RepoModels );
  finally
    TGHVCLUtils.EnableControlsAndChilds(pnlTop, True, True);
    EnableRadioButton;
  end;
end;

procedure TFrmMain.rgNewMainTagClick(Sender: TObject);
begin
  FTreeViewBuilder.CalculateNewMainTags( GetNewTagOperationFromSelection );
end;

procedure TFrmMain.FillTreeView(const ARepoModels: TArray<TGHCliRepoModel>);
begin
  tvMain.BeginUpdate;
  try
    FTreeViewBuilder.LoadRepos(ARepoModels);
  finally
    tvMain.EndUpdate;
    tvMain.ExpandAll;
  end;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  InitComponents;
end;

function TFrmMain.GetNewTagOperationFromSelection: TNewTagOperation;
begin
  case rgNewMainTag.ItemIndex of
    0: Result := ntoIncreaseMinor;
    1: Result := ntoIncreaseFix;
    else
      Result := ntoNull;
  end;
end;

procedure TFrmMain.InitComponents;
begin
  cbxOrganizations.ItemIndex := 0;
  cbxTopics.ItemIndex := 0;

  InitCompPushNewTag;

  EnableBtnRepoList;
  EnableRadioButton;

  sbRepos.Panels[0].Width := sbRepos.Width;
end;

procedure TFrmMain.InitCompPushNewTag;
begin
  rgNewMainTag.ItemIndex := -1;
end;

procedure TFrmMain.tvMainAfterCheckNode(Sender: TObject;
  ANode: TAdvTreeViewVirtualNode; AColumn: Integer);
var
  LNodeData: TTVNodeData;
begin
  if TTreeViewBuilder.GetTVNodeData(ANode.Node, LNodeData) then
    if LNodeData.IsRoot then
      tvMain.CheckNode(ANode.Node, 0, True);
end;

procedure TFrmMain.tvMainAfterUnCheckNode(Sender: TObject;
  ANode: TAdvTreeViewVirtualNode; AColumn: Integer);
var
  LNodeData: TTVNodeData;
begin
  if TTreeViewBuilder.GetTVNodeData(ANode.Node, LNodeData) then
    if LNodeData.IsRoot then
      tvMain.UnCheckNode(ANode.Node, 0, True);
end;

end.
