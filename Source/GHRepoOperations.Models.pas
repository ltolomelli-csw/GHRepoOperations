unit GHRepoOperations.Models;

interface

uses
  System.SysUtils,
  GHRepoOperations.Types;

type
  TGHCliReleaseModel = class
    Tag: string;
    NewTag: string;
    ReleaseType: TPairGHReleaseType;
    PublishedDate: string;
  end;

  TGHCliRepoModel = class
    Organization: string;
    Name: string;
    Branches: TArray<string>;
    Tags: TArray<TGHCliReleaseModel>;
  private
    function GetRepoMainLink: string;
  public
    destructor Destroy; override;

    function FullName: string;
    function GetLink(const ABranchName: string = ''): string;
    function GetReleasesLink: string;
    function GetTagsLink: string;
  end;

  TTVNodeData = class
    IsRoot: Boolean;
    ShowCheckBox: Boolean;
    RepoModel: TGHCliRepoModel;
    Branch: string;
    ReleaseModel: TGHCliReleaseModel;
  public
    destructor Destroy; override;
  end;

implementation

{ TGHCliRepoModel }

destructor TGHCliRepoModel.Destroy;
var
  I: Integer;
begin
  for I := 0 to High(Tags) do
    FreeAndNil(Tags[I]);

  inherited;
end;

function TGHCliRepoModel.FullName: string;
begin
  Result := Organization + '/' + Name;
end;

function TGHCliRepoModel.GetLink(const ABranchName: string): string;
begin
  Result := GetRepoMainLink;
  if not(ABranchName.Trim.IsEmpty) and not(SameText(ABranchName, 'main')) then
    Result := Result + '/tree/' + ABranchName.Trim;
end;

function TGHCliRepoModel.GetReleasesLink: string;
begin
  Result := GetRepoMainLink + '/releases';
end;

function TGHCliRepoModel.GetRepoMainLink: string;
begin
  Result := 'https://github.com/' + FullName;
end;

function TGHCliRepoModel.GetTagsLink: string;
begin
  Result := GetRepoMainLink + '/tags';
end;

{ TTVNodeData }

destructor TTVNodeData.Destroy;
begin
  FreeAndNil(RepoModel);
  FreeAndNil(ReleaseModel);
  inherited;
end;

end.
