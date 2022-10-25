﻿unit uRESTDWUniDACDriver;

{$I ..\..\Source\Includes\uRESTDWPlataform.inc}

{
  REST Dataware .
  Criado por XyberX (Gilbero Rocha da Silva), o REST Dataware tem como objetivo o uso de REST/JSON
 de maneira simples, em qualquer Compilador Pascal (Delphi, Lazarus e outros...).
  O REST Dataware também tem por objetivo levar componentes compatíveis entre o Delphi e outros Compiladores
 Pascal e com compatibilidade entre sistemas operacionais.
  Desenvolvido para ser usado de Maneira RAD, o REST Dataware tem como objetivo principal você usuário que precisa
 de produtividade e flexibilidade para produção de Serviços REST/JSON, simplificando o processo para você programador.

 Membros do Grupo :

 XyberX (Gilberto Rocha)    - Admin - Criador e Administrador  do pacote.
 Alexandre Abbade           - Admin - Administrador do desenvolvimento de DEMOS, coordenador do Grupo.
 Anderson Fiori             - Admin - Gerencia de Organização dos Projetos
 Flávio Motta               - Member Tester and DEMO Developer.
 Mobius One                 - Devel, Tester and Admin.
 Gustavo                    - Criptografia and Devel.
 Eloy                       - Devel.
 Roniery                    - Devel.
 Fernando Banhos            - Refactor Drivers REST Dataware.
}

interface

uses
  {$IFDEF FPC}
    LResources,
  {$ENDIF}
  Classes, SysUtils, uRESTDWDriverBase, uRESTDWBasicTypes, DB, MemDS,
  DBAccess, Uni, uRESTDWMemtable;

const
  {$IFDEF FPC}
    rdwUniDACProtocols : array of string = ('access','advantage','ase','db2',
                      'dbf','interbase','mysql','mongodb','nexusdb','obdc',
                      'oracle','postgresql','redshift','sql server','sqlite',
                      'bigcommerce','bigquery','dynamics 365','freshbooks',
                      'hubspot','magento','mailchimp','netsuite','quickbooks',
                      'salesforce mc','salesforce','sugar crm','zoho crm');

    rdwUniDACDbType : array of TRESTDWDatabaseType = (dbtAccess,dbtUndefined,
                   dbtUndefined,dbtUndefined,dbtDbase,dbtInterbase,dbtMySQL,
                   dbtUndefined,dbtUndefined,dbtODBC,dbtOracle,dbtPostgreSQL,
                   dbtUndefined,dbtMsSQL,dbtSQLLite,dbtUndefined,dbtUndefined,
                   dbtUndefined,dbtUndefined,dbtUndefined,dbtUndefined,
                   dbtUndefined,dbtUndefined,dbtUndefined,dbtUndefined,
                   dbtUndefined,dbtUndefined,dbtUndefined);
  {$ELSE}
    rdwUniDACProtocols : array of string = ['access','advantage','ase','db2',
                      'dbf','interbase','mysql','mongodb','nexusdb','obdc',
                      'oracle','postgresql','redshift','sql server','sqlite',
                      'bigcommerce','bigquery','dynamics 365','freshbooks',
                      'hubspot','magento','mailchimp','netsuite','quickbooks',
                      'salesforce mc','salesforce','sugar crm','zoho crm'];

    rdwUniDACDbType : array of TRESTDWDatabaseType = [dbtAccess,dbtUndefined,
                   dbtUndefined,dbtUndefined,dbtDbase,dbtInterbase,dbtMySQL,
                   dbtUndefined,dbtUndefined,dbtODBC,dbtOracle,dbtPostgreSQL,
                   dbtUndefined,dbtMsSQL,dbtSQLLite,dbtUndefined,dbtUndefined,
                   dbtUndefined,dbtUndefined,dbtUndefined,dbtUndefined,
                   dbtUndefined,dbtUndefined,dbtUndefined,dbtUndefined,
                   dbtUndefined,dbtUndefined,dbtUndefined];
  {$ENDIF}

  crdwConnectionNotIsUniDAC = 'Componente não é um UniConnection';

