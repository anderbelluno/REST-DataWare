unit uDWMassiveBuffer;

{$I uRESTDW.inc}

interface

uses SysUtils,       Classes,      uDWJSONObject,
     DB,             uRESTDWBase,  uDWConsts,
     uDWConstsData,  uDWJSONTools, udwjson;

Type
 TMassiveValue = Class
 Private
  vJSONValue  : TJSONValue;
  Function    GetValue       : String;
  Procedure   SetValue(Value : String);
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Stream : TMemoryStream);
  Property    Value          : String  Read GetValue Write SetValue;
End;

Type
 PMassiveValue  = ^TMassiveValue;
 TMassiveValues = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveValue;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveValue); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                          Overload;
  Function   Add   (Item  : TMassiveValue) : Integer;          Overload;
  Property   Items[Index  : Integer]       : TMassiveValue Read GetRec Write PutRec; Default;
End;

Type
 TMassiveField = Class
 Private
  vMassiveFields : TList;
  vAutoGenerateValue,
  vRequired,
  vKeyField   : Boolean;
  vFieldName  : String;
  vFieldType  : TObjectValue;
  vFieldIndex,
  vSize,
  vPrecision  : Integer;
  Function    GetValue       : String;
  Procedure   SetValue(Value : String);
 Protected
 Public
  Constructor Create(MassiveFields : TList; FieldIndex : Integer);
  Destructor  Destroy;Override;
  Procedure   LoadFromStream(Stream : TMemoryStream);
  Procedure   SaveToStream  (Stream : TMemoryStream);
  Property    Required          : Boolean      Read vRequired          Write vRequired;
  Property    AutoGenerateValue : Boolean      Read vAutoGenerateValue Write vAutoGenerateValue;
  Property    KeyField          : Boolean      Read vKeyField          Write vKeyField;
  Property    FieldType         : TObjectValue Read vFieldType         Write vFieldType;
  Property    FieldName         : String       Read vFieldName         Write vFieldName;
  Property    Size              : Integer      Read vSize              Write vSize;
  Property    Precision         : Integer      Read vPrecision         Write vPrecision;
  Property    Value             : String       Read GetValue           Write SetValue;
End;

Type
 PMassiveField  = ^TMassiveField;
 TMassiveFields = Class(TList)
 Private
  vMassiveDataset : TMassiveDataset;
  Function   GetRec(Index : Integer)       : TMassiveField;  Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveField); Overload;
  Procedure  ClearAll;
 Protected
 Public
  Constructor Create(MassiveDataset : TMassiveDataset);
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                          Overload;
  Function   Add   (Item  : TMassiveField) : Integer;          Overload;
  Function   FieldByName(FieldName : String) : TMassiveField;
  Property   Items[Index  : Integer]       : TMassiveField Read GetRec Write PutRec; Default;
End;

Type
 TMassiveLine = Class
 Private
  vMassiveValues  : TMassiveValues;
  vPrimaryValues  : TMassiveValues;
  vMassiveMode    : TMassiveMode;
  vChanges        : TStringList;
  Function   GetRec  (Index : Integer)       : TMassiveValue;
  Procedure  PutRec  (Index : Integer; Item  : TMassiveValue);
  Function   GetRecPK(Index : Integer)       : TMassiveValue;
  Procedure  PutRecPK(Index : Integer; Item  : TMassiveValue);
 Protected
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Procedure   ClearAll;
  Property    MassiveMode                     : TMassiveMode   Read vMassiveMode Write vMassiveMode;
  Property    UpdateFieldChanges              : TStringList    Read vChanges     Write vChanges;
  Property    Values       [Index  : Integer] : TMassiveValue  Read GetRec       Write PutRec;
  Property    PrimaryValues[Index  : Integer] : TMassiveValue  Read GetRecPK     Write PutRecPK;
End;

Type
 PMassiveLine   = ^TMassiveLine;
 TMassiveBuffer = Class(TList)
 Private
  Function   GetRec(Index : Integer)       : TMassiveLine;    Overload;
  Procedure  PutRec(Index : Integer; Item  : TMassiveLine);   Overload;
  Procedure  ClearAll;
 Protected
 Public
  Destructor Destroy;Override;
  Procedure  Delete(Index : Integer);                         Overload;
  Function   Add   (Item  : TMassiveLine)  : Integer;         Overload;
  Property   Items[Index  : Integer]       : TMassiveLine Read GetRec Write PutRec; Default;
End;

