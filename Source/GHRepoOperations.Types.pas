unit GHRepoOperations.Types;

interface

uses
  System.Generics.Collections;

type
  TThreadOperation = (toNull, toRepoExtraction, toTagPush);
  TGHReleaseType = (grtNull, grtNormal, grtLatest, grtPreRelease);
  TNewTagOperation = (ntoNull, ntoClean, ntoIncreaseMinor, ntoIncreaseFix);

  TPairGHReleaseType = TPair<TGHReleaseType, string>;

implementation

end.
