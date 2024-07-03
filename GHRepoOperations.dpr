program GHRepoOperations;

uses
  Vcl.Forms,
  GHRepoOperations.MainForm in 'Source\GHRepoOperations.MainForm.pas' {FrmMain},
  GHRepoOperations.GHCommands in 'Source\GHRepoOperations.GHCommands.pas',
  GHRepoOperations.Models in 'Source\GHRepoOperations.Models.pas',
  GHRepoOperations.Types in 'Source\GHRepoOperations.Types.pas',
  GHRepoOperations.Utils in 'Source\GHRepoOperations.Utils.pas',
  GHRepoOperations.Constants in 'Source\GHRepoOperations.Constants.pas',
  GHRepoOperations.TreeViewBuilder in 'Source\GHRepoOperations.TreeViewBuilder.pas',
  GHRepoOperations.Messages in 'Source\GHRepoOperations.Messages.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.