Type
 TMassiveDatasetBuffer = Class(TMassiveDataset)
 Protected
  vRecNo         : Integer;
  vMassiveBuffer : TMassiveBuffer;
  vMassiveLine   : TMassiveLine;
  vMassiveFields : TMassiveFields;
  vMassiveMode   : TMassiveMode;
  vTableName     : String;
 Private
  Procedure ReadStatus;
  Procedure NewLineBuffer(Var MassiveLineBuff : TMassiveLine;
                          MassiveModeData     : TMassiveMode);
 Public
  Constructor Create;
  Destructor  Destroy;Override;
  Function  RecNo       : Integer;
  Function  RecordCount : Integer;
  Procedure First;
  Procedure Prior;
  Procedure Next;
  Procedure Last;
  Function  PrimaryKeys : TStringList;
  Function  AtualRec    : TMassiveLine;
  Procedure NewBuffer   (Dataset              : TRESTDWClientSQLBase;
                         MassiveModeData      : TMassiveMode); Overload;
  Procedure NewBuffer   (Var MassiveLineBuff  : TMassiveLine;
                         MassiveModeData      : TMassiveMode); Overload;
  Procedure NewBuffer   (MassiveModeData      : TMassiveMode); Overload;
  Procedure BuildDataset(Dataset              : TRESTDWClientSQLBase;
                         UpdateTableName      : String);                 //Constroi o Dataset Massivo
  Procedure BuildLine   (Dataset              : TRESTDWClientSQLBase;
                         MassiveModeBuff      : TMassiveMode;
                         Var MassiveLineBuff  : TMassiveLine;
                         UpdateTag            : Boolean = False);
  Procedure BuildBuffer (Dataset              : TRESTDWClientSQLBase;    //Cria um Valor Massivo Baseado nos Dados de Um Dataset
                         MassiveMode          : TMassiveMode;
                         UpdateTag            : Boolean = False);
  Procedure SaveBuffer  (Dataset              : TRESTDWClientSQLBase);   //Salva Um Buffer Massivo na Lista de Massivos
  Procedure ClearBuffer;                                                //Limpa o Buffer Massivo Atual
  Procedure ClearDataset;                                               //Limpa Todo o Dataset Massivo
  Procedure ClearLine;                                                  //Limpa o Buffer Temporario
  Function  ToJSON      : String;                                       //Gera o JSON do Dataset Massivo
  Procedure FromJSON    (Value : String);                               //Carrega o Dataset Massivo a partir de um JSON
  Property  MassiveMode : TMassiveMode   Read vMassiveMode;             //Modo Massivo do Buffer Atual
  Property  Fields      : TMassiveFields Read vMassiveFields Write vMassiveFields;
  Property  TableName   : String         Read vTableName;
End;

implementation

Uses uRESTDWPoolerDB, uDWPoolerMethod;

{ TMassiveField }

Constructor TMassiveField.Create(MassiveFields : TList; FieldIndex : Integer);
Begin
 vRequired          := False;
 vAutoGenerateValue := False;
 vKeyField          := vRequired;
 vFieldType         := ovUnknown;
 vFieldName         := '';
 vMassiveFields     := MassiveFields;
 vFieldIndex        := FieldIndex;
End;

Destructor TMassiveField.Destroy;
Begin
 Inherited;
End;

Procedure TMassiveField.LoadFromStream(Stream: TMemoryStream);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].LoadFromStream(Stream);
  End;
End;

Procedure TMassiveField.SaveToStream(Stream: TMemoryStream);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].SaveToStream(Stream);
  End;
End;

Procedure TMassiveField.SetValue(Value: String);
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Value := Value;
  End;
End;

Function TMassiveField.GetValue : String;
Var
 vRecNo : Integer;
Begin
 If TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Count > 0 Then
  Begin
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   If vRecNo <= 0 Then
    TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo := 1;
   vRecNo := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vRecNo;
   Result := TMassiveDatasetBuffer(TMassiveFields(vMassiveFields).vMassiveDataset).vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[vFieldIndex +1].Value;
  End;
End;

{ TMassiveFields }

Function TMassiveFields.Add(Item: TMassiveField): Integer;
Var
 vItem : ^TMassiveField;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveFields.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveField(TList(Self).Items[Index]^)) Then
      FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PMassiveField(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Procedure TMassiveFields.ClearAll;
Var
 I : Integer;
Begin
 For I := TList(Self).Count -1 DownTo 0 Do
  Self.Delete(I);
End;

Constructor TMassiveFields.Create(MassiveDataset: TMassiveDataset);
Begin
 Inherited Create;
 vMassiveDataset := MassiveDataset;
End;

Destructor TMassiveFields.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveFields.FieldByName(FieldName : String): TMassiveField;
Var
 I : Integer;
Begin
 Result := Nil;
 For I := 0 To Self.Count -1 Do
  Begin
   If LowerCase(TMassiveField(TList(Self).Items[I]^).vFieldName) =
      LowerCase(FieldName) Then
    Begin
     Result := TMassiveField(TList(Self).Items[I]^);
     Break;
    End;
  End;
End;

Function TMassiveFields.GetRec(Index : Integer) : TMassiveField;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveField(TList(Self).Items[Index]^);
End;

Procedure TMassiveFields.PutRec(Index : Integer; Item : TMassiveField);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveField(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveValue }

Constructor TMassiveValue.Create;
Begin
 vJSONValue := TJSONValue.Create;
End;

Destructor TMassiveValue.Destroy;
Begin
 FreeAndNil(vJSONValue);
 Inherited;
End;

Function TMassiveValue.GetValue: String;
Begin
 Result := vJSONValue.Value;
End;

Procedure TMassiveValue.LoadFromStream(Stream: TMemoryStream);
Begin
 vJSONValue.LoadFromStream(Stream);
End;

Procedure TMassiveValue.SaveToStream(Stream: TMemoryStream);
Begin
 vJSONValue.SaveToStream(Stream);
End;

Procedure TMassiveValue.SetValue(Value: String);
Begin
 vJSONValue.SetValue(Value);
End;

{ TMassiveValues }

Function TMassiveValues.Add(Item: TMassiveValue): Integer;
Var
 vItem : ^TMassiveValue;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveValues.ClearAll;
Var
 I : Integer;
Begin
 For I := TList(Self).Count -1 DownTo 0 Do
  Self.Delete(I);
End;

Procedure TMassiveValues.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveValue(TList(Self).Items[Index]^)) Then
      FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PMassiveValue(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveValues.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveValues.GetRec(Index: Integer): TMassiveValue;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(Self).Items[Index]^);
