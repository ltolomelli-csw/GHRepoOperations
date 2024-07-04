unit GHRepoOperations.Messages;

interface

resourcestring
  RS_Msg_TreeColTitle_RepoBranch = 'Repository/Branch';
  RS_Msg_TreeColTitle_Tag = 'Tag';
  RS_Msg_TreeColTitle_ReleaseType = 'Tipo release';
  RS_Msg_TreeColTitle_PublishedDate = 'Data pubblicazione';
  RS_Msg_TreeColTitle_NewTag = 'Nuovo Tag';

  RS_Msg_PBar_ExtractRepos = 'Estrazione repository dell''organizzazione %s con topic %s';
  RS_Msg_PBar_ExtractRepoBranches = 'Estrazione branch repository %s';
  RS_Msg_PBar_ExtractRepoTags = 'Estrazione tag repository %s';

  RS_Msg_PBar_CloneRepo = 'Clonazione repository %s';
  RS_Msg_PBar_CheckoutBranch = 'Checkout branch %s';
  RS_Msg_PBar_CreateNewTag = 'Creazione nuovo tag %s';
  RS_Msg_PBar_PushTag = 'Push nuovo tag %s';

  RS_Err_DescrReleaseTypeNotValid = 'Descrizione %s non gestita';
  RS_Err_EnumReleaseTypeNotValid = 'Enumerato %s non gestito';

implementation

end.
