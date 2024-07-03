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
  TGHRepoOperationsRT = class
  private
    FGHRepoOpProgressBar: IGHRepoOpProgressBar;
  public
    function ExtractReposInfo(const AOrganization, ATopic: string): TArray<TGHCliRepoModel>;

    property GHRepoOpProgressBar: IGHRepoOpProgressBar read FGHRepoOpProgressBar write FGHRepoOpProgressBar;
  end;

implementation

{ TGHRepoOperationsRT }

function TGHRepoOperationsRT.ExtractReposInfo(const AOrganization, ATopic: string): TArray<TGHCliRepoModel>;
var
  LTempRepoFileName, LTempBranchesFileName, LTempReleaseFileName: string;
  LModel: TGHCliRepoModel;
  I: Integer;
begin
  LTempRepoFileName := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'repoList.txt';
  try
    try
      if TGHCliRepoCommand.RepoListAndLoad(AOrganization, ATopic, LTempRepoFileName, Result) then
      begin
        InitializeGHRepoProgBar(
          GHRepoOpProgressBar,
          Format(RS_Msg_PBar_ExtractRepos, [AOrganization.QuotedString, ATopic.QuotedString]),
          Length(Result)
        );

        for I := 0 to High(Result) do
        begin
          LModel := Result[I];

          GHRepoOpProgressBar.SetMessage(Format(RS_Msg_PBar_ExtractRepoBranches, [LModel.FullName.QuotedString]));

          LTempBranchesFileName := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'branchesList.txt';
          if TGHCliRepoCommand.BranchesListAndLoad(LModel, LTempBranchesFileName) then
          begin
            GHRepoOpProgressBar.SetMessage(Format(RS_Msg_PBar_ExtractRepoTags, [LModel.FullName.QuotedString]));

            LTempReleaseFileName := IncludeTrailingPathDelimiter(TPath.GetTempPath) + 'releaseList.txt';
            TGHCliRepoCommand.ReleaseListAndLoad(LModel, LTempReleaseFileName);
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

    if TFile.Exists(LTempRepoFileName) then
      TFile.Delete(LTempRepoFileName);
    if TFile.Exists(LTempBranchesFileName) then
      TFile.Delete(LTempBranchesFileName);
    if TFile.Exists(LTempReleaseFileName) then
      TFile.Delete(LTempReleaseFileName);
  end;
end;

end.
