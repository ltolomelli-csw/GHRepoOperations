unit GHRepoOperations.Types;

interface

uses
  System.Generics.Collections;

type
  TThreadOperation = (toNull, toRepoExtraction, toTagPush);
  TGHReleaseType = (grtNull, grtNormal, grtLatest, grtPreRelease);
  TNewTagOperation = (ntoNull, ntoClean, ntoIncreaseMinor, ntoIncreaseFix);
  TRepoLinkType = (rltNull, rltMain, rltBranch, rltReleases, rltTags);

  TPairGHReleaseType = TPair<TGHReleaseType, string>;

implementation

end.
