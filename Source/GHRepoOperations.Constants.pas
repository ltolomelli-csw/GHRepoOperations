unit GHRepoOperations.Constants;

interface

const
  C_RELEASETYPE_NULL = 'null'; // non esiste su GitHub, usata per comodità interna
  C_RELEASETYPE_LATEST = 'Latest';
  C_RELEASETYPE_PRERELEASE = 'Pre-release';

  C_TREECOL_REPO_BRANCH = 0;
  C_TREECOL_NEW_TAG = 1;
  C_TREECOL_TAG = 2;
  C_TREECOL_RELEASE_TYPE = 3;
  C_TREECOL_RELEASE_DATE = 4;

implementation

end.