type
  { TRESTDWUniDACDataset }

  TRESTDWUniDACDataset = class(TRESTDWDataset)
  public
    procedure SaveToStream(stream : TStream); override;
  end;

  { TRESTDWUniDACStoreProc }

  TRESTDWUniDACStoreProc = class(TRESTDWStoreProc)
  public
    procedure ExecProc; override;
    procedure Prepare; override;
  end;

  { TRESTDWUniDACQuery }

  TRESTDWUniDACQuery = class(TRESTDWQuery)
  protected
    procedure createSequencedField(seqname,field : string); override;
  public
    procedure ExecSQL; override;
    procedure Prepare; override;

    function RowsAffected : Int64; override;
  end;

  { TRESTDWUniDACDriver }

  TRESTDWUniDACDriver = class(TRESTDWDriverBase)
  private
    function aGetConnection: TUniConnection;
    procedure aSetConnection(const Value: TUniConnection);
  protected
    procedure setConnection(AValue: TComponent); override;
    function getConectionType : TRESTDWDatabaseType; override;
  public
    function getQuery : TRESTDWQuery; override;
    function getTable : TRESTDWTable; override;
    function getStoreProc : TRESTDWStoreProc; override;

    procedure Connect; override;
    procedure Disconect; override;

    function isConnected : boolean; override;
    function connInTransaction : boolean; override;
    procedure connStartTransaction; override;
    procedure connRollback; override;
    procedure connCommit; override;

    class procedure CreateConnection(Const AConnectionDefs : TConnectionDefs;
                                     var AConnection : TComponent); override;
  published
    Property  Connection : TUniConnection Read aGetConnection Write aSetConnection;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('REST Dataware - Drivers', [TRESTDWUniDACDriver]);
end;

{ TRESTDWUniDACStoreProc }

procedure TRESTDWUniDACStoreProc.ExecProc;
var
  qry : TUniStoredProc;
begin
  inherited ExecProc;
  qry := TUniStoredProc(Self.Owner);
  qry.ExecProc;
end;

procedure TRESTDWUniDACStoreProc.Prepare;
var
  qry : TUniStoredProc;
begin
  inherited Prepare;
  qry := TUniStoredProc(Self.Owner);
  qry.Prepare;
end;

{ TRESTDWUniDACDataset }

procedure TRESTDWUniDACDataset.SaveToStream(stream : TStream);
var
  vDWMemtable : TRESTDWMemtable;
  qry : TCustomUniDataSet;
begin
  inherited SaveToStream(stream);
  qry := TCustomUniDataSet(Self.Owner);
  vDWMemtable := TRESTDWMemtable.Create(Nil);
  try
    vDWMemtable.Assign(qry);
    vDWMemtable.SaveToStream(stream);
    stream.Position := 0;
  finally
    FreeAndNil(vDWMemtable);
  end;
end;

 { TRESTDWUniDACDriver }

procedure TRESTDWUniDACDriver.setConnection(AValue : TComponent);
begin
  if (Assigned(AValue)) and (not AValue.InheritsFrom(TUniConnection)) then
    raise Exception.Create(crdwConnectionNotIsUniDAC);
  inherited setConnection(AValue);
end;

function TRESTDWUniDACDriver.getConectionType : TRESTDWDatabaseType;
var
  prot : string;
  i : integer;
begin
  Result:=inherited getConectionType;
  if not Assigned(Connection) then
    Exit;

  prot := LowerCase(TUniConnection(Connection).ProviderName);

  i := 0;
  while i < Length(rdwUniDACProtocols) do begin
    if Pos(rdwUniDACProtocols[i],prot) > 0 then begin
      Result := rdwUniDACDbType[i];
      Break;
    end;
    i := i + 1;
  end;
end;

function TRESTDWUniDACDriver.getQuery : TRESTDWQuery;
var
  qry : TUniQuery;
begin
  qry := TUniQuery.Create(Self);
  qry.Connection := TUniConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimVarChar       := StrsTrim;
  qry.Options.TrimFixedChar     := StrsTrim;

  Result := TRESTDWUniDACQuery.Create(qry);
end;

function TRESTDWUniDACDriver.getTable : TRESTDWTable;
var
  qry : TUniTable;
begin
  qry := TUniTable.Create(Self);
  qry.Connection := TUniConnection(Connection);

  Result := TRESTDWTable.Create(qry);
end;

function TRESTDWUniDACDriver.getStoreProc : TRESTDWStoreProc;
var
  qry : TUniStoredProc;
begin
  qry := TUniStoredProc.Create(Self);
  qry.Connection := TUniConnection(Connection);
  qry.Options.SetEmptyStrToNull := StrsEmpty2Null;
  qry.Options.TrimVarChar       := StrsTrim;
  qry.Options.TrimFixedChar     := StrsTrim;

  Result := TRESTDWUniDACStoreProc.Create(qry);