End;

Procedure TMassiveValues.PutRec(Index: Integer; Item: TMassiveValue);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveValue(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveLine }

Constructor TMassiveLine.Create;
Begin
 vMassiveValues  := TMassiveValues.Create;
 vMassiveMode    := mmBrowse;
 vChanges        := TStringList.Create;
End;

Destructor TMassiveLine.Destroy;
Begin
 FreeAndNil(vMassiveValues);
 FreeAndNil(vChanges);
 If Assigned(vPrimaryValues) Then
  FreeAndNil(vPrimaryValues);
 Inherited;
End;

Function TMassiveLine.GetRec(Index: Integer): TMassiveValue;
Begin
 Result := Nil;
 If (Index < vMassiveValues.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(vMassiveValues).Items[Index]^);
End;

Function TMassiveLine.GetRecPK(Index : Integer) : TMassiveValue;
Begin
 Result := Nil;
 If (Index < vPrimaryValues.Count) And (Index > -1) Then
  Result := TMassiveValue(TList(vPrimaryValues).Items[Index]^);
End;

Procedure TMassiveLine.ClearAll;
Begin
 vMassiveValues.ClearAll;
 If Assigned(vPrimaryValues) Then
  vPrimaryValues.ClearAll;
 If Assigned(vChanges)       Then
  vChanges.Clear;
End;

Procedure TMassiveLine.PutRec(Index: Integer;   Item : TMassiveValue);
Begin
 If (Index < vMassiveValues.Count) And (Index > -1) Then
  TMassiveValue(TList(vMassiveValues).Items[Index]^) := Item;
End;

Procedure TMassiveLine.PutRecPK(Index: Integer; Item : TMassiveValue);
Begin
 If (Index < vPrimaryValues.Count) And (Index > -1) Then
  TMassiveValue(TList(vPrimaryValues).Items[Index]^) := Item;
End;

{ TMassiveBuffer }

Function TMassiveBuffer.Add(Item : TMassiveLine): Integer;
Var
 vItem : ^TMassiveLine;
Begin
 New(vItem);
 vItem^ := Item;
 Result := TList(Self).Add(vItem);
End;

Procedure TMassiveBuffer.ClearAll;
Var
 I : Integer;
Begin
 For I := TList(Self).Count -1 DownTo 0 Do
  Self.Delete(I);
End;

Procedure TMassiveBuffer.Delete(Index: Integer);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  Begin
   If Assigned(TList(Self).Items[Index]) Then
    Begin
     If Assigned(TMassiveLine(TList(Self).Items[Index]^)) Then
      FreeAndNil(TList(Self).Items[Index]^);
     {$IFDEF FPC}
      Dispose(PMassiveLine(TList(Self).Items[Index]));
     {$ELSE}
      Dispose(TList(Self).Items[Index]);
     {$ENDIF}
    End;
   TList(Self).Delete(Index);
  End;
End;

Destructor TMassiveBuffer.Destroy;
Begin
 ClearAll;
 Inherited;
End;

Function TMassiveBuffer.GetRec(Index: Integer): TMassiveLine;
Begin
 Result := Nil;
 If (Index < Self.Count) And (Index > -1) Then
  Result := TMassiveLine(TList(Self).Items[Index]^);
End;

Procedure TMassiveBuffer.PutRec(Index: Integer; Item: TMassiveLine);
Begin
 If (Index < Self.Count) And (Index > -1) Then
  TMassiveLine(TList(Self).Items[Index]^) := Item;
End;

{ TMassiveDatasetBuffer }

Procedure TMassiveDatasetBuffer.NewLineBuffer(Var MassiveLineBuff : TMassiveLine;
                                              MassiveModeData     : TMassiveMode);
Var
 I            : Integer;
 MassiveValue : TMassiveValue;
Begin
 MassiveLineBuff.vMassiveMode := MassiveModeData;
 For I := 0 To vMassiveFields.Count Do
  Begin
   MassiveValue       := TMassiveValue.Create;
   If I = 0 Then
    MassiveValue.Value := MassiveModeToString(MassiveModeData);
   MassiveLineBuff.vMassiveValues.Add(MassiveValue);
  End;
End;

