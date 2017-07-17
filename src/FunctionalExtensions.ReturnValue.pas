{
MIT License

Copyright (c) 2017 Jamie Geddes

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
}

unit FunctionalExtensions.ReturnValue;

interface

type
  ReturnValue = record
  private
    _isSuccess: Boolean;

    _error: string;

    class var OkReturnValue: ReturnValue;

    constructor Create(const isSuccess: Boolean;
                       const error:     string);

    function GetIsSuccess: Boolean;
    function GetIsFailure: Boolean;

    function GetError: string;

  public
    class constructor Create;

    class function Ok: ReturnValue; static;
    class function Fail(const error: string): ReturnValue; static;

    class function FirstFailureOrSuccess(const results: array of ReturnValue): ReturnValue; static;

    property IsSuccess: Boolean read GetIsSuccess;
    property IsFailure: Boolean read GetIsFailure;

    property Error: string read GetError;
  end;


  ReturnValue<T: class> = record
  private
    _value: T;

    _error: string;

    _failure: Boolean;

    function GetValue: T;
    function GetError: string;

    constructor Create(const isFailure: Boolean;
                       const value:     T;
                       const error:     string);

  public
    function IsSuccess: Boolean;
    function IsFailure: Boolean;

    class operator Implicit(const value: ReturnValue<T>): ReturnValue;

    property Value: T read GetValue;

    property Error: string read GetError;
  end;

implementation

uses
  System.SysUtils;

{ ReturnValue }

class constructor ReturnValue.Create;
begin
  OkReturnValue := ReturnValue.Create(true, string.Empty);
end;

constructor ReturnValue.Create(const isSuccess: Boolean;
                               const error:     string);
begin
  if(error.IsNullOrWhiteSpace(error)) then raise Exception.Create('error');
  if(isSuccess and not error.IsNullOrWhiteSpace(error)) then raise Exception.Create('error string should not be set for success');
  if(not isSuccess) and (error.IsEmpty) then raise Exception.Create('error string must be specified for error cases');

  _isSuccess := isSuccess;
  _error := error;
end;

class function ReturnValue.Ok: ReturnValue;
begin
  Result := OkReturnValue;
end;

class function ReturnValue.Fail(const error: string): ReturnValue;
begin
  Result := ReturnValue.Create(false, error);
end;

function ReturnValue.GetIsSuccess: Boolean;
begin
  Result := _isSuccess;
end;

function ReturnValue.GetIsFailure: Boolean;
begin
  Result := not _isSuccess;
end;

function ReturnValue.GetError: string;
begin
  Result := _error;
end;

class function ReturnValue.FirstFailureOrSuccess(const results: array of ReturnValue): ReturnValue;
var
  index: Integer;
  resultObj: ReturnValue;
begin
  for Index := Low(results) to High(results) do
  begin
    resultObj := results[Index];
    if(resultObj.IsFailure) then
    begin
      Exit(Fail(resultObj.Error));
    end;
  end;

  Result := Ok;
end;


{ ReturnValue<T> }

constructor ReturnValue<T>.Create(const isFailure: Boolean;
                                  const value:     T;
                                  const error:     string);
begin
  if(not isFailure) and ( value = Nil) then raise Exception.Create( 'no value assigned for success');

  if(isFailure) then
  begin
    if(String.IsNullOrWhiteSpace(error)) then raise Exception.Create('There must be an error message for failure.');
  end
  else begin
    if(not String.IsNullOrWhiteSpace(error)) then raise Exception.Create('There should be no error message for success.');
  end;

  _value := value;
  _error := error;
  _failure := isFailure;
end;

function ReturnValue<T>.IsSuccess: Boolean;
begin
  Result := not _failure;
end;

function ReturnValue<T>.IsFailure: Boolean;
begin
  Result := _failure;
end;

function ReturnValue<T>.GetValue: T;
begin
  if(not IsSuccess) then raise Exception.Create('No value for failure');

  Result := _value;
end;

function ReturnValue<T>.GetError: string;
begin
  if(IsSuccess) then raise Exception.Create('No error message for success');

  Result := _error;
end;

class operator ReturnValue<T>.Implicit(const value: ReturnValue<T>): ReturnValue;
begin
  if(value.IsSuccess) then Result := ReturnValue.Ok
  else Result := ReturnValue.Fail(value.Error);
end;

end.

