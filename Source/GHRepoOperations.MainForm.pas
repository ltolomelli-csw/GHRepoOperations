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
  GHRepoOperations.Messages,
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
  LTempRepoFileName, LTempBranchesFileName, LTempReleaseFileName: string;
  LRepoModels: TArray<TGHCliRepoModel>;
  LModel: TGHCliRepoModel;
  I: Integer;
begin
  LTempRepoFileName := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'repoList.txt';
  try
    LOrg   := cbxOrganizations.Items[cbxOrganizations.ItemIndex];
    LTopic := cbxTopics.Items[cbxTopics.ItemIndex];

    sbRepos.Panels[0].Text := Format(RS_Msg_PBar_ExtractRepos, [LOrg.QuotedString, LTopic.QuotedString]);

    if TGHCliRepoCommand.RepoListAndLoad(LOrg, LTopic, LTempRepoFileName, LRepoModels) then
    begin
      pbLoadData.Step := 1;
      pbLoadData.Min  := 1;
      pbLoadData.Max  := Length(LRepoModels);
      pbLoadData.Visible := True;

      for I := 0 to High(LRepoModels) do
      begin
        LModel := LRepoModels[I];

        sbRepos.Panels[0].Text := Format(RS_Msg_PBar_ExtractRepoBranches, [LModel.FullName.QuotedString]);

        LTempBranchesFileName := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'branchesList.txt';
        if TGHCliRepoCommand.BranchesListAndLoad(LModel, LTempBranchesFileName) then
        begin
          sbRepos.Panels[0].Text := Format(RS_Msg_PBar_ExtractRepoTags, [LModel.FullName.QuotedString]);

          LTempReleaseFileName := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'releaseList.txt';
          TGHCliRepoCommand.ReleaseListAndLoad(LModel, LTempReleaseFileName);
        end;

        pbLoadData.StepIt;
      end;
    end;

    FillTreeView(LRepoModels);
  finally
    pbLoadData.Visible := False;

    sbRepos.Panels[0].Text := '';

    for I := 0 to High(LRepoModels) do
      FreeAndNil(LRepoModels[I]);

    if TFile.Exists(LTempRepoFileName) then
      TFile.Delete(LTempRepoFileName);
    if TFile.Exists(LTempBranchesFileName) then
      TFile.Delete(LTempBranchesFileName);
    if TFile.Exists(LTempReleaseFileName) then
      TFile.Delete(LTempReleaseFileName);
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