Procedure TMassiveDatasetBuffer.BuildLine(Dataset             : TRESTDWClientSQLBase;
                                          MassiveModeBuff     : TMassiveMode;
                                          Var MassiveLineBuff : TMassiveLine;
                                          UpdateTag           : Boolean = False);
 Procedure CopyValue(MassiveModeBuff : TMassiveMode);
 Var
  I             : Integer;
  Field         : TField;
  vStringStream : TMemoryStream;
  vUpdateCase   : Boolean;
  MassiveValue  : TMassiveValue;
 Begin
  vUpdateCase := False;
  //KeyValues to Update
  If MassiveModeBuff = mmUpdate Then
   vUpdateCase := MassiveLineBuff.vPrimaryValues = Nil;
  If MassiveLineBuff.vPrimaryValues <> Nil Then
   vUpdateCase := MassiveLineBuff.vPrimaryValues.Count = 0;
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    Field := Dataset.FindField(vMassiveFields.Items[I].vFieldName);
    If Field <> Nil Then
     Begin
      If MassiveModeBuff = mmDelete Then
       If Not(pfInKey in Field.ProviderFlags) Then
        Continue;
      //KeyValues to Update
      If (MassiveModeBuff = mmUpdate)      And
         (vUpdateCase)                     Then
       If (pfInKey in Field.ProviderFlags) Then
        Begin
         If MassiveLineBuff.vPrimaryValues = Nil Then
          MassiveLineBuff.vPrimaryValues := TMassiveValues.Create;
         If vUpdateCase Then
          Begin
           MassiveValue  := TMassiveValue.Create;
           If Field.DataType in [ftBytes, ftVarBytes,
                                 ftBlob, ftGraphic,
                                 ftOraBlob, ftOraClob] Then
            Begin
             vStringStream := TMemoryStream.Create;
             Try
              If TBlobField(Field).Size > 0 Then
               Begin
                TBlobField(Field).SaveToStream(vStringStream);
                vStringStream.Position := 0;
                MassiveValue.LoadFromStream(vStringStream);
               End
              Else
               MassiveValue.Value := '';
             Finally
              FreeAndNil(vStringStream);
             End;
            End
           Else
            Begin
             If Trim(Field.AsString) <> '' Then
              MassiveValue.Value := Field.AsString;
            End;
           MassiveLineBuff.vPrimaryValues.Add(MassiveValue);
          End;
        End;
      Case Field.DataType Of
       {$IFNDEF FPC}{$if CompilerVersion > 21} // Delphi 2010 pra baixo
       ftFixedChar, ftFixedWideChar,{$IFEND}{$ENDIF}
       ftString,    ftWideString : Begin
                                    If Not UpdateTag Then
                                     Begin
                                      If Trim(Field.AsString) <> '' Then
                                       Begin
                                        If Field.Size > 0 Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Copy(Field.AsString, 1, Field.Size)
                                        Else
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
                                       End
                                      Else
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                     End
                                    Else
                                     Begin
                                      If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.AsString Then
                                       Begin
                                        MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
                                        MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                       End;
                                     End;
                                   End;
       ftInteger, ftSmallInt,
       ftWord
       {$IFNDEF FPC}{$if CompilerVersion > 21}, ftLongWord{$IFEND}{$ENDIF}
                                 : Begin
                                    If Not UpdateTag Then
                                     Begin
                                      If Trim(Field.AsString) <> '' Then
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Trim(Field.AsString)
                                      Else
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                     End
                                    Else
                                     Begin
                                      If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.AsString Then
                                       Begin
                                        MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Trim(Field.AsString);
                                        MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                       End;
                                     End;
                                   End;
       ftFloat,
       ftCurrency, ftBCD         : Begin
                                    If Not UpdateTag Then
                                     Begin
                                      If Trim(Field.AsString) <> '' Then
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := FloatToStr(Field.AsCurrency)
                                      Else
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                     End
                                    Else
                                     Begin
                                      If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.AsString Then
                                       Begin
                                        If Trim(Field.AsString) <> '' Then
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := FloatToStr(Field.AsCurrency)
                                        Else
                                         MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                        MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                       End;
                                     End;
                                   End;
       ftDate, ftTime,
       ftDateTime, ftTimeStamp   : Begin
                                    If Not UpdateTag Then
                                     Begin
                                      If Trim(Field.AsString) <> '' Then
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString
                                      Else
                                       MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                     End
                                    Else
                                     Begin
                                      If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.AsString Then
                                       Begin
                                        MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
                                        MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
                                       End;
                                     End;
                                   End;
       ftBytes, ftVarBytes,
       ftBlob, ftGraphic,
       ftOraBlob, ftOraClob      : Begin
                                    vStringStream := TMemoryStream.Create;
                                    Try
                                     If TBlobField(Field).Size > 0 Then
                                      Begin
                                       TBlobField(Field).SaveToStream(vStringStream);
                                       vStringStream.Position := 0;
                                       If Not UpdateTag Then
                                        MassiveLineBuff.vMassiveValues.Items[I + 1].LoadFromStream(vStringStream)
                                       Else
                                        Begin
                                         If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> StreamToHex(vStringStream) Then
                                          MassiveLineBuff.vMassiveValues.Items[I + 1].LoadFromStream(vStringStream);
                                        End;
                                      End
                                     Else
                                      MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
                                    Finally
                                     FreeAndNil(vStringStream);
                                    End;
                                   End;
       Else
        Begin
         If Not UpdateTag Then
          Begin
           If Trim(Field.AsString) <> '' Then
            MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString
           Else
            MassiveLineBuff.vMassiveValues.Items[I + 1].Value := '';
          End
         Else
          Begin
           If MassiveLineBuff.vMassiveValues.Items[I + 1].Value <> Field.AsString Then
            Begin
             MassiveLineBuff.vMassiveValues.Items[I + 1].Value := Field.AsString;
             MassiveLineBuff.vChanges.Add(Uppercase(Field.FieldName));
            End;
          End;
        End;
      End;
     End;
   End;
 End;
Begin
 MassiveLineBuff.vMassiveMode := MassiveModeBuff;
 Case MassiveModeBuff Of
  mmInsert : CopyValue(MassiveModeBuff);
  mmUpdate : CopyValue(MassiveModeBuff);
  mmDelete : Begin
              NewBuffer(MassiveModeBuff);
              CopyValue(MassiveModeBuff);
             End;
 End;
End;

