unit GHRepoOperations.GHCommands;

interface

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  System.Classes,
  System.IOUtils,
  System.StrUtils,
  System.SysUtils,
  System.Generics.Collections,
  GHRepoOperations.Models;

type
  TGHCliRepoCommand = class
  private
    class function GetCmdOutput(const ACommandLine, AWorkDir: string): string; overload;
    class function GetCmdOutput(const ACommandLine, AWorkDir: string; const ADelimiter: Char;
      out ARes: TStringList): Boolean; overload;

    class function LoadRepoNamesInModel(const ASL: TStringList): TArray<TGHCliRepoModel>;
    class function LoadRepoReleasesInModel(const ASL: TStringList): TArray<TGHCliReleaseModel>;
    class function LoadRepoBranchesInModel(const ASL: TStringList): TArray<string>;
  public
    class function RepoListAndLoad(const AOrganization, ATopic: string; out ARepoModels: TArray<TGHCliRepoModel>): Boolean;
    class function BranchesListAndLoad(const ARepoFullName: string; out ABranches: TArray<string>): Boolean; overload;
    class function ReleaseListAndLoad(const ARepoFullName: string; out ATags: TArray<TGHCliReleaseModel>): Boolean;
  end;

implementation

uses
  GHRepoOperations.Utils;

{ TGHCliRepoCommand }

class function TGHCliRepoCommand.ReleaseListAndLoad(const ARepoFullName: string;
  out ATags: TArray<TGHCliReleaseModel>): Boolean;
var
  LCMD: string;
  LSL: TStringList;
