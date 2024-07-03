unit GHRepoOperations.GHCommands;

interface

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  System.Classes,
  System.StrUtils,
  System.SysUtils,
  System.Generics.Collections,
  GHRepoOperations.Models;

function CSExec(Fn, Pa: string; Sw: Word; WaitExec: Boolean): DWord;

type
  TGHCliRepoCommand = class
  private
    class function LoadRepoNamesInModel(const ATempFileName: string): TArray<TGHCliRepoModel>;
    class function LoadRepoReleasesInModel(const ATempFileName: string): TArray<TGHCliTagModel>;
    class function LoadRepoBranchesInModel(const ATempFileName: string): TArray<string>;
  public
    class function RepoList(const AOrganization, ATopic: string; const ATempFileName: string): Boolean;
    class function RepoListAndLoad(const AOrganization, ATopic: string; const ATempFileName: string;
      out ARepoModels: TArray<TGHCliRepoModel>): Boolean;

    class function ReleaseList(const ARepoFullName, ATempFileName: string): Boolean; overload;
    class function ReleaseListAndLoad(const ARepoFullName, ATempFileName: string): TArray<TGHCliTagModel>; overload;

    class function ReleaseList(var ARepoModel: TGHCliRepoModel; const ATempFileName: string): Boolean; overload;
    class function ReleaseListAndLoad(var ARepoModel: TGHCliRepoModel; const ATempFileName: string): Boolean; overload;
    class function ReleaseListAndLoad2(var ARepoModel: TGHCliRepoModel; const ATempFileName: string): TArray<TGHCliTagModel>;

    class function BranchesList(const ARepoFullName, ATempFileName: string): Boolean; overload;
    class function BranchesListAndLoad(const ARepoFullName, ATempFileName: string): TArray<string>; overload;
    class function BranchesList(var ARepoModel: TGHCliRepoModel; const ATempFileName: string): Boolean; overload;
    class function BranchesListAndLoad(var ARepoModel: TGHCliRepoModel; const ATempFileName: string): Boolean; overload;
  end;

implementation

uses
  GHRepoOperations.Utils;

{ TGHCliRepoCommand }

class function TGHCliRepoCommand.LoadRepoReleasesInModel(const ATempFileName: string): TArray<TGHCliTagModel>;
var
  LSL: TStringList;
  LArr: TArray<string>;
  I: Integer;
  LModel: TGHCliTagModel;