Function TMassiveDatasetBuffer.AtualRec : TMassiveLine;
Begin
 If RecordCount > 0 Then
  Result := vMassiveBuffer.Items[vRecNo -1];
End;

Procedure TMassiveDatasetBuffer.BuildBuffer(Dataset     : TRESTDWClientSQLBase;
                                            MassiveMode : TMassiveMode;
                                            UpdateTag   : Boolean = False);
Begin
 Case MassiveMode Of
  mmInactive : Begin
                vMassiveBuffer.ClearAll;
                vMassiveLine.ClearAll;
                vMassiveFields.ClearAll;
               End;
  mmBrowse   : vMassiveLine.ClearAll;
  Else
   BuildLine(Dataset, MassiveMode, vMassiveLine, UpdateTag);
 End;
End;

Procedure TMassiveDatasetBuffer.BuildDataset(Dataset         : TRESTDWClientSQLBase;
                                             UpdateTableName : String);
Var
 I : Integer;
 MassiveField : TMassiveField;
Begin
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
 For I := 0 To Dataset.Fields.Count -1 Do
  Begin
   If (Dataset.Fields[I].FieldKind = fkData) And (Not(Dataset.Fields[I].ReadOnly)) Then
    Begin
     MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
     MassiveField.vRequired          := Dataset.Fields[I].Required;
     MassiveField.vKeyField          := pfInKey in Dataset.Fields[I].ProviderFlags;
     MassiveField.vFieldName         := Dataset.Fields[I].FieldName;
     MassiveField.vFieldType         := FieldTypeToObjectValue(Dataset.Fields[I].DataType);
     MassiveField.vSize              := Dataset.Fields[I].DataSize;
     {$IFNDEF FPC}{$IF CompilerVersion > 21}
     MassiveField.vAutoGenerateValue := Dataset.Fields[I].AutoGenerateValue = arAutoInc;
     {$ELSE}
     MassiveField.vAutoGenerateValue := False;
     {$IFEND}
     {$ENDIF}
     vMassiveFields.Add(MassiveField);
    End;
  End;
 If vMassiveFields.Count > 0 Then
  vMassiveLine.vMassiveMode := mmBrowse;
 vTableName := UpdateTableName;
End;

Procedure TMassiveDatasetBuffer.ClearBuffer;
Begin
 vMassiveBuffer.ClearAll;
End;

Procedure TMassiveDatasetBuffer.ClearLine;
Begin
 vMassiveLine.ClearAll;
End;

Procedure TMassiveDatasetBuffer.ClearDataset;
Begin
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
End;

Constructor TMassiveDatasetBuffer.Create;
Begin
 vRecNo         := -1;
 vMassiveBuffer := TMassiveBuffer.Create;
 vMassiveLine   := TMassiveLine.Create;
 vMassiveFields := TMassiveFields.Create(Self);
 vMassiveMode   := mmInactive;
 vTableName     := '';
End;

Destructor TMassiveDatasetBuffer.Destroy;
Begin
 FreeAndNil(vMassiveBuffer);
 FreeAndNil(vMassiveLine);
 FreeAndNil(vMassiveFields);
 Inherited;
End;

Procedure TMassiveDatasetBuffer.First;
Begin
 If RecordCount > 0 Then
  Begin
   vRecNo := 1;
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.Last;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo <> RecordCount Then
    vRecNo := RecordCount;
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.NewBuffer(Var MassiveLineBuff : TMassiveLine;
                                          MassiveModeData     : TMassiveMode);
Begin
 MassiveLineBuff.ClearAll;
 MassiveLineBuff.vMassiveMode := MassiveModeData;
 NewLineBuffer(MassiveLineBuff, MassiveModeData); //Sempre se assume mmInsert como padr�o
End;

Procedure TMassiveDatasetBuffer.NewBuffer(Dataset         : TRESTDWClientSQLBase;
                                          MassiveModeData : TMassiveMode);
Begin
 vMassiveLine.ClearAll;
 vMassiveLine.vMassiveMode := MassiveModeData;
 NewLineBuffer(vMassiveLine, MassiveModeData); //Sempre se assume mmInsert como padr�o
 BuildLine(Dataset, MassiveModeData, vMassiveLine);//Sempre se assume mmInsert como padr�o
End;

Procedure TMassiveDatasetBuffer.NewBuffer(MassiveModeData     : TMassiveMode);
Begin
 vMassiveLine.ClearAll;
 vMassiveLine.vMassiveMode := MassiveModeData;
 NewLineBuffer(vMassiveLine, MassiveModeData); //Sempre se assume mmInsert como padr�o
End;

Procedure TMassiveDatasetBuffer.Next;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo < RecordCount Then
    Inc(vRecNo);
   ReadStatus;
  End;
End;

Function TMassiveDatasetBuffer.PrimaryKeys : TStringList;
Var
 I : Integer;
Begin
 Result := TStringList.Create;
 If vMassiveFields <> Nil Then
  Begin
   For I := 0 To vMassiveFields.Count -1 Do
    Begin
     If vMassiveFields.Items[I].vKeyField Then
      Result.Add(vMassiveFields.Items[I].vFieldName);
    End;
  End;
End;

Procedure TMassiveDatasetBuffer.Prior;
Begin
 If RecordCount > 0 Then
  Begin
   If vRecNo > 1 Then
    Dec(vRecNo);
   ReadStatus;
  End;
End;