begin
  Result := False;
  LCMD := 'gh release list -R ' + ARepoFullName;
  try
    // delimito con il solo carattere CR per avere ogni riga su un elemento della StringList
    if GetCmdOutput(LCMD, IncludeTrailingPathDelimiter(TPath.GetTempPath), #10, LSL) then
    begin
      ATags := LoadRepoReleasesInModel(LSL);
      Result := Length(ATags) > 0;
    end;
  finally
    FreeAndNil(LSL);
  end;
end;

class function TGHCliRepoCommand.RepoListAndLoad(const AOrganization, ATopic: string;
  out ARepoModels: TArray<TGHCliRepoModel>): Boolean;
var
  LCMD: string;
  LSL: TStringList;
begin
  Result := False;
  LCMD := 'gh repo list ' + AOrganization + ' -L 100 --topic ' + ATopic;
  try
    // delimito con il solo carattere CR per avere ogni riga su un elemento della StringList
    if GetCmdOutput(LCMD, IncludeTrailingPathDelimiter(TPath.GetTempPath), #10, LSL) then
    begin
      ARepoModels := LoadRepoNamesInModel(LSL);
      Result := Length(ARepoModels) > 0;
    end;
  finally
    FreeAndNil(LSL);
  end;
end;

class function TGHCliRepoCommand.BranchesListAndLoad(const ARepoFullName: string; out ABranches: TArray<string>): Boolean;
var
  LCMD: string;
  LSL: TStringList;
begin
  Result := False;
  LCMD := 'gh api repos/' + ARepoFullName + '/branches -q ".[].name" ';
  try
    // delimito con il solo carattere CR per avere ogni riga su un elemento della StringList
    if GetCmdOutput(LCMD, IncludeTrailingPathDelimiter(TPath.GetTempPath), #10, LSL) then
    begin
      ABranches := LoadRepoBranchesInModel(LSL);
      Result := Length(ABranches) > 0;
    end;
  finally
    FreeAndNil(LSL);
  end;
end;

class function TGHCliRepoCommand.GetCmdOutput(const ACommandLine, AWorkDir: string;
  const ADelimiter: Char; out ARes: TStringList): Boolean;
var
  LCMDRes: string;
begin
  LCMDRes := GetCmdOutput(ACommandLine, AWorkDir);
  ARes := TStringList.Create;
  try
    ARes.StrictDelimiter := True;
    ARes.Delimiter := ADelimiter;
    ARes.DelimitedText := LCMDRes;
    // Utilizzando GetCmdOutput, la StringList che valorizzo
    // ha un elemento in più vuoto che elimino per comodità
    if (ARes.Count > 0) and (ARes[ARes.Count -1].Trim.IsEmpty) then
      ARes.Delete(ARes.Count - 1);
  except
    begin
      FreeAndNil(ARes);
      raise;
    end;
  end;
  Result := ARes.Count > 0;
end;

class function TGHCliRepoCommand.GetCmdOutput(const ACommandLine, AWorkDir: string): string;
var
  LSA: TSecurityAttributes;
  LSI: TStartupInfo;
  LPI: TProcessInformation;
  LStdOutPipeRead, StdOutPipeWrite: THandle;
  LWasOK: Boolean;
  LBuffer: array[0..255] of AnsiChar;
  LBytesRead: Cardinal;
  LWorkDir: string;
  LHandle: Boolean;
begin
  Result := '';
  LSA.nLength := SizeOf(LSA);
  LSA.bInheritHandle := True;
  LSA.lpSecurityDescriptor := nil;
  CreatePipe(LStdOutPipeRead, StdOutPipeWrite, @LSA, 0);
  try
    FillChar(LSI, SizeOf(LSI), 0);
    LSI.cb := SizeOf(LSI);
    LSI.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
    LSI.wShowWindow := SW_HIDE;
    LSI.hStdInput := GetStdHandle(STD_INPUT_HANDLE); // don't redirect stdin
    LSI.hStdOutput := StdOutPipeWrite;
    LSI.hStdError := StdOutPipeWrite;

    LWorkDir := AWorkDir;
    LHandle := CreateProcess(nil, PChar('cmd.exe /C ' + ACommandLine),
                            nil, nil, True, 0, nil,
                            PChar(LWorkDir), LSI, LPI);
    CloseHandle(StdOutPipeWrite);
    if LHandle then
    begin
      try
        repeat
          LWasOK := ReadFile(LStdOutPipeRead, LBuffer, 255, LBytesRead, nil);
          if LBytesRead > 0 then
          begin
            LBuffer[LBytesRead] := #0;
            Result := Result + string(LBuffer); // altrimenti warning di conversione implicita
          end;
        until not LWasOK or (LBytesRead = 0);
        WaitForSingleObject(LPI.hProcess, INFINITE);
      finally
        CloseHandle(LPI.hThread);
        CloseHandle(LPI.hProcess);
      end;
    end;
  finally
    CloseHandle(LStdOutPipeRead);
  end;
end;

class function TGHCliRepoCommand.LoadRepoBranchesInModel(const ASL: TStringList): TArray<string>;
var
  I: Integer;
begin
  SetLength(Result, 0);
  for I := 0 to ASL.Count -1 do
  begin
    if ASL[I].StartsWith('6.') or SameText(ASL[I], 'main') then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := ASL[I];
    end;
  end;
end;

class function TGHCliRepoCommand.LoadRepoNamesInModel(const ASL: TStringList): TArray<TGHCliRepoModel>;
var
  I: Integer;
  LModel: TGHCliRepoModel;
  LArr, LArrName: TArray<string>;
begin
  SetLength(Result, ASL.Count);

  for I := 0 to ASL.Count -1 do
  begin
    LArr := ASL[I].Split([#9]);
    LArrName := LArr[0].Split(['/']);

    LModel := TGHCliRepoModel.Create;
    LModel.Organization := LArrName[0];
    LModel.Name := LArrName[1];

    Result[I] := LModel;
  end;
end;

class function TGHCliRepoCommand.LoadRepoReleasesInModel(const ASL: TStringList): TArray<TGHCliReleaseModel>;
var
  I: Integer;
  LModel: TGHCliReleaseModel;
  LArr: TArray<string>;
begin
  SetLength(Result, ASL.Count);

  for I := 0 to ASL.Count -1 do
  begin
    LArr := ASL[I].Split([#9]);

    LModel := TGHCliReleaseModel.Create;
    LModel.Tag := LArr[0];
    LModel.ReleaseType := TGHReleaseTypeDecode.PairFromDescr(LArr[1]);
    LModel.PublishedDate := LArr[3];

    Result[I] := LModel;
  end;
end;

end.
