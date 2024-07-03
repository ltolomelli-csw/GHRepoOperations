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
  public
    destructor Destroy; override;

    function FullName: string;
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

{ TTVNodeData }

destructor TTVNodeData.Destroy;
begin
  FreeAndNil(RepoModel);
  FreeAndNil(ReleaseModel);
  inherited;
end;

end.