Procedure TMassiveDatasetBuffer.ReadStatus;
Begin
 If RecordCount > 0 Then
  vMassiveMode := StringToMassiveMode(vMassiveBuffer.Items[vRecNo -1].vMassiveValues.Items[0].Value)
 Else
  vMassiveMode := mmInactive;
End;

Function TMassiveDatasetBuffer.RecNo : Integer;
Begin
 Result := vRecNo;
End;

Function TMassiveDatasetBuffer.RecordCount : Integer;
Begin
 Result := vMassiveBuffer.Count;
End;

Procedure TMassiveDatasetBuffer.SaveBuffer(Dataset : TRESTDWClientSQLBase);
Var
 I, A          : Integer;
 Field         : TField;
 vStringStream : TMemoryStream;
 MassiveLine   : TMassiveLine;
 MassiveValue  : TMassiveValue;
Begin
 MassiveLine   := TMassiveLine.Create;
 NewBuffer(MassiveLine, vMassiveLine.vMassiveMode);
 Try
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    If I = 0 Then
     MassiveLine.vMassiveValues.Items[I].Value := vMassiveLine.vMassiveValues.Items[I].Value;
    Field := Dataset.FindField(vMassiveFields.Items[I].vFieldName);
    If vMassiveLine.vMassiveMode = mmDelete Then
     If Not(pfInKey in Field.ProviderFlags) Then
      Continue;
    If Field <> Nil Then
     Begin
      If Field.DataType  In [ftBytes, ftVarBytes,
                             ftBlob, ftGraphic,
                             ftOraBlob, ftOraClob] Then
       Begin
        vStringStream := TMemoryStream.Create;
        Try
         vMassiveLine.vMassiveValues.Items[I +1].SaveToStream(vStringStream);
         vStringStream.Position := 0;
         If vStringStream.Size > 0 Then
          MassiveLine.vMassiveValues.Items[I +1].LoadFromStream(vStringStream);
        Finally
         FreeAndNil(vStringStream);
        End;
       End
      Else
       Begin
        If vMassiveLine.vMassiveValues.Items[I +1].Value <> '' Then
         MassiveLine.vMassiveValues.Items[I +1].Value := vMassiveLine.vMassiveValues.Items[I +1].Value;
       End;
     End;
   End;
 Finally
  //Update Changes
  For A := 0 To vMassiveLine.vChanges.Count -1 do
   MassiveLine.vChanges.Add(vMassiveLine.vChanges[A]);
  //KeyValues to Update
  If vMassiveLine.vPrimaryValues <> Nil Then
   Begin
    If vMassiveLine.vPrimaryValues.Count > 0 Then
     Begin
      If MassiveLine.vPrimaryValues = Nil Then
       MassiveLine.vPrimaryValues := TMassiveValues.Create;
      For A := 0 To vMassiveLine.vPrimaryValues.Count -1 do
       Begin
        MassiveValue  := TMassiveValue.Create;
        MassiveValue.Value := vMassiveLine.vPrimaryValues.Items[A].Value;
        MassiveLine.vPrimaryValues.Add(MassiveValue);
       End;
     End;
   End;
  vMassiveBuffer.Add(MassiveLine);
  vMassiveLine.ClearAll;
 End;
End;

Procedure TMassiveDatasetBuffer.FromJSON(Value : String);
Var
 bJsonOBJ,
 bJsonOBJb,
 bJsonValue  : udwjson.TJsonObject;
 bJsonArray,
 bJsonArrayB,
 bJsonArrayC,
 bJsonArrayD,
 bJsonArrayE  : udwjson.TJsonArray;
 MassiveValue : TMassiveValue;
 A, C,
 D, E, I      : Integer;
 MassiveField : TMassiveField;
 MassiveLine  : TMassiveLine;
 Function GetFieldIndex(FieldName : String) : Integer;
 Var
  I : Integer;
 Begin
  Result := -1;
  For I := 0 To vMassiveFields.Count -1 Do
   Begin
    If LowerCase(vMassiveFields.Items[I].FieldName) = LowerCase(FieldName) Then
     Result := I;
    If Result <> -1 Then
     Break;
   End;
 End;