begin
  LSL := TStringList.Create;
  try
    try
      LSL.LoadFromFile(ATempFileName, TEncoding.UTF8);
    except
      on E: EFOpenError do
      begin
        // in caso di errore, aspetto 1 secondo e ci riprovo
        Sleep(1000);
        LSL.LoadFromFile(ATempFileName, TEncoding.UTF8);
      end;
    end;
    SetLength(Result, LSL.Count);

    for I := 0 to LSL.Count -1 do
    begin
      LArr := LSL[I].Split([#9]);

      LModel := TGHCliTagModel.Create;
      LModel.Tag := LArr[0];
      LModel.ReleaseType := TGHReleaseTypeDecode.PairFromDescr(LArr[1]);

      Result[I] := LModel;
    end;
  finally
    FreeAndNil(LSL);
  end;
end;

class function TGHCliRepoCommand.ReleaseList(var ARepoModel: TGHCliRepoModel; const ATempFileName: string): Boolean;
var
  LRes: Integer;
  LCMD: string;
begin
  LCMD := 'gh release list -R ' + ARepoModel.FullName + ' > ' + ATempFileName;
  LRes := ShellExecute(0, nil,
            'cmd.exe',
            PWideChar('/K ' + LCMD), nil,
            SW_HIDE
          );
  Result := LRes > 32;
  Sleep(300);
end;

class function TGHCliRepoCommand.ReleaseList(const ARepoFullName, ATempFileName: string): Boolean;
var
  LRes: Integer;
  LCMD: string;
begin
  LCMD := 'gh release list -R ' + ARepoFullName + ' > ' + ATempFileName;
  LRes := ShellExecute(0, nil,
            'cmd.exe',
            PWideChar('/K ' + LCMD), nil,
            SW_HIDE
          );
  Result := LRes > 32;
  Sleep(300);
end;

class function TGHCliRepoCommand.ReleaseListAndLoad(
  var ARepoModel: TGHCliRepoModel; const ATempFileName: string): Boolean;
begin
  Result := ReleaseList(ARepoModel, ATempFileName);
  if Result then
    ARepoModel.Tags := LoadRepoReleasesInModel(ATempFileName);
end;

class function TGHCliRepoCommand.ReleaseListAndLoad(const ARepoFullName,
  ATempFileName: string): TArray<TGHCliTagModel>;
begin
  if ReleaseList(ARepoFullName, ATempFileName) then
    Result := LoadRepoReleasesInModel(ATempFileName);
end;

class function TGHCliRepoCommand.ReleaseListAndLoad2(
  var ARepoModel: TGHCliRepoModel;
  const ATempFileName: string): TArray<TGHCliTagModel>;
begin
  if ReleaseList(ARepoModel, ATempFileName) then
    Result := LoadRepoReleasesInModel(ATempFileName);
end;

class function TGHCliRepoCommand.RepoList(const AOrganization, ATopic: string; const ATempFileName: string): Boolean;
var
  LRes: Integer;
  LCMD: string;
begin
  LCMD := 'gh repo list ' + AOrganization + ' -L 100 --topic ' + ATopic + ' > ' + ATempFileName;
  LRes := ShellExecute(0, nil,
            'cmd.exe',
            PWideChar('/K ' + LCMD), nil,
            SW_HIDE
          );
  Result := LRes > 32;
  Sleep(300);
end;

class function TGHCliRepoCommand.RepoListAndLoad(const AOrganization, ATopic: string; const ATempFileName: string;
  out ARepoModels: TArray<TGHCliRepoModel>): Boolean;
begin
  Result := RepoList(AOrganization, ATopic, ATempFileName);
  if Result then
    ARepoModels := LoadRepoNamesInModel(ATempFileName);
end;

class function TGHCliRepoCommand.BranchesList(var ARepoModel: TGHCliRepoModel;
  const ATempFileName: string): Boolean;
var
  LRes: Integer;
  LCMD: string;
begin
  LCMD := 'gh api repos/' + ARepoModel.FullName + '/branches -q ".[].name" > ' + ATempFileName;
  LRes := ShellExecute(0, nil,
            'cmd.exe',
            PWideChar('/K ' + LCMD), nil,
            SW_HIDE
          );
  Result := LRes > 32;
  Sleep(300);
end;

class function TGHCliRepoCommand.BranchesListAndLoad(const ARepoFullName,
  ATempFileName: string): TArray<string>;
begin
  if BranchesList(ARepoFullName, ATempFileName) then
    Result := LoadRepoBranchesInModel(ATempFileName);
end;

class function TGHCliRepoCommand.BranchesList(const ARepoFullName, ATempFileName: string): Boolean;
var
  LRes: Integer;
  LCMD: string;
begin
  LCMD := 'gh api repos/' + ARepoFullName + '/branches -q ".[].name" > ' + ATempFileName;
  LRes := ShellExecute(0, nil,
            'cmd.exe',
            PWideChar('/K ' + LCMD), nil,
            SW_HIDE
          );
  Result := LRes > 32;
  Sleep(300);
end;

class function TGHCliRepoCommand.BranchesListAndLoad(
  var ARepoModel: TGHCliRepoModel; const ATempFileName: string): Boolean;
begin
  Result := BranchesList(ARepoModel, ATempFileName);
  if Result then
    ARepoModel.Branches := LoadRepoBranchesInModel(ATempFileName);
end;

class function TGHCliRepoCommand.LoadRepoBranchesInModel(const ATempFileName: string): TArray<string>;
var
  LSL: TStringList;
  I: Integer;
begin
  LSL := TStringList.Create;
  try
    try
      LSL.LoadFromFile(ATempFileName, TEncoding.UTF8);
    except
      on E: EFOpenError do
      begin
        // in caso di errore, aspetto 1 secondo e ci riprovo
        Sleep(1000);
        LSL.LoadFromFile(ATempFileName, TEncoding.UTF8);
      end;
    end;

    for I := 0 to LSL.Count -1 do
    begin
      if LSL[I].StartsWith('6.') or SameText(LSL[I], 'main') then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := LSL[I];
      end;
    end;
  finally
    FreeAndNil(LSL);
  end;
end;

class function TGHCliRepoCommand.LoadRepoNamesInModel(const ATempFileName: string): TArray<TGHCliRepoModel>;
var
  LSL: TStringList;
  LArr, LArrName: TArray<string>;
  I: Integer;
  LModel: TGHCliRepoModel;
begin
  LSL := TStringList.Create;
  try
    try
      LSL.LoadFromFile(ATempFileName, TEncoding.UTF8);
    except
      on E: EFOpenError do
      begin
        // in caso di errore, aspetto 1 secondo e ci riprovo
        Sleep(1000);
        LSL.LoadFromFile(ATempFileName, TEncoding.UTF8);
      end;
    end;
    SetLength(Result, LSL.Count);

    for I := 0 to LSL.Count -1 do
    begin
      LArr := LSL[I].Split([#9]);
      LArrName := LArr[0].Split(['/']);

      LModel := TGHCliRepoModel.Create;
      LModel.Organization := LArrName[0];
      LModel.Name := LArrName[1];

      Result[I] := LModel;
    end;
  finally
    FreeAndNil(LSL);
  end;
end;

function CSExec(Fn, Pa: string; Sw: Word; WaitExec: Boolean): DWord;
var
  LStartInfo: TStartUpInfo;
  LProcInfo: TProcessInformation;
  LSt: DWord;
  LEc: LongInt;
  LEr: DWord;
begin
  // initialize to avoid warnings
  LSt := 0;
  //LEr := 0;

  // Azzero l'ultimo errore
  SetLastError(0);

  // setting the TStartUpInfo record
  with LStartInfo do
  begin
    cb := sizeof(LStartInfo);
    lpReserved := nil;
    lpDesktop := nil;
    lpTitle := nil;
    dwX := STARTF_USEPOSITION;
    dwY := STARTF_USEPOSITION;
    dwXSize := STARTF_USESIZE;
    dwYSize := STARTF_USESIZE;
    dwXCountChars := STARTF_USECOUNTCHARS;
    dwYCountChars := STARTF_USECOUNTCHARS;
    dwFillAttribute := FOREGROUND_BLUE;
    dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
    wShowWindow := Sw;
    cbReserved2 := 0;
    lpReserved2 := nil;
    hStdInput := 0;
    hStdOutput := 0;
    hStdError := 0;
  end;

  if Trim(Fn) = '' then
    CreateProcess(nil, PChar(Pa),
                  nil, nil, False,
                  CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                  nil, nil, LStartInfo, LProcInfo)
  Else
    CreateProcess(PChar(Fn), PChar(Pa),
                  nil, nil, False,
                  CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS,
                  nil, nil, LStartInfo, LProcInfo);

  // wait the completation flag
  if WaitExec then
  begin
    repeat
      GetExitCodeProcess(LProcInfo.hProcess, LSt);
      Sleep(3000);
    until (LSt<>STILL_ACTIVE);

    GetExitCodeProcess(LProcInfo.hProcess, LSt);
    //LEr := GetLastError;
    LEr := Integer(LSt);

    LEc := 0;
    TerminateProcess(LProcInfo.hProcess, LEc);
  end
  else
  begin
    GetExitCodeProcess(LProcInfo.hProcess, LSt);
    //LEr := GetLastError;
    LEr := Integer(LSt);
  end;

  try
    // Clean up the handles.
    CloseHandle(LProcInfo.hProcess);
    CloseHandle(LProcInfo.hThread);
  except
  end;

  Result := LEr;
end;

end.
