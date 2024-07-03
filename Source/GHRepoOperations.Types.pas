unit GHRepoOperations.Types;

interface

uses
  System.Generics.Collections;

type
  TGHReleaseType = (grtNull, grtNormal, grtLatest, grtPreRelease);

  TPairGHReleaseType = TPair<TGHReleaseType, string>;

implementation

end.