Begin
 bJsonValue := udwjson.TJsonObject.Create(Value);
 vMassiveBuffer.ClearAll;
 vMassiveLine.ClearAll;
 vMassiveFields.ClearAll;
 Try
  vTableName  := bJsonValue.opt(bJsonValue.names.get(4).ToString).ToString;
  bJsonArray  := bJsonValue.optJSONArray(bJsonValue.names.get(5).ToString);
  For A := 0 To 1 Do
   Begin
    If A = 0 Then //Fields
     Begin
      bJsonOBJ    := udwjson.TJsonObject.Create(bJsonArray.get(A).ToString); //bJsonOBJ.names.get(0).ToString);
      Try
       bJsonArrayB := bJsonOBJ.optJSONArray('fields');
       For I := 0 To bJsonArrayB.Length - 1 Do
        Begin
         bJsonOBJb := udwjson.TJsonObject.Create(bJsonArrayB.get(I).ToString);
         Try
          MassiveField                    := TMassiveField.Create(vMassiveFields, vMassiveFields.Count);
          MassiveField.vRequired          := bJsonOBJb.opt('Required').ToString       = 'S';
          MassiveField.vKeyField          := bJsonOBJb.opt('Primary').ToString        = 'S';
          MassiveField.vFieldName         := bJsonOBJb.opt('field').ToString;
          MassiveField.vFieldType         := GetValueType(bJsonOBJb.opt('Type').ToString);
          MassiveField.vSize              := StrToInt(bJsonOBJb.opt('Size').ToString);
          {$IFNDEF FPC}{$IF CompilerVersion > 21}
          MassiveField.vAutoGenerateValue := bJsonOBJb.opt('Autogeneration').ToString = 'S';
          {$ELSE}
          MassiveField.vAutoGenerateValue := False;
          {$IFEND}
          {$ENDIF}
          vMassiveFields.Add(MassiveField);
         Finally
          bJsonOBJb.Clean;
          FreeAndNil(bJsonOBJb);
         End;
        End;
      Finally
       bJsonOBJ.Clean;
       FreeAndNil(bJsonOBJ);
      End;
     End
    Else //Data
     Begin
      bJsonOBJ    := udwjson.TJsonObject.Create(bJsonArray.get(A).ToString); //bJsonOBJ.names.get(0).ToString);
      bJsonArrayB := bJsonOBJ.optJSONArray('lines');
      For E := 0 to bJsonArrayB.length -1  Do
       Begin
        bJsonArrayC := bJsonArrayB.getJSONArray(E);
        Try
         bJsonArrayD  := bJsonArrayC.getJSONArray(0); //Line
         vMassiveMode := StringToMassiveMode(bJsonArrayD.opt(0).tostring);
         MassiveLine  := TMassiveLine.Create;
         NewLineBuffer(MassiveLine, vMassiveMode); //Sempre se assume MassiveMode vindo na String
         If vMassiveMode = mmUpdate Then
          Begin
           If bJsonArrayD.length > 1 Then
            Begin
             bJsonArrayE  := bJsonArrayC.getJSONArray(2); //Campos Alterados
             For D := 0 To bJsonArrayE.length -1 Do //Valores
              MassiveLine.vChanges.Add(bJsonArrayE.opt(D).tostring);
             bJsonArrayE  := bJsonArrayC.getJSONArray(1); //Key Primary
             For D := 0 To bJsonArrayE.length -1 Do //Valores
              Begin
               MassiveValue       := TMassiveValue.Create;
               If vMassiveFields.Items[D].vFieldType in [ovString, ovWideString, ovFixedChar, ovFixedWideChar] Then
                Begin
                 If lowercase(bJsonArrayE.opt(D).tostring) <> 'null' then
                  MassiveValue.Value := DecodeStrings(bJsonArrayE.opt(D).tostring{$IFDEF FPC}, csUndefined{$ENDIF})
                 Else
                  MassiveValue.Value := bJsonArrayE.opt(D).tostring;
                End
               Else
                MassiveValue.Value := bJsonArrayE.opt(D).tostring;
               If Not Assigned(MassiveLine.vPrimaryValues) Then
                MassiveLine.vPrimaryValues := TMassiveValues.Create;
               MassiveLine.vPrimaryValues.Add(MassiveValue);
              End;
            End;
           For C := 1 To bJsonArrayD.length -1 Do //Valores
            Begin
             If vMassiveFields.Items[GetFieldIndex(MassiveLine.vChanges[C-1])].vFieldType in [ovString, ovWideString, ovFixedChar, ovFixedWideChar] Then
              Begin
               If lowercase(bJsonArrayD.opt(C).tostring) <> 'null' then
                MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := DecodeStrings(bJsonArrayD.opt(C).tostring{$IFDEF FPC}, csUndefined{$ENDIF})
               Else
                MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := bJsonArrayD.opt(C).tostring;
              End
             Else
              MassiveLine.Values[GetFieldIndex(MassiveLine.vChanges[C-1]) +1].Value := bJsonArrayD.opt(C).tostring;
            End;
          End
         Else
          Begin
           For C := 1 To bJsonArrayD.length -1 Do //Valores
            Begin
             If vMassiveFields.Items[C-1].vFieldType in [ovString, ovWideString, ovFixedChar, ovFixedWideChar] Then
              Begin
               If lowercase(bJsonArrayD.opt(C).tostring) <> 'null' then
                MassiveLine.Values[C].Value := DecodeStrings(bJsonArrayD.opt(C).tostring{$IFDEF FPC}, csUndefined{$ENDIF})
               Else
                MassiveLine.Values[C].Value := bJsonArrayD.opt(C).tostring;
              End
             Else
              MassiveLine.Values[C].Value := bJsonArrayD.opt(C).tostring;
            End;
          End;
        Finally
         vMassiveBuffer.Add(MassiveLine);
        End;
       End;
      FreeAndNil(bJsonOBJ);
     End;
   End;
 Finally
  bJsonValue.Free;
 End;
End;

