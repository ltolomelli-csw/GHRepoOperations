unit GHRepoOperations.Types;

interface

uses
  System.Generics.Collections;

type
  TGHReleaseType = (grtNull, grtNormal, grtLatest, grtPreRelease);
  TNewTagOperation = (ntoNull, ntoIncreaseMinor, ntoIncreaseFix);

  TPairGHReleaseType = TPair<TGHReleaseType, string>;

implementation

end.
