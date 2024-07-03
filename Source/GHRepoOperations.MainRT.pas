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
    function ExtractReposInfo(const AOrganization, ATopic: string): TArray<TGHCliRepoModel>; overload;
    function ExtractReposInfo: TArray<TGHCliRepoModel>; overload;
  public
    destructor Destroy; override;

    procedure Execute; override;

    property ThreadOperation: TThreadOperation read FThreadOperation write FThreadOperation;
    property GHRepoOpProgressBar: IGHRepoOpProgressBar read FGHRepoOpProgressBar write FGHRepoOpProgressBar;
    property Organization: string read FOrganization write FOrganization;
    property Topic: string read FTopic write FTopic;
    property RepoModels: TArray<TGHCliRepoModel> read FRepoModels;
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
  FreeOnTerminate := True;
  case ThreadOperation of
    toRepoExtraction:
      FRepoModels := ExtractReposInfo;
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
        InitializeGHRepoProgBar(
          GHRepoOpProgressBar,
          Format(RS_Msg_PBar_ExtractRepos, [AOrganization.QuotedString, ATopic.QuotedString]),
          Length(Result)
        );

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

end.