Function TMassiveDatasetBuffer.ToJSON : String;
Var
 A           : Integer;
 vLines,
 vTagFields  : String;
 Function GenerateHeader: String;
 Var
  I              : Integer;
  vPrimary,
  vRequired,
  vReadOnly,
  vGenerateLine,
  vAutoinc       : string;
 Begin
  For I := 0 To vMassiveFields.Count - 1 Do
   Begin
    vPrimary  := 'N';
    vAutoinc  := 'N';
    vReadOnly := 'N';
    If vMassiveFields.Items[I].vKeyField Then
     vPrimary := 'S';
    vRequired := 'N';
    If vMassiveFields.Items[I].vRequired Then
     vRequired := 'S';
    {$IFNDEF FPC}{$IF CompilerVersion > 21}
     If vMassiveFields.Items[I].vAutoGenerateValue Then
      vAutoinc := 'S';
    {$ELSE}
     vAutoinc := 'N';
    {$IFEND}
    {$ENDIF}
    If vMassiveFields.Items[I].FieldType In [{$IFNDEF FPC}{$IF CompilerVersion > 21}ovExtended,
                                             {$IFEND}{$ENDIF}ovFloat, ovCurrency, ovFMTBcd, ovBCD] Then
     vGenerateLine := Format(TJsonDatasetHeader, [vMassiveFields.Items[I].vFieldName,
                                                  GetValueType(vMassiveFields.Items[I].FieldType),
                                                  vPrimary, vRequired, vMassiveFields.Items[I].Size,
                                                  vMassiveFields.Items[I].Precision, vReadOnly, vAutoinc])
    Else
     vGenerateLine := Format(TJsonDatasetHeader, [vMassiveFields.Items[I].vFieldName,
                                                  GetValueType(vMassiveFields.Items[I].FieldType),
                                                  vPrimary, vRequired, vMassiveFields.Items[I].Size, 0, vReadOnly, vAutoinc]);
    If I = 0 Then
     Result := vGenerateLine
    Else
     Result := Result + ', ' + vGenerateLine;
   End;
 End;
 Function GenerateLine(MassiveLineBuff : TMassiveLine) : String;
 Var
  A, I          : Integer;
  vTempLine,
  vTempComp,
  vTempKeys,
  vTempValue    : String;
  vMassiveMode  : TMassiveMode;
  vNoChange     : Boolean;
 Begin
  For I := 0 To MassiveLineBuff.vMassiveValues.Count - 1 Do
   Begin
    If I = 0 Then
     vMassiveMode  := StringToMassiveMode(MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value)
    Else
     Begin
      If vMassiveMode = mmUpdate Then
       Begin
        If MassiveLineBuff.vChanges.Count = 0 Then
         Continue;
        vNoChange := True;
        For A := 0 To MassiveLineBuff.vChanges.Count -1 Do
         Begin
          vNoChange := Lowercase(vMassiveFields.Items[I-1].vFieldName) <>
                       Lowercase(MassiveLineBuff.vChanges[A]);
          If Not (vNoChange) Then
           Break;
         End;
        If vNoChange Then
         Continue;
       End;
     End;
    If MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.IsNull Then
     vTempValue := Format('"%s"', ['null'])
    Else
     Begin
      If I = 0 Then
       vTempValue    := Format('"%s"', [MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value])    //asstring
      Else
       Begin
        If vMassiveFields.Items[I-1].vFieldType in [ovString, ovWideString, ovFixedChar, ovFixedWideChar] Then
         vTempValue    := Format('"%s"', [EncodeStrings(MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value{$IFDEF FPC}, csUndefined{$ENDIF})])
        Else
         vTempValue    := Format('"%s"', [MassiveLineBuff.vMassiveValues.Items[I].vJSONValue.Value])
       End;
     End;
    If I = 0 Then
     vTempLine := vTempValue
    Else
     vTempLine := vTempLine + ', ' + vTempValue;
   End;
  vTempLine := '[' + vTempLine + ']';
  If MassiveLineBuff.vChanges.Count > 0 Then
   Begin
    For A := 0 To MassiveLineBuff.vChanges.Count -1 Do
     Begin
      vTempValue := Format('"%s"', [MassiveLineBuff.vChanges[A]]);    //asstring
      If A = 0 Then
       vTempKeys := vTempValue
      Else
       vTempKeys := vTempKeys + ', ' + vTempValue;
     End;
    vTempKeys := '[' + vTempKeys + ']';
   End;
  If MassiveLineBuff.vPrimaryValues <> Nil Then
   Begin
    For I := 0 To MassiveLineBuff.vPrimaryValues.Count - 1 Do
     Begin
      If MassiveLineBuff.vPrimaryValues.Items[I].vJSONValue.IsNull Then
       vTempValue := Format('"%s"', ['null'])
      Else
       vTempValue    := Format('"%s"', [MassiveLineBuff.vPrimaryValues.Items[I].vJSONValue.Value]);    //asstring
      If I = 0 Then
       vTempComp := vTempValue
      Else
       vTempComp := vTempComp + ', ' + vTempValue;
     End;
    If MassiveLineBuff.vPrimaryValues.Count > 0 Then
     vTempComp := '[' + vTempComp + ']';
   End;
  If (vTempComp <> '') And (vTempKeys <> '') Then
   Result := Format('%s,%s,%s', [vTempLine, vTempComp, vTempKeys])
  Else
   Result := vTempLine;
 End;
Begin
 vTagFields  := '{"fields":[' + GenerateHeader + ']}, {"lines":[%s]}';
 For A := 0 To vMassiveBuffer.Count -1 Do
  Begin
   If A = 0 Then
    vLines := Format('[%s]', [GenerateLine(vMassiveBuffer.Items[A])])
   Else
    vLines := vLines + Format(', [%s]', [GenerateLine(vMassiveBuffer.Items[A])]);
  End;
 vTagFields := Format(vTagFields, [vLines]);
 Result := Format(TMassiveFormatJSON, ['ObjectType',   GetObjectName(toMassive),
                                       'Direction',    GetDirectionName(odINOUT),
                                       'Encoded',      'true',
                                       'ValueType',    GetValueType(ovObject),
                                       'TableName',    vTableName,
                                       'MassiveValue', vTagFields]);
End;

End.
