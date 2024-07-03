unit GHRepoOperations.Repo;

interface

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  System.Classes,
  System.SysUtils,
  System.Generics.Collections;

function CSExec(Fn, Pa: string; Sw: Word; WaitExec: Boolean): DWord;

type
  TGHCliRepoModel = class
    Name: string;
  end;

  TGHCliRepoCommand = class
  private
    class function LoadRepoModel(const ATempFileName: string): TArray<TGHCliRepoModel>;
  public
    class function Execute(const AOrganization: string; const ATempFileName: string): Boolean;
    class function ExecuteAndLoadRepoInfo(const AOrganization: string; const ATempFileName: string;
      out ARepoModels: TArray<TGHCliRepoModel>): Boolean;
  end;

implementation

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

{ TGHCliRepoCommand }

class function TGHCliRepoCommand.Execute(const AOrganization: string; const ATempFileName: string): Boolean;
var
  LRes: Integer;
  LCMD: string;
begin
  LCMD := 'gh repo list ' + AOrganization + ' -L 100 --topic addon > ' + ATempFileName;
  LRes := ShellExecute(0, nil,
            'cmd.exe',
            PWideChar('/K ' + LCMD), nil,
            SW_HIDE
          );
  Result := LRes > 32;
end;

class function TGHCliRepoCommand.ExecuteAndLoadRepoInfo(const AOrganization: string; const ATempFileName: string;
      out ARepoModels: TArray<TGHCliRepoModel>): Boolean;
begin
  Result := Execute(AOrganization, ATempFileName);
  if Result then
    ARepoModels := LoadRepoModel(ATempFileName);
end;

class function TGHCliRepoCommand.LoadRepoModel(const ATempFileName: string): TArray<TGHCliRepoModel>;
var
  LSL: TStringList;
  LArr: TArray<string>;
  I: Integer;
  LModel: TGHCliRepoModel;
begin
  LSL := TStringList.Create;
  try
    LSL.LoadFromFile(ATempFileName, TEncoding.UTF8);
    SetLength(Result, LSL.Count);

    for I := 0 to LSL.Count -1 do
    begin
      LArr := LSL[I].Split([#9]);

      LModel := TGHCliRepoModel.Create;
      LModel.Name := LArr[0];

      Result[I] := LModel;
    end;
  finally
    FreeAndNil(LSL);
  end;
end;

end.
