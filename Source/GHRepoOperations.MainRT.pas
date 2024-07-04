unit GHRepoOperations.MainRT;

interface

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  System.StrUtils,
  GHRepoOperations.GHCommands,
  GHRepoOperations.Messages,
  GHRepoOperations.ProgBar,
  GHRepoOperations.Models,
  GHRepoOperations.TreeViewBuilder,
  GHRepoOperations.Types,
  GHRepoOperations.Utils;

type
  TGHRepoOperationsRT = class(TThread)
  private
    FThreadOperation: TThreadOperation;
    FGHRepoOpProgressBar: IGHRepoOpProgressBar;
    FOrganization: string;
    FTopic: string;
    FRepoModels: TArray<TGHCliRepoModel>;
    FTVNodeData: TTVNodeData;
    function ExtractReposInfo(const AOrganization, ATopic: string): TArray<TGHCliRepoModel>; overload;
    function ExtractReposInfo: TArray<TGHCliRepoModel>; overload;
    procedure PushNewTag;
  public
    destructor Destroy; override;

    procedure Execute; override;

    property ThreadOperation: TThreadOperation read FThreadOperation write FThreadOperation;
    property GHRepoOpProgressBar: IGHRepoOpProgressBar read FGHRepoOpProgressBar write FGHRepoOpProgressBar;
    property Organization: string read FOrganization write FOrganization;
    property Topic: string read FTopic write FTopic;
    property RepoModels: TArray<TGHCliRepoModel> read FRepoModels;
    property TVNodeData: TTVNodeData read FTVNodeData write FTVNodeData;
  end;

implementation

{ TGHRepoOperationsRT }

destructor TGHRepoOperationsRT.Destroy;
var
  I: Integer;
begin
  for I := 0 to High(RepoModels) do
    FreeAndNil(RepoModels[I]);
  inherited;
end;

procedure TGHRepoOperationsRT.Execute;
begin
  inherited;
  case ThreadOperation of
    toRepoExtraction:
      begin
        FreeOnTerminate := True;
        FRepoModels := ExtractReposInfo;
      end;
    toTagPush:
      begin
        FreeOnTerminate := False;
        PushNewTag;
      end
    else
      Exit;
  end;
end;

function TGHRepoOperationsRT.ExtractReposInfo(const AOrganization, ATopic: string): TArray<TGHCliRepoModel>;
var
  LModel: TGHCliRepoModel;
  I: Integer;
begin
  try
    try
      if TGHCliRepoCommand.RepoListAndLoad(AOrganization, ATopic, Result) then
      begin
        GHRepoOpProgressBar.Max(Length(Result));
        GHRepoOpProgressBar.SetMessage(Format(RS_Msg_PBar_ExtractRepos, [AOrganization.QuotedString, ATopic.QuotedString]));

        for I := 0 to High(Result) do
        begin
          LModel := Result[I];

          GHRepoOpProgressBar.SetMessage(Format(RS_Msg_PBar_ExtractRepoBranches, [LModel.FullName.QuotedString]));

          if TGHCliRepoCommand.BranchesListAndLoad(LModel.FullName, LModel.Branches) then
          begin
            GHRepoOpProgressBar.SetMessage(Format(RS_Msg_PBar_ExtractRepoTags, [LModel.FullName.QuotedString]));
            TGHCliRepoCommand.ReleaseListAndLoad(LModel.FullName, LModel.Tags);
          end;

          GHRepoOpProgressBar.Step;
        end;
      end;
    except
      begin
        for I := 0 to High(Result) do
          FreeAndNil(Result[I]);

        raise;
      end;
    end;
  finally
    GHRepoOpProgressBar.Hide(True);
  end;
end;

function TGHRepoOperationsRT.ExtractReposInfo: TArray<TGHCliRepoModel>;
begin
  Result := ExtractReposInfo(Organization, Topic);
end;

procedure TGHRepoOperationsRT.PushNewTag;
var
  LTempPath, LRepoPath: string;
begin
  try
  //  LTempPath := IncludeTrailingPathDelimiter(TPath.GetTempPath);
    LTempPath := 'c:\scambio\_test\GitHub\CLI\';

    if TGHCliRepoCommand.RepoClone(TVNodeData.RepoModel, LRepoPath, LTempPath) then
      if TGHCliRepoCommand.RepoBranchCheckout(TVNodeData.Branch, LRepoPath) then
        if TGHCliRepoCommand.RepoCreateNewTag(TVNodeData.ReleaseModel.NewTag, LRepoPath) then
          TGHCliRepoCommand.RepoPushTag(LRepoPath);
  finally
    if DirectoryExists(LRepoPath) then
      TDirectory.Delete(LRepoPath, True);
  end;
end;

end.
