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
  GHRepoOperations.TreeViewBuilder;

type
  TFrmMain = class(TForm)
    pnlAll: TPanel;
    pnlTop: TPanel;
    pnlMain: TPanel;
    cbxOrganizations: TComboBox;
    btnRepoList: TButton;
    lblOrganizations: TLabel;
    lblTopics: TLabel;
    cbxTopics: TComboBox;
    tvMain: TAdvTreeView;
    pbLoadData: TProgressBar;
    sbRepos: TStatusBar;
    procedure btnRepoListClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tvMainAfterUnCheckNode(Sender: TObject;
      ANode: TAdvTreeViewVirtualNode; AColumn: Integer);
    procedure tvMainAfterCheckNode(Sender: TObject;
      ANode: TAdvTreeViewVirtualNode; AColumn: Integer);
  private
    FTreeViewBuilder: TTreeViewBuilder;
    procedure FillTreeView(const ARepoModels: TArray<TGHCliRepoModel>);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.btnRepoListClick(Sender: TObject);
var
  LOrg, LTopic: string;
  LMainRT: TGHRepoOperationsRT;
  LRepoModels: TArray<TGHCliRepoModel>;
  I: Integer;
begin
  LOrg   := cbxOrganizations.Items[cbxOrganizations.ItemIndex];
  LTopic := cbxTopics.Items[cbxTopics.ItemIndex];

  LMainRT := TGHRepoOperationsRT.Create;
  try
    LMainRT.GHRepoOpProgressBar := TGHRepoOpProgressBar.Create(pbLoadData, sbRepos.Panels[0]);
    LRepoModels := LMainRT.ExtractReposInfo(LOrg, LTopic);
    try
      FillTreeView(LRepoModels);
    finally
      for I := 0 to High(LRepoModels) do
        FreeAndNil(LRepoModels[I]);
    end;
  finally
    FreeAndNil(LMainRT);
  end;
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

procedure TFrmMain.FillTreeView(const ARepoModels: TArray<TGHCliRepoModel>);
begin
  tvMain.BeginUpdate;
  try
    FTreeViewBuilder.LoadRepos(ARepoModels);
  finally
    tvMain.EndUpdate;
    tvMain.ExpandAll;
  end;
//    tvMain.Refresh;
//    LoadRepoTree(ARepoModels);
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  cbxOrganizations.ItemIndex := 0;
  cbxTopics.ItemIndex := 0;
  sbRepos.Panels[0].Width := sbRepos.Width;
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