end;

procedure TRESTDWUniDACDriver.Connect;
begin
  if Assigned(Connection) then
    TUniConnection(Connection).Open;
  inherited Connect;
end;

procedure TRESTDWUniDACDriver.Disconect;
begin
  if Assigned(Connection) then
    TUniConnection(Connection).Close;
  inherited Disconect;
end;

function TRESTDWUniDACDriver.isConnected : boolean;
begin
  Result:=inherited isConnected;
  if Assigned(Connection) then
    Result := TUniConnection(Connection).Connected;
end;

function TRESTDWUniDACDriver.connInTransaction : boolean;
begin
  Result:=inherited connInTransaction;
  if Assigned(Connection) then
    Result := TUniConnection(Connection).InTransaction;
end;

procedure TRESTDWUniDACDriver.connStartTransaction;
begin
  inherited connStartTransaction;
  if Assigned(Connection) then
    TUniConnection(Connection).StartTransaction;
end;

procedure TRESTDWUniDACDriver.connRollback;
begin
  inherited connRollback;
  if Assigned(Connection) then
    TUniConnection(Connection).Rollback;
end;

function TRESTDWUniDACDriver.aGetConnection: TUniConnection;
begin
 Result := TUniConnection(GetConnection);
end;

procedure TRESTDWUniDACDriver.aSetConnection(const Value: TUniConnection);
begin
 setConnection(Value);
end;

procedure TRESTDWUniDACDriver.connCommit;
begin
  inherited connCommit;
  if Assigned(Connection) then
    TUniConnection(Connection).Commit;
end;

class procedure TRESTDWUniDACDriver.CreateConnection(const AConnectionDefs : TConnectionDefs;
                                                     var AConnection : TComponent);
begin
  inherited CreateConnection(AConnectionDefs, AConnection);
  if Assigned(AConnectionDefs) then begin
    case AConnectionDefs.DriverType Of
      dbtUndefined  : TUniConnection(AConnection).ProviderName := '';
      dbtAccess     : TUniConnection(AConnection).ProviderName := 'access';
      dbtDbase      : TUniConnection(AConnection).ProviderName := 'dbf';
      dbtParadox    : TUniConnection(AConnection).ProviderName := '';
      dbtFirebird   : TUniConnection(AConnection).ProviderName := 'interbase';
      dbtInterbase  : TUniConnection(AConnection).ProviderName := 'interbase';
      dbtMySQL      : TUniConnection(AConnection).ProviderName := 'mysql';
      dbtSQLLite    : TUniConnection(AConnection).ProviderName := 'sqlite';
      dbtOracle     : TUniConnection(AConnection).ProviderName := 'oracle';
      dbtMsSQL      : TUniConnection(AConnection).ProviderName := 'sql server';
      dbtODBC       : TUniConnection(AConnection).ProviderName := 'odbc';
      dbtPostgreSQL : TUniConnection(AConnection).ProviderName := 'postgresql';
      dbtAdo        : TUniConnection(AConnection).ProviderName := '';
    end;
  end;

  with TUniConnection(AConnection) do begin
    Server   := AConnectionDefs.HostName;
    Database := AConnectionDefs.DatabaseName;
    Username := AConnectionDefs.Username;
    Password := AConnectionDefs.Password;
    Port     := AConnectionDefs.DBPort;
  end;
end;

{ TRESTDWUniDACQuery }

procedure TRESTDWUniDACQuery.createSequencedField(seqname, field : string);
var
  qry : TUniQuery;
  fd : TField;
begin
  qry := TUniQuery(Self.Owner);
  fd := qry.FindField(field);
  if fd <> nil then begin
    fd.Required          := False;
    fd.AutoGenerateValue := arAutoInc;
  end;
end;

procedure TRESTDWUniDACQuery.ExecSQL;
var
  qry : TUniQuery;
begin
  inherited ExecSQL;
  qry := TUniQuery(Self.Owner);
  qry.ExecSQL;
end;

procedure TRESTDWUniDACQuery.Prepare;
var
  qry : TUniQuery;
begin
  inherited Prepare;
  qry := TUniQuery(Self.Owner);
  qry.Prepare;
end;

function TRESTDWUniDACQuery.RowsAffected : Int64;
var
  qry : TUniQuery;
begin
  qry := TUniQuery(Self.Owner);
  Result := qry.RowsAffected;
end;

{$IFDEF FPC}
initialization
  {$I restdwunidacdriver.lrs}
{$ENDIF}

end.

